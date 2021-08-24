#!/bin/bash
has() { type -p "$1" &> /dev/null; }

if has sudo ; then
    printf "Using sudo for root priveleges\n"
else
    printf "sudo not found, if you're using doas or other ill just trust that you know what you're doing.\n"
    exit
fi

if has apt ; then
    printf "existing pacman installation detected. Updating now.\n"
    sudo pacman -Syu
else
    printf "pacman not found in PATH. Please use the apporopriate installed for your distro or fix your PATH\n"
    exit
fi

sudo pacman -S git openjdk-11-jdk code

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

