@echo off
title Pruebas Unitarias - Proyecto Flutter
color 0B

echo ========================================================
echo Iniciando bateria de pruebas unitarias de Flutter...
echo ========================================================
echo.

:: Ejecuta todas las pruebas en la carpeta test/
call flutter test

echo.
echo ========================================================
echo Ejecucion finalizada. Revisa los resultados arriba.
echo ========================================================
pause