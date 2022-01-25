#!/bin/bash


#TODO: merge this script into the main bashInstaller script

#required packages:
#curl
#grep
#sed
#coreutils obv

PRINT_VERSIONS=true

showHelp() { printf "Usage:
    versionCheck --option \"value\" --option \"value\"

Description:
    versionCheck is a script to get the latest version of the packages installed by bashInstaller

Options:
    --help, -h          show this help message
    --verbose, -v       toggle verbose output on
    --print             print latest versions to screen (default)
    --write             write latest versions to config file
"
}

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
        "--print")
            #print versions to screen
            PRINT_VERSIONS=true
            shift
            ;;
        "--write")
            #save versions to config file
            PRINT_VERSIONS=false
            shift
            ;;
    esac
done

latestGithubRelease() {
    curl --silent "https://api.github.com/repos/$1/$2/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                                 # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' |                                       # Pluck JSON value
    sed "s/^v//"                                                         # remove the v from the front of the version number
}

latestWpilib() {
    # Get latest wpilib version from github repo
    latestGithubRelease "wpilibsuite" "allwpilib"
}

latestPhoenix() {
    # get latest phoenix framework version from github repo
    latestGithubRelease "CrossTheRoadElec" "Phoenix-Releases"
}

latestRev() {
    # get latest rev hardware client version from github repo
    latestGithubRelease "REVrobotics" "REV-Software-Binaries" |
    sed "s/rhc-//"
}

latestNI() {
    #welcome to the pipe factory
    curl --silent -L "https://www.ni.com/en-us/support/downloads/drivers/download.frc-game-tools.html" | # download the ni webpage
    grep -Eo "[0-9]{2}\.[0-9]{1,2}\.[0-9]{1,2}" | # search the file for version numbers (in the format that ni uses for their software)
    sort -ur | # sort the version numbers newest to oldest
    head -n1 # grab the first item, which will be the latest version
}

WPILIB_VERSION=$(latestWpilib)
PHOENIX_VERSION=$(latestPhoenix)
REV_VERSION=$(latestRev)
NI_VERSION=$(latestNI)

if $PRINT_VERSIONS ; then
    printf "Wpilib: %s\n" "$WPILIB_VERSION"
    printf "Phoenix: %s\n" "$PHOENIX_VERSION"
    printf "Rev: %s\n" "$REV_VERSION"
    printf "NI Tools: %s\n" "$NI_VERSION"
else
    printf "WPILIB_VERSION=%s
PHOENIX_VERSION=%s
REV_VERSION=%s
NI_VERSION=%s
" "$WPILIB_VERSION" "$PHOENIX_VERSION" "$REV_VERSION" "$NI_VERSION" > "../bashInstaller.conf"
fi
