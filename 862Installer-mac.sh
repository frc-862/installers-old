#!/bin/bash
has() { type -p "$1" &> /dev/null; }

echo "You are about install brew, git, openjdk, vscode, and the wpilib extensions for vscode."

read -r -p "Do you want to continue [Y/n] " input
 
case $input in
    [yY] | "")
 cont=true
    ;;

    [nN])
 cont=false
    ;;
    *)

 echo "Invalid input..."
 exit 1
 ;;
esac

if $cont ; then
    echo "sussy amogus"


    if has brew ; then
        echo "existing brew installation detected. Updating now."
        brew update
        brew upgrade
    else
        echo "no brew installation detected. Installing brew now."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [ -d "$(brew --prefix)/Cellar/git" ] ; then
        echo "git is installed. Upgrading now."
        brew upgrade git
    else
        echo "git doesn't appear to be installed. Installing now."
        brew install git
    fi

    if [ -d "$(brew --prefix)/Cellar/openjdk@11" ] ; then
        echo "openjdk11 is installed. Upgrading now."
        brew upgrade openjdk@11
    else
        echo "openjdk11 doesn't appear to be installed. Installing now."
        brew install openjdk@11
    fi

    if [ -d "$(brew --prefix)/Caskroom/visual-studio-code" ] ; then
        echo "vs code is installed. Upgrading now."
        brew upgrade visual-studio-code
    else
        echo "vs code doesn't appear to be installed. Installing now."
        brew install visual-stuio-code
    fi


    if has code ; then
        echo "installing vscode extensions..."
        code --install-extension vscjava.vscode-java-pack
        code --install-extension wpilibsuite.vscode-wpilib
    else
        echo "ERROR: vscode failed to install"
    fi

    echo "Cloning lightning source code over https into $HOME/Documents/"
    echo "Note: you will need to clone over ssh in order to contribute code"
    if [ -d "$HOME/Documents/lightning" ] ; then
        echo "lightning already appears to be cloned. Pulling latest version now."
        git -C "$HOME/Documents/lightning" pull
    else
        echo "lightning doesn't appear to be cloned. Cloning now."
        git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
    fi

    echo "Building gradle..."
    "$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build

else
     echo "Have a nice day"
fi