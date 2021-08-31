#!/bin/bash
has() { type -p "$1" &> /dev/null; }
if has brew ; then
    printf "\033[32mexisting brew installation detected\nupdating brew...\n\033[39m"
    brew update
    brew upgrade
else
    printf "\033[32mno brew installation detected\ninstalling brew...\n\033[39m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -d "$(brew --prefix)/Cellar/git" ] ; then
    printf "\033[32mgit installation detected\nupgrading git...\n\033[39m"
    brew upgrade git
else
    printf "\033[32mgit not found\ninstalling git...\n\033[39m"
    brew install git
fi

if [ -d "$(brew --prefix)/Cellar/openjdk@11" ] ; then
    printf "\033[32mopenjdk installation detected\nupgrading openjdk...\n\033[39m"
    brew upgrade openjdk@11
else
    printf "\033[32mopenjdk not found\ninstalling openjdk...\n\033[39m"
    brew install openjdk@11
fi

if [ -d "$(brew --prefix)/Caskroom/visual-studio-code" ] ; then
    printf "\033[32mvs code installation detected\nupgrading vs code...\n\033[39m"
    brew upgrade visual-studio-code
else
    printf "\033[32mvs code not found\ninstalling vs code...\n\033[39m"
    brew install visual-stuio-code
fi


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
buildstatus=$?
if [ $buildstatus -eq 0 ] ; then
    printf "\033[32mbuild completed successfully\n\033[39m"
else
    printf '\033[31merror: build failed with exit code %s\nplease open an issue on github for help with this issue\n\033[39m' "$buildstatus"
fi
