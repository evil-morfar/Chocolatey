# Installation

In an elevated powershell simply run:

```ps
iex "& { $(irm https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Install.ps1) } -all -windows"
```

To install everything.
The script will install chocolatey if it's missing, and otherwise install packages based on the given commands.

## Commands

* -noop - Passes the `--noop` argument to all chocolatey scripts.
* -all - Installs all packages from all scripts in `/Scripts` - except WindowsSettings.
* -windows - Runs the `WindowsSettings.ps1` script.
* -scripts "script.ps1" - Runs the specified script(s) from `/Scripts`. Multiple script can be done at once by comma seperating them. The `.ps1` extension is added automatically if needed.
* -list "list" - Takes a comma seperated list of chocolatey packages and installs those. If an entry is `pin` then the package before it is pinned in chocolatey.


## Examples

### Test results

Runs all scripts with `--noop` added to the chocolatey command, which downloads and shows what will happen without actually installing anything. If run with `-windows` flag, then the windows script won't be executed.

```ps
iex "& { $(irm https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Install.ps1) } -all -noop"
```


### Gaming package

```ps
iex "& { $(irm https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Install.ps1) } -scripts 'Gaming.ps1'"
```

### Windows, Basic, and Utils package

```ps
iex "& { $(irm https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Install.ps1) } -scripts 'Utils, Basic' -windows"
```

### Custom list

See examples in `Lists.txt`.

```ps
iex "& { $(irm https://raw.githubusercontent.com/evil-morfar/Chocolatey/master/Install.ps1) } -list 'googlechrome, pin, kodi, firefox, pin'"
```

*Google Chrome and Firefox will be pinned (i.e. not updated by chocolatey).*
