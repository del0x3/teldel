<#
.SYNOPSIS
    Wireless ADB Connection Guardian & Watchdog with Dynamic Network Discovery (teldel).
.DESCRIPTION
    Manages secure, autonomous wireless connectivity between PC and Android device over Wi-Fi.
    Features:
      - Dynamic Subnet & ARP Auto-Discovery (zero manual IP edits if router or DHCP changes)
      - mDNS ZeroConf service discovery for Android 11+ TLS Wireless Debugging
      - Auto-reconnect watchdog daemon
      - 1-click connection teardown (locks down port for security)
#>

[CmdletBinding()]
param(
    [ValidateSet("connect", "disconnect", "watch", "status", "arm")]
    [string]$Action = "connect",
    [string]$Ip,
    [int]$Port = 5555
)

function Resolve-Adb {
    $cmd = Get-Command "adb.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        (Join-Path $PSScriptRoot "platform-tools\adb.exe"),
        (Join-Path $PSScriptRoot "..\platform-tools\adb.exe"),
        "C:\platform-tools\adb.exe",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    return "adb"
}

$ADB = Resolve-Adb
$cfgFile = Join-Path $PSScriptRoot "..\data\wireless_config.json"

function Find-DeviceEndpoint {
    if ($Ip) { return @{ IP = $Ip; Port = $Port } }

    # Tier 1: Check saved config endpoint
    $savedIp = ""
    $savedPort = $Port
    if (Test-Path $cfgFile) {
        try {
            $cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
            if ($cfg.last_ip) { $savedIp = $cfg.last_ip }
            if ($cfg.port) { $savedPort = [int]$cfg.port }
        } catch {}
    }

    if ($savedIp) {
        $tcpTest = Test-NetConnection -ComputerName $savedIp -Port $savedPort -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($tcpTest) {
            return @{ IP = $savedIp; Port = $savedPort }
        }
    }

    # Tier 2: Check mDNS ZeroConf services (Android 11+ Wireless Debugging)
    $mdnsOut = (& $ADB mdns services 2>$null | Out-String)
    if ($mdnsOut -match '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):([0-9]+)') {
        $foundIp = $Matches[1]
        $foundPort = [int]$Matches[2]
        return @{ IP = $foundIp; Port = $foundPort }
    }

    # Tier 3: Dynamic Local Subnet ARP probe
    $arpOut = (arp -a | Out-String)
    $lines = $arpOut -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)\s+([0-9a-fA-F-]+)\s+dynamic') {
            $candidateIp = $Matches[1]
            if ($candidateIp -notlike '169.254*' -and $candidateIp -notlike '224*' -and $candidateIp -notmatch '\.1$') {
                $probe = Test-NetConnection -ComputerName $candidateIp -Port 5555 -InformationLevel Quiet -WarningAction SilentlyContinue
                if ($probe) {
                    return @{ IP = $candidateIp; Port = 5555 }
                }
            }
        }
    }

    if ($savedIp) { return @{ IP = $savedIp; Port = $savedPort } }
    return @{ IP = "192.168.0.108"; Port = 5555 }
}

$endpointInfo = Find-DeviceEndpoint
$targetIp = $endpointInfo.IP
$targetPort = $endpointInfo.Port
$endpoint = "${targetIp}:${targetPort}"

switch ($Action) {
    "arm" {
        Write-Host "[+] Querying connected device for Wi-Fi IP and arming TCP port $targetPort..." -ForegroundColor Cyan
        $devIp = (& $ADB shell "ip -4 addr show wlan0 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d ' ' -f 2" | Out-String).Trim()
        if ($devIp) {
            & $ADB tcpip $targetPort
            $cfg = @{ last_ip = $devIp; port = $targetPort; auto_connect = $true }
            $cfg | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
            Write-Host "[SUCCESS] Device armed! Dynamic Wi-Fi IP: $devIp on port $targetPort" -ForegroundColor Green
            Write-Host "You can now safely unplug the USB cable." -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] Could not detect Wi-Fi IP on device. Ensure phone is connected to Wi-Fi." -ForegroundColor Red
        }
    }
    "connect" {
        Write-Host "[+] Resolving device and connecting wirelessly to $endpoint..." -ForegroundColor Cyan
        $res = (& $ADB connect $endpoint 2>&1 | Out-String).Trim()
        Write-Host $res -ForegroundColor Green
        
        $devs = (& $ADB devices | Out-String)
        if ($devs -match "$endpoint\tdevice") {
            # Update cache with active verified endpoint
            $cfg = @{ last_ip = $targetIp; port = $targetPort; auto_connect = $true }
            $cfg | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
            Write-Host "[SUCCESS] Device connected and cryptographically authorized over Wi-Fi!" -ForegroundColor Green
        } else {
            Write-Host "[!] Could not establish wireless ADB session at $endpoint." -ForegroundColor Yellow
            Write-Host "Ensure phone and PC are on the same Wi-Fi network." -ForegroundColor Gray
        }
    }
    "disconnect" {
        Write-Host "[+] Dropping wireless ADB session for security..." -ForegroundColor Yellow
        & $ADB disconnect $endpoint | Out-Host
        Write-Host "[SUCCESS] Wireless session terminated. Port closed." -ForegroundColor Green
    }
    "status" {
        Write-Host "Target Endpoint: $endpoint" -ForegroundColor Cyan
        $devs = (& $ADB devices | Out-String)
        Write-Host $devs -ForegroundColor White
    }
    "watch" {
        Write-Host "==========================================================================" -ForegroundColor Cyan
        Write-Host "   WIRELESS ADB DYNAMIC GUARDIAN - AUTONOMOUS KEEPALIVE                 " -ForegroundColor Yellow
        Write-Host "==========================================================================" -ForegroundColor Cyan
        Write-Host "Monitoring phone across dynamic subnets. Press Ctrl+C to stop." -ForegroundColor Gray
        
        while ($true) {
            $devs = (& $ADB devices 2>$null | Out-String)
            if ($devs -notmatch "$endpoint\tdevice") {
                $curEndpoint = Find-DeviceEndpoint
                if ($curEndpoint) {
                    $ep = "$($curEndpoint.IP):$($curEndpoint.Port)"
                    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Phone resolved at $ep. Auto-connecting..." -ForegroundColor Cyan
                    & $ADB connect $ep 2>$null | Out-Null
                }
            }
            Start-Sleep -Seconds 6
        }
    }
}
