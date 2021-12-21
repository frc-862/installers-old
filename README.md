# FRC Installers

These scripts can be used to install the essential software for [FRC](https://www.firstinspires.org/robotics/frc) code development.

# Table of Contents
- [What You Need](#What-You-Need)
    - [Unix Requirements](#Unix-Requirements)
    - [Windows Requirements](#Windows-Requirements)
- [Included Packages](#Included-Packages)
- [Windows Installation](#Windows-Installation)
- [Unix Installation](#Unix-Installation)
    - [WPILib Install Proccess](#WPILib-Install-Process)
- [GPR Key Instructions](#GPR-Key-Instructions)
- [SSH Key Instructions](#SSH-Key-Instructions)

# What You Need

## Unix Requirements

- Software:
    - [bash](https://www.gnu.org/software/bash/) (works in git bash also)
    - [curl]((https://www.tecmint.com/install-curl-in-linux/))
    - Administrator privileges
- Hardware:
    - Hey kyle could you fill out this plz thx

## Windows Requirements

- Software:
    - [PowerShell](https://github.com/PowerShell/PowerShell) (v2 or higher)
    - [.NET Framework](https://dotnet.microsoft.com/en-us/download/dotnet-framework) (version ≥ 4)
    - Administrator privileges
- Hardware
    - 10-30 minutes of free time (may vary based on internet speed)
    - Hey kyle could you fill out this plz thx

# Included Packages

## Unix

Name | Use
--- | ---
[git](https://git-scm.com/) | The version control system that we use to manage all of our code.
wget | for some reason we don't use curl? will fix this soon
tar | used to extract wpilib image
lazygit | ubuntu only, a nice cui tool for working with git

## Windows
Name | Use
--- | ---
[Visual Studio Code](https://code.visualstudio.com/) | An editor to develop code efficiently.
[git](https://git-scm.com/) | The version control system that we use to manage all of our code.
[openjdk11](https://openjdk.java.net/projects/jdk/11/) | The language we use to write our code.
[WPILib (extension)](https://wpilib.org/) | An extension for Visual Studio Code that makes working on WPILib projects easier.
[Java Extension Pack (extension)](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack) | Contains several extensions that make writing java code much easier.
[brew (Mac)](https://brew.sh/) | A package manager that makes installing software a lot easier.
[chocolatey (Windows)](https://chocolatey.org/) | Another package manager but for windows.
[gradle](https://gradle.org/) | An open-source build system for java we use to manage dependencies.
[lazygit](https://github.com/jesseduffield/lazygit) | A TUI that makes version control with git a whole lot easier.


At the end of all the installations, the script clones the [lightning](https://github.com/frc-862/lightning) repository into `~/Documents/lightning`

Finally, the script builds the lightning repository. If any errors occur feel free to make a JIRA ticket or put a note on discord, and someone will help you out.

# Windows Installation
 
Start by opening powershell as an administrator.  
Then, run
```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
```
and then
```PowerShell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/frc-862/installers/main/powershellInstaller.ps1" -OutFile ".\install.ps1"; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/frc-862/installers/main/bashInstaller.sh" -OutFile ".\bashInstaller.sh"; .\install.ps1; rm .\install.ps1; rm .\bashInstaller.sh
```
The powershell installer has a built-in macro that automatically clicks through the WPILib, NI, phoenix, and radio configuration installers, so you should leave the computer alone while running the script.

The only time you may need to click is during the phoenix install, where you will need to press the `install` button on a pop up.

## Unix Installation

For systems with bash, use the `bashInstaller.sh` script.  

```bash
bash <(curl https://raw.githubusercontent.com/frc-862/installers/main/bashInstaller.sh)
```

### WPILib Install Proccess
After the installer downloads the WPILib installer, (this can take several minutes on slower connections) a new window will launch that will look something like this:  
![wpilib1.png](https://github.com/frc-862/installers/raw/main/assets/wpilib1.png)

Press start, and you will see the vscode install screen:  
![wpilib2.png](https://github.com/frc-862/installers/raw/main/assets/wpilib2.png)

*If you already have vs code, you can press skip and move past the installation instructions.*

*If you already have vs code downloaded for installation, you can select the "Use downloaded installer" option.*

Otherwise, press "download vs code for single install."  
Press continue once the loading bar has finished.

On the next screen, select the following options:  
![wpilib3.png](https://github.com/frc-862/installers/raw/main/assets/wpilib3.png)

Press "Install for single user" to install.

If nothing goes wrong, you should see a screen like this:  
![wpilib4.png](https://github.com/frc-862/installers/raw/main/assets/wpilib4.png)

Press Finish, and the installer script will continue.

# GPR Key Instructions
Some of our robot projects depend on [lightning](https://github.com/frc-862/lightning), which is published on the GitHub Package Registry (we will just call this the "gpr"). Unfortunately, the gpr requires authentication to use public repositories (not sure why, or when this will change). There are instructions for how to set this up below.

To begin, open settings after clicking on your profile picture.  
![gpr1.png](https://github.com/frc-862/installers/raw/main/assets/gpr1.png)  
Then, click on "Developer settings", near the end of the page.  
![gpr2.png](https://github.com/frc-862/installers/raw/main/assets/gpr2.png)  
Afterward, click on "Personal access tokens".  
![gpr3.png](https://github.com/frc-862/installers/raw/main/assets/gpr3.png)  
Next, click on "Generate new token" to create a token.  
![gpr4.png](https://github.com/frc-862/installers/raw/main/assets/gpr4.png)  
Name your token something memorable, or at least be able to identify the key.  
For the Expiration, you can set it to expire never, but as advised by GitHub, I would set it to 30-90 days and follow these instructions again when it expires. However, it is usually fine to set it to not expire.  
Finally, make sure to check the `write:packages` and `delete:packages` scopes (The repo scope will automagically be checked).  
![gpr5.png](https://github.com/frc-862/installers/raw/main/assets/gpr5.png)  
After clicking on "Generate token" at the end of the page, you will get prompted to copy the key for the token. Make sure the copy this and save it for the next steps.  
Assuming you ran one of the install scripts, you should have a `.gradle/` folder in your home directory, (`~` for Linux, Mac OSX, and Powershell).  
Navigate into the folder and open the file `gradle.properties` in your favorite text editor (it's ok if it's not there, just create a new file with the same name).  
Then, add these two lines into `gradle.properties`

```properties
gpr.user=USERNAME
gpr.key=KEY
```

Where `USERNAME` is your GitHub Username, and `KEY` is the key you got earlier.  
Save the file and you should be able to build other repositories now. As always, feel free to make a JIRA ticket if you have any issues.

# SSH Key Instructions

An SSH Key is required to contribute code.

Instructions to create an SSH key are located at the [GitHub Docs](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/about-ssh).  

Note: Make sure to clone repositories through SSH instead of HTTPS.  
The repository address will look something like `git@github.com:USER/REPO.git` (SSH) as opposed to `https://github.com/USER/REPO.git` (HTTPS).
