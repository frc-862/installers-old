#define constants
$WPILIB_VERSION="2021.3.1"
$WPILIB_TYPE="Windows64"
$WPILIB_EXTENSION="iso"

#check if scoop is installed
if ( Test-Path "$HOME\scoop\shims\scoop" ) {
    #if it is, continue
    Write-Output "Existing Scoop installation found."
} else {
    Write-Output "Scoop Not found. Installing now."
    #if it isn't, get the install script from the scoop website
    Invoke-WebRequest -useb "https://get.scoop.sh" | Invoke-Expression
}

#install git in order to allow updating scoop
Write-Output "Installing git..."
scoop install git
#update scoop
Write-Output "Updating Scoop..."
scoop update
#add extras bucket for lazygit
Write-Output "Installing scoop buckets..."
scoop bucket add extras
Write-Output "Installing lazygit, wget, and 7zip..."
scoop install lazygit
scoop install aria2 #install aria2 to download wget
scoop install 7zip #install 7zip to extract wpilib iso

Write-Output "Downloading wpilib installer..."
$wpilibUrl="https://github.com/wpilibsuite/allwpilib/releases/download/v$WPILIB_VERSION/WPILib_$WPILIB_TYPE-$WPILIB_VERSION.$WPILIB_EXTENSION"
$wpilibFilename="WPILib_$WPILIB_TYPE-$WPILIB_VERSION.$WPILIB_EXTENSION"
aria2c "$wpilibUrl"

Write-Output "Extracting wpilib installer..."
7z x -y -o".\$WPILIB_TYPE" ".\$wpilibFilename"

Write-Output "Running wpilib installer"
Invoke-Expression ".\$WPILIB_TYPE\WPILibInstaller.exe"
Pause

Write-Output "Cloning lightning source code over https into $HOME\Documents\lightning"
Write-Output "Note: you will need to clone over ssh if you want to contribute code"
#clone lighning into ~/Documents/lighning
if ( Test-Path "$HOME\Documents\lightning" ) {
    git -C "$HOME/Documents/lightning" pull
} else {
    git clone "https://github.com/frc-862/lightning.git" "$HOME\Documents\lightning"
}

#run a gradle build in the lighning folder
Write-Output "Building gradle..."
Start-Process -FilePath "$HOME\Documents\lightning\gradlew.bat" -ArgumentList "build"  -Wait -NoNewWindow
#Invoke-Expression "$HOME\Documents\lightning\gradlew build"
