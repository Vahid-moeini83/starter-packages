# Interactive Skills Installer (PowerShell)
#
# Flow:
#   1. Ask which area to install (Frontend / Backend / Both)
#   2. Show a checkbox list of skills for that area (+ shared skills),
#      grouped visually with separators
#   3. Confirm selection
#   4. Install only the selected skills
#
# Usage (self-contained, run directly from GitHub):
#   iwr https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 -OutFile install.ps1
#   .\install.ps1
#
# Or locally (if you cloned the repo):
#   .\install.ps1

$RawBase = "https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer"
$ManifestUrl = "$RawBase/skills-manifest.json"

# ---- Load manifest (local copy if present, otherwise download) ----

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

# ---- Step 1: choose area ----

function Show-AreaMenu {
    $options = @("Frontend", "Backend", "Both (Frontend + Backend)")
    $selectedIndex = 0

    while ($true) {
        Clear-Host
        Write-Host "Which area do you want to install skills for?`n" -ForegroundColor Cyan
        for ($i = 0; $i -lt $options.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "  > $($options[$i])" -ForegroundColor Green
            } else {
                Write-Host "    $($options[$i])"
            }
        }
        Write-Host "`n(Use Up/Down arrows, Enter to confirm)" -ForegroundColor DarkGray

        $key = [System.Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow"   { $selectedIndex = [Math]::Max(0, $selectedIndex - 1) }
            "DownArrow" { $selectedIndex = [Math]::Min($options.Count - 1, $selectedIndex + 1) }
            "Enter"     { return $selectedIndex }
        }
    }
}

$areaIndex = Show-AreaMenu
switch ($areaIndex) {
    0 { $Categories = @("frontend") ; $AreaLabel = "Frontend" }
    1 { $Categories = @("backend")  ; $AreaLabel = "Backend" }
    2 { $Categories = @("frontend", "backend") ; $AreaLabel = "Both (Frontend + Backend)" }
}
# shared is always offered alongside the chosen area(s)
$Categories += "shared"

# ---- Build the flat list of selectable items, with group separators ----

$Items = @()  # each: @{ name; source; skill; group; isSeparator }

foreach ($category in $Categories) {
    $groupLabel = switch ($category) {
        "frontend" { "Frontend" }
        "backend"  { "Backend" }
        "shared"   { "Shared" }
    }
    $Items += [PSCustomObject]@{ isSeparator = $true; group = $groupLabel }

    foreach ($entry in $Manifest.$category) {
        $Items += [PSCustomObject]@{
            isSeparator = $false
            name        = $entry.name
            source      = $entry.source
            skill       = $entry.skill
            group       = $groupLabel
        }
    }
}

$SelectableIndexes = @()
for ($i = 0; $i -lt $Items.Count; $i++) {
    if (-not $Items[$i].isSeparator) { $SelectableIndexes += $i }
}
$Checked = @{}
foreach ($idx in $SelectableIndexes) { $Checked[$idx] = $false }

# ---- Step 2: checkbox list with separators ----

function Show-SkillCheckboxMenu {
    param($Items, $SelectableIndexes, $Checked, $AreaLabel)

    $cursor = $SelectableIndexes[0]

    while ($true) {
        Clear-Host
        Write-Host "Area: $AreaLabel" -ForegroundColor Cyan
        Write-Host "Select skills to install (Space to toggle, Enter to confirm, A to toggle all)`n" -ForegroundColor Cyan

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $item = $Items[$i]
            if ($item.isSeparator) {
                Write-Host "`n-- $($item.group) --" -ForegroundColor Yellow
                continue
            }
            $mark = if ($Checked[$i]) { "[x]" } else { "[ ]" }
            $prefix = if ($i -eq $cursor) { ">" } else { " " }
            $noSourceTag = if ([string]::IsNullOrEmpty($item.source) -or $item.source -eq "null") { " (no source yet)" } else { "" }
            $color = if ($i -eq $cursor) { "Green" } else { "White" }
            Write-Host "$prefix $mark $($item.name)$noSourceTag" -ForegroundColor $color
        }

        $key = [System.Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" {
                do {
                    $pos = [Array]::IndexOf($SelectableIndexes, $cursor)
                    $pos = [Math]::Max(0, $pos - 1)
                    $cursor = $SelectableIndexes[$pos]
                } while ($false)
            }
            "DownArrow" {
                $pos = [Array]::IndexOf($SelectableIndexes, $cursor)
                $pos = [Math]::Min($SelectableIndexes.Count - 1, $pos + 1)
                $cursor = $SelectableIndexes[$pos]
            }
            "Spacebar" {
                $Checked[$cursor] = -not $Checked[$cursor]
            }
            { $_ -eq "A" } {
                $allChecked = -not ($Checked.Values -contains $false)
                foreach ($idx in $SelectableIndexes) { $Checked[$idx] = -not $allChecked }
            }
            "Enter" {
                return $Checked
            }
        }
    }
}

$Checked = Show-SkillCheckboxMenu -Items $Items -SelectableIndexes $SelectableIndexes -Checked $Checked -AreaLabel $AreaLabel

$SelectedItems = @()
foreach ($idx in $SelectableIndexes) {
    if ($Checked[$idx]) { $SelectedItems += $Items[$idx] }
}

Clear-Host

if ($SelectedItems.Count -eq 0) {
    Write-Host "No skills selected. Nothing to install." -ForegroundColor Yellow
    exit 0
}

# ---- Step 3: confirm ----

Write-Host "You selected the following skills:`n" -ForegroundColor Cyan
foreach ($item in $SelectedItems) {
    Write-Host "  - $($item.name)  [$($item.group)]"
}

$confirm = Read-Host "`nProceed with installation? (Y/n)"
if ($confirm -and $confirm.ToUpper() -ne "Y") {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

# ---- Step 4: install ----

$SuccessList = @()
$FailedList = @()
$SkippedList = @()

Write-Host "`nStarting installation...`n" -ForegroundColor Cyan

foreach ($item in $SelectedItems) {
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

Write-Host "----------------------------------------"
Write-Host "Installation finished" -ForegroundColor Cyan
Write-Host "Success ($($SuccessList.Count)): $($SuccessList -join ', ')" -ForegroundColor Green
Write-Host "Failed ($($FailedList.Count)): $($FailedList -join ', ')" -ForegroundColor DarkYellow
Write-Host "Skipped/no source ($($SkippedList.Count)): $($SkippedList -join ', ')" -ForegroundColor Yellow