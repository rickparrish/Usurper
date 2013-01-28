{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}
Unit DDPlus;
{$V-,F+}

Interface

Uses dos, crt, comio, ddscott, ddansi2, ddovr, ddovr2;

type
 CharOriginType=(localchar,remotechar);
 strptr=^string;
const
 version= 'Version 7.10  ; 05-01-95';

 progname: string[60] = 'Usurper 0.23';
 graphics_codes: array[1..5] of string[4] = ('','.ASC','.ANS','.MUS','.ANS');
 { You will have to make up your mind to have item #5 .ANS or .RIP.  You may }
 { find that displaying a ripfile is more effectively done if shown some     }
 { other day.                                                                }

 ack=#6;
 nak=#21;
 sot=#1;
var
 lockbaud: longint;                 {lock baud rate                          }
 com1,com2,com3,com4 : byte;        { temporary non-std comports             }
 port1,port2,port3,port4:word;
 irq1,irq2,irq3,irq4 : byte;
 com_port: byte;                    {from DROP FILE: com port                }
 fossilIO,DigiIO: boolean;          {from .CTL file: fossil, digiboard i/o   }
 mintime: byte;                     {Minimum time left before user kicked off}
 notime: string;                    {Out of time filename                    }
 macro,macro_str: string;           {Used in the macro routines              }
 node_num: integer;                 {Node number                             }
 time_credit: integer;              {Time credit +/- (arrow keys)            }
 CharOrigin: CharOrigInType;        {Where character came from               }
 fouled_up: char;                   {Internal use                            }
 localcol: boolean;                 {From .CTL file: Local color enabled     }
 ansion: boolean;                   {Process ANSI locally                    }
 time_check: boolean;               {Check time left - halt if < mintime     }
 moreok : boolean;                  {display <more> prompt?                  }
 curlinenum: integer;               {current line num - used by <more>       }
 stacked: string;                   {used internally - stacked commands      }
 F1toggle: byte;                    {Show Help or Status Line                }
 inchat  : byte;                    {Already inchat don't do this again      }
 chatdone : boolean;                {has there been a chat?                  }
 current_foreground: byte;          {current foreground color                }
 current_background: byte;          {current background color                }
 color_chg: boolean;                {send ANSI color change sequences?       }
 default_fore: byte;                {default foreground color                }
 default_back: byte;                {default background color                }
 cdropped,tdropped: boolean;        {carrier dropped? timedropped            }
 bbs_time_left: integer;            {from DROP FILE: time left               }
 bbs_software: byte;                {from .CTL file: bbs type                }
 baud_rate: longint;                {from DROP FILE: baud rate               }
 statfore,statback: byte;           {status line foreground                  }
 statline: boolean;                 {status line background                  }
 graphics: byte;                    {from DROP FILE: graphics code           }
 local: boolean;                    {from DROP FILE: local mode              }
 user_number: word;           {from DROP FILE: user's access level     }
 user_first_name: string[30];       {from DROP FILE: user's first name       }
 user_last_name: string[30];        {from DROP FILE: user's last name        }
 sysop_first_name: string[30];      {from .CTL file: sysop's first name      }
 sysop_last_name: string[30];       {from .CTL file: sysop's last name       }
 board_name: string[70];            {from .CTL file: board name              }
 Pause_Code : string;               { Rip PAUSE CODE OF YOUR BBS             }
 st_hr, st_mn, st_sc,save_sc: word; {used by timer calculations              }
 color1: boolean;                   {from .CTL file: color1 mode             }
 EMSOK : boolean;                   {/ESM use esm memory                     }
 NetOK : boolean;                   {A Dos only network is present           }
 NoLocal : boolean;                 { Local echo turned off (statback)       }
 stackon: boolean;                  {process stacked commands?               }
 badchar: string;                   {internal use                            }
 maxtime: word;                     {from .CTL file: maximum time in door    }
 user_access_level: word;
 numlines: byte;                    {from .CTL file: number of lines/screen  }
 oldtextmode: word;                 {original text mode                      }
 GoRip      : byte;                 { enables force RIP }
 lastsetfore: byte;                 {last set_foreground color               }
 setforecheck: boolean;             {check repetetive set_foreground calls?  }
 dropfilepath: string;              {from parm list                          }
 cc          : integer;             { read cycle counter                     }
 soutput: text;                     {Simultanious output file                }

 proc_call_ptr: pointer;            {used internally                         }
 nodirect: boolean;

Procedure DV_Aware_On;
Procedure DV_Pause;
Procedure Win_Pause;
Procedure ReleaseTimeSlice;
procedure close_async_port;
procedure Open_async_port;
function  skeypressed: boolean;
Procedure Clear_Region(x,a,b:byte);
procedure sendtext(s: string);
procedure sgoto_xy(x,y: integer);
procedure sclrscr;
procedure sclreol;
procedure swrite(s: string);
procedure swritec(ch: char);
procedure swriteln(s: string);
Procedure swritexy(x,y:integer;s:string);
Procedure Propeller(v:byte);
procedure sread_char(var ch: char);
procedure sread(var s: string);
procedure sread_num(var n: integer);
procedure sread_num_byte(var b: byte);
procedure sread_num_word(var n: word);
procedure sread_num_longint(var n: longint);
Procedure speedread(var ch : char);
function time_left: integer;
procedure set_foreground(f: byte);
procedure set_background(b: byte);
procedure set_color(f,b: byte);
procedure promptj(var s: string; le: integer; pc: boolean;get_stack:boolean);

procedure promptsec(var s: string; le: integer; pc: boolean; sec:char); {jakobs own edited version}
procedure promptwr(var s: string; le: integer; pc: boolean); {jakobs own edited version}

Procedure elapsed(time1_hour, time1_min, time1_sec, time2_hour, time2_min,
                  time2_sec: longint; var elap_hour, elap_min, elap_sec: longint);  {jakob, var word egentligen}
procedure get_stacked(var s: string);
procedure sread_char_filtered(var ch: char);
procedure display_status(force:boolean); {jakob added force!}
Procedure Displayfile1(const filen: string); {jakobs special! remove original!}
Procedure SelectAnsi(chflag :char;filenm: string);
procedure DDAssignSoutput(var f: text);
procedure InitDoorDriver(ConfigFileName: string);
function Time_used: integer;

Implementation
{$IFDEF MSDOS}
{$L DVAWARE.OBJ}
{$ENDIF}

Uses Init, Cms, InitGods,
     Jakob, Mail, News,
     Online, File_io; {jakob! You have also changed in DDOVR2.PAS}

Procedure DV_Aware_On;       {$IFDEF MSDOS}External;{$ENDIF}
{$IFDEF WIN32}
begin
  WriteLn('REETODO DDPLUS DV_Aware_On'); Halt;
end;
{$ENDIF}
Procedure DV_Pause;          {$IFDEF MSDOS}External;{$ENDIF}
{$IFDEF WIN32}
begin
  WriteLn('REETODO DDPLUS DV_Pause'); Halt;
end;
{$ENDIF}

var
 buffered: boolean;
 exitsave: pointer;
 tcolor,bcolor: integer;
 firsttime: boolean;

{$IFDEF MSDOS}
procedure Dos_Sleep;
var
 Regs : Registers;
begin
 with Regs do
   Intr($28,Regs);
end;
{$ENDIF}
{$IFDEF WIN32}
procedure Dos_Sleep;
begin
  WriteLn('REETODO DDPLUS Dos_Sleep'); Halt;
end;
{$ENDIF}
{ This releases the virtual machine time slice for MSwindows, Dos 5.0, OS/2 }

{$IFDEF MSDOS}
procedure Win_Pause;
var
 Regs : Registers;
begin
 with Regs do
 begin
   Ax := $1680;
   Intr($2F,Regs);
 end;
end;
{$ENDIF}
{$IFDEF WIN32}
procedure Win_Pause;
begin
  WriteLn('REETODO DDPLUS Win_Pause'); Halt;
end;
{$ENDIF}

Procedure ReleaseTimeSlice;
begin
  Case Tasker of
    1     : DV_Pause;
    2,4,5 : Win_Pause;
    3     : begin
             Win_Pause;
             Dos_Sleep;        { OS/2 likes this/ it don't hurt }
            end;
  else
    Dos_Sleep;
  end;
end;

Procedure Clear_Region(x,a,b:byte);
var
  i : byte;
begin
  for i := a to b do
    begin
      SGoto_XY(x,i);
      Sclreol;
    end;
end;

Procedure Chat_Eof(flag:byte);
begin
  If wherey =24 then
    begin
      Clear_Region(1,19,21);
      SGoto_XY(1,19);
      Swrite('¯');
    end
  else
  if flag=1 then
    swriteln('');
  If wherey=22 then
    begin
      Clear_Region(1,22,24);
      Sgoto_XY(1,22);
    end;
end;

{ This is the new formated chat that uses lines 19-24 for a chat   }
{ window that rolls from 19-24 and back again.                     }

{ Remember to check for #3 when this returns so you can refresh the }
{ area this has colored black.                                      }
procedure forced_chat;
var
  i,x,y,cx,cy,oldy:byte;
  ch: char;
  a: integer;
  old_origin: charorigintype;
  word: string;
  lastspace: integer;

begin;
  SGoto_XY(1,19);
  Set_Color(0,6);
  swrite(' The SYSOP wants to chat with you.       [ESC] to exit.');
  Sclreol;
  Set_Color(7,0);
  Clear_Region(1,20,24);
  SGoto_XY(1,20);
  Swrite('¯');
  set_foreground(11);
  old_origin:=localchar;
  lastspace:=0;
  word:='';

  repeat;
  sread_char(ch);
  if charorigin<>old_origin then
    if charorigin=localchar then
      set_foreground(11)
    else
      set_foreground(14);
  old_origin:=charorigin;
  swrite(ch);
  if ch=#8 then
    begin
      swrite(' '+#8);
      if length(word)>0 then
        delete(word,1,1);
    end;

  if ch=#13 then
   begin
     if wherey >23 then
       Chat_Eof(0)
     else
      begin
       swrite(#10);
        if wherey =22 then
          Chat_Eof(0);
       swrite('¯');
      end;
     lastspace:=0;
     word:='';
   end;

  if (ch<>' ') and (ch<>#8) and (ch<>#13) then
    word:=word+ch;
  if ch=' ' then
    begin
     lastspace:=wherex;
     word:='';
    end;

  if wherex>75 then
    begin
     if lastspace=0 then
        Chat_Eof(1)
     else
       begin
         while wherex>lastspace do swrite(#8+' '+#8);
         Chat_Eof(1);
         swrite(word);
       end;
    end;
  until ch=#27;
  Set_Color(7,0);
  Clear_Region(1,19,24);
end;

Procedure DropMessage;
begin;

 {jakob}
 if global_maintrunning=true then begin
 { writeln;
  writeln('Carrier Dropped. [Maintenance is running]');
  writeln('Returning to BBS when maintenance is done.');}
  global_carrierdropped:=true;
 end
 else if global_checkcarrier=true then begin
  writeln;
  writeln('Carrier Dropped, returning to BBS.');
  cdropped:=true;
  halt;
 end;

end;

procedure BlankScreenMessage;
begin
  gotoxy (trunc((80-length(progname))/2),10);
  write(progname);
  gotoxy (26,12);
  write('Local screen mode turned off.');
  gotoxy (1,1);
end;

Procedure HosedMessage;
begin
  Swriteln('');
  Swriteln('');
  Set_Color(15,0);
  Swrite('The SYSOP has terminated the game and is returning you to the BBS!');
  {we restore the "player in fight" variable so player wont be punished
   for dropping carrier, jakob}
  global_PlayerInFight:=false; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}

  ReleaseTimeSlice;
  delay2(500);
  ReleaseTimeSlice;
end;

procedure textcolor(i: byte);
begin;
 if localcol then crt.textcolor(i);
 tcolor:=i;
end;

procedure textbackground(i: byte);
begin;
 if localcol then crt.textbackground(i);
 bcolor:=i;
end;

procedure elapsed(time1_hour, time1_min, time1_sec, time2_hour, time2_min,
                  time2_sec: longint; var elap_hour, elap_min, elap_sec: longint);
var
 a,b,c: longint;
begin;
 if time1_hour<time2_hour then time1_hour:=time1_hour+24;
 a:=(time1_hour*3600)+(time1_min*60)+time1_sec;
 b:=(time2_hour*3600)+(time2_min*60)+time2_sec;
 c:=a-b;
 if c>=3600 then elap_hour:=c div 3600 else elap_hour:=0;
 c:=c-((c div 3600)*3600);
 if c>=60 then elap_min:=c div 60 else elap_min:=0;
 c:=c-((c div 60)*60);
 elap_sec:=c;
end;

function time_left: integer;
var
 hour, minute, second, sec100: word;
 el_hr, el_mn, el_sc: longint;
begin;
 gettime(hour, minute, second, sec100);
 elapsed(hour, minute, second, st_hr, st_mn, st_sc, el_hr, el_mn, el_sc);
 time_left:=time_credit+(bbs_time_left-((el_hr*60)+el_mn));
end;


function time_used: integer;
var
 hour, minute, second, sec100: word;
 el_hr, el_mn, el_sc: longint;
begin;
 gettime(hour, minute, second, sec100);
 elapsed(hour, minute, second, st_hr, st_mn, st_sc, el_hr, el_mn, el_sc);
 time_used:=(el_hr*60)+el_mn;
end;

procedure display_Fkeys;
var
 a,b: integer;
 x,y: integer;
begin;
 save_sc:=999;
 x:=wherex;
 y:=wherey;
 cursoroff;
 window(1,1,80,numlines);
 a:=tcolor;
 b:=bcolor;
 textcolor(statfore);
 textbackground(statback);
 gotoxy(1,numlines);
 clreol;                          {jakob drop-dos}
 write(' F1=Help Toggle ³ F2=Chat ³ F6=Dos ³ F7=+5Min ³ F8=-5Min ³ F10=Eject ³');
 window(1,1,80,numlines-1);
 gotoxy(x,y);
 textcolor(a);
 textbackground(b);
 If Not NoLocal then cursoron;
 if f1toggle=0 then
  f1toggle:=1
 else
  begin
    firsttime:=true;
    f1toggle:=0
  end;
end;

procedure display_status(force:boolean);
var
 a,b: integer;
 c,d: word;
 x,y: integer;
 hour, minute, second, sec100:word;
 el_mn, el_hr, el_sc: longint; {jakob:longint}
 alias : string[30];
begin;
 x:=wherex;
 y:=wherey;
 cursoroff;
 window(1,1,80,numlines);
 a:=tcolor;
 b:=bcolor;
 textcolor(statfore);
 textbackground(statback);

 if (firsttime) or (force) then
   begin
     gotoxy(1,numlines);
     clreol;

     if global_godactive=true then begin
      alias:=god.name;
      write(alias+' ('+user_first_name+' '+user_last_name+')'); {jakob}
     end
     else if player.name2='' then begin
      alias:='Unknown';
      write(user_first_name+' '+user_last_name+' ('+alias+')'); {jakob}
     end
     else begin
      alias:=player.name2;
      write(alias+' ('+user_first_name+' '+user_last_name+')'); {jakob}
     end;

     gotoxy(60-(length(progname+' - Node '+va(node_num)) div 2),numlines);
     write(progname+' - Node '+va(node_num));
     firsttime:=false;
     save_sc:=999;
   end;
 gettime(hour,minute,second,sec100);
 elapsed(hour,minute,second,st_hr,st_mn,st_sc,el_hr,el_mn,el_sc);
 c:=(bbs_time_left-1)+time_credit;
 if (time_left<mintime) and (time_check) then
   begin
     cursoron;
     if notime<>'' then swriteln('(*** Time limit exceeded ***)');
     swriteln('');
     tdropped:=true;
     halt;
   end;
 c:=c-((el_hr*60)+el_mn);
 d:=60-el_sc;
 if d<>save_sc then
   begin
     gotoxy(74,numlines);
     clreol;
     gotoxy(74,numlines);
     write(c,':');
     if d<10 then write('0');
     write(d);
     save_sc:=d;
   end;

 textcolor(a);
 textbackground(b);
 window(1,1,80,numlines-1);
 gotoxy(x,y);
 If Not NoLocal then cursoron;
end;

procedure Selectansi;
var
  f: text;
  b,g,counter,chcount : integer;
  c,quit: boolean;
  k,ch: char;
  ansisave,moresave,swon : boolean;
  ofm: word;
begin
  ofm:=filemode;
  filemode:=66;
  ansisave:=ansion;
  ansion:=true;
  quit:=false;
  counter:=1;
  chcount:=0;
  c:=false;
  swon:=false;
  g:=graphics;
  k:=' ';

  assign(f,'ERROR');
  if pos('.',filenm)<>0 then assign(f,filenm) else
   begin
     while (g>=0) and (not c) do
       begin
         if exist(filenm+graphics_codes[g]) then
           begin
             assign(f,filenm+graphics_codes[g]);
             c:=true;
           end;
         dec(g);
       end;
   end;

 {$I-}
 filemode:=66;
 reset(f);
 filemode:=66;
 {$I+}
 if ioresult<>0 then
   begin
     swriteln('File '+filenm+' missing');
     ansion:=ansisave;
     filemode:=ofm;
     exit;
   end;

 while (not eof(f)) and (not quit) do
  begin
    if ch=#10 then
      begin
        chcount:=0;
        inc(counter);
      end;

    read(f,ch);
    if chcount>0 then
      begin
        if swon then
           swritec(ch);
      end
    else
      begin
        if swon then
          begin
            if ch<>chflag then
              quit:=true;
          end
        else
        if ch=chflag then
          swon:=true;
      end;
    inc(chcount);
   end;

   close(f);
   ansion:=ansisave;
   set_foreground(default_fore);
   filemode:=ofm;
end;

procedure displayfile1; {jakobs special! ta bort originalet!}
var
  f: text;
  g, counter,b: integer;
  error : integer;
  c,quit,nonstop: boolean;
  k,ch: char;
  ansisave,moresave: boolean;
  nyfil : string[100];

begin
 error:=0;
 ansisave:=ansion;
 ansion:=true;
 nonstop:=false;
 quit:=false;
 counter:=1;
 c:=false;
 g:=graphics;
 k:=' ';

 assign(f,'ERROR');
 if pos('.',filen)<>0 then begin
  nyfil:=filen;
 end
 else begin
  while (g>=0) and (not c) do begin
   if exist(filen+graphics_codes[g]) then begin
    if g in [2,3,5] then nonstop:=true;
    nyfil:=filen+graphics_codes[g];
    c:=true;
   end;
   dec(g);
  end;
 end;

 open_txtfile(treset,f,nyfil);

 while (not eof(f)) and (not quit) do begin
  if ch=#10 then inc(counter);
  if (counter>global_screenlines-1) and (not nonstop) then begin
   counter:=1;
   swrite('Continue,Stop,Non-stop ? ');
   sread_char(ch);
   for b:=1 to 26 do swrite(chr(8));
   clreol;
   if ch in ['S','s'] then Quit:=true;
   if ch in ['N','n'] then nonstop:=true;
  end;

  {$I-}read(f,ch);{$I+}
  error:=IOREsult;
  if error<>0 then unable_to_read(nyfil,error);

  if skeypressed then sread_char(k);
  if k=^S then sread_char(k);
  if (k=^k) or (k=^c) or (K='s') then begin {sista ifet „r jakobs verk}
   close_text(f);
   AsyncPurgeOutput;
   swriteln('');
   ansion:=ansisave;
   exit;
  end;
  if not quit then swritec(ch);
 end;

 close_text(f);
 ansion:=ansisave;
 set_foreground(default_fore);

end;

procedure SendText(s: string);
var
 a: integer;
begin;
 {jakob}
 If (Not AsyncCarrierPresent) then begin
  DropMessage;
 end
 else begin
  for a:=1 to length(s) do AsyncSendChar(s[a]);
 end;

end;

procedure CharOut(ch: char);
begin;
 AsyncSendChar(ch);
end;

function charin(var ch: char): boolean;
begin;
 if badchar<>'' then
   begin;
     ch:=badchar[1];
     delete(badchar,1,1);
     charin:=true;
   end
 else
  if AsyncCharPresent then
     begin;
       AsyncReceiveChar(ch);
       charin:=true;
     end
 else charin:=false;
end;

procedure CloseDown;
begin;
  if buffered then
     AsyncFlushOutput;
  If Not noFossinit then
     AsyncCloseCom(com_port);
  buffered := false;
end;

procedure sclrscr;
begin
 if not local then sendtext(#27'[2J');
 If NoLocal then
   begin
     TextColor(statfore);
     TextBackGround(statback);
   end;

 clrscr;
 If NoLocal then BlankScreenMessage;
 curlinenum:=1;
 lastsetfore:=99;
end;

procedure sclreol;
begin;
 if not local then sendtext(#27'[K');
 clreol;
end;

procedure morecheck;
var
 ch: char;
begin;
 swrite('<More>');
 sread_char(ch);
 swrite(#8+#8+#8+#8+#8+#8);
 write('      ');
 write(#8+#8+#8+#8+#8+#8);
end;

procedure swritec(ch: char);
begin;
 if not local then
   AsyncSendChar(ch);
 if NoLocal then
    begin
      gotoxy(Wherex+1,Wherey);
      exit;
    end;
 if ansion then
    ansi_write(ch)
  else
    write(ch);
end;

procedure swrite(s: string);
begin;
 if hexon then hexfilt(s);
 if not local then sendtext(s);
 if NoLocal then
  begin
    GotoXY(wherex+length(s),wherey);
    exit;
  end;

 if ansion then
     ansi_write_str(s)
 else
    write(s);
end;

procedure swriteln(s: string);
begin;
 if hexon then hexfilt(s);
 if not local then sendtext(s+#13+#10);
 if NoLocal then
  begin
    GotoXY(wherex+length(s),wherey);
    writeln;
    exit;
  end;

 if ansion then
   begin
     s:=s+#13+#10;
     ansi_write_str(s);
   end
 else
   writeln(s);
 inc(curlinenum);
 if (curlinenum=(numlines-1)) then begin;
  curlinenum:=1;
  if moreok then morecheck;
 end;
end;

Procedure swritexy;
begin
 Sgoto_XY(x,y);
 if hexon then hexfilt(s);
 if not local then sendtext(s);
 if NoLocal then
  begin
    GotoXY(wherex+length(s),wherey);
    exit;
  end;

 if ansion then
     ansi_write_str(s)
 else
    write(s);
end;

Procedure Propeller(v:byte);
const
  CX :array [1..6] of char =(chr(250),'³','/','-','\','?');
var
  b : byte;
begin
  b:=6;
  case v of
   1,15      : b:=1;
   2,6,10,14 : b:=2;
   3,7,11    : b:=3;
   4,8,12    : b:=4;
   5,9,13    : b:=5;
  end;
  if v < 17 then
    begin
      Swritec(cx[b]);
      SwriteC(#8);
    end;
end;

procedure DDexit;
begin;
 If not local then CloseDown;
 if lastmode<>oldtextmode then textmode(oldtextmode);
 cursoron;
 { This should fix the problem OS/2 serial IO drivers are having exiting. }
 exitproc:=exitsave;
end;

 { Customize this for each game }

Procedure CallProc;
{$IFDEF MSDOS}
inline($FF/$1E/Proc_Call_Ptr);
{$ENDIF}
{$IFDEF WIN32}
begin
  WriteLn('REETODO DDPLUS CallProc'); Halt;
end;
{$ENDIF}

Procedure DefineFKeys(var a:char;fkeyon:byte);
begin
  a:=#0;
  case fkeyon of
    1: Display_Fkeys;
    2: begin
         if inchat>0 then exit;
         inchat:=1;
         Forced_Chat;
         inchat:=0;
         a:=#3;
         chatdone:=true;
       end;
    6: drop_dos; {jakob egna lilla drop-to-dos funktion}
    7: inc(time_credit,5);
    8: dec(time_credit,5);
   10: begin
         HosedMessage;
         halt;
       end;
  end;
end;

procedure sfkeys(var a: char);
var
 fkeyon:byte;
begin
  fkeyon:=0;
   case a of
     #59:fkeyon:=1;
     #60:fkeyon:=2;
     #61:fkeyon:=3;
     #62:fkeyon:=4;
     #63:fkeyon:=5;
     #64:fkeyon:=6;
     #65:fkeyon:=7;
     #66:fkeyon:=8;
     #67:fkeyon:=9;
     #68:fkeyon:=10;
  else
     a:=#0;
  end;
  If a<>#0 then
    DefineFkeys(a,fkeyon);
end;

Procedure ReadScanCode(var a:char);
begin
  a :=readkey;
  if (a=#0) and (keypressed) then
    begin;
      a:=readkey;
      sFkeys(a);
    end;
end;

procedure sread_ch(var ch: char);
var
 a: char;
 i : integer;

 hour, minute, second, sec100:word;

 el_mn2, el_hr2, el_sc2: longint; {jakob}
 minute_warning : boolean; {jakob}
 s : s30; {jakob}

begin;
 cc:=0;

 a:=#0;
 ch:=#0;
 charorigin:=localchar;

 repeat;
  if not local then begin
   If (Not AsyncCarrierPresent) then DropMessage;
   if charin(a) then charorigin:=remotechar;
  end;
  if keypressed then
    ReadScanCode(a);

  If (a<>#0) then
    ch := a
  else
  If cc mod 100 = 99 then
    ReleaseTimeSlice;

  inc(cc);

  if statline then begin;
   if cc=1 then display_status(false);
   if cc>1000 then cc:=0;

   {jakob start}
   gettime(hour,minute,second,sec100);

   {online events}
   if config.multicheck>0 then begin
    elapsed(hour,minute,second,global_lasthour,global_lastminute,global_lastsecond,el_hr2,el_mn2,el_sc2);

    {should online events be executed?}
    if el_sc2>=config.multicheck then begin
     if global_multi then begin
      node_check;
     end;
     global_lasthour  :=hour;
     global_lastminute:=minute;
     global_lastsecond:=second;
    end;
   end;

   if onliner.location=Onloc_MultiChat then begin
    IpcHook;
   end;

   {inactivity check}
   if (global_multi) and (config.inactivity>0) then begin
    elapsed(hour,minute,second,global_lastkeyhour,global_lastkeyminute,global_lastkeysecond,el_hr2,el_mn2,el_sc2);

    {user inactivity check}
    if el_mn2>=config.inactivity then begin
      d(12,'You have been Disconnected for inactivity!');

      {inform other nodes}
      online_send_to_all(uplc+player.name2+ugreen+' was kicked out from the game because of inactivity!',player.name2,'');

      {news-paper}
      newsy(true,
      'Sleeper Kicked Out',
      ' '+uplc+player.name2+config.textcol1+' fell asleep over the keyboard and',
      ' was kicked out from the game because of inactivity.',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      {inform player via mail}
      s:='Booted from the System!';
      post(MailSend,
      player.name2,
      player.ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+s+config.textcol1,
      mkstring(length(s),underscore),
      'You were booted from the System because of inactivity!',
      'The game has a '+uwhite+commastr(config.inactivity)+config.textcol1+' minute inactivity limit.',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');


      {goodbye}
      normal_exit;


    end
    else if (config.inactivity-el_mn2<2) and (minute_warning=false)then begin
     minute_warning:=true;
     d(12,'***You are about be disconnected for inactivity!***');
    end;
   end;

   {jakob end}

  end;

 until ch<>#0;

 {reset "last keypressed" time}
 global_lastkeyhour  :=hour;
 global_lastkeyminute:=minute;
 global_lastkeysecond:=second;

 if ch=#23  then begin {CTRL+W jakobs rutin}
  who_is_on(false,true);
 end
 else if ch=#20 then begin {CTRL+T jakobs rutin}
  online_message;
 end;

 { A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z}
 {                                    13,               19,         23,}

end;

procedure sread_char(var ch: char);
var
 ch1,ch2: char;
begin;
 curlinenum:=1;
 repeat;

  if macro<>'' then
    begin;
      ch:=macro[1];
      delete(macro,1,1);
    end
  else
    repeat;
    ch:=#0;
    if fouled_up<>#0 then
      begin;
        ch:=fouled_up;
        fouled_up:=#0;
      end
    else
      begin;
        sread_ch(ch1);
        if ch1=^N then
          begin;
            ch1:=#1;
            macro:=macro_str;
          end;

{       delay(20);
        if (ch1=#27) and skeypressed then
          begin;
            sread_ch(ch2);
            if ch2='[' then
              begin;
                sread_ch(ch2);
                if (ch2 in ['1'..'9']) and (skeypressed) then
                  sread_ch(ch2);
                case ch2 of
                   'A' : ch:=^E;
                   'B' : ch:=^X;
                   'C' : ch:=^D;
                   'D' : ch:=^S;
                end;
              end
            else
              begin;
                ch:=ch1;
                fouled_up:=ch2;
              end;
           end
         else
  }
           ch:=ch1;
        end;
  until ch<>#0;
 until ch<>#1;

end;

procedure sread_char_filtered(var ch: char);
begin;
 sread_char(ch);
 {if ch in [#1..#7,#10..#12,#14..#31,#127..#255] then ch:='.';}
end;

procedure get_stacked(var s: string);
var
 s2: string;
 a: integer;
 b: boolean;
begin;
 s:='';
 s2:='';
 b:=false;
 if length(stacked)=0 then begin;
  s:='';
  exit;
 end;
 for a:=1 to length(stacked) do begin;
  if stacked[a]=';' then b:=true else if not b then s:=s+stacked[a];
  if b then s2:=s2+stacked[a];
 end;
 if length(s2)>=1 then delete(s2,1,1);
 stacked:=s2;
end;

procedure sread(var s: string);
var
 ch: char;
 hexsave: boolean;
begin;
 hexsave:=hexon;
 hexon:=false;
 curlinenum:=1;
 s:='';
 get_stacked(s);
 if s<>'' then swrite(s) else begin;
  repeat;
   sread_char_filtered(ch);
   if (ch<>#8) and (ch<>^M) then begin;
    s:=s+ch;
    swrite(ch);
   end;
   if (ch=chr(8)) and (length(s)>0) then begin;
    delete(s,length(s),1);
    swrite(chr(8)+' '+chr(8));
   end;
  until (ch=^M);
  if (pos(';',s)<>0) and (stackon) then begin;
   stacked:=s;
   get_stacked(s);
  end;
 end;
 swriteln('');
 hexon:=hexsave;
 if hexon then hextodec(s);
end;

procedure sread_num(var n: integer);
var
 e: integer;
 s: string;
begin;
 sread(s);
 val(s,n,e);
end;

procedure sread_num_byte(var b: byte);
var
 e: integer;
 s: string;
begin;
 sread(s);
 val(s,b,e);
end;

procedure sread_num_word(var n: word);
var
 e: integer;
 s: string;
begin;
 sread(s);
 val(s,n,e);
end;

procedure sread_num_longint(var n: longint);
var
 e: integer;
 s: string;
begin;
 sread(s);
 val(s,n,e);
end;

 { Speed read is a one time read of the comport.  What I have used it for }
 { is part of another routine that reads for a number of seconds.  Here   }
 { the caller must enter all his commands or info in that time allotment. }
 { They cannot delay a multi-node game by not inputting a command.        }


Procedure SpeedRead(var ch : char);
var
  a : char;
begin
  inc(cc);
  if statline then
    begin;
       if cc=1 then display_status(false);
       if cc>1000 then cc:=0;
    end;

  ch := #0;
  a := #0;
  If local then
    begin
      If KeyPressed then
        ReadScanCode(a);
      If (a<>#0) then
        ch := a
      else
      If cc mod 100 = 99 then
         ReleaseTimeSlice;
      exit;
    end;

  charorigin:=localchar;
  If (Not AsyncCarrierPresent) then DropMessage;

  if charin(a) then
    charorigin:=remotechar
  else
  If KeyPressed then
     ReadScanCode(a);

  If (a<>#0) then
    ch := a
  else
  If cc mod 100 = 99 then
    ReleaseTimeSlice;
end;

function va(i: integer): string;
var
 s: string;
begin;
 str(i,s);
 va:=s;
end;

procedure set_foreground;  { f : byte }
const
  colorf: array[0..7] of integer = (30,34,32,36,31,35,33,37);
  colorb: array[0..7] of integer = (40,44,42,46,41,45,43,47);
var
 s,sb : string;
begin;
 if f > 31 then exit;
 if (f = current_foreground) then exit;
 if Not NoLocal then textcolor(f);

 if not local then
   begin
   if (f=7) and (current_background=0) then
       sendtext(#27+'[0m')
   else
   begin
   If current_background = 0 then
     sb := ''
   else
     sb := ';'+va(colorb[current_background]);
   case f of
     0..7  :  begin
                s := va(colorf[f]);
                case current_foreground of
                { 0..7  : s := s;  }
                  8..31 : s := '0;'+s+sb;
               end;
            end;
     8..15 : begin
               s := va(colorf[f-8]);
               case current_foreground of
                  0..7  : s := '1;'+s;
              {   8..15 : s := s; }
                 16..31 : s := '0;1;'+s+sb;
               end;
             end;
    16..23 : begin
               s := va(colorf[f-16]);
               case current_foreground of
                  0..7  : s := '5;'+s;
                  8..15,
               { 16..23 : s := s; }
                 24..31 : s := '0;5;'+s+sb;
               end;
            end;
    24..31 : begin
               s := va(colorf[f-24]);
                case current_foreground of
                  0..7  : s := '1;5;'+s;
                  8..15 : s := '5;'+s;
                 16..23 : s := '1;'+s;
              {  24..31 : s := s; }
                end;
            end;
     end;
       sendtext(#27+'['+s+'m');
    end;
  end;
  current_foreground:=f;
end;

procedure set_background;  { b : byte }
const
 colorb: array[0..7] of integer = (40,44,42,46,41,45,43,47);
begin;
 if b > 7 then exit;
 if (b = current_background) then exit;
 if Not NoLocal then textbackground(b);
 current_background:=b;
 if not local then
    if (current_foreground=7) and (b=0) then
       sendtext(#27+'[0m')
    else
       sendtext(#27+'['+va(colorb[b])+'m');
end;

Procedure Set_Color;     { f,b : byte }
const
  colorf: array[0..7] of integer = (30,34,32,36,31,35,33,37);
  colorb: array[0..7] of integer = (40,44,42,46,41,45,43,47);
var
 f1:byte;
 s:string;
 NoBackG_Ok : boolean;
begin
 if (f>31) or (b>7) then exit;
 if (f=current_foreground) and (b=current_background) then exit;
 if (f<>current_foreground) and (b<>current_background) then
    begin
      if Not NoLocal then
        begin
          textcolor(f);
          textbackground(b);
        end;
      If not local then
         If (f=7) and (b=0) then
            sendtext(#27+'[0m')
         else
         begin
          s := '[';
          NoBackG_OK := false;
          case f of
            0..7  : begin
                      f1:=f;
                      case current_foreground of
                      { 0..7  : s := s;  }
                        8..31 : begin
                                  s := s+'0;';
                                  NoBackG_OK := true;
                                end;
                      end;
                    end;
            8..15 : begin
                      f1:=f-8;
                      case current_foreground of
                        0..7  : s := s+'1;';
                    {   8..15 : s := s; }
                       16..31 : begin
                                  s := s+'0;1;';
                                  NoBackG_OK := true;
                                end;
                      end;
                    end;
           16..23 : begin
                      f1:=f-16;
                      case current_foreground of
                        0..7  : s := s+'5;';
                        8..15,
                     { 16..23 : s := s; }
                       24..31 : begin
                                  s := s+'0;5;';
                                  NoBackG_OK := true;
                                end;
                     end;
                   end;
          24..31 : begin
                     f1:=f-24;
                     case current_foreground of
                        0..7  : s := s+'1;5;';
                        8..15 : s := s+'5;';
                       16..23 : s := s+'1;';
                    {  24..31 : s := s; }
                     end;
                   end;
         end;
         If NoBackG_OK and (b=0) then
           sendtext(#27+s+va(colorf[f1])+'m')
         else
           sendtext(#27+s+va(colorf[f1])+';'+va(colorb[b])+'m');
      end;
      current_foreground:=f;
      current_background:=b;
    end
     else
     if (f<>current_foreground) then
        set_foreground(f)
     else
       set_background(b);
end;


procedure PromptJ; {jakobs PromptJ, (replacing ddplus prompt routine)
                    improving stacked strings}
const
 promptcol1=7;
 promptcol2=1;
 promptcol3=15;
var

 fg,bg: integer;
 x,y,code: integer;
 ch: char;
 a: integer;
 hexsave: boolean;

 jake: string;

begin;

 hexsave:=hexon;
 hexon:=false;
 fg:=current_foreground;
 bg:=current_background;

 if get_stack then begin
  get_stacked(s);
 end;

 jake:='';
 if s<>'' then begin;
  {set_foreground(promptcol3);}
  while length(s)>le do delete(s,length(s),1);
  swrite(s);
  jake:=s;
  {set_foreground(fg);}
 end;

 s:=jake;
 if not color_chg then pc:=false;
 if pc then begin;
  set_foreground(promptcol1);
  set_background(promptcol2);
  for a:=1 to le do swrite(' ');
  for a:=1 to le do swrite(#8);
  x:=wherex;
  y:=wherey;
 end;

  repeat;
   sread_char_filtered(ch); {read(kbd,ch);}
   if (ch<>#8) and (ch<>^M) and (length(s)<le) then begin;
    s:=s+ch;
    swrite(ch); { write(ch);}
   end;
   if length(s)>200 then delete(s,1,1);
   if (ch=chr(8)) and (length(s)>0) then begin;
    delete(s,length(s),1);
    swrite(chr(8));                                { write(#8,' ',#8);}
    swrite(' ');
    swrite(#8);
   end;
  until (ch=^M) or (length(s)=999);
  if pc then begin;
   set_foreground(promptcol3);
   set_background(bg);
   while wherex>x do swrite(#8);
   swrite(s);                                      { write(s);}
   while wherex<x+le do swrite(' ');               { write(' ');}
   set_foreground(fg);
  end;
  swriteln('');                                    { writeln('');}
  if pos(';',s)<>0 then begin;
   stacked:=s;
   get_stacked(s);
   while length(s)>le do delete(s,length(s),1);
  end;
 hexon:=hexsave;

end;

procedure promptsec; {jakobs egna, f”r l”senord, returnerar '*' eller annat}
const
 promptcol1=7;
 promptcol2=1;
 promptcol3=15;
var
 fg,bg: integer;
 x,y,code: integer;
 ch: char;
 a: integer;
 hexsave: boolean;
begin;
 hexsave:=hexon;
 hexon:=false;
 fg:=current_foreground;
 bg:=current_background;
 get_stacked(s);
 if s<>'' then begin;
  set_foreground(promptcol3);
  while length(s)>le do delete(s,length(s),1);
  swrite(s);
  set_foreground(fg);
 end else begin;
  if not color_chg then pc:=false;
  if pc then begin;
   set_foreground(promptcol1);
   set_background(promptcol2);
   for a:=1 to le do swrite(' ');
   for a:=1 to le do swrite(#8);
   x:=wherex;
   y:=wherey;
  end;
  s:='';
  repeat;
   sread_char_filtered(ch);                                 { read(kbd,ch);}
   if (ch<>#8) and (ch<>^M) and (length(s)<le) then begin;
    s:=s+ch;
    {swrite(ch);}                                    { write(ch);}
    swrite(sec);
   end;
   if length(s)>200 then delete(s,1,1);
   if (ch=chr(8)) and (length(s)>0) then begin;
    delete(s,length(s),1);
    swrite(chr(8));                                { write(#8,' ',#8);}
    swrite(' ');
    swrite(#8);
   end;
  until (ch=^M) or (length(s)=999);
  if pc then begin;
   set_foreground(promptcol3);
   set_background(bg);
   while wherex>x do swrite(#8);
   swrite(s);                                      { write(s);}
   while wherex<x+le do swrite(' ');               { write(' ');}
   set_foreground(fg);
  end;
  swriteln('');                                    { writeln('');}
  if pos(';',s)<>0 then begin;
   stacked:=s;
   get_stacked(s);
   while length(s)>le do delete(s,length(s),1);
  end;
 end;
 hexon:=hexsave;
end;

procedure promptwr;  {jakob, som PROMPT ovan, men med word wrap}
const
 promptcol1=7;
 promptcol2=1;
 promptcol3=15;
var
 fg,bg: integer;
 x,y,code: integer;
 ch: char;
 a: integer;
 hexsave: boolean;
begin;

 hexsave:=hexon;
 hexon:=false;
 fg:=current_foreground;
 bg:=current_background;
 {get_stacked(s);}

 if s<>'' then begin;
  swrite(s);
 end;

 if s<>'†††' then begin;
  if not color_chg then pc:=false;
  if pc then begin;
   set_foreground(promptcol1);
   set_background(promptcol2);
   for a:=1 to le do swrite(' ');
   for a:=1 to le do swrite(#8);
   x:=wherex;
   y:=wherey;
  end;
  {s:='';}
  repeat;
   sread_char_filtered(ch);                                 { read(kbd,ch);}
   if (ch<>#8) and (ch<>^M) and (length(s)<le) then begin;
    s:=s+ch;
    swrite(ch);                                    { write(ch);}
   end;
   if length(s)>200 then delete(s,1,1);
   if (ch=chr(8)) and (length(s)>0) then begin;
    delete(s,length(s),1);
    swrite(chr(8));                                { write(#8,' ',#8);}
    swrite(' ');
    swrite(#8);
   end;
  until (ch=^M) or (length(s)=le); {jakobs „ndring f”r att f† wordwrap}

  if pc then begin;
   set_foreground(promptcol3);
   set_background(bg);
   while wherex>x do swrite(#8);
   swrite(s);                                      { write(s);}
   while wherex<x+le do swrite(' ');               { write(' ');}
   set_foreground(fg);
  end;
  {swriteln('');}                                    { writeln('');}

  {if pos(';',s)<>0 then begin;
   stacked:=s;
   {get_stacked(s);}
   {while length(s)>le do delete(s,length(s),1);
  end;}

 end;
 hexon:=hexsave;
end;

procedure sgoto_xy;
var
 s,s2: string;
begin;
 gotoxy(x,y);
 curlinenum := y;
 s:=#27+'[';
 str(y,s2);
 s:=s+s2;
 str(x,s2);
 s:=s+';'+s2+'f';
 if not local then sendtext(s);
end;

function skeypressed: boolean;
var
 b: boolean;
begin;
 b:=false;
 if not local then b:=AsyncCharPresent;
 if not b then     b:=keypressed;
 if macro<>'' then b:=true;
 skeypressed:=b;
end;

procedure close_async_port;
begin;
 if buffered then begin;
   buffered:=false;
   AsyncFlushOutput;
   AsyncCloseUp;
 end;
end;

procedure open_async_port;
begin;
 AsyncSelectPort(com_port);
 if lockbaud=0 then
  AsyncSetBaud(baud_rate)
 else
  AsyncSetBaud(lockbaud);
 buffered := true;   { Not set in original DD - this may not be the best }
                     { place for this but it does work in my tests       }
end;
{
  }
var
 nclastchar: char;

function NewCrtOutPut(var f: textrec): integer;
var
 p: integer;
begin;
 for p:=0 to f.bufpos-1 do swrite(f.bufptr^[p]);
 f.bufpos:=0;
 NewCrtOutPut:=0;
end;

function NewCrtInPut(var f: textrec): integer;
var
 p: integer;
 ch: char;
begin;
 with f do begin;
  p:=0;
  if nclastchar=#13 then begin; nclastchar:=' '; end else repeat;
   ch:=readkey;
   nclastchar:=ch;
   write(ch);
   bufptr^[p]:=ch;
   inc(p);
   if ch=#13 then write(#10);
   if ch=#8 then begin;
    write(' '#8);
    if p>0 then dec(p);
    if p>0 then dec(p);
   end;
  until (p=bufsize-1) or (ch=#13);
  bufpos:=0;
  bufend:=p;
 end;
 NewCrtInput:=0;
end;

function NewCrtIgnore(var f: textrec): integer;
begin;
 newcrtignore:=0;
end;

function NewCRTOpen(var f: textrec): integer;
begin;
 if f.mode=fmInput then begin;
  f.inoutfunc:=@NewCrtInput;
  f.flushfunc:=@NewCrtIgnore;
 end else begin;
  f.mode:=fmOutput;
  f.inoutfunc:=@NewCrtOutPut;
  f.flushfunc:=@NewCrtOutPut;
 end;
 NewCrtOpen:=0;
end;

Function RipDetect: boolean;
var
  i,j,k : integer;
  a : char;
  s : string;
  RipYes : boolean;
begin
 RipYes := false;
 If local then
   begin
     RipDetect := RipYes;
     exit;
   end;

 exit; {jakob vill inte ha rip detect, slowar upp i b”rjan}

 sendtext(#27+'[0;30m'+#13+#10);
 writeln;
 writeln('Checking for RIP');
 sendtext(#27'[!');
 delay2(222);
 s := '';
 i := 0;
 j := 0;
 charorigin:=localchar;
 repeat;

   a:=chr(0);
   inc(i);

  If (Not AsyncCarrierPresent) then DropMessage;

  if charin(a) then
    charorigin:=remotechar;
  if (a<>chr(0)) then
    begin
      s := s+a;
      inc(j);
    end
  else
     begin
       If (i mod 50 = 0) then
         ReleaseTimeSlice;
     end;
  delay2(2);
  until (i>666) or (j>13);

  If Copy(s,1,3) = 'RIP' then
    begin
      RipYes := true;
      writeln('Rip Detected');
      if charin(a) then
         charorigin:=remotechar;
    end;
 RipDetect := RipYes;
 Swriteln('');
end;

procedure DDAssignSOutput(var f: text);
begin;
 with textrec(f) do begin;
  handle   := $FFFF;
  mode     := fmclosed;
  bufsize  := sizeof(buffer);
  bufptr   := @buffer;
  OpenFunc := @NewCrtOpen;
  CloseFunc:= @NewCrtIgnore;
  Name[0]  := #0;
 end;
end;

Procedure StatusMess(var fs:string);
begin
  Set_Color(2,0);
  Case Tasker of
    1 : writeln('DESQview Detected');
    2 : writeln('MS-Windows Detected'); {jakob}
    3 : writeln('OS/2 Detected');
    4 : writeln('Win/NT Detected');
    5 : writeln('Dos 5.0 with Network Detected');
    6 : writeln('Dos 5.0+ Detected');
  else
        writeln('No Multiplexer Detected');
  end;
  If FossilIO or DigiIO then
   begin
      Set_Foreground(10);
      writeln(fs);
   end;
  Set_Color(7,0);
  ReleaseTimeSlice;
end;

procedure InitDoorDriver(ConfigFileName: string);
Var
 i,a: byte;
 b: integer;
 junk: word;
 fossilstr:string;

begin;

 initddansi;
 oldtextmode:=lastmode;
 lastsetfore:=99;
 setforecheck:=false;
 badchar:='';
 fossilstr:='';
 digiio:=false;
 fossilio:=false;
 ansion:=false;
 moreok:=false;
 numlines:=ScreenRows; {jakob}
 {numlines:=25; {ddplus original}
 cc:=0;
 F1toggle:=0;
 Inchat:=0;
 clrscr;
 window(1,1,80,numlines-1);
 node_num:=1;
 statfore:=7;
 statback:=1;
 GoRip := 0;
 com_port:=0;
 fouled_up:=#0;
 stacked:='';
 hexon:=false;
 buffered:=false;
 cdropped:=false;
 tdropped:=false;
 exitsave:=Exitproc;
 exitproc:=@DDexit;
 firsttime:=true;

 LoadPorts(port1,port2,port3,port4,irq1,irq2,irq3,irq4);
 Loadconfig( ConfigFileName,
             bbs_software,
             user_first_name,user_last_name,
             user_access_level,
             bbs_time_left,
             com_port,
             baud_rate,
             node_num,
             local,
             graphics,
             color1,
             color_chg,
             noFossinit,
             board_name,
             pause_code,
             sysop_first_name,
             sysop_last_name,
             maxtime,
             localcol,
             statfore,
             statback,
             statline,
             EMSOK,NetOK,
             nolocal,
             fossilio,
             digiio,
             dropfilepath,
             GoRip,
             lockbaud,
             nodirect,
             port1,port2,port3,port4,irq1,irq2,irq3,irq4);

 numlines:=ScreenRows; {jakob}
 {numlines:=25; {ddplus original}

 if nodirect then directvideo:=false;
 clrscr;
 window(1,1,80,numlines-1);
 textcolor(7);
 textbackground(0);
 default_fore:=7;
 default_back:=0;
 gettime(st_hr,st_mn,st_sc,junk);

 GetBBSInfo( bbs_software,
             user_first_name,user_last_name,
             user_access_level,
             bbs_time_left,
             com_port,
             baud_rate,
             node_num,
             local,
             graphics,
             color1,
             color_chg,
             board_name,
             sysop_first_name,
             sysop_last_name,
             maxtime,
             dropfilepath,
             lockbaud);

 ReSetPorts(port1,port2,port3,port4,irq1,irq2,irq3,irq4);

 if not local then
   begin;
    if FossilIO then AsyncSelectFossil(fossilstr) else
     if DigiIO then AsyncSelectDigiBoard(fossilstr) else
      AsyncSelectInternal;
    Open_Async_Port;
   end;

 if not local then
  if not initok then
   begin
     writeln('');
     if fossilio then
      begin
        writeln('Fossil was not initialized properly! You should change to INTERNAL');
        writeln('communications routines.');
      end
    else
    if digiio then
      begin
        writeln('DigiDriver was not initialized properly!');
      end;
    delay2(1000);
    halt;
  end;

 If GoRip = 4 then     { forces RipLink on }
   If Local then       { If local then forces it into graphics mode as well}
     graphics := 5;
 If Graphics <> 5 then
    If RipDetect then
          graphics := 5;

 DV_Aware_ON;
 current_foreground:=default_fore;
 current_background:=default_back;
 if graphics = 3 then
   begin
     set_foreground(statfore);
     set_background(statback);
   end;
 curlinenum:=1;
 time_check:=true;
 time_credit:=0;
 macro_str:='';
 macro:='';
 mintime:=1;
 notime:='';
 user_first_name:=stu(user_first_name);
 user_last_name:=stu(user_last_name);
 stackon:=true;
{ if node_num=0 then node_num:=1; }
 ddassignsoutput(soutput);
 rewrite(soutput);
 If Not NetOk then
   If (Tasker = 5) then inc(Tasker);
 StatusMess(fossilstr);

end;

end.

