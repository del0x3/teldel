# ==============================================================================
# Android Productivity Terminal & Dopamine Detox - Phone Manager
# ==============================================================================

function Resolve-Adb {
    # 1. Check system PATH
    $cmd = Get-Command "adb.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # 2. Check local platform-tools relative to script
    $localAdb = Join-Path $PSScriptRoot "platform-tools\adb.exe"
    if (Test-Path $localAdb) { return $localAdb }

    # 3. Check Android SDK in user AppData
    if ($env:LOCALAPPDATA) {
        $appDataAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
        if (Test-Path $appDataAdb) { return $appDataAdb }
    }

    # 4. Check common installation directories
    $candidates = @(
        "C:\platform-tools\adb.exe",
        "$env:ProgramFiles\Android\platform-tools\adb.exe",
        "${env:ProgramFiles(x86)}\Android\android-sdk\platform-tools\adb.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }

    return $null
}

$ADB = Resolve-Adb

function Show-Header {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "       ANDROID PRODUCTIVITY TERMINAL - PHONE MANAGER" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Временно ВКЛЮЧИТЬ Google Play Store  (для обновлений)" -ForegroundColor Green
    Write-Host "  [2] ВЫКЛЮЧИТЬ Google Play Store          (вернуть замок)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  [3] ВЫВЕСТИ ЭКРАН ТЕЛЕФОНА НА ПК         (scrcpy трансляция)" -ForegroundColor Cyan
    Write-Host "  [4] Переключить экран: Ч/Б <--> ЦВЕТ     (быстрый возврат цветов)" -ForegroundColor Magenta
    Write-Host "  [5] Экспресс-аудит батареи, памяти и безопасности" -ForegroundColor White
    Write-Host ""
    Write-Host "  [6] Заблокировать всё (Браузер + YouTube + Play Store + DoT)" -ForegroundColor Red
    Write-Host "  [7] Открыть интерактивные HTML-отчеты и Дофаминовый Дашборд" -ForegroundColor Blue
    Write-Host "  [8] Восстановить стандартные настройки Android (Откат)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [9] Выход" -ForegroundColor Gray
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Test-DeviceConnection {
    $devsText = (& $ADB devices | Out-String)
    if ($devsText -notmatch "\tdevice") {
        Write-Host "`n[ПРЕДУПРЕЖДЕНИЕ] Телефон не обнаружен через ADB!" -ForegroundColor Yellow
        Write-Host "1. Подключите телефон кабелем к ПК." -ForegroundColor DarkGray
        Write-Host "2. Включите 'Отладку по USB' в меню разработчика." -ForegroundColor DarkGray
        Write-Host "3. Подтвердите 'Разрешить отладку по USB' на экране телефона.`n" -ForegroundColor DarkGray
        return $false
    }
    return $true
}

if (-not $ADB) {
    Write-Host "[ОШИБКА] adb.exe не найден в PATH или стандартных папках Android SDK!" -ForegroundColor Red
    Write-Host "Скачайте platform-tools: https://developer.android.com/tools/releases/platform-tools" -ForegroundColor Yellow
    Write-Host "Или положите adb.exe в папку 'platform-tools' рядом со скриптом." -ForegroundColor Cyan
    Read-Host "`nНажмите Enter для выхода..."
    exit 1
}

$running = $true
while ($running) {
    Show-Header
    $rawChoice = Read-Host "Выберите пункт [1-9]"
    
    if ($null -eq $rawChoice) {
        break
    }
    
    $choice = $rawChoice.Trim()
    if ($choice -eq "") {
        continue
    }
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "=== Включение Google Play Store ===" -ForegroundColor Green
            if (Test-DeviceConnection) {
                & $ADB shell pm enable com.android.vending
                Write-Host "`n[+] ГОТОВО! Google Play Store доступен на телефоне." -ForegroundColor Green
                Write-Host "Обновите нужное приложение, затем вернитесь сюда и нажмите [2] для повторной заморозки.`n" -ForegroundColor Yellow
            }
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "2" {
            Clear-Host
            Write-Host "=== Заморозка Google Play Store ===" -ForegroundColor Red
            if (Test-DeviceConnection) {
                & $ADB shell pm disable-user --user 0 com.android.vending
                Write-Host "`n[+] ГОТОВО! Google Play Store снова заблокирован." -ForegroundColor Green
                Write-Host "Периметр закрыт.`n" -ForegroundColor Cyan
            }
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "3" {
            Clear-Host
            Write-Host "=== Запуск трансляции экрана телефона на ноутбук ===" -ForegroundColor Cyan
            $scrcpyCmd = Get-Command "scrcpy.exe" -ErrorAction SilentlyContinue
            $localScrcpy = Join-Path $PSScriptRoot "scrcpy.exe"
            
            if ($scrcpyCmd) {
                Start-Process "scrcpy.exe" -ArgumentList "--window-title", "Android Productivity Terminal"
                Write-Host "`n[+] Окно экрана телефона запущено через системный scrcpy!`n" -ForegroundColor Green
            } elseif (Test-Path $localScrcpy) {
                Start-Process $localScrcpy -ArgumentList "--window-title", "Android Productivity Terminal"
                Write-Host "`n[+] Окно экрана телефона запущено через локальный scrcpy!`n" -ForegroundColor Green
            } else {
                Write-Host "[!] scrcpy не обнаружен." -ForegroundColor Yellow
                Write-Host "Скачайте scrcpy: https://github.com/Genymobile/scrcpy/releases" -ForegroundColor Cyan
                Write-Host "Положите scrcpy.exe в текущую папку или добавьте в PATH." -ForegroundColor Yellow
            }
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "4" {
            Clear-Host
            Write-Host "=== Переключение цветового режима экрана ===" -ForegroundColor Magenta
            if (Test-DeviceConnection) {
                $status = (& $ADB shell settings get secure accessibility_display_daltonizer_enabled)
                if ($status) { $status = $status.Trim() }
                if ($status -eq "1") {
                    Write-Host "Текущий режим: МОНОХРОМ. Переключаем в ЦВЕТ..." -ForegroundColor Yellow
                    & $ADB shell settings put secure accessibility_display_daltonizer_enabled 0
                    Write-Host "`n[+] Экран переведен в ЦВЕТНОЙ режим!`n" -ForegroundColor Green
                } else {
                    Write-Host "Текущий режим: ЦВЕТНОЙ. Переключаем в МОНОХРОМ..." -ForegroundColor Yellow
                    & $ADB shell settings put secure accessibility_display_daltonizer 0
                    & $ADB shell settings put secure accessibility_display_daltonizer_enabled 1
                    Write-Host "`n[+] Экран возвращен в строгий МОНОХРОМ («Серый камень»)!`n" -ForegroundColor Green
                }
            }
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "5" {
            Clear-Host
            Write-Host "================= ЭКСПРЕСС-АУДИТ ПЕРИМЕТРА И БЕЗОПАСНОСТИ =================" -ForegroundColor Cyan
            if (Test-DeviceConnection) {
                Write-Host "`n--- БАТАРЕЯ И ПАМЯТЬ ---" -ForegroundColor Yellow
                & $ADB shell "dumpsys battery | grep -E 'level|temperature|status'"
                & $ADB shell "cat /proc/meminfo | head -n 2"
                
                Write-Host "`n--- БРАУЗЕРНЫЙ ПЕРИМЕТР ---" -ForegroundColor Yellow
                $br = (& $ADB shell cmd package resolve-activity http://google.com)
                if ($br) { $br = $br.Trim() }
                Write-Host "Резолв HTTP: $br" -ForegroundColor Green

                Write-Host "`n--- СТАТУС ПРИВАТНОГО DNS (DoT) ---" -ForegroundColor Yellow
                $dnsMode = (& $ADB shell settings get global private_dns_mode).Trim()
                $dnsHost = (& $ADB shell settings get global private_dns_specifier).Trim()
                Write-Host "DNS Режим: $dnsMode | Хост: $dnsHost" -ForegroundColor Green

                Write-Host "`n--- ПРОВЕРКА ЗАБЛОКИРОВАННЫХ ВЕКТОРОВ ---" -ForegroundColor Yellow
                $users = (& $ADB shell pm list users)
                Write-Host "Пользователи: $users" -ForegroundColor Cyan
                $vpn = (& $ADB shell pm list packages -d --user 0 | Select-String "vpndialogs")
                Write-Host "VPN Consent Dialog: $vpn" -ForegroundColor Cyan
                $inst = (& $ADB shell settings get secure install_non_market_apps).Trim()
                Write-Host "Установка неизвестных APK (0=запрещено): $inst" -ForegroundColor Cyan
                Write-Host "`n==========================================================================" -ForegroundColor Cyan
            }
            Read-Host "Нажмите Enter для возврата в меню..."
        }
        "6" {
            Clear-Host
            Write-Host "=== Тотальная зачистка и блокировка всех лазеек ===" -ForegroundColor Red
            if (Test-DeviceConnection) {
                Write-Host "[1/7] Удаление браузеров и YouTube..." -ForegroundColor Yellow
                & $ADB shell pm disable-user --user 0 com.android.chrome
                & $ADB shell pm uninstall -k --user 0 com.android.chrome
                & $ADB shell pm uninstall -k --user 0 com.google.android.youtube
                & $ADB shell pm disable-user --user 0 com.samsung.android.video
                & $ADB shell pm disable-user --user 0 com.android.htmlviewer

                Write-Host "[2/7] Уничтожение магазинов приложений..." -ForegroundColor Yellow
                & $ADB shell pm uninstall -k --user 0 com.android.vending
                & $ADB shell pm uninstall -k --user 0 com.sec.android.app.samsungapps

                Write-Host "[3/7] Удаление Termux..." -ForegroundColor Yellow
                & $ADB shell pm uninstall -k --user 0 com.termux

                Write-Host "[4/7] Ликвидация Secure Folder..." -ForegroundColor Yellow
                & $ADB shell pm remove-user 150
                & $ADB shell pm disable-user --user 0 com.samsung.knox.securefolder

                Write-Host "[5/7] Блокировка VPN туннелей (VpnDialogs)..." -ForegroundColor Yellow
                & $ADB shell pm disable-user --user 0 com.android.vpndialogs
                & $ADB shell pm disable-user --user 0 com.sec.android.easyMover

                Write-Host "[6/7] Запрет установки любых сторонних APK..." -ForegroundColor Yellow
                & $ADB shell settings put secure install_non_market_apps 0
                & $ADB shell 'cmd appops set org.telegram.messenger REQUEST_INSTALL_PACKAGES deny; cmd appops set com.discord REQUEST_INSTALL_PACKAGES deny; cmd appops set com.whatsapp REQUEST_INSTALL_PACKAGES deny; cmd appops set org.thoughtcrime.securesms REQUEST_INSTALL_PACKAGES deny; cmd appops set com.sec.android.app.myfiles REQUEST_INSTALL_PACKAGES deny; cmd appops set com.google.android.apps.docs REQUEST_INSTALL_PACKAGES deny; cmd appops set com.microsoft.skydrive REQUEST_INSTALL_PACKAGES deny'

                Write-Host "[7/7] Активация DNS-over-TLS CleanBrowsing Family Filter..." -ForegroundColor Yellow
                & $ADB shell settings put global private_dns_mode hostname
                & $ADB shell settings put global private_dns_specifier family-filter-dns.cleanbrowsing.org

                Write-Host "`n[+] ПЕРИМЕТР ПОЛНОСТЬЮ ЗАБЛОКИРОВАН ПО ВСЕМ ВЕКТОРАМ!" -ForegroundColor Green
            }
            Read-Host "`nНажмите Enter для возврата в меню..."
        }
        "7" {
            Clear-Host
            Write-Host "=== Открытие интерактивных отчетов и дашбордов ===" -ForegroundColor Cyan
            $reportPath = Join-Path $PSScriptRoot "step_by_step_transformation.html"
            if (Test-Path $reportPath) {
                Start-Process $reportPath
                Write-Host "`n[+] Отчет открыт в стандартном веб-браузере!" -ForegroundColor Green
            } else {
                Write-Host "[!] Файл отчета не найден: $reportPath" -ForegroundColor Yellow
            }
            Read-Host "`nНажмите Enter для возврата в меню..."
        }
        "8" {
            Clear-Host
            Write-Host "=== Откат и восстановление настроек по умолчанию ===" -ForegroundColor DarkYellow
            Write-Host "Вы уверены, что хотите разблокировать Play Store, вернуть цвета, анимации и стандартный DNS? (Y/N)" -ForegroundColor Yellow
            $ans = Read-Host
            if ($ans -match "^[yYдД]") {
                if (Test-DeviceConnection) {
                    Write-Host "`n[1/6] Включение Google Play Store..." -ForegroundColor Cyan
                    & $ADB shell pm enable com.android.vending

                    Write-Host "[2/6] Возврат цветного режима экрана..." -ForegroundColor Cyan
                    & $ADB shell settings put secure accessibility_display_daltonizer_enabled 0
                    & $ADB shell settings put secure reduce_bright_colors_activated 0

                    Write-Host "[3/6] Возврат стандартных анимаций (1.0x)..." -ForegroundColor Cyan
                    & $ADB shell settings put global window_animation_scale 1.0
                    & $ADB shell settings put global transition_animation_scale 1.0
                    & $ADB shell settings put global animator_duration_scale 1.0

                    Write-Host "[4/6] Возврат тактильных откликов и звуков..." -ForegroundColor Cyan
                    & $ADB shell settings put system haptic_feedback_enabled 1
                    & $ADB shell settings put system sound_effects_enabled 1
                    & $ADB shell settings put system lockscreen_sounds_enabled 1

                    Write-Host "[5/6] Сброс приватного DNS в автоматический режим..." -ForegroundColor Cyan
                    & $ADB shell settings put global private_dns_mode opportunistic
                    & $ADB shell settings put global private_dns_specifier ""

                    Write-Host "[6/6] Разрешение бейджей уведомлений..." -ForegroundColor Cyan
                    & $ADB shell settings put secure notification_badging 1

                    Write-Host "`n[+] Базовые настройки успешно восстановлены!" -ForegroundColor Green
                }
            } else {
                Write-Host "`nОперация отменена." -ForegroundColor Gray
            }
            Read-Host "`nНажмите Enter для возврата в меню..."
        }
        "9" {
            $running = $false
            Write-Host "До свидания!" -ForegroundColor Green
        }
        default {
            Write-Host "Неверный пункт. Введите цифру от 1 до 9." -ForegroundColor Red
            Start-Sleep -Milliseconds 800
        }
    }
}