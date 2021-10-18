if ( Test-Path "$HOME\scoop\shims\scoop" ) {
    echo "Existing Scoop installation found."
} else {
    echo "Scoop Not found. Installing now."
    iwr -useb get.scoop.sh | iex
}

echo "Installing git..."
scoop install git
echo "Updating Scoop..."
scoop update
echo "Installing scoop buckets..."
scoop bucket add java
scoop bucket add extras
echo "Installing java and vscode..."
scoop install openjdk11 vscode

if ( Test-Path "$HOME\scoop\shims\code" ) {
    echo "Installing vs code extensions"
    code --install-extension vscjava.vscode-java-pack
    code --install-extension wpilibsuite.vscode-wpilib
} else {
    echo "WARNING: VS code not detected"
    echo "You may need to reinstall it manually"
}

echo "Cloning lightning source code over https into $HOME\Documents\lightning"
echo "Note: you will need to clone over ssh if you want to contribute code"
git clone "https://github.com/frc-862/lightning.git" "$HOME\Documents\lightning"

echo "Building gradle..."
iex "$HOME\Documents\lightning\gradlew build"
