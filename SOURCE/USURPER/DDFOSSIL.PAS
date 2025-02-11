{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}

unit ddfossil;

{$S-,V-,R-}

interface

uses
  dos;

type
  ASCIZ_id = array[1..128] of char;
  ascizptr = ^asciz_id;

  fossildatatype = record
    strsize: word;
    majver:  byte;
    minver:  byte;
    ident:   ascizPtr;
    ibufr:   word;
    ifree:   word;
    obufr:   word;
    ofree:   word;
    swidth:  byte;
    sheight: byte;
    baud:    byte;
  end;
var
  port_num:   longint;
  fossildata: fossildatatype;

procedure async_send(c: char);
procedure async_send_string(s: string);
function async_receive(var ch: char): boolean;
function async_carrier_drop: boolean;
function async_carrier_present: boolean;
function async_buffer_check: boolean;
function async_init_fossil: boolean;
procedure async_deinit_fossil;
procedure async_flush_output;
procedure async_purge_output;
procedure async_purge_input;
procedure async_set_baud(n: longint);
procedure async_set_baudBnu(n: longint);
procedure Async_Buffer_Status(var Insize, Infree, OutSize, Outfree: word; var fossilname: string);

implementation

{$IFNDEF MSDOS}
uses
  Comm, RPPort;

var LastChar: char;
  DidInit:    boolean;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_send(c: char);
var
  regs: registers;
begin
  with regs do
  begin
    ah := $01;
    al := byte(c);
    dx := port_num;
  end;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_send(c: char);
begin
  if not (DidInit) then
    Exit;
  CommWrite(c);
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_send_string(s: string);
var
  a: integer;
begin
  { REETODO This could probably be optimized to send a block at a time, not a character at a time }
  for a := 1 to length(s) do
    async_send(s[a]);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_send_string(s: string);
begin
  if not (DidInit) then
    Exit;
  CommWrite(s);
end;

{$ENDIF}

{$IFDEF MSDOS}
function async_receive(var ch: char): boolean;
var
  regs: registers;
begin
  ch := #0;
  regs.ah := $03;
  regs.dx := port_num;
  intr($14, regs);
  if (regs.ah and 1) = 1 then
  begin
    regs.ah := $02;
    regs.dx := port_num;
    intr($14, regs);
    ch := chr(regs.al);
    async_receive := True;
  end else async_receive := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function async_receive(var ch: char): boolean;
begin
  ch := #0;
  async_receive := False;
  if not (DidInit) then
    Exit;

  // Loop until we get a key we want
  while (CommCharAvail) and (ch = #0) do
  begin
    // Get next char
    ch := CommReadChar;

    // Handle translating the LF character
    if (ch = #10) then
    begin
      if (LastChar = #13) then
      begin
        // Last was CR, so ignore LF
        LastChar := #0;
        ch := #0;
      end else
      begin
        // Last was not CR, so translate this LF to CR
        ch := #13;
        LastChar := ch;
        async_receive := True;
        Exit;
      end;
    end else
    begin
      LastChar := ch;
      async_receive := True;
      Exit;
    end;
  end;
end;

{$ENDIF}

{$IFDEF MSDOS}
function async_carrier_drop: boolean;
var
  regs: registers;
begin
  regs.ah := $03;
  regs.dx := port_num;
  intr($14, regs);
  if (regs.al and $80) <> 0 then
    async_carrier_drop := False else async_carrier_drop := True;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function async_carrier_drop: boolean;
begin
  async_carrier_drop := False;
  if not (DidInit) then
    Exit;
  async_carrier_drop := not CommCarrier;
end;

{$ENDIF}

{$IFDEF MSDOS}
function async_carrier_present: boolean;
var
  regs: registers;
begin
  regs.ah := $03;
  regs.dx := port_num;
  intr($14, regs);
  if (regs.al and $80) <> 0 then
    async_carrier_present := True else async_carrier_present := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function async_carrier_present: boolean;
begin
  async_carrier_present := True;
  if not (DidInit) then
    Exit;
  async_carrier_present := CommCarrier;
end;

{$ENDIF}

{$IFDEF MSDOS}
function async_buffer_check: boolean;
var
  regs: registers;
begin
  regs.ah := $03;
  regs.dx := port_num;
  intr($14, regs);
  if (regs.ah and 1) = 1 then
    async_buffer_check := True else async_buffer_check := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function async_buffer_check: boolean;
begin
  async_buffer_check := False;
  if not (DidInit) then
    Exit;
  async_buffer_check := CommCharAvail;
end;

{$ENDIF}

{$IFDEF MSDOS}
function async_init_fossil: boolean;
var
  regs: registers;
begin
  regs.ah := $04;
  regs.bx := $00;
  regs.dx := port_num;
  intr($14, regs);
  if regs.ax = $1954 then
    async_init_fossil := True else async_init_fossil := False;
end;

{$ENDIF}
{$IFNDEF MSDOS}
function async_init_fossil: boolean;
begin
  if (DidInit) then
    Exit;
  DidInit := True;
  CommOpen(port_num);
  async_init_fossil := True;
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_deinit_fossil;
var
  regs: registers;
begin
  regs.ah := $05;
  regs.dx := port_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_deinit_fossil;
begin
  if not (DidInit) then
    Exit;
  CommClose(false);
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_flush_output;
var
  regs: registers;
begin
  regs.ah := $08;
  regs.dx := port_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure MySlice;
begin
  RPSleep(1);
end;

procedure async_flush_output;
begin
  CommFlushOutBuffer();
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_purge_output;
var
  regs: registers;
begin
  regs.ah := $09;
  regs.dx := port_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_purge_output;
begin
  if not (DidInit) then
    Exit;
  CommPurgeOutBuffer;
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_purge_input;
var
  regs: registers;
begin
  regs.ah := $0A;
  regs.dx := port_num;
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_purge_input;
begin
  if not (DidInit) then
    Exit;
  CommPurgeInBuffer;
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_set_baud(n: longint);
var
  w:    word;
  regs: registers;
begin
  regs.ah := $00;
  regs.al := $03;
  regs.dx := port_num;
  w := n;

  if n > 76800 then
    {115200 } regs.al := regs.al or $80
  else
  if n > 57600 then
    { 76800 } regs.al := regs.al or $60
  else
    case w of
      300: regs.al := regs.al or $40;
      600: regs.al := regs.al or $60;
      1200: regs.al := regs.al or $80;
      2400: regs.al := regs.al or $A0;
      4800: regs.al := regs.al or $C0;
      9600: regs.al := regs.al or $E0;
      9601..19200: regs.al := regs.al or $00;
      19201..38400: regs.al := regs.al or $20;
      38401..57600: regs.al := regs.al or $40;
    end;

  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_set_baud(n: longint);
begin
  if not (DidInit) then
    Exit;
  CommSetBaud(n);
end;

{$ENDIF}

{$IFDEF MSDOS}
procedure async_set_baudBnu(n: longint);
var
  w:    word;
  regs: registers;
begin
  regs.ah := $00;
  regs.al := $03;
  regs.dx := port_num;
  w := n;

  if n > 38400 then
  begin
    if n > 57600 then
      {115200} regs.al := regs.al or $80
    else
      regs.al := regs.al or $60;       { 57600 }
    regs.bx := $69DC;
    regs.cx := $69DC;
  end else
    case w of
      300: regs.al := regs.al or $40;
      600: regs.al := regs.al or $60;
      1200: regs.al := regs.al or $80;
      2400: regs.al := regs.al or $A0;
      4800: regs.al := regs.al or $C0;
      9600: regs.al := regs.al or $E0;
      9601..19200: regs.al := regs.al or $00;
      19201..38400: regs.al := regs.al or $20;
    end;

  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure async_set_baudBnu(n: longint);
begin
  if not (DidInit) then
    Exit;
  CommSetBaud(n);
end;

{$ENDIF}

{
The "enhanced" port rate settings are accessed by setting the both BX
and CX CPU registeres to the magic value 0x69dc when calling Fn 0 (INT
14H, AH=0). This changes the meaning of the meaning of the three bits
used to set the baud rate, bits 5-7, according to this table:

    Value       Standard        Enhanced (BX=CX=69DCh)
    -----       --------        --------
    000           19200              75
    001           38400             110
    010             300            7200
    011             600           57600
    100            1200          115200
    101            2400          |
    110            4800          | undefined
    111            9600          |

david  }

{$IFDEF MSDOS}
procedure async_get_fossil_data;
var
  regs: registers;
begin
  regs.ah := $1B;
  regs.cx := sizeof(fossildata);
  regs.dx := port_num;
  regs.es := seg(fossildata);
  regs.di := ofs(fossildata);
  intr($14, regs);
end;

{$ENDIF}
{$IFNDEF MSDOS}
  // async_get_fossil_data is only called internally from an IFDEF MSDOS
{$ENDIF}

{$IFDEF MSDOS}
procedure Async_Buffer_Status(var Insize, Infree, OutSize, Outfree: word; var fossilname: string);
var
  i: byte;
begin
  async_get_fossil_data;
  insize := fossildata.ibufr;
  infree := fossildata.ifree;
  outsize := fossildata.obufr;
  outfree := fossildata.ofree;
  i := 1;
  while (i < 62) and (fossildata.ident^[i] <> #0) do
    Inc(i);
  move(fossildata.ident^, fossilname[1], i);
  fossilname[0] := char(i);
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure Async_Buffer_Status(var Insize, Infree, OutSize, Outfree: word; var fossilname: string);
var FInFree, FOutFree, FInUsed, FOutUsed: longint;
begin
  if not (DidInit) then
    Exit;
  CommGetBufferStatus(FInFree, FOutFree, FInUsed, FOutUsed, fossilname);
  Insize := FInFree + FInUsed;
  Infree := FInFree;
  Outsize := FOutFree + FOutUsed;
  Outfree := FOutFree;
end;

{$ENDIF}

begin
{$IFNDEF MSDOS}
  DidInit := false;
{$ENDIF}
end.
