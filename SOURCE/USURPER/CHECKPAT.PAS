{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}

unit checkpat;

{
   --- Version 3.3 91-11-21 16:12 ---

   CHECKPAT.PAS: Wrapper unit for path check function.

   Needs Assembler file 'checkpat.asm' (assembled as 'checkpap.obj').

Public domain software by

        Thomas Wagner
        Ferrari electronic GmbH
        Beusselstrasse 27
        D-1000 Berlin 21
        Germany

        BIXname: twagner
}

interface

const

  INF_NODIR = 1;  { Don't interpret name as directory }

  { Error Return codes }

  ERR_DRIVE     = -1;  { Invalid drive }
  ERR_PATH      = -2;  { Invalid path }
  ERR_FNAME     = -3;  { Malformed filename }
  ERR_DRIVECHAR = -4;  { Illegal drive letter }
  ERR_PATHLEN   = -5;  { Path too long }
  ERR_CRITICAL  = -6;  { Critical error (invalid drive) }

  { Good returns (values ORed): }

  HAS_WILD    = 1;  { Filename/ext has wildcard characters }
  HAS_EXT     = 2;  { Extension specified }
  HAS_FNAME   = 4;  { Filename specified }
  HAS_PATH    = 8;  { Path specified }
  HAS_DRIVE   = $10;  { Drive specified }
  FILE_EXISTS = $20;  { File exists, upper byte has attributes }
  IS_DIR      = $1000;  { Directory, upper byte has attributes }


  { The file attributes returned if FILE_EXISTS or IS_DIR is set }

  IS_READ_ONLY = $0100;
  IS_HIDDEN    = $0200;
  IS_SYSTEM    = $0400;
  IS_ARCHIVED  = $2000;
  IS_DEVICE    = $4000;


function checkpath(var Name; inflags: integer; var drive; var dir; var fname; var ext; var fullpath): integer;

function exists(var fname): boolean;

implementation

{$IFDEF MSDOS}
{$L checkpap}
{$ENDIF}
function checkpath(var Name; inflags: integer; var drive; var dir; var fname; var ext; var fullpath): integer; {$IFDEF MSDOS}external;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT CHECKPAT checkpath'); Halt;
end;
{$ENDIF}

function exists(var fname): boolean; {$IFDEF MSDOS}external;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT CHECKPAT exists'); Halt;
end;
{$ENDIF}


end.
