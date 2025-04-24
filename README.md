# Virtualenv Auto Activate / Deactivate for PowerShell

## What is this?
  * Automatically activate and deactivate python virtualenv for PowerShell users.
    - When you enter into the python project's top folder with `venv` or `.env` folder, this script will automatically activate it.
    - When you go outside of the project folder, this will automatically deactivate it.

## Install
  * Place the `virtualenv-auto-activate.ps1` file anywhere you like.
  * Add below into the PowerShell's profile file (`$profile`).
    - Don't miss the first `.` and the white space.

```ps1
. "<ABSOLUTE_PATH_TO>\virtualenv-auto-activate.ps1"
```

  * Hint.
    - The `$profile` file may be in the path below, I think. (You can know it by just typing `$profile` in your PowerShell)
      + [PS 5] `C:\Users\<USER_NAME>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` 
      + [PS 7] `C:\Users\<USER_NAME>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`


## Uninstall
  * Delete `virtualenv-auto-activate.ps1` file, and remove the line you write into your `$profile`.


## Advanced
  * If you want to use some other name for the virtualenv folder other than `venv` or `.env`,
    change `$VENV_NAMES` definition in the `virtualenv-auto-activate.ps1` at line `3` (or thereabouts).
