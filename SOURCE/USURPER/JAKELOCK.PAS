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


Unit JakeLock; {Usurper - Filelocking routine used when
                          Config.NetShareMethod=RecordLocking}

Interface

Uses Init;

function File_Lock(var F; Action: filAction; FPos,Len: Longint): Word;

Implementation

Uses Dos {$IFNDEF MSDOS}, Windows{$ENDIF};

{this routine was taken from the SWAG archive, locks records AND files}
{$IFDEF MSDOS}
function File_Lock(var F; Action: filAction; FPos,Len: Longint): Word;
 assembler;
asm
  je @@End
  mov al, Action  {0=Lock,1=Unlock}
  mov ah, $5C     {Dos lock function}
  les si, F       {Load F}
  mov bx, es:[si] {Get file handle}
  les dx, Fpos
  mov cx, es      {CX:DI=Begin position}
  les di, len
  mov si, es      {SI:DI length lock area}
  int 21h         {MS-DOS}
  jc @@End        {If error, return AX}
  xor ax, ax      {Else, return 0}
@@End:

end; {File_Lock *end*}
{$ENDIF}
{$IFNDEF MSDOS}
// From ELEBBS (and modified)
function File_Lock(var F; Action: filAction; FPos,Len: Longint): Word;
var Tmp: Word;
    StrtHi: Longint;
    StrtLo: Longint;
    LgHi: Longint;
    LgLo: Longint;
begin
  StrtHi := FPos Shr 16;
  StrtLo := FPos and $FFFF;
  LgHi := Len Shr 16;
  LgLo := Len and $FFFF;

  if (Action = FLock) then
  begin
    if NOT Windows.LockFile(FileRec(F).Handle, StrtLo, StrtHi, LgLo, LgHi) then
      Tmp := GetLastError
        else Tmp := 00;
  end else
  if (Action = FUnlock) then
  begin
    if NOT Windows.UnLockFile(FileRec(F).Handle, StrtLo, StrtHi, LgLo, LgHi) then
      Tmp := GetLastError
        else Tmp := 00;
  end;
       
  File_Lock := Tmp;
end; { func. LockFile }
{$ENDIF}

end. {Unit JakeLock .end.}
