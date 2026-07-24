param(
  [switch]$Status,
  [switch]$NoFooterConfig,
  [switch]$NoUsageConfig,
  [switch]$NoPackagePatches
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$AgentDir = if ($env:PI_CODING_AGENT_DIR) { $env:PI_CODING_AGENT_DIR } else { Join-Path $env:USERPROFILE ".pi\agent" }
$FooterSource = Join-Path $RepoRoot "pi-extensions\pi-footer.json"
$FooterTarget = Join-Path $AgentDir "extensions\pi-footer.json"
$UsageSource = Join-Path $RepoRoot "pi-extensions\pi-openai-usage.json"
$UsageTarget = Join-Path $AgentDir "extensions\pi-openai-usage.json"
$UsagePackageRoot = Join-Path $AgentDir "npm\node_modules\pi-openai-usage"
$UsagePackageJson = Join-Path $UsagePackageRoot "package.json"
$UsageSnapshotTarget = Join-Path $UsagePackageRoot "src\usage-snapshot.ts"
$UsageFormatTarget = Join-Path $UsagePackageRoot "src\format.ts"
$UsageMarginPatch = Join-Path $RepoRoot "pi-extensions\patches\pi-openai-usage-0.1.3-weekly-margin.patch"
$FooterPackageTarget = Join-Path $AgentDir "npm\node_modules\pi-footer\src\index.ts"
$ChromeTarget = Join-Path $AgentDir "npm\node_modules\pi-chrome\extensions\chrome-profile-bridge\index.ts"

function Get-UsageStatusKey([string]$Path) {
  if (!(Test-Path $Path)) { return $null }
  $config = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
  foreach ($line in $config.lines) {
    foreach ($widget in $line) {
      if ($widget.id -eq "jp-openai-usage") {
        return [string]$widget.options.externalStatusKey
      }
    }
  }
  return $null
}

function Invoke-UsageMarginGitApply([switch]$Reverse, [switch]$Check) {
  $arguments = @("apply")
  if ($Reverse) { $arguments += "--reverse" }
  if ($Check) { $arguments += "--check" }
  $arguments += $UsageMarginPatch

  $previousErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    & git @arguments 2>&1 | Out-Null
    return $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }
}

function Test-UsageMarginPatch {
  if (!(Test-Path $UsagePackageRoot) -or !(Test-Path $UsageMarginPatch)) { return $false }
  Push-Location $UsagePackageRoot
  try {
    return (Invoke-UsageMarginGitApply -Reverse -Check) -eq 0
  } finally {
    Pop-Location
  }
}

function Show-Status {
  $ok = $true
  Write-Host "Repo:         $RepoRoot"
  Write-Host "Pi agent dir: $AgentDir"
  Write-Host "Footer src:   $FooterSource"
  Write-Host "Footer dst:   $FooterTarget"
  Write-Host "Usage src:    $UsageSource"
  Write-Host "Usage dst:    $UsageTarget"
  Write-Host "Usage pkg:    $UsagePackageRoot"
  Write-Host "Margin patch: $UsageMarginPatch"
  Write-Host "pi-footer:    $FooterPackageTarget"
  Write-Host "pi-chrome:    $ChromeTarget"
  Write-Host ""
  foreach ($path in @($FooterSource, $FooterTarget, $UsageSource, $UsageTarget, $UsagePackageJson, $UsageSnapshotTarget, $UsageFormatTarget, $UsageMarginPatch, $FooterPackageTarget, $ChromeTarget)) {
    if (Test-Path $path) {
      Write-Host "ok      $path"
    } else {
      Write-Host "missing $path"
      $ok = $false
    }
  }

  $sourceKey = Get-UsageStatusKey $FooterSource
  $targetKey = Get-UsageStatusKey $FooterTarget
  if ($sourceKey -eq "openai-usage") {
    Write-Host "ok      canonical usage key: openai-usage"
  } else {
    Write-Host "drift   canonical usage key: $sourceKey"
    $ok = $false
  }
  if ($targetKey -eq $sourceKey -and $targetKey) {
    Write-Host "ok      installed usage key: $targetKey"
  } else {
    Write-Host "drift   installed usage key: $targetKey (expected $sourceKey)"
    $ok = $false
  }
  if (Test-Path $UsagePackageJson) {
    $usagePackageVersion = (Get-Content -LiteralPath $UsagePackageJson -Raw | ConvertFrom-Json).version
    if ($usagePackageVersion -eq "0.1.3") {
      Write-Host "ok      pi-openai-usage version: $usagePackageVersion"
    } else {
      Write-Host "drift   pi-openai-usage version: $usagePackageVersion (expected 0.1.3)"
      $ok = $false
    }
  }
  if (Test-UsageMarginPatch) {
    Write-Host "ok      weekly margin patch is applied"
  } else {
    Write-Host "drift   weekly margin patch is missing"
    $ok = $false
  }
  if ((Test-Path $FooterSource) -and (Test-Path $FooterTarget)) {
    $sourceContent = Get-Content -LiteralPath $FooterSource -Raw
    $targetContent = Get-Content -LiteralPath $FooterTarget -Raw
    if ($sourceContent -ceq $targetContent) {
      Write-Host "ok      footer config is synchronized"
    } else {
      Write-Host "drift   footer config differs from canonical source"
      $ok = $false
    }
  }
  if ((Test-Path $UsageSource) -and (Test-Path $UsageTarget)) {
    $sourceContent = Get-Content -LiteralPath $UsageSource -Raw
    $targetContent = Get-Content -LiteralPath $UsageTarget -Raw
    if ($sourceContent -ceq $targetContent) {
      Write-Host "ok      OpenAI usage config is synchronized"
    } else {
      Write-Host "drift   OpenAI usage config differs from canonical source"
      $ok = $false
    }
  }
  return $ok
}

function Backup-File([string]$Path) {
  if (!(Test-Path $Path)) { return }
  $backup = "$Path.bak-pi-statusline-$(Get-Date -Format yyyyMMdd-HHmmss)"
  Copy-Item $Path $backup -Force
  Write-Host "backup  $backup"
}

function Replace-Regex([string]$Path, [string]$Pattern, [string]$Replacement, [string]$Label) {
  if (!(Test-Path $Path)) {
    Write-Warning "$Label skipped: missing $Path"
    return
  }

  $content = Get-Content $Path -Raw
  $next = [regex]::Replace($content, $Pattern, $Replacement, 1)
  if ($next -eq $content) {
    Write-Warning "$Label unchanged: pattern not found or already equivalent in $Path"
    return
  }

  Backup-File $Path
  Set-Content -Path $Path -Value $next -NoNewline -Encoding UTF8
  Write-Host "patched $Label"
}

function Install-FooterConfig {
  if (!(Test-Path $FooterSource)) { throw "Missing source footer config: $FooterSource" }
  New-Item -ItemType Directory -Force (Split-Path -Parent $FooterTarget) | Out-Null
  if (Test-Path $FooterTarget) { Backup-File $FooterTarget }
  Copy-Item $FooterSource $FooterTarget -Force
  Write-Host "copied  pi-footer config"
}

function Install-UsageConfig {
  if (!(Test-Path $UsageSource)) { throw "Missing source usage config: $UsageSource" }
  New-Item -ItemType Directory -Force (Split-Path -Parent $UsageTarget) | Out-Null
  if (Test-Path $UsageTarget) { Backup-File $UsageTarget }
  Copy-Item $UsageSource $UsageTarget -Force
  Write-Host "copied  pi-openai-usage config"
}

function Patch-OpenAIUsageMargin {
  if (!(Test-Path $UsagePackageJson)) { throw "Missing pi-openai-usage package: $UsagePackageRoot" }
  if (!(Test-Path $UsageMarginPatch)) { throw "Missing usage margin patch: $UsageMarginPatch" }
  $usagePackageVersion = (Get-Content -LiteralPath $UsagePackageJson -Raw | ConvertFrom-Json).version
  if ($usagePackageVersion -ne "0.1.3") {
    throw "Unsupported pi-openai-usage version: $usagePackageVersion (expected 0.1.3)"
  }
  if (Test-UsageMarginPatch) {
    Write-Host "ok      weekly margin patch already applied"
    return
  }

  Push-Location $UsagePackageRoot
  try {
    if ((Invoke-UsageMarginGitApply -Check) -ne 0) {
      throw "Usage margin patch does not apply cleanly"
    }
    Backup-File $UsageSnapshotTarget
    Backup-File $UsageFormatTarget
    if ((Invoke-UsageMarginGitApply) -ne 0) { throw "Usage margin patch failed" }
  } finally {
    Pop-Location
  }
  Write-Host "patched pi-openai-usage weekly margin"
}

function Patch-PiFooterPackage {
  $mapReplacement = @'
          )
            .map((entry) => entry.value)
            .filter((value) => !isDuplicateCodexUsageStatus(value));
          const renderedLines = lines.map((line) => truncateToWidth(line, width, "…"));
'@
  $helperReplacement = @'
function isDuplicateCodexUsageStatus(value: string): boolean {
  return /^Codex(?: Spark)?\s+5h\s+\d+%\s+7d\s+\d+%/.test(stripAnsi(value));
}

function stripAnsi(value: string): string {
  // oxlint-disable-next-line no-control-regex
  return value.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
}

function collectStatuslineData(
'@

  Replace-Regex $FooterPackageTarget '(?s)\)\.map\(\(entry\) => entry\.value\);\r?\n\s+const renderedLines = lines\.map\(\(line\) => truncateToWidth\(line, width, "…"\)\);|\)\r?\n\s+\.map\(\(entry\) => entry\.value\)\r?\n\s+\.filter\(\(value\) => !isDuplicateCodexUsageStatus\(value\)\);\r?\n\s+const renderedLines = lines\.map\(\(line\) => truncateToWidth\(line, width, "…"\)\);' $mapReplacement "pi-footer filter duplicate Codex usage row"
  Replace-Regex $FooterPackageTarget '(?s)(?:function isDuplicateCodexUsageStatus\(value: string\): boolean \{.*?\r?\n\}\r?\n\r?\nfunction stripAnsi\(value: string\): string \{.*?\r?\n\}\r?\n\r?\n)?function collectStatuslineData\(' $helperReplacement "pi-footer duplicate Codex usage helper"
}

function Patch-PiChrome {
  $authReplacement = @'
	const authCountdownLabel = (): string => {
		if (chromeAuthorizedUntil === "indefinite") return ":∞";
		if (typeof chromeAuthorizedUntil === "number") {
			const remainingMs = chromeAuthorizedUntil - Date.now();
			if (remainingMs > 0) {
				const mins = Math.ceil(remainingMs / 60_000);
				return mins >= 1 ? `:${mins}m` : ":<1m";
			}
		}
		return "";
	};
'@

  $statusReplacement = @'
	const updateChromeStatus = (ctx: ExtensionContext): void => {
		if (chromeControlAuthorized()) {
			ctx.ui.setStatus("chrome", ctx.ui.theme.fg("success", "chrome" + authCountdownLabel()));
		} else {
			ctx.ui.setStatus("chrome", undefined);
		}
	};
'@

  Replace-Regex $ChromeTarget '(?s)\tconst authCountdownLabel = \(\): string => \{.*?\r?\n\t\};' $authReplacement "pi-chrome compact auth label"
  Replace-Regex $ChromeTarget '(?s)\tconst updateChromeStatus = \(ctx: ExtensionContext\): void => \{.*?\r?\n\t\};' $statusReplacement "pi-chrome compact status"
}

if ($Status) {
  if (Show-Status) { exit 0 }
  exit 1
}

if (!$NoFooterConfig) { Install-FooterConfig }
if (!$NoUsageConfig) { Install-UsageConfig }
if (!$NoPackagePatches) {
  Patch-OpenAIUsageMargin
  Patch-PiFooterPackage
  Patch-PiChrome
}

Write-Host ""
Write-Host "Next step inside Pi: /reload"
