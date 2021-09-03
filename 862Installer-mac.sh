#!/bin/bash

#Define functions
#Has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

if ! has brew ; then
    #if brew isn't installed, install it now
    printf "\033[32mno brew installation detected\ninstalling brew...\n\033[39m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if has brew ; then
    #define the standard functions
    update() { brew update; brew upgrade; }
    #installreqs: install required packages
    installreqs() { brew install git openjdk@11; }
    #installopts: install optional packages
    installopts() { brew install visual-studio-code; }
    #pkgmanager: the name of the detected package manager
    pkgmanager="brew"
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
