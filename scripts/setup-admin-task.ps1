# Скрипт создания задачи в Планировщике Windows с правами администратора
# Запускается с повышением прав (RunAs) ОДИН раз.

$action = "taskkill.exe /F /T /IM Discord.exe"
schtasks /create /tn "KillElevatedApps" /tr $action /sc once /st 00:00 /rl highest /f

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[+] Задача 'KillElevatedApps' успешно зарегистрирована в Планировщике Windows!" -ForegroundColor Green
    Write-Host "[+] Теперь скрипты переключения режимов смогут закрывать Discord без UAC-запросов.`n" -ForegroundColor Cyan
} else {
    Write-Host "`n[-] Ошибка регистрации задачи. Запусти PowerShell от имени Администратора.`n" -ForegroundColor Red
}

Start-Sleep -Seconds 2
