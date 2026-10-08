@echo off
setlocal enabledelayedexpansion
title Mercato 5 - Exportation Automatique PC et Mobile
cd /d "%~dp0"

echo ========================================================
echo         MERCATO 5 - COMPILATION ET EXPORTATION
echo ========================================================
echo.

set "GODOT_EXE=%~dp0bin\godot.exe"

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

echo [1/4] Preparation des dossiers de sortie...
if not exist "build\pc" mkdir "build\pc"
if not exist "build\web" mkdir "build\web"
if not exist "mobile\build\web" mkdir "mobile\build\web"
if not exist "mobile\build\windows" mkdir "mobile\build\windows"

echo.
echo [2/4] Exportation de la Version PC (Windows Desktop autonome)...
"%GODOT_EXE%" --headless --path . --export-release "Windows Desktop" "build\pc\Mercato5.exe"
if !errorlevel! equ 0 (
    echo       [SUCCES] build\pc\Mercato5.exe genere avec succes !
) else (
    echo       [ERREUR] Echec de l'export PC.
)

echo.
echo [3/4] Exportation de la Version Mobile (Web / PWA pour smartphone)...
"%GODOT_EXE%" --headless --path "%~dp0mobile" --export-release "Web" "build\web\index.html"
if !errorlevel! equ 0 (
    echo       [SUCCES] mobile\build\web\ genere avec succes !
) else (
    echo       [ERREUR] Echec de l'export Mobile Web.
)

echo.
echo [4/4] Creation de l'archive ZIP PC prete a distribuer...
powershell -Command "if (Test-Path 'build\Mercato5_PC_Pret_A_Jouer.zip') { Remove-Item 'build\Mercato5_PC_Pret_A_Jouer.zip' -Force }; Compress-Archive -Path 'build\pc\Mercato5.exe' -DestinationPath 'build\Mercato5_PC_Pret_A_Jouer.zip' -Force"
if exist "build\Mercato5_PC_Pret_A_Jouer.zip" (
    echo       [SUCCES] Archive build\Mercato5_PC_Pret_A_Jouer.zip prete pour vos joueurs !
)

echo.
echo ========================================================
echo                  EXPORTATION TERMINEE !
echo ========================================================
echo.
echo 1. PC       : Double-cliquez sur build\pc\Mercato5.exe pour jouer directement.
echo               Partagez build\Mercato5_PC_Pret_A_Jouer.zip a vos amis / sur itch.io.
echo 2. MOBILE   : Les fichiers Web sont dans mobile\build\web\ (prets a heberger).
echo.
pause
exit /b 0
