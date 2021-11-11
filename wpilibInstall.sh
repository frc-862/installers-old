#!/bin/bash

os="$(uname -s)"
wpilibVersion="2021.3.1"

if [ "$os" == "Linux" ] ; then
    wpilibType="Linux"
    wpilibExtension="tar.gz" #tgz is extractable by tar
elif [ "$os" == "Darwin" ] ; then
    wpilibType="macOS"
    wpilibExtension="dmg" #dmg needs to be mounted
fi

wpilibUrl="https://github.com/wpilibsuite/allwpilib/releases/download/v$wpilibVersion/WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
wpilibFilename="WPILib_$wpilibType-$wpilibVersion.$wpilibExtension"
wget "$wpilibUrl" -O "$wpilibFilename"

if [ "$wpilibExtension" == "dmg" ] ; then
    hdiutil attach -readonly "./$wpilibFilename"
    /Volumes/WPILibInstaller/WPILibInstaller.app/Contents/MacOS/WPILibInstaller
    hdiutil detach /Volumes/WPILibInstaller
fi
