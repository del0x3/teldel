<#
.SYNOPSIS
    Wireless ADB Connection Guardian & Watchdog (teldel).
.DESCRIPTION
    Manages secure, autonomous wireless connectivity between PC and Android device over Wi-Fi.
    Supports auto-reconnect watchdog, instant connect, and secure session teardown.
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

function Get-SavedIp {
    if ($Ip) { return $Ip }
    if (Test-Path $cfgFile) {
        try {
            $cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
            if ($cfg.last_ip) { return $cfg.last_ip }
        } catch {}
    }
    return "192.168.0.108"
}

$targetIp = Get-SavedIp
$endpoint = "${targetIp}:${Port}"

switch ($Action) {
    "arm" {
        Write-Host "[+] Querying connected device for Wi-Fi IP and arming TCP port $Port..." -ForegroundColor Cyan
        $devIp = (& $ADB shell "ip -4 addr show wlan0 2>/dev/null | grep -o 'inet [0-9.]*' | cut -d ' ' -f 2" | Out-String).Trim()
        if ($devIp) {
            & $ADB tcpip $Port
            $cfg = @{ last_ip = $devIp; port = $Port; auto_connect = $true }
            $cfg | ConvertTo-Json | Set-Content $cfgFile -Encoding UTF8
            Write-Host "[SUCCESS] Device armed! Wi-Fi IP: $devIp on port $Port" -ForegroundColor Green
            Write-Host "You can now safely unplug the USB cable." -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] Could not detect Wi-Fi IP on device. Ensure phone is connected to Wi-Fi." -ForegroundColor Red
        }
    }
    "connect" {
        Write-Host "[+] Connecting wirelessly to $endpoint..." -ForegroundColor Cyan
        $res = (& $ADB connect $endpoint 2>&1 | Out-String).Trim()
        Write-Host $res -ForegroundColor Green
        
        $devs = (& $ADB devices | Out-String)
        if ($devs -match "$endpoint\tdevice") {
            Write-Host "[SUCCESS] Device connected and authorized over Wi-Fi!" -ForegroundColor Green
        } else {
            Write-Host "[!] Wireless session not established. Ensure phone is on same Wi-Fi and port $Port is armed." -ForegroundColor Yellow
        }
    }
    "disconnect" {
        Write-Host "[+] Dropping wireless ADB session for security..." -ForegroundColor Yellow
        & $ADB disconnect $endpoint | Out-Host
        Write-Host "[SUCCESS] Wireless session closed." -ForegroundColor Green
    }
    "status" {
        Write-Host "Target Phone Endpoint: $endpoint" -ForegroundColor Cyan
        $devs = (& $ADB devices | Out-String)
        Write-Host $devs -ForegroundColor White
    }
    "watch" {
        Write-Host "==========================================================================" -ForegroundColor Cyan
        Write-Host "   WIRELESS ADB WATCHDOG ACTIVE - AUTO-RECONNECT GUARDIAN               " -ForegroundColor Yellow
        Write-Host "==========================================================================" -ForegroundColor Cyan
        Write-Host "Monitoring phone at $endpoint. Press Ctrl+C to stop." -ForegroundColor Gray
        
        while ($true) {
            $devs = (& $ADB devices 2>$null | Out-String)
            if ($devs -notmatch "$endpoint\tdevice") {
                $ping = Test-Connection -ComputerName $targetIp -Count 1 -Quiet -ErrorAction SilentlyContinue
                if ($ping) {
                    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Phone detected online. Auto-connecting..." -ForegroundColor Cyan
                    & $ADB connect $endpoint 2>$null | Out-Null
                }
            }
            Start-Sleep -Seconds 5
        }
    }
}
