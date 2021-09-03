#!/bin/bash

#Define functions
#Has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

#detect a program to use to obtain root privileges
#set rootstring variable to say what command to use
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
    exit 1
fi

#detect a compatible package manager to install packages
if has apt ; then
    #define functions for each package manager
    #these functions apply to all other package managers also
    #update: get the latest version of all packages
    update() { $rootstring apt update; $rootstring apt -y upgrade; }
    #installreqs: install required packages
    installreqs() { $rootstring apt -y install git openjdk-11-jdk; }
    #installopts: install optional packages
    installopts() { $rootstring apt -y install code; }
    #pkgmanager: the name of the detected package manager
    pkgmanager="apt"
elif has pacman ; then
    update() { $rootstring pacman --noconfirm -Syu; }
    installreqs() { $rootstring pacman --noconfirm -S git jdk11-openjdk; }
    installopts() { $rootstring pacman --noconfirm -S code; }
    pkgmanager="pacman"
else
    printf "\033[31mno supported package manager found\ntry verifying that one is installed and in your PATH\n\033[39m"
    exit 1
fi

#run the defined update, installreqs, and installopts functions
printf '\033[32m%s installation detected\nupgrading %s...\n\033[39m' "$pkgmanager" "$pkgmanager"
update
printf "\033[32minstalling required packages...\n\033[39m"
installreqs
printf "\033[32minstalling optional packages...\n\033[39m"
installopts

#install vscode extensions
if has code ; then
    printf "\033[32minstalling vscode extensions...\n\033[39m"
    code --install-extension vscjava.vscode-java-pack #java extension pack
    code --install-extension wpilibsuite.vscode-wpilib #wpilib extension
else
    #don't exit if vscode breaks, as the build can still work without vscode
    printf "\033[33merror: vscode failed to install\n\033[39m"
    printf "\033[33mvscode extensions will not be installed automatically\n\033[39m"
fi

#build section
printf '\033[32mcloning lightning source code into %s/Documents/\n\033[39m' "$HOME"
printf "\033[33mnote: you will need to clone over ssh in order to contribute code\n\033[39m"
#clone lightning repo
if [ -d "$HOME/Documents/lightning" ] ; then
    printf "\033[32mlightning code detected\npulling latest version...\n\033[39m"
    git -C "$HOME/Documents/lightning" pull
else
    printf "\033[32mno lightning code detected\ncloning new code...\n\033[39m"
    git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
fi

#build lightning repo
printf "\033[32mbuilding gradle...\n\033[39m"
"$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build
buildstatus=$?
if [ $buildstatus -eq 0 ] ; then
    printf "\033[32mbuild completed successfully\n\033[39m"
else
    printf '\033[31merror: build failed with exit code %s\nplease open an issue on github for help with this issue\n\033[39m' "$buildstatus"
fi
