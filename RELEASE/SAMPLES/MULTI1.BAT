@ECHO OFF
REM
REM BATCH FILE FOR USURPER
REM   This is a sample of a batch file to be used
REM   in a multinode Setup
REM   %1 is the Node Number which can be passed to the
REM   batch file from the BBS software.
REM   (With RemoteAccess BBS software, this can be accomplished by
REM   placing *N on the command line in ; execute Sub-program)
REM
REM /N1 tells Usurper that it's firing up on node 1. 
REM  This switch is only necessary when node information is not
REM  available from dropfile.    
REM
REM /P{path to dropfile} tells Usurper where to look for dropfile.
REM  Look in SYSOP.DOC for more command line options and batc file
REM  examples. 
REM


CD\BBS\DOORS\USURPER
Usurper /N%1 /PC:\BBS\NODE%1
CD\BBS\NODE%1
