#Requires -Version 5.1

$VENV_NAMES = @("venv", ".env") # priority order

function Activate-VirtualEnv {
    # If activate.ps1 is called in this time, set its VENV_NAME. This value is used for change prompt instantly.
    $calledVenv = $null

    # find virtualenv directory
    $EnvDir = $null
    foreach ($venvName in $script:VENV_NAMES) {
        if (Test-Path -Path $venvName -PathType Container) {
            $EnvDir = $venvName
            break
        }
    }

    if ($null -eq $EnvDir) {
        return $calledVenv
    }

    # if virtualenv directory is found, ensure it is activated and the venv path is set to VENV_TLD variable
    try {
        $envFullPath = (Resolve-Path -Path $EnvDir).Path
        $activateScriptPath = Join-Path -Path $envFullPath -ChildPath "Scripts\Activate.ps1"
        if (-not (Test-Path -Path $activateScriptPath -PathType Leaf)) {
            return $calledVenv
        }

        # if the target virtualenv is not activated, activate
        $currentVenvPath = $env:VIRTUAL_ENV
        if ($null -eq $currentVenvPath -or $currentVenvPath -ne $envFullPath) {
            Write-Host "Auto-activated virtualenv." -ForegroundColor Yellow
            . $activateScriptPath
            $calledVenv = $EnvDir
        } 
        
        # ensure the venv path is set to VENV_TLD variable
        $script:VENV_TLD = (Get-Location).Path # Save top level directory (for deactivation)
    } catch {
        Write-Warning "Error during virtualenv activation for '$foundEnvDir': $($_.Exception.Message)"
        return $calledVenv
    }

    return $calledVenv
}


function Deactivate-VirtualEnv {
    if (($null -ne $script:VENV_TLD) -and ($null -ne $env:VIRTUAL_ENV)) {
        # check if the current path is outside the venv path
        $currentPath = (Get-Location).Path
        if ($currentPath.StartsWith($script:VENV_TLD)) {
            return
        }

        # if deactivate command exists, deactivate
        try {
            if (Get-Command deactivate -ErrorAction SilentlyContinue) {
                deactivate
                Write-Host "Auto-deactivated virtualenv." -ForegroundColor Yellow
                Remove-Variable -Name VENV_TLD -Scope Script -Force -ErrorAction SilentlyContinue
            } else {
                # if deactivate command does not exist, clear VENV_TLD variable
                Write-Warning "'deactivate' command not found. Cannot deactivate automatically."
                Remove-Variable -Name VENV_TLD -Scope Script -Force -ErrorAction SilentlyContinue
            }
        } catch {
            Write-Warning "Error during virtualenv deactivation: $($_.Exception.Message)"
            Remove-Variable -Name VENV_TLD -Scope Script -Force -ErrorAction SilentlyContinue
        }

    } elseif ($null -eq $env:VIRTUAL_ENV -and $null -ne $script:VENV_TLD) {
        # if VIRTUAL_ENV is not set but VENV_TLD exists, clear VENV_TLD variable. (e.g. When deactivate by hand)
        Write-Verbose "VIRTUAL_ENV not set, but VENV_TLD exists. Cleaning up VENV_TLD."
        Remove-Variable -Name VENV_TLD -Scope Script -Force -ErrorAction SilentlyContinue
    }
}


# save original prompt function as __prompt_original
if (Test-Path Function:\prompt) {
    # Rename original prompt function
    Rename-Item Function:\prompt __prompt_org -Force -ErrorAction SilentlyContinue
} elseif (Test-Path Function:\__prompt_org) {
    # Do nothing (already renamed)
} else {
    # Define default prompt function
    function __prompt_org { "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) " }
}


# custom prompt function
function prompt {
    $calledVenv = $null

    if ($null -ne $env:VIRTUAL_ENV) {
        Deactivate-VirtualEnv # deactivate virtualenv if necessary
    }

    $calledVenv = Activate-VirtualEnv # activate virtualenv if necessary

    # call original prompt function
    $promptString = Invoke-Command -ScriptBlock $Function:__prompt_org
    
    # if Activate.ps1 is called this time, create prompt string for aplly instantly.
    if ($null -ne $calledVenv) {
        $green = "`e[32m"
        $reset = "`e[0m"
        $promptString = "$green($calledVenv)$reset $promptString"
    }

    return $promptString
}
