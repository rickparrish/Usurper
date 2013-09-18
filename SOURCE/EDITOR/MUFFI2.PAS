{$I DEFINES.INC}
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

unit Muffi2;

interface

procedure Terminate;

implementation

uses
  init, file_io;

var txt:         Text;
  a, sysop, bbs: string[90];

procedure Terminate;
label
  9044,
  9046,
  8088,
  9045;

var
  i, j:  integer;
  yy, x: longint;
  regnr: longint;

begin

  regnr := 0;
  registered := 0;

  Assign(txt, ucfg);
  if f_exists(ucfg) = True then
  begin
    reset(txt);
    readln(txt, sysop);
    readln(txt, bbs);
    readln(txt, a);
    readln(txt, a);
    readln(txt, a);
    Close(txt);
  end else
  begin
    sysop := '';
    bbs := '';
    a := '';
  end;

  val(a, regnr, j);
  if j <> 0 then regnr := 0;

  {bbs, sysop, regnr}
  registered := 0;
  if (length(bbs) > 2) and (length(sysop) > 3) then
  begin
    a := bbs + sysop + ' ';
    j := length(a);
    yy := 0;
    x := 0;
    for i := 1 to length(a) do
    begin
      x := x + (Ord(a[i]) * i);
      yy := yy + (Ord(a[i]) * j);
      j := j - 1;
    end;
    for i := 1 to length(sysop) do
    begin
      x := x + Ord(sysop[i]);
    end;
    goto 9046;
    9044: x := x + Ord(bbs[1]);
    x := x + Ord(sysop[2]);
    x := x * 13;
    yy := yy + 2;
    x := x div 4;
    x := x * 523;
    9046: x := x + Ord(bbs[1]);
    x := x + Ord(sysop[2]);

    if ubeta = False then
    begin
      x := x * 4;
      x := x div 3;
      x := x * 213;
    end else
    begin
      x := x * 123;
    end;

    goto 8088;
    8088: x := x + yy + 1;
    if (x = regnr) and (x <> 0) then registered := 1;
  end;

  if registered = 1 then goto 9045;
  9045:
    {registration is free, from 0.18}
    registered := 1;

end;

end.
