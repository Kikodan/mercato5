@echo off
setlocal enabledelayedexpansion
title Mercato 5 Mobile - Lancement
cd /d "%~dp0"

echo ========================================================
echo         MERCATO 5 - VERSION MOBILE PORTRAIT
echo ========================================================
echo.

set "GODOT_EXE=%~dp0..\bin\godot.exe"

if not exist "%GODOT_EXE%" (
    where godot >nul 2>nul
    if !errorlevel! equ 0 (
        for /f "delims=" %%I in ('where godot') do set "GODOT_EXE=%%I"
    )
)

if not exist "%GODOT_EXE%" (
    echo [ERREUR] Impossible de trouver Godot Engine dans bin\godot.exe
    pause
    exit /b 1
)

echo [OK] Lancement de Mercato 5 Mobile...
start "" "%GODOT_EXE%" --path "%~dp0."
exit /b 0
