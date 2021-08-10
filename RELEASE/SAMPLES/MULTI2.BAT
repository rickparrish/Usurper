@ECHO OFF
REM
REM Usurper multinode batch file for PcBoard
REM   This is a sample of a batch file to be used in a multinode Setup
REM
REM   %1 is the Node Number which can be passed to the
REM   batch file from the BBS software.
REM   (With RemoteAccess BBS software, this can be accomplished by
REM   placing *N on the command line in ; execute Sub-program)
REM
REM /N1 tells Usurper thate it's firing up on node 1. 
REM  This switch is only necessary when node information is not
REM  available from dropfile.    
REM
REM /P{path to dropfile} tells Usurper where to look for dropfile.
REM  Look in SYSOP.DOC for more command line options and batc file
REM  examples.
REM
REM /N1 tells Usurper that it's firing up on node 1. 
REM  This switch is only necessary when node information is not
REM  available from dropfile.    
REM
REM /P{path to dropfile} tells Usurper where to look for dropfile.
REM  Look in SYSOP.DOC for more command line options and batc file
REM  examples.
REM
REM DONT FORGET!:
REM activate the section in the configuration file for multi-node and lock it.
REM (example from Chris Capo)
REM
REM *******START BAT********

If %pcbnode% == 1 Goto Node1
If %pcbnode% == 2 Goto Node2

:node1
usurper.exe /M /pc:\pcb\pcbnode1
goto end

:Node2
Usurper.exe /M /pc:\pcb\pcbnode2
goto end

:end
board
