
#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install git -y

choco install lazygit -y

choco install openjdk11 -y

#Install NI game tools (driver station, rio imager, etc.)
#choco install ni-frcgametools -y

#Install WPLIB
choco install wpilib -y --params="'/ProgrammingLanguage:java'"#/AllowUserInteraction:true

#choco install frc-radioconfigurationutility -y

choco install ctre-phoenixframework -y


refreshenv

Write-Output "Cloning lightning source code over https into $HOME/Documents/lightning"
Write-Output "Note: you will need to clone over ssh if you want to contribute code"
#clone lighning into ~/Documents/lighning
if ( Test-Path "$HOME/Documents/lightning" ) {
    git -C "$HOME/Documents/lightning" pull
} else {
    git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
}

#run a gradle build in the lighning folder
Write-Output "Building gradle..."
& "$HOME/Documents/lightning/gradlew.bat" "build"
