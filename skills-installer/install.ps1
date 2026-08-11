# Batch install Agent Skills - self-contained version (runs directly from GitHub)
#
# One-liner, no repo clone needed:
#   irm https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 | iex
#   (this runs the default "all" mode)
#
# To pick a specific mode, download first then run with a parameter:
#   iwr https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 -OutFile install.ps1
#   .\install.ps1 -Mode frontend
#   .\install.ps1 -Mode backend
#
# Or locally (if you cloned the repo):
#   .\install.ps1 -Mode frontend

param(
    [ValidateSet("all", "frontend", "backend")]
    [string]$Mode = "all"
)

$RawBase = "https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer"
$ManifestUrl = "$RawBase/skills-manifest.json"

# If running as a local file and the manifest sits next to it, use that copy
$ManifestPath = $null
try {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path -ErrorAction Stop
    $LocalManifest = Join-Path $ScriptDir "skills-manifest.json"
    if (Test-Path $LocalManifest) {
        $ManifestPath = $LocalManifest
        Write-Host "Using local manifest: $ManifestPath" -ForegroundColor DarkGray
    }
} catch {
    # Running via iex (no local file) - fine, we will download instead
}

$TempManifest = $null
if (-not $ManifestPath) {
    Write-Host "Downloading manifest from GitHub..." -ForegroundColor DarkGray
    $TempManifest = Join-Path ([System.IO.Path]::GetTempPath()) "skills-manifest-$(Get-Random).json"
    try {
        Invoke-WebRequest -Uri $ManifestUrl -OutFile $TempManifest -UseBasicParsing
        $ManifestPath = $TempManifest
    } catch {
        Write-Host "ERROR: Failed to download manifest: $ManifestUrl" -ForegroundColor Red
        exit 1
    }
}

$Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json

if ($TempManifest -and (Test-Path $TempManifest)) {
    Remove-Item $TempManifest -Force -ErrorAction SilentlyContinue
}

switch ($Mode) {
    "frontend" { $Categories = @("frontend", "shared") }
    "backend"  { $Categories = @("backend", "shared") }
    "all"      { $Categories = @("frontend", "backend", "shared") }
}

$SuccessList = @()
$FailedList = @()
$SkippedList = @()

Write-Host "Starting Skill installation (mode: $Mode)`n" -ForegroundColor Cyan

foreach ($category in $Categories) {
    $items = $Manifest.$category
    foreach ($item in $items) {
        $name = $item.name
        $source = $item.source
        $skill = $item.skill

        if ([string]::IsNullOrEmpty($source) -or $source -eq "null") {
            Write-Host "SKIP (no source defined): $name" -ForegroundColor Yellow
            $SkippedList += $name
            continue
        }

        Write-Host "Installing: $name  (from $source)" -ForegroundColor White

        $agentArgs = @("-g", "-a", "claude-code", "-a", "cursor", "-a", "kiro-cli", "-y")

        if ([string]::IsNullOrEmpty($skill) -or $skill -eq "null") {
            $cmdArgs = @("skills", "add", $source) + $agentArgs
        } else {
            $cmdArgs = @("skills", "add", $source, "--skill", $skill) + $agentArgs
        }

        & npx @cmdArgs
        if ($LASTEXITCODE -eq 0) {
            Write-Host "OK: $name`n" -ForegroundColor Green
            $SuccessList += $name
        } else {
            Write-Host "FAILED: $name (continuing to next item)`n" -ForegroundColor DarkYellow
            $FailedList += $name
        }
    }
}

Write-Host "----------------------------------------"
Write-Host "Installation finished" -ForegroundColor Cyan
Write-Host "Success ($($SuccessList.Count)): $($SuccessList -join ', ')" -ForegroundColor Green
Write-Host "Failed ($($FailedList.Count)): $($FailedList -join ', ')" -ForegroundColor DarkYellow
Write-Host "Skipped/no source ($($SkippedList.Count)): $($SkippedList -join ', ')" -ForegroundColor Yellow