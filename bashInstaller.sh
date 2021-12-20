#!/bin/bash

#Define functions
#Has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }
#Error, Warn, ok: print message in red, orange, or green text
#use of a variable in printf fstring is intentional here
error() { printf "\033[31mERROR: $1\n\033[39m"; }
warn() { printf "\033[33mWARNING: $1\n\033[39m"; }
ok() { printf "\033[32mOK: $1\n\033[39m"; }

#Define constants
OS="$(uname -s)"
WPILIB_VERSION="2021.3.1"

#detect a program to use for root privileges
# andset ROOT_STRING variable to the found command
if [ "$OS" == "Darwin" ] ; then
    ok "no root privileges needed on macOS"
elif [[ "$OS" == *"MINGW"* ]] ; then
    ok "windows os detected"
elif has sudo ; then
    ROOT_STRING="sudo"
    ok "using sudo ($(type -p $ROOT_STRING)) for root privileges"
elif has doas ; then
    ROOT_STRING="doas"
    ok "using doas ($(type -p $ROOT_STRING)) for root privileges"
elif [ "$EUID" -eq 0 ] ; then
    ROOT_STRING=""
    ok "using current user ($USER) for root privileges"
else
    error "no root privileges\ntry running this script as root and verifying that sudo/doas is installed and in your PATH"
    exit 1
fi

#detect which wpilib release to download based on the info from uname -s
case $OS in

    "Linux")
        NEEDS_WPILIB_DOWNLOAD=true
        WPILIB_TYPE="Linux"
        WPILIB_EXTENSION="tar.gz" ;;

    "Darwin")
        NEEDS_WPILIB_DOWNLOAD=true
        WPILIB_TYPE="macOS"
        WPILIB_EXTENSION="dmg" ;;

    *"MINGW"*)
        NEEDS_WPILIB_DOWNLOAD=false
        WPILIB_TYPE=""
        WPILIB_EXTENSION="" ;;

esac

#define constants for download url and filename to save to
WPILIB_URL="https://github.com/wpilibsuite/allwpilib/releases/download/v$WPILIB_VERSION/WPILib_$WPILIB_TYPE-$WPILIB_VERSION.$WPILIB_EXTENSION"
WPILIB_FILENAME="WPILib_$WPILIB_TYPE-$WPILIB_VERSION.$WPILIB_EXTENSION"

#detect a compatible package manager to install packages
if [ "$OS" == "Darwin" ] ; then
    # only install brew from scratch on mac
    if ! has brew ; then
        ok "no brew installation detected\ninstalling brew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    #define functions for each package manager
    #these functions are also defined for all other package managers
    #update: get the latest version of all installed packages
    update() {
        brew update;
        brew upgrade;
    }

    #installReqs: install required packages
    installReqs() {
        brew install git wget;
    }

    #installOpts: install optional packages
    installOpts() {
        brew install lazygit;
    }

    #PKG_MANAGER: the name of the detected package manager
    PKG_MANAGER="brew"

elif has apt ; then

    update() {
        $ROOT_STRING apt update;
        $ROOT_STRING apt -y upgrade;
    }

    installReqs() {
        $ROOT_STRING apt -y install git wget tar;
    }

    if [ -f "/etc/ubuntu-release" ] ; then # seperate ubuntu and debian installers because lazygit PPA is ubuntu only

        installOpts() {
            $ROOT_STRING apt -y install software-properties-common
            $ROOT_STRING add-apt-repository "ppa:lazygit-team/release"
            $ROOT_STRING apt -y update
            $ROOT_STRING apt -y install lazygit
        }
        PKG_MANAGER="apt (ubuntu)"
    else
        installOpts() { true; } #no optional packages on debian
        PKG_MANAGER="apt"
    fi

elif has pacman ; then

    update() {
        $ROOT_STRING pacman --noconfirm -Syu;
    }

    installReqs() {
        $ROOT_STRING pacman --noconfirm -S git wget tar;
    }

    installOpts() {
        $ROOT_STRING pacman --noconfirm -S lazygit;
    }

    PKG_MANAGER="pacman"

elif has choco ; then

    update() {
        choco upgrade all;
    }

    installReqs() {
        choco install openjdk11 wpilib;
        refreshenv;
    }

    installOpts() {
        #thanks to DarthJake (https://github.com/DarthJake) from 4146 for most of these repositories
        choco install lazygit ni-frcgametools ctre-phoenixframework frc-radioconfigurationutility;
        refreshenv;
    }

    PKG_MANAGER="chocolatey"

else
    error "no supported package manager found\ntry verifying that one is installed and in your PATH"
    exit 1
fi

#run the defined update, installReqs, and installOpts functions
ok "$PKG_MANAGER installation detected\nupgrading $PKG_MANAGER..."
update

updateExitCode=$?
case $updateExitCode in
    0)  ok "update completed successfully";;
    *)  warn "update failed with exit code $updateExitCode" #don't exit if the update fails
esac

ok "installing required packages..."
installReqs

installExitCode=$?
case $installExitCode in
    0)  ok "installReqs completed successfully" ;;
    *)  error "installReqs failed with exit code $installExitCode\nplease open an issue on jira for assistance"
        exit $installExitCode ;; #exit if a non-0 exit code is recieved 
esac

ok "installing optional packages..."
installOpts

installExitCode=$?
case $installExitCode in
    0)  ok "installOpts completed successfully" ;;
    *)  warn "installOpts failed with exit code $installExitCode" #don't exit if installOpts fails, as the build can still work
esac

if [ $NEEDS_WPILIB_DOWNLOAD ] ; then
    ok "downloading wpilib installer..."
    if [ ! -f "./$WPILIB_FILENAME" ] ; then #skip download if file is already downloaded or isn't required
        wget "$WPILIB_URL" -O "$WPILIB_FILENAME"
    fi

    case $WPILIB_EXTENSION in #different methods for installing and running each archive
        "dmg")
            ok "Mounting wpilib installer..."
            hdiutil attach -readonly "./$WPILIB_FILENAME" #dmg needs to be mounted using hdiutil on mac

            ok "Launching wpilib installer..."
            /Volumes/WPILibInstaller/WPILibInstaller.app/Contents/MacOS/WPILibInstaller

            ok "Unmounting wpilib installer..."
            hdiutil detach /Volumes/WPILibInstaller ;;
        "tar.gz")
            ok "extracting wpilib installer..."
            tar -xvzf "./$WPILIB_FILENAME" #.tar.gz can be extracted using tar

            ok "launching wpilib installer..."
            "./WPILib_$WPILIB_TYPE-$WPILIB_VERSION/WPILibInstaller" ;;
    esac
fi

#clone lightning repo
ok "cloning lightning source code into $HOME/Documents/"

#check if lightning is already cloned
if [ -d "$HOME/Documents/lightning" ] ; then
    ok "lightning code detected\npulling latest version..."
    git -C "$HOME/Documents/lightning" pull

    gitExitCode=$?
    case $gitExitCode in
        0)  ok "pull completed successfully" ;;
        *)
            error "pull failed with exit code $gitExitCode\nplease open an issue on jira for assistance"
            exit $gitExitCode ;;
    esac
else
    ok "no lightning code detected\ncloning new code..."
    #check if ssh is set up
    if [[ "$(ssh -o StrictHostKeyChecking=no git@github.com &> /dev/stdout)" == *"success"* ]] ; then
        git clone "git@github.com:frc-862/lightning.git" "$HOME/Documents/lightning"
    else
        git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
        warn "note: you will need to clone over ssh in order to contribute code"
    fi

    gitExitCode=$?
    case $gitExitCode in
        0)  ok "pull completed successfully" ;;
        *)
            error "clone failed with exit code $gitExitCode\nplease open an issue on jira for assistance"
            exit $gitExitCode ;;
    esac
fi

#Check if user has a properly set up gradle.properties file
if [ -f "$HOME/.gradle/gradle.properties" ] ; then
    if [[ "$(<"$HOME/.gradle/gradle.properties")" == *"gpr.key"*"gpr.user"* ]] || [[ "$(<"$HOME/.gradle/gradle.properties")" == *"gpr.user"*"gpr.key"* ]] ; then
        ok "gradle.properties properly configured"
    else
        warn "gradle.properties missing one or more required values"
    fi
else
    warn "no gradle.properties file found"
fi

#build lightning repo
ok "building gradle..."
"$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build

buildExitCode=$?
case $buildExitCode in
    0) ok "build completed successfully" ;;
    *) error "build failed with exit code $buildExitCode\nplease open an issue on jira for assistance" ;;
esac
