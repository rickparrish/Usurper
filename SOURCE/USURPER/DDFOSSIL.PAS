
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

procedure async_send(c: char);
var
 regs: registers;
begin;
 with regs do
  begin
    ah:=$01;
    al:=byte(c);
    dx:=port_num;
  end;
 intr($14,regs);
end;

procedure async_send_string(s: string);
var
 a: integer;
begin;
 for a:=1 to length(s) do async_send(s[a]);
end;

function async_receive(var ch: char): boolean;
var
 regs: registers;
begin;
 ch:=#0;
 regs.ah:=$03;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.ah and 1)=1 then begin;
  regs.ah:=$02;
  regs.dx:=port_num;
  intr($14,regs);
  ch:=chr(regs.al);
  async_receive:=true;
 end else async_receive:=false;
end;

function async_carrier_drop: boolean;
var
 regs: registers;
begin;
 regs.ah:=$03;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.al and $80)<>0 then async_carrier_drop:=false else async_carrier_drop:=true;
end;

function async_carrier_present: boolean;
var
 regs: registers;
begin;
 regs.ah:=$03;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.al and $80)<>0 then async_carrier_present:=true else async_carrier_present:=false;
end;

function async_buffer_check: boolean;
var
 regs: registers;
begin;
 regs.ah:=$03;
 regs.dx:=port_num;
 intr($14,regs);
 if (regs.ah and 1)=1 then async_buffer_check:=true else async_buffer_check:=false;
end;

function async_init_fossil: boolean;
var
 regs: registers;
begin;
 regs.ah:=$04;
 regs.bx:=$00;
 regs.dx:=port_num;
 intr($14,regs);
 if regs.ax=$1954 then async_init_fossil:=true else async_init_fossil:=false;
end;

procedure async_deinit_fossil;
var
 regs: registers;
begin;
 regs.ah:=$05;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_set_dtr(state: boolean);
var
 regs: registers;
begin;
 regs.ah:=$06;
 if state then regs.al:=1 else regs.al:=0;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_flush_output;
var
 regs: registers;
begin;
 regs.ah:=$08;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_purge_output;
var
 regs: registers;
begin;
 regs.ah:=$09;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_purge_input;
var
 regs: registers;
begin;
 regs.ah:=$0A;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_watchdog_on;
var
 regs: registers;
begin;
 regs.ah:=$14;
 regs.al:=$01;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_watchdog_off;
var
 regs: registers;
begin;
 regs.ah:=$14;
 regs.al:=$00;
 regs.dx:=port_num;
 intr($14,regs);
end;

procedure async_warm_reboot;
var
 regs: registers;
begin;
 regs.ah:=$17;
 regs.al:=$01;
 intr($14,regs);
end;

procedure async_cold_reboot;
var
 regs: registers;
begin;
 regs.ah:=$17;
 regs.al:=$00;
 intr($14,regs);
end;

procedure async_set_baud(n: longint);
var
 w : word;
 regs: registers;
begin;
 regs.ah:=$00;
 regs.al:=$03;
 regs.dx:=port_num;
 w := n;

 If n > 76800 then         {115200 }
   regs.al:=regs.al or $80
 else
 If n > 57600 then         { 76800 }
   regs.al:=regs.al or $60
 else
   case w of
     300  : regs.al:=regs.al or $40;
     600  : regs.al:=regs.al or $60;
     1200 : regs.al:=regs.al or $80;
     2400 : regs.al:=regs.al or $A0;
     4800 : regs.al:=regs.al or $C0;
     9600 : regs.al:=regs.al or $E0;
     9601..19200:  regs.al:=regs.al or $00;
     19201..38400: regs.al:=regs.al or $20;
     38401..57600: regs.al:=regs.al or $40;
   end;

 intr($14,regs);
end;

procedure async_set_baudBnu(n: longint);
var
 w : word;
 regs: registers;
begin;
 regs.ah:=$00;
 regs.al:=$03;
 regs.dx:=port_num;
 w := n;

 If n>38400 then
  begin
    If n > 57600 then               {115200}
      regs.al:=regs.al or $80
    else
      regs.al:=regs.al or $60;       { 57600 }
    regs.bx:=$69DC;
    regs.cx:=$69DC;
  end
 else
   case w of
     300  : regs.al:=regs.al or $40;
     600  : regs.al:=regs.al or $60;
     1200 : regs.al:=regs.al or $80;
     2400 : regs.al:=regs.al or $A0;
     4800 : regs.al:=regs.al or $C0;
     9600 : regs.al:=regs.al or $E0;
     9601..19200:  regs.al:=regs.al or $00;
     19201..38400: regs.al:=regs.al or $20;
   end;

 intr($14,regs);
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
var
 regs: registers;
begin;
 regs.ah:=$0F;
 regs.al:=$00;
 if softtran then regs.al:=regs.al or $01;
 if Hard then regs.al:=regs.al or $02;
 if SoftRecv then regs.al:=regs.al or $08;
 regs.al:=regs.al or $F0;
 Intr($14,regs);
end;

procedure async_get_fossil_data;
var
 regs: registers;
begin;
 regs.ah:=$1B;
 regs.cx:=sizeof(fossildata);
 regs.dx:=port_num;
 regs.es:=seg(fossildata);
 regs.di:=ofs(fossildata);
 intr($14,regs);
end;

procedure Async_Buffer_Status(var Insize,Infree,OutSize,Outfree: word;
                              var fossilname:string);
var
 i:byte;
begin;
 async_get_fossil_data;
 insize:=fossildata.ibufr;
 infree:=fossildata.ifree;
 outsize:=fossildata.obufr;
 outfree:=fossildata.ofree;
 i := 1;
 while (i<62) and (fossildata.ident^[i] <> #0)  do
   inc(i);
 move(fossildata.ident^, fossilname[1], i);
 fossilname[0] := char(i);
end;

end.
