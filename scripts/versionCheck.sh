#!/bin/bash

#required packages:
#curl
#grep
#sed
#coreutils obv

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

printf "Latest Wpilib: $(latestWpilib)\n"
printf "Latest Phoenix: $(latestPhoenix)\n"
printf "Latest Rev: $(latestRev)\n"
printf "Latest NI Tools: $(latestNI)\n"
