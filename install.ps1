# mroc installer for Windows
# Usage: irm https://raw.githubusercontent.com/yusufgurdogan/mroc/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$repo = "yusufgurdogan/mroc"
$binary = "mroc"

Write-Host ""
Write-Host "  _ __ ___  _ __ ___   ___ "
Write-Host " | '_ `` _ \| '__/ _ \ / __|"
Write-Host " | | | | | | | | (_) | (__ "
Write-Host " |_| |_| |_|_|  \___/ \___|"
Write-Host ""
Write-Host " Secure file transfer"
Write-Host ""

# Detect architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "64bit" } else { "32bit" }
Write-Host "Detecting system..."
Write-Host "  OS: Windows"
Write-Host "  Arch: $arch"

# Get latest version
Write-Host "Fetching latest version..."
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"
$version = $release.tag_name
Write-Host "  Version: $version"

# Download
$fileName = "${binary}_${version}_Windows-${arch}.zip"
$url = "https://github.com/$repo/releases/download/$version/$fileName"
$tempDir = Join-Path $env:TEMP "mroc-install"
$zipPath = Join-Path $tempDir $fileName

Write-Host "Downloading $binary..."
Write-Host "  URL: $url"

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

Invoke-WebRequest -Uri $url -OutFile $zipPath

# Extract
Write-Host "Extracting..."
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

# Install to user's local bin
$installDir = Join-Path $env:USERPROFILE ".local\bin"
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

$exePath = Join-Path $tempDir "$binary.exe"
$destPath = Join-Path $installDir "$binary.exe"
Move-Item -Path $exePath -Destination $destPath -Force

# Cleanup
Remove-Item $tempDir -Recurse -Force

Write-Host ""
Write-Host "Successfully installed $binary $version!" -ForegroundColor Green
Write-Host ""
Write-Host "Installed to: $destPath"
Write-Host ""

# Check if in PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$installDir*") {
    Write-Host "Adding to PATH..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$installDir", "User")
    Write-Host "Added $installDir to your PATH."
    Write-Host ""
    Write-Host "Please restart your terminal, then run: mroc --help" -ForegroundColor Yellow
} else {
    Write-Host "Run 'mroc --help' to get started."
}
Write-Host ""
