# Check for active Conda environment
$condaEnv = $env:CONDA_DEFAULT_ENV

if ([string]::IsNullOrEmpty($condaEnv) -or $condaEnv -eq "base") {
    Write-Host "Error: No active Conda environment or currently in 'base' environment." -ForegroundColor Red
    Write-Host "Please activate a non-base Conda environment before running this script." -ForegroundColor Yellow
    exit 1
}

# Uninstall all pip packages and remove the lock file
Write-Host "Uninstalling all pip packages from Conda environment: $condaEnv"
pip freeze | Where-Object { $_ -notmatch "^-e" } | ForEach-Object { pip uninstall -y $_.Split('==')[0] }

if ($LASTEXITCODE -eq 0) {
    if (Test-Path requirements-lock.txt) {
        Remove-Item requirements-lock.txt
        Write-Host "Removed requirements-lock.txt" -ForegroundColor Green
    }
    Write-Host "All packages uninstalled successfully." -ForegroundColor Green
} else {
    Write-Host "Failed to uninstall some packages. Check the output above for details." -ForegroundColor Red
    exit 1
}