{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}

{

Copyright 2007 Jakob Dangarden

 This file is part of Usurper.

    Usurper is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Usurper is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Usurper; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}


unit JakeLock; {Usurper - Filelocking routine used when
                          Config.NetShareMethod=RecordLocking}

interface

uses
  Init;

function File_Lock(var F; Action: filAction; FPos, Len: longint): word;

implementation

uses
  Dos {$IFNDEF MSDOS}, RPPort{$ENDIF};

{this routine was taken from the SWAG archive, locks records AND files}
{$IFDEF MSDOS}
function File_Lock(var F; Action: filAction; FPos, Len: longint): word;
  assembler;
asm
         JE      @@end
         MOV     AL, Action  {0=Lock,1=Unlock}
         MOV     AH, $5C     {Dos lock function}
         LES     SI, F       {Load F}
         MOV     BX, ES:[SI] {Get file handle}
         LES     DX, Fpos
         MOV     CX, ES      {CX:DI=Begin position}
         LES     DI, len
         MOV     SI, ES      {SI:DI length lock area}
         INT     21h         {MS-DOS}
         JC      @@end        {If error, return AX}
         XOR     AX, AX      {Else, return 0}
         @@end:
end; {File_Lock *end*}
{$ENDIF}
{$IFNDEF MSDOS}
function File_Lock(var F; Action: filAction; FPos, Len: longint): word;
begin
  if (Action = FLock) then
  begin
    File_Lock := RPLockFile(FileRec(F).Handle, FPos, Len);
  end else if (Action = FUnlock) then
  begin
    File_Lock := RPUnLockFile(FileRec(F).Handle, FPos, Len);
  end;
end;
{ func. LockFile }
{$ENDIF}

end. {Unit JakeLock .end.}
