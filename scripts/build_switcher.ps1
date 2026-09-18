<#
.SYNOPSIS
    Compiles, signs, and deploys the Teldel Switcher APK to Android.
#>

[CmdletBinding()]
param(
    [switch]$Install = $true
)

$ErrorActionPreference = "Continue"

$SDK_DIR = "$env:LOCALAPPDATA\Android\Sdk"
$BUILD_TOOLS = "$SDK_DIR\build-tools\36.1.0"
$PLATFORM_JAR = "$SDK_DIR\platforms\android-36\android.jar"

$AAPT2 = "$BUILD_TOOLS\aapt2.exe"
$D8 = "$BUILD_TOOLS\d8.bat"
$APKSIGNER = "$BUILD_TOOLS\apksigner.bat"
$JDK_BIN = "C:\Program Files\Microsoft\jdk-17.0.17.10-hotspot\bin"
$JAVAC = "$JDK_BIN\javac.exe"
$KEYTOOL = "$JDK_BIN\keytool.exe"

$ROOT_DIR = Split-Path $PSScriptRoot -Parent
$APP_DIR = Join-Path $ROOT_DIR "app"
$BUILD_DIR = Join-Path $ROOT_DIR "build\app_out"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "       BUILDING TELDEL SWITCHER NATIVE ANDROID APP              " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan

# Clean build directory
if (Test-Path $BUILD_DIR) { Remove-Item -Recurse -Force $BUILD_DIR }
New-Item -ItemType Directory -Force -Path "$BUILD_DIR\classes" | Out-Null
New-Item -ItemType Directory -Force -Path "$BUILD_DIR\dex" | Out-Null
New-Item -ItemType Directory -Force -Path "$ROOT_DIR\bin" | Out-Null

# 1. Compile Resources
Write-Host "[1/6] Compiling resources with aapt2..." -ForegroundColor Cyan
& $AAPT2 compile --dir "$APP_DIR\src\main\res" -o "$BUILD_DIR\res.zip"

# 2. Link Resources & Generate R.java
Write-Host "[2/6] Linking resources and generating R.java..." -ForegroundColor Cyan
& $AAPT2 link -I $PLATFORM_JAR `
    --manifest "$APP_DIR\src\main\AndroidManifest.xml" `
    -o "$BUILD_DIR\unaligned.apk" `
    -R "$BUILD_DIR\res.zip" `
    --java "$APP_DIR\src\main\java" `
    --min-sdk-version 26 `
    --target-sdk-version 36 `
    --auto-add-overlay

# 3. Compile Java classes
Write-Host "[3/6] Compiling Java classes with javac..." -ForegroundColor Cyan
$jarFiles = Get-ChildItem "$ROOT_DIR\build\shizuku_jars\*.jar" | Select-Object -ExpandProperty FullName
$classpath = "$PLATFORM_JAR;" + ($jarFiles -join ";")
$javaSources = Get-ChildItem "$APP_DIR\src\main\java" -Recurse -Filter *.java | Select-Object -ExpandProperty FullName

& $JAVAC -source 8 -target 8 -cp $classpath -d "$BUILD_DIR\classes" $javaSources

# 4. Dexing with d8
Write-Host "[4/6] Dexing bytecode with d8..." -ForegroundColor Cyan
$classFiles = Get-ChildItem "$BUILD_DIR\classes" -Recurse -Filter *.class | Select-Object -ExpandProperty FullName
$d8Args = @("--min-api", "26", "--output", "$BUILD_DIR\dex") + $classFiles + $jarFiles
& cmd.exe /c "$D8" $d8Args

# 5. Packaging classes.dex into APK
Write-Host "[5/6] Packaging classes.dex into APK..." -ForegroundColor Cyan
$dexFile = "$BUILD_DIR\dex\classes.dex"
$unalignedApk = "$BUILD_DIR\unaligned.apk"

python -c "
import zipfile, sys
apk_path = r'$unalignedApk'
dex_path = r'$dexFile'
with zipfile.ZipFile(apk_path, 'a', compression=zipfile.ZIP_DEFLATED) as z:
    z.write(dex_path, 'classes.dex')
"

# 6. Sign APK
Write-Host "[6/6] Signing APK with debug keystore..." -ForegroundColor Cyan
$keystore = "$ROOT_DIR\build\debug.keystore"
if (-not (Test-Path $keystore)) {
    & $KEYTOOL -genkey -v -keystore $keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
}

$finalApk = "$ROOT_DIR\bin\TeldelSwitcher.apk"
& cmd.exe /c "$APKSIGNER" sign --ks $keystore --ks-pass pass:android --out $finalApk $unalignedApk

Write-Host "[SUCCESS] Built $finalApk!" -ForegroundColor Green

if ($Install) {
    Write-Host "[+] Deploying Teldel Switcher to Android device..." -ForegroundColor Cyan
    & adb.exe connect 192.168.0.108:5555 2>$null | Out-Null
    & adb.exe install -r "$finalApk" | Out-Host
    Write-Host "[+] Granting Shizuku API permissions..." -ForegroundColor Cyan
    & adb.exe shell "pm grant com.teldel.switcher moe.shizuku.manager.permission.API_V23" 2>$null | Out-Null
    & adb.exe shell "cmd appops set com.teldel.switcher moe.shizuku.manager.permission.API_V23 allow" 2>$null | Out-Null
    Write-Host "[SUCCESS] Installed and authorized com.teldel.switcher!" -ForegroundColor Green
}
