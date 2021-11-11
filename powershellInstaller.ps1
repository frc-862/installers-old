if ( Test-Path "$HOME\scoop\shims\scoop" ) {
    Write-Output "Existing Scoop installation found."
} else {
    Write-Output "Scoop Not found. Installing now."
    Invoke-WebRequest -useb "https://get.scoop.sh" | Invoke-Expression
}

Write-Output "Installing git..."
scoop install git
Write-Output "Updating Scoop..."
scoop update
Write-Output "Installing scoop buckets..."
scoop bucket add java
scoop bucket add extras
Write-Output "Installing java and vscode..."
scoop install openjdk11 vscode

if ( Test-Path "$HOME\scoop\shims\code" ) {
    Write-Output "Installing vs code extensions"
    code --install-extension vscjava.vscode-java-pack
    code --install-extension wpilibsuite.vscode-wpilib
} else {
    Write-Output "WARNING: VS code not detected"
    Write-Output "You may need to reinstall it manually"
}

Write-Output "Cloning lightning source code over https into $HOME\Documents\lightning"
Write-Output "Note: you will need to clone over ssh if you want to contribute code"
git clone "https://github.com/frc-862/lightning.git" "$HOME\Documents\lightning"

Write-Output "Building gradle..."
Invoke-Expression "$HOME\Documents\lightning\gradlew build"
