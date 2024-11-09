# Check for active Conda environment
$condaEnv = $env:CONDA_DEFAULT_ENV

if ([string]::IsNullOrEmpty($condaEnv) -or $condaEnv -eq "base") {
    Write-Host "Error: No active Conda environment or currently in 'base' environment." -ForegroundColor Red
    Write-Host "Please activate a non-base Conda environment before running this script." -ForegroundColor Yellow
    exit 1
}

# Install dependencies and create a lock file
Write-Host "Installing dependencies in Conda environment: $condaEnv"
pip install -r ./requirements.txt
pip install -r ./requirements-dev.txt

if ($LASTEXITCODE -eq 0) {
    # Use UTF-8 encoding without BOM for requirements-lock.txt
    pip freeze | Out-File -FilePath requirements-lock.txt -Encoding utf8
    Write-Host "Pinned requirements exported to requirements-lock.txt" -ForegroundColor Green
} else {
    Write-Host "Failed to install some dependencies. Check the output above for details." -ForegroundColor Red
    exit 1
}