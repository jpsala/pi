param(
  [switch]$Status,
  [switch]$NoFooterConfig,
  [switch]$NoPackagePatches
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$AgentDir = if ($env:PI_CODING_AGENT_DIR) { $env:PI_CODING_AGENT_DIR } else { Join-Path $env:USERPROFILE ".pi\agent" }
$FooterSource = Join-Path $RepoRoot "pi-extensions\pi-footer.json"
$FooterTarget = Join-Path $AgentDir "extensions\pi-footer.json"
$FooterPackageTarget = Join-Path $AgentDir "npm\node_modules\pi-footer\src\index.ts"
$ChromeTarget = Join-Path $AgentDir "npm\node_modules\pi-chrome\extensions\chrome-profile-bridge\index.ts"
$UsageTarget = Join-Path $AgentDir "npm\node_modules\@calesennett\pi-codex-usage\src\codex-usage\format.ts"
$UsageExtensionTarget = Join-Path $AgentDir "npm\node_modules\@calesennett\pi-codex-usage\extensions\codex-usage-status.ts"

function Show-Status {
  Write-Host "Repo:         $RepoRoot"
  Write-Host "Pi agent dir: $AgentDir"
  Write-Host "Footer src:   $FooterSource"
  Write-Host "Footer dst:   $FooterTarget"
  Write-Host "pi-footer:    $FooterPackageTarget"
  Write-Host "pi-chrome:    $ChromeTarget"
  Write-Host "codex-usage:  $UsageTarget"
  Write-Host "codex-ext:    $UsageExtensionTarget"
  Write-Host ""
  foreach ($path in @($FooterSource, $FooterTarget, $FooterPackageTarget, $ChromeTarget, $UsageTarget, $UsageExtensionTarget)) {
    if (Test-Path $path) { Write-Host "ok      $path" } else { Write-Host "missing $path" }
  }
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

function Patch-CodexUsageExtension {
  $importReplacement = @'
import { formatCompactStatus, formatStatus, unavailableStatus } from "../src/codex-usage/format";
'@
  $constReplacement = @'
const EXTENSION_ID = "codex-usage";
const COMPACT_EXTENSION_ID = `${EXTENSION_ID}.compact`;
'@
  $stopReplacement = @'
	private stop(ctx: ExtensionContext): void {
		if (this.timer) clearInterval(this.timer);
		this.timer = undefined;
		this.queued = undefined;
		this.ctx = undefined;
		this.generation++;
		if (ctx.hasUI) {
			ctx.ui.setStatus(EXTENSION_ID, undefined);
			ctx.ui.setStatus(COMPACT_EXTENSION_ID, undefined);
		}
	}

	private enqueuePreferenceOperation
'@
  $refreshReplacement = @'
	private async refresh(ctx = this.ctx, modelId = ctx?.model?.id, generation = this.generation): Promise<void> {
		if (!ctx?.hasUI || !this.isCurrent(generation)) return;

		if (this.inFlight) {
			this.queued = { ctx, generation, modelId };
			return;
		}

		this.inFlight = true;
		try {
			const usage = await getUsage(modelId);
			if (!this.isCurrent(generation)) return;
			this.lastUsage = usage;
			ctx.ui.setStatus(EXTENSION_ID, "");
			ctx.ui.setStatus(COMPACT_EXTENSION_ID, formatCompactStatus(ctx, usage, this.preferences));
		} catch (error) {
			if (!this.isCurrent(generation)) return;
			if (errorMessage(error).includes(MISSING_AUTH_ERROR)) {
				this.lastUsage = undefined;
				ctx.ui.setStatus(EXTENSION_ID, undefined);
				ctx.ui.setStatus(COMPACT_EXTENSION_ID, undefined);
			} else {
				ctx.ui.setStatus(EXTENSION_ID, unavailableStatus(ctx, modelId));
				ctx.ui.setStatus(COMPACT_EXTENSION_ID, undefined);
			}
		} finally {
			this.inFlight = false;
			const queued = this.queued;
			this.queued = undefined;
			if (queued && this.isCurrent(queued.generation)) void this.refresh(queued.ctx, queued.modelId, queued.generation);
		}
	}

	private renderLast
'@
  $renderLastReplacement = @'
	private renderLast(ctx: ExtensionContext): boolean {
		if (!ctx.hasUI || !this.lastUsage) return false;
		ctx.ui.setStatus(EXTENSION_ID, "");
		ctx.ui.setStatus(COMPACT_EXTENSION_ID, formatCompactStatus(ctx, this.lastUsage, this.preferences));
		return true;
	}

	private savePreferences
'@

  Replace-Regex $UsageExtensionTarget 'import \{ (?:formatCompactStatus, )?formatStatus, unavailableStatus \} from "\.\./src/codex-usage/format";' $importReplacement "codex-usage import compact formatter"
  Replace-Regex $UsageExtensionTarget 'const EXTENSION_ID = "codex-usage";\r?\n(?:const COMPACT_EXTENSION_ID = `\$\{EXTENSION_ID\}\.compact`;\r?\n?)?' ($constReplacement + "`n") "codex-usage compact status key"
  Replace-Regex $UsageExtensionTarget '(?s)\tprivate stop\(ctx: ExtensionContext\): void \{.*?\r?\n\t\}\r?\n\r?\n\tprivate enqueuePreferenceOperation' $stopReplacement "codex-usage stop clears compact status"
  Replace-Regex $UsageExtensionTarget '(?s)\tprivate async refresh\(ctx = this\.ctx, modelId = ctx\?\.model\?\.id, generation = this\.generation\): Promise<void> \{.*?\r?\n\t\}\r?\n\r?\n\tprivate renderLast' $refreshReplacement "codex-usage compact refresh method"
  Replace-Regex $UsageExtensionTarget '(?s)\tprivate renderLast\(ctx: ExtensionContext\): boolean \{.*?\r?\n\t\}\r?\n\r?\n\tprivate savePreferences' $renderLastReplacement "codex-usage compact renderLast method"
}

function Patch-CodexUsage {
  Patch-CodexUsageExtension

  $percentReplacement = @'
const ACTIVE_DAYS_PER_WEEK = 6;
const WEEK_SECONDS = 7 * 24 * 60 * 60;
const DAY_SECONDS = 24 * 60 * 60;

function clamp(value: number, min: number, max: number): number {
	return Math.min(max, Math.max(min, value));
}

function formatBudgetCushionDays(theme: Theme, usage: UsageSnapshot): string | null {
	const left7d = usage.leftPercent["7d"];
	const reset7d = usage.resetInSeconds["7d"];
	if (left7d === null || reset7d === null || Number.isNaN(reset7d)) return null;

	const used7d = 100 - left7d;
	const elapsedSeconds = clamp(WEEK_SECONDS - reset7d, 0, WEEK_SECONDS);
	const elapsedActiveDays = clamp(elapsedSeconds / DAY_SECONDS, 0, ACTIVE_DAYS_PER_WEEK);
	const expectedUsed = clamp(elapsedActiveDays * (100 / ACTIVE_DAYS_PER_WEEK), 0, 100);
	const dailyBudget = 100 / ACTIVE_DAYS_PER_WEEK;
	const rounded = Math.round(((expectedUsed - used7d) / dailyBudget) * 10) / 10;
	const cushionDays = Object.is(rounded, -0) ? 0 : rounded;
	const color = usage.isLimited || cushionDays <= -0.9 ? "error" : cushionDays <= -0.3 ? "warning" : "success";
	return theme.fg(color, `colchón:${cushionDays > 0 ? "+" : ""}${cushionDays.toFixed(1)}d`);
}

function formatPercent(theme: Theme, leftPercent: number | null, mode: PercentMode): string {
	if (leftPercent === null) return theme.fg("muted", "--");

	const color = leftPercent <= 10 ? "error" : leftPercent <= 25 ? "warning" : "success";
	const displayed = mode === "left" ? leftPercent : 100 - leftPercent;
	return theme.fg(color, `${Math.round(displayed)}% ${mode}`);
}

function formatCompactPercent(theme: Theme, leftPercent: number | null, mode: PercentMode): string {
	if (leftPercent === null) return theme.fg("muted", "--");

	const color = leftPercent <= 10 ? "error" : leftPercent <= 25 ? "warning" : "success";
	const displayed = mode === "left" ? leftPercent : 100 - leftPercent;
	return theme.fg(color, `${Math.round(displayed)}%`);
}

function formatCountdown
'@

  $compactReplacement = @'
export function formatCompactStatus(ctx: ExtensionContext, usage: UsageSnapshot, preferences: Preferences): string {
	const theme = ctx.ui.theme;
	const separator = theme.fg("dim", " · ");
	const usageText = windowNames
		.map(name => `${theme.fg("dim", `${name}:`)}${formatCompactPercent(theme, usage.leftPercent[name], preferences.usageMode)}`)
		.join(separator);
	const cushion = formatBudgetCushionDays(theme, usage);
	const cushionText = cushion ? `${separator}${cushion}` : "";
	const reset = formatCountdown(usage.resetInSeconds[preferences.refreshWindow]);
	const resetText = reset ? `${separator}${theme.fg("dim", `↺${preferences.refreshWindow}:${reset}`)}` : "";
	return `${usageText}${cushionText}${resetText}`;
}

export function unavailableStatus
'@

  Replace-Regex $UsageTarget '(?s)(?:const ACTIVE_DAYS_PER_WEEK = 6;.*?\r?\n\r?\n)?function formatPercent\(theme: Theme, leftPercent: number \| null, mode: PercentMode\): string \{.*?\r?\n\}\r?\n\r?\n(?:function formatCompactPercent\(theme: Theme, leftPercent: number \| null, mode: PercentMode\): string \{.*?\r?\n\}\r?\n\r?\n)?function formatCountdown' $percentReplacement "codex-usage compact percent"
  Replace-Regex $UsageTarget '(?s)(?:export function formatCompactStatus\(ctx: ExtensionContext, usage: UsageSnapshot, preferences: Preferences\): string \{.*?\r?\n\}\r?\n\r?\n)?export function unavailableStatus' $compactReplacement "codex-usage compact status"
}

if ($Status) {
  Show-Status
  exit 0
}

if (!$NoFooterConfig) { Install-FooterConfig }
if (!$NoPackagePatches) {
  Patch-PiFooterPackage
  Patch-PiChrome
  Patch-CodexUsage
}

Write-Host ""
Write-Host "Next step inside Pi: /reload"
