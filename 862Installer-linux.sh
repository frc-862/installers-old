#!/bin/bash
has() { type -p "$1" &> /dev/null; }

if has sudo ; then
    printf "\033[32musing sudo for root privileges\n\033[39m"
    rootstring="sudo"
elif has doas ; then
    printf "\033[32musing doas for root privileges\n\033[39m"
    rootstring="doas"
elif [ "$EUID" -eq 0 ] ; then
    printf "\033[32musing current user for root privileges\n\033[39m"
    rootstring=""
else
    printf "\033[31merror: no root privileges\n\033[39m"
    printf "\033[31mtry running this script as root or verifying that sudo or doas is installed and in your PATH\n\033[39m"
    exit
fi

if has apt ; then
    update() { $rootstring apt update; $rootstring apt upgrade; }
    installreqs() { $rootstring apt install git openjdk-11-jdk; }
    installopts() { $rootstring apt install code; }
    pkgmanager="apt"
elif has pacman ; then
    update() { $rootstring pacman -Syu; }
    installreqs() { $rootstring pacman -S git jdk-11-openjdk; }
    installopts() { $rootstring pacman -S code; }
    pkgmanager="pacman"
else
    printf "\033[31mno supported package manager found\ntry verifying that one is installed and in your PATH\n\033[39m"
    exit
fi

printf '\033[32m%s installation detected\nupgrading %s...\n\033[39m' "$pkgmanager" "$pkgmanager"
update

printf "\033[32minstalling required packages...\n\033[39m"
installreqs
printf "\033[32minstalling optional packages...\n\033[39m"
installopts

if has code ; then
    printf "\033[32minstalling vscode extensions...\n\033[39m"
    code --install-extension vscjava.vscode-java-pack
    code --install-extension wpilibsuite.vscode-wpilib
else
    printf "\033[33merror: vscode failed to install\n\033[39m"
    printf "\033[33mvscode extensions will not be installed automatically\n\033[39m"
fi

printf '\033[32mcloning lightning source code into %s/Documents/\n\033[39m' "$HOME"
printf "\033[33mnote: you will need to clone over ssh in order to contribute code\n\033[39m"
if [ -d "$HOME/Documents/lightning" ] ; then
    printf "\033[32mlightning code detected\npulling latest version...\n\033[39m"
    git -C "$HOME/Documents/lightning" pull
else
    printf "\033[32mno lightning code detected\ncloning new code...\n\033[39m"
    git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
fi

printf "\033[32mbuilding gradle...\n\033[39m"
"$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build

