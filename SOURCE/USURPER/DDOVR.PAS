{$I DEFINES.INC}
unit ddovr;
{$O+}

interface

uses crt, init;

{procedure showhelp;}

procedure GetBBSInfo(
 bbstype: byte;
 var user_first_name,user_last_name: string;
 var user_access_level: word;
 var bbs_time_left: integer;
 var com_port: integer;
 var baud_rate : Longint;
 var node_num: integer;
 var local: boolean;
 var graphics: byte;
 var color1: boolean;
 var color_chg: boolean;
 var board_name: string;
 var sysop_first_name: string;
 var sysop_last_name: string;
 var maxtime: word;
 var dropfilepath: string;
 var lockbaud: LongInt);

procedure MakeInfoStrings(
 bbstype: word;
 var user_first_name,user_last_name: string;
 var user_access_level: word;
 var bbs_time_left: integer;
 var com_port: integer;
 var baud_rate,baud_modem: longint;
 var node_num: integer;
 var local: boolean;
 var graphics: byte;
 var color1: boolean;
 var color_chg: boolean;
 var board_name: string;
 var sysop_first_name: string;
 var sysop_last_name: string;
 var maxtime: word;
 var dropfilepath: string;
 var lockbaud: longint);

const
 numddovrstr=11;
type
 ddovrstrptr=^string;
 ddovrstrarray=array[1..numddovrstr] of ddovrstrptr;
var
 ddovrinfo: ddovrstrarray;

implementation

uses
  SysUtils;

procedure GetBBSInfo(
 bbstype: byte;
 var user_first_name,user_last_name: string;
 var user_access_level: word;
 var bbs_time_left: integer;
 var com_port: integer;
 var baud_rate: LongInt;
 var node_num: integer;
 var local: boolean;
 var graphics: byte;
 var color1: boolean;
 var color_chg: boolean;
 var board_name: string;
 var sysop_first_name: string;
 var sysop_last_name: string;
 var maxtime: word;
 var dropfilepath: string;
 var lockbaud: LongInt);

type

   char2  = array[1..2] of char;
   char4  = array[1..4] of char;
   char5  = array[1..5] of char;
   char12 = array[1..12] of char;
   char15 = array[1..15] of char;
   char25 = array[1..25] of char;
   single = array [0..3] of byte;
   bitmap = record
     bits : array [0..4] of byte;
   end;

   basic_real_type = array[1..4] of char;

   {layout of the PCBOARD12.SYS file while doors are open}

   pcb_sys_rec12 = record
      display:        char2;          {display on console?  -1 or 0}
      printer:        char2;          {print log?           -1 or 0}
      page_bell:      char2;          {bother sysop?        -1 or 0}
      alarm:          char2;          {caller alarm sound?  -1 or 0}
      sysop_next:     char2;          {force sysop on next? 'N ', 'X ' or '  '}

      baud:           array [1..4] of char;       {caller's baud rate}
      name:           char25;         {caller's name}
      xpert:          char;           {pcb/pro's own expert flag}
      nulls:          char;           {pcb/pro's own nulls flag}
      firstname:      array [1..15] of char;      {caller's first name}
      graphics:       char2;       {ansi graphics mode?  '-1',' 0', or '7E'}
      password:       array [1..12] of char;      {caller's password (last 2 chars redef'd}
      usernum:        integer;        {record number in user file}
      time_on:        Basic_real_type;
      time_limit:     Basic_real_type;
      open_time:      Basic_real_type;
      time_logged:    array [1..5] of char;       {time the user logged on in hh:mm}
      conference:     integer;        {active conference when door opened}
      joined:         array[1..9] of integer;
                                      {0 or -1 for conferences joined}
      time_added:     integer;        {highest conference added time in mins}
      down_limit:     array[1..8] of char;
      upload_credit:  integer;        {upload time credit so far that call}

      slanguage:      array [1..4] of char;       {language version used, blank, .FRE etc}
      errcheck:       char2;          {error check/correcting modem? -1 or 0}
      nodechat:       char;           {node chat flag prior to exit to DOS}
   end;

var
 pcbsys:       pcb_sys_rec12;

function wva(a: word): string;
var
 s: string;
begin
 str(a,s);
 wva:=s;
end;

Function In36(Num : byte) : String;
const
  Array36 : array[0..35] of Char = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  ch:char;
begin
  ch:='1';
  if num in [0..35] then
    ch:=Array36[num+1];
  In36:=ch;
end;

function w36(a: word): string;
var
 s: string;
begin
 case a of
  10..35 : s:=in36(a);
 else
   str(a,s);
 end;
 w36:=s;
end;

function stu(s: string): string;
var
 a: integer;
begin
 for a:=1 to length(s) do s[a]:=upcase(s[a]);
 stu:=s;
end;

procedure DDError(s: string);
begin
 write(^G^G);
 writeln('ERROR: '+s);
 write(^G^G);
 Sleep(2000);
 halt;
end;

function basic_real(breal: basic_real_type): real;
type
 atmp=array[1..6] of char;
var
 dummy: real;
 x: atmp absolute dummy;
begin
 x[1]:=breal[4];
 x[2]:=#0;
 x[3]:=#0;
 x[4]:=breal[1];
 x[5]:=breal[2];
 x[6]:=breal[3];
 basic_real:=int(dummy);
end;

procedure get_pcbsys_file;
var
   fd:  file of pcb_sys_rec12;
begin
 assign(fd,dropfilepath+'PCBOARD.SYS');
 {$i-} reset(fd); {$i+}
 if ioresult <> 0 then begin
  dderror('Can''t read system file PCBOARD.SYS');
  halt;
 end;
 read(fd,pcbsys);
 close(fd);
end;

function pcboard_time_left: byte;
var
 tl: integer;
 time_used: real;
 time_left: real;
begin
 time_used:=basic_real(pcbsys.open_time)-basic_real(pcbsys.time_on);
 time_left:=basic_Real(pcbsys.time_limit)-(time_used);
 tl:=round(time_left/60);
 if tl>255 then tl:=255;
 pcboard_time_left:=tl;
end;

procedure GetPcb14(var fname,lname: string; var comport,graphics,tleft: integer;
                   var baud :longint);
Type
   {layout of the PCBOARD14.SYS file while doors are open}
{
   Offset   Type   Length  Description
   ------  ------  ------  -----------
      0    str        2    Display On/Off ("-1" = On, " 0" = Off)
      2    str        2    Printer On/Off ("-1" = On, " 0" = Off)
      4    str        2    Page Bell On/Off ("-1" = On, " 0" = Off)
      6    str        2    Caller Alarm On/Off ("-1" = On, " 0" = Off)
      8    char       1    Sysop Flag (" ", "N"=sysop next, "X"=exit dos)
      9    str        2    Error Corrected ("-1" = On, " 0" = Off)
     11    char       1    Graphics Mode ('Y'=yes, 'N'=no, '7'=7E1)
     12    char       1    Node Chat Status ('A'=available, 'U'=unavailable)
     13    str        5    DTE Port Speed (PC to Modem speed)
     18    str        5    Connect Speed shown to caller or "Local"
     23    int        2    User's Record Number in the USERS file
     25    str       15    User's First Name (padded to 15 characters)
     40    str       12    User's Password (padded to 12 characters)
     52    int        2    Time User Logged On (in minutes since midnight)
     54    int        2    Time used so far today (negative number of minutes)
     56    str        5    Time User Logged On (in "HH:MM" format)
     61    int        2    Time Allowed On (from PWRD file) (see note 1 below)
     63    int        2    Allowed K-Bytes for Download (see note 2 below)
     65    char       1    Conference Area user was in (if <= 255)
     66    bitmap     5    Conference Areas the user has joined this session
     71    bitmap     5    Conference Areas the user has scanned this session
     76    int        2    Conference Add Time in minutes
     78    int        2    Upload/Sysop CHAT Credit Minutes (see note 3 below)
     80    str        4    Language Extension (see note 4 below)
     84    str       25    User's Full Name (padded to 25 characters)
    109    int        2    Calculated Minutes Remaining (see note 5 below)
    111    char       1    Node Number (or ' ' if no network)
|   112    str        5    Event Time (in "HH:MM" format, "00:00" if no event)
|   117    str        2    Is Event Active ("-1" = On, " 0" = Off) (see note 7)
|   119    str        2    Reserved (was Slide Event, no longer used here)
    121    bsreal     4    Memorized Message Number
    125    char       1    Comm Port Number (0=none, 1-8)
    126    char       1    Reserved for PCBoard
|   127    bitmap     1    See Node 8 below for details
    128    char       1    Use ANSI (1 = Yes, 0 = No)
|   129    int        2    Country Code
|   131    int        2    Code Page
|   133    char       1    YES character
|   134    char       1    NO character
|   135    char       1    Language 0=None, otherwise correspond with PCBML.DAT
|   136    char       3    RESERVED
    139    char       1    Caller Exited to DOS (1 = Yes, 0 = No)
|   140    char       1    RESERVED (was Event Up Coming, no longer used)
    141    char       1    Stop Uploads (1 = Yes, 0 = No)
    142    int        2    Conference Area user was in (up to 65535)
    144    bitmap  varies  High Conference Areas the user has joined (note 6)
   varies  bitmap  varies  High Conference Areas the user has scanned (note 6)
|  variees int        2    Node Number if offset 111 is set to 255, seek to
                           the end of the file, minus 2, to read this value
}
   pcb_sys_rec14 = record
    {1  } display:        char2;          {display on console?  -1 or 0}
    {3  } printer:        char2;          {print log?           -1 or 0}
    {5  } page_bell:      char2;          {bother sysop?        -1 or 0}
    {7  } alarm:          char2;          {caller alarm sound?  -1 or 0}
    {9  } sysop_next:     char;           {force sysop on next? 'N', 'X' or ' '}

    case integer of
    1: (
    {10 } errcheck:       char2;          {error check/correcting modem? -1 or 0}
    {12 } graphics:       char;           {ansi graphics mode?   'Y','N','7'}
    {13 } nodechat:       char;           {node chat status 'U' or 'A'}
    {14 } openbps:        char5;          {BPS rate to open modem port at}
    {19 } connectbps:     char5;          {BPS connect rate or 'Local'}
    {24 } usernum:        integer;        {record number in user file}
    {26 } firstname:      char15;         {caller's first name}
    {41 } password:       char12;         {caller's password}
    {53 } time_on:        integer;        {when the user logged on in MINUTES}
    {55 } prev_used:      integer;        {minutes used in prev calls today, <0}
    {57 } time_logged:    char5;          {hh:mm time the user logged on}
    {62 } time_limit:     integer;        {maximum minutes allowed from PWRD}
    {64 } down_limit:     integer;        {daily download limit/1024 from PWRD}
    {66 } curconf:        byte;           {active conference when door opened}
    {67 } joined:         bitmap;         {areas user has been in}
    {72 } ydone:          bitmap;         {areas user has done 'Y' on}
    {77 } time_added:     integer;        {highest conference added time in mins}
    {79 } time_credit:    integer;        {upload/chat time credit in minutes}
    {81 } slanguage:      char4;          {language used, blank, .FRE etc}
    {85 } name:           char25;         {caller's full name}
    {110} sminsleft:      integer;        {minutes left when door opened}
    {112} snodenum:       byte;           {current node number}
    {113} seventtime:     char5;          {hh:mm event time}
    {118} seventactive:   char2;          {event time active? "-1" or "0 "}
    {120} sslide:         char2;          {slide event? "-1" or " 0"}
    {122} smemmsg:        single;         {memorized message number}
    {126} scomport:       char;           {com port number '0','1','2'}
    {127} resv99:         char;           {filler UNDOCUMENTED}
    {128} bitmap:         byte;           {rip is bit $02     }
    {record size: 128}
      );

    2: (
      offline_filler:    array[1..119] of char      {filler, spaces}
      );
   end;

VAR
   pcbfile  : file;
   pcb14    : pcb_sys_rec14;
   a    : integer;
   s: string;
   Name        : String[25];

Begin
 Assign(PCBFile,dropfilepath+'PCBoard.Sys');
 {$I-}
 Reset(PCBFile);
 {$I+}
 If (IOResult<>0) Then dderror('... Unable to open pcboard.sys file...');
 BlockRead(PCBFile,PCB14,1);
 Close(PCBFile);
 Name:=pcb14.name;
 FName:=pcb14.firstname;
 LName:=Copy(Name,Pos(' ',Name)+1,Length(Name));
{ If (Data[23]=' ') Then Data[23]:='.'; }
 s:='';
 s :=s+Pcb14.SComPort;
 ComPort := StrToIntDef(s, 0);
 s:='';
 for a:= 1 to 5 do
   s:=s+Pcb14.openbps[a];
 while s[length(s)]=' ' do delete(s,length(s),1);
 baud := StrToIntDef(s, 0);
 If PCB14.connectbps='Local' then
     baud:=0;
 If (baud=0) Then ComPort:=0;

 Case Pcb14.graphics of
  'Y': begin
        Graphics:=2;
       end;
  'N': begin
        Graphics:=0;
       end;
  '7': begin
        Graphics:=0;
       end;
 End; {Case}
 If BBStype = 6 then
   If (PCB14.Bitmap And $02 = $02) then
      Graphics := 4;
 TLeft:=pcb14.sminsleft;
 while ((fname[1]=#0) or (fname[1]=#32)) and (length(fname)>1) do delete(fname,1,1);
 while ((fname[length(fname)]=#0) or (fname[length(fname)]=#32)) and (length(fname)>1) do delete(fname,length(fname),1);
 while ((lname[1]=#0) or (lname[1]=#32)) and (length(lname)>1) do delete(lname,1,1);
 while ((lname[length(lname)]=#0) or (lname[length(lname)]=#32)) and (length(lname)>1) do delete(lname,length(lname),1);
 for a:=1 to length(fname) do fname[a]:=upcase(fname[a]);
 for a:=1 to length(lname) do lname[a]:=upcase(lname[a]);
end;

procedure load_rbbs16;
var
 fd:    text;
 a: integer;
 info_num:byte;
 s,s2: string;
begin
 If BBStype in [3,9] then color1 := true;
 info_num:=node_num;
 If BBStype=9 then info_num:=1;
 assign(fd,dropfilepath+'DORINFO'+w36(info_num)+'.DEF');
 {$i-}
 reset(fd);
 {$i+}
 if ioresult <> 0 then dderror('Can''t open DORINFO'+w36(info_num)+'.DEF');
 local:=false;
 readln(fd,s);
 readln(fd,s);
 readln(fd,s);
 readln(fd,s);
 val(s[4],com_port,a);
 if com_port=0 then local:=true;
 readln(fd,s);
 s2:='';
 s:=stu(s);
 for a:=1 to pos('BAUD',s)-2 do s2:=s2+s[a];
 if s2[1]=' ' then delete(s2,1,1);
 val(s2,baud_rate,a);
 if (stu(s2)='LOCA') or (stu(s2)='LOCAL') then local:=true;
 if baud_rate=0 then local:=true;
 readln(fd,s);
 readln(fd,user_first_name);
 readln(fd,user_last_name);
 readln(fd,s);
 readln(fd,s);
 if s[1]=' ' then delete(s,1,1);
 while s[length(s)]=' ' do delete(s,length(s),1);
 val(s,graphics,a);
 inc(graphics);
 if color1 then inc(graphics);
 readln(fd,s);
 if s[1]=' ' then delete(s,1,1);
 while s[length(s)]=' ' do delete(s,length(s),1);
 val(s,user_access_level,a);
 readln(fd,s);
 if s[1]=' ' then delete(s,1,1);
 while s[length(s)]=' ' do delete(s,length(s),1);
 val(s,bbs_time_left,a);
 close(fd);
 user_first_name:=stu(user_first_name);
 user_last_name:=stu(user_last_name);
end;

procedure Load_pcboard14;
var
 tleft,com,graph: integer;
 baud : longint;
begin
 getpcb14(user_first_name,user_last_name,com,graph,tleft,baud);
 com_port:=com;
 baud_rate:=baud;
 graphics:=graph;
 bbs_time_left:=tleft;
 user_access_level:=50;
 inc(graphics);
 if (baud_rate=0) or (com_port=0) then local:=true else local:=false;
end;

procedure load_pcboard;
var
 a: integer;
 b: boolean;
begin
 user_access_level:=0;
 local:=false;
 get_pcbsys_file;
 b:=false;
 user_first_name:='';
 user_last_name:='';
 for a:=1 to 25 do if (pcbsys.name[a]=' ') or (pcbsys.name[a]=#0) then b:=true else if b=false then
  user_first_name:=user_first_name+pcbsys.name[a] else user_last_name:=user_last_name+pcbsys.name[a];
 baud_rate:=300;
 if (pcbsys.baud[1]='1') and (pcbsys.baud[2]='2') then baud_rate:=1200;
 if pcbsys.baud[1]='2' then baud_rate:=2400;
 if pcbsys.baud[1]='4' then baud_rate:=4800;
 if pcbsys.baud[1]='9' then baud_rate:=9600;
 if (pcbsys.baud[1]='1') and (pcbsys.baud[2]='9') then baud_rate:=19200;
 if pcbsys.baud[1]='L' then local:=true;
 if pcbsys.graphics[2]='0' then graphics:=1 else graphics:=3;
 bbs_time_left:=pcboard_time_left;
 user_first_name:=stu(user_first_name);
 user_last_name:=stu(user_last_name);
end;

procedure load_phnx;
var
 f : text;
 s : string;
 i: integer;
 b : boolean;
 a: integer;
begin
 assign(f,dropfilepath+'info.bbs');
 writeln('Opening file "info.bbs"');
 {$I-}
 reset(f);
 {$I+}
 if ioresult<>0 then dderror('Error in opening "info.bbs"');
 readln(f,s);
 b:=false;
 user_first_name:='';
 user_last_name:='';
 for a:=1 to 25 do if (pcbsys.name[a]=' ') or (pcbsys.name[a]=#0) then b:=true else if b=false then
  user_first_name:=user_first_name+pcbsys.name[a] else user_last_name:=user_last_name+pcbsys.name[a];
 readln(f,s); i := StrToIntDef(s, 0); baud_rate:=i;
 readln(f,s); i := StrToIntDef(s, 0); com_port:=i;
 readln(f,s); i := StrToIntDef(s, 0); user_access_level:=i;
 readln(f,s); s:=stu(s); if s='TRUE' then local:=true else local:=false;
 readln(f,s);
 readln(f,s); i := StrToIntDef(s, 0); bbs_time_left:=i;
 readln(f,s);
 if s='TRUE' then graphics:=3 else graphics:=1;
 if s='TRUE' then color_chg:=true else color_chg:=false;
 readln(f,s);
 close(f);
end;

procedure load_WWIV;
var
 a: integer;
 b: boolean;
 f : text;
 s : string;
 i: integer;
 sint: word;

begin
 assign(f,dropfilepath+'chain.txt');
 writeln('Opening file "Chain.txt"');
 {$I-}
 reset(f);
 {$I+}
 if ioresult<>0 then dderror('Error in opening "Chain.txt"');
 readln(f,s);
 readln(f,s);
 user_first_name:='';
 user_last_name:='';
 b:=false;
 for a:=1 to length(s) do if s[a]=' ' then b:=true else if b then
  user_last_name:=user_last_name+s[a] else user_first_name:=user_first_name+s[a];
 for i:=1 to 9 do begin
  readln(f,s);
 end;
 sint := StrToIntDef(s, 0);
 user_access_level:=sint;
 readln(f,s);
 readln(f,s);
 readln(f,s);
 if s<>'0' then begin graphics:=3;color_chg:=true; end else begin
  graphics:=1;
  color_chg:=false;
 end;
 readln(f,s);
 if s<>'0' then local:=false else local:=true;
 readln(f,s);
 while (s<>'') and (s[1]=' ') do delete(s,1,1);
 delete(s,length(s)-3,3);
 sint := StrToIntDef(s, 0);
 bbs_time_left:=sint div 60;
 readln(f,s);
 readln(f,s);
 readln(f,s);
 readln(f,s);
 baud_rate := StrToIntDef(s, 0);
 readln(f,s);
 sint := StrToIntDef(s, 0);
 com_port:=sint;
 readln(f,s);
 board_name:=s;
 readln(f,s);
 sysop_first_name:='';
 sysop_last_name:='';
 b:=false;
 for a:=1 to length(s) do if s[a]=' ' then b:=true else if b then
   sysop_last_name:=sysop_last_name+s[a] else sysop_first_name:=sysop_first_name+s[a];
 close(f);
end;

{$IFNDEF GO32V2}
procedure load_door32;
var
 a: integer;
 b: boolean;
 f: text;
 s: string;
begin
 writeln('Opening "' + dropfilepath + 'DOOR32.SYS".');
 assign(f,dropfilepath+'DOOR32.SYS');
 {$I-}
 reset(F);
 {$I+}
 if ioresult<>0 then dderror('Cannot load DOOR32.SYS');

 readln(f, s); { 1 - Comm Type (0=Local, 1=Serial, 2=Telnet) }
 if (s = '0') then local := true else local := false;

 readln(f, s); { 2 - Comm Or Socket Handle }
 val(s,com_port,a);
 
 readln(f, s); { 3 - Baud Rate }
 val(s,baud_rate,a);
 
 readln(f, s); { 4 - BBSID (Software Name & Version }
 
 readln(f, s); { 5 - User's Record Position (1 based) }
 
 readln(f, s); { 6 - User's Real Name }
 s:=stu(s);
 b:=false;
 user_first_name:='';
 user_last_name:='';
 for a:=1 to length(s) do if s[a]=' ' then b:=true else if b then
  user_last_name:=user_last_name+upcase(s[a]) else user_first_name:=user_first_name+upcase(s[a]);

 readln(f, s); { 7 - User's Handle/Alias }
 
 readln(f, s); { 8 - User's Access Level }
 val(s,user_access_level,a);
 
 readln(f, s); { 9 - User's Time Left (In Minutes) }
 val(s,bbs_time_left,a);
 
 readln(f, s); { 10 - Emulation (0=Ascii, 1=Ansi, 2=Avatar, 3=RIP, 4=MaxGfx) }
 if (s = '0') then graphics := 2 else graphics := 3;
 
 readln(f, s); { 11 - Current Node Number }

 close(f);
end;
{$ENDIF}

procedure load_doorsys;
var
 b: boolean;
 a: integer;
 f: text;
 s: string;
begin
 writeln('Opening "DOOR.SYS".');
 assign(f,dropfilepath+'DOOR.SYS');
 {$I-}
 reset(F);
 {$I+}
 if ioresult<>0 then dderror('Cannot load DOOR.SYS');

 readln(f,s); {Com Port}
 delete(s,1,3);
 delete(s,2,1);
 val(s,com_port,a);
 if com_port=0 then local:=true else local:=false;

 readln(f,s); { remote baud rate}
 readln(f,s); {dbits}
 readln(f,s); {node num}

 readln(f,s); {actual internal bbs}
 val(s,baud_rate,a);
 readln(f,s); {screen on}
 readln(f,s); {printer}
 readln(f,s); {page bell}
 readln(f,s); {caller bell}

 readln(f,s); {user name}
 s:=stu(s);
 b:=false;
 user_first_name:='';
 user_last_name:='';
 for a:=1 to length(s) do if s[a]=' ' then b:=true else if b then
  user_last_name:=user_last_name+upcase(s[a]) else user_first_name:=user_first_name+upcase(s[a]);

 readln(f,s); {city,state}
 readln(f,s); {home phone}
 readln(f,s); {work phone}
 readln(f,s); {password}

 readln(f,s); {security}
 val(s,user_access_level,a);

 readln(f,s); {times on}
 readln(f,s); {last called}
 readln(f,s); {secs left}

 readln(f,s); {time left}
 val(s,bbs_time_left,a);

 readln(f,s); {graphics code}
 if s='GR' then graphics:=3
 else
 if s='RIP' then graphics:=5
 else graphics:=1;

 readln(f,s); {#21, screen length, jakob added this line}
 val(s,global_screenlines,a);

 close(f);
end;

procedure load_spitfire;
var
 b: boolean;
 a: integer;
 f: text;
 s: string;
begin
 writeln('Opening "SFDOORS.DAT".');
 assign(f,dropfilepath+'SFDOORS.DAT');
 {$I-}
 reset(F);
 {$I+}
 if ioresult<>0 then dderror('Cannot load SFDOORS.DAT');

 readln(f,s);
 readln(f,s); {name}
 s:=stu(s);
 b:=false;
 user_first_name:='';
 user_last_name:='';
 for a:=1 to length(s) do if s[a]=' ' then b:=true else if b then
  user_last_name:=user_last_name+upcase(s[a]) else user_first_name:=user_first_name+upcase(s[a]);

 readln(f,s);
 readln(f,s);
 readln(f,s); {baud}
 val(s,baud_rate,a);
 if baud_rate=0 then local:=true else local:=false;

 readln(f,s); {cport}
 val(s,com_port,a);
 if com_port=0 then local:=true else local:=false;

 readln(f,s); {time left}
 val(s,bbs_time_left,a);

 readln(f,s);
 readln(f,s);
 readln(f,s); {ansi}
 if stu(s)='TRUE' then graphics:=3 else graphics:=1;

 readln(f,s); {sec}
 val(s,user_access_level,a);

 close(f);
end;

procedure Load_2am;
var
 f: text;
 s,s2: string;
begin
 local:=false;
 user_access_level:=0;
 writeln('Opening JUMPER.DAT');
 assign(f,dropfilepath+'JUMPER.DAT');
 {$I-}
 reset(F);
 {$I+}
 if ioresult<>0 then dderror('Cannot open JUMPER.DAT');
 readln(f,s);
 readln(f,s);
 readln(f,s);
 readln(f,s);

 readln(f,s);
 user_first_name:=s;
 readln(f,s);
 user_last_name:=s;

 readln(f,s);

 readln(f,s);
 bbs_time_left := StrToIntDef(s, 0);
 readln(f,s);
 com_port := StrToIntDef(s, 0);
 if com_port=0 then local:=true;
 readln(f,s);
 baud_rate := StrToIntDef(s, 0);
 if baud_rate=0 then local:=true;

 readln(f,s);
 readln(f,s);
 readln(f,s);
 readln(f,s);

 readln(f,s);
 readln(f,s2);
 graphics:=1;
 if (s='TRUE') and (s2='FALSE') then graphics:=2;
 if (s2='TRUE') then graphics:=3;
 close(f);
end;

procedure Load_TriBBS;
var
 b: boolean;
 a: integer;
 f: text;
 s: string;
begin
 local:=false;
 user_access_level:=0;
 writeln('Opening TRIBBS.SYS');
 assign(f,dropfilepath+'TRIBBS.SYS');
 {$I-}
 reset(F);
 {$I+}
 if ioresult<>0 then dderror('Cannot open TRIBBS.SYS');
 readln(f,s);
 readln(f,s); {user name}
 s:=stu(s);
 b:=false;
 user_first_name:='';
 user_last_name:='';
 for a:=1 to length(s) do if s[a]=' ' then b:=true else if b then
  user_last_name:=user_last_name+upcase(s[a]) else user_first_name:=user_first_name+upcase(s[a]);
 readln(f,s);  {password }
 readln(f,s);  {security}
 readln(f,s);  {help lev}
 readln(f,s);  {graphics}
 If s = 'Y' then
  graphics := 3
 else
  graphics := 1;

 readln(f,s); {minutes left}
 val(s,bbs_time_left,a);

 readln(f,s); {phonenumber}
 readln(f,s); {citystate  }
 readln(f,s); {birthdate  }
 readln(f,s); {nodenumber }
 val(s,node_num,a);
 readln(f,s);  {comportno }
 val(s,com_port,a);
 if com_port=0 then local:=true;

 readln(f,s); {modembaud rate }
 val(s,baud_rate,a);
 if baud_rate=0 then local:=true;
 readln(f,s); {baud rate }
 val(s,baud_rate,a);
 lockbaud := baud_rate;
 if baud_rate=0 then local:=true;
 close(f);
end;

procedure load_local;
var
 a: integer;
 d: boolean;
 s: string;
begin
 a := StrToIntDef(ParamStr(1), 0);
 if a>0 then node_num:=a;
 local:=true;
 writeln;
 writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
 writeln('³          Local Logon          ³');
 writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
 writeln;
 writeln('Please enter your name below (or leave blank for '+sysop_first_name+' '+sysop_last_name+'):');
 write('>');
 readln(s);
 if s='' then begin
  user_first_name:=stu(sysop_first_name);
  user_last_name:=stu(sysop_last_name);
 end else begin
  user_first_name:='';
  user_last_name:='';
  d:=false;
  for a:=1 to length(s) do if s[a]=' ' then d:=true else if d=false then
   user_first_name:=user_first_name+upcase(s[a])
  else
   user_last_name:=user_last_name+upcase(s[a]);
  if user_last_name='' then begin
   writeln('Please enter your last name:');
   write('>');
   readln(user_last_name);
   user_last_name:=stu(user_last_name);
  end;
 end;
 graphics:=3;
 bbs_time_left:=120;
 user_access_level:=255;
end;

procedure load_maint;
begin
 local:=true;
 user_first_name:='SYSTEM';
 user_last_name:='MAINTENANCE';
 bbs_time_left:=120;
 graphics:=3;
end;

begin
 baud_rate:=0;
 if bbstype=0 then load_maint;
 if bbstype=1 then load_local;
 if bbstype=3 then load_rbbs16;
 if bbstype=4 then load_pcboard;
 if bbstype=5 then load_WWIV;
 if bbstype=6 then load_pcboard14;
 if bbstype=7 then load_rbbs16;
 if bbstype=8 then load_phnx;
 if bbstype=9 then load_rbbs16;
 if bbstype=10 then load_pcboard14;
 if bbstype=11 then load_doorsys;
 if bbstype=12 then load_spitfire;
 if bbstype=13 then load_2am;
 if bbstype=14 then load_TriBBS;
{$IFNDEF GO32V2}
 if bbstype=15 then load_door32;
{$ENDIF}
 user_first_name:=stu(user_first_name);
 user_last_name:=stu(user_last_name);
{if node_num=0 then node_num:=1; }
 if graphics>=3 then color_chg:=true else color_chg:=false;
 if bbs_time_left>maxtime then bbs_time_left:=maxtime;
end;

function wva(w: word): string;
var
 s: string;
begin
 str(w,s);
 wva:=s;
end;

procedure stuffstr(n: word; s: string);
begin
 getmem(ddovrinfo[n],length(s)+1);
 move(s,ddovrinfo[n]^,length(s)+1);
end;

procedure MakeInfoStrings(
 bbstype: word;
 var user_first_name,user_last_name: string;
 var user_access_level: word;
 var bbs_time_left: integer;
 var com_port: integer;
 var baud_rate,baud_modem: longint;
 var node_num: integer;
 var local: boolean;
 var graphics: byte;
 var color1: boolean;
 var color_chg: boolean;
 var board_name: string;
 var sysop_first_name: string;
 var sysop_last_name: string;
 var maxtime: word;
 var dropfilepath: string;
 var lockbaud: longint);

const
{$IFDEF GO32V2}
 software_names: array[0..14] of string[15]=
  ('Maint',     'Local',      'Sysop',      'QBBS',       'PCBoard 12',
   'WWIV',      'PCBoard 15',        'RBBS 16+',   'Phoenix',    'DORINFO1',
   'PCBoard 14','DOORSYS',    'Spitfire',   '2am-bbs',   'TriBBS');
 drop_files: array[0..14] of string[15]=
  ('n/a',        'n/a',         'n/a',         'DORINFOx.DEF',
   'PCBOARD.SYS','CHAIN.TXT','PCBOARD.SYS', 'DORINFOx.DEF',
   'INFO.BBS',   'DORINFO1.DEF','PCBOARD.SYS', 'DOOR.SYS',
   'SFDOORS.DAT','JUMPER.DAT','TRIBBS.SYS');
{$ENDIF}
{$IFNDEF GO32V2}
 software_names: array[0..15] of string[15]=
  ('Maint',     'Local',      'Sysop',      'QBBS',       'PCBoard 12',
   'WWIV',      'PCBoard 15',        'RBBS 16+',   'Phoenix',    'DORINFO1',
   'PCBoard 14','DOORSYS',    'Spitfire',   '2am-bbs',   'TriBBS', 'DOOR32.SYS');
 drop_files: array[0..15] of string[15]=
  ('n/a',        'n/a',         'n/a',         'DORINFOx.DEF',
   'PCBOARD.SYS','CHAIN.TXT','PCBOARD.SYS', 'DORINFOx.DEF',
   'INFO.BBS',   'DORINFO1.DEF','PCBOARD.SYS', 'DOOR.SYS',
   'SFDOORS.DAT','JUMPER.DAT','TRIBBS.SYS', 'DOOR32.SYS');
{$ENDIF}
 istrue: array[false..true] of string[8] = ('FALSE','TRUE');
var
 s: string;
 a: integer;
begin
 stuffstr( 1,'Baud rate: '+wva(baud_rate));
 stuffstr( 2,'    Local: '+istrue[local]);
 stuffstr( 3,' Graphics: '+wva(graphics));
 stuffstr( 4,'Time left: '+wva(bbs_time_left));
 stuffstr( 5,' Com Port: '+wva(com_port));
 stuffstr( 6,'     User: '+user_first_name+' '+user_last_name);
 stuffstr( 7,'Access lv: '+wva(user_access_level));
 stuffstr( 8,' Node num: '+wva(node_num));
 if lockbaud=0 then s:='Not Locked' else s:=wva(lockbaud);
 stuffstr( 9,'Lock Baud: '+s);
 stuffstr( 10,' Software: '+software_names[bbstype]);
 s:=drop_files[bbstype];
 for a:=1 to length(s) do begin
  if s[a]='x' then begin
   s[a]:=chr(node_num+ord('0'));
  end;
 end;
 stuffstr(11,'Drop file: '+s);
 stuffstr(12,'Drop Path: '+dropfilepath);
end;

{
 /E - Use ESM for extra memory');
 /L - Local mode');
 /Bxxx - Specify locked baud rate (i.e. /B38400)');
 /C    - Specify comport number.
 /F    - Specify maintenance type 1.
 /H    - Specify maintenance type 2.
 /Nx   - Specify node number');
 /R    - Force RIP graphics');
 /Pyyy - Specify path to drop file (i.e. /Pc:\bbs');

    }

end.
