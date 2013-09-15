{$I DEFINES.INC}

unit ddfossil;
{$S-,V-,R-}

interface
uses dos;

type
 ASCIZ_id = array[1..128] of char;
 ascizptr  = ^asciz_id;

 fossildatatype = record
                   strsize: word;
                   majver: byte;
                   minver: byte;
                   ident: ascizPtr;
                   ibufr: word;
                   ifree: word;
                   obufr: word;
                   ofree: word;
                   swidth: byte;
                   sheight: byte;
                   baud: byte;
                  end;
var
 port_num: integer;
 fossildata: fossildatatype;

procedure async_send(c: char);
procedure async_send_string(s: string);
function async_receive(var ch: char): boolean;
function async_carrier_drop: boolean;
function async_carrier_present : boolean;
function async_buffer_check: boolean;
function async_init_fossil: boolean;
procedure async_deinit_fossil;
procedure async_flush_output;
procedure async_purge_output;
procedure async_purge_input;
procedure async_set_dtr(state: boolean);
procedure async_watchdog_on;
procedure async_watchdog_off;
procedure async_warm_reboot;
procedure async_cold_reboot;
procedure async_set_baud(n: longint);
procedure async_set_baudBnu(n: longint);
procedure async_set_flow(SoftTran,Hard,SoftRecv: boolean);
procedure Async_Buffer_Status(var Insize,Infree,OutSize,Outfree: word;
                              var fossilname:string);

implementation

uses
  Comm;

procedure async_send(c: char);
begin
  CommWrite(c);
end;

procedure async_send_string(s: string);
begin
  CommWrite(s);
end;

function async_receive(var ch: char): boolean;
begin
  ch := #0;
  async_receive := false;

  // Loop until we get a key we want
  while (CommCharAvail) and (ch = #0) do
  begin
    // Get next char
    ch := CommReadChar;
    async_receive := true;
  end;
end;

function async_carrier_drop: boolean;
begin
  async_carrier_drop := false;
  async_carrier_drop := NOT CommCarrier;
end;

function async_carrier_present: boolean;
begin
  async_carrier_present := true;
  async_carrier_present := CommCarrier;
end;

function async_buffer_check: boolean;
begin
  async_buffer_check := false;
  async_buffer_check := CommCharAvail;
end;

function async_init_fossil: boolean;
begin
  CommOpen(port_num);
  async_init_fossil := true;
end;

procedure async_deinit_fossil;
begin
  CommClose(false);
end;

procedure async_set_dtr(state: boolean);
begin
  WriteLn('REEPORT DDFOSSIL async_set_dtr'); Halt;
end;

procedure async_flush_output;
begin
  WriteLn('REEPORT ddfossil async_flush_output'); Halt;
end;

procedure async_purge_output;
begin
  WriteLn('REEPORT ddfossil async_purge_output'); Halt;
end;

procedure async_purge_input;
begin
  WriteLn('REEPORT ddfossil async_purge_input'); Halt;
end;

procedure async_watchdog_on;
begin
  WriteLn('REEPORT ddfossil async_watchdog_on'); Halt;
end;

procedure async_watchdog_off;
begin
  WriteLn('REEPORT ddfossil async_watchdog_off'); Halt;
end;

procedure async_warm_reboot;
begin
  WriteLn('REEPORT ddfossil async_warm_reboot'); Halt;
end;

procedure async_cold_reboot;
begin
  WriteLn('REEPORT ddfossil async_cold_reboot'); Halt;
end;

procedure async_set_baud(n: longint);
begin
  WriteLn('REEPORT ddfossil async_set_baud'); Halt;
end;

procedure async_set_baudBnu(n: longint);
begin
  WriteLn('REEPORT ddfossil async_set_baudBnu'); Halt;
end;

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

procedure async_set_flow(SoftTran,Hard,SoftRecv: boolean);
begin
  WriteLn('REEPORT ddfossil async_set_flow'); Halt;
end;

procedure async_get_fossil_data;
begin
  WriteLn('REEPORT ddfossil async_get_fossil_data'); Halt;
end;

procedure Async_Buffer_Status(var Insize,Infree,OutSize,Outfree: word;
                              var fossilname:string);
var FInFree, FOutFree, FInUsed, FOutUsed: Longint;
begin
  WriteLn('REEPORT ddfossil Async_Buffer_Status'); Halt;
end;

end.
