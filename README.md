# FRC Installers

These scripts are installing essential packages to be able to develop code for [FRC](https://www.firstinspires.org/robotics/frc).

## Dependencies

You will need to install\
[bash](https://www.gnu.org/software/bash/) (Linux, Macos, Windows, etc.)\
[PowerShell](https://github.com/PowerShell/PowerShell) (Windows only, version >= 5.0)

## Installation Instructions

To install, you can either clone this repository and run the scripts directly or run the following commands.

### Windows 10 and 11

For the Windows Command Prompt, use the `Installer-windows.cmd` script.

```cmd
curl.exe --output install.cmd --url https://github.com/frc-862/installers/blob/main/Installer-windows.cmd && ./install.cmd && del ./install.cmd
```

Or the `installer-powershell.ps1` script for PowerShell.

```PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/frc-862/installers/main/Installer-powershell.ps1" -OutFile ".\install.ps1"; .\install.ps1; rm .\install.ps1
```

### Linux, Mac OS, etc

For systems with bash, use the `Installer-bash.sh` script.\
You may need to install `curl`. Follow [this guide](https://www.tecmint.com/install-curl-in-linux/).

```bash
bash <(curl https://raw.githubusercontent.com/frc-862/installers/main/Installer-bash.sh)
```

## Included Packages

Name | Use
--- | ---
[Visual Studio Code](https://code.visualstudio.com/) | An editor to develop code efficiently.
[git](https://git-scm.com/) | The version control system that we use to manage all of our code.
[openjdk11](https://openjdk.java.net/projects/jdk/11/) | The language we use to write our code.
[WPILib (extension)](https://wpilib.org/) | An extension for Visual Studio Code that makes working on WPILib projects easier.
[brew (Mac, Linux)](https://brew.sh/) | A package manager that makes installing software a lot easier.
[scoop (Windows)](https://scoop.sh/) | Another package manager that makes installing software a lot easier.
[gradle](https://gradle.org/) | An open-source build system for java we use to manage dependencies.

At the end of all the installations, the script clones the [lightning](https://github.com/frc-862/lightning) repository into `$HOME/Documents/lightning`

Finally, the script builds the lightning repository. If any errors occur feel free to make a JIRA ticket or put a note on discord, and someone will help you out.

If no errors occur, you have installed all the necessary applications/packages to build FRC code

*PLEASE NOTE:*\
Some of our robot projects depend on [lightning](https://github.com/frc-862/lightning), which is published on the GitHub Package Registry (we will just call this the "gpr"). Unfortunately, the gpr requires authentication to use public repositories (not sure why, or when this will change). There are instructions for how to set this up below.\
Additionally, you will need to setup an ssh key to contribute code to our repositories. You can also find instructions for setting this up below.

## Other Things You Should Set Up

### GPR Key Instructions

A GPR key is required to build any code besides the lightning repository.\
To begin, open settings after clicking on your profile picture.\
![gpr1.png](https://github.com/frc-862/862-installers/raw/main/assets/gpr1.png)\
Then, click on "Developer settings", near the end of the page.\
![gpr2.png](https://github.com/frc-862/862-installers/raw/main/assets/gpr2.png)\
Afterward, click on "Personal access tokens".\
![gpr3.png](https://github.com/frc-862/862-installers/raw/main/assets/gpr3.png)\
Next, click on "Generate new token" to create a token.\
![gpr4.png](https://github.com/frc-862/862-installers/raw/main/assets/gpr4.png)\
Name your token something memorable, or at least be able to identify the key.\
For the Expiration, you can set it to expire never, but as advised by GitHub, I would set it to 30-90 days and follow these instructions again when it expires. However, it is usually fine to set it to not expire.\
Finally, make sure to check the `write:packages` and `delete:packages` scopes (The repo scope will automagically be checked).\
![gpr5.png](https://github.com/frc-862/862-installers/raw/main/assets/gpr5.png)\
After clicking on "Generate token" at the end of the page, you will get prompted to copy the key for the token. Make sure the copy this and save it for the next steps.\
Assuming you ran one of the install scripts, you should have a `.gradle/` folder in your home directory, (`~` for Linux, Mac OSX, and Powershell).\
Navigate into the folder and open the file `gradle.properties` in your favorite text editor (it's ok if it's not there, just create a new file with the same name).\
Then, add these two lines into `gradle.properties`

```bash
gpr.user=USERNAME
gpr.key=KEY
```

Where `USERNAME` is your GitHub Username, and `KEY` is the key you got earlier.\
Save the file and you should be able to build other repositories now. As always, feel free to make a JIRA ticket if you have any issues.

### SSH Key Instructions

An SSH Key is required to contribute code.

Instructions to create an SSH key are located at the [GitHub Docs](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/about-ssh).  

Note: Make sure to clone repositories through SSH instead of HTTPS.\
The repository address will look something like `git@github.com:USER/REPO.git` (SSH) as opposed to `https://github.com/USER/REPO.git` (HTTPS).

## Driver Station (Windows Only)

There's a video on installing the Driver Station and other relevant tools [here](https://drive.google.com/file/d/161bp7iFEciRYEJMP1MONmpF_pKdheI-W/view).

The link to the NI Tool Suite installer can be found [here](https://www.ni.com/en-us/support/downloads/drivers/download.frc-game-tools.html#369633).

These tools are only built for Windows machines.
