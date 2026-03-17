#!/usr/bin/env pwsh
# AiComi Lua Mod Installer Script
# This script installs the AiComi_LuaMod plugin and its required files

$ErrorActionPreference = 'Stop'

Write-Host "AiComi Lua Mod Installer" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# Get the script directory (solution directory)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Script directory: $scriptDir"

# Check if we're in the right directory
if (-not (Test-Path "$scriptDir\AC_LoadModDLL\AiComi_LuaMod.csproj")) {
    Write-Host "Error: This script should be run from the solution directory." -ForegroundColor Red
    Write-Host "Expected to find: $scriptDir\AC_LoadModDLL\AiComi_LuaMod.csproj" -ForegroundColor Red
    Write-Host "Please run this script from the root of the AiComi_LuaMod project." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Get game folder path from user
$gameFolder = Read-Host "Please enter the path to your AiComi game folder (e.g., G:\Games\AiComi)"
$gameFolder = $gameFolder.Trim()

# Validate game folder path
if ([string]::IsNullOrWhiteSpace($gameFolder)) {
    Write-Host "Error: Game folder path cannot be empty." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Normalize path (remove trailing backslash if present)
$gameFolder = $gameFolder.TrimEnd('\')

# Check if game folder exists
if (-not (Test-Path $gameFolder)) {
    Write-Host "Error: Game folder does not exist: $gameFolder" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Define paths
$pluginsDir = Join-Path $gameFolder "BepInEx\plugins"
$luaScriptsDir = Join-Path $pluginsDir "lua_scripts"
$sourceDll = Join-Path $scriptDir "BepInEx\plugins\AiComi_LuaMod.dll"
$sourceLua = Join-Path $scriptDir "AC_LuaContent\AiComi_LuaMod.lua"
$sourceMods = Join-Path $scriptDir "AC_LuaContent\mods"
$sourceStubs = Join-Path $scriptDir "AC_LuaContent\stubs"

Write-Host ""
Write-Host "Installation Summary:" -ForegroundColor Yellow
Write-Host "Game Folder: $gameFolder" -ForegroundColor Yellow
Write-Host "Plugins Directory: $pluginsDir" -ForegroundColor Yellow
Write-Host ""

# Check if source files exist
$sourceFilesExist = $true

if (-not (Test-Path $sourceDll)) {
    Write-Host "Warning: Source DLL not found: $sourceDll" -ForegroundColor Yellow
    Write-Host "Please build the project first before running this installer." -ForegroundColor Yellow
    $sourceFilesExist = $false
}

if (-not (Test-Path $sourceLua)) {
    Write-Host "Warning: Source Lua file not found: $sourceLua" -ForegroundColor Yellow
    $sourceFilesExist = $false
}

if (-not (Test-Path $sourceMods)) {
    Write-Host "Warning: Source mods folder not found: $sourceMods" -ForegroundColor Yellow
    $sourceFilesExist = $false
}

if (-not (Test-Path $sourceStubs)) {
    Write-Host "Warning: Source stubs folder not found: $sourceStubs" -ForegroundColor Yellow
    $sourceFilesExist = $false
}

if (-not $sourceFilesExist) {
    Write-Host ""
    Write-Host "Some source files are missing. Installation cannot continue." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Create plugins directory if it doesn't exist
if (-not (Test-Path $pluginsDir)) {
    Write-Host "Creating plugins directory: $pluginsDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
}

# Create lua_scripts directory
Write-Host "Creating lua_scripts directory: $luaScriptsDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Path $luaScriptsDir -Force | Out-Null

Write-Host ""
Write-Host "Installing files..." -ForegroundColor Green

# Copy DLL file
Write-Host "Copying AiComi_LuaMod.dll..." -ForegroundColor Cyan
Copy-Item -Path $sourceDll -Destination $pluginsDir -Force
if ($?) {
    Write-Host "  ▭▷ AiComi_LuaMod.dll copied successfully" -ForegroundColor Green
} else {
    Write-Host "  ╳ Failed to copy AiComi_LuaMod.dll" -ForegroundColor Red
}

# Copy Lua file
Write-Host "Copying AiComi_LuaMod.lua..." -ForegroundColor Cyan
Copy-Item -Path $sourceLua -Destination $pluginsDir -Force
if ($?) {
    Write-Host "  ▭▷ AiComi_LuaMod.lua copied successfully" -ForegroundColor Green
} else {
    Write-Host "  ╳ Failed to copy AiComi_LuaMod.lua" -ForegroundColor Red
}

# Copy mods folder
Write-Host "Copying mods folder..." -ForegroundColor Cyan
$modsDest = Join-Path $luaScriptsDir "mods"
if (Test-Path $modsDest) {
    Remove-Item -Path $modsDest -Recurse -Force
}
Copy-Item -Path $sourceMods -Destination $luaScriptsDir -Recurse -Force
if ($?) {
    Write-Host "  ▭▷ mods folder copied successfully" -ForegroundColor Green
} else {
    Write-Host "  ╳ Failed to copy mods folder" -ForegroundColor Red
}

# Copy stubs folder
Write-Host "Copying stubs folder..." -ForegroundColor Cyan
$stubsDest = Join-Path $luaScriptsDir "stubs"
if (Test-Path $stubsDest) {
    Remove-Item -Path $stubsDest -Recurse -Force
}
Copy-Item -Path $sourceStubs -Destination $luaScriptsDir -Recurse -Force
if ($?) {
    Write-Host "  ▭▷ stubs folder copied successfully" -ForegroundColor Green
} else {
    Write-Host "  ╳ Failed to copy stubs folder" -ForegroundColor Red
}

Write-Host ""
Write-Host "Installation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Files installed to:" -ForegroundColor Yellow
Write-Host "  $pluginsDir\AiComi_LuaMod.dll" -ForegroundColor White
Write-Host "  $pluginsDir\AiComi_LuaMod.lua" -ForegroundColor White
Write-Host "  $luaScriptsDir\mods\*" -ForegroundColor White
Write-Host "  $luaScriptsDir\stubs\*" -ForegroundColor White
Write-Host ""
Write-Host "You can now start AiComi and the Lua mod should be loaded automatically." -ForegroundColor Green
Write-Host ""
Write-Host "To uninstall, simply delete these files and folders from your game directory." -ForegroundColor Yellow

Read-Host "Press Enter to exit"