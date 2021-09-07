@echo off
setlocal
if NOT exist %UserProfile%\scoop\shims\scoop.cmd (
    ::if scoop is not installed, install it
    echo Scoop Not found. Installing now.
    powershell -ExecutionPolicy Unrestricted -Command "iwr -useb get.scoop.sh | iex"
    set PATH=%PATH%;%UserProfile%\scoop\shims
)

::define functions for each package manager
::these functions apply to all other package managers also
::update: get the latest version of all packages
:update
    call scoop install git
    call scoop update
    exit /b

::installreqs: install required packages
:installreqs
    call scoop install git
    call scoop bucket add java
    call scoop install openjdk11
    set PATH=%path%;%UserProfile%\scoop\apps\openjdk11\current\bin
    exit /b

::installopts: install optional packages
:installopts
    call scoop bucket add extras
    call scoop install vscode lazygit
    exit /b

::pkgmanager: the name of the detected package manager
set pkgmanager=scoop

::run the defined update, installreqs, and installopts functions
call :update
call :installreqs
call :installopts

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
endlocal
pause
exit /b
