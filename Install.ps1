
Param (
    [string]$list,
    [Switch]$all,
    [Switch]$noop,
    [string]$scripts,
    [Switch]$windows
)


try {
    choco config get cacheLocation -r
}
catch {
    Write-Output "Chocolatey not detected, trying to install now"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$noopCmd = ""
$helperUri = "https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Scripts"

function ExecuteRemoteScript {
    <#
    .SYNOPSIS
    Downloads an runs a remote script from the pre specified URL.
    #>
    param(
        # Name of the script to run.
        [string]$script
    )

    Write-Host "Executing $helperUri/$script ..."
    $content = (New-Object net.WebClient).DownloadString("$helperUri/$script")
    # $content = Get-Content -Path .\$script
    $content = $content -split "\n" | foreach { "$($_.Trim())" }
    foreach ($line in $content) {
        # Skip comments and empty lines
        if (($line.StartsWith("#") -eq $false) -and ([string]::IsNullOrWhiteSpace($line) -eq $false)) {
            Invoke-Expression "$line $noopCmd" 
        }
    }
}


function InstallFromList {
    <#
    .SYNOPSIS
    Installs chocolatey packages from a comma seperated list provided as the argument.
    .Description
    The list must contain valid chocolatey package names.
    A package can optionally be preceeded with "pin" to pin said package after installing.
    #>
    Param(  
        [string]$chocolateyAppList
    )

    if ([string]::IsNullOrWhiteSpace($chocolateyAppList) -eq $false) {   
        Write-Host "Chocolatey Apps Specified"  
    
        $appsToInstall = $chocolateyAppList -split "," | foreach { "$($_.Trim())" }

        $prev = ""

        foreach ($app in $appsToInstall) {
            # Install app
            if (([string]::IsNullOrWhiteSpace($app) -eq $false) -and ($app -ne "pin") ) {
                Write-Host "Installing $app"
                & choco install $app /y $noopCmd
                $prev = $app
            }

            #  Pin previous installed app
            if (([string]::IsNullOrWhiteSpace($prev) -eq $false) -and ($app -eq "pin")) {
                Write-Host "Pinning $prev"
                & choco pin add --name=$prev $noopCmd
            }
        }
    }
}


if ($noop) { $noopCmd = "-r --noop" }

if ($all) {
    ExecuteRemoteScript "Basic.ps1";
    ExecuteRemoteScript "Gaming.ps1";
    ExecuteRemoteScript "Programming.ps1";
    ExecuteRemoteScript "Utils.ps1";
    ExecuteRemoteScript "nnp.ps1";
    return
}

if ($windows) {
    Write-Output "Setting up Windows settings ..."
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$helperUri/WindowsSettings.ps1"))
}

if ($list) {
    InstallFromList "$list"
}

if ($scripts) {
    ExecuteRemoteScript $scripts
}