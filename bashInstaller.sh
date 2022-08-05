#!/bin/bash

#has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }

#showHelp: show help information for the program
showHelp() { printf "Usage:
    bashInstaller --option1 --option2 \"value\"

Description:
    bashInstaller is a script to automatically install tools used for developing code for FIRST Robotics Competition.

General Options:
    --help, -h          show this help message
    --verbose, -v       give a more verbose output, equivalent to running with -x flag
    --version, -V       show program version
    --uninstall         uninstall previously installed programs

Wpilib Options:
    --wpilib_version    set the version of wpilib to install
    --no_wpilib         don't install wpilib

Ni options:
    --ni_version        set the version of ni to install (windows only)
    --no_ni             don't install ni game tools (windows only)

Phoenix options:
    --phoenix_version   set the version of phoenix framework to install (windows only)
    --no_phoenix        don't install phoenix framework (windows only)

Rev options:
    --rev_version       set the version of the rev hardware client to install (windows only)
    --no_rev            don't install rev hardware client (windows only)

Developer options:
    --no_update         don't update installed packages when running installer
    --no_opts           don't install optional packages when running installer
    --no_reqs           don't install required packages (warning: this will cause things to break)
    --no_build          don't build lightning at the end of the script
    --no_lightning      don't clone or pull from lightning repo during install
    --spoof_os          set \$OS to the provided value
    --version_check     prints the latest availible version of software and exits the script.
    --headless          turn off all user interaction, and disable any non-automated software
";
}

#Error, Warn, ok: print message in red, orange, or green text
#use of a variable in printf fstring is intentional here
error() { >&2 echo -e "\033[91mERROR: $1\033[39m"; exit "$2"; }
warn() { >&2 echo -e "\033[93mWARNING: $1\033[39m"; }
ok() { echo -e "\033[92mOK: $1\033[39m"; }

#parseExitCode: give a message based on an install function's exit code
parseExitCode() {
    #params:
    #1: the exit code to parse
    #2: the name of the install function
    #3: boolean if it's a critical program or not

    message="Task $2 failed with exit code $1. Please open an issue on jira for assistance"

    case $1 in
        0) ok "Task $2 completed successfully" ;;
        *) if $3 ; then error "$message" "$1"; else warn "$message"; fi ;;
    esac

}

#function to grab the title of the latest github release on a provided user's repo
latestGithubRelease() {
    curl --silent "https://api.github.com/repos/$1/$2/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                 # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |                                       # Pluck JSON value
    sed "s/^v//"                                                         # remove the v from the front of the version number
}

# Get latest wpilib version from github repo
latestWpilib() { latestGithubRelease "wpilibsuite" "allwpilib"; }

# get latest phoenix framework version from github repo
latestPhoenix() { latestGithubRelease "CrossTheRoadElec" "Phoenix-Releases"; }

# get latest rev hardware client version from github repo
# also remove rhc- prefix from the beginning of the string
latestRev() { latestGithubRelease "REVrobotics" "REV-Software-Binaries" | sed "s/rhc-//"; }

latestNI() {
    #welcome to the pipe factory
    curl --silent -L "https://www.ni.com/en-us/support/downloads/drivers/download.frc-game-tools.html" | # download the ni webpage
    grep -Eo "[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}" | # search the file for version numbers (in the format that ni uses for their software)
    sort -ur | # sort the version numbers newest to oldest
    head -n1 # grab the first item, which will be the latest version
}

installWpilib() {
    #wpilib constants
    WPILIB_FILENAME="WPILib_$WPILIB_TYPE-$WPILIB_VERSION.$WPILIB_EXTENSION"
    WPILIB_URL="https://github.com/wpilibsuite/allwpilib/releases/download/v$WPILIB_VERSION/$WPILIB_FILENAME"

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
            tar -xvzf "$HOME/Downloads/$WPILIB_FILENAME" -C "$HOME/Downloads" #.tar.gz can be extracted using tar

            ok "launching wpilib installer..."
            "$HOME/Downloads/WPILib_$WPILIB_TYPE-$WPILIB_VERSION/WPILibInstaller" ;;
        "iso")
            ok "extracting wpilib installer..."
            7z.exe x -y -o"$HOME/Downloads/WPILib_$WPILIB_TYPE-$WPILIB_VERSION" "$HOME/Downloads/$WPILIB_FILENAME"

            ok "launching wpilib installer..."
            "$HOME/Downloads/WPILib_$WPILIB_TYPE-$WPILIB_VERSION/WPILibInstaller.exe"

    esac
}

installLightning() {
    #check if lightning is already cloned
    if [ -d "$HOME/Documents/lightning" ] ; then
        ok "lightning code detected at '$HOME/Documents/lightning', pulling latest version..."
        git -C "$HOME/Documents/lightning" pull
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
    fi
}

buildLightning() {
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

    "$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" -Dorg.gradle.java.home="$HOME/wpilib/${WPILIB_VERSION::4}/jdk" build
}

versionCheck() {
    versionTable="name latest\n"
    versionTable+="wpilib $WPILIB_VERSION\n"
    versionTable+="ni $NI_VERSION\n"
    versionTable+="phoenix $PHOENIX_VERSION\n"
    versionTable+="rev $REV_VERSION"
    echo -e "$versionTable" | column --table
}

runTask() {
    #params:
    #1: run variable
    #2: program name
    #3 frontend name
    #4 critical?
    if $1 ; then
        ok "Running Task $3..." 
        "$2"
        parseExitCode "$?" "$3" "$4"
fi
}

#pull default values fron config
if [ -f "./installConfig.conf" ] ; then
    source "./installConfig.conf"
else
    warn "No Config File Found"
fi

#Define constants
OS="$(uname -s)"

#General Options
INSTALLER_VERSION="2022-5 DEV"

#version detection
WPILIB_VERSION=$(latestWpilib)
NI_VERSION=$(latestNI)
PHOENIX_VERSION=$(latestPhoenix)
REV_VERSION=$(latestRev)

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
        "--spoof_os")
            OS=$2
            shift 2
            ;;
        "--version_check")
            RUN_VERSION_CHECK=true
            RUN_INSTALLOPTS=false
            RUN_INSTALLREQS=false
            RUN_UPDATE=false
            RUN_BUILD=false
            INSTALL_LIGHTNING=false
            INSTALL_NI=false
            INSTALL_PHOENIX=false
            INSTALL_REV=false
            INSTALL_WPILIB=false
            shift
            ;;
        "--headless")
            INSTALL_WPILIB=false
            INSTALL_NI=false
            INSTALL_PHOENIX=false
            INSTALL_REV=false
            SKIP_DEVWARN=true
            shift
            ;;
        "-"*)
            error "Unknown option $1" "1"
            ;;
    esac
done

#give a warning if running a dev build
if [[ "$INSTALLER_VERSION" == *"DEV" ]] && ! $SKIP_DEVWARN ; then
    warn "You are running a development version of the installer. Some features may not work properly. Continue at your own risk."
    read -rp "Continue Anyway? [y/N] "
    case "${REPLY,,}" in
        "y") true;;
        "yes") true;;
        *) exit 1;;
    esac
fi

#detect a program to use for root privileges
#and set ROOT_STRING variable to the found command
case $OS in

    "Darwin")
        #WPILIB Constants
        WPILIB_TYPE="macOS"
        WPILIB_EXTENSION="dmg"

        #we use brew on macos because installing git on macos without it can be sketchy
        #brew is also incredibly common among advanced users, who this script is intended for

        #install brew if it's not already installed
        if ! has brew ; then
            ok "no brew installation detected, installing brew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        #ensure brew cask versions are tapped on install
        if ! [[ "$(brew tap)" == *"homebrew/cask-versions"* ]] ; then
            brew tap "homebrew/cask-versions"
        fi
        #define functions for each package manager
        #these functions are also defined for every other package manager based OS

        #pkgHas: check if a provided package name is installed
        pkgHas() {
            [[ $(brew list) == *"$1"* ]]
        }

        #update: get the latest version of all installed packages
        update() {
            brew update;
            brew upgrade;
        }

        #installReqs: install required packages
        #these packages will raise a critical error if they fail to install
        installReqs() {
            if ! has git ; then
                brew install git
            fi
        }

        #installOpts: install optional packages
        #these packages will not raise a critical error if they fail to install
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
        #Windows is, as always, a little bit special.
        #Although chocolatey does exist, the FRC software is consistently out of date
        #So, we download everything from github and make use of git-bash's wonderful builtin programs
        #This OS is the longest because it has NI tools, Phoenix Tuner, and Rev Tuner in addition to WPIlib

        #WPILIB Constants
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

        update() { 
            warn "Windows Doesn't Use a Package Manager, and Therefore can't be automatically updated.
    If you'd like to update your programs, just run the standard install script.";
        }

        installOpts() {
            #TODO: add lazygit installation
            #TODO: deal with 7zip dependency

            if $INSTALL_NI ; then
                if [ ! -f "$HOME/Downloads/$NI_FILENAME.iso" ] ; then
                    curl -L "$NI_URL" --output "$HOME/Downloads/$NI_FILENAME.iso"
                fi
                ok "extracting ni installer..."
                7z.exe x -y -o"$HOME/Downloads/$NI_FILENAME" "$HOME/Downloads/$NI_FILENAME.iso"

                ok "launching ni installer..."
                "$HOME/Downloads/$NI_FILENAME/Install.exe" --passive --accept-eulas --prevent-reboot --prevent-activation
            fi

            if $INSTALL_PHOENIX ; then
                if [ ! -f "$HOME/Downloads/$PHOENIX_FILENAME" ] ; then
                    curl -L "$PHOENIX_URL" --output "$HOME/Downloads/$PHOENIX_FILENAME"
                fi
                ok "launching phoenix installer..."
                "$HOME/Downloads/$PHOENIX_FILENAME"
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
            warn "Sorry, There's no uninstall functionality on windws yet. You can remove programs using windows' built in add/remove programs app"
        }
        ;;

    "Linux")
        #linux makes use of whatever the built in package manager is (like a sophisticated OS)
        #pacman and apt are supported

        #figure out how to acqure root access to install packages
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
            error "no root privilege\ntry running this script as root and verifying that sudo/doas is installed and in your PATH" "1"
        fi

        WPILIB_TYPE="Linux"
        WPILIB_EXTENSION="tar.gz"

        if has apt ; then
            pkgHas() {
                [[ $(apt list "$1") == *"installed"* ]]
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
            }

            uninstall() {
                if pkgHas "git" ; then
                    $ROOT_STRING apt -y purge git
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


runTask "$RUN_UPDATE" "update" "Update $PKG_MANAGER" false

runTask "$RUN_VERSION_CHECK" "versioncheck" "Version Check" false

runTask "$RUN_UNINSTALL" "uninstall" "Uninstall" true

runTask "$RUN_INSTALLREQS" "installReqs" "Install Required Packages" true

runTask "$RUN_INSTALLOPTS" "installOpts" "Install Optional Packages" false

runTask "$INSTALL_WPILIB" "installWpilib" "WPIlib Install" true

runTask "$INSTALL_LIGHTNING" "installLightning" "Lightning Repo Install" true

runTask "$RUN_BUILD" "buildLightning" "Build Lightning Repo" true
