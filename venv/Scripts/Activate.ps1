<#
.Synopsis
Activate a Python virtual environment for the current PowerShell session.

.Description
Pushes the python executable for a virtual environment to the front of the
$Env:PATH environment variable and sets the prompt to signify that you are
in a Python virtual environment. Makes use of the command line switches as
well as the `pyvenv.cfg` file values present in the virtual environment.

.Parameter VenvDir
Path to the directory that contains the virtual environment to activate. The
default value for this is the parent of the directory that the Activate.ps1
script is located within.

.Parameter Prompt
The prompt prefix to display when this virtual environment is activated. By
default, this prompt is the name of the virtual environment folder (VenvDir)
surrounded by parentheses and followed by a single space (ie. '(.venv) ').

.Example
Activate.ps1
Activates the Python virtual environment that contains the Activate.ps1 script.

.Example
Activate.ps1 -Verbose
Activates the Python virtual environment that contains the Activate.ps1 script,
and shows extra information about the activation as it executes.

.Example
Activate.ps1 -VenvDir C:\Users\MyUser\Common\.venv
Activates the Python virtual environment located in the specified location.

.Example
Activate.ps1 -Prompt "MyPython"
Activates the Python virtual environment that contains the Activate.ps1 script,
and prefixes the current prompt with the specified string (surrounded in
parentheses) while the virtual environment is active.

.Notes
On Windows, it may be required to enable this Activate.ps1 script by setting the
execution policy for the user. You can do this by issuing the following PowerShell
command:

PS C:\> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

For more information on Execution Policies: 
https://go.microsoft.com/fwlink/?LinkID=135170

#>
Param(
    [Parameter(Mandatory = $false)]
    [String]
    $VenvDir,
    [Parameter(Mandatory = $false)]
    [String]
    $Prompt
)

<# Function declarations --------------------------------------------------- #>

<#
.Synopsis
Remove all shell session elements added by the Activate script, including the
addition of the virtual environment's Python executable from the beginning of
the PATH variable.

.Parameter NonDestructive
If present, do not remove this function from the global namespace for the
session.

#>
function global:deactivate ([switch]$NonDestructive) {
    # Revert to original values

    # The prior prompt:
    if (Test-Path -Path Function:_OLD_VIRTUAL_PROMPT) {
        Copy-Item -Path Function:_OLD_VIRTUAL_PROMPT -Destination Function:prompt
        Remove-Item -Path Function:_OLD_VIRTUAL_PROMPT
    }

    # The prior PYTHONHOME:
    if (Test-Path -Path Env:_OLD_VIRTUAL_PYTHONHOME) {
        Copy-Item -Path Env:_OLD_VIRTUAL_PYTHONHOME -Destination Env:PYTHONHOME
        Remove-Item -Path Env:_OLD_VIRTUAL_PYTHONHOME
    }

    # The prior PATH:
    if (Test-Path -Path Env:_OLD_VIRTUAL_PATH) {
        Copy-Item -Path Env:_OLD_VIRTUAL_PATH -Destination Env:PATH
        Remove-Item -Path Env:_OLD_VIRTUAL_PATH
    }

    # Just remove the VIRTUAL_ENV altogether:
    if (Test-Path -Path Env:VIRTUAL_ENV) {
        Remove-Item -Path env:VIRTUAL_ENV
    }

    # Just remove VIRTUAL_ENV_PROMPT altogether.
    if (Test-Path -Path Env:VIRTUAL_ENV_PROMPT) {
        Remove-Item -Path env:VIRTUAL_ENV_PROMPT
    }

    # Just remove the _PYTHON_VENV_PROMPT_PREFIX altogether:
    if (Get-Variable -Name "_PYTHON_VENV_PROMPT_PREFIX" -ErrorAction SilentlyContinue) {
        Remove-Variable -Name _PYTHON_VENV_PROMPT_PREFIX -Scope Global -Force
    }

    # Leave deactivate function in the global namespace if requested:
    if (-not $NonDestructive) {
        Remove-Item -Path function:deactivate
    }
}

<#
.Description
Get-PyVenvConfig parses the values from the pyvenv.cfg file located in the
given folder, and returns them in a map.

For each line in the pyvenv.cfg file, if that line can be parsed into exactly
two strings separated by `=` (with any amount of whitespace surrounding the =)
then it is considered a `key = value` line. The left hand string is the key,
the right hand is the value.

If the value starts with a `'` or a `"` then the first and last character is
stripped from the value before being captured.

.Parameter ConfigDir
Path to the directory that contains the `pyvenv.cfg` file.
#>
function Get-PyVenvConfig(
    [String]
    $ConfigDir
) {
    Write-Verbose "Given ConfigDir=$ConfigDir, obtain values in pyvenv.cfg"

    # Ensure the file exists, and issue a warning if it doesn't (but still allow the function to continue).
    $pyvenvConfigPath = Join-Path -Resolve -Path $ConfigDir -ChildPath 'pyvenv.cfg' -ErrorAction Continue

    # An empty map will be returned if no config file is found.
    $pyvenvConfig = @{ }

    if ($pyvenvConfigPath) {

        Write-Verbose "File exists, parse `key = value` lines"
        $pyvenvConfigContent = Get-Content -Path $pyvenvConfigPath

        $pyvenvConfigContent | ForEach-Object {
            $keyval = $PSItem -split "\s*=\s*", 2
            if ($keyval[0] -and $keyval[1]) {
                $val = $keyval[1]

                # Remove extraneous quotations around a string value.
                if ("'""".Contains($val.Substring(0, 1))) {
                    $val = $val.Substring(1, $val.Length - 2)
                }

                $pyvenvConfig[$keyval[0]] = $val
                Write-Verbose "Adding Key: '$($keyval[0])'='$val'"
            }
        }
    }
    return $pyvenvConfig
}


<# Begin Activate script --------------------------------------------------- #>

# Determine the containing directory of this script
$VenvExecPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$VenvExecDir = Get-Item -Path $VenvExecPath

Write-Verbose "Activation script is located in path: '$VenvExecPath'"
Write-Verbose "VenvExecDir Fullname: '$($VenvExecDir.FullName)"
Write-Verbose "VenvExecDir Name: '$($VenvExecDir.Name)"

# Set values required in priority: CmdLine, ConfigFile, Default
# First, get the location of the virtual environment, it might not be
# VenvExecDir if specified on the command line.
if ($VenvDir) {
    Write-Verbose "VenvDir given as parameter, using '$VenvDir' to determine values"
}
else {
    Write-Verbose "VenvDir not given as a parameter, using parent directory name as VenvDir."
    $VenvDir = $VenvExecDir.Parent.FullName.TrimEnd("\\/")
    Write-Verbose "VenvDir=$VenvDir"
}

# Next, read the `pyvenv.cfg` file to determine any required value such
# as `prompt`.
$pyvenvCfg = Get-PyVenvConfig -ConfigDir $VenvDir

# Next, set the prompt from the command line, or the config file, or
# just use the name of the virtual environment folder.
if ($Prompt) {
    Write-Verbose "Prompt specified as argument, using '$Prompt'"
}
else {
    Write-Verbose "Prompt not specified as argument to script, checking pyvenv.cfg value"
    if ($pyvenvCfg -and $pyvenvCfg['prompt']) {
        Write-Verbose "  Setting based on value in pyvenv.cfg='$($pyvenvCfg['prompt'])'"
        $Prompt = $pyvenvCfg['prompt'];
    }
    else {
        Write-Verbose "  Setting prompt based on parent's directory's name. (Is the directory name passed to venv module when creating the virtual environment)"
        Write-Verbose "  Got leaf-name of $VenvDir='$(Split-Path -Path $venvDir -Leaf)'"
        $Prompt = Split-Path -Path $venvDir -Leaf
    }
}

Write-Verbose "Prompt = '$Prompt'"
Write-Verbose "VenvDir='$VenvDir'"

# Deactivate any currently active virtual environment, but leave the
# deactivate function in place.
deactivate -nondestructive

# Now set the environment variable VIRTUAL_ENV, used by many tools to determine
# that there is an activated venv.
$env:VIRTUAL_ENV = $VenvDir

$env:VIRTUAL_ENV_PROMPT = $Prompt

if (-not $Env:VIRTUAL_ENV_DISABLE_PROMPT) {

    Write-Verbose "Setting prompt to '$Prompt'"

    # Set the prompt to include the env name
    # Make sure _OLD_VIRTUAL_PROMPT is global
    function global:_OLD_VIRTUAL_PROMPT { "" }
    Copy-Item -Path function:prompt -Destination function:_OLD_VIRTUAL_PROMPT
    New-Variable -Name _PYTHON_VENV_PROMPT_PREFIX -Description "Python virtual environment prompt prefix" -Scope Global -Option ReadOnly -Visibility Public -Value $Prompt

    function global:prompt {
        Write-Host -NoNewline -ForegroundColor Green "($_PYTHON_VENV_PROMPT_PREFIX) "
        _OLD_VIRTUAL_PROMPT
    }
}

# Clear PYTHONHOME
if (Test-Path -Path Env:PYTHONHOME) {
    Copy-Item -Path Env:PYTHONHOME -Destination Env:_OLD_VIRTUAL_PYTHONHOME
    Remove-Item -Path Env:PYTHONHOME
}

# Add the venv to the PATH
Copy-Item -Path Env:PATH -Destination Env:_OLD_VIRTUAL_PATH
$Env:PATH = "$VenvExecDir$([System.IO.Path]::PathSeparator)$Env:PATH"

# SIG # Begin signature block
# MII+EgYJKoZIhvcNAQcCoII+AzCCPf8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBALKwKRFIhr2RY
# IW/WJLd9pc8a9sj/IoThKU92fTfKsKCCItQwggXMMIIDtKADAgECAhBUmNLR1FsZ
# lUgTecgRwIeZMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVu
# dGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAy
# MDAeFw0yMDA0MTYxODM2MTZaFw00NTA0MTYxODQ0NDBaMHcxCzAJBgNVBAYTAlVT
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jv
# c29mdCBJZGVudGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
# b3JpdHkgMjAyMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALORKgeD
# Bmf9np3gx8C3pOZCBH8Ppttf+9Va10Wg+3cL8IDzpm1aTXlT2KCGhFdFIMeiVPvH
# or+Kx24186IVxC9O40qFlkkN/76Z2BT2vCcH7kKbK/ULkgbk/WkTZaiRcvKYhOuD
# PQ7k13ESSCHLDe32R0m3m/nJxxe2hE//uKya13NnSYXjhr03QNAlhtTetcJtYmrV
# qXi8LW9J+eVsFBT9FMfTZRY33stuvF4pjf1imxUs1gXmuYkyM6Nix9fWUmcIxC70
# ViueC4fM7Ke0pqrrBc0ZV6U6CwQnHJFnni1iLS8evtrAIMsEGcoz+4m+mOJyoHI1
# vnnhnINv5G0Xb5DzPQCGdTiO0OBJmrvb0/gwytVXiGhNctO/bX9x2P29Da6SZEi3
# W295JrXNm5UhhNHvDzI9e1eM80UHTHzgXhgONXaLbZ7LNnSrBfjgc10yVpRnlyUK
# xjU9lJfnwUSLgP3B+PR0GeUw9gb7IVc+BhyLaxWGJ0l7gpPKWeh1R+g/OPTHU3mg
# trTiXFHvvV84wRPmeAyVWi7FQFkozA8kwOy6CXcjmTimthzax7ogttc32H83rwjj
# O3HbbnMbfZlysOSGM1l0tRYAe1BtxoYT2v3EOYI9JACaYNq6lMAFUSw0rFCZE4e7
# swWAsk0wAly4JoNdtGNz764jlU9gKL431VulAgMBAAGjVDBSMA4GA1UdDwEB/wQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTIftJqhSobyhmYBAcnz1AQ
# T2ioojAQBgkrBgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEAr2rd5hnn
# LZRDGU7L6VCVZKUDkQKL4jaAOxWiUsIWGbZqWl10QzD0m/9gdAmxIR6QFm3FJI9c
# Zohj9E/MffISTEAQiwGf2qnIrvKVG8+dBetJPnSgaFvlVixlHIJ+U9pW2UYXeZJF
# xBA2CFIpF8svpvJ+1Gkkih6PsHMNzBxKq7Kq7aeRYwFkIqgyuH4yKLNncy2RtNwx
# AQv3Rwqm8ddK7VZgxCwIo3tAsLx0J1KH1r6I3TeKiW5niB31yV2g/rarOoDXGpc8
# FzYiQR6sTdWD5jw4vU8w6VSp07YEwzJ2YbuwGMUrGLPAgNW3lbBeUU0i/OxYqujY
# lLSlLu2S3ucYfCFX3VVj979tzR/SpncocMfiWzpbCNJbTsgAlrPhgzavhgplXHT2
# 6ux6anSg8Evu75SjrFDyh+3XOjCDyft9V77l4/hByuVkrrOj7FjshZrM77nq81YY
# uVxzmq/FdxeDWds3GhhyVKVB0rYjdaNDmuV3fJZ5t0GNv+zcgKCf0Xd1WF81E+Al
# GmcLfc4l+gcK5GEh2NQc5QfGNpn0ltDGFf5Ozdeui53bFv0ExpK91IjmqaOqu/dk
# ODtfzAzQNb50GQOmxapMomE2gj4d8yu8l13bS3g7LfU772Aj6PXsCyM2la+YZr9T
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggb+MIIE5qADAgECAhMzAADcG6+V
# xTB/HBRIAAAAANwbMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBFT0MgQ0EgMDEwHhcNMjQxMDE1MTQwOTU2WhcNMjQxMDE4
# MTQwOTU2WjB8MQswCQYDVQQGEwJVUzEPMA0GA1UECBMGT3JlZ29uMRIwEAYDVQQH
# EwlCZWF2ZXJ0b24xIzAhBgNVBAoTGlB5dGhvbiBTb2Z0d2FyZSBGb3VuZGF0aW9u
# MSMwIQYDVQQDExpQeXRob24gU29mdHdhcmUgRm91bmRhdGlvbjCCAaIwDQYJKoZI
# hvcNAQEBBQADggGPADCCAYoCggGBAJ+HNfocUXcsZiIJUfVWdNajHUhsic4PJhHk
# rDtSGddvddjj/AStI7BVvLlw1Nf/mB/G98BvP3YqQYkTERLR9TaxlqtOFrv8P2qs
# rut//wGZJ7eOuvJOHCOK6WMPc960hmRepM9w8rkaNFYi6v3PvU9HWnCdj2fyajd8
# KoV5cOlaA2JkYoIoL/vBE5M20bLaH3J1JZMBwcxrgqN+cNl8rtbIXcCDMGwVL5jP
# 8bxBmNpN+KGBtTOlYKPM94rweYd1r5JCU9TIcEVIybbfDMy29PZWT2bb9hIOz1A1
# AXW3wXEthroC3AAgojPDnRyGtryDxr3k6RwrYMbTqY1yDeCNJPNy3hL+wiAm6eNP
# J0CXm6PgdwSiChAB1g2Byw9KuRZtQGuZM1Ca/whwqz0TPEiZ+iKlFyEdp9eZ/Y7+
# VVA++T+gH8x0RQKDCL7IeejaE2WPeFxl4/lgx70NXdJQwBjAZQu8ckpxO96aCJh0
# jaA919YIgMruw06TBAjzjMpR6znmtwIDAQABo4ICGTCCAhUwDAYDVR0TAQH/BAIw
# ADAOBgNVHQ8BAf8EBAMCB4AwPAYDVR0lBDUwMwYKKwYBBAGCN2EBAAYIKwYBBQUH
# AwMGGysGAQQBgjdhgqKNuwqmkohkgZH0oEWCk/3hbzAdBgNVHQ4EFgQU5aMqzJGe
# bD1S2Q7DvnCR5qD3uzUwHwYDVR0jBBgwFoAUdpw2dBPRkH1hX7MC64D0mUulPoUw
# ZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwRU9DJTIwQ0El
# MjAwMS5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQGCCsGAQUFBzAChlhodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEVPQyUyMENBJTIwMDEuY3J0MC0GCCsGAQUFBzABhiFo
# dHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwZgYDVR0gBF8wXTBRBgwr
# BgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEEATANBgkqhkiG
# 9w0BAQwFAAOCAgEAHjlyv8x/ZxvAaMDetDBIXZBiO1nJlyeUoVtbye+eQGjqy81a
# HYvU7L5EUL2+1JNwAk+FuQXsHPRSI4D02kzlz7ePenYA6n17O/4NKKDYWOBCnh6v
# CuwrJHjYEBKwlMNpMdQ6wN8fke9vEZ/fhWXGfoCUnhjVM5dsxxO1uiKV3rfh5Q+d
# CbsU1V3m05JT4AkyEMO59AucpTec/lRkX7JR7P9dT4j0oZostLbuwlMBfsAPSEnO
# YpoMZS7LPOYcesEA1poiZhhEmo58ufg1x/AOtsHwkhUBzOAQrx0We/amxm+Z80hf
# dyWDmYy/LqwwbSIarWgtHjeIMZZ7d8gsaKoRmJ7FOFOwKWVr2CoqDv61yWB6Yfjb
# VBuHqPH5exMPyiRdnMmKt/z3vxJIsYDJZfCAZnes5wLu+Mizqyu27K0lGlivF+I+
# YkCiHlTlOPZlE9avDIFfFrHquZk5cJR+2PZi7xciUoog4o49DJZvq+NwhElw4nX8
# dINSeQ56oku5s1rZKVY+0yuObkkAbYU8o2Wmu62Tb/+JJw+PqAZRUMZEYXx/Lu3I
# egqeTDt56tUbcX/aYxWPOoVRtJAkograHw8lYIIf6hznVdEbUR3jKiA0mo56OqS7
# dA65Ujrycy4p4VCa0jeax/LGfPyWquDbmu8W4q8BelDCqpTKOQmj6R4bocowggb+
# MIIE5qADAgECAhMzAADcG6+VxTB/HBRIAAAAANwbMA0GCSqGSIb3DQEBDAUAMFox
# CzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzAp
# BgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBFT0MgQ0EgMDEwHhcNMjQx
# MDE1MTQwOTU2WhcNMjQxMDE4MTQwOTU2WjB8MQswCQYDVQQGEwJVUzEPMA0GA1UE
# CBMGT3JlZ29uMRIwEAYDVQQHEwlCZWF2ZXJ0b24xIzAhBgNVBAoTGlB5dGhvbiBT
# b2Z0d2FyZSBGb3VuZGF0aW9uMSMwIQYDVQQDExpQeXRob24gU29mdHdhcmUgRm91
# bmRhdGlvbjCCAaIwDQYJKoZIhvcNAQEBBQADggGPADCCAYoCggGBAJ+HNfocUXcs
# ZiIJUfVWdNajHUhsic4PJhHkrDtSGddvddjj/AStI7BVvLlw1Nf/mB/G98BvP3Yq
# QYkTERLR9TaxlqtOFrv8P2qsrut//wGZJ7eOuvJOHCOK6WMPc960hmRepM9w8rka
# NFYi6v3PvU9HWnCdj2fyajd8KoV5cOlaA2JkYoIoL/vBE5M20bLaH3J1JZMBwcxr
# gqN+cNl8rtbIXcCDMGwVL5jP8bxBmNpN+KGBtTOlYKPM94rweYd1r5JCU9TIcEVI
# ybbfDMy29PZWT2bb9hIOz1A1AXW3wXEthroC3AAgojPDnRyGtryDxr3k6RwrYMbT
# qY1yDeCNJPNy3hL+wiAm6eNPJ0CXm6PgdwSiChAB1g2Byw9KuRZtQGuZM1Ca/whw
# qz0TPEiZ+iKlFyEdp9eZ/Y7+VVA++T+gH8x0RQKDCL7IeejaE2WPeFxl4/lgx70N
# XdJQwBjAZQu8ckpxO96aCJh0jaA919YIgMruw06TBAjzjMpR6znmtwIDAQABo4IC
# GTCCAhUwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwPAYDVR0lBDUwMwYK
# KwYBBAGCN2EBAAYIKwYBBQUHAwMGGysGAQQBgjdhgqKNuwqmkohkgZH0oEWCk/3h
# bzAdBgNVHQ4EFgQU5aMqzJGebD1S2Q7DvnCR5qD3uzUwHwYDVR0jBBgwFoAUdpw2
# dBPRkH1hX7MC64D0mUulPoUwZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmll
# ZCUyMENTJTIwRU9DJTIwQ0ElMjAwMS5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQG
# CCsGAQUFBzAChlhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRz
# L01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDUyUyMEVPQyUyMENBJTIwMDEu
# Y3J0MC0GCCsGAQUFBzABhiFodHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29j
# c3AwZgYDVR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRt
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAHjlyv8x/ZxvAaMDetDBIXZBi
# O1nJlyeUoVtbye+eQGjqy81aHYvU7L5EUL2+1JNwAk+FuQXsHPRSI4D02kzlz7eP
# enYA6n17O/4NKKDYWOBCnh6vCuwrJHjYEBKwlMNpMdQ6wN8fke9vEZ/fhWXGfoCU
# nhjVM5dsxxO1uiKV3rfh5Q+dCbsU1V3m05JT4AkyEMO59AucpTec/lRkX7JR7P9d
# T4j0oZostLbuwlMBfsAPSEnOYpoMZS7LPOYcesEA1poiZhhEmo58ufg1x/AOtsHw
# khUBzOAQrx0We/amxm+Z80hfdyWDmYy/LqwwbSIarWgtHjeIMZZ7d8gsaKoRmJ7F
# OFOwKWVr2CoqDv61yWB6YfjbVBuHqPH5exMPyiRdnMmKt/z3vxJIsYDJZfCAZnes
# 5wLu+Mizqyu27K0lGlivF+I+YkCiHlTlOPZlE9avDIFfFrHquZk5cJR+2PZi7xci
# Uoog4o49DJZvq+NwhElw4nX8dINSeQ56oku5s1rZKVY+0yuObkkAbYU8o2Wmu62T
# b/+JJw+PqAZRUMZEYXx/Lu3IegqeTDt56tUbcX/aYxWPOoVRtJAkograHw8lYIIf
# 6hznVdEbUR3jKiA0mo56OqS7dA65Ujrycy4p4VCa0jeax/LGfPyWquDbmu8W4q8B
# elDCqpTKOQmj6R4bocowggdaMIIFQqADAgECAhMzAAAABkoa+s8FYWp0AAAAAAAG
# MA0GCSqGSIb3DQEBDAUAMGMxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xNDAyBgNVBAMTK01pY3Jvc29mdCBJRCBWZXJpZmllZCBD
# b2RlIFNpZ25pbmcgUENBIDIwMjEwHhcNMjEwNDEzMTczMTU0WhcNMjYwNDEzMTcz
# MTU0WjBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ1MgRU9DIENBIDAx
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAx+PIP/Qh3cYZwLvFy6uu
# J4fTp3ln7Gqs7s8lTVyfgOJWP1aABwk2/oxdVjfSHUq4MTPXilL57qi/fH7YndEK
# 4Knd3u5cedFwr2aHSTp6vl/PL1dAL9sfoDvNpdG0N/R84AhYNpBQThpO4/BqxmCg
# l3iIRfhh2oFVOuiTiDVWvXBg76bcjnHnEEtXzvAWwJu0bBU7oRRqQed4VXJtICVt
# +ZoKUSjqY5wUlhAdwHh+31BnpBPCzFtKViLp6zEtRyOxRegagFU+yLgXvvmd07ID
# N0S2TLYuiZjTw+kcYOtoNgKr7k0C6E9Wf3H4jHavk2MxqFptgfL0gL+zbSb+VBNK
# iVT0mqzXJIJmWmqw0K+D3MKfmCer3e3CbrP+F5RtCb0XaE0uRcJPZJjWwciDBxBI
# bkNF4GL12hl5vydgFMmzQcNuodKyX//3lLJ1q22roHVS1cgtsLgpjWYZlBlhCTcX
# JeZ3xuaJvXZB9rcLCX15OgXL21tUUwJCLE27V5AGZxkO3i54mgSCswtOmWU4AKd/
# B/e3KtXv6XBURKuAteez1EpgloaZwQej9l5dN9Uh8W19BZg9IlLl+xHRX4vDiMWA
# Uf/7ANe4MoS98F45r76IGJ0hC02EMuMZxAErwZj0ln0aL53EzlMa5JCiRObb0UoL
# HfGSdNJsMg0uj3DAQDdVWTECAwEAAaOCAg4wggIKMA4GA1UdDwEB/wQEAwIBhjAQ
# BgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQUdpw2dBPRkH1hX7MC64D0mUulPoUw
# VAYDVR0gBE0wSzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTASBgNVHRMBAf8ECDAGAQH/AgEAMB8GA1UdIwQYMBaA
# FNlBKbAPD2Ns72nX9c0pnqRIajDmMHAGA1UdHwRpMGcwZaBjoGGGX2h0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIwVmVy
# aWZpZWQlMjBDb2RlJTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3JsMIGuBggrBgEF
# BQcBAQSBoTCBnjBtBggrBgEFBQcwAoZhaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ29kZSUy
# MFNpZ25pbmclMjBQQ0ElMjAyMDIxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29u
# ZW9jc3AubWljcm9zb2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQBqLwmf
# 2LB1QjUga0G7zFkbGd8NBQLHP0KOFBWNJFZiTtKfpO0bZ2Wfs6v5vqIKjE32Q6M8
# 9G4ZkVcvWuEAA+dvjLThSy89Y0//m/WTSKwYtiR1Ewn7x1kw/Fg93wQps2C1WUj+
# 00/6uNrF+d4MVJxV1HoBID+95ZIW0KkqZopnOA4w5vP4T5cBprZQAlP/vMGyB0H9
# +pHNo0jT9Q8gfKJNzHS9i1DgBmmufGdW9TByuno8GAizFMhLlIs08b5lilIkE5z3
# FMAUAr+XgII1FNZnb43OI6Qd2zOijbjYfursXUCNHC+RSwJGm5ULzPymYggnJ+kh
# JOq7oSlqPGpbr70hGBePw/J7/mmSqp7hTgt0mPikS1i4ap8x+P3yemYShnFrgV17
# 52TI+As69LfgLthkITvf7bFHB8vmIhadZCOS0vTCx3B+/OVcEMLNO2bJ0O9ikc1J
# qR0Fvqx7nAwMRSh3FVqosgzBbWnVkQJq7oWFwMVfFIYn6LPRZMt48u6iMUCFBSPd
# dsPA/6k85mEv+08U5WCQ7ydj1KVV2THre/8mLHiem9wf/CzohqRntxM2E/x+NHy6
# TBMnSPQRqhhNfuOgUDAWEYmlM/ZHGaPIb7xOvfVyLQ/7l6YfogT3eptwp4GOGRjH
# 5z+gG9kpBIx8QrRl6OilnlxRExokmMflL7l12TCCB54wggWGoAMCAQICEzMAAAAH
# h6M0o3uljhwAAAAAAAcwDQYJKoZIhvcNAQEMBQAwdzELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/TWljcm9zb2Z0
# IElkZW50aXR5IFZlcmlmaWNhdGlvbiBSb290IENlcnRpZmljYXRlIEF1dGhvcml0
# eSAyMDIwMB4XDTIxMDQwMTIwMDUyMFoXDTM2MDQwMTIwMTUyMFowYzELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMr
# TWljcm9zb2Z0IElEIFZlcmlmaWVkIENvZGUgU2lnbmluZyBQQ0EgMjAyMTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALLwwK8ZiCji3VR6TElsaQhVCbRS
# /3pK+MHrJSj3Zxd3KU3rlfL3qrZilYKJNqztA9OQacr1AwoNcHbKBLbsQAhBnIB3
# 4zxf52bDpIO3NJlfIaTE/xrweLoQ71lzCHkD7A4As1Bs076Iu+mA6cQzsYYH/Cbl
# 1icwQ6C65rU4V9NQhNUwgrx9rGQ//h890Q8JdjLLw0nV+ayQ2Fbkd242o9kH82RZ
# sH3HEyqjAB5a8+Ae2nPIPc8sZU6ZE7iRrRZywRmrKDp5+TcmJX9MRff241UaOBs4
# NmHOyke8oU1TYrkxh+YeHgfWo5tTgkoSMoayqoDpHOLJs+qG8Tvh8SnifW2Jj3+i
# i11TS8/FGngEaNAWrbyfNrC69oKpRQXY9bGH6jn9NEJv9weFxhTwyvx9OJLXmRGb
# AUXN1U9nf4lXezky6Uh/cgjkVd6CGUAf0K+Jw+GE/5VpIVbcNr9rNE50Sbmy/4RT
# CEGvOq3GhjITbCa4crCzTTHgYYjHs1NbOc6brH+eKpWLtr+bGecy9CrwQyx7S/Bf
# YJ+ozst7+yZtG2wR461uckFu0t+gCwLdN0A6cFtSRtR8bvxVFyWwTtgMMFRuBa3v
# mUOTnfKLsLefRaQcVTgRnzeLzdpt32cdYKp+dhr2ogc+qM6K4CBI5/j4VFyC4QFe
# UP2YAidLtvpXRRo3AgMBAAGjggI1MIICMTAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFNlBKbAPD2Ns72nX9c0pnqRIajDmMFQGA1Ud
# IARNMEswSQYEVR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wGQYJKwYBBAGCNxQCBAwe
# CgBTAHUAYgBDAEEwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTIftJqhSob
# yhmYBAcnz1AQT2ioojCBhAYDVR0fBH0wezB5oHegdYZzaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJp
# ZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3JpdHklMjAyMDIw
# LmNybDCBwwYIKwYBBQUHAQEEgbYwgbMwgYEGCCsGAQUFBzAChnVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElkZW50aXR5
# JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRpZmljYXRlJTIwQXV0aG9yaXR5
# JTIwMjAyMC5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29m
# dC5jb20vb2NzcDANBgkqhkiG9w0BAQwFAAOCAgEAfyUqnv7Uq+rdZgrbVyNMul5s
# kONbhls5fccPlmIbzi+OwVdPQ4H55v7VOInnmezQEeW4LqK0wja+fBznANbXLB0K
# rdMCbHQpbLvG6UA/Xv2pfpVIE1CRFfNF4XKO8XYEa3oW8oVH+KZHgIQRIwAbyFKQ
# 9iyj4aOWeAzwk+f9E5StNp5T8FG7/VEURIVWArbAzPt9ThVN3w1fAZkF7+YU9kbq
# 1bCR2YD+MtunSQ1Rft6XG7b4e0ejRA7mB2IoX5hNh3UEauY0byxNRG+fT2MCEhQl
# 9g2i2fs6VOG19CNep7SquKaBjhWmirYyANb0RJSLWjinMLXNOAga10n8i9jqeprz
# SMU5ODmrMCJE12xS/NWShg/tuLjAsKP6SzYZ+1Ry358ZTFcx0FS/mx2vSoU8s8HR
# vy+rnXqyUJ9HBqS0DErVLjQwK8VtsBdekBmdTbQVoCgPCqr+PDPB3xajYnzevs7e
# idBsM71PINK2BoE2UfMwxCCX3mccFgx6UsQeRSdVVVNSyALQe6PT12418xon2iDG
# E81OGCreLzDcMAZnrUAx4XQLUz6ZTl65yPUiOh3k7Yww94lDf+8oG2oZmDh5O1Qe
# 38E+M3vhKwmzIeoB1dVLlz4i3IpaDcR+iuGjH2TdaC1ZOmBXiCRKJLj4DT2uhJ04
# ji+tHD6n58vhavFIrmcxghqUMIIakAIBATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBFT0MgQ0EgMDECEzMAANwbr5XFMH8cFEgAAAAA3BswDQYJ
# YIZIAWUDBAIBBQCgXjAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQgKld7dFLdvZygPQIm94QeWCWq09Rh
# nYWpKs5R8/oLpjgwDQYJKoZIhvcNAQEBBQAEggGAYi8i2go5MKykuOZBetQ/gzCd
# D1P/DjyYujGCLqirkp7aLoT/eAllEspH11Yun91uqtGzkWhqHIlr7FmLCFLroFQh
# 05Bd8/3Qp8D+HOEYquLovV4DlZM0/jsd2gvQH796cYDoQCqqItdrGxzZ9qMudiLb
# iJbyfdv9+Mh7kFEKMNUQTq/aAfGEK7ChPRNNVG7gFUrXlAOLfqUCvoXZkarbrIS7
# DrPJ62enxBGNxAscVFYpu/0X+0MVhwg24Jxhke7UVkPZV8/OVdhUTTXpYEs2qH9k
# gvItqtuD/SThhirRnR8LdsaGdCjccvbyKs9C0EidZMvAX+WpP6NayQgcJaUG10V9
# ZwWCnquNFNWB9jjeYcATpFPTLS4t/+uVhuDKHPaDe9LWr0fgF3iF8b/N2vGMX+g6
# 5GUBVuExIdQ35/d0+LFT/mer5zrJila4Auzyp78yiacSFT81i5TZT6E9nI7YObh1
# xtlTV9lUu1rZ3ZTA/BWiV4Ec3c0yOkndpbMN2fBkoYIYFDCCGBAGCisGAQQBgjcD
# AwExghgAMIIX/AYJKoZIhvcNAQcCoIIX7TCCF+kCAQMxDzANBglghkgBZQMEAgEF
# ADCCAWIGCyqGSIb3DQEJEAEEoIIBUQSCAU0wggFJAgEBBgorBgEEAYRZCgMBMDEw
# DQYJYIZIAWUDBAIBBQAEII7lqeHixqBx+d3yijVoFlKTBoJn/ymfli+mZq+hUyv5
# AgZnDR3yPScYEzIwMjQxMDE1MjEwMjQ0LjEzMlowBIACAfSggeGkgd4wgdsxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jv
# c29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# Tjo3ODAwLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0Eg
# VGltZSBTdGFtcGluZyBBdXRob3JpdHmggg8hMIIHgjCCBWqgAwIBAgITMwAAAAXl
# zw//Zi7JhwAAAAAABTANBgkqhkiG9w0BAQwFADB3MQswCQYDVQQGEwJVUzEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMUgwRgYDVQQDEz9NaWNyb3NvZnQg
# SWRlbnRpdHkgVmVyaWZpY2F0aW9uIFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMjAwHhcNMjAxMTE5MjAzMjMxWhcNMzUxMTE5MjA0MjMxWjBhMQswCQYDVQQG
# EwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylN
# aWNyb3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJ5851Jj/eDFnwV9Y7UGIqMcHtfnlzPR
# EwW9ZUZHd5HBXXBvf7KrQ5cMSqFSHGqg2/qJhYqOQxwuEQXG8kB41wsDJP5d0zmL
# YKAY8Zxv3lYkuLDsfMuIEqvGYOPURAH+Ybl4SJEESnt0MbPEoKdNihwM5xGv0rGo
# fJ1qOYSTNcc55EbBT7uq3wx3mXhtVmtcCEr5ZKTkKKE1CxZvNPWdGWJUPC6e4uRf
# WHIhZcgCsJ+sozf5EeH5KrlFnxpjKKTavwfFP6XaGZGWUG8TZaiTogRoAlqcevbi
# qioUz1Yt4FRK53P6ovnUfANjIgM9JDdJ4e0qiDRm5sOTiEQtBLGd9Vhd1MadxoGc
# HrRCsS5rO9yhv2fjJHrmlQ0EIXmp4DhDBieKUGR+eZ4CNE3ctW4uvSDQVeSp9h1S
# aPV8UWEfyTxgGjOsRpeexIveR1MPTVf7gt8hY64XNPO6iyUGsEgt8c2PxF87E+CO
# 7A28TpjNq5eLiiunhKbq0XbjkNoU5JhtYUrlmAbpxRjb9tSreDdtACpm3rkpxp7A
# QndnI0Shu/fk1/rE3oWsDqMX3jjv40e8KN5YsJBnczyWB4JyeeFMW3JBfdeAKhzo
# hFe8U5w9WuvcP1E8cIxLoKSDzCCBOu0hWdjzKNu8Y5SwB1lt5dQhABYyzR3dxEO/
# T1K/BVF3rV69AgMBAAGjggIbMIICFzAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYBBAGC
# NxUBBAMCAQAwHQYDVR0OBBYEFGtpKDo1L0hjQM972K9J6T7ZPdshMFQGA1UdIARN
# MEswSQYEVR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwDwYDVR0TAQH/BAUwAwEB/zAf
# BgNVHSMEGDAWgBTIftJqhSobyhmYBAcnz1AQT2ioojCBhAYDVR0fBH0wezB5oHeg
# dYZzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0
# JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUl
# MjBBdXRob3JpdHklMjAyMDIwLmNybDCBlAYIKwYBBQUHAQEEgYcwgYQwgYEGCCsG
# AQUFBzAChnVodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01p
# Y3Jvc29mdCUyMElkZW50aXR5JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRp
# ZmljYXRlJTIwQXV0aG9yaXR5JTIwMjAyMC5jcnQwDQYJKoZIhvcNAQEMBQADggIB
# AF+Idsd+bbVaFXXnTHho+k7h2ESZJRWluLE0Oa/pO+4ge/XEizXvhs0Y7+KVYyb4
# nHlugBesnFqBGEdC2IWmtKMyS1OWIviwpnK3aL5JedwzbeBF7POyg6IGG/XhhJ3U
# qWeWTO+Czb1c2NP5zyEh89F72u9UIw+IfvM9lzDmc2O2END7MPnrcjWdQnrLn1Nt
# day7JSyrDvBdmgbNnCKNZPmhzoa8PccOiQljjTW6GePe5sGFuRHzdFt8y+bN2neF
# 7Zu8hTO1I64XNGqst8S+w+RUdie8fXC1jKu3m9KGIqF4aldrYBamyh3g4nJPj/LR
# 2CBaLyD+2BuGZCVmoNR/dSpRCxlot0i79dKOChmoONqbMI8m04uLaEHAv4qwKHQ1
# vBzbV/nG89LDKbRSSvijmwJwxRxLLpMQ/u4xXxFfR4f/gksSkbJp7oqLwliDm/h+
# w0aJ/U5ccnYhYb7vPKNMN+SZDWycU5ODIRfyoGl59BsXR/HpRGtiJquOYGmvA/pk
# 5vC1lcnbeMrcWD/26ozePQ/TWfNXKBOmkFpvPE8CH+EeGGWzqTCjdAsno2jzTeNS
# xlx3glDGJgcdz5D/AAxw9Sdgq/+rY7jjgs7X6fqPTXPmaCAJKVHAP19oEjJIBwD1
# LyHbaEgBxFCogYSOiUIr0Xqcr1nJfiWG2GwYe6ZoAF1bMIIHlzCCBX+gAwIBAgIT
# MwAAADuKaVm+FAVkcQAAAAAAOzANBgkqhkiG9w0BAQwFADBhMQswCQYDVQQGEwJV
# UzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNy
# b3NvZnQgUHVibGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDAeFw0yNDAyMTUy
# MDM2MTJaFw0yNTAyMTUyMDM2MTJaMIHbMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRp
# b25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046NzgwMC0wNUUwLUQ5NDcxNTAz
# BgNVBAMTLE1pY3Jvc29mdCBQdWJsaWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9y
# aXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAqDdrWVe9AA4HgK0i
# qMLze7A9Vo/XdnSg8zbEqUGUg95MFH7T/aguKP3g7788fwMz7SaZFuSaQ6mChiJN
# zUsslhZWNdpaC+poZETvCt5Sy4GfcAK+vM/tVtDS7NAXePEFLS33JAIk6HpJ3bKi
# hT9vI2TigVON51tkoixC9VqNiVBxVuQq8NegZJrN2/FPXrUCnBKzQ4E21J8RW3O9
# w6+O3peqabMumTBSu2ls68oymWXycEtRJoE9gk0OF2Pao9hXfct4EljZT/l6xsgo
# j0N6EOXHa/TLOfZ2ozWtFsR20ewfAzyMV0Q8QpnUMR8Nxy/TfEgtNe3L8AOIRLgT
# H4sdoAu8Yg8jPqU5JdvAWdQDZwc5xDGbPa2x7SkKcs9m7DTtEWET/sayGbVnbr8A
# lhAepNh+VB0mBKzFE5tk+FTkHhrIz0RXKPrf+bKRajwbFK/+++IuGfnwHw/dQ9Qx
# YIiuQlWYIJNUrShVQ30EilOWEVyP02jOG1aHAFt0va1YKUFwnFiP1iRAcWGZ+kie
# XROOVZQsMguxxGbwjq7TNNqxC5QnF2xnSAi9xZbT4fQNmbA8NBwOv+zVxd5ocmd+
# 8kN7Ka0vzIJW+XXWN/yi+58gn3oVbkA4xQ9kv4exQpDNbRRTiZx65/lB2gbFkvy4
# 8inQS0itug/wukT2zOpuTKniUCMCAwEAAaOCAcswggHHMB0GA1UdDgQWBBQZg5Ep
# zt2JMd0FrPd98JDZpxzxFTAfBgNVHSMEGDAWgBRraSg6NS9IY0DPe9ivSek+2T3b
# ITBsBgNVHR8EZTBjMGGgX6BdhltodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2NybC9NaWNyb3NvZnQlMjBQdWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmcl
# MjBDQSUyMDIwMjAuY3JsMHkGCCsGAQUFBwEBBG0wazBpBggrBgEFBQcwAoZdaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBQ
# dWJsaWMlMjBSU0ElMjBUaW1lc3RhbXBpbmclMjBDQSUyMDIwMjAuY3J0MAwGA1Ud
# EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeA
# MGYGA1UdIARfMF0wUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAI
# BgZngQwBBAIwDQYJKoZIhvcNAQEMBQADggIBACqwLunRSWLugSoSzHQMZxDM3isy
# TjLp8jngjF/VQv5nlRbnVEct0SmTGFKtGBakNAbJn7n7MBrM8H0p6mqtdev36Jom
# KJMQQ0FP69rvLF6HejX0mg/P8cf6QBUlNvGBWCYeOvsHZUd9MIH/vLiSTJaWfdHx
# omdnK08NCmSVlkoOdzJV02pQT+2XqZ6FafTZnEQ/Qg8PtyHZI8x9cgp3421qdB3w
# SXb+1iVZXJ0TOOTGKlF9cfuSwnng5wcNqU493AyjzTbTYW/AR0XEyUh/OLY1UU7a
# QrXNV2RObvrtINbQsy0puwJkfkmY6Apcs4p7kLqpP/JMemEaMO2PMAYmYz+S364k
# a3mgxqZve3n84ZMFSnLGbCp8NNOxoT0UFs+dn0oDLEc4Oq1sejEQb93PpAXHn4C1
# VRCN4ILoHo/TcA11J5h/gwuoq+TU0N2VS4cANhY25/q3LXF3qMz+YPwkvUMeAvEa
# ZL8mRrwRAQ8jRXVPa9h8jLxT/zWlAiNMQu6C3XuRTjXkRSNNYrUl5NTe0fNCVFu4
# 6kSr8u1HqoOk+j8FnwHf0fr4e6EF4Sx/fHTyTDg893HQrcOTHgJ33H1AxBPG+psy
# SuYiyW5ymCEPqPU/wHEtANcgogpWgWQU6HImhU+SUrbwnuwg871FlQWN++Xs0Ppe
# jN7U88utxqQQ6IUjMYIHRjCCB0ICAQEweDBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAADuKaVm+FAVkcQAAAAAA
# OzANBglghkgBZQMEAgEFAKCCBJ8wEQYLKoZIhvcNAQkQAg8xAgUAMBoGCSqGSIb3
# DQEJAzENBgsqhkiG9w0BCRABBDAcBgkqhkiG9w0BCQUxDxcNMjQxMDE1MjEwMjQ0
# WjAvBgkqhkiG9w0BCQQxIgQgAktq98MGfffvjNwlhFdlplNRxaKnieGNjkL64JeB
# O0wwgbkGCyqGSIb3DQEJEAIvMYGpMIGmMIGjMIGgBCCT2ycyxJ4mJM8KXMA60ErM
# CSf8r156/dSj4jtvwZau3DB8MGWkYzBhMQswCQYDVQQGEwJVUzEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVibGlj
# IFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMAITMwAAADuKaVm+FAVkcQAAAAAAOzCC
# A2EGCyqGSIb3DQEJEAISMYIDUDCCA0yhggNIMIIDRDCCAiwCAQEwggEJoYHhpIHe
# MIHbMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046NzgwMC0wNUUwLUQ5NDcxNTAzBgNVBAMTLE1pY3Jvc29mdCBQdWJs
# aWMgUlNBIFRpbWUgU3RhbXBpbmcgQXV0aG9yaXR5oiMKAQEwBwYFKw4DAhoDFQAp
# TtyEDHUj3Lv5f7jeOCak0Ihv96BnMGWkYzBhMQswCQYDVQQGEwJVUzEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUHVi
# bGljIFJTQSBUaW1lc3RhbXBpbmcgQ0EgMjAyMDANBgkqhkiG9w0BAQsFAAIFAOq4
# 7fgwIhgPMjAyNDEwMTUxMzM0NDhaGA8yMDI0MTAxNjEzMzQ0OFowdzA9BgorBgEE
# AYRZCgQBMS8wLTAKAgUA6rjt+AIBADAKAgEAAgISDwIB/zAHAgEAAgITRTAKAgUA
# 6ro/eAIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAID
# B6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBCwUAA4IBAQCAeS6fDxVdyUrJUoIK
# QhT5Mbk2t8EIAyGguQz8U0MYR5p8rfb/TpPMVaRi2qaWjren+gK43n5mPL+ycBIq
# Kpth6msxjzwrTulT7MYWbaF1pw0PwDRdIJ5BHAgpJhe0itY7Q7P4S2ncToNFvJwb
# R8u3J7369KWandK7V3+8QlP5yYfSV6K25JCuz1ugJb2JnHQFrXcGRhkOLTKeHIcP
# lUiaqlByxOTpDcORE0NZ2HGYkKm4hWKyGjfmuV0k669aS3eZFpMqWJqh3lbD0+rQ
# oZHwF6/hItGPIOelNr2cS/KTvVDfY1It1H7mlHavkolMbJaB3zJt5lwntwrzMt+f
# qgjpMA0GCSqGSIb3DQEBAQUABIICADYfvkznolt+xmSzZ84ryiY0TlOBjB+BbbHF
# Skvv5K4cHAR1kU6gN4LbJJJ5eQ6VWJVoJ9qsgZ6lGMck3W2znDU3rXzauM3QKMeb
# P5sDDk3ColF7VR+B+DGtAMwQt1btP5rLidlrmvDhBWgTYtjXfGG5hBd3Jt1AYpFb
# XX7YCssip9/eC6gkVgZWBPPLAYBo1qwGQkeDqIQ7/nXewnId6/OwAoaRXu2zyafm
# 0jYNylTqPC09QLwwqkxHg+XYmslhpKKdbsnVK4bcH4OZ1BBWrL147ZbTwkxfHeE/
# 7JBIB98+tv7uCFQ580YeikhClgNWnSrlFhv3JT7HPpSW4AEZ4qlMhpPMxlmSfnrA
# W6zdHpeAkGiVrV2aXrirtRHlWBBRZX3PrejkxpuOP6tAL2j4A7OHeq2hlC9TP3t2
# iXtyvFp39kqKxOFUyeuasrGQqRSKlOykb0jFdkfrCKg8YEn3LZBhd44mK25DXwlA
# F0efErX+pV4voObxwDWlr4ITYa5OQbznp8AQPo8R+Qjz6sK1HwQwrdzu1iW1pMVp
# pGrGzlyUAJ0IAl1Ut7FVbppCYcqU8t7JmB+nIMbKwMiqtgVrIyL2lbPSWa5KeTxy
# aP2VuH0qnOz8gDHFdIRURkZqOvfvHqubMFPz1UNc/eWvVaPJefxYyu/td2gEWapJ
# FfYqOb2E
# SIG # End signature block
