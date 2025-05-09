# Reset-Autopilot.ps1
# Kjøres fra WinPE

wpeinit
Start-Sleep -Seconds 2

Write-Host "`n=== Startet Autopilot Reset ==="

# Disk wipe (GPT og EFI-basert)
$diskScript = @"
select disk 0
clean
convert gpt
create partition efi size=100
format quick fs=fat32 label="System"
assign letter=S
create partition primary
format quick fs=ntfs label="Windows"
assign letter=W
exit
"@

Write-Host "Wiper og konfigurerer disk..."
$diskScript | Out-File -Encoding ASCII X:\diskpart.txt
diskpart /s X:\diskpart.txt

# Pek til Windows install.wim eller ISO (tilpass hvis ISO brukes)
$WindowsSource = "X:\Sources\install.wim"  # eller X:\install.wim fra USB eller nettverk
$Index = 1

Write-Host "Installerer Windows 11 generisk..."
Dism /Apply-Image /ImageFile:$WindowsSource /Index:$Index /ApplyDir:W:\

Write-Host "Konfigurerer BCD..."
bcdboot W:\Windows /s S: /f UEFI

Write-Host "`n=== Ferdig. Starter Windows for OOBE og Autopilot...`n"
Start-Sleep -Seconds 3
wpeutil reboot
