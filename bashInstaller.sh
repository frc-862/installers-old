#!/bin/bash

#Define constants
OS="$(uname -s)"

#Version Constants
INSTALLER_VERSION="2022-5 DEV"
WPILIB_VERSION="2022.2.1"
NI_VERSION="22.0.0"
PHOENIX_VERSION="5.20.2.2"
REV_VERSION="1.4.2"

#Option Defaults

#Function switches
RUN_UPDATE=true
RUN_INSTALLOPTS=true
RUN_INSTALLREQS=true
RUN_BUILD=true
RUN_UNINSTALL=false
SKIP_DEVWARN=false

#Package Switches
INSTALL_WPILIB=true
INSTALL_NI=true
INSTALL_LIGHTNING=true
INSTALL_PHOENIX=true

#Fallback switches
FALLBACK_WPILIB=false
FALLBACK_NI=false
FALLBACK_PHOENIX=false

#Define functions

#has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

#showHelp: show help information for the program
showHelp() { printf "Usage:
    bashInstaller --option1 --option2 \"value\"

Description:
    bashInstaller is a script to automatically install tools used for developing code for FIRST Robotics Competition.

General Options:
    --help, -h          show this help message
    --verbose, -v       give a more verbose output
    --version, -V       show program version
    --uninstall         uninstall previously installed programs

Wpilib Options:
    --wpilib_version    set the version of wpilib to install
    --no_wpilib         don't install wpilib
    --fallback_wpilib   use fallback downloading method for wpilib on windows (download from github)

Ni options:
    --ni_version        set the version of ni to install (windows only)
    --no_ni             don't install ni game tools (windows only)
    --fallback_ni       use fallback downloading method for ni tools on windows (download from ni website)

Phoenix options:
    --phoenix_version   set the version of phoenix framework to install (windows only)
    --no_phoenix        don't install phoenix framework (windows only)
    --fallback_phoenix  use fallback donwloading method for phoenix framework on windows (download from github)

Rev options:
    --rev_version       set the version of the rev hardware client to install (windows only)
    --no_rev            don't install rev hardware client (windows only)

Developer options:
    --no_update         don't update installed packages when running installer
    --no_opts           don't install optional packages when running installer
    --no_reqs           don't install required packages
    --no_build          don't build lightning at the end
    --no_lightning      don't clone or pull from lightning repo during install
    --spoof_os          set \$OS to the provided value
    --headless          turn off all user interaction, and disable any non-automated software
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
            RUN_INSTALLREQS=false
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
        "--phoenix_version")
            #set phoenix framework version
            PHOENIX_VERSION=$2
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
        "--no_reqs")
            RUN_INSTALLREQS=false
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
        "--no_phoenix")
            INSTALL_PHOENIX=false
            shift
            ;;
        "--no_rev")
            INSTALL_REV=false
            shift
            ;;
        "--rev_version")
            REV_VERSION=$2
            shift 2
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
        "--fallback_phoenix")
            FALLBACK_PHOENIX=true
            shift
            ;;
        "--spoof_os")
            OS=$2
            shift 2
            ;;
        "--headless")
            INSTALL_WPILIB=false
            SKIP_DEVWARN=true
            shift
            ;;
        "-"*)
            error "Unknown option $1"
            exit 1
            ;;
    esac
done

#give a warning if running a dev build
if [[ "$INSTALLER_VERSION" == *"DEV" ]] && ! $SKIP_DEVWARN ; then
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

        #ensure brew cask versions are tapped on install
        if ! [[ "$(brew tap)" == *"homebrew/cask-versions"* ]] ; then
            brew tap "homebrew/cask-versions"
        fi
        #define functions for each package manager
        #these functions are also defined for all other package managers

        #pkgHas: check if a provided package name is installed
        pkgHas() {
            [[ $(brew list) == *"$1"* ]]
        }

        #pkgVersion: get the latest availible version of a provided package
        pkgVersion() {
            brew info "$1" | grep "stable" | grep -Eo "([0-9]{1,}\.)+[0-9]{1,}"
        }

        #update: get the latest version of all installed packages
        update() {
            brew update;
            brew upgrade;
        }

        #installReqs: install required packages
        installReqs() {
            if ! has git ; then
                brew install git
            fi

            if ! pkgHas microsoft-openjdk11 ; then
                brew install microsoft-openjdk11
            fi
        }

        #installOpts: install optional packages
        installOpts() {
            if ! pkgHas lazygit ; then
                brew install lazygit;
            fi
        }

        #uninstall: remove all previosuly installed programs
        uninstall() {
            if pkgHas git ; then
                brew uninstall git
            fi

            if pkgHas lazygit ; then
                brew uninstall lazygit
            fi
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

        #Phoenix Constants
        PHOENIX_FILENAME="CTRE_Phoenix_Framework_v$PHOENIX_VERSION.exe"
        PHOENIX_URL="https://github.com/CrossTheRoadElec/Phoenix-Releases/releases/download/v$PHOENIX_VERSION/$PHOENIX_FILENAME"

        #Rev Constants
        REV_FILENAME="REV-Hardware-Client-Setup-$REV_VERSION.exe"
        REV_URL="https://github.com/REVrobotics/REV-Software-Binaries/releases/download/rhc-$REV_VERSION/$REV_FILENAME"

        #Package manager setup functions
        if ! has choco ; then #TODO: add chocolatey installation functionality
            ok "No chocolatey installation found. installing chocolatey..."
            powershell.exe -ExecutionPolicy Bypass -command "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        fi

        update() { true; } #intentionally left blank to prevent some issues with upgrading autohotkey

        pkgHas() {
            [[ "$(choco list -lo --pre)" == *"$1"* ]]
        }

        pkgVersion() {
            "$(choco list -lo --pre)" | grep "$1" | sed "s/$1 //"
        }

        installReqs() {
            if ! pkgHas "openjdk11" ; then
                choco install -y openjdk11
                export JAVA_HOME="C:\Program Files\OpenJDK\openjdk-11.0.13_8";
            fi

            if $INSTALL_WPILIB && ! pkgHas "wpilib" ; then
                if $FALLBACK_WPILIB ; then
                    true;
                else
                    choco install -y wpilib --version="$WPILIB_VERSION" --params="'/ProgrammingLanguage:java'";
                fi
            fi
        }

        installOpts() {
            #thanks to DarthJake (https://github.com/DarthJake) from 4146 for most of these repositories
            if ! pkgHas "lazygit" ; then
                choco install -y lazygit;
            fi

            if $INSTALL_NI && ! pkgHas "ni-frcgametools" ; then
                if $FALLBACK_WPILIB || $FALLBACK_NI ; then
                    choco install -y 7zip
                fi

                if $FALLBACK_NI ; then
                    if [ ! -f "$HOME/Downloads/$NI_FILENAME.iso" ] ; then
                        curl -L "$NI_URL" --output "$HOME/Downloads/$NI_FILENAME.iso"
                    fi
                    ok "extracting ni installer..."
                    7z.exe x -y -o"$HOME/Downloads/$NI_FILENAME" "$HOME/Downloads/$NI_FILENAME.iso"

                    ok "launching ni installer..."
                    "$HOME/Downloads/$NI_FILENAME/Install.exe" --passive --accept-eulas --prevent-reboot --prevent-activation

                else
                    choco install -y ni-frcgametools --version="$NI_VERSION"
                fi
            fi

            if $INSTALL_PHOENIX && ! pkgHas "ctre-phoenixframework" ; then
                if $FALLBACK_PHOENIX ; then
                    if [ ! -f "$HOME/Downloads/$PHOENIX_FILENAME" ] ; then
                        curl -L "$PHOENIX_URL" --output "$HOME/Downloads/$PHOENIX_FILENAME"
                    fi
                    ok "launching phoenix installer..."
                    "$HOME/Downloads/$PHOENIX_FILENAME"
                else
                    choco install -y ctre-phoenixframework --version="$PHOENIX_VERSION";
                fi
            fi

            if $INSTALL_REV ; then
                if [ ! -f "$HOME/Downloads/$REV_FILENAME" ] ; then
                    curl -L "$REV_URL" --output "$HOME/Downloads/$REV_FILENAME"
                fi
                ok "launching rev installer..."
                "$HOME/Downloads/$REV_FILENAME"
            fi
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
            pkgHas() {
                [[ $(apt list "$1") == *"installed"* ]]
            }

            pkgVersion() {
                apt show "$1" | grep "Version:" | sed "s/Version: //"
            }

            update() {
                $ROOT_STRING apt update;
                $ROOT_STRING apt -y upgrade;
            }

            installReqs() {
                if ! pkgHas "git" ; then
                    $ROOT_STRING apt -y install git
                fi

                if ! pkgHas "curl" ; then
                    $ROOT_STRING apt -y install curl
                fi

                if ! pkgHas "tar" ; then
                    $ROOT_STRING apt -y install tar
                fi

                if ! pkgHas "openjdk-11-jdk" ; then
                    $ROOT_STRING apt -y install openjdk-11-jdk
                fi
            }

            uninstall() {
                if pkgHas "git" ; then
                    $ROOT_STRING apt -y purge git
                fi

                if pkgHas "lazygit" ; then
                    $ROOT_STRING apt -y purge openjdk-11-jdk
                fi
            }

            # seperate ubuntu and debian installers because lazygit PPA is ubuntu only
            if [ -f "/etc/os-release" ] && [ "$(awk -F= '/^NAME/{print $2}' /etc/os-release)" == "Ubuntu" ] ; then

                installOpts() {
                    if ! pkgHas "lazygit" ; then
                        $ROOT_STRING apt -y install software-properties-common
                        $ROOT_STRING add-apt-repository "ppa:lazygit-team/release"
                        #check no_update flag here and give a warning since it's required
                        $ROOT_STRING apt -y update
                        $ROOT_STRING apt -y install lazygit
                    fi
                }

                PKG_MANAGER="apt (ubuntu)"
            else
                installOpts() { true; } #no optional packages on debian

                PKG_MANAGER="apt"
            fi

        elif has pacman ; then
            pkgHas() {
                pacman -Q | grep -q "$1"
            }

            pkgVersion() {
                pacman -Q "$1" | sed "s/$1 //"
            }

            update() {
                $ROOT_STRING pacman --noconfirm -Syu;
            }

            installReqs() {
                if ! pkgHas "git" ; then
                    $ROOT_STRING pacman --noconfirm -S git
                fi

                if ! pkgHas "curl" ; then
                    $ROOT_STRING pacman --noconfirm -S curl
                fi

                if ! pkgHas "tar" ; then
                    $ROOT_STRING pacman --noconfirm -S tar
                fi

                if ! pkgHas "jdk11-openjdk" ; then
                    $ROOT_STRING pacman --noconfirm -S jdk11-openjdk
                fi
            }

            installOpts() {
                if ! pkgHas "lazygit" ; then
                    $ROOT_STRING pacman --noconfirm -S lazygit;
                fi
            }

            uninstall() {
                if pkgHas "git" ; then
                    $ROOT_STRING pacman --noconfirm -R git
                fi

                if pkgHas "lazygit" ; then
                    $ROOT_STRING pacman --noconfirm -R lazygit
                fi
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
        127) warn "some chocolatey packages may not have been uninstalled properly." ;;
        *)  error "uninstall failed with exit code $installExitCode. please open an issue on jira for assistance"
            exit $installExitCode ;; #exit if a non-0 exit code is recieved
    esac
fi

if $RUN_INSTALLREQS ; then
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
    if [ ! -f "$HOME/Downloads/$WPILIB_FILENAME" ] ; then #skip download if file is already downloaded or isn't required
        curl -L "$WPILIB_URL" --output "$HOME/Downloads/$WPILIB_FILENAME"
    fi

    case $WPILIB_EXTENSION in #different methods for installing and running each archive
        "dmg")
            ok "Mounting wpilib installer..."
            hdiutil attach -readonly "$HOME/Downloads/$WPILIB_FILENAME" #dmg needs to be mounted using hdiutil on mac

            ok "Launching wpilib installer..."
            /Volumes/WPILibInstaller/WPILibInstaller.app/Contents/MacOS/WPILibInstaller

            ok "Unmounting wpilib installer..."
            hdiutil detach /Volumes/WPILibInstaller ;;
        "tar.gz")
            ok "extracting wpilib installer..."
            tar -xvzf "$HOME/Downloads/$WPILIB_FILENAME" #.tar.gz can be extracted using tar

            ok "launching wpilib installer..."
            "$HOME/Downloads/WPILib_$WPILIB_TYPE-$WPILIB_VERSION/WPILibInstaller" ;;
        "iso")
            ok "extracting wpilib installer..."
            7z.exe x -y -o"$HOME/Downloads/WPILib_$WPILIB_TYPE-$WPILIB_VERSION" "$HOME/Downloads/$WPILIB_FILENAME"

            ok "launching wpilib installer..."
            "$HOME/Downloads/WPILib_$WPILIB_TYPE-$WPILIB_VERSION/WPILibInstaller.exe"

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
        if [[ "$(<"$HOME/.gradle/gradle.properties")" == *"gpr.key"*"gpr.user"* ]] ||
           [[ "$(<"$HOME/.gradle/gradle.properties")" == *"gpr.user"*"gpr.key"* ]] ; then
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
