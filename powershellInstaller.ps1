function ok { Write-Host "OK: $args" -ForegroundColor Green }
function warn { Write-Host "WARNING: $args" -ForegroundColor Yellow }
function showError { Write-Host "ERROR: $args" -ForegroundColor Red } #use showError instead of error to avoid issues when overriding built-in cmdlets
function has { Get-Command "$args" -ErrorAction SilentlyContinue }

# Run checks to make sure the installer can install
#requires -version 4.0
#requires -RunAsAdministrator

#Check for enough disk space
$freespace = (Get-CimInstance CIM_LogicalDisk -Filter "DeviceId='C:'").FreeSpace #TODO: check whatever drive the programs are installed to, not just C:/
if (($freespace -lt 15gb)) {
    #TODO: this disk space number is made up, need to make it more accurate
    #TODO: make user able to override this error
    showError "You do not have enough disk space ('C:\') for this install! You need at least 15 gigabytes to run this installer."
    exit
}
ok "All checks have passed"

# Pre-install warning/starting
ok "Starting install (check back here in about 10 minutes)..."
warn "Please try not to touch the mouse while the installer is running. (a macro is setup to do everything for you)"

#Install Chocolatey
if (-not has "choco") {
    ok "Installing Chocolatey..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

#Install git in order to use git bash
if (-not has "git") {
    ok "Installing git..."
    choco install -y git
    refreshenv
}

#Run the bash script through git bash
& "$Env:Programfiles\git\bin\bash.exe" "./bashInstaller.sh" $args

#Run build in powershell to avoid some weirdness with gradle's loading bar
$env:JAVA_HOME = "C:\Program Files\OpenJDK\openjdk-11.0.13_8"
& "$HOME/Documents/lightning/gradlew.bat" "build"
