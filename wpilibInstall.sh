#!/bin/bash

#this script download and runs the wpilib installer
#the user will still need to step through the installer

#NEW DEPENDENCIES:
#wget (for all systems)
#tar (linux)
#7zip (windows)

#BUNDLED SOFTWARE
#Wpilib vscode (probably won't use)
#gradle (installed when you run a build)
#a jdk (good alternative to installing from a package manager)
#wpilib tools (pathweaver, etc.)
#wpilib deps
#wpilib vs code extensions (probably won't use)

os="$(uname -s)"
wpilibVersion="2021.3.1"

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

wpilibUrl="https://github.com/wpilibsuite/allwpilib/releases/download/v$wpilibVersion/WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
wpilibFilename="WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
wget "$wpilibUrl" -O "$wpilibFilename"

if [ "$wpilibExtension" == "dmg" ] ; then
    hdiutil attach -readonly "./$wpilibFilename" #dmg needs to be mounted
    /Volumes/WPILibInstaller/WPILibInstaller.app/Contents/MacOS/WPILibInstaller
    hdiutil detach /Volumes/WPILibInstaller
elif [ "$wpilibExtension" == "tar.gz" ] ; then
    tar -xvzf "./$wpilibFilename" #tgz is extractable by tar
    "./WPILib_$wpilibType-$wpilibVersion/WPILibInstaller"
elif [ "$wpilibExtension" == "iso" ] ; then
    7z x -y -o "./$wpilibType" "./$wpilibFilename" #iso can be extracted with 7zip
fi
