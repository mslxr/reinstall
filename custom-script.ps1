# Set TLS version to ensure compatibility
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# INSTALL GOOGLE CHROME
Write-Output "Mengunduh dan menginstall Google Chrome..."
$chromeInstaller = "$env:TEMP\chrome_installer.exe"
Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller
Start-Process -FilePath $chromeInstaller -Args "/silent /install" -Wait
Remove-Item -Path $chromeInstaller -Force

# OPEN FOLDER AND CREATE SETTINGS FOLDER
Write-Output "Membuka dan membuat folder Settings..."
New-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Settings" -ItemType Directory -Force

# CREATE FILE CHANGE PASSWORD.bat
Write-Output "Membuat file CHANGE PASSWORD.bat..."
$changePasswordBatContent = @"
@echo off
title "GANTI PASSWORD RDP"

color e

echo *Password minimal 10 karakter
echo *Password tidak boleh pakai spasi
echo *Password harus kombinasi huruf kecil, huruf besar, angka dan karakter
echo *Dimohon catat password dalam catatan pribadi, sebelum mengganti password
echo:

set /p PWD=Masukkan Password Baru : 
set /p PWD2=Masukkan Ulang Password : 

call :strLen PWD strlen

echo:

if %strlen% LSS 10 echo (!) Password minimal 10 karakter
if NOT %PWD% == %PWD2% echo (!) Kedua password tidak sama
if %strlen% GEQ 10 (if %PWD% == %PWD2% net user Administrator %PWD% & echo PASSWORD BERHASIL DIGANTI)

timeout /t 5 /nobreak
exit

:strLen
setlocal enabledelayedexpansion

:strLen_Loop
   if not "!%1:~%len%!"=="" set /A len+=1 & goto :strLen_Loop
(endlocal & set %2=%len%)
"@
Set-Content -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Settings\CHANGE PASSWORD.bat" -Value $changePasswordBatContent

# DOWNLOAD ICO FILE FROM DROPBOX
Write-Output "Mengunduh file ICO dari Dropbox..."
Invoke-WebRequest -Uri "https://www.dropbox.com/scl/fi/ngilo7rfu293l30ood2st/CHANGE-PASSWORD.ico?rlkey=v2g5lxoetcldkyvfu695wk8qx&st=mrpdl6sk&dl=1" -OutFile "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Settings\CHANGE PASSWORD.ico"

# CREATE SHORTCUT ON DESKTOP WITH CUSTOM ICON
Write-Output "Membuat shortcut di desktop..."
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'CHANGE PASSWORD.lnk')
$targetPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Settings\CHANGE PASSWORD.bat"
$iconPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Settings\CHANGE PASSWORD.ico"
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($desktopPath)
$Shortcut.TargetPath = $targetPath
$Shortcut.IconLocation = $iconPath
$Shortcut.Save()

# ENABLE CAD (Ctrl+Alt+Delete)
Write-Output "Mengaktifkan CAD (Ctrl+Alt+Delete)..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 1 -Type DWord

# SET LOCKOUT THRESHOLD TO 0
Write-Output "Mengatur batas login yang salah menjadi 0..."
net accounts /lockoutthreshold:0

Write-Output "Selesai."

# DELETE SCRIPT ITSELF
Write-Output "Menghapus script ini sendiri..."
Start-Sleep -Seconds 2
Remove-Item -Path $PSCommandPath -Force
