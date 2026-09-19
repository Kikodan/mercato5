@echo off
title Mercato 5 - Serveur Mobile iPhone/Android
cd /d "%~dp0"

echo =======================================================
echo    MERCATO 5 - SERVEUR LOCAL ET TUNNEL HTTPS (iOS)
echo =======================================================
echo Demarrage du serveur local...
start /b "" node scripts\serve.js

echo.
echo Demarrage du tunnel Cloudflare HTTPS pour iPhone Safari...
echo (Un lien HTTPS securise va s'afficher ci-dessous)
echo.
cloudflared.exe tunnel --url http://localhost:8000
pause
