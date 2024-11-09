###############################################################################
# PowerShell Profile Configuration
# Last Updated: 09/23/2024
###############################################################################

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\nicholasgrundl\miniconda3\Scripts\conda.exe") {
    (& "C:\Users\nicholasgrundl\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

###############################################################################
# Custom Aliases and Functions
###############################################################################

# Custom ls functions
function Get-ChildItemFormatWide { Get-ChildItem @args | Format-Wide }
function Get-ChildItemWithHidden { Get-ChildItem -Force @args }
function Get-ChildItemDetailed { Get-ChildItem -Force @args | Format-Table -AutoSize }

# Create aliases
New-Alias -Name l -Value Get-ChildItemFormatWide -Force -Option AllScope
New-Alias -Name la -Value Get-ChildItemWithHidden -Force -Option AllScope
New-Alias -Name ll -Value Get-ChildItemDetailed -Force -Option AllScope

###############################################################################
# Custom PS1 Prompt
###############################################################################

function prompt {
    $origLastExitCode = $LASTEXITCODE
    $prompt = [System.Text.StringBuilder]::new()

    # Get current git branch
    $gitBranch = git branch --show-current 2>$null
    if ($gitBranch) { $gitBranch = "($gitBranch)" }

    # Get current conda environment or use "()" if none
    $condaEnv = if ($env:CONDA_DEFAULT_ENV) { "($env:CONDA_DEFAULT_ENV)" } else { "()" }

    # Build prompt
    [void]$prompt.Append((Write-Host $condaEnv -ForegroundColor Cyan -NoNewline))
    [void]$prompt.Append((Write-Host ":" -ForegroundColor DarkGray -NoNewline))
    [void]$prompt.Append((Write-Host "$env:USERNAME@$env:COMPUTERNAME" -ForegroundColor Green -NoNewline))
    [void]$prompt.Append((Write-Host ":" -ForegroundColor DarkGray -NoNewline))
    [void]$prompt.Append((Write-Host $($ExecutionContext.SessionState.Path.CurrentLocation) -ForegroundColor Blue -NoNewline))
    [void]$prompt.Append((Write-Host ":" -ForegroundColor DarkGray -NoNewline))

    if ($gitBranch) {
        [void]$prompt.Append((Write-Host $gitBranch -ForegroundColor Yellow -NoNewline))
    }
    
    [void]$prompt.Append((Write-Host "$('$' * ($nestedPromptLevel + 1)) " -ForegroundColor White -NoNewline))

    $LASTEXITCODE = $origLastExitCode
    return " "
}

###############################################################################
# Load Custom Function Modules
###############################################################################

$customModules = @(
    "DiagnosticFunctions", # Troubleshooting functions and SSH state
    "SSHFunctions", # setup SSH on shell start
    "EnvFunctions"  # environment variable management dotenv format
)

foreach ($module in $customModules) {
    $modulePath = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\$module.ps1"
    if (Test-Path $modulePath) {
        . $modulePath
        Write-Host "Loaded custom module: $module" -ForegroundColor Green
    } else {
        Write-Host "Warning: Custom module not found: $module" -ForegroundColor Yellow
    }
}

###############################################################################
# Initialize Profile Configuration
###############################################################################

# Call the SSH setup function
Set-SSHEnvironment

###############################################################################
# End of Profile Configuration
###############################################################################

Write-Host "PowerShell profile loaded successfully!" -ForegroundColor Cyan