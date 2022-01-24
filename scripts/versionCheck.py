#!/usr/bin/env python3
""""Get the latest version of the software installed by the script"""
import json
from packaging import version
import requests

def multiStrip(string: str, toRemove: list) -> str:
    """Run .strip() on the given string once per item in the toRemove list"""
    for i in toRemove:
        string = string.strip(i)
    return string

def latestGithubRelease(username: str, repo: str) -> version.LegacyVersion | version.Version:
    """get the latest github release of the provided repo"""
    #grab latest json info on the latest info from github api, parse it, pull out release name, and parse it with packaging
    return version.parse(requests.get("https://api.github.com/repos/" + username + "/" + repo + "/releases/latest").json()["tag_name"])

def latestWpilib() -> version.LegacyVersion | version.Version:
    """Get latest wpilib version from github repo"""
    return latestGithubRelease("wpilibsuite", "allwpilib")

def latestPhoenix() -> version.LegacyVersion | version.Version:
    """get latest phoenix framework version from github repo"""
    return latestGithubRelease("CrossTheRoadElec", "Phoenix-Releases")

def latestNI() -> version.LegacyVersion | version.Version:
    """get latest ni version from their website"""
    versions = []
    #download latest ni download page
    for i in requests.get("https://www.ni.com/en-us/support/downloads/drivers/download.frc-game-tools.html").text.split("\n"):
        #pull out the line containing info on all availible releases
        if "NI.Download.init" in i:
            #from that line, clean up extra stuff from html and parse it as a dict
            versionString = json.loads(multiStrip(i.lstrip(), [";", "NI.Download.init", "(", ")"]))
            break

    for i in versionString:
        try:
            #from the availible releases, grab download urls and chop them up to get version number
            versions.append(version.parse(i["includedversions-downloadpath"].split("/")[-1].split("_")[1]))
        except KeyError:
            continue
    #because of the wonderful version.LegacyVersion and version.Version types we can just do max() to find the newest version
    return max(versions)

print("Latest Wpilib version: "   + str(latestWpilib()))
print("Latest Phoenix Version: "  + str(latestPhoenix()))
print("Latest NI Tools Version: " + str(latestNI()))
