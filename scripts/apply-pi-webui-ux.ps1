<#
.SYNOPSIS
Applies JP's Pi WebUI/TUI readability tweaks to the current Pi agent install.

Copies versioned configs for pi-tool-display and pi-hide-messages and hides
@firstpick/pi-package-webui transient extension notification cards from the
browser transcript.
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$AgentDir = if ($env:PI_CODING_AGENT_DIR) { $env:PI_CODING_AGENT_DIR } else { Join-Path $HOME ".pi\agent" }

$ToolDisplaySource = Join-Path $RepoRoot "pi-extensions\pi-tool-display.json"
$ToolDisplayTargetDir = Join-Path $AgentDir "extensions\pi-tool-display"
$ToolDisplayTarget = Join-Path $ToolDisplayTargetDir "config.json"
$HideMessagesSource = Join-Path $RepoRoot "pi-extensions\pi-hide-messages.json"
$HideMessagesTargetDir = Join-Path $AgentDir "extensions\pi-hide-messages"
$HideMessagesTarget = Join-Path $HideMessagesTargetDir "config.json"
$WebUiCss = Join-Path $AgentDir "npm\node_modules\@firstpick\pi-package-webui\public\styles.css"
$Marker = "/* Pi local patch: hide extension notify transcript cards */"
$Patch = @"

$Marker
.message.extension {
  display: none !important;
}
"@

function Copy-Config($Source, $TargetDir, $Target) {
  if (!(Test-Path $Source)) { throw "Missing source config: $Source" }
  New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
  Copy-Item $Source $Target -Force
  Write-Host "copied  $Target"
}

Copy-Config $ToolDisplaySource $ToolDisplayTargetDir $ToolDisplayTarget
Copy-Config $HideMessagesSource $HideMessagesTargetDir $HideMessagesTarget

if (Test-Path $WebUiCss) {
  $Text = Get-Content $WebUiCss -Raw
  if ($Text -notlike "*$Marker*") {
    Set-Content -Path $WebUiCss -Value ($Text.TrimEnd() + $Patch) -NoNewline
    Write-Host "patched $WebUiCss"
  } else {
    Write-Host "already patched $WebUiCss"
  }
} else {
  Write-Host "skip    WebUI CSS not found; install npm:@firstpick/pi-package-webui first"
}

Write-Host "Next: restart WebUI or hard-refresh browser; run /reload in Pi for TUI configs."
