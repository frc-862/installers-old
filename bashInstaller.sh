#!/bin/bash

#Define constants
OS="$(uname -s)"
INSTALLER_VERSION="2022-2 DEV"

#Defaults
WPILIB_VERSION="2021.3.1"
NI_VERSION="20.0.1"
RUN_UPDATE=true
RUN_INSTALLOPTS=true
UNINSTALL=false

#Define functions

#has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

#showHelp: show help information for the program
showHelp() { printf "Usage:
    bashInstaller --option \"value\" --option \"value\"

Description:
    bashInstaller is a script to automatically install toold used for developing code for FIRST Robotics Competition.

Options:
    --help, -h          show this help message
    --verbose, -v       give a more verbose output
    --version, -V       show program version
    --uninstall         uninstall previously installed programs
    --wpilib_version    set the version of wpilib to install
    --ni_version        set the version of ni to install (windows only)
    --no_update         don't update installed packages when running installer
    --no_opts           don't install optional packages when running installer
";
}

#Error, Warn, ok: print message in red, orange, or green text
#use of a variable in printf fstring is intentional here
error() { >&2 printf "\033[91mERROR: $1\n\033[39m"; }
warn() { >&2 printf "\033[93mWARNING: $1\n\033[39m"; }
ok() { printf "\033[92mOK: $1\n\033[39m"; }

#Interpret parameters
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            #Display Help message and exit
            showHelp
            exit 0
            ;;
        -v|--verbose)
            #Toggle verbose output on
            set -x
            shift
            ;;
        -V|--version)
            #Print the current version and exit
            printf 'bashInstaller %s\n' "$INSTALLER_VERSION"
            exit 0
            ;;
        --uninstall)
            #Switch to uninstall mode
            RUN_UPDATE=false
            RUN_INSTALLOPTS=false
            UNINSTALL=true
            shift
            ;;
        --wpilib_version)
            #set wpilib version
            WPILIB_VERSION=$2
            shift 2
            ;;
        --ni_version)
            #set ni version
            NI_VERSION=$2
            shift 2
            ;;
        --no_update)
            #Toggle updating on install off
            RUN_UPDATE=false
            shift
            ;;
        --no_opts)
            #Toggle installing optional packages off
            RUN_INSTALLOPTS=false
            shift
            ;;
        -*)
            error "Unknown option $1"
            exit 1
            ;;
    esac
done

#give a warning if running a dev build
if [[ "$INSTALLER_VERSION" == *"DEV" ]] ; then
    warn "You are running a development version of the installer. Some features may not work properly. Only continue if you know what you're doing."
    read -rp "Continue Anyway? [y/N] "
    #TODO: make this less awful
    case $REPLY in
        "y") true;;
        "Y") true;;
        "yes") true;;
        "Yes") true;;
        *) exit 1;;
    esac
fi

#detect a program to use for root privileges
#and set ROOT_STRING variable to the found command
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
    error "no root privilege"
    error "try running this script as root and verifying that sudo/doas is installed and in your PATH"
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
        ok "no brew installation detected, installing brew..."
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
        brew install git;
    }

    #installOpts: install optional packages
    installOpts() {
        brew install lazygit;
    }

    #uninstall: remove all previosuly installed programs
    uninstall() {
        brew uninstall git lazygit
    }

    #PKG_MANAGER: the name of the detected package manager
    PKG_MANAGER="brew"

elif [[ $OS == *"MINGW"* ]] ; then

    if ! has choco ; then
        ok "no chocolatey installation detected, installing chocolatey..."
        error "sorry, installing chocolatey from git bash hasn't been implemented yet :("
        exit 1
        #powershell.exe -ExecutionPolicy Bypass -NoProfile
        #requires -version 4.0
        #requires -RunAsAdministrator
        #Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        #choco install -y git
        #refreshenv
    fi

    update() { true; } #intentionally left blank to prevent some issues with upgrading autohotkey

    installReqs() {
        choco install -y openjdk11
        choco install -y wpilib --version="$WPILIB_VERSION" --params="'/ProgrammingLanguage:java'";
        export JAVA_HOME="C:\Program Files\OpenJDK\openjdk-11.0.13_8";
    }

    installOpts() {
        #thanks to DarthJake (https://github.com/DarthJake) from 4146 for most of these repositories
        choco install -y lazygit;
        choco install -y ni-frcgametools --version="$NI_VERSION";
        choco install -y ctre-phoenixframework;
    }

    uninstall() {
        choco uninstall openjdk11 wpilib lazygit ni-frcgametools ctre-phoenixframework
    }

    PKG_MANAGER="chocolatey"


elif has apt ; then

    update() {
        $ROOT_STRING apt update;
        $ROOT_STRING apt -y upgrade;
    }

    installReqs() {
        $ROOT_STRING apt -y install git curl tar;
    }

    if [ -f "/etc/ubuntu-release" ] ; then # seperate ubuntu and debian installers because lazygit PPA is ubuntu only

        installOpts() {
            $ROOT_STRING apt -y install software-properties-common
            $ROOT_STRING add-apt-repository "ppa:lazygit-team/release"
            $ROOT_STRING apt -y update
            $ROOT_STRING apt -y install lazygit
        }

        uninstall() {
            $ROOT_STRING apt -y uninstall git lazygit
        }
        PKG_MANAGER="apt (ubuntu)"
    else
        installOpts() { true; } #no optional packages on debian

        uninstall() {
            $ROOT_STRING apt -y uninstall git
        }

        PKG_MANAGER="apt"
    fi

elif has pacman ; then

    update() {
        $ROOT_STRING pacman --noconfirm -Syu;
    }

    installReqs() {
        $ROOT_STRING pacman --noconfirm -S git curl tar;
    }

    installOpts() {
        $ROOT_STRING pacman --noconfirm -S lazygit;
    }

    uninstall() {
        $ROOT_STRING pacman --noconfirm -R git lazygit
    }

    PKG_MANAGER="pacman"

else
    error "no supported package manager found, try verifying that one is installed and in your PATH"
    exit 1
fi
if $RUN_UPDATE ; then
    #run the defined update, installReqs, and installOpts functions
    ok "$PKG_MANAGER installation detected, upgrading $PKG_MANAGER..."
    update

    updateExitCode=$?
    case $updateExitCode in
        0)  ok "update completed successfully";;
        *)  warn "update failed with exit code $updateExitCode" #don't exit if the update fails
    esac
fi

if $UNINSTALL ; then
    ok "uninstalling all packages..."
    uninstall
else
    ok "installing required packages..."
    installReqs
fi

installExitCode=$?
case $installExitCode in
    0)  ok "installReqs completed successfully" ;;
    *)  error "installReqs failed with exit code $installExitCode. please open an issue on jira for assistance"
        exit $installExitCode ;; #exit if a non-0 exit code is recieved 
esac

if $RUN_INSTALLOPTS ; then
    ok "installing optional packages..."
    installOpts

    installExitCode=$?
    case $installExitCode in
        0)  ok "installOpts completed successfully" ;;
        *)  warn "installOpts failed with exit code $installExitCode" #don't exit if installOpts fails, as the build can still work
    esac
fi

if $NEEDS_WPILIB_DOWNLOAD ; then
    ok "downloading wpilib installer..."
    if [ ! -f "./$WPILIB_FILENAME" ] ; then #skip download if file is already downloaded or isn't required
        curl -L "$WPILIB_URL" --output "$WPILIB_FILENAME"
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
    ok "lightning code detected, pulling latest version..."
    git -C "$HOME/Documents/lightning" pull

    gitExitCode=$?
    case $gitExitCode in
        0)  ok "pull completed successfully" ;;
        *)
            error "pull failed with exit code $gitExitCode. please open an issue on jira for assistance"
            exit $gitExitCode ;;
    esac
else
    ok "no lightning code detected, cloning new code..."
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
            error "clone failed with exit code $gitExitCode. please open an issue on jira for assistance"
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

#Don't run build if running from git bash inside powershell terminal, as gradle special characters won't work
if [[ $OS == *"MINGW"* ]] && [ -n "$PSExecutionPolicyPreference" ] ; then
    exit 0
fi

"$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build

buildExitCode=$?
case $buildExitCode in
    0) ok "build completed successfully" ;;
    *) error "build failed with exit code $buildExitCode. please open an issue on jira for assistance" ;;
esac
