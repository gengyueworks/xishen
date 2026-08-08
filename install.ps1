#!/usr/bin/env pwsh
<#
  xishen (喜神 · 八字暖读) — universal installer (install.ps1)

  Installs this repo (the skill folder) into any agent runtime's skills directory.
  Works natively on Windows PowerShell 5.1 and PowerShell 7+.

  Quick usage:
    .\install.ps1                     # auto-detect and install to every detected runtime
    .\install.ps1 -Claude -Codex      # install only to Claude and Codex
    .\install.ps1 -Target C:\skills   # install to a custom folder
    .\install.ps1 -Link -Claude       # development mode: symlink (repo edits apply instantly)
    .\install.ps1 -DryRun -All        # preview only, no changes
#>
param(
    [switch]$All,
    [switch]$Claude,
    [switch]$OpenCode,
    [switch]$Codex,
    [switch]$Gemini,
    [switch]$Cursor,
    [switch]$WorkBuddy,
    [switch]$Agents,
    [string]$Target = '',
    [switch]$Link,
    [switch]$DryRun,
    [string]$Name = 'xishen',
    [switch]$Help
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot

# --- usage ---
function Show-Usage {
    Write-Host @'
xishen (喜神 · 八字暖读) — universal installer (install.ps1)

Usage:
  .\install.ps1 [options]

Options:
  -All            Install to every detected runtime (default when no runtime flag is given)
  -Claude         Install to ~\.claude\skills
  -OpenCode       Install to ~\.config\opencode\skills (honors $env:XDG_CONFIG_HOME)
  -Codex          Install to ~\.codex\skills
  -Gemini         Install to ~\.gemini\skills
  -Cursor         Install to ~\.cursor\skills
  -WorkBuddy      Install to ~\.workbuddy\skills
  -Agents         Install to ~\.agents\skills (shared by Codex / Copilot / Gemini CLI)
  -Target <dir>   Install to a custom folder (dir is the skills dir; the skill goes inside)
  -Link           Symlink instead of copy (development mode — repo edits appear instantly)
  -DryRun         Preview install targets, make no changes
  -Name <name>    Folder name inside the skills dir (default: xishen)
  -Help           Show this help and exit

Examples:
  .\install.ps1                 # auto-detect and install to every detected runtime
  .\install.ps1 -Claude -Codex  # install only to Claude and Codex
  .\install.ps1 -Target C:\my-skills -Name xishen
  .\install.ps1 -Link -Claude   # development mode: symlink into Claude

Detection (used by -All or when no runtime flag is given):
  A runtime counts as detected if its CLI binary is on PATH
  (claude / opencode / codex / gemini / cursor / workbuddy)
  OR its config/skills dir already exists.
'@
}

# --- helpers ---
function Test-Command {
    param([string]$CmdName)
    return $null -ne (Get-Command $CmdName -ErrorAction SilentlyContinue)
}

# Returns a new list with (@{Dir=..;Label=..}) appended if not already present.
# The leading comma keeps the result an array even when it holds a single item.
function Add-Target {
    param($List, [string]$Dir, [string]$Label)
    foreach ($t in $List) {
        if ($t.Dir -eq $Dir) { return ,$List }
    }
    $List += ,@{ Dir = $Dir; Label = $Label }
    return ,$List
}

# Auto-detect runtimes: CLI on PATH, or config/skills dir already exists.
function Get-DetectedTargets {
    $list = @()
    if ((Test-Command 'claude')    -or (Test-Path $ClaudeDir))    { $list += ,@{ Dir = $ClaudeDir;    Label = 'Claude' } }
    if ((Test-Command 'opencode')  -or (Test-Path $OpenCodeDir))  { $list += ,@{ Dir = $OpenCodeDir;  Label = 'OpenCode' } }
    if ((Test-Command 'codex')     -or (Test-Path $CodexDir))     { $list += ,@{ Dir = $CodexDir;     Label = 'Codex' } }
    if ((Test-Command 'gemini')    -or (Test-Path $GeminiDir))    { $list += ,@{ Dir = $GeminiDir;    Label = 'Gemini' } }
    if ((Test-Command 'cursor')    -or (Test-Path $CursorDir))    { $list += ,@{ Dir = $CursorDir;    Label = 'Cursor' } }
    if ((Test-Command 'workbuddy') -or (Test-Path $WorkBuddyDir)) { $list += ,@{ Dir = $WorkBuddyDir; Label = 'WorkBuddy' } }
    if ((Test-Command 'codex') -or (Test-Command 'gemini') -or (Test-Command 'copilot') -or (Test-Path $AgentsDir)) {
        $list += ,@{ Dir = $AgentsDir; Label = 'Agents' }
    }
    return ,$list
}

# Copy mode: PowerShell's '*' wildcard does NOT match hidden/dot items,
# so .git is never copied. The Remove-Item below is a safety net.
function Copy-Install {
    param([string]$Dest)
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    Copy-Item -Path (Join-Path $RepoRoot '*') -Destination $Dest -Recurse -Force
    $git = Join-Path $Dest '.git'
    if (Test-Path $git) { Remove-Item $git -Recurse -Force }
    Write-Host "  [OK] installed: $Dest"
}

function Install-To {
    param([string]$Dir, [string]$Label)
    $dest = Join-Path $Dir $Name

    if ($DryRun) {
        Write-Host "  [dry-run] would install to: $dest ($Label)"
        return
    }

    New-Item -ItemType Directory -Path $Dir -Force | Out-Null

    # Get-Item -Force also sees broken symlinks, so re-running always updates cleanly.
    if (Get-Item $dest -Force -ErrorAction SilentlyContinue) {
        Write-Host "  Updating existing install: $dest"
        Remove-Item $dest -Recurse -Force
    }

    if ($Link) {
        try {
            New-Item -ItemType SymbolicLink -Path $dest -Target $RepoRoot -ErrorAction Stop | Out-Null
            Write-Host "  [OK] installed (symlink): $dest ($Label)"
        }
        catch {
            # Windows symlinks need admin rights or Developer Mode — fall back to copy.
            Write-Host "  [WARN] Symlink failed (needs admin or Developer Mode): $($_.Exception.Message)"
            Copy-Install $dest
        }
    }
    else {
        Copy-Install $dest
    }
}

# --- runtime skill directories ---
$ClaudeDir    = Join-Path $HOME '.claude\skills'
$OpenCodeDir  = Join-Path $HOME '.config\opencode\skills'
if ($env:XDG_CONFIG_HOME) { $OpenCodeDir = Join-Path $env:XDG_CONFIG_HOME 'opencode\skills' }
$CodexDir     = Join-Path $HOME '.codex\skills'
$GeminiDir    = Join-Path $HOME '.gemini\skills'
$CursorDir    = Join-Path $HOME '.cursor\skills'
$WorkBuddyDir = Join-Path $HOME '.workbuddy\skills'
$AgentsDir    = Join-Path $HOME '.agents\skills'

# --- entry checks ---
if ($Help) { Show-Usage; exit 0 }

if (-not (Test-Path (Join-Path $RepoRoot 'SKILL.md'))) {
    Write-Host "ERROR: SKILL.md not found next to install.ps1. Run this script from inside the xishen repo folder." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Name) -or $Name -match '[/\\]') {
    Write-Host "ERROR: -Name must be a plain folder name (no slashes, not empty)." -ForegroundColor Red
    exit 1
}

# --- collect targets ---
$targets = @()
if ($Claude)    { $targets = Add-Target $targets $ClaudeDir    'Claude' }
if ($OpenCode)  { $targets = Add-Target $targets $OpenCodeDir  'OpenCode' }
if ($Codex)     { $targets = Add-Target $targets $CodexDir     'Codex' }
if ($Gemini)    { $targets = Add-Target $targets $GeminiDir    'Gemini' }
if ($Cursor)    { $targets = Add-Target $targets $CursorDir    'Cursor' }
if ($WorkBuddy) { $targets = Add-Target $targets $WorkBuddyDir 'WorkBuddy' }
if ($Agents)    { $targets = Add-Target $targets $AgentsDir    'Agents' }
if ($Target) {
    # Expand ~ and relative paths to absolute before adding.
    $resolvedTarget = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)
    $targets = Add-Target $targets $resolvedTarget 'Custom'
}

# -All given, or no runtime flag / no -Target → auto-detect (same as -All)
if ($All -or $targets.Count -eq 0) {
    foreach ($t in @(Get-DetectedTargets)) {
        $targets = Add-Target $targets $t.Dir $t.Label
    }
}

# Nothing detected and no -Target → friendly message, exit 0 (not an error).
if ($targets.Count -eq 0) {
    Write-Host ""
    Write-Host "No agent runtimes detected and no -Target was given."
    Write-Host "Supported runtimes: Claude (-Claude), OpenCode (-OpenCode), Codex (-Codex), Gemini (-Gemini), Cursor (-Cursor), WorkBuddy (-WorkBuddy), Agents (-Agents)."
    Write-Host "Or install into a custom folder: .\install.ps1 -Target C:\path\to\skills"
    exit 0
}

# --- install ---
Write-Host ""
if ($DryRun) { Write-Host "xishen — dry run:" } else { Write-Host "xishen — installing:" }
foreach ($t in $targets) {
    Install-To $t.Dir $t.Label
}

# --- summary ---
Write-Host ""
if ($DryRun) {
    Write-Host "Dry run complete — nothing was changed. Targets that would be installed:"
}
else {
    Write-Host "xishen (喜神 · 八字暖读) installed. Locations:"
}
foreach ($t in $targets) {
    Write-Host "  - $(Join-Path $t.Dir $Name) ($($t.Label))"
}
Write-Host ""

if ($DryRun) {
    Write-Host "Re-run without -DryRun to actually install."
}
else {
    Write-Host "Next step: in the agent's chat, say:"
    Write-Host '  算我八字：公历 1995 年 8 月 12 日 14 时 30 分，女'
    Write-Host "to trigger the skill. (The full trigger words are in SKILL.md / README.md.)"
}
