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

#Clone the installers repository
#Start-Process "git" -NoNewWindow -Wait -ArgumentList "clone","https://github.com/frc-862/installers.git","$HOME/Documents/installers"
#& "git" "clone" "https://github.com/frc-862/installers.git" "$HOME/Documents/installers"

#Run the bash script through git bash
Start-Process -FilePath "$Env:Programfiles\git\bin\bash.exe" -NoNewWindow -Wait -ArgumentList "./bashInstaller.sh",($args | Out-String)
#& "$Env:Programfiles\git\bin\bash.exe" "$HOME/Documents/installers/bashInstaller.sh" $args

#Run build in powershell to avoid some weirdness with gradle's loading bar
Start-Process -FilePath "$HOME\Documents\lightning\gradlew.bat" -NoNewWindow -Wait -ArgumentList "-p","$HOME/Documents/lightning","build"
#& "$HOME\Documents\lightning\gradlew.bat" "-p" "$HOME/Documents/lightning" "build"
