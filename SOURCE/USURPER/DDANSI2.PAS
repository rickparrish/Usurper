unit ddansi2;

interface

uses dos, crt;
{----------------------------------------------------------------------------}
{                       Ansi screen emulation routines                       }
{                              By Scott Baker                                }
{                        Revised By Derrick Parkhurst
{----------------------------------------------------------------------------}
{                                                                            }
{ Purpose: to execute ansi escape sequences locally. This includes changing  }
{          color, moving the cursor, setting high/low intensity, setting     }
{          blinking, and playing music.                                      }
{                                                                            }
{ Remarks: These routines use a few global variables which are defined       }
{          below. So far, only ESC m, J, f, C, and ^N are supported by these }
{          routines. I hope to include more in the future.                   }
{                                                                            }
{ Routines: Here is a listing of the subroutines:                            }
{                                                                            }
{             change_color(x):      Change to ansi color code X.             }
{             Eval_string(s):       Evaluate/execute ansi string             }
{             ansi_write(ch):       Write a character with ansi checking     }
{                                                                            }
{----------------------------------------------------------------------------}

var
 escape,blink,high,norm,any,any2,fflag,gflag: boolean;
 ansi_string: string;
const
 ddansibanner: boolean = true;

procedure ansi_write(ch: char);
procedure ansi_write_str(var s: string);
procedure initddansi;

implementation

const
 scale: array[0..7] of integer = (0,4,2,6,1,5,3,7);
 scaleh: array[0..7] of integer = (8,12,10,14,9,13,11,15);
var
 bbb: boolean;
 t: char;
 restx,resty,curcolor: integer;
 Note_Octave: integer;
 Note_Fraction, Note_Length, Note_Quarter: real;

procedure change_color(c: integer);
begin;
 case c of
  00: begin;any:=true;blink:=false;high:=false;norm:=true;end;
  01: begin;high:=true;end;
  02: begin;clrscr;any:=true;end;
  05: begin;blink:=true;any:=true;end;
 end;
 if (c>29) and (c<38) then begin;
  any:=true;
  any2:=true;
  c:=c-30;
  curcolor:=c;
  if (high=true) and (blink=true) then textcolor(scaleh[c]+32);
  if (high=true) and (blink=false) then textcolor(scaleh[c]);
  if (high=false) and (blink=true) then textcolor(scale[c]+32);
  if (high=false) and (blink=false) then textcolor(scale[c]);
  fflag:=true;
 end;
 if (c>39) and (c<48) then begin;
  any:=true;
  c:=c-40;
  textbackground(scale[c]);
  gflag:=true;
 end;
end;

procedure eval_string(var s: string);
var
 cp: integer;
 T: CHAR;
 b:byte;
 jj,a,ttt,tttt: integer;
 flag1:boolean;
begin;
 t:=s[length(s)];
 cp:=2;
 case t of
  'k','K': clreol;
  'u': gotoxy(restx,resty);
  's': begin;
        restx:=wherex;
        resty:=wherey;
       end;
  'm','J':begin;
           repeat;
            a:=-1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
             end;
             change_color(a);
            end;
            cp:=cp+1;
           until cp>=length(s);
           if norm then begin;
             if (fflag=false) and (gflag=false) then begin;textcolor(7);textbackground(0);curcolor:=7;end;
             if (fflag=false) and (gflag=true) then begin;textcolor(7);curcolor:=7;end;
             if (high=true) and (fflag=false) then textcolor(scaleh[curcolor]);
             if (blink=true) and (fflag=false) then textcolor(scale[curcolor]+32);
             if (blink=true) and (high=true) and (fflag=false) then textcolor(scaleh[curcolor]+32);
             if (fflag=true) and (gflag=false) then begin;textbackground(0);end;
            end;
           if any=false then textcolor(scaleh[curcolor]);
{ 5/12/95 srl }
           if (any2=false)  then
             if (high=true) then
               begin
                 if (blink=true) then
                   textcolor(scaleh[curcolor]+32)
                 else
                   textcolor(scaleh[curcolor]);
               end
             else
             if (blink=true) then textcolor(scale[curcolor]+32);

           any2:=false;any:=false;fflag:=false;gflag:=false;norm:=false;
         end;
   'C': begin;
            a:=1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
             end;
            end else a:=1;
            ttt:=wherex;
            if a+ttt<=80 then gotoxy(a+ttt,wherey);
           end;
   'D': begin;
            a:=1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
             end;
            end else a:=1;
            ttt:=wherex;
            if ttt-a>=1 then gotoxy(ttt-a,wherey);
           end;
   'A': begin;
            a:=1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
             end;
            end else a:=1;
            ttt:=wherey;
            if ttt-a>=1 then gotoxy(wherex,ttt-a);
           end;
   'B': begin;
            a:=1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
             end;
            end else a:=1;
            ttt:=wherey;
            if ttt+a<=25 then gotoxy(wherex,ttt+a);
           end;
  'f','H': begin;
           flag1:=false;
           a:=1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
              flag1:=true;
             end;
            end else a:=1;
            jj:=a;
            if flag1=false then cp:=cp+1;
            if flag1=true then cp:=cp+2;
            if cp<length(s) then begin;
            a:=1;
            val(s[cp],a,tttt);
            if tttt=0 then begin;
             cp:=cp+1;
             val(s[cp],ttt,tttt);
             if tttt=0 then begin;
              a:=a*10;
              a:=a+ttt;
             end;
            end else a:=1;
           end else a:=1;
          gotoxy(a,jj);
       end;
  else writeln(s);
 end;
end;

Procedure ansi_write(ch: char);
begin;
  case ch of
   #12: clrscr;
   #09: repeat; write(' '); until wherex/8 = wherex div 8;
   #27: begin; escape:=true; bbb:=true; end;

   else begin;
    if escape then begin;
     if (bbb=true) and (ch<>'[') then begin;
      blink:=false;
      high:=false;
      escape:=false;
      ansi_string:='';
      write(#27);
     end else bbb:=false;
     if escape then begin;
      ansi_string:=ansi_string+ch;
      if ch=#13 then escape:=false;
      if (ch in ['u','s','A','B','C','D','H','m','J','f','K','k',#14]) then begin;
       escape:=false;
       eval_string(ansi_string);
       ansi_string:='';
      end;
     end;
    end else write(ch);
   end;
  end;
end;

Procedure ansi_write_str(var s: string);
var
 a: integer;
begin;
 for a:=1 to length(s) do begin;
  case s[a] of
   #12: clrscr;
   #09: repeat; write(' '); until wherex/8 = wherex div 8;
   #27: begin; escape:=true; bbb:=true; end;

   else begin;
    if escape then begin;
     if (bbb=true) and (s[a]<>'[') then begin;
      blink:=false;
      high:=false;
      escape:=false;
      ansi_string:='';
      write(#27);
     end else bbb:=false;
     if escape then begin;
      ansi_string:=ansi_string+s[a];
      if s[a]=#13 then escape:=false;
      if (s[a] in ['u','s','A','B','C','D','H','m','J','f','K','k',#14]) then begin;
       escape:=false;
       eval_string(ansi_string);
       ansi_string:='';
      end;
     end;
    end else write(s[a]);
   end;
  end;
 end;
end;

procedure InitDDAnsi;
begin;
 escape:=false;
 ansi_string:='';
 blink:=false;
 high:=false;
end;

end.