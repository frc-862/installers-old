#!/bin/bash

#Define constants
OS="$(uname -s)"

#Version Constants
INSTALLER_VERSION="2022-2 DEV"
WPILIB_VERSION="2022.1.1"
NI_VERSION="22.0.0"

#Option Defaults

#Function switches
RUN_UPDATE=true
RUN_INSTALLOPTS=true
RUN_BUILD=true
RUN_UNINSTALL=false

#Package Switches
INSTALL_WPILIB=true
INSTALL_NI=true
INSTALL_LIGHTNING=true

#Fallback switches
FALLBACK_WPILIB=false
FALLBACK_NI=false

#Define functions

#has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

#showHelp: show help information for the program
showHelp() { printf "Usage:
    bashInstaller --option \"value\" --option \"value\"

Description:
    bashInstaller is a script to automatically install tools used for developing code for FIRST Robotics Competition.

Options:
    --help, -h          show this help message
    --verbose, -v       give a more verbose output
    --version, -V       show program version
    --uninstall         uninstall previously installed programs
    --wpilib_version    set the version of wpilib to install
    --ni_version        set the version of ni to install (windows only)
    --no_update         don't update installed packages when running installer
    --no_opts           don't install optional packages when running installer
    --no_wpilib         don't install wpilib
    --no_ni             don't install ni game tools
    --no_build          don't build lightning at the end
    --no_lightning      don't clone or pull from lightning repo during install
    --fallback_wpilib   use fallback downloading method for wpilib on windows (download from github)
    --fallback_ni       use fallback downloading method for ni tools on windows (download from ni website)
    --spoof_os          set \$OS to the provided value
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
        "-h"|"--help")
            #Display Help message and exit
            showHelp
            exit 0
            ;;
        "-v"|"--verbose")
            #Toggle verbose output on
            set -x
            shift
            ;;
        "-V"|"--version")
            #Print the current version and exit
            printf 'bashInstaller %s\n' "$INSTALLER_VERSION"
            exit 0
            ;;
        "--uninstall")
            #Switch to uninstall mode
            RUN_UPDATE=false
            RUN_INSTALLOPTS=false
            RUN_UNINSTALL=true
            INSTALL_WPILIB=false
            INSTALL_NI=false
            RUN_BUILD=false
            INSTALL_LIGHTNING=false
            shift
            ;;
        "--wpilib_version")
            #set wpilib version
            WPILIB_VERSION=$2
            shift 2
            ;;
        "--ni_version")
            #set ni version
            NI_VERSION=$2
            shift 2
            ;;
        "--no_update")
            #Toggle updating on install off
            RUN_UPDATE=false
            shift
            ;;
        "--no_opts")
            #Toggle installing optional packages off
            RUN_INSTALLOPTS=false
            shift
            ;;
        "--no_wpilib")
            INSTALL_WPILIB=false
            shift
            ;;
        "--no_ni")
            INSTALL_NI=false
            shift
            ;;
        "--no_build")
            RUN_BUILD=false
            shift
            ;;
        "--no_lightning")
            INSTALL_LIGHTNING=false
            shift
            ;;
        "--fallback_wpilib")
            FALLBACK_WPILIB=true
            shift
            ;;
        "--fallback_ni")
            FALLBACK_NI=true
            shift
            ;;
        "--spoof_os")
            OS=$2
            shift 2
            ;;
        "-"*)
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
case $OS in

    "Darwin")

        #WPILIB Constants
        NEEDS_WPILIB_DOWNLOAD=true
        WPILIB_TYPE="macOS"
        WPILIB_EXTENSION="dmg"

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
        ;;

    *"MINGW"*)

        #WPILIB Constants
        NEEDS_WPILIB_DOWNLOAD=$FALLBACK_WPILIB #only download if fallback method is selected
        WPILIB_TYPE="Windows64"
        WPILIB_EXTENSION="iso"

        #NI Constants
        NI_YEAR_SHORT="${NI_VERSION::2}"
        NI_VERSION_SHORT="${NI_VERSION::4}"
        NI_FILENAME="ni-frc-20$NI_YEAR_SHORT-game-tools_${NI_VERSION}_offline"
        NI_URL="https://download.ni.com/support/nipkg/products/ni-f/ni-frc-20$NI_YEAR_SHORT-game-tools/$NI_VERSION_SHORT/offline/$NI_FILENAME.iso"

        #Package manager setup functions
        if ! has choco ; then #TODO: add chocolatey installation functionality
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
            if $INSTALL_WPILIB || ! $FALLBACK_WPILIB ; then
                choco install -y wpilib --version="$WPILIB_VERSION" --params="'/ProgrammingLanguage:java'";
            fi
            export JAVA_HOME="C:\Program Files\OpenJDK\openjdk-11.0.13_8";
        }

        installOpts() {
            #thanks to DarthJake (https://github.com/DarthJake) from 4146 for most of these repositories
            choco install -y lazygit;
            if $INSTALL_NI ; then
                if $FALLBACK_NI ; then
                    curl -L "$NI_URL" --output "$NI_FILENAME"
                    ok "extracting ni installer..."
                    7z.exe x -y -o"./$NI_FILENAME" "./$NI_FILENAME.iso"

                    ok "launching ni installer..."
                    "$NI_FILENAME/Install.exe" --passive --accept-eulas --prevent-reboot --prevent-activation

                else
                    choco install -y ni-frcgametools --version="20.0.0"; #left to old version as 22.0.0 isn't on choco yet
                fi
            fi
            if $FALLBACK_WPILIB || $FALLBACK_NI ; then
                choco install -y 7zip
            fi
            choco install -y ctre-phoenixframework;
        }

        uninstall() {
            choco uninstall -y openjdk11 wpilib lazygit ni-frcgametools ctre-phoenixframework
        }

        PKG_MANAGER="chocolatey"
        ;;

    "Linux")
        if [ "$EUID" -eq 0 ] ; then
            ROOT_STRING=""
            ok "using current user ($USER) for root privileges"
        elif has sudo ; then
            ROOT_STRING="sudo"
            ok "using sudo ($(type -p $ROOT_STRING)) for root privileges"
        elif has doas ; then
            ROOT_STRING="doas"
            ok "using doas ($(type -p $ROOT_STRING)) for root privileges"
        else
            error "no root privilege"
            error "try running this script as root and verifying that sudo/doas is installed and in your PATH"
            exit 1
        fi

        NEEDS_WPILIB_DOWNLOAD=true
        WPILIB_TYPE="Linux"
        WPILIB_EXTENSION="tar.gz"

        if has apt ; then

            update() {
                $ROOT_STRING apt update;
                $ROOT_STRING apt -y upgrade;
            }

            installReqs() {
                $ROOT_STRING apt -y install git curl tar;
            }

            if [ -f "/etc/os-release" ] && [ "$(awk -F= '/^NAME/{print $2}' /etc/os-release)" == "Ubuntu" ] ; then # seperate ubuntu and debian installers because lazygit PPA is ubuntu only

                installOpts() {
                    $ROOT_STRING apt -y install software-properties-common
                    $ROOT_STRING add-apt-repository "ppa:lazygit-team/release"
                    #check no_update flag here and give a warning since it's required
                    $ROOT_STRING apt -y update
                    $ROOT_STRING apt -y install lazygit
                }

                uninstall() {
                    $ROOT_STRING apt -y purge git lazygit
                }
                PKG_MANAGER="apt (ubuntu)"
            else
                installOpts() { true; } #no optional packages on debian

                uninstall() {
                    $ROOT_STRING apt -y purge git
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
        fi
        ;;
esac

#wpilib constants
WPILIB_FILENAME="WPILib_$WPILIB_TYPE-$WPILIB_VERSION.$WPILIB_EXTENSION"
WPILIB_URL="https://github.com/wpilibsuite/allwpilib/releases/download/v$WPILIB_VERSION/$WPILIB_FILENAME"

#Run defined package manager functions
if $RUN_UPDATE ; then
    ok "$PKG_MANAGER installation detected ($(type -p $PKG_MANAGER)), upgrading $PKG_MANAGER..."
    update

    updateExitCode=$?
    case $updateExitCode in
        0)  ok "update completed successfully";;
        *)  warn "update failed with exit code $updateExitCode";; #don't exit if the update fails
    esac
fi

if $RUN_UNINSTALL ; then
    ok "uninstalling all packages..."
    uninstall

    installExitCode=$?
    case $installExitCode in
        0)  ok "installReqs completed successfully" ;;
        *)  error "installReqs failed with exit code $installExitCode. please open an issue on jira for assistance"
            exit $installExitCode ;; #exit if a non-0 exit code is recieved
    esac
else
    ok "installing required packages..."
    installReqs

    installExitCode=$?
    case $installExitCode in
        0)  ok "installReqs completed successfully" ;;
        *)  error "installReqs failed with exit code $installExitCode. please open an issue on jira for assistance"
            exit $installExitCode ;; #exit if a non-0 exit code is recieved
    esac
fi

if $RUN_INSTALLOPTS ; then
    ok "installing optional packages..."
    installOpts

    installExitCode=$?
    case $installExitCode in
        0)  ok "installOpts completed successfully" ;;
        *)  warn "installOpts failed with exit code $installExitCode" #don't exit if installOpts fails, as the build can still work
    esac
fi

if $NEEDS_WPILIB_DOWNLOAD && $INSTALL_WPILIB ; then
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
        "iso")
            ok "extracting wpilib installer..."
            7z.exe x -y -o"./WPILib_$WPILIB_TYPE-$WPILIB_VERSION" "./$WPILIB_FILENAME"

            ok "launching wpilib installer..."
            "./WPILib_$WPILIB_TYPE-$WPILIB_VERSION/WPILibInstaller.exe"

    esac
fi


if $INSTALL_LIGHTNING ; then
    #check if lightning is already cloned
    if [ -d "$HOME/Documents/lightning" ] ; then
        ok "lightning code detected at '$HOME/Documents/lightning', pulling latest version..."
        git -C "$HOME/Documents/lightning" pull

        gitExitCode=$?
        case $gitExitCode in
            0)  ok "pull completed successfully" ;;
            *)
                error "pull failed with exit code $gitExitCode. please open an issue on jira for assistance"
                exit $gitExitCode ;;
        esac
    else
        #clone lightning repo
        ok "cloning lightning source code into $HOME/Documents/"
        #check if ssh is set up
        if [[ "$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null git@github.com &> /dev/stdout)" == *"success"* ]] ; then
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
fi

if $RUN_BUILD ; then
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
fi
