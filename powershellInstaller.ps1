$wpilibVersion="2021.3.1"
$wpilibType="Windows64"
$wpilibExtension="iso"

#check if scoop is installed
if ( Test-Path "$HOME\scoop\shims\scoop" ) {
    #if it is, continue
    Write-Output "Existing Scoop installation found."
} else {
    Write-Output "Scoop Not found. Installing now."
    #if it isn't, get the install script from the scoop website
    Invoke-WebRequest -useb "https://get.scoop.sh" | Invoke-Expression
}

#install software from scoop
Write-Output "Installing git..."
scoop install git
Write-Output "Updating Scoop..."
scoop update
Write-Output "Installing scoop buckets..."
scoop bucket add extras
Write-Output "Installing lazygit, wget, and 7zip..."
scoop install lazygit
scoop install wget
scoop install 7zip

$wpilibUrl="https://github.com/wpilibsuite/allwpilib/releases/download/v$wpilibVersion/WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
#$wpilibFilename="WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
wget "$wpilibUrl"

Write-Output "Cloning lightning source code over https into $HOME\Documents\lightning"
Write-Output "Note: you will need to clone over ssh if you want to contribute code"
#clone lighning into ~/Documents/lighning
git clone "https://github.com/frc-862/lightning.git" "$HOME\Documents\lightning"

#run a gradle build in the lighning folder
Write-Output "Building gradle..."
Invoke-Expression "$HOME\Documents\lightning\gradlew build"
