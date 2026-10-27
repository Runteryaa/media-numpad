@echo off
setlocal EnableExtensions
title Medya Numpad - Kurulum
cd /d "%~dp0"

rem ---------- yonetici kontrolu ----------
net session >nul 2>&1
if errorlevel 1 (
    echo.
    echo Yonetici izni gerekiyor. UAC penceresini onaylayin...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "KEY=HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
set "NAME=Scancode Map"
set "HEX=00000000000000000700000010e0470022e0480019e049002ee04b0020e04c0030e04d0000000000"

:menu
cls
echo ==========================================================
echo    NUMPAD  -^>  MEDYA TUSLARI
echo ==========================================================
echo   7 = Onceki parca      8 = Oynat / Duraklat
echo   9 = Sonraki parca     4 = Ses azalt
echo   5 = Sessize al        6 = Ses artir
echo ----------------------------------------------------------
echo   1) Kur
echo   2) Kaldir
echo   3) Durum
echo   0) Cikis
echo ==========================================================
set "sec="
set /p "sec=Secim: "
if "%sec%"=="1" goto install
if "%sec%"=="2" goto remove
if "%sec%"=="3" goto status
if "%sec%"=="0" exit /b
goto menu

rem ---------- yardimcilar ----------
:hasvalue
reg query "%KEY%" /v "%NAME%" >nul 2>&1
exit /b %errorlevel%

:backup
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "DT=%%I"
if not defined DT set "DT=manual"
set "BAK=%~dp0yedek-%DT%.reg"
reg export "%KEY%" "%BAK%" /y >nul
if errorlevel 1 (
    echo UYARI: yedek alinamadi, devam ediliyor.
) else (
    echo Yedek alindi: %BAK%
)
exit /b 0

:rebootprompt
echo.
set "ans="
set /p "ans=Simdi yeniden baslatilsin mi? (E/H): "
if /i "%ans%"=="E" shutdown /r /t 5 /c "Scancode Map uygulandi"
exit /b 0

rem ---------- kur ----------
:install
cls
call :hasvalue
if %errorlevel%==0 (
    echo Mevcut bir Scancode Map bulundu, once yedekleniyor...
    call :backup
) else (
    echo Mevcut Scancode Map yok. Temiz kurulum yapiliyor.
)
echo.
reg add "%KEY%" /v "%NAME%" /t REG_BINARY /d %HEX% /f >nul
if errorlevel 1 (
    echo HATA: deger yazilamadi.
    echo.
    pause
    goto menu
)
echo Kuruldu. Dogrulama:
reg query "%KEY%" /v "%NAME%"
echo.
echo ==========================================================
echo  REBOOT GEREKLI. Yeniden baslatmadan tuslar degismez.
echo ==========================================================
call :rebootprompt
goto menu

rem ---------- kaldir ----------
:remove
cls
call :hasvalue
if not %errorlevel%==0 (
    echo Scancode Map zaten yok. Yapilacak bir sey yok.
    echo.
    pause
    goto menu
)
echo Mevcut deger yedekleniyor...
call :backup
echo.
reg delete "%KEY%" /v "%NAME%" /f >nul
if errorlevel 1 (
    echo HATA: deger silinemedi.
    echo.
    pause
    goto menu
)
echo Kaldirildi.
echo ==========================================================
echo  REBOOT GEREKLI.
echo ==========================================================
call :rebootprompt
goto menu

rem ---------- durum ----------
:status
cls
call :hasvalue
if %errorlevel%==0 (
    echo Durum: KURULU
    echo.
    reg query "%KEY%" /v "%NAME%"
    echo.
    echo Beklenen 40 bayt:
    echo %HEX%
) else (
    echo Durum: KURULU DEGIL
)
echo.
pause
goto menu