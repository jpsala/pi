<#
.SYNOPSIS
Installs the Pi windows-input extension from this repo.

.EXAMPLE
./scripts/install-windows-input.ps1
Installs globally to $HOME/.pi/agent/extensions/windows-input.ts.

.EXAMPLE
./scripts/install-windows-input.ps1 -Scope Project -RemoveGlobal
Installs project-local and removes the global copy to avoid double-loading.

After installing, open Pi or run /reload in an existing Pi session.
#>

param(
    [ValidateSet("Global", "Project")]
    [string]$Scope = "Global",

    [switch]$RemoveGlobal,
    [switch]$Status
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$SourceFile = Join-Path $RepoRoot "pi-extensions/windows-input.ts"
$GlobalDest = Join-Path $HOME ".pi/agent/extensions/windows-input.ts"
$ProjectDest = Join-Path $RepoRoot ".pi/extensions/windows-input.ts"

function Show-InstallStatus {
    Write-Host "Source:  $SourceFile"
    if (Test-Path $SourceFile) { Write-Host "  ok" } else { Write-Host "  missing" }

    Write-Host "Global:  $GlobalDest"
    if (Test-Path $GlobalDest) { Write-Host "  installed" } else { Write-Host "  not installed" }

    Write-Host "Project: $ProjectDest"
    if (Test-Path $ProjectDest) { Write-Host "  installed" } else { Write-Host "  not installed" }

    if ((Test-Path $GlobalDest) -and (Test-Path $ProjectDest)) {
        Write-Warning "Both global and project copies are installed; Pi may double-load the extension."
    }
}

if (-not (Test-Path $SourceFile)) {
    throw "Source extension not found: $SourceFile"
}

if ($Status) {
    Show-InstallStatus
    exit 0
}

if ($Scope -eq "Project" -and $RemoveGlobal -and (Test-Path $GlobalDest)) {
    Remove-Item $GlobalDest -Force
    Write-Host "Removed global copy: $GlobalDest"
}

if ($Scope -eq "Global") {
    New-Item -ItemType Directory -Force (Split-Path -Parent $GlobalDest) | Out-Null
    Copy-Item $SourceFile $GlobalDest -Force
    Write-Host "Installed global Pi extension: $GlobalDest"
} else {
    if ((Test-Path $GlobalDest) -and -not $RemoveGlobal) {
        Write-Warning "Global copy already exists: $GlobalDest"
        Write-Warning "Use -RemoveGlobal if you intentionally want project-local only."
    }
    New-Item -ItemType Directory -Force (Split-Path -Parent $ProjectDest) | Out-Null
    Copy-Item $SourceFile $ProjectDest -Force
    Write-Host "Installed project-local Pi extension: $ProjectDest"
}

Show-InstallStatus
Write-Host ""
Write-Host "Next step inside Pi:"
Write-Host "  /reload"
Write-Host "  /windows-input status"
Write-Host ""
Write-Host "Linux clipboard note: Wayland needs wl-copy from wl-clipboard; X11 needs xclip for Ctrl+C/Ctrl+X clipboard integration."
