@ECHO OFF

C:\lazarus\lazbuild --build-all EDITOR.lpi
if %errorlevel% neq 0 goto end

C:\lazarus\lazbuild --build-all USURPER.lpi
if %errorlevel% neq 0 goto end

:end
pause