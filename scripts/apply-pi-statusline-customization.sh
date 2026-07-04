#!/usr/bin/env bash
set -euo pipefail

show_status=0
no_footer_config=0
no_package_patches=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status|-Status)
      show_status=1
      ;;
    --no-footer-config|-NoFooterConfig)
      no_footer_config=1
      ;;
    --no-package-patches|-NoPackagePatches)
      no_package_patches=1
      ;;
    -h|--help)
      cat <<'HELP'
Usage: scripts/apply-pi-statusline-customization.sh [--status] [--no-footer-config] [--no-package-patches]

Applies JP's compact Pi statusline configuration on Linux/macOS hosts.
Uses PI_CODING_AGENT_DIR when set, otherwise ~/.pi/agent.
HELP
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
  shift
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
agent_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"

footer_source="$repo_root/pi-extensions/pi-footer.json"
footer_target="$agent_dir/extensions/pi-footer.json"
footer_package_target="$agent_dir/npm/node_modules/pi-footer/src/index.ts"
chrome_target="$agent_dir/npm/node_modules/pi-chrome/extensions/chrome-profile-bridge/index.ts"
usage_target="$agent_dir/npm/node_modules/@calesennett/pi-codex-usage/src/codex-usage/format.ts"
usage_extension_target="$agent_dir/npm/node_modules/@calesennett/pi-codex-usage/extensions/codex-usage-status.ts"

show_status_fn() {
  echo "Repo:         $repo_root"
  echo "Pi agent dir: $agent_dir"
  echo "Footer src:   $footer_source"
  echo "Footer dst:   $footer_target"
  echo "pi-footer:    $footer_package_target"
  echo "pi-chrome:    $chrome_target"
  echo "codex-usage:  $usage_target"
  echo "codex-ext:    $usage_extension_target"
  echo
  for path in "$footer_source" "$footer_target" "$footer_package_target" "$chrome_target" "$usage_target" "$usage_extension_target"; do
    if [[ -e "$path" ]]; then
      echo "ok      $path"
    else
      echo "missing $path"
    fi
  done
}

backup_file() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  local backup="$path.bak-pi-statusline-$(date +%Y%m%d-%H%M%S)"
  cp -f -- "$path" "$backup"
  echo "backup  $backup"
}

if [[ "$show_status" -eq 1 ]]; then
  show_status_fn
  exit 0
fi

if [[ "$no_footer_config" -eq 0 ]]; then
  if [[ ! -f "$footer_source" ]]; then
    echo "Missing source footer config: $footer_source" >&2
    exit 1
  fi
  mkdir -p -- "$(dirname -- "$footer_target")"
  backup_file "$footer_target"
  cp -f -- "$footer_source" "$footer_target"
  echo "copied  pi-footer config"
fi

if [[ "$no_package_patches" -eq 1 ]]; then
  echo
  echo "Next step inside Pi: /reload"
  exit 0
fi

export FOOTER_PACKAGE_TARGET="$footer_package_target"
export CHROME_TARGET="$chrome_target"
export USAGE_TARGET="$usage_target"
export USAGE_EXTENSION_TARGET="$usage_extension_target"

python3 <<'PY'
import os
import re
import shutil
import time
from pathlib import Path


def backup(path: Path) -> None:
    if not path.exists():
        return
    stamp = time.strftime("%Y%m%d-%H%M%S")
    target = path.with_name(path.name + f".bak-pi-statusline-{stamp}")
    shutil.copy2(path, target)
    print(f"backup  {target}")


def replace_regex(path_value: str, pattern: str, replacement: str, label: str) -> None:
    path = Path(path_value)
    if not path.exists():
        print(f"warning {label} skipped: missing {path}")
        return
    content = path.read_text(encoding="utf-8")
    next_content, count = re.subn(pattern, lambda _match: replacement, content, count=1, flags=re.S)
    if count == 0 or next_content == content:
        print(f"warning {label} unchanged: pattern not found or already equivalent in {path}")
        return
    backup(path)
    path.write_text(next_content, encoding="utf-8")
    print(f"patched {label}")

footer_package = os.environ["FOOTER_PACKAGE_TARGET"]
chrome = os.environ["CHROME_TARGET"]
usage = os.environ["USAGE_TARGET"]
usage_ext = os.environ["USAGE_EXTENSION_TARGET"]

footer_map_replacement = '''          )
            .map((entry) => entry.value)
            .filter((value) => !isDuplicateCodexUsageStatus(value));
          const renderedLines = lines.map((line) => truncateToWidth(line, width, "…"));'''
footer_helper_replacement = r'''function isDuplicateCodexUsageStatus(value: string): boolean {
  return /^Codex(?: Spark)?\s+5h\s+\d+%\s+7d\s+\d+%/.test(stripAnsi(value));
}

function stripAnsi(value: string): string {
  // oxlint-disable-next-line no-control-regex
  return value.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
}

function collectStatuslineData('''
replace_regex(
    footer_package,
    r'''\)\.map\(\(entry\) => entry\.value\);\r?\n\s+const renderedLines = lines\.map\(\(line\) => truncateToWidth\(line, width, "…"\)\);|\)\r?\n\s+\.map\(\(entry\) => entry\.value\)\r?\n\s+\.filter\(\(value\) => !isDuplicateCodexUsageStatus\(value\)\);\r?\n\s+const renderedLines = lines\.map\(\(line\) => truncateToWidth\(line, width, "…"\)\);''',
    footer_map_replacement,
    "pi-footer filter duplicate Codex usage row",
)
replace_regex(
    footer_package,
    r'''(?:function isDuplicateCodexUsageStatus\(value: string\): boolean \{.*?\r?\n\}\r?\n\r?\nfunction stripAnsi\(value: string\): string \{.*?\r?\n\}\r?\n\r?\n)?function collectStatuslineData\(''',
    footer_helper_replacement,
    "pi-footer duplicate Codex usage helper",
)

chrome_auth_replacement = '''\tconst authCountdownLabel = (): string => {
\t\tif (chromeAuthorizedUntil === "indefinite") return ":∞";
\t\tif (typeof chromeAuthorizedUntil === "number") {
\t\t\tconst remainingMs = chromeAuthorizedUntil - Date.now();
\t\t\tif (remainingMs > 0) {
\t\t\t\tconst mins = Math.ceil(remainingMs / 60_000);
\t\t\t\treturn mins >= 1 ? `:${mins}m` : ":<1m";
\t\t\t}
\t\t}
\t\treturn "";
\t};'''
chrome_status_replacement = '''\tconst updateChromeStatus = (ctx: ExtensionContext): void => {
\t\tif (chromeControlAuthorized()) {
\t\t\tctx.ui.setStatus("chrome", ctx.ui.theme.fg("success", "chrome" + authCountdownLabel()));
\t\t} else {
\t\t\tctx.ui.setStatus("chrome", undefined);
\t\t}
\t};'''
replace_regex(chrome, r'''\tconst authCountdownLabel = \(\): string => \{.*?\r?\n\t\};''', chrome_auth_replacement, "pi-chrome compact auth label")
replace_regex(chrome, r'''\tconst updateChromeStatus = \(ctx: ExtensionContext\): void => \{.*?\r?\n\t\};''', chrome_status_replacement, "pi-chrome compact status")

usage_ext_import_replacement = '''import { formatCompactStatus, formatStatus, unavailableStatus } from "../src/codex-usage/format";'''
usage_ext_const_replacement = '''const EXTENSION_ID = "codex-usage";
const COMPACT_EXTENSION_ID = `${EXTENSION_ID}.compact`;'''
usage_ext_stop_replacement = '''\tprivate stop(ctx: ExtensionContext): void {
\t\tif (this.timer) clearInterval(this.timer);
\t\tthis.timer = undefined;
\t\tthis.queued = undefined;
\t\tthis.ctx = undefined;
\t\tthis.generation++;
\t\tif (ctx.hasUI) {
\t\t\tctx.ui.setStatus(EXTENSION_ID, undefined);
\t\t\tctx.ui.setStatus(COMPACT_EXTENSION_ID, undefined);
\t\t}
\t}

\tprivate enqueuePreferenceOperation'''
usage_ext_refresh_replacement = '''\tprivate async refresh(ctx = this.ctx, modelId = ctx?.model?.id, generation = this.generation): Promise<void> {
\t\tif (!ctx?.hasUI || !this.isCurrent(generation)) return;

\t\tif (this.inFlight) {
\t\t\tthis.queued = { ctx, generation, modelId };
\t\t\treturn;
\t\t}

\t\tthis.inFlight = true;
\t\ttry {
\t\t\tconst usage = await getUsage(modelId);
\t\t\tif (!this.isCurrent(generation)) return;
\t\t\tthis.lastUsage = usage;
\t\t\tctx.ui.setStatus(EXTENSION_ID, "");
\t\t\tctx.ui.setStatus(COMPACT_EXTENSION_ID, formatCompactStatus(ctx, usage, this.preferences));
\t\t} catch (error) {
\t\t\tif (!this.isCurrent(generation)) return;
\t\t\tif (errorMessage(error).includes(MISSING_AUTH_ERROR)) {
\t\t\t\tthis.lastUsage = undefined;
\t\t\t\tctx.ui.setStatus(EXTENSION_ID, undefined);
\t\t\t\tctx.ui.setStatus(COMPACT_EXTENSION_ID, undefined);
\t\t\t} else {
\t\t\t\tctx.ui.setStatus(EXTENSION_ID, unavailableStatus(ctx, modelId));
\t\t\t\tctx.ui.setStatus(COMPACT_EXTENSION_ID, undefined);
\t\t\t}
\t\t} finally {
\t\t\tthis.inFlight = false;
\t\t\tconst queued = this.queued;
\t\t\tthis.queued = undefined;
\t\t\tif (queued && this.isCurrent(queued.generation)) void this.refresh(queued.ctx, queued.modelId, queued.generation);
\t\t}
\t}

\tprivate renderLast'''
usage_ext_render_replacement = '''\tprivate renderLast(ctx: ExtensionContext): boolean {
\t\tif (!ctx.hasUI || !this.lastUsage) return false;
\t\tctx.ui.setStatus(EXTENSION_ID, "");
\t\tctx.ui.setStatus(COMPACT_EXTENSION_ID, formatCompactStatus(ctx, this.lastUsage, this.preferences));
\t\treturn true;
\t}

\tprivate savePreferences'''
replace_regex(
    usage_ext,
    r'''import \{ (?:formatCompactStatus, )?formatStatus, unavailableStatus \} from "\.\./src/codex-usage/format";''',
    usage_ext_import_replacement,
    "codex-usage import compact formatter",
)
replace_regex(
    usage_ext,
    r'''const EXTENSION_ID = "codex-usage";\r?\n(?:const COMPACT_EXTENSION_ID = `\$\{EXTENSION_ID\}\.compact`;\r?\n)?''',
    usage_ext_const_replacement + "\n",
    "codex-usage compact status key",
)
replace_regex(
    usage_ext,
    r'''\tprivate stop\(ctx: ExtensionContext\): void \{.*?\r?\n\t\}\r?\n\r?\n\tprivate enqueuePreferenceOperation''',
    usage_ext_stop_replacement,
    "codex-usage stop clears compact status",
)
replace_regex(
    usage_ext,
    r'''\tprivate async refresh\(ctx = this\.ctx, modelId = ctx\?\.model\?\.id, generation = this\.generation\): Promise<void> \{.*?\r?\n\t\}\r?\n\r?\n\tprivate renderLast''',
    usage_ext_refresh_replacement,
    "codex-usage compact refresh method",
)
replace_regex(
    usage_ext,
    r'''\tprivate renderLast\(ctx: ExtensionContext\): boolean \{.*?\r?\n\t\}\r?\n\r?\n\tprivate savePreferences''',
    usage_ext_render_replacement,
    "codex-usage compact renderLast method",
)

usage_percent_replacement = '''function formatPercent(theme: Theme, leftPercent: number | null, mode: PercentMode): string {
\tif (leftPercent === null) return theme.fg("muted", "--");

\tconst color = leftPercent <= 10 ? "error" : leftPercent <= 25 ? "warning" : "success";
\tconst displayed = mode === "left" ? leftPercent : 100 - leftPercent;
\treturn theme.fg(color, `${Math.round(displayed)}% ${mode}`);
}

function formatCompactPercent(theme: Theme, leftPercent: number | null, mode: PercentMode): string {
\tif (leftPercent === null) return theme.fg("muted", "--");

\tconst color = leftPercent <= 10 ? "error" : leftPercent <= 25 ? "warning" : "success";
\tconst displayed = mode === "left" ? leftPercent : 100 - leftPercent;
\treturn theme.fg(color, `${Math.round(displayed)}%`);
}

function formatCountdown'''
usage_compact_replacement = '''export function formatCompactStatus(ctx: ExtensionContext, usage: UsageSnapshot, preferences: Preferences): string {
\tconst theme = ctx.ui.theme;
\tconst separator = theme.fg("dim", " · ");
\tconst usageText = windowNames
\t\t.map(name => `${theme.fg("dim", `${name}:`)}${formatCompactPercent(theme, usage.leftPercent[name], preferences.usageMode)}`)
\t\t.join(separator);
\tconst reset = formatCountdown(usage.resetInSeconds[preferences.refreshWindow]);
\tconst resetText = reset ? `${separator}${theme.fg("dim", `↺${preferences.refreshWindow}:${reset}`)}` : "";
\treturn `${usageText}${resetText}`;
}

export function unavailableStatus'''
replace_regex(
    usage,
    r'''function formatPercent\(theme: Theme, leftPercent: number \| null, mode: PercentMode\): string \{.*?\r?\n\}\r?\n\r?\n(?:function formatCompactPercent\(theme: Theme, leftPercent: number \| null, mode: PercentMode\): string \{.*?\r?\n\}\r?\n\r?\n)?function formatCountdown''',
    usage_percent_replacement,
    "codex-usage compact percent",
)
replace_regex(
    usage,
    r'''(?:export function formatCompactStatus\(ctx: ExtensionContext, usage: UsageSnapshot, preferences: Preferences\): string \{.*?\r?\n\}\r?\n\r?\n)?export function unavailableStatus''',
    usage_compact_replacement,
    "codex-usage compact status",
)
PY

echo
echo "Next step inside Pi: /reload"
