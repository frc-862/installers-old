#!/bin/bash
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
