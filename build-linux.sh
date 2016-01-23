#!/bin/bash

cd SOURCE/EDITOR
fpc -B EDITOR.PAS -Fi../COMMON -Fu../COMMON -Fu../../../rmdoor -FE../../bin/i386-linux

cd ../USURPER
fpc -B USURPER.PAS -Fi../COMMON -Fu../COMMON -Fu../../../rmdoor -FE../../bin/i386-linux
