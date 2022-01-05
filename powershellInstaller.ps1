# Define script parameters -> Ex. '.\script.ps1 -doMacro 0'
# Many params do not work, they are just defined here for future implemenation
param (
    [string]$chocoPath = "C:\ProgramData\chocolatey",
    [switch]$noMacro = $false
)

#Check elevation and powershell ver first
#requires -version 4.0
#requires -RunAsAdministrator
Write-Host "PS Version and Admin Permissions check passed" -ForegroundColor Green

# Handle parameters here
if ($chocoPath -ne "C:\ProgramData\chocolatey") {
    Write-Host "You have selected the 'chocoPath' parameter, however it has not been implemented and will not affect the installation." -ForegroundColor Red
}
if ($noMacro) {
    Write-Host "You have selected the 'noMacro' parameter, however it has not been implemented and will not affect the installation" -ForegroundColor Red
}

exit

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
