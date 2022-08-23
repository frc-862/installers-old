function ok { Write-Host "OK: $args" -ForegroundColor Green }
function warn { Write-Host "WARNING: $args" -ForegroundColor Yellow }
function showError { Write-Host "ERROR: $args" -ForegroundColor Red } #use showError instead of error to avoid issues when overriding built-in cmdlets
function has { Get-Command "$args" -ErrorAction SilentlyContinue }

# Run checks to make sure the installer can install
#requires -version 4.0
#requires -RunAsAdministrator

#TODO: install git here

#Run the bash script through git bash
Start-Process -FilePath "$Env:Programfiles\git\bin\bash.exe" -NoNewWindow -Wait -ArgumentList "./bashInstaller.sh",($args | Out-String)

if (-Not($args.Contains("--headless"))) { #don't run build in headless mode because it will just hang
    #Run build in powershell to avoid some weirdness with gradle's loading bar
    Start-Process -FilePath "$HOME\Documents\lightning\gradlew.bat" -NoNewWindow -Wait -ArgumentList "-p","$HOME/Documents/lightning","build"
}