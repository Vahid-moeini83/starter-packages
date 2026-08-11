# نصب دسته‌جمعی Agent Skills — نسخه خودکفا (مستقیم از GitHub)
#
# استفاده مستقیم بدون کلون کردن ریپو (یک‌خطی در PowerShell):
#   irm https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 | iex
#   (این حالت پیش‌فرض "all" را اجرا می‌کند)
#
# برای انتخاب حالت خاص، اول دانلود و بعد با پارامتر اجرا کنید:
#   iwr https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer/install.ps1 -OutFile install.ps1
#   .\install.ps1 -Mode frontend
#   .\install.ps1 -Mode backend
#
# یا به صورت لوکال (اگر ریپو را کلون کرده‌اید):
#   .\install.ps1 -Mode frontend

param(
    [ValidateSet("all", "frontend", "backend")]
    [string]$Mode = "all"
)

$RawBase = "https://raw.githubusercontent.com/Vahid-moeini83/starter-packages/main/skills-installer"
$ManifestUrl = "$RawBase/skills-manifest.json"

# اگر اسکریپت به صورت فایل لوکال اجرا شده و manifest کنارش بود، از همان استفاده کن
$ManifestPath = $null
try {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path -ErrorAction Stop
    $LocalManifest = Join-Path $ScriptDir "skills-manifest.json"
    if (Test-Path $LocalManifest) {
        $ManifestPath = $LocalManifest
        Write-Host "📄 استفاده از manifest محلی: $ManifestPath" -ForegroundColor DarkGray
    }
} catch {
    # اجرا از طریق iex بوده (فایل لوکالی وجود ندارد) — مشکلی نیست، می‌رویم سراغ دانلود
}

$TempManifest = $null
if (-not $ManifestPath) {
    Write-Host "🌐 دانلود manifest از GitHub..." -ForegroundColor DarkGray
    $TempManifest = Join-Path ([System.IO.Path]::GetTempPath()) "skills-manifest-$(Get-Random).json"
    try {
        Invoke-WebRequest -Uri $ManifestUrl -OutFile $TempManifest -UseBasicParsing
        $ManifestPath = $TempManifest
    } catch {
        Write-Host "❌ دانلود manifest ناموفق بود: $ManifestUrl" -ForegroundColor Red
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

Write-Host "🚀 شروع نصب Skill ها (حالت: $Mode)`n" -ForegroundColor Cyan

foreach ($category in $Categories) {
    $items = $Manifest.$category
    foreach ($item in $items) {
        $name = $item.name
        $source = $item.source
        $skill = $item.skill

        if ([string]::IsNullOrEmpty($source) -or $source -eq "null") {
            Write-Host "⏭  رد شد (source مشخص نیست): $name" -ForegroundColor Yellow
            $SkippedList += $name
            continue
        }

        Write-Host "📦 در حال نصب: $name  (از $source)" -ForegroundColor White

        $agentArgs = @("-g", "-a", "claude-code", "-a", "cursor", "-a", "kiro-cli", "-y")

        if ([string]::IsNullOrEmpty($skill) -or $skill -eq "null") {
            $cmdArgs = @("skills", "add", $source) + $agentArgs
        } else {
            $cmdArgs = @("skills", "add", $source, "--skill", $skill) + $agentArgs
        }

        & npx @cmdArgs
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ موفق: $name`n" -ForegroundColor Green
            $SuccessList += $name
        } else {
            Write-Host "⚠️  ناموفق: $name (ادامه به مورد بعدی)`n" -ForegroundColor DarkYellow
            $FailedList += $name
        }
    }
}

Write-Host "----------------------------------------"
Write-Host "🎉 پایان نصب" -ForegroundColor Cyan
Write-Host "✅ موفق ($($SuccessList.Count)): $($SuccessList -join ', ')" -ForegroundColor Green
Write-Host "⚠️  ناموفق ($($FailedList.Count)): $($FailedList -join ', ')" -ForegroundColor DarkYellow
Write-Host "⏭  رد شده/بدون source ($($SkippedList.Count)): $($SkippedList -join ', ')" -ForegroundColor Yellow
