function Get-SSHDiagnostics {
    Write-Host "==== SSH Environment Diagnostics ====" -ForegroundColor Cyan

    # Check SSH environment variables
    Write-Host "`nSSH Environment Variables:" -ForegroundColor Yellow
    Write-Host "SSH_AUTH_SOCK: $env:SSH_AUTH_SOCK"
    Write-Host "SSH_AGENT_PID: $env:SSH_AGENT_PID"

    # Check if SSH_AUTH_SOCK file exists
    if ($env:SSH_AUTH_SOCK) {
        if (Test-Path $env:SSH_AUTH_SOCK) {
            Write-Host "SSH_AUTH_SOCK file exists." -ForegroundColor Green
        } else {
            Write-Host "SSH_AUTH_SOCK file does not exist!" -ForegroundColor Red
        }
    } else {
        Write-Host "SSH_AUTH_SOCK is not set!" -ForegroundColor Red
    }

    # Check for running ssh-agent processes
    $sshAgents = Get-Process ssh-agent -ErrorAction SilentlyContinue
    Write-Host "`nRunning ssh-agent processes:" -ForegroundColor Yellow
    if ($sshAgents) {
        foreach ($agent in $sshAgents) {
            Write-Host "PID: $($agent.Id), Start Time: $($agent.StartTime)"
        }
        if ($sshAgents.Count -gt 1) {
            Write-Host "Warning: Multiple ssh-agent processes detected!" -ForegroundColor Red
        }
    } else {
        Write-Host "No ssh-agent processes found." -ForegroundColor Red
    }

    # Check if the SSH_AGENT_PID matches any running ssh-agent
    if ($env:SSH_AGENT_PID) {
        $matchingAgent = $sshAgents | Where-Object { $_.Id -eq $env:SSH_AGENT_PID }
        if ($matchingAgent) {
            Write-Host "SSH_AGENT_PID matches a running ssh-agent process." -ForegroundColor Green
        } else {
            Write-Host "SSH_AGENT_PID does not match any running ssh-agent process!" -ForegroundColor Red
        }
    } else {
        Write-Host "SSH_AGENT_PID is not set!" -ForegroundColor Red
    }

    # Check for SSH keys in the agent
    Write-Host "`nSSH Keys in Agent:" -ForegroundColor Yellow
    try {
        $sshAddOutput = ssh-add -l 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host $sshAddOutput
        } elseif ($LASTEXITCODE -eq 1) {
            Write-Host "The agent has no identities." -ForegroundColor Yellow
        } else {
            Write-Host "Error communicating with ssh-agent." -ForegroundColor Red
        }
    } catch {
        Write-Host "Failed to run ssh-add: $_" -ForegroundColor Red
    }

    # Check for persistent environment variables
    Write-Host "`nPersistent SSH Environment Variables:" -ForegroundColor Yellow
    $persistentSockPath = [System.Environment]::GetEnvironmentVariable('SSH_AUTH_SOCK', [System.EnvironmentVariableTarget]::User)
    Write-Host "Persistent SSH_AUTH_SOCK: $persistentSockPath"
    if ($persistentSockPath -ne $env:SSH_AUTH_SOCK) {
        Write-Host "Warning: Persistent SSH_AUTH_SOCK doesn't match current session!" -ForegroundColor Red
    }

    Write-Host "`n==== End of SSH Diagnostics ====" -ForegroundColor Cyan
}

function Test-SSHEnvironment {
    Write-Host "==== Testing SSH Environment ===="

    # 1. Check current state
    Write-Host "`nCurrent SSH Environment:"
    Write-Host "SSH_AUTH_SOCK: $env:SSH_AUTH_SOCK"
    Write-Host "SSH_AGENT_PID: $env:SSH_AGENT_PID"
    
    Write-Host "`nLoaded SSH Keys:"
    ssh-add -l

    # 2. Test GitHub connection
    Write-Host "`nTesting GitHub Connection:"
    ssh -T git@github.com

    # 3. Reset SSH Environment
    Write-Host "`n==== Resetting SSH Environment ===="
    Reset-SSHEnvironment

    # 4. Check state after reset
    Write-Host "`nSSH Environment after reset:"
    Write-Host "SSH_AUTH_SOCK: $env:SSH_AUTH_SOCK"
    Write-Host "SSH_AGENT_PID: $env:SSH_AGENT_PID"
    
    Write-Host "`nLoaded SSH Keys (should be none):"
    ssh-add -l

    # 5. Set up SSH Environment again
    Write-Host "`n==== Setting up SSH Environment ===="
    Set-SSHEnvironment

    # 6. Check final state
    Write-Host "`nFinal SSH Environment:"
    Write-Host "SSH_AUTH_SOCK: $env:SSH_AUTH_SOCK"
    Write-Host "SSH_AGENT_PID: $env:SSH_AGENT_PID"
    
    Write-Host "`nLoaded SSH Keys:"
    ssh-add -l

    # 7. Test GitHub connection again
    Write-Host "`nTesting GitHub Connection again:"
    ssh -T git@github.com

    Write-Host "`n==== SSH Environment Test Complete ===="
}