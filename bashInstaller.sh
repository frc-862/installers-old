#!/bin/bash

#Define functions
#Has: check if a program is in PATH
has() { type -p "$1" &> /dev/null; }
#Error, Warn, ok: print message in red, orange, or green text
#use of a variable in printf fstring is intentional here
error() { printf "\033[31m$1\n\033[39m"; }
warn() { printf "\033[33m$1\n\033[39m"; }
ok() { printf "\033[32m$1\n\033[39m"; }

#Define constants
os="$(uname -s)"
wpilibVersion="2021.3.1"

#detect a program to use to obtain root privileges
#set rootstring variable to say what command to use
if [ "$os" == "Darwin" ] ; then
    ok "no root privileges needed on macos"
elif has sudo ; then
    rootstring="sudo"
    ok "using sudo ($(type -p $rootstring)) for root privileges"
elif has doas ; then
    rootstring="doas"
    ok "using doas ($(type -p $rootstring)) for root privileges"
elif [ "$EUID" -eq 0 ] ; then
    rootstring=""
    ok "using current user ($USER) for root privileges"
else
    error "error: no root privileges"
    error "try running this script as root or verifying that sudo or doas is installed and in your PATH"
    exit 1
fi

#detect which wpilib release to download
if [ "$os" == "Linux" ] ; then
    wpilibType="Linux"
    wpilibExtension="tar.gz"
elif [ "$os" == "Darwin" ] ; then
    wpilibType="macOS"
    wpilibExtension="dmg"
elif [[ "$os" == *"MINGW64"* ]] ; then
    wpilibType="Windows64"
    wpilibExtension="iso"
elif [[ "$os" == *"MINGW"* ]] ; then
    wpilibType="Windows32"
    wpilibExtension="iso"
fi

#detect a compatible package manager to install packages
if [ "$os" == "Darwin" ] ; then
    # only install brew from scratch on mac
    if ! has brew ; then
        #if brew isn't installed and we are on mac, then install it
        ok "no brew installation detected\ninstalling brew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    #define functions for each package manager
    #these functions apply to all other package managers also
    #update: get the latest version of all packages
    update() {
        brew update;
        brew upgrade;
    }
    #installreqs: install required packages
    installreqs() {
        brew install git wget;
    }
    #installopts: install optional packages
    installopts() {
        brew install lazygit;
    }
    #pkgmanager: the name of the detected package manager
    pkgmanager="brew"
elif has apt ; then
    update() {
        $rootstring apt update;
        $rootstring apt -y upgrade;
    }
    installreqs() {
        $rootstring apt -y install git wget tar;
    }
    if [ -f "/etc/ubuntu-release" ] ; then # seperate ubuntu and debian installers because of lazygit PPA
        installopts() {
            $rootstring apt -y install software-properties-common
            #Lazygit PPA is Ubuntu only
            $rootstring add-apt-repository "ppa:lazygit-team/release"
            $rootstring apt -y update
            $rootstring apt -y install lazygit
        }
        pkgmanager="apt (ubuntu)"
    else
        installopts() { true; }
        pkgmanager="apt"
    fi
elif has pacman ; then
    update() { $rootstring pacman --noconfirm -Syu; }
    installreqs() { $rootstring pacman --noconfirm -S git wget tar; }
    installopts() { $rootstring pacman --noconfirm -S lazygit; }
    pkgmanager="pacman"
elif has scoop ; then
    update() {
        scoop install git;
        scoop update;
    }
    installreqs() { scoop install git;
        scoop bucket add java;
        scoop install wget;
        scoop install 7zip;
    }
    installopts() {
        scoop bucket add extras;
        scoop install lazygit;
    }
    pkgmanager="scoop"
else
    error "no supported package manager found\ntry verifying that one is installed and in your PATH"
    exit 1
fi

#run the defined update, installreqs, and installopts functions
ok "$pkgmanager installation detected\nupgrading $pkgmanager..."
update
updateexitcode=$?
if [ $updateexitcode -eq 0 ] ; then
    ok "update completed successfully"
else
    #don't exit if the update fails
    warn "warning: update failed with exit code $updateexitcode"
fi

ok "installing required packages..."
installreqs
installexitcode=$?
if [ $installexitcode -eq 0 ] ; then
    ok "installreqs completed successfully"
else
    #exit if a non-0 exit code is recieved
    error "error: installreqs failed with exit code $installexitcode\nplease open an issue on jira for assistance"
    exit $installexitcode
fi

ok "installing optional packages..."
installopts
installexitcode=$?
if [ $installexitcode -eq 0 ] ; then
    ok "installopts completed successfully"
else
    #don't exit if installopts fails, as the build can still work
    warn "warning: installopts failed with exit code $installexitcode"
fi

wpilibUrl="https://github.com/wpilibsuite/allwpilib/releases/download/v$wpilibVersion/WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
wpilibFilename="WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
ok "downloading wpilib installer..."
wget "$wpilibUrl" -O "$wpilibFilename"

if [ "$wpilibExtension" == "dmg" ] ; then
    ok "Mounting wpilib installer..."
    hdiutil attach -readonly "./$wpilibFilename" #dmg needs to be mounted
    ok "Launching wpilib installer..."
    /Volumes/WPILibInstaller/WPILibInstaller.app/Contents/MacOS/WPILibInstaller
    ok "Unmounting wpilib installer..."
    hdiutil detach /Volumes/WPILibInstaller
elif [ "$wpilibExtension" == "tar.gz" ] ; then
    ok "extracting wpilib installer..."
    tar -xvzf "./$wpilibFilename" #tgz is extractable by tar
    ok "launching wpilib installer..."
    "./WPILib_$wpilibType-$wpilibVersion/WPILibInstaller"
elif [ "$wpilibExtension" == "iso" ] ; then
    ok "extracting wpilib installer..."
    7z x -y -o"./$wpilibType" "./$wpilibFilename" #iso can be extracted with 7zip
    ok "launching wpilib installer..."
    "./$wpilibType/WPILibInstaller.exe"
fi

#clone lightning repo
ok "cloning lightning source code into $HOME/Documents/"
warn "note: you will need to clone over ssh in order to contribute code"
if [ -d "$HOME/Documents/lightning" ] ; then
    ok "lightning code detected\npulling latest version..."
    git -C "$HOME/Documents/lightning" pull
    gitexitcode=$?
    if [ $gitexitcode -eq 0 ] ; then
        ok "pull completed successfully"
    else
        error "error: pull failed with exit code $gitexitcode\nplease open an issue on jira for assistance"
        exit $gitexitcode
    fi
else
    ok "no lightning code detected\ncloning new code..."
    git clone "https://github.com/frc-862/lightning.git" "$HOME/Documents/lightning"
    gitexitcode=$?
    if [ $gitexitcode -eq 0 ] ; then
        ok "pull completed successfully"
    else
        error "error: clone failed with exit code $gitexitcode\nplease open an issue on jira for assistance"
        exit $gitexitcode
    fi
fi

#build lightning repo
ok "building gradle..."
"$HOME/Documents/lightning/gradlew" -p "$HOME/Documents/lightning" build
buildstatus=$?
#detect if the build failed based on its exit code
if [ $buildstatus -eq 0 ] ; then
    ok "build completed successfully"
else
    error "error: build failed with exit code $buildstatus\nplease open an issue on jira for assistance"
fi
