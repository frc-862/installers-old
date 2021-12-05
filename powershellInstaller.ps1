#Install Chocolatey
Write-Host "Installing Chocolatey..." -ForegroundColor Green
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install specified packages, in order
Write-Host "Installing packages..." -ForegroundColor Green
#thanks to DarthJake (https://github.com/DarthJake) from 4146 for most of these repositories
choco install -y git openjdk11 wpilib lazygit ni-frcgametools ctre-phoenixframework frc-radioconfigurationutility

refreshenv

Write-Host "Cloning lightning source code over https into $HOME/Documents/lightning" -ForegroundColor Green
Write-Host "Note: you will need to clone over ssh if you want to contribute code" -ForegroundColor Yellow

if ( Test-Path "$HOME/Documents/lightning" ) {
    # manually call git's path because git doesn't get added to path automatically even with refreshenv
    & "C:\Program Files\Git\cmd\git" "-C" "$HOME/Documents/lightning" "pull"
} else {
    #clone lighning into ~/Documents/lighning
    & "C:\Program Files\Git\cmd\git" "clone" "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
}

#run a gradle build in the lighning folder
Write-Host "Building gradle..." -ForegroundColor Green
$env:JAVA_HOME = 'C:\Program Files\OpenJDK\openjdk-11.0.13_8'
& "$HOME/Documents/lightning/gradlew.bat" "build"
