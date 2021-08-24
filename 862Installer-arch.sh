#!/bin/bash
has() { type -p "$1" &> /dev/null; }

if has sudo ; then
    printf "Using sudo for root privileges\n"
    rootstring="sudo"
elif has doas ; then
    printf "Using doas for root privileges\m"
    rootstring="doas"
elif [ "$EUID" -eq 0 ] ; then
    printf "Using current user for root privileges\m"
    rootstring=""
else
    printf "ERROR: no root privileges found.\n"
    printf "You can try running this script as root or verifying that sudo or doas is in your PATH"
    exit
fi

$rootstring pacman -S git jdk11-openjdk code

if has code ; then
    printf "installing vscode extensions...\n"
    code --install-extension vscjava.vscode-java-pack
    code --install-extension wpilibsuite.vscode-wpilib
else
    printf "ERROR: vscode not detected in PATH.\n"
    printf "It may have failed to install or failed to add itself to your PATH\n"
    printf "You may be able to fix thie by manually install vscode or manually adding /usr/bin/code to your PATH\n"
fi

printf 'Cloning lightning source code over https into %s/Documents/\n' "$HOME"
printf "Note: you will need to clone over ssh in order to contribute code\n"
if [ -d "$HOME/Documents/lightning" ] ; then
    printf "lightning already appears to be cloned. Pulling latest version now.\n"
    git -C "$HOME/Documents/lightning" pull
else
    printf "lightning doesn't appear to be cloned. Cloning now.\n"
    git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
fi

printf "Building gradle...\n"
"$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build

