{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
unit ddigi;

{$S-,V-,R-}

interface

uses
  dos;

type
  Idarray = array[1..8] of char;

var
  AsyncStat: word;
  dport_num: integer;
  nameptr:   ^idarray;
  OutReady:  boolean;

function digi_Init_driver: boolean;
function digi_deinit_driver: boolean;
function digi_buffer_check: boolean;
procedure digi_send(c: char);
function digi_receive(var c: char): boolean;
function digi_carrier_present: boolean;
procedure digi_set_modem;
function digi_set_baud(n: longint; WordSize: byte; Parity: char; StopBits: byte): boolean;
procedure digi_flush_io;
procedure digi_flush_input;
procedure digi_flush_output;
procedure digi_Get_Info(var drivername: string);
procedure EnableTimeOutError;
procedure Digi_Break(StatusCode: word);

implementation

const
  dtrmask = 1;
  rtsmask = 2;
type
  BytePtr = ^byte;
var
  EBIOSok, DTRok, RTSok: boolean;
  CharReadyP: BytePtr;

{$IFDEF MSDOS}
function digi_Init_driver: boolean;
var
  regs: registers;
begin;
  with regs do                         { Get Channel Parameters }
  begin
    ah := $0C;
    dx := dport_num;
  end;
  intr($14, regs);
  if regs.ah = $FF then
    digi_init_driver := False
  else
    digi_init_driver := True;
  { Checks for extended Bios }
  asm
           MOV     AH,$F4
           MOV     AL,$00
           MOV     DX,dport_num
           INT     $14
  end;
  if regs.ax = $000 then
    EbiosOk := True
  else
    EbiosOk := False;

  with regs do                         { checks modem dtr/rts status }
  begin
    ah := $05;
    al := $00;
    dx := dport_num;
  end;
  intr($14, regs);
  if (regs.bl and DTRmask) <> $00 then
    DTRok := True
  else
    DTRok := False;
  if (regs.bl and RTSmask) <> $00 then
    RTSok := True
  else
    RTSok := False;

  OutReady := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function digi_Init_driver: boolean;
begin
  WriteLn('REEPORT DDIGI digi_Init_driver');
end;

{$ENDIF}

function digi_deinit_driver;  { A do nada routine, no deinit calls exist. }
begin
  digi_deinit_driver := True;
end;

{$IFDEF MSDOS}
function digi_buffer_check: boolean;
var
  regs: registers;
begin;
  with regs do
  begin
    ah := $03;
    dx := dport_num;
  end;
  intr($14, regs);
  if (regs.ah and $01) <> $00 then
    { data ready bit               } digi_buffer_check := True        { checks if byte ready to send }
  else
    digi_buffer_check := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function digi_buffer_check: boolean;
begin
  WriteLn('REEPORT DDIGI digi_buffer_check');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure digi_send(c: char);
var
  regs: registers;
begin;
  with regs do
  begin
    ah := $01;
    al := byte(c);
    dx := dport_num;
  end;
  intr($14, regs);
  { bit 5 set on = buffer space avail }
  if (regs.ah and $20) <> $00 then
    OutReady := True
  else
    OutReady := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure digi_send(c: char);
begin
  WriteLn('REEPORT DDIGI digi_send');
end;

{$ENDIF}

{$IFDEF MSDOS}
function digi_receive(var c: char): boolean;
var
  regs: registers;
begin;
  c := #0;
  digi_receive := False;
  if digi_buffer_check then
  begin
    with regs do
    begin
      ah := $02;
      dx := dport_num;
    end;
    intr($14, regs);
    if (regs.ah and $8E) = $00 then
    begin
      c := chr(regs.al);
      digi_receive := True;
    end;
  end;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function digi_receive(var c: char): boolean;
begin
  WriteLn('REEPORT DDIGI digi_receive');
end;

{$ENDIF}

{$IFDEF MSDOS}
function digi_carrier_present: boolean;
var
  regs: registers;
begin;
  with regs do
  begin
    ah := $03;
    dx := dport_num;
  end;
  intr($14, regs);
  if (regs.al and $80) <> $00 then
    { carrier present bit } digi_carrier_present := True
  else
    digi_carrier_present := False;
  if (regs.ah and $20) <> $00 then
    { bit 5 set on = buffer space avail } OutReady := True                    { thus can check if out buffer ready}
  else
    OutReady := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function digi_carrier_present: boolean;
begin
  WriteLn('REEPORT DDIGI digi_carrier_present');
end;

{$ENDIF}

function ExtBaud(n: longint): byte;
var
  b: byte;
  w: word;
begin
  b := $00;
  w := n;

  if n > 76800 then
    { 115200 } b := $0C
  else
  if n > 57600 then
    {  76800 } b := $0B
  else
    case w of
      300: b := $02;
      600: b := $03;
      1200: b := $04;
      1800: b := $11;
      2400: b := $05;
      4800: b := $06;
      4801..9600: b := $07;
      9601..19200: b := $08;
      19201..38400: b := $09;
      38401..57600: b := $0A;
    end;
  ExtBaud := b;
end;

{$IFDEF MSDOS}
procedure digi_set_modem;
var
  regs: registers;
begin
  with regs do
  begin
    dx := dport_num;
    ah := $05;
    al := $01;
    if dtrok then
      bl := bl or dtrmask;
    if rtsok then
      bl := bl or rtsmask;
  end;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure digi_set_modem;
begin
  WriteLn('REEPORT DDIGI digi_set_modem');
end;

{$ENDIF}

 { This is included for completeness only }
 { Most sysops don't want a door to reinitiallize their board }
 { so this is by passed.                                      }
{$IFDEF MSDOS}
function digi_set_baud;      { new form digiboard init }
var
  regs: registers;
begin;

  with regs do
  begin
    ah := $04;
    al := $00;
    dx := dport_num;
    case parity of
      'N': bh := $00;
      'O': bh := $01;
      'E': bh := $02;
    end;                  {0 = none/ 1 = odd / 2 = even }
    case stopbits of
      1: bl := $00;
      2: bl := $01;
    end;
    case wordsize of
      5: ch := $00;
      6: ch := $01;
      7: ch := $02;
      8: ch := $03;
    end;
    cl := ExtBaud(n);      { set baud rate }
  end;
  intr($14, regs);
  if regs.ah = $FF then
    digi_set_baud := False
  else
  begin
    digi_set_baud := True;
    digi_set_modem;
  end;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function digi_set_baud;      { new form digiboard init }
begin
  WriteLn('REEPORT DDIGI digi_set_baud');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure digi_flush_io;
var
  regs: registers;
begin;
  regs.ah := $09;
  regs.dx := dport_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure digi_flush_io;
begin
  WriteLn('REEPORT DDIGI digi_flush_io');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure digi_flush_input;
var
  regs: registers;
begin;
  regs.ah := $10;
  regs.dx := dport_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure digi_flush_input;
begin
  WriteLn('REEPORT DDIGI digi_flush_input');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure digi_flush_output;
var
  regs: registers;
begin;
  regs.ah := $11;
  regs.dx := dport_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure digi_flush_output;
begin
  WriteLn('REEPORT DDIGI digi_flush_output');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure digi_Get_Info(var drivername: string);
const
  dname: array[1..5] of
    string[6] = ('COM/Xi', 'MC/Xi', 'PC/Xe', 'PC/Xi', 'PC/Xm');
var
  i:       byte;
  regs:    registers;
  d, s, o: string;
  versno:  word;
begin;
  versno := 0;
  d := '';s := '';o := ' ';
  with regs do
  begin
    ah := $06;
    al := $ff;
    dx := dport_num;
  end;
  intr($14, regs);
  nameptr := ptr(regs.es, regs.bx);
  i := 1;
  while (i < 8) and (nameptr^[i] <> #0) do
    Inc(i);
  move(nameptr^, d[1], i);
  d[0] := char(i);

  with regs do
  begin
    ah := $06;
    al := $01;
    dx := dport_num;
  end;
  intr($14, regs);
  if regs.ah <> $ff then
  begin
    versno := regs.bx;
    str(versno, o);
    s := ' Version[' + o + '] : ';
    str(regs.ax, o);
  end;
  d := d + s;

  s := '';

  with regs do
  begin
    ah := $06;
    al := $02;
    bx := $000;
    dx := dport_num;
  end;
  intr($14, regs);
  if regs.ah <> $ff then
    if regs.al in [$01..$05] then
      s := dname[regs.al]
    else str(regs.al, s);
  drivername := d + s + o;

end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure digi_Get_Info(var drivername: string);
begin
  WriteLn('REEPORT DDIGI digi_Get_Info');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure EnableTimeOutError;
var
  regs: registers;
begin;
  with regs do
  begin
    ah := $20;
    al := $01;
    dx := dport_num;
  end;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure EnableTimeOutError;
begin
  WriteLn('REEPORT DDIGI EnableTimeOutError');
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure Digi_Break(StatusCode: word);  { send break }
var
  regs: registers;
begin;
  with regs do
  begin
    ah := $07;
    al := $00;       { defaults 250 millisecs }
    dx := dport_num;
  end;
  intr($14, regs);
  AsyncStat := StatusCode;
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure Digi_Break(StatusCode: word);  { send break }
begin
  WriteLn('REEPORT DDIGI Digi_Break');
end;

{$ENDIF}


end.
