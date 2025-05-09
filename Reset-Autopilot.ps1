wpeinit
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "=== Starter Autopilot Reset ==="

# Sjekk om install.wim finnes
$WindowsSource = "X:\Sources\install.wim"
$Index = 1

if (-not (Test-Path $WindowsSource)) {
    Write-Host "Fant ikke $WindowsSource. Avbryter."
    Start-Sleep -Seconds 10
    exit 1
}

# Diskpart-script
$diskScript = @"
select disk 0
clean
convert gpt
create partition efi size=100
format quick fs=fat32 label=System
assign letter=S
create partition primary
format quick fs=ntfs label=Windows
assign letter=W
exit
"@

Write-Host "Wiper og konfigurerer disk..."
$diskScript | Out-File -Encoding ASCII X:\diskpart.txt
diskpart /s X:\diskpart.txt

# Installer Windows
Write-Host "Installerer Windows 11..."
Start-Process dism.exe -ArgumentList "/Apply-Image","/ImageFile:$WindowsSource","/Index:$Index","/ApplyDir:W:\" -Wait

# BCD
Write-Host "Konfigurerer BCD..."
bcdboot W:\Windows /s S: /f UEFI

Write-Host ""
Write-Host "Fullfort. Starter Windows..."
Start-Sleep -Seconds 5
wpeutil reboot
