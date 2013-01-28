{$IFDEF WIN32}
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

Uses Dos;

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
{$IFDEF WIN32}
function File_Lock(var F; Action: filAction; FPos,Len: Longint): Word;
begin
  WriteLn('REETODO JAKELOCK File_Lock'); Halt;
end;
{$ENDIF}

end. {Unit JakeLock .end.}
