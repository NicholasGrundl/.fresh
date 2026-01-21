###############################################################################
# Environment Variable Management Functions
# Last Updated: 09/23/2024
###############################################################################

# Function: Resolve-EnvPath
# Synopsis: Resolves various path formats to a full path.
# Description: This helper function resolves relative paths, paths with ~, and absolute paths.
function Resolve-EnvPath {
    param (
        [string]$Path
    )

    if ($Path.StartsWith("~")) {
        $Path = $Path.Replace("~", $HOME)
    }
    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

# Function: Set-EnvironmentFromFile
# Synopsis: Sets environment variables from a .env file.
# Description: This function reads a .env file and sets environment variables based on its contents.
#              It supports variable expansion, tilde (~) expansion for home directory, and relative paths.
# Parameter: Path to the .env file (can be provided without a parameter name)
# Example: Set-EnvironmentFromFile ".env"
#          Set-EnvironmentFromFile "~/project/.env"
#          Set-EnvironmentFromFile -EnvFilePath "C:\Projects\MyProject\.env"
function Set-EnvironmentFromFile {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$EnvFilePath
    )

    $FullPath = Resolve-EnvPath $EnvFilePath
    Write-Verbose "Resolved path: $FullPath"

    if (-not (Test-Path $FullPath)) {
        Write-Error "File not found: $FullPath"
        return
    }

    Write-Host "+-----------------------+"
    Write-Host "| Setting Env Variables |"
    Write-Host "+-----------------------+"

    Get-Content $FullPath | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#")) {
            $key, $value = $_ -split '=', 2
            $expandedValue = $ExecutionContext.InvokeCommand.ExpandString($value)
            
            # Replace '~' with the user's home directory in the value
            if ($expandedValue.StartsWith("~")) {
                $expandedValue = $expandedValue -replace '^~', $HOME
            }

            [Environment]::SetEnvironmentVariable($key.Trim(), $expandedValue.Trim(), [System.EnvironmentVariableTarget]::Process)
            Write-Host "  - $key"
        }
    }
    Write-Host ""
}

# Function: Unset-EnvironmentFromFile
# Synopsis: Unsets environment variables specified in a .env file.
# Description: This function reads a .env file and unsets (removes) the environment variables 
#              specified in the file. It supports relative paths and ~ for home directory.
# Parameter: Path to the .env file (can be provided without a parameter name)
# Example: Unset-EnvironmentFromFile ".env"
#          Unset-EnvironmentFromFile "~/project/.env"
#          Unset-EnvironmentFromFile -EnvFilePath "C:\Projects\MyProject\.env"
function Unset-EnvironmentFromFile {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$EnvFilePath
    )

    $FullPath = Resolve-EnvPath $EnvFilePath
    Write-Verbose "Resolved path: $FullPath"

    if (-not (Test-Path $FullPath)) {
        Write-Error "File not found: $FullPath"
        return
    }

    Write-Host "+-------------------------+"
    Write-Host "| Unsetting Env Variables |"
    Write-Host "+-------------------------+"

    Get-Content $FullPath | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith("#")) {
            $key = ($_ -split '=')[0].Trim()
            [Environment]::SetEnvironmentVariable($key, $null, [System.EnvironmentVariableTarget]::Process)
            Write-Host "  - $key"
        }
    }
    Write-Host ""
}

###############################################################################
# End of Environment Functions
###############################################################################