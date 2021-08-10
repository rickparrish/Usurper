; DDplus Door Control File
;-----------------------------------------------
; The semi-colons are comment markers.  Remove them to activate option.
;
;Sysopfirst  Specifies the first name of the sysop as it will be shown to
;            the users.
;
;SysopLast   Specifies the last name of the sysop as it will be shown to
;            the users.
;
;BBSName     Specifies the name of the bbs as it will be shown to users.
;
;Mono        Will disable color on the local side. (Necessary if you are
;            running a monochrome system)
;
;BBSType     Specifies the type of bbs software under which this door program
;            will be run. Valid bbs types include:
;
;                  DOORSYS - The DOOR.SYS format (Wildcat! 4.xx, GAP, etc)
;                     RBBS - Rbbs version 16.1+  (uses DORINFOx.DEF*)
;                    QUICK - Quickbbs,Force      (uses DORINFOx.DEF**)
;                 DORINFO1 - Remote Access,others(uses DORINFO1.DEF**)
;                    PCB14 - Pcboard version 14
;                    PCB15 - Pcboard version 15
;                  PHOENIX - Phoenix bbs
;                 SPITFIRE - Spitfires drop file (SFDOORS.DAT)
;                   TRIBBS - TriBBS drop file (TRIBBS.SYS)
;                     WWIV - WWIV bbs (uses chain.txt)
;                     2AM  - Jumper.dat
;
;  Notes    *  ANSI graphics is selected when a "2" is passed in the graphics
;              parameter of the DORINFOx.DEF.   RBBS, Maximus standard.
;          **  ANSI graphics is selected when a "1" is passed in the graphics
;              parameter of the DORINFOx.DEF.   QuickBBS,Maximus,UltraBBS and
;              many shareware BBSes require this type.
;          **  Parameter of the DORINFO1.DEF.   Remote Access others.
;
;
;ComPort     For bbs types that do not have the com-port contained in their
;            door information files you will have to specify the com-port.
;            Simply put the port number (i.e. 1,2,etc) not the whole word COM1.
;
;Digi        Selecting this option will cause ddplus to use its digiboard
;            driver interface. This will not reset anything in the digiboard.
;            Support speeds up to 115,200.
;
;Fossil      Selecting this option will cause ddplus to use a fossil port
;            driver. Note - do not use both fossil and Xfossil at the same
;            time. This option initializes the port and resets the speed to
;            either the lock speed (if locked) or the baud speed.
;
;Xfossil     This is another way of selecting the fossil option.  This method
;            can support all speeds that your fossil can support.  The fossil
;            is not initialized by this option.
;
;LockBaud    This will specify a locked baud rate. If you specify this
;            parameter, then no matter what the bbs software says, this
;            baud rate will be used. [NOTE: You can also specify the locked
;            baud rate using /Bxxxx from the command line]
;
; If neither options digi, fossil, or xfossil are set the door will use its
; own internal comport handlers.
;
;Port1       If you must use a non-standard interrupt, the door can be
;Port2       configured for IRQs 0-15. The port# indicates the chosen comport
;Port3       Follow this with the port address in hex.  Afterward put the IRQ
;Port4       in decimal.  For an example if comport 3 at irq 15 and address
;            $03E8 was needed use the following:
;            PORT3 03E8 15
;
;Pausecode   Specifies the Rip pause code that your bbs uses.  This will
;            be added to muliple page Rip news file so you can use them
;            as a bulletin.  Note - this option is only useful if the door
;            indeed has rip bulletins.
;
;Maxtime     The maxtime parameter will allow you to specify a maximum time
;            per day that a user may be in the door. (i.e. if you specified
;            30 minutes, then if the user had 60 mins left, he could only play
;            for 30 mins)  Otherwise the game will use the maximum session
;            time for maximum time.
;
;Status      Specify "ON" if you wish the status line to appear at the bottom
;            of "OFF" if you wish it to be disabled.
;
;Statfore    Statfore foreground color of the status line and the major input
;            fields. (default 7  light-grey)
;
;Statback    The background color of the status line (default 1  blue)
;
;
;------------------------------ Sample Data ----------------------------------
;
SYSOPFIRST Bob
SYSOPLAST Dalton
BBSNAME The TANSTAFL BBS
;
;       ::::------- Put your bbs type here! Select from those listed above.
;       ::::
;       \/\/
BBSTYPE DOORSYS
;
;                   If you are using a bbs type that doesn't provide the com
;        ::-------- port num in it's door information file then uncomment this
;        \/         line and put your comport here.
;COMPORT 1
;
; Uncomment the next line if you wish to use the digiboard driver support
; calls.
;DIGI
;
; Uncomment the next line if you use a fossil device driver and wish to have
; the door initialize your fossil to the locked/baud speed rate.
;FOSSIL
;
; Uncomment the next line if you use a fossil device and do not wish to have
; the door reinitialize your fossil.
;XFOSSIL
;
;           ::------If you are locking ports uncomment this line and set this
;           ::      number to the port speed.
;           \/
;LOCKBAUD 57600
;
;       ::------------ If you are going to use a non-standard IRQ place the
;       ::             port address in hex one space after the PORT# option.
;       ::
;       ::  ::-------- If you have a non-standard IRQ position the IRQ number
;       \/  \/         one space after the ports' hex address. (decimal)
;PORT1 03F8 4
;PORT2 02F8 3
;PORT3 03E8 4
;PORT4 02E8 3
;                   Uncomment this line if you want to make Rip bulletins
;  ::-------------- for your BBS.  Here a Wildcat pause is shown.
;  \/
;PAUSECODE @PAUSE@
;
;------------------------------ End of File ----------------------------------

