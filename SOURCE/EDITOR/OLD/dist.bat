ECHO OFF
CLS
ECHO *************************************************************
ECHO Copying Usurper Editor files to delevop,test and release DIRS
ECHO also refreshing editor.zip
ECHO *************************************************************

REM Copy Usurper Editor files to 3 places
REM *************************************

REM development directory
copy editor.exe ..\usurper /Y
copy editor.ovr ..\usurper /Y
copy editor.hlp ..\usurper /Y

REM testlab dir
copy editor.exe ..\usurp018.test /Y
copy editor.ovr ..\usurp018.test /Y
copy editor.hlp ..\usurp018.test /Y

REM release dir
copy editor.exe ..\usurper\release /Y /V
copy editor.ovr ..\usurper\release /Y /V
copy editor.hlp ..\usurper\release /Y /V

REM update zip archive with Editor Source files
pkzip -f editor

ECHO ON
