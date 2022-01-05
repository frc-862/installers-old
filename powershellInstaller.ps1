#Check elevation and powershell ver first
#requires -version 4.0
#requires -RunAsAdministrator
Write-Host "PS Version and Admin Permissions passed" -ForegroundColor Green

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

& "$Env:Programfiles\git\bin\bash.exe" "./bashInstaller.sh"

#Run build in powershell to avoid some weirdness with gradle's loading bar
$env:JAVA_HOME = "C:\Program Files\OpenJDK\openjdk-11.0.13_8"
& "$HOME/Documents/lightning/gradlew.bat" "build"
