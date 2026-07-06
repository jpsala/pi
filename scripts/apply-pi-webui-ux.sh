#!/usr/bin/env bash
set -euo pipefail

# Applies JP's Pi WebUI/TUI readability tweaks to the current Pi agent install.

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
agent_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"

tool_display_source="$repo_root/pi-extensions/pi-tool-display.json"
tool_display_target_dir="$agent_dir/extensions/pi-tool-display"
tool_display_target="$tool_display_target_dir/config.json"
hide_messages_source="$repo_root/pi-extensions/pi-hide-messages.json"
hide_messages_target_dir="$agent_dir/extensions/pi-hide-messages"
hide_messages_target="$hide_messages_target_dir/config.json"
webui_css="$agent_dir/npm/node_modules/@firstpick/pi-package-webui/public/styles.css"
marker='/* Pi local patch: hide extension notify transcript cards */'
patch="

$marker
.message.extension {
  display: none !important;
}
"

copy_config() {
  local source="$1" target_dir="$2" target="$3"
  if [[ ! -f "$source" ]]; then
    echo "missing source config: $source" >&2
    exit 1
  fi
  mkdir -p -- "$target_dir"
  cp -f -- "$source" "$target"
  echo "copied  $target"
}

copy_config "$tool_display_source" "$tool_display_target_dir" "$tool_display_target"
copy_config "$hide_messages_source" "$hide_messages_target_dir" "$hide_messages_target"

if [[ -f "$webui_css" ]]; then
  if ! grep -Fq -- "$marker" "$webui_css"; then
    printf '%s%s' "$(perl -0pe 's/\s+\z//' "$webui_css")" "$patch" > "$webui_css"
    echo "patched $webui_css"
  else
    echo "already patched $webui_css"
  fi
else
  echo "skip    WebUI CSS not found; install npm:@firstpick/pi-package-webui first"
fi

echo "Next: restart WebUI or hard-refresh browser; run /reload in Pi for TUI configs."
