#!/bin/bash

set -e

fpc -B -Tlinux -Px86_64 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiEDITOR -Fi../../RMDoor -Fi../obj/x86_64-linux -FuCOMMON \
    -Fu../../RMDoor -FU../obj/x86_64-linux -FE../bin/x86_64-linux/ \
    EDITOR/EDITOR.PAS

fpc -B -Tlinux -Px86_64 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiUSURPER -Fi../../RMDoor -Fi../obj/x86_64-linux -FuCOMMON \
    -Fu../../RMDoor -FU../obj/x86_64-linux -FE../bin/x86_64-linux/ \
    USURPER/USURPER.PAS

fpc -B -Tlinux -Pi386 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiEDITOR -Fi../../RMDoor -Fi../obj/i386-linux -FuCOMMON \
    -Fu../../RMDoor -FU../obj/i386-linux -FE../bin/i386-linux/ \
    EDITOR/EDITOR.PAS

fpc -B -Tlinux -Pi386 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiUSURPER -Fi../../RMDoor -Fi../obj/i386-linux -FuCOMMON \
    -Fu../../RMDoor -FU../obj/i386-linux -FE../bin/i386-linux/ \
    USURPER/USURPER.PAS
