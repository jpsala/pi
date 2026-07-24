#!/usr/bin/env bash
set -euo pipefail

show_status=0
no_footer_config=0
no_usage_config=0
no_package_patches=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --status|-Status)
      show_status=1
      ;;
    --no-footer-config|-NoFooterConfig)
      no_footer_config=1
      ;;
    --no-usage-config|-NoUsageConfig)
      no_usage_config=1
      ;;
    --no-package-patches|-NoPackagePatches)
      no_package_patches=1
      ;;
    -h|--help)
      cat <<'HELP'
Usage: scripts/apply-pi-statusline-customization.sh [--status] [--no-footer-config] [--no-usage-config] [--no-package-patches]

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
usage_source="$repo_root/pi-extensions/pi-openai-usage.json"
usage_target="$agent_dir/extensions/pi-openai-usage.json"
usage_package_root="$agent_dir/npm/node_modules/pi-openai-usage"
usage_package_json="$usage_package_root/package.json"
usage_snapshot_target="$usage_package_root/src/usage-snapshot.ts"
usage_format_target="$usage_package_root/src/format.ts"
usage_margin_patch="$repo_root/pi-extensions/patches/pi-openai-usage-0.1.3-weekly-margin.patch"
footer_package_target="$agent_dir/npm/node_modules/pi-footer/src/index.ts"
chrome_target="$agent_dir/npm/node_modules/pi-chrome/extensions/chrome-profile-bridge/index.ts"

show_status_fn() {
  local status=0
  echo "Repo:         $repo_root"
  echo "Pi agent dir: $agent_dir"
  echo "Footer src:   $footer_source"
  echo "Footer dst:   $footer_target"
  echo "Usage src:    $usage_source"
  echo "Usage dst:    $usage_target"
  echo "Usage pkg:    $usage_package_root"
  echo "Margin patch: $usage_margin_patch"
  echo "pi-footer:    $footer_package_target"
  echo "pi-chrome:    $chrome_target"
  echo
  for path in "$footer_source" "$footer_target" "$usage_source" "$usage_target" "$usage_package_json" "$usage_snapshot_target" "$usage_format_target" "$usage_margin_patch" "$footer_package_target" "$chrome_target"; do
    if [[ -e "$path" ]]; then
      echo "ok      $path"
    else
      echo "missing $path"
      status=1
    fi
  done

  if ! python3 - "$footer_source" "$footer_target" "$usage_source" "$usage_target" "$usage_package_json" "$usage_snapshot_target" "$usage_format_target" <<'PY'
import json
import sys
from pathlib import Path

source_path, target_path, usage_source_path, usage_target_path, usage_package_json, usage_snapshot_path, usage_format_path = map(Path, sys.argv[1:])
if not source_path.exists() or not target_path.exists():
    raise SystemExit(1)

def usage_key(path: Path) -> str | None:
    config = json.loads(path.read_text(encoding="utf-8"))
    for line in config.get("lines", []):
        for widget in line:
            if widget.get("id") == "jp-openai-usage":
                return widget.get("options", {}).get("externalStatusKey")
    return None

source_key = usage_key(source_path)
target_key = usage_key(target_path)
ok = True
if source_key == "openai-usage":
    print("ok      canonical usage key: openai-usage")
else:
    print(f"drift   canonical usage key: {source_key}")
    ok = False
if target_key == source_key and target_key:
    print(f"ok      installed usage key: {target_key}")
else:
    print(f"drift   installed usage key: {target_key} (expected {source_key})")
    ok = False
usage_version = json.loads(usage_package_json.read_text(encoding="utf-8")).get("version")
if usage_version == "0.1.3":
    print(f"ok      pi-openai-usage version: {usage_version}")
else:
    print(f"drift   pi-openai-usage version: {usage_version} (expected 0.1.3)")
    ok = False
if source_path.read_bytes() == target_path.read_bytes():
    print("ok      footer config is synchronized")
else:
    print("drift   footer config differs from canonical source")
    ok = False
if usage_source_path.read_bytes() == usage_target_path.read_bytes():
    print("ok      OpenAI usage config is synchronized")
else:
    print("drift   OpenAI usage config differs from canonical source")
    ok = False
raise SystemExit(0 if ok else 1)
PY
  then
    status=1
  fi
  if (cd "$usage_package_root" && git apply --reverse --check "$usage_margin_patch" >/dev/null 2>&1); then
    echo "ok      weekly margin patch is applied"
  else
    echo "drift   weekly margin patch is missing or incomplete"
    status=1
  fi
  return "$status"
}

backup_file() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  local backup
  backup="$path.bak-pi-statusline-$(date +%Y%m%d-%H%M%S)"
  cp -f -- "$path" "$backup"
  echo "backup  $backup"
}

patch_openai_usage_margin() {
  if [[ ! -f "$usage_package_json" ]]; then
    echo "Missing pi-openai-usage package: $usage_package_root" >&2
    return 1
  fi
  if [[ ! -f "$usage_margin_patch" ]]; then
    echo "Missing usage margin patch: $usage_margin_patch" >&2
    return 1
  fi

  local usage_version
  usage_version="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["version"])' "$usage_package_json")"
  if [[ "$usage_version" != "0.1.3" ]]; then
    echo "Unsupported pi-openai-usage version: $usage_version (expected 0.1.3)" >&2
    return 1
  fi
  if (cd "$usage_package_root" && git apply --reverse --check "$usage_margin_patch" >/dev/null 2>&1); then
    echo "ok      weekly margin patch already applied"
    return 0
  fi

  (cd "$usage_package_root" && git apply --check "$usage_margin_patch")
  backup_file "$usage_snapshot_target"
  backup_file "$usage_format_target"
  (cd "$usage_package_root" && git apply "$usage_margin_patch")
  echo "patched pi-openai-usage weekly margin"
}

if [[ "$show_status" -eq 1 ]]; then
  show_status_fn
  exit $?
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

if [[ "$no_usage_config" -eq 0 ]]; then
  if [[ ! -f "$usage_source" ]]; then
    echo "Missing source usage config: $usage_source" >&2
    exit 1
  fi
  mkdir -p -- "$(dirname -- "$usage_target")"
  backup_file "$usage_target"
  cp -f -- "$usage_source" "$usage_target"
  echo "copied  pi-openai-usage config"
fi

if [[ "$no_package_patches" -eq 1 ]]; then
  echo
  echo "Next step inside Pi: /reload"
  exit 0
fi

patch_openai_usage_margin

export FOOTER_PACKAGE_TARGET="$footer_package_target"
export CHROME_TARGET="$chrome_target"

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


PY

echo
echo "Next step inside Pi: /reload"
