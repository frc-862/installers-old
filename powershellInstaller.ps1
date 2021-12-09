#Install Chocolatey
Write-Host "Installing Chocolatey..." -ForegroundColor Green
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install git in order to use git bash
Write-Host "Installing git..." -ForegroundColor Green
choco install -y git
refreshenv

& sh --login -i -c "./bashInstaller.sh"
