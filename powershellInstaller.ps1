# Run checks to make sure the installer can install
#requires -version 4.0
#requires -RunAsAdministrator

$freespace = (Get-CimInstance CIM_LogicalDisk -Filter "DeviceId='C:'").FreeSpace
if (($freespace -lt 15gb) -and (-Not ($uninstall))) {
    Write-Host "You do not have enough disk space ('C:\') for this install! You need at least 15 gigabytes to run this installer." -ForegroundColor Red
    exit
}
Write-Host "All checks have passed" -ForegroundColor Green

# Pre-install warning/starting
Write-Host "Starting install (check back here in about 10 minutes)..." -ForegroundColor Green
Write-Host "Please do not touch or terminate this install (a macro is setup to do everything for you)" -ForegroundColor Yellow

#Install Chocolatey
Write-Host "Installing Chocolatey..." -ForegroundColor Green
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install git in order to use git bash
Write-Host "Installing git..." -ForegroundColor Green
choco install -y git
refreshenv

& "$Env:Programfiles\git\bin\bash.exe" "./bashInstaller.sh" $args

#Run build in powershell to avoid some weirdness with gradle's loading bar
$env:JAVA_HOME = "C:\Program Files\OpenJDK\openjdk-11.0.13_8"
& "$HOME/Documents/lightning/gradlew.bat" "build"
