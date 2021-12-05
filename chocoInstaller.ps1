#Install Chocolatey
Write-Output "Installing Chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install specified packages, in order
Write-Output "Installing packages..."
choco install -y git lazygit openjdk11 ni-frcgametools wpilib frc-radioconfigurationutility ctre-phoenixframework

refreshenv

Write-Output "Cloning lightning source code over https into $HOME/Documents/lightning"
Write-Output "Note: you will need to clone over ssh if you want to contribute code"

if ( Test-Path "$HOME/Documents/lightning" ) {
    # manually call git's path because git doesn't get added to path automatically even with refreshenv
    & "C:\Program Files\Git\cmd\git" "-C" "$HOME/Documents/lightning" "pull"
} else {
    #clone lighning into ~/Documents/lighning
    & "C:\Program Files\Git\cmd\git" "clone" "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
}

#run a gradle build in the lighning folder
Write-Output "Building gradle..."
$env:JAVA_HOME = 'C:\Program Files\OpenJDK\openjdk-11.0.13_8'
& "$HOME/Documents/lightning/gradlew.bat" "build"
