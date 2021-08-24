# 862-installers
These scripts are installing essential packages to be able to develop code for [WPILib](https://wpilib.org/).

# Dependencies
The only dependency you need to install is [git](https://git-scm.com/).

You also need to setup a gpr key, (Instructions WIP)

# How to install

For all of these we need to first clone this repository and run the scripts from there.  
First, open the terminal (Powershell for Windows) and type `git clone https://github.com/Fr1tzBot/862-installers.git`.  
Then, navigate into the directory by typing `cd 862-installers/`.  

```bash
git clone https://github.com/Fr1tzBot/862-installers.git
cd 862-installers/
```
From here, follow the instructions for your specific type of operating system. If it's not there feel free to open an issue.

## Windows 10 and 11
For Windows we want to use the `862Installer-windows.ps1` script.  

We need to first be able to run powershell scripts by running `Set-ExecutionPolicy RemoteSigned -scope CurrentUser`
Then simply run the script with `.\862installer-windows.ps1`.   

```ps1
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
.\862installer-windows.ps1
```

## Debian-based (Ubuntu, Pop_OS!, etc.)
For Debian-based operating systems, we want to use the `862Installer-debian.sh` script.  

We need to first make the script executable by running `chmod +x 862Installer-debian.sh`.  
Then we can run the script by running `./862Installer-debian.sh`

```bash
chmod +x 862Installer-debian.sh
./862Installer-debian.sh
```

## Arch-based (Archcraft, Manjaro, etc.)
For Arch-based operating systems, it's the same as Debian-based except for the script we are running.  

```bash
chmod +x 862Installer-arch.sh
./862Installer-arch.sh
```

## Mac OS
Macs are also very similar to Debian-based operating systems as well.

```bash
chmod +x 862Installer-mac.sh
./862Installer-mac.sh
```

# Info

Name | Repository/Link | Use 
--- | --- | ---
Visual Studio Code | [link](https://code.visualstudio.com/) | An IDE to develop code efficiently for WPILib.
git | [link](https://git-scm.com/) | A version control tool to make code development a lot easier.
openjdk11 | [link](https://openjdk.java.net/projects/jdk/11/) | The Java development kit is required to develop code in Java.
WPILib (extension) | [link](https://wpilib.org/) | It's required to deploy code onto robots.
brew (Mac only) | [link](https://brew.sh/) | It's a package manager that makes installing certain packages a lot easier.
scoop (Windows only) | [link](https://scoop.sh/) | It's a package manager to install certain packages much easier.

At the end of all the installations, the script clones the [lightning](https://github.com/frc-862/lightning) repository into `C:\Users\<username>\Documents\lightning` (Windows) or `/home/<username>/Documents/lightning` (Linux).

Finally, the script builds the lightning repository, and if any errors occur feel free to leave an issue.

If no errors occur, you have installed all the necessary applications/packages to develop code for FRC WPILib