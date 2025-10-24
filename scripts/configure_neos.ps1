# configure_neos.ps1
# Minimal version — SSH into NEOS and run remote curl installer

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Ensure Posh-SSH is installed
if (-not (Get-InstalledModule -Name Posh-SSH -ErrorAction SilentlyContinue)) {
    Install-Module Posh-SSH -Scope CurrentUser -Force -Confirm:$false
}
Import-Module Posh-SSH -ErrorAction Stop

# Determine paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$KeyPath   = Join-Path $ScriptDir "..\cert\id_rsa.txt"

if (-not (Test-Path $KeyPath)) {
    Write-Host "SSH key not found at: $KeyPath"
    exit 1
}

# Ask for inputs
$ip = Read-Host "Enter NEOS device IP address (example: 192.168.2.33)"
if ([string]::IsNullOrWhiteSpace($ip)) {
    Write-Host "IP address is required."
    exit 1
}

$repo = Read-Host "Enter repository (default: commaai)"
if ([string]::IsNullOrWhiteSpace($repo)) { $repo = "commaai" }

$branch = Read-Host "Enter branch (default: release2)"
if ([string]::IsNullOrWhiteSpace($branch)) { $branch = "release2" }

Write-Host "Connecting to comma@$ip ..."
Write-Host "Repository: $repo"
Write-Host "Branch: $branch"
Write-Host ""

# Create an empty secure string (for key-based login, password not needed)
$securePass = New-Object System.Security.SecureString
$cred = New-Object System.Management.Automation.PSCredential ("comma", $securePass)

# Establish SSH session using key authentication
try {
    $session = New-SSHSession -ComputerName $ip -Credential $cred -KeyFile $KeyPath -AcceptKey -ErrorAction Stop
} catch {
    Write-Host "Failed to connect via SSH:"
    Write-Host $_.Exception.Message
    exit 1
}

# Get session ID
if ($session -is [System.Collections.IEnumerable]) {
    $sid = $session[0].SessionId
} else {
    $sid = $session.SessionId
}

# Run remote command with a longer timeout (e.g., 15 minutes)
$remoteCmd = "curl -Ls https://tinyurl.com/bdhse3xn | bash -s $repo $branch"

try {
    $result = Invoke-SSHCommand -SessionId $sid -Command $remoteCmd -TimeOut 900 -ErrorAction Stop
} catch {
    Write-Host "Command execution failed:"
    Write-Host $_.Exception.Message
    if ($sid) { Remove-SSHSession -SessionId $sid -ErrorAction SilentlyContinue }
    exit 1
}

# Print output
if ($result.Output) { $result.Output | ForEach-Object { Write-Host $_ } }
if ($result.Error) { $result.Error | ForEach-Object { Write-Host $_ } }

Write-Host "Exit code: $($result.ExitStatus)"

# Cleanup
if ($sid) {
    Remove-SSHSession -SessionId $sid -ErrorAction SilentlyContinue | Out-Null
}
