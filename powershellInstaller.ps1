#a couple of requirments to make sure nothing dies
#requires -version 4.0
#requires -RunAsAdministrator

function ok { Write-Host "OK: $args" -ForegroundColor Green }
function warn { Write-Host "WARNING: $args" -ForegroundColor Yellow }
function showError { Write-Host "ERROR: $args" -ForegroundColor Red } #use showError instead of error to avoid issues when overriding built-in cmdlets
function has { Get-Command "$args" -ErrorAction SilentlyContinue }

function installGit {
    ok "Installing Git..."
    $gitUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
    $asset = Invoke-RestMethod -Method Get -Uri $gitUrl | ForEach-Object assets | Where-Object name -like "*64-bit.exe"
    # download installer
    $installer = "$env:temp\$($asset.name)"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer
    # run installer
    $git_install_inf = "./gitInstall.inf"
    $install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
    Start-Process -FilePath $installer -ArgumentList $install_args -Wait
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

#imstall git if not already installed
if (!(has git)) {
    installGit
}

#Run the bash script through git bash
if ($args.Count -eq 0) {
    Start-Process -FilePath "$Env:Programfiles\git\bin\bash.exe" -NoNewWindow -Wait -ArgumentList "./bashInstaller.sh"
} else {
    Start-Process -FilePath "$Env:Programfiles\git\bin\bash.exe" -NoNewWindow -Wait -ArgumentList "./bashInstaller.sh",($args | Out-String)
}

if (-Not($args.Contains("--headless"))) { #don't run build in headless mode because it will just hang
    #Run build in powershell to avoid some weirdness with gradle's loading bar
    Start-Process -FilePath "$HOME\Documents\lightning\gradlew.bat" -NoNewWindow -Wait -ArgumentList "-p","$HOME/Documents/lightning","build"
}
