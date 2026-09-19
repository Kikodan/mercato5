@echo off
setlocal enabledelayedexpansion
title Mercato 5 - Lancement du Jeu
cd /d "%~dp0"

echo ========================================================
echo             MERCATO 5 - FOOTBALL MANAGER
echo ========================================================
echo.

set "GODOT_EXE=%~dp0bin\godot.exe"

REM 1. Verifier si Godot est deja extrait dans le dossier bin
if not exist "%GODOT_EXE%" (
    if exist "%~dp0bin\godot.zip" (
        echo [INFO] Premier lancement detecte : extraction de Godot Engine integre au projet...
        echo Veuillez patienter quelques secondes...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%~dp0bin\godot.zip' -DestinationPath '%~dp0bin' -Force"
    )
)

REM 2. Verifier a nouveau apres extraction
if not exist "%GODOT_EXE%" (
    where godot >nul 2>nul
    if !errorlevel! equ 0 (
        for /f "delims=" %%I in ('where godot') do set "GODOT_EXE=%%I"
    )
)

REM 3. Verifier les emplacements habituels de secours
if not exist "%GODOT_EXE%" (
    if exist "C:\Users\%USERNAME%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" (
        set "GODOT_EXE=C:\Users\%USERNAME%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
    )
)

REM 4. Verification finale
if not exist "%GODOT_EXE%" (
    echo [ERREUR] Impossible de trouver ou d'extraire Godot Engine.
    echo Assurez-vous que le fichier 'bin\godot.zip' est present dans le projet.
    echo.
    pause
    exit /b 1
)

echo [OK] Lancement de Mercato 5...
start "" "%GODOT_EXE%" --path "%~dp0."
exit /b 0
