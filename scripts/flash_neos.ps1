# Determine script directory and files folder path
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FilesDir = Join-Path $ScriptDir "..\files"

# Check if 'fastboot' exists in PATH
$fastboot = Get-Command fastboot -ErrorAction SilentlyContinue

if (-not $fastboot) {
    Write-Host "Fastboot not found. Please install Android Platform Tools and ensure it's in your PATH." -ForegroundColor Red
    exit 1
}

# boot.img = https://mega.nz/file/aUUTQSJL#nJauYOIbKwWFVp3MGjqqdxiY36ccwTxQFWsUMfxz-_s
# recovery.img = https://mega.nz/file/mN12DRzL#139jBwBAKxxtFlFARI-nLSWzK54VKc9-fWFWunnRFlY
# system.img = https://mega.nz/file/yUkRQLKT#e3A72hE7H584zhxNy5CWiJGKBBHNnvK2tZu3uPonxj4


# Get fastboot path (unquoted)
$fastbootPath = $fastboot.Source

# Verify required files exist
$RequiredFiles = @("boot.img", "recovery.img", "system.img")
$MissingFiles = @()

foreach ($file in $RequiredFiles) {
    $path = Join-Path $FilesDir $file
    if (-not (Test-Path $path)) {
        $MissingFiles += $file
    }
}

if ($MissingFiles.Count -gt 0) {
    Write-Host "The following required files are missing in '$FilesDir':" -ForegroundColor Red
    $MissingFiles | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
    exit 1
}

Write-Host "All required image files found in '$FilesDir'." -ForegroundColor Green
Write-Host ""

# Check for connected devices
Write-Host "Checking for fastboot devices..." -ForegroundColor Cyan
$devices = & "$fastbootPath" devices 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error running 'fastboot devices':" -ForegroundColor Red
    Write-Host $devices -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($devices)) {
    Write-Host "Fastboot is working, but no devices are detected." -ForegroundColor Yellow
    exit 1
}

Write-Host "Fastboot is working and device detected:" -ForegroundColor Green
Write-Host $devices -ForegroundColor Green
Write-Host ""

# Ask for confirmation before flashing
$confirmation = Read-Host "Do you want to proceed with flashing the device? (Y/N)"
if ($confirmation -notin @("Y", "y")) {
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Starting flash sequence..." -ForegroundColor Cyan

# Flash images
try {
    & "$fastbootPath" flash recovery "$FilesDir\recovery.img"
    & "$fastbootPath" flash boot "$FilesDir\boot.img"
    & "$fastbootPath" flash system "$FilesDir\system.img"
    
    & "$fastbootPath" erase userdata
    & "$fastbootPath" format cache
    & "$fastbootPath" reboot

    Write-Host ""
    Write-Host "Flashing complete. Device rebooting..." -ForegroundColor Green
}
catch {
    Write-Host "Error during flashing process:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
