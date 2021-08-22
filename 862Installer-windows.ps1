if ( Test-Path "$HOME\scoop\shims\scoop" ) {
    echo "Existing Scoop installation found. Updating now."
    sleep 0.1
    scoop install git
    scoop update
} else {
    echo "Scoop Not found. Installing now."
    sleep 0.5
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    iwr -useb get.scoop.sh | iex
}
echo "Installing git..."
sleep 0.1
scoop install git
echo "Installing scoop buckets..."
sleep 0.1
scoop bucket add java
scoop bucket add extras
echo "Installing java and vscode..."
sleep 0.1
scoop install openjdk11 vscode
if ( Test-Path "$HOME\scoop\shims\code" ) {
    echo "Installing vs code extensions"
    sleep 0.1
    code --install-extension vscjava.vscode-java-pack 
    code --install-extension wpilibsuite.vscode-wpilib
} else {
    echo "WARNING: VS code not detected"
    echo "You may need to reinstall it manually"
    exit
}

echo "Cloning lightning source code over https into $HOME\Documents\"
echo "Note: you will need to clone over ssh if you want to contribute code"
sleep 0.1
git clone "https://github.com/frc-862/lightning.git" "$HOME\Documents\lightning"

echo "Building gradle..."
sleep 0.1
iex "$HOME\Documents\lightning\gradlew build"

#echo "Installing C++ runtime..."
#iwr -useb "https://aka.ms/vs/16/release/vc_redist.x64.exe" | iex
