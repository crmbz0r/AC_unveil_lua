@echo off
chcp 65001 >nul
echo AiComi Lua Mod Installer
echo =======================
echo.
echo This will install the AiComi Lua Mod to your game directory.
echo.
echo Requirements:
echo - AiComi game installed
echo - BepInEx installed in your AiComi game directory
echo.
pause
echo.
echo Starting PowerShell installer...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0install_plugin.ps1"
echo.
echo Installation completed!
echo.
pause