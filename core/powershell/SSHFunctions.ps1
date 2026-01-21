function Set-SSHEnvironment {
    Write-Host "==== Starting SSH setup ===="

    function Find-SSHAgentPipe {
        $agentPipes = Get-ChildItem "\\.\pipe\" | Where-Object { $_.Name -like "*ssh-agent*" }
        if ($agentPipes) {
            return "\\.\pipe\$($agentPipes[0].Name)"
        }
        return $null
    }

    function Start-NewSSHAgent {
        Write-Host "Starting new SSH agent..."
        Start-Process -FilePath "ssh-agent" -NoNewWindow -Wait
        $sshAgent = Get-Process ssh-agent -ErrorAction SilentlyContinue
        if ($sshAgent) {
            $env:SSH_AGENT_PID = $sshAgent.Id
            $env:SSH_AUTH_SOCK = Find-SSHAgentPipe
            Write-Host "New SSH agent started with PID: $env:SSH_AGENT_PID"
            return $true
        }
        Write-Host "Failed to start SSH Agent."
        return $false
    }

    # Check for existing ssh-agent processes
    $sshAgent = Get-Process ssh-agent -ErrorAction SilentlyContinue
    if ($sshAgent) {
        Write-Host "Found existing SSH agent with PID: $($sshAgent.Id)"
        $env:SSH_AGENT_PID = $sshAgent.Id
        $env:SSH_AUTH_SOCK = Find-SSHAgentPipe
    } else {
        Write-Host "No existing SSH agent found. Starting a new one..."
        if (-not (Start-NewSSHAgent)) {
            Write-Host "Failed to set up SSH agent. Exiting..."
            return
        }
    }

    # Verify SSH agent connection
    $sshAddOutput = ssh-add -l 2>&1
    if ($LASTEXITCODE -in 0, 1) {
        Write-Host "Successfully connected to SSH agent."
    } else {
        Write-Host "Failed to connect to SSH agent. Trying to start a new one..."
        if (-not (Start-NewSSHAgent)) {
            Write-Host "Failed to set up SSH agent. Exiting..."
            return
        }
    }

    # Add SSH keys to the agent
    Write-Host "Checking for SSH keys..."
    $sshKeyTypes = @("id_rsa", "id_ed25519")
    $keyAdded = $false

    foreach ($keyType in $sshKeyTypes) {
        $keyPath = "$env:USERPROFILE\.ssh\$keyType"
    
        if (Test-Path $keyPath) {
            Write-Host "Adding $keyType SSH key to the agent..."
            $addKeyOutput = ssh-add $keyPath 2>&1
            Write-Host $addKeyOutput
            $keyAdded = $true
        } else {
            Write-Host "No $keyType SSH key found at $keyPath"
        }
    }

    if (-not $keyAdded) {
        Write-Host "No SSH keys were found or added."
    }

    # Persist the environment variables
    [System.Environment]::SetEnvironmentVariable('SSH_AUTH_SOCK', $env:SSH_AUTH_SOCK, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable('SSH_AGENT_PID', $env:SSH_AGENT_PID, [System.EnvironmentVariableTarget]::User)

    Write-Host "SSH_AUTH_SOCK: $env:SSH_AUTH_SOCK"
    Write-Host "SSH_AGENT_PID: $env:SSH_AGENT_PID"
	
	Write-Host "==== SSH setup complete ===="
    Write-Host "You can now run Reset-SSHEnvironment to clear all SSH setup"
}

function Reset-SSHEnvironment {
    Write-Host "==== Resetting SSH Environment ===="

    # Stop all ssh-agent processes
    $sshAgents = Get-Process ssh-agent -ErrorAction SilentlyContinue
    if ($sshAgents) {
        Write-Host "Stopping SSH agent processes..."
        foreach ($agent in $sshAgents) {
            Stop-Process -Id $agent.Id -Force
            Write-Host "Stopped SSH agent with PID: $($agent.Id)"
        }
    } else {
        Write-Host "No running SSH agent processes found."
    }

    # Clear SSH-related environment variables
    $envVars = @('SSH_AUTH_SOCK', 'SSH_AGENT_PID')
    foreach ($var in $envVars) {
        if (Test-Path env:$var) {
            Remove-Item env:$var
            Write-Host "Cleared environment variable: $var"
        }
        [System.Environment]::SetEnvironmentVariable($var, $null, [System.EnvironmentVariableTarget]::User)
        Write-Host "Removed persistent environment variable: $var"
    }

    # Remove any lingering SSH agent sockets (named pipes in Windows)
    $sshPipes = Get-ChildItem "\\.\pipe\" | Where-Object { $_.Name -like "*ssh-agent*" }
    if ($sshPipes) {
        Write-Host "Removing SSH agent named pipes..."
        foreach ($pipe in $sshPipes) {
            Remove-Item "\\.\pipe\$($pipe.Name)" -Force -ErrorAction SilentlyContinue
            Write-Host "Removed named pipe: $($pipe.Name)"
        }
    } else {
        Write-Host "No SSH agent named pipes found."
    }

    # Clear any loaded identities
    ssh-add -D 2>&1 | Out-Null
    Write-Host "Cleared all identities from SSH agent (if any were loaded)."

    Write-Host "==== SSH Environment Reset Complete ===="
    Write-Host "You can now run Set-SSHEnvironment to set up a fresh SSH environment."
}