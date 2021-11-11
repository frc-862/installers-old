#!/bin/bash

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
    7z x -y -o "./$wpilibType" "./$wpilibFilename"
fi
