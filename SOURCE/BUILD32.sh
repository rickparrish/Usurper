#!/bin/bash

set -e

fpc -B -Tlinux -Pi386 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiEDITOR -Fi../obj/i386-linux -FuCOMMON \
    -FU../obj/i386-linux -FE../bin/i386-linux/ \
    EDITOR/EDITOR.PAS

fpc -B -Tlinux -Pi386 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiUSURPER -Fi../obj/i386-linux -FuCOMMON -FuUSURPER/DDPLUS \
    -Fu../../RMDoor -FU../obj/i386-linux -FE../bin/i386-linux/ \
    USURPER/USURPER.PAS
