@ECHO OFF

C:\lazarus\lazbuild --build-all --operating-system=go32v2 EDITOR.lpi
if %errorlevel% neq 0 goto end

C:\lazarus\lazbuild --build-all --operating-system=go32v2 USURPER.lpi
if %errorlevel% neq 0 goto end

:end
pause