#!/bin/bash

set -e

fpc -B -Tlinux -Px86_64 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiEDITOR -Fi../obj/x86_64-linux -FuCOMMON \
    -FU../obj/x86_64-linux -FE../bin/x86_64-linux/ \
    EDITOR/EDITOR.PAS

fpc -B -Tlinux -Px86_64 -Mtp -Scgi -CX -Cg -O3 -g -gl -Xs -XX -l -vewnhibq \
    -FiCOMMON -FiUSURPER -Fi../obj/x86_64-linux -FuCOMMON -FuUSURPER/DDPLUS \
    -Fu../../RMDoor -FU../obj/x86_64-linux -FE../bin/x86_64-linux/ \
    USURPER/USURPER.PAS
