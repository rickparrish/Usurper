unit ddscott;

interface
uses dos,crt;
type
 adaptertype= (MDA,CGA,EGAMono,EGAColor);
 datetype=string[6];
 screentype= array[1..4000] of byte;
 screenptr=^screentype;
var
 Tasker  : byte;
 screen: screenptr;
 x,y: integer;
 ch: char;
 DOS_Major,DOS_Minor,Os2Vers : Word;
 hexon,OS2OK,WinOK,WinNTOK,DVOK : Boolean;

function va(n: integer): string;
function wva(n: word): string;
function lva(n: longint): string;
function rva(n: real): string;
function stu(s: string): string;
function locase(c: char): char;
function stl(s: string): string;
function namestr(s: string): string;
function exist(file_name: string): boolean;
procedure delete_file(fn: string);
procedure setmode(modenumber: byte);
{ procedure set43lines; }
procedure set25lines;
function isega: boolean;
function queryadaptertype: adaptertype;
function determinepoints: integer;
procedure cursoron;
procedure cursoroff;
procedure cursorblock;
function screenaddress: word;
procedure savescreen;
procedure restorescreen;
function date: datetype;
function bitcheck(n: word; b: byte): boolean;
procedure setbit(var n: word; b: byte);
procedure resetbit(var n: word; b: byte);
function hex(i: byte): string;
procedure HexFilt(var s: string);
procedure HexToDec(var s: string);

implementation

function hex(i: byte): string;
const
 ss: string='0123456789ABCDEF';
var
 hibyte,lobyte: byte;
begin;
 hibyte:=i div 16;
 lobyte:=i-((i div 16)*16);
 hex:=ss[hibyte+1]+ss[lobyte+1];
end;

procedure HexFilt(var s: string);
var
 s2,s3: string;
 numst: string;
 r: real;
 a,b: integer;
 e: integer;
 d: longint;
 c: array[1..4] of byte absolute d;
begin;
 s:=s+#13;
 s2:='';
 numst:='';
 for a:=1 to length(S) do begin;
  if s[a] in ['0'..'9'] then numst:=numst+s[a] else begin;
   if (numst<>'') then begin;
    val(numst,r,b);
    str(r:0:0,s3);
    val(s3,r,b);
    e:=a-1;
    b:=0;
    repeat
     e:=e+1;
     if upcase(s[e])='H' then b:=1;
    until (s[e]=' ') or (e>=length(s)) or (s[e]=#13) or (s[e]=#10);
    if (r<2000000000) and (b=0) then begin;
     d:=trunc(r);
     numst:=hex(c[4])+hex(c[3])+hex(c[2])+hex(c[1]);
     while (length(numst)>0) and (numst[1]='0') do delete(numst,1,1);
     if (length(numst)=0) or (not (numst[1] in ['0'..'9'])) then numst:='0'+numst;
     numst:=numst+'h';
    end;
    s2:=s2+numst;
    numst:='';
   end;
   s2:=s2+s[a];
  end;
 end;
 delete(s2,length(s2),1);
 s:=s2;
end;

procedure HexToDec(var s: string);
const
 ss: string ='0123456789ABCDEF';
var
 d: longint;
 c: array[1..4] of byte absolute d;
begin;
 if length(s)=0 then exit;
 if upcase(s[length(s)])<>'H' then exit;
 if not (s[1] in ['0'..'9']) then exit;
 delete(s,length(s),1);
 if length(s)=0 then exit;
 while length(s)<8 do s:='0'+s;
 c[1]:=(pos(upcase(s[8]),ss)-1)+(pos(upcase(s[7]),ss)-1)*16;
 c[2]:=(pos(upcase(s[6]),ss)-1)+(pos(upcase(s[5]),ss)-1)*16;
 c[3]:=(pos(upcase(s[4]),ss)-1)+(pos(upcase(s[3]),ss)-1)*16;
 c[4]:=(pos(upcase(s[2]),ss)-1)+(pos(upcase(s[1]),ss)-1)*16;
 str(d,s);
end;

procedure delete_file(fn: string);
var
 f: file;
begin;
 assign(f,fn);
 erase(f);
end;

function va(n: integer): string;
var
 v: string;
begin;
 str(n,v);
 if hexon then hexfilt(v);
 va:=v;
end;

function wva(n: word): string;
var
 v: string;
begin;
 str(n,v);
 if hexon then hexfilt(v);
 wva:=v;
end;

function lva(n: longint): string;
var
 v: string;
begin;
 str(n,v);
 if hexon then hexfilt(v);
 lva:=v;
end;

function rva(n: real): string;
var
 v: string;
begin;
 str(n:0:0,v);
 if hexon then hexfilt(v);
 rva:=v;
end;

function stu(s: string): string;
var
 a: integer;
begin;
 for a:=1 to length(s) do s[a]:=upcase(s[a]);
 stu:=s;
end;

function locase(c: char): char;
begin;
 if (c>='A') and (c<='Z') then c:=chr(ord(c)+32);
 locase:=c;
end;

function stl(s: string): string;
var
 a: integer;
begin;
 for a:=1 to length(s) do s[a]:=locase(s[a]);
 stl:=s;
end;

Function exist(file_name: string): boolean;
var
 f: text;
 b: boolean;
begin;
 assign(f,file_name);
 {$I-} reset(f); {$I+}
 if ioresult<>0 then b:=false else b:=true;
 if b then close(f);
 exist:=b;
end;

function namestr(s: string): string;
var
 a: integer;
begin;
 s:=stl(s);
 if length(s)>2 then begin;
  s[1]:=upcase(s[1]);
  for a:=1 to length(s) do begin;
   if (s[a] in ['.',' ',',',':',';','-','_','(',')']) and (a+1<length(s)) then s[a+1]:=upcase(s[a+1]);
  end;
 end;
 namestr:=s;
end;

procedure setmode(modenumber: byte);
var
 regs: registers;
begin;
 regs.ah:=0;
 regs.al:=modenumber;
 intr($10,regs);
end;

procedure set25lines;
var
 regs: registers;
begin;
 regs.ax:=$1111;
 regs.bx:=0;
 intr($10,regs);
 mem[$40:$87]:=mem[$40:$87] or $01;
 regs.ax:=$100;
 regs.bx:=0;
 regs.cx:=$0C00;
 intr($10,regs);
end;

function isega: boolean;
var
 regs: registers;
begin;
 regs.ah:=$12;
 regs.bx:=$10;
 intr($10,regs);
 if regs.bx=$10 then isega:=false else isega:=true;
end;

function QueryAdapterType: Adaptertype;
var
 regs: registers;
 code: byte;
begin;
 if isega then begin;
  regs.ah:=$12;
  regs.bx:=$10;
  intr($10,regs);
  if (regs.bh=0) then queryadaptertype:=egacolor else queryadaptertype:=egamono;
 end else begin;
  intr($11,regs);
  code:=(regs.al and $30) shr 4;
  case code of
   1: queryadaptertype:=cga;
   2: queryadaptertype:=cga;
   3: queryadaptertype:=mda;
  else queryadaptertype:=cga;
  end;
 end;
end;

procedure cursoroff;
var
 regs: registers;
begin;
 regs.ax:=$0100;
 regs.cx:=$2000;
 intr($10,regs);
end;

function determinepoints: integer;
var
 regs: registers;
begin;
 case queryadaptertype of
  cga: determinepoints:=8;
  mda: determinepoints:=14;
  egamono, egacolor: begin;
                      regs.ax:=$1130;
                      regs.bx:=0;
                      intr($10,regs);
                      determinepoints:=regs.cx;
                     end;
 end;
end;

procedure cursoron;
var
 regs: registers;
begin;
 regs.ax:=$0100;
 regs.ch:=determinepoints-2;
 regs.cl:=determinepoints-1;
 intr($10,regs);
end;

procedure cursorblock;
var
 regs: registers;
begin;
 regs.ax:=$0100;
 regs.ch:=1;
 regs.cl:=determinepoints-1;
 intr($10,regs);
end;

function screenaddress: word;
begin;
 case queryadaptertype of
  cga: screenaddress:=$B800;
  mda: screenaddress:=$b000;
  egamono: screenaddress:=$b000;
  egacolor: screenaddress:=$b800;
 end;
end;

procedure savescreen;
var
 sc1: byte absolute $b000:0;
 sc2: byte absolute $b800:0;
begin;
 if screenaddress=$b000 then move(sc1,screen^,4000);
 if screenaddress=$b800 then move(sc2,screen^,4000);
 x:=wherex;
 y:=wherey;
end;

procedure restorescreen;
var
 sc1: byte absolute $b800:0;
 sc2: byte absolute $b000:0;
begin;
 if screenaddress=$b000 then move(screen^, sc2,4000);
 if screenaddress=$b800 then move(screen^, sc1,4000);
 gotoxy(x,y);
end;

function date: datetype;
var
 d,m,y,dow: word;
 s,s2: string[6];
begin;
 getdate(y,m,d,dow);
 y:=y-1900;
 s:=va(m);
 if length(s)=1 then s:='0'+s;
 s2:=va(d);
 if length(s2)=1 then s2:='0'+s2;
 s:=s+s2;
 s2:=va(y);
 if length(s2)=1 then s2:='0'+s2;
 s:=s+s2;
 date:=s;
end;

function bitcheck(n: word; b: byte): boolean;
var
 a,c: integer;
begin;
 a:=2;
 for c:=1 to b do a:=a*2;
 if (a and n)<>0 then bitcheck:=true else bitcheck:=false;
end;

procedure setbit(var n: word; b: byte);
var
 a,c: integer;
begin;
 a:=2;
 for c:=1 to b do a:=a*2;
 n:=(a or n);
end;

procedure resetbit(var n: word; b: byte);
var
 a,c: integer;
begin;
 a:=2;
 for c:=1 to b do a:=a*2;
 a:= not a;
 n:=(a and n);
end;

function TrueDosVer (var WinNtOK :boolean): Word;
var
 Regs: Registers;
Begin
  with Regs do
  begin
    Ax := $3306;
    MsDos(Regs);
    If Bx = $3205 then
      WinNtOK := true
    else
      WinNtOK := false;
    TrueDosVer := Bl;
  end;
end;

function DosVer(var Minor,OS2Ver : Word) : Word;
var
 Regs: Registers;
Begin
  OS2Ver := 0;
  with Regs do
  begin
    Ax := $3000;
    MsDos(Regs);
    DosVer := Al;
    Minor  := Ah;
    If Al = $0A then
      OS2Ver := 1
    else
    If Al = $14 then
      OS2Ver := 2;
  end;
end;

Function Win3_Check_On: boolean;
const
  Multplx_intr = $2F;
var
  Regs : registers;
begin
  With Regs do
  begin
    AX := $1600;
    Intr(Multplx_intr,regs);                { $00 no Win 2.x or 3.x      }
    if AL in [$00,$01,$80,$FF] then         { $01 Win/386 2.x running    }
      Win3_Check_On := false                { $80 obsolete XMS installed }
    else                                    { $FF Win/386 2.x running    }
      Win3_Check_On := true;
   end;
end;

Function DV_Check_On : boolean;
var
  Regs : registers;
begin
  DV_Check_On := false;
  With Regs do
  begin
    Ax := $2B01;
    Cx := $4445;
    Dx := $5351;
    Intr($21,Regs);
  end;
  If (Regs.AL = $FF) then
     DV_Check_On := false
  else
     DV_Check_On := true;
end;

Procedure FindTaskerType;  { Find what tasker if any is being used      }
var
 D5 : word;
begin
 D5 := 0;
 Tasker := 0;
 DVOK  := false;
 OS2OK := false;
 WinOK := false;
 WinNtOK := false;    { This could also be just plain old Dos 5.0+ }

 DOS_Major := DosVer(DOS_Minor,Os2Vers);
 If Os2Vers in [1,2] then
   Os2OK := true
 else
   DVOK := DV_Check_On;

 If (not DVOK) and (not Os2OK) then
  begin
    WinOK := Win3_Check_On;
    If Not WinOK then
      Case Dos_Major of
         5..9  : D5 := TrueDosVer(WinNtOK);
       end;
   end;

  If DVOK then
       Tasker := 1
  else
  If WinOK then
       Tasker := 2
  else
  If Os2OK then
       Tasker := 3
  else
  If WinNtOK then
      Tasker := 4
  else
  if D5 >= 5 then
      Tasker := 5;
end;

begin
 FindTaskerType;
 hexon:=false;
 new(screen);
end.