@ECHO OFF

SET PATH=%PATH%;Z:\lazarus\fpc\3.0.2\bin\x86_64-win64

fpc -B -Twin64 -Px86_64 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq ^
    -FiCOMMON -FiEDITOR -Fi../../RMDoor -Fi../obj/x86_64-win64 -FuCOMMON ^
    -Fu../../RMDoor -FU../obj/x86_64-win64 -FE../bin/x86_64-win64/ ^
    EDITOR/EDITOR.PAS
if %errorlevel% neq 0 goto end

fpc -B -Twin64 -Px86_64 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq ^
    -FiCOMMON -FiUSURPER -Fi../../RMDoor -Fi../obj/x86_64-win64 -FuCOMMON ^
    -Fu../../RMDoor -FU../obj/x86_64-win64 -FE../bin/x86_64-win64/ ^
    USURPER/USURPER.PAS
if %errorlevel% neq 0 goto end

fpc -B -Twin32 -Pi386 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq ^
    -FiCOMMON -FiEDITOR -Fi../../RMDoor -Fi../obj/i386-win32 -FuCOMMON ^
    -Fu../../RMDoor -FU../obj/i386-win32 -FE../bin/i386-win32/ ^
    EDITOR/EDITOR.PAS
if %errorlevel% neq 0 goto end

fpc -B -Twin32 -Pi386 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq ^
    -FiCOMMON -FiUSURPER -Fi../../RMDoor -Fi../obj/i386-win32 -FuCOMMON ^
    -Fu../../RMDoor -FU../obj/i386-win32 -FE../bin/i386-win32/ ^
    USURPER/USURPER.PAS
if %errorlevel% neq 0 goto end

:end
exit /b %errorlevel%
pause