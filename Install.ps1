
Param (
    [string]$list,
    [Switch]$all,
    [Switch]$noop,
    [string]$scripts,
    [Switch]$windows
)


Write-Output "Running Install script..."

try {
    choco config get cacheLocation -r
}
catch {
    Write-Output "Chocolatey not detected, trying to install now"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$noopCmd = ""
$helperUri = "https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Scripts"


function GetArrayFromCSVString {
    param (
        [string]$csvString
    )
    if ([string]::IsNullOrWhiteSpace($csvString) -eq $false) {  
        return $csvString -split "," | foreach { "$($_.Trim())" }
    }
}

function ExecuteRemoteScript {
    <#
    .SYNOPSIS
    Downloads an runs a remote script from the pre specified URL.
    #>
    param(
        # Name of the script to run.
        [string]$scripts
    )

    foreach ($script in GetArrayFromCSVString "$scripts") {
        if ($script.EndsWith(".ps1") -eq $false) {
            $script = $script + ".ps1"
        }

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
        Write-Output "Done with $script"
        Write-Output "---------------------------------------------`n"
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
    
        $appsToInstall = GetArrayFromCSVString "$chocolateyAppList"

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


if ($noop) { $noopCmd = "--noop" }

if ($windows) {
    if ($noop -eq $false) {
        Write-Output "Setting up Windows settings ..."
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("$helperUri/WindowsSettings.ps1"))
    } else {
        Write-Output "Skipping Windows Settings (-noop)`n"
    }
}

if ($all) {
    ExecuteRemoteScript "Basic, Gaming, Programming, Utils, nnp";
    return
}

if ($list) {
    InstallFromList "$list"
}

if ($scripts) {
    ExecuteRemoteScript "$scripts"
}