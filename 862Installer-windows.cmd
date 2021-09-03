@echo off
if exist %UserProfile%\scoop\shims\scoop.cmd (
    echo Existing Scoop installation found. Updating now.
    call scoop install git
    call scoop update
) else (
    echo Scoop Not found. Installing now.
    powershell -ExecutionPolicy Unrestricted -Command "iwr -useb get.scoop.sh | iex"
    set PATH=%path%;%UserProfile%\scoop\shims
)
echo Installing git...
call scoop install git
echo Installing scoop buckets...
call scoop bucket add java
call scoop bucket add extras
echo Installing java and vscode...
call scoop install openjdk11 vscode
set PATH=%path%;%UserProfile%\scoop\apps\openjdk11\current\bin

if exist "%UserProfile%\scoop\shims\code" (
    echo Installing vs code extensions
    call code --install-extension vscjava.vscode-java-pack
    call code --install-extension wpilibsuite.vscode-wpilib
) else (
    echo WARNING: VS code not detected
    echo You may need to reinstall it manually
)

if exist "%UserProfile%\Documents\lightning\" (
    echo lightning code detected
    echo pulling latest version...
    call git -C "%UserProfile%\Documents\lightning" pull
) else (
    echo Cloning lightning source code over https into %UserProfile%\Documents\lightning
    echo Note: you will need to clone over ssh if you want to contribute code
    call git clone "https://github.com/frc-862/lightning.git" "%UserProfile%\Documents\lightning"
)


echo Building gradle...
call %UserProfile%\Documents\lightning\gradlew.bat -p "%UserProfile%\Documents\lightning" "build"
