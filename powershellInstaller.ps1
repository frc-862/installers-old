#Install Chocolatey
Write-Host "Installing Chocolatey..." -ForegroundColor Green

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install git in order to use git bash
Write-Host "Installing git..." -ForegroundColor Green
choco install -y git
refreshenv

& "$Env:Programfiles\git\git-bash.exe" --login -i -c "./bashInstaller.sh"
