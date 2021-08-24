#!/bin/bash
has() { type -p "$1" &> /dev/null; }
if has brew ; then
    printf "existing brew installation detected. Updating now.\n"
    brew update
    brew upgrade
else
    printf "no brew installation detected. Installing brew now.\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -d "$(brew --prefix)/Cellar/git" ] ; then
    printf "git is installed. Upgrading now.\n"
    brew upgrade git
else
    printf "git doesn't appear to be installed. Installing now.\n"
    brew install git
fi

if [ -d "$(brew --prefix)/Cellar/openjdk@11" ] ; then
    printf "openjdk11 is installed. Upgrading now.\n"
    brew upgrade openjdk@11
else
    printf "openjdk11 doesn't appear to be installed. Installing now.\n"
    brew install openjdk@11
fi

if [ -d "$(brew --prefix)/Caskroom/visual-studio-code" ] ; then
    printf "vs code is installed. Upgrading now.\n"
    brew upgrade visual-studio-code
else
    printf "vs code doesn't appear to be installed. Installing now.\n"
    brew install visual-stuio-code
fi


if has code ; then
    printf "installing vscode extensions...\n"
    code --install-extension vscjava.vscode-java-pack
    code --install-extension wpilibsuite.vscode-wpilib
else
    printf "ERROR: vscode failed to install\n"
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

