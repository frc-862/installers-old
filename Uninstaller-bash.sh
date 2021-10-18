#!/bin/bash

#Define functions
#Has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

#Define constants
os=$(uname -s)

#detect a program to use to obtain root privileges
#set rootstring variable to say what command to use
if [ "$os" == "Darwin" ] ; then
    printf "\033[32mno root privileges needed on macos\n\033[39m"
elif has sudo ; then
    rootstring="sudo"
    printf '\033[32musing sudo (%s) for root privileges\n\033[39m' "$(type -p $rootstring)"
elif has doas ; then
    rootstring="doas"
    printf '\033[32musing doas (%s) for root privileges\n\033[39m' "$(type -p $rootstring)"
elif [ "$EUID" -eq 0 ] ; then
    rootstring=""
    printf '\033[32musing current user (%s) for root privileges\n\033[39m' "$(whoami)"
else
    printf "\033[31merror: no root privileges\n\033[39m"
    printf "\033[31mtry running this script as root or verifying that sudo or doas is installed and in your PATH\n\033[39m"
    exit 1
fi

#detect a compatible package manager to uninstall packages
if has apt && [ -f "/etc/ubuntu-release" ] ; then
    uninstall() { $rootstring apt -y purge git openjdk-11-jdk wget software-properties-common code lazygit; }
    pkgmanager="apt (ubuntu)"
elif has apt ; then
    uninstall() { $rootstring apt -y purge git openjdk-11-jdk wget software-properties-common code; }
    pkgmanager="apt"
elif has pacman ; then
    installreqs() { $rootstring pacman --noconfirm -R git jdk11-openjdk code lazygit; }
    pkgmanager="pacman"
elif has brew ; then
    uninstall() { ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"; }
    pkgmanager="brew"
elif has scoop ; then
    rm -rf "$HOME/scoop"
    pkgmanager="scoop"
else
    printf "\033[31mno supported package manager found\ntry verifying that one is installed and in your PATH\n\033[39m"
    exit 1
fi

#run the defined update, installreqs, and installopts functions
printf '\033[32m%s installation detected\nuninstalling all packages from %s...\n\033[39m' "$pkgmanager" "$pkgmanager"
update
exitcode=$?
if [ $exitcode -eq 0 ] ; then
    printf "\033[32muninstall completed successfully\n\033[39m"
else
    #don't exit if the update fails
    printf '\033[31merror: uninstall failed with exit code %s\n\033[39m' "$exitcode"
fi

rm -rf "$HOME/Documents/lightning"
