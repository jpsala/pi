#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install the Pi windows-input extension from this repo.

Usage:
  scripts/install-windows-input.sh [--global|--project] [--remove-global] [--status]

Defaults:
  --global        Install to ~/.pi/agent/extensions/windows-input.ts (recommended)

Options:
  --project       Install to .pi/extensions/windows-input.ts for this repo only
  --remove-global Remove ~/.pi/agent/extensions/windows-input.ts before project install
  --status        Show source/destination status and exit

After installing, open Pi or run /reload in an existing Pi session.
EOF
}

scope="global"
remove_global="false"
status_only="false"

for arg in "$@"; do
  case "$arg" in
    --global) scope="global" ;;
    --project) scope="project" ;;
    --remove-global) remove_global="true" ;;
    --status) status_only="true" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; usage; exit 2 ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
source_file="$repo_root/pi-extensions/windows-input.ts"
global_dest="${HOME}/.pi/agent/extensions/windows-input.ts"
project_dest="$repo_root/.pi/extensions/windows-input.ts"

if [[ ! -f "$source_file" ]]; then
  echo "Source extension not found: $source_file" >&2
  exit 1
fi

show_status() {
  echo "Source:  $source_file"
  [[ -f "$source_file" ]] && echo "  ok" || echo "  missing"
  echo "Global:  $global_dest"
  [[ -f "$global_dest" ]] && echo "  installed" || echo "  not installed"
  echo "Project: $project_dest"
  [[ -f "$project_dest" ]] && echo "  installed" || echo "  not installed"
  if [[ -f "$global_dest" && -f "$project_dest" ]]; then
    echo "WARNING: both global and project copies are installed; Pi may double-load the extension."
  fi
}

if [[ "$status_only" == "true" ]]; then
  show_status
  exit 0
fi

if [[ "$scope" == "project" && "$remove_global" == "true" && -f "$global_dest" ]]; then
  rm -f "$global_dest"
  echo "Removed global copy: $global_dest"
fi

if [[ "$scope" == "global" ]]; then
  mkdir -p "$(dirname "$global_dest")"
  cp "$source_file" "$global_dest"
  echo "Installed global Pi extension: $global_dest"
else
  if [[ -f "$global_dest" && "$remove_global" != "true" ]]; then
    echo "WARNING: global copy already exists: $global_dest" >&2
    echo "Use --remove-global if you intentionally want project-local only." >&2
  fi
  mkdir -p "$(dirname "$project_dest")"
  cp "$source_file" "$project_dest"
  echo "Installed project-local Pi extension: $project_dest"
fi

show_status
cat <<'EOF'

Next step inside Pi:
  /reload
  /windows-input status

Linux clipboard note:
  Wayland needs wl-copy from wl-clipboard; X11 needs xclip for Ctrl+C/Ctrl+X clipboard integration.
EOF
