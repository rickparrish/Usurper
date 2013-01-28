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

Unit Pedit;

Interface


Procedure Player_Editor (modd : integer );

Implementation
uses crt, init, jakobe,
     obj_aff2, get_num,
     racedis2, clasdis2, spell_i2;

var

   s,ss : s70;
   i, inv, ncol, vcol, col, justval : integer;
   rand, temp, nr : longint;
   ofil : file of objektrec;
   otyp : objtype;
   allmodd : byte;


Function File_size : longint;
var lemmy : integer;
    ok : boolean;
begin

 lemmy:=filemode;

 repeat
  ok:=true;

  case allmodd of
   1: assign(playerfile,pfile);
   2: assign(playerfile,npfile);
  end;

  FileMode:=fmReadOnly+fmDenyNone;

  ok:=true;
  {$I-}reset(playerfile);{$I+}
  if IoResult<>0 then begin
   delay(lockdelay);
   ok:=false;
  end;
 until ok;

 file_size:=filesize(playerfile);
 close(playerfile);
 filemode:=lemmy;

end;

Procedure Load_Player(   action : char;
                      var gubbe : userrec;
                             gr : longint);
var
    memmy : integer;
    i : integer;
    ok : boolean;

begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;

  case allmodd of
   1: assign(playerfile,pfile);
   2: assign(playerfile,npfile);
  end;

  case action of
   'L': FileMode:=fmReadOnly+fmDenyNone;
   'S': FileMode:=fmReadWrite+fmDenyAll;
  end;

  {$I-}reset(playerfile);{$I+}

  if IOResult<>0 then begin
   display(0,14,0,'Denied access... :');
   delay(lockdelay);
   ok:=false;
   inc(i);
  end;

 until (Ok) or (i>20);

 seek(playerfile,gr);
 case action of
  'L': Read (playerfile,gubbe);
  'S': Write(playerfile,gubbe);
 end;
 close(playerfile);
 filemode:=memmy;

end;

Function Get_Type ( oldtype : objtype ) : ObjType;
var
   tmptype : objtype;
   a : string[5];
   start, i : integer;

begin
 crlf;
 display(0,13,0,'Select Type of Object :');
 crlf;

 sdisplay(0,3,0,'#1 Head    ');
 display(0,3,0,'#10 Face');

 sdisplay(0,3,0,'#2 Body    ');
 display(0,3,0,'#11 Shield');

 sdisplay(0,3,0,'#3 Arms    ');
 display(0,3,0,'#12 Food');

 sdisplay(0,3,0,'#4 Hands   ');
 display(0,3,0,'#13 Drink');

 sdisplay(0,3,0,'#5 Fingers ');
 display(0,3,0,'#14 Weapon');

 sdisplay(0,3,0,'#6 Legs    ');
 display(0,3,0,'#15 Around Body');

 display(0,3,0,'#7 Feet    ');

 display(0,3,0,'#8 Waist   ');
 display(0,3,0,'#9 Neck');

 crlf;
 sdisplay(0,2,0,':');

 {prompt(a,2,false);}
 val(a,start,i);
 if (i<>0) or (start<1) or (start>16) then start:=0;

 tmptype:=oldtype;

 case start of
  1: tmptype:= Head;
  2: tmptype:= Body;
  3: tmptype:= Arms;
  4: tmptype:= Hands;
  5: tmptype:= Fingers;
  6: tmptype:= Legs;
  7: tmptype:= Feet;
  8: tmptype:= Waist;
  9: tmptype:= Neck;
 10: tmptype:= Face;
 11: tmptype:= Shield;
 12: tmptype:= Food;
 13: tmptype:= Drink;
 14: tmptype:= Weapon;
 15: tmptype:= Abody;
 end;

 get_type:=tmptype;

end;

Procedure Big_Display;
begin

 sdisplay(0,3,0,'#1  ');
 sdisplay(0,col,0,'User Name : ');
 sdisplay(0,10,0,ljust(player.name1,justval));
 sdisplay(0,3,0,'#22 ');
 sdisplay(0,col,0,'Good Deeds     : ');
 display(0,vcol,0,commastr(player.chivnr));

 sdisplay(0,3,0,'#2  ');
 sdisplay(0,col,0,'Alias     : ');
 sdisplay(0,10,0,ljust(player.name2,justval));
 sdisplay(0,3,0,'#23 ');
 sdisplay(0,col,0,'Team name      : ');
 display(0,vcol,0,player.team);

 if player.ai='H' then ss:='Human'
                  else ss:='Computer';

 sdisplay(0,3,0,'#3  ');
 sdisplay(0,col,0,'Control   : ');
 sdisplay(0,vcol,0,ljust(ss,justval));
 sdisplay(0,3,0,'#24 ');
 sdisplay(0,col,0,'Team Password  : ');
 display(0,vcol,0,player.teampw);

 sdisplay(0,3,0,'#4  ');
 sdisplay(0,col,0,'Race      : ');
 sdisplay(0,vcol,0,ljust(race_display(player.race),justval));
 sdisplay(0,3,0,'#25 ');
 sdisplay(0,col,0,'Drug Addiction : ');
 display(0,vcol,0,commastr(player.addict)+' %');

 sdisplay(0,3,0,'#5  ');
 sdisplay(0,col,0,'Age       : ');
 sdisplay(0,vcol,0,ljust(commastr(player.age),justval));
 sdisplay(0,3,0,'#26 ');
 sdisplay(0,col,0,'Mental Health  : ');
 display(0,vcol,0,commastr(player.mental)+' %');

 sdisplay(0,3,0,'#6  ');
 sdisplay(0,col,0,'Money     : ');
 sdisplay(0,vcol,0,ljust(commastr(player.money),justval));
 if player.wellwish=false then ss:='No'
                          else ss:='Yes';

 sdisplay(0,3,0,'#27 ');
 sdisplay(0,col,0,'Well Visited   : ');
 display(0,vcol,0,ss);

 sdisplay(0,3,0,'#7  ');
 sdisplay(0,col,0,'Bank Funds: ');
 sdisplay(0,vcol,0,ljust(commastr(player.bank),justval));
 sdisplay(0,3,0,'#28 ');
 sdisplay(0,col,0,'Class          : ');
 display(0,vcol,0,class_display(player.class));

 sdisplay(0,3,0,'#8  ');
 sdisplay(0,col,0,'Hitpoints : ');
 sdisplay(0,vcol,0,ljust(commastr(player.hps),justval));
 sdisplay(0,3,0,'#29 ');
 sdisplay(0,col,0,'Mana           : ');
 display(0,vcol,0,commastr(player.mana));

 sdisplay(0,3,0,'#9  ');
 sdisplay(0,col,0,'Max Hps   : ');
 sdisplay(0,vcol,0,ljust(commastr(player.maxhps),justval));
 sdisplay(0,3,0,'#30 ');
 sdisplay(0,col,0,'Maxmana        : ');
 display(0,vcol,0,commastr(player.maxmana));

 sdisplay(0,3,0,'#10 ');
 sdisplay(0,col,0,'Experience: ');
 sdisplay(0,vcol,0,ljust(commastr(player.exp),justval));
 sdisplay(0,3,0,'#31 ');
 sdisplay(0,col,0,'Stamina        : ');
 display(0,vcol,0,commastr(player.stamina));

 sdisplay(0,3,0,'#11 ');
 sdisplay(0,col,0,'Level     : ');
 sdisplay(0,vcol,0,ljust(commastr(player.level),justval));
 sdisplay(0,3,0,'#32 ');
 sdisplay(0,col,0,'Agility        : ');
 display(0,vcol,0,commastr(player.agility));

 sdisplay(0,3,0,'#12 ');
 sdisplay(0,col,0,'Chivalry  : ');
 sdisplay(0,vcol,0,ljust(commastr(player.chiv),justval));
 sdisplay(0,3,0,'#33 ');
 sdisplay(0,col,0,'Charisma       : ');
 display(0,vcol,0,commastr(player.charisma));

 sdisplay(0,3,0,'#13 ');
 sdisplay(0,col,0,'Darkness  : ');
 sdisplay(0,vcol,0,ljust(commastr(player.dark),justval));
 sdisplay(0,3,0,'#34 ');
 sdisplay(0,col,0,'Dexterity      : ');
 display(0,vcol,0,commastr(player.dex));

 sdisplay(0,3,0,'#14 ');
 sdisplay(0,col,0,'Dng Fghts : ');
 sdisplay(0,vcol,0,ljust(commastr(player.fights),justval));
 sdisplay(0,3,0,'#35 ');
 sdisplay(0,col,0,'Wisdom         : ');
 display(0,vcol,0,commastr(player.wisdom)+'  ');

 sdisplay(0,3,0,'#15 ');
 sdisplay(0,col,0,'Strength  : ');
 sdisplay(0,vcol,0,ljust(commastr(player.strength),justval));
 sdisplay(0,3,0,'#36 ');
 sdisplay(0,col,0,'Trainings      : ');
 display(0,vcol,0,commastr(player.trains));

 sdisplay(0,3,0,'#16 ');
 sdisplay(0,col,0,'Defence   : ');
 sdisplay(0,vcol,0,ljust(commastr(player.defence),justval));
 sdisplay(0,3,0,'#37 ');
 sdisplay(0,col,0,'Never Delete Character : ');
 if player.immortal=false then display(0,vcol,0,'No')
                          else display(0,vcol,0,'Yes');

 sdisplay(0,3,0,'#17 ');
 sdisplay(0,col,0,'Healings  : ');
 sdisplay(0,vcol,0,ljust(commastr(player.healing),justval));
 sdisplay(0,3,0,'#38 ');
 sdisplay(0,col,0,'Plague    : ');
 if player.plague=false then display(0,vcol,0,'No')
                        else display(0,vcol,0,'Yes');

 sdisplay(0,3,0,'#18 ');
 if player.allow=true then ss:='Yes'
                      else ss:='No';

 sdisplay(0,col,0,'Allow in  : ');
 sdisplay(0,vcol,0,ljust(ss,justval));
 sdisplay(0,3,0,'#39 ');
 sdisplay(0,col,0,'Smallpox  : ');
 if player.smallpox=false then display(0,vcol,0,'No')
                          else display(0,vcol,0,'Yes');

 sdisplay(0,3,0,'#19 ');
 sdisplay(0,col,0,'Last on   : ');
 sdisplay(0,vcol,0,ljust(player.laston,justval));
 sdisplay(0,3,0,'#40 ');
 sdisplay(0,col,0,'Measles   : ');
 if player.measles=false then display(0,vcol,0,'No')
                         else display(0,vcol,0,'Yes');

 sdisplay(0,3,0,'#20 ');
 sdisplay(0,col,0,'Pl Fghts  : ');
 sdisplay(0,vcol,0,ljust(commastr(player.pfights),justval));
 sdisplay(0,3,0,'#41 ');
 sdisplay(0,col,0,'Leprosy   : ');
 if player.leprosy=false then display(0,vcol,0,'No')
                         else display(0,vcol,0,'Yes');

 sdisplay(0,3,0,'#21 ');
 sdisplay(0,col,0,'Dark Deeds: ');
 sdisplay(0,vcol,0,ljust(commastr(player.darknr),justval));
 sdisplay(0,3,0,'#42 ');
 sdisplay(0,col,0,'Blindness : ');
 if player.blind=false then display(0,vcol,0,'No')
                       else display(0,vcol,0,'Yes');

 sdisplay(0,12,0,'[User # ');
 sdisplay(0,14,0,commastr(edman+1));
 sdisplay(0,12,0,']          ');

 menu('(S)earch..');

 sdisplay(0,2,0,'[');
 sdisplay(0,5,0,'Enter');
 sdisplay(0,2,0,'] for More    ');

 menu2('(+) Next user, ');
 menu2('(-) Last User, ');
 menu('(<) Move to top of file');

 sdisplay(0,2,0,'[');
 sdisplay(0,5,0,'Esc');
 sdisplay(0,2,0,'] Quit  ');

 menu2('(A)dd   ');
 menu2('(D)elete User  ');
 menu2('(E)dit value   ');
 menu2('(>) Move to end of file :');

end;

Procedure Objekt_Load ( otyp : objtype;
                        nr : longint );
var
    ok : boolean;
    cc : integer;

begin

 assign(ofil,objf1);
 if (nr>62000) or (nr<1) then begin
  nr:=1;
 end;

 case otyp of
  Head    : assign(ofil,objf1);
  Body    : assign(ofil,objf2);
  Arms    : assign(ofil,objf3);
  Hands   : assign(ofil,objf4);
  Fingers : assign(ofil,objf5);
  Legs    : assign(ofil,objf6);
  Feet    : assign(ofil,objf7);
  Waist   : assign(ofil,objf8);
  Neck    : assign(ofil,objf9);
  Face    : assign(ofil,objf10);
  Shield  : assign(ofil,objf11);
  Food    : assign(ofil,objf12);
  Drink   : assign(ofil,objf13);
  Weapon  : assign(ofil,objf14);
  Abody   : assign(ofil,objf15);
 end;

 objekt.name:='';

 reset(ofil);
 seek(ofil,nr-1);
 {$I-}read(ofil,objekt);{$I+}

 if IOResult<>0 then begin
  sdisplay(0,15,0,'Error in Objekt Loader #');
  display(0,15,0,commastr(nr));
  reset(ofil);
  read(ofil,objekt);
 end;

 close(ofil);

end;

Function Get_Char (s1,s2,s3,s4,s5: s70;
                   c1,c2 : char)  : char;

 var tcol : integer;
     charry : char;

begin

 tcol:=15;

 if s1<>'' then display(0,tcol,0,s1);
 if s2<>'' then display(0,tcol,0,s2);
 if s3<>'' then display(0,tcol,0,s3);
 if s4<>'' then display(0,tcol,0,s4);
 if s5<>'' then display(0,tcol,0,s5);

 sdisplay(0,2,0,':');

 repeat
  charry:=upcase(getchar);
 until (charry=c1) or (charry=c2);

 get_char:=charry;

 finger:=1;

end;

Function Get_Boolean (s1,s2,s3,s4,s5 : s70) : boolean;
 var tcol : integer;
begin

 tcol:=15;

 if s1<>'' then display(0,tcol,0,s1);
 if s2<>'' then display(0,tcol,0,s2);
 if s3<>'' then display(0,tcol,0,s3);
 if s4<>'' then display(0,tcol,0,s4);
 if s5<>'' then display(0,tcol,0,s5);

 sdisplay(0,2,0,':');

 if confirm(' ','N')=true then get_boolean:=true
                          else get_boolean:=false;

end;

Function Get_String (s1,s2,s3,s4,s5,oldval : s70) : s70;
 var tcol : integer;
     st : string[90];
begin

 tcol:=15;
 get_string:=oldval;

 if s1<>'' then display(0,tcol,0,s1);
 if s2<>'' then display(0,tcol,0,s2);
 if s3<>'' then display(0,tcol,0,s3);
 if s4<>'' then display(0,tcol,0,s4);
 if s5<>'' then display(0,tcol,0,s5);

 sdisplay(0,2,0,':');

 {prompt(st,30,false);}
 get_string:=st;
 finger:=1;

end;

Procedure Objekt_List ( otype : objtype );

var count,cc : longint;
begin

 case otype of
  Head    : assign(ofil,objf1);
  Body    : assign(ofil,objf2);
  Arms    : assign(ofil,objf3);
  Hands   : assign(ofil,objf4);
  Fingers : assign(ofil,objf5);
  Legs    : assign(ofil,objf6);
  Feet    : assign(ofil,objf7);
  Waist   : assign(ofil,objf8);
  Neck    : assign(ofil,objf9);
  Face    : assign(ofil,objf10);
  Shield  : assign(ofil,objf11);
  Food    : assign(ofil,objf12);
  Drink   : assign(ofil,objf13);
  Weapon  : assign(ofil,objf14);
  Abody   : assign(ofil,objf15);
 end;

 count:=0;
 reset(ofil);
 for cc:=1 to filesize(ofil) do begin
  read(ofil,objekt);
  sdisplay(0,3,0,'#'+commastr(cc));
  display(0,15,0,' '+objekt.name);

  inc(count);
  if (count>14) or (cc=filesize(ofil)) then begin
   count:=0;
   if confirm('Continue List ','Y')=false then begin
    break;
   end;
  end;
 end;

 finger:=1;

end;

Function Select_Objekt ( otype : objtype ) : longint;

var selected, nr : longint;
    i : integer;
    big : s70;

begin

 case otype of
  Head    : assign(ofil,objf1);
  Body    : assign(ofil,objf2);
  Arms    : assign(ofil,objf3);
  Hands   : assign(ofil,objf4);
  Fingers : assign(ofil,objf5);
  Legs    : assign(ofil,objf6);
  Feet    : assign(ofil,objf7);
  Waist   : assign(ofil,objf8);
  Neck    : assign(ofil,objf9);
  Face    : assign(ofil,objf10);
  Shield  : assign(ofil,objf11);
  Food    : assign(ofil,objf12);
  Drink   : assign(ofil,objf13);
  Weapon  : assign(ofil,objf14);
  Abody   : assign(ofil,objf15);
 end;

 selected:=0;

 repeat
  reset(ofil);

  crlf;
  case otype of
   Head    : display(0,12,0,'*Head*');
   Body    : display(0,12,0,'*Body*');
   Arms    : display(0,12,0,'*Arms*');
   Hands   : display(0,12,0,'*Hands*');
   Fingers : display(0,12,0,'*Fingers*');
   Legs    : display(0,12,0,'*Legs*');
   Feet    : display(0,12,0,'*Feet*');
   Waist   : display(0,12,0,'*Waist*');
   Neck    : display(0,12,0,'*Neck*');
   Face    : display(0,12,0,'*Face*');
   Shield  : display(0,12,0,'*Shield*');
   Food    : display(0,12,0,'*Food*');
   Drink   : display(0,12,0,'*Drink*');
   Weapon  : display(0,12,0,'*Weapon*');
  end;

  display(0,2,0,'Enter Object #  ( Objects range from 1 - '+commastr(filesize(ofil)));
  display(0,2,0,'                      ? = list of available items');
  display(0,2,0,'                     -1 = removes current object from player');
  display(0,2,0,'                  Enter = Exit )');

  sdisplay(0,2,0,':');

  prompt(big,30,false);

  if big='?' then begin
   objekt_list(otype);
  end
  else if big=' ' then begin
   crlf;
  end
  else if big='-1' then begin
   selected:=-1;
  end
  else begin
   val(big,nr,i);
   if i=0 then begin
    if (nr>=1) and (nr<=filesize(ofil)) then begin
     reset(ofil);
     seek(ofil,nr-1);
     read(ofil,objekt);

     sdisplay(0,15,0,' '+objekt.name);
     if confirm(' ','N')=true then begin
      selected:=nr;
     end;

    end;
   end;
  end;
 until (big='') or (big='-1') or (selected>0);

 select_objekt:=selected;
 close(ofil);
 finger:=1;

end;

Procedure Player_Editor;
var
    x1,y1 : byte;
    pl0 : userrec;

begin

 allmodd:=modd;

 case allmodd of
  1: assign(playerfile,pfile);
  2: assign(playerfile,npfile);
 end;

 if file_size<=0 then begin
  crlf;
  d('File is empty. Try adding a couple of players.');
  crlf;
  pause;
  exit;
 end;

 load_player('L',player,0);

  edman:=0;
  finger:=0;
  repeat
   clearscreen;

   justval:=17;
   col:=2;
   vcol:=7;
   ncol:=12;

   Big_Display;

   repeat
    ch:=upcase(getchar);
   until ch in [chr(27),chr(13),'+','-','>','<','A','D','E','S'];

   crlf;

   case ch of
    'S':begin
         if finger=1 then begin
          load_player('S',player,edman);
          finger:=0;
         end;

         y1:=21;
         x1:=31;
         gotoxy(x1,y1);
         sdisplay(0,2,0,':');
         {prompt(s,20,false);}
         s:=upcasestr(s);

         if s<>'' then begin
          gotoxy(x1,y1);
          display(0,15,0,'Searching...');
         end;

         for i:=1 to file_size do begin
          load_player('L',pl0,i-1);
          ss:=upcasestr(pl0.name1);
          if length(ss)>length(s) then begin
           delete(ss,length(s)+1,99);
          end;
          if s=ss then begin
           gotoxy(x1,y1);
           sdisplay(0,10,0,pl0.name1);
           if confirm(' ','n')=true then begin
            edman:=i-1;
            player:=pl0;
            break;
           end;
          end;
         end;

        end;
    '>':begin
        edman:=file_size-1;
        load_player('L',player,edman);
        finger:=0;
        end;
    '<':begin
        edman:=0;
        load_player('L',player,edman);
        finger:=0;
        end;
    'A':begin
         d('A copy of the current Character will be added to the file.');
         d('You may then Edit the Character as you wish.');

         if confirm('Go ahead and do this ','N')=true then begin
         
          player.king:=false;
          player.amember:=false;
          player.cturf:=false;
          player.team:='';
          for i:=1 to 20 do begin
           player.medal[i]:=false;
          end;
          player.bankguard:=false;
          player.bankwage:=0;

          load_player('S',player,file_size);

          finger:=0;
         end;
        end;
    'D':begin
        if confirm('Really DELETE player ','N')=true then begin
         player.name1:='Empty';
         player.name2:='Empty';
         load_player('S',player,edman);
         finger:=0;
        end;
        end;
    'E':begin
         display(0,3,0,'# to change');
         sdisplay(0,2,0,':');
         {prompt(a,5,false);}
         val(a,nr,i);
         if i=0 then begin
          case nr of
           1: player.name1:=get_string('Enter new username',
                                       '',
                                       '',
                                       '',
                                       '',
                                       player.name1);

           2: player.name2:=get_string('Enter new Alias',
                                       '',
                                       '',
                                       '',
                                       '',
                                       player.name2);

           3: player.ai:=get_char('(H)uman or (C)omputer Controlled',
                                  '',
                                  '',
                                  '',
                                  '',
                                  'H','C');

           4:begin
              d('1-Human, 2-Hobbit, 3-Elf, 4-HalfElf, 5-Dwarf, 6-Troll');
              d('7-Orc, 8-Gnome, 9-Gnoll, 10-Mutant');
              d('Race (1-10)');
              sdisplay(0,2,0,':');
              {prompt(a,10,false);}
              val(a,rand,i);
              if i=0 then begin
               case rand of
                1: player.race:=Human;
                2: player.race:=Hobbit;
                3: player.race:=Elf;
                4: player.race:=HalfElf;
                5: player.race:=Dwarf;
                6: player.race:=Troll;
                7: player.race:=Orc;
                8: player.race:=Gnome;
                9: player.race:=Gnoll;
               10: player.race:=Mutant;
               end;

               finger:=1;
              end;
             end;
           5: player.age:=get_numeric('Enter new Age',
                                      '',
                                      '',
                                      '',
                                      '',
                                      10,150,player.age);

           6: player.money:=get_numeric('New amount of Money',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,2000000000,player.money);

           7: player.bank:=get_numeric('New amount of Bank Money',
                                       '',
                                       '',
                                       '',
                                       '',
                                       0,2000000000,player.bank);


           8: player.hps:=get_numeric('Hitpoints',
                                       '',
                                       '',
                                       '',
                                       '',
                                       0,player.maxhps,player.hps);


           9: player.maxhps:=get_numeric('Maximum Hitpoints',
                                         '',
                                         '',
                                         '',
                                         '',
                                         1,25000,player.maxhps);


          10: player.exp:=get_numeric('Experience Points',
                                      '',
                                      '',
                                      '',
                                      '',
                                      0,2000000000,player.exp);


          11: player.level:=get_numeric('Player Level',
                                        '',
                                        '',
                                        '',
                                        '',
                                        1,200,player.level);


          12: player.chiv:=get_numeric('Player Chivalry',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,32000000,player.chiv);


          13: player.dark:=get_numeric('Player Darkness',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,32000000,player.dark);


          14: player.fights:=get_numeric('Dungeon Fights',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,99999,player.fights);


          15: player.strength:=get_numeric('Strength',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,32000,player.strength);

          16: player.defence:=get_numeric('Defence',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,32000,player.defence);

          17: player.healing:=get_numeric('Healing Potions',
                                        '',
                                        '',
                                        '',
                                        '',
                                        0,32000,player.healing);

          18: player.allow:=get_boolean('Player allowed to play today?',
                                        '',
                                        '',
                                        '',
                                        '');

          19: player.laston:=get_string('Last on Date',
                                        '',
                                        '',
                                        '',
                                        '',
                                        player.laston);

          20: player.pfights:=get_numeric('Player Fights',
                                          '',
                                          '',
                                          '',
                                          '',
                                          0,99999,player.pfights);

          21: player.darknr:=get_numeric('Dark Deeds',
                                         '',
                                         '',
                                         '',
                                         '',
                                         0,32000,player.darknr);

          22: player.chivnr:=get_numeric('Good Deeds',
                                         '',
                                         '',
                                         '',
                                         '',
                                         0,32000,player.chivnr);

          23: player.team:=get_string('Team Name',
                                      '',
                                      '',
                                      '',
                                      '',
                                      player.team);

          24: player.teampw:=get_string('Team Password',
                                        '',
                                        '',
                                        '',
                                        '',
                                        player.teampw);

          25: player.addict:=get_numeric('Drug Addiction',
                                         '',
                                         '',
                                         '',
                                         '',
                                         0,100,player.addict);

          26: player.mental:=get_numeric('Mental Stability',
                                         '',
                                         '',
                                         '',
                                         '',
                                         0,100,player.mental);

          27: player.wellwish:=get_boolean('Well Visited',
                                           '',
                                           '',
                                           '',
                                           '');
          28:begin
              d('1-Alchemist, 2-Assassin, 3-Barbarian, 4-Bard, 5-Cleric, 6-Jester');
              d('7-Magician, 8-Paladin, 9-Ranger, 10-Sage, 11-Warrior');
              d('Class (1-11)');
              sdisplay(0,2,0,':');
              {prompt(a,10,false);}
              val(a,rand,i);
              if i=0 then begin
               case rand of
                1: player.class:=Alchemist;
                2: player.class:=Assassin;
                3: player.class:=Barbarian;
                4: player.class:=Bard;
                5: player.class:=Cleric;
                6: player.class:=Jester;
                7: player.class:=Magician;
                8: player.class:=Paladin;
                9: player.class:=Ranger;
               10: player.class:=Sage;
               11: player.class:=Warrior;
               end;
               finger:=1;
              end;
             end;

          29: player.mana:=get_numeric('Mana (spell points)',
                                       '',
                                       '',
                                       '',
                                       '',
                                       0,player.maxmana,player.mana);

          30: player.maxmana:=get_numeric('MaxMana (spell points)',
                                          '',
                                          '',
                                          '',
                                          '',
                                          0,99999,player.maxmana);

          31: player.stamina:=get_numeric('Stamina',
                                          '',
                                          '',
                                          '',
                                          '',
                                          0,32000,player.stamina);

          32: player.agility:=get_numeric('Agility',
                                          '',
                                          '',
                                          '',
                                          '',
                                          0,32000,player.agility);

          33: player.charisma:=get_numeric('Charisma',
                                          '',
                                          '',
                                          '',
                                          '',
                                          0,32000,player.charisma);

          34: player.dex:=get_numeric('Dexterity',
                                      '',
                                      '',
                                      '',
                                      '',
                                      0,32000,player.dex);

          35: player.wisdom:=get_numeric('Wisdom',
                                         '',
                                         '',
                                         '',
                                         '',
                                         0,32000,player.wisdom);

          36: player.trains:=get_numeric('Close Combat Trainings',
                                         '',
                                         '',
                                         '',
                                         '',
                                         0,32000,player.trains);

          37: player.immortal:=get_boolean('Never Delete This Player',
                                           '(prevents "deleted because of inactivity")',
                                           '',
                                           '',
                                           '');
          38: player.plague:=get_boolean('Have THE PLAGUE',
                                         '',
                                         '',
                                         '',
                                         '');
          39: player.smallpox:=get_boolean('Have SMALLPOX',
                                           '',
                                           '',
                                           '',
                                           '');
          40: player.measles:=get_boolean('Have MEASLES',
                                          '',
                                          '',
                                          '',
                                          '');
          41: player.leprosy:=get_boolean('Have LEPROSY',
                                          '',
                                          '',
                                          '',
                                          '');
          42: player.blind:=get_boolean('Be BLIND',
                                        '',
                                        '',
                                        '',
                                        '');

          end;
         end;
         finger:=1;
        end;
    '+':begin
         if finger=1 then begin
          load_player('S',player,edman);
          finger:=0;
         end;
         inc(edman);
         if edman<0 then edman:=0;
         if edman>=file_size then edman:=file_size-1;
         load_player('L',player,edman);
        end;
    '-':begin
         if finger=1 then begin
          load_player('S',player,edman);
          finger:=0;
         end;
         dec(edman);
         if edman<0 then edman:=0;
         if edman>=file_size then edman:=file_size-1;
         load_player('L',player,edman);
        end;
 chr(27):begin
          if finger=1 then begin
           load_player('S',player,edman);
           finger:=0;
          end;
         end;
 chr(13):begin
          repeat
           clearscreen;
           {page 2}
           sdisplay(0,3,0,'Editing : ');
           sdisplay(0,10,0,player.name1+' ('+player.name2+')');
           crlf;

           justval:=17;

           objekt.name:='';
           if player.rhand>0 then objekt_load(weapon,player.rhand);

           sdisplay(0,3,0,'#1  ');
           sdisplay(0,col,0,'Right Hand  : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[1]>0 then objekt_load(player.itemtype[1],player.item[1]);
           sdisplay(0,3,0,'#17 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.lhand>0 then objekt_load(weapon,player.lhand);

           sdisplay(0,3,0,'#2  ');
           sdisplay(0,col,0,'Left Hand   : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[2]>0 then objekt_load(player.itemtype[2],player.item[2]);
           sdisplay(0,3,0,'#18 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.head>0 then objekt_load(head,player.head);
           sdisplay(0,3,0,'#3  ');
           sdisplay(0,col,0,'On Head     : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[3]>0 then objekt_load(player.itemtype[3],player.item[3]);
           sdisplay(0,3,0,'#19 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.face>0 then objekt_load(face,player.face);
           sdisplay(0,3,0,'#4  ');
           sdisplay(0,col,0,'On Face     : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[4]>0 then objekt_load(player.itemtype[4],player.item[4]);
           sdisplay(0,3,0,'#20 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.neck>0 then objekt_load(neck,player.neck);
           sdisplay(0,3,0,'#5  ');
           sdisplay(0,col,0,'Around Neck : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[5]>0 then objekt_load(player.itemtype[5],player.item[5]);
           sdisplay(0,3,0,'#21 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.neck2>0 then objekt_load(neck,player.neck2);
           sdisplay(0,3,0,'#6  ');
           sdisplay(0,col,0,'Around Neck : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[6]>0 then objekt_load(player.itemtype[6],player.item[6]);
           sdisplay(0,3,0,'#22 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.body>0 then objekt_load(body,player.body);
           sdisplay(0,3,0,'#7  ');
           sdisplay(0,col,0,'On Body     : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[7]>0 then objekt_load(player.itemtype[7],player.item[7]);
           sdisplay(0,3,0,'#23 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.arms>0 then objekt_load(arms,player.arms);
           sdisplay(0,3,0,'#8  ');
           sdisplay(0,col,0,'On Arms     : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[8]>0 then objekt_load(player.itemtype[8],player.item[8]);
           sdisplay(0,3,0,'#24 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.lfinger>0 then objekt_load(fingers,player.lfinger);
           sdisplay(0,3,0,'#9  ');
           sdisplay(0,col,0,'L. Finger   : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[9]>0 then objekt_load(player.itemtype[9],player.item[9]);
           sdisplay(0,3,0,'#25 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.rfinger>0 then objekt_load(fingers,player.rfinger);
           sdisplay(0,3,0,'#10 ');
           sdisplay(0,col,0,'R. Finger   : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[10]>0 then objekt_load(player.itemtype[10],player.item[10]);
           sdisplay(0,3,0,'#26 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.waist>0 then objekt_load(waist,player.waist);
           sdisplay(0,3,0,'#11 ');
           sdisplay(0,col,0,'Waist       : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[11]>0 then objekt_load(player.itemtype[11],player.item[11]);
           sdisplay(0,3,0,'#27 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.legs>0 then objekt_load(legs,player.legs);
           sdisplay(0,3,0,'#12 ');
           sdisplay(0,col,0,'On Legs     : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[12]>0 then objekt_load(player.itemtype[12],player.item[12]);
           sdisplay(0,3,0,'#28 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.feet>0 then objekt_load(feet,player.feet);
           sdisplay(0,3,0,'#13 ');
           sdisplay(0,col,0,'On Feet     : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[13]>0 then objekt_load(player.itemtype[13],player.item[13]);
           sdisplay(0,3,0,'#29 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.abody>0 then objekt_load(abody,player.abody);
           sdisplay(0,3,0,'#14 ');
           sdisplay(0,col,0,'Around Body : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[14]>0 then objekt_load(player.itemtype[14],player.item[14]);
           sdisplay(0,3,0,'#30 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.shield>0 then objekt_load(shield,player.shield);
           sdisplay(0,3,0,'#15 ');
           sdisplay(0,col,0,'Shield      : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           objekt.name:='';
           if player.item[15]>0 then objekt_load(player.itemtype[15],player.item[15]);
           sdisplay(0,3,0,'#31 ');
           sdisplay(0,col,0,'Inventory : ');
           display(0,vcol,0,objekt.name);

           objekt.name:='';
           if player.hands>0 then objekt_load(hands,player.hands);
           sdisplay(0,3,0,'#16 ');
           sdisplay(0,col,0,'On Hands    : ');
           sdisplay(0,vcol,0,ljust(objekt.name,justval));

           sdisplay(0,3,0,'#32 ');
           sdisplay(0,col,0,'Gender : ');
           if player.sex=1 then display(0,vcol,0,'Male')
                           else display(0,vcol,0,'Female');

           sdisplay(0,8,0,'#98 ');
           sdisplay(0,col,0,'Armor Power : ');
           sdisplay(0,15,0,ljust(commastr(player.arm),justval));

           sdisplay(0,3,0,'#33 ');
           sdisplay(0,col,0,'Time Left Today : ');
           display(0,vcol,0,commastr(player.maxtime));

           sdisplay(0,8,0,'#99 ');
           sdisplay(0,col,0,'Weapon Power: ');
           sdisplay(0,15,0,ljust(commastr(player.weap),justval));

           crlf;
           sdisplay(0,2,0,'[');
           sdisplay(0,5,0,'Enter');
           sdisplay(0,2,0,'] for More, ');

           sdisplay(0,2,0,'[');
           sdisplay(0,5,0,'Esc');
           sdisplay(0,2,0,'] to Quit, ');

           menu2('(E)dit value :');

           repeat
            ch:=upcase(getchar);
           until (ch=chr(27)) or (ch='E') or (ch=chr(13));

          crlf;
          case ch of

           'E':begin
                display(0,3,0,'# to change');
                sdisplay(0,2,0,':');
                {prompt(a,5,false);}
                val(a,nr,i);
                if i=0 then begin
                 case nr of
                  1:begin

                     temp:=select_objekt(Weapon);

                     if (temp=-1) and (player.rhand>0) then begin
                      objekt_affect(2,player.rhand,weapon,player);
                      player.rhand:=0;
                     end;

                     if temp>0 then begin
                      if player.rhand>0 then begin
                       objekt_affect(2,player.rhand,weapon,player);
                      end;

                      player.rhand:=temp;
                      objekt_affect(1,temp,weapon,player);
                     end;

                    end;
                  2:begin
                     temp:=select_objekt(Weapon);

                     if (temp=-1) and (player.lhand>0) then begin
                      objekt_affect(2,player.lhand,weapon,player);
                      player.lhand:=0;
                     end;

                     if temp>0 then begin
                      if player.lhand>0 then begin
                       objekt_affect(2,player.lhand,weapon,player);
                      end;

                      player.lhand:=temp;
                      objekt_affect(1,temp,weapon,player);
                     end;

                    end;
                  3:begin
                     temp:=select_objekt(Head);
                     if (temp=-1) and (player.head>0) then begin
                      objekt_affect(2,player.head,head,player);
                      player.head:=0;
                     end;
                     if temp>0 then begin
                      if player.head>0 then begin
                       objekt_affect(2,player.head,head,player);
                      end;
                      objekt_affect(1,temp,head,player);
                      player.head:=temp;
                     end;
                    end;
                  4:begin
                     temp:=select_objekt(Face);
                     if (temp=-1) and (player.face>0) then begin
                      objekt_affect(2,player.face,face,player);
                      player.face:=0;
                     end;
                     if temp>0 then begin
                      if player.face>0 then begin
                       objekt_affect(2,player.face,face,player);
                      end;
                      objekt_affect(1,temp,face,player);
                      player.face:=temp;
                     end;
                    end;
                  5:begin
                     temp:=select_objekt(Neck);
                     if (temp=-1) and (player.neck>0) then begin
                      objekt_affect(2,player.neck,neck,player);
                      player.neck:=0;
                     end;
                     if temp>0 then begin
                      if player.neck>0 then begin
                       objekt_affect(2,player.neck,neck,player);
                      end;
                      objekt_affect(1,temp,neck,player);
                      player.neck:=temp;
                     end;
                    end;
                  6:begin
                     temp:=select_objekt(Neck);
                     if (temp=-1) and (player.neck2>0) then begin
                      objekt_affect(2,player.neck2,neck,player);
                      player.neck2:=0;
                     end;
                     if temp>0 then begin
                      if player.neck2>0 then begin
                       objekt_affect(2,player.neck2,neck,player);
                      end;
                      objekt_affect(1,temp,neck,player);
                      player.neck2:=temp;
                     end;
                    end;
                  7:begin
                     temp:=select_objekt(Body);
                     if (temp=-1) and (player.body>0) then begin
                      objekt_affect(2,player.body,body,player);
                      player.body:=0;
                     end;
                     if temp>0 then begin
                     if player.body>0 then begin
                       objekt_affect(2,player.body,body,player);
                      end;
                      objekt_affect(1,temp,body,player);
                      player.body:=temp;
                     end;
                    end;
                  8:begin
                     temp:=select_objekt(Arms);
                     if (temp=-1) and (player.arms>0) then begin
                      objekt_affect(2,player.arms,arms,player);
                      player.arms:=0;
                     end;
                     if temp>0 then begin
                      if player.arms>0 then begin
                       objekt_affect(2,player.arms,arms,player);
                      end;
                      objekt_affect(1,temp,arms,player);
                      player.arms:=temp;
                     end;
                    end;
                  9:begin
                     temp:=select_objekt(Fingers);
                     if (temp=-1) and (player.lfinger>0) then begin
                      objekt_affect(2,player.lfinger,fingers,player);
                      player.lfinger:=0;
                     end;
                     if temp>0 then begin
                      if player.lfinger>0 then begin
                       objekt_affect(2,player.lfinger,fingers,player);
                      end;
                      objekt_affect(1,temp,fingers,player);
                      player.lfinger:=temp;
                     end;
                    end;
                 10:begin
                     temp:=select_objekt(Fingers);
                     if (temp=-1) and (player.rfinger>0) then begin
                      objekt_affect(2,player.rfinger,fingers,player);
                      player.rfinger:=0;
                     end;
                     if temp>0 then begin
                      if player.rfinger>0 then begin
                       objekt_affect(2,player.rfinger,fingers,player);
                      end;
                      objekt_affect(1,temp,fingers,player);
                      player.rfinger:=temp;
                     end;
                    end;
                 11:begin
                     temp:=select_objekt(Waist);
                     if (temp=-1) and (player.waist>0) then begin
                      objekt_affect(2,player.waist,waist,player);
                      player.waist:=0;
                     end;
                     if temp>0 then begin
                      if player.waist>0 then begin
                       objekt_affect(2,player.waist,waist,player);
                      end;
                      objekt_affect(1,temp,waist,player);
                      player.waist:=temp;
                     end;
                    end;
                 12:begin
                     temp:=select_objekt(Legs);
                     if (temp=-1) and (player.legs>0) then begin
                      objekt_affect(2,player.legs,legs,player);
                      player.legs:=0;
                     end;
                     if temp>0 then begin
                      if player.legs>0 then begin
                       objekt_affect(2,player.legs,legs,player);
                      end;
                      objekt_affect(1,temp,legs,player);
                      player.legs:=temp;
                     end;
                    end;
                 13:begin
                     temp:=select_objekt(Feet);
                     if (temp=-1) and (player.feet>0) then begin
                      objekt_affect(2,player.feet,feet,player);
                      player.feet:=0;
                     end;
                     if temp>0 then begin
                      if player.feet>0 then begin
                       objekt_affect(2,player.feet,feet,player);
                      end;
                      objekt_affect(1,temp,feet,player);
                      player.feet:=temp;
                     end;
                    end;
                 14:begin
                     temp:=select_objekt(Abody);
                     if (temp=-1) and (player.abody>0) then begin
                      objekt_affect(2,player.abody,abody,player);
                      player.abody:=0;
                     end;
                     if temp>0 then begin
                      if player.abody>0 then begin
                       objekt_affect(2,player.abody,abody,player);
                      end;
                      objekt_affect(1,temp,abody,player);
                      player.abody:=temp;
                     end;
                    end;
                 15:begin
                     temp:=select_objekt(Shield);
                     if (temp=-1) and (player.shield>0) then begin
                      objekt_affect(2,player.shield,shield,player);
                      player.shield:=0;
                     end;
                     if temp>0 then begin
                      if player.shield>0 then begin
                       objekt_affect(2,player.shield,shield,player);
                      end;
                      objekt_affect(1,temp,shield,player);
                      player.shield:=temp;
                     end;
                    end;
                 16:begin
                     temp:=select_objekt(Hands);
                     if (temp=-1) and (player.hands>0) then begin
                      objekt_affect(2,player.hands,hands,player);
                      player.hands:=0;
                     end;
                     if temp>0 then begin
                      if player.hands>0 then begin
                       objekt_affect(2,player.hands,hands,player);
                      end;
                      objekt_affect(1,temp,hands,player);
                      player.hands:=temp;
                     end;
                    end;
            17..31:begin
                    inv:=nr-16;

                    otyp:=Weapon;
                    otyp:=get_type(otyp);

                    temp:=select_objekt(otyp);

                    if (temp=-1) and (player.item[inv]>0) then begin
                     player.item[inv]:=0;
                    end;
                    if temp>0 then begin
                     player.item[inv]:=temp;
                     player.itemtype[inv]:=objekt.ttype;
                    end;
                   end;
                32:begin
                    sdisplay(0,2,0,'Choose (M)ale or (F)emale :');
                    repeat
                     ch:=upcase(getchar);
                    until (ch='M') or (ch='F');
                    case ch of
                     'M': player.sex:=1;
                     'F': player.sex:=2;
                    end;
                    finger:=1;
                   end;
                33:begin
                    player.maxtime:=get_numeric('Time Left Today (minutes)',
                                    '',
                                    '',
                                    '',
                                    '',
                                    0,9999,player.maxtime);
                     finger:=1;
                   end;
                98:begin
                    {not mess with these values if not absolutely necessary}
                    crlf;
                    display(0,5,0,'When not wearing any armor or weapon, this should always');
                    display(0,5,0,'read 0. Do not change this if not absolutely necessary!');
                    display(0,5,0,'Change ONLY if some kind of screwup has occured ; when for some');
                    display(0,5,0,'reason you might have negative numbers or something.');
                    player.arm:=get_numeric('Armor value',
                                            '',
                                            '',
                                            '',
                                            '',
                                            0,9999,player.arm);
                     finger:=1;

                   end;
                99:begin
                    {not mess with these values if not absolutely necessary}
                    crlf;
                    display(0,5,0,'When not wearing any armor or weapon, this should always');
                    display(0,5,0,'read 0. Do not change this if not absolutely necessary!');
                    display(0,5,0,'Change ONLY if some kind of screwup has occured ; when for some');
                    display(0,5,0,'reason you might have negative numbers or something.');
                    player.weap:=get_numeric('Weapon value',
                                             '',
                                             '',
                                             '',
                                             '',
                                             0,9999,player.weap);
                     finger:=1;

                   end;
                 end;
                end;
               end;
           '+':begin
                if finger=1 then begin
                 load_player('S',player,edman);
                 finger:=0;
                 inc(edman);
                 if edman<0 then edman:=0;
                 if edman>=file_size then edman:=file_size-1;
                 load_player('L',player,edman);
                end;
               end;
           '-':begin
                if finger=1 then begin
                 load_player('S',player,edman);
                 finger:=0;
                 dec(edman);
                 if edman<0 then edman:=0;
                 if edman>=file_size then edman:=file_size-1;
                 load_player('L',player,edman);
                end;
               end;
       chr(27):begin
                if finger=1 then begin
                 load_player('S',player,edman);
                 finger:=0;
                end;
               end;
          end;
         until (ch=chr(13)) or (ch=chr(27));

         if ch=chr(13) then begin
          repeat
           clearscreen;
           {page 3}
           sdisplay(0,3,0,'Editing : ');
           sdisplay(0,10,0,player.name1+' ('+player.name2+')');
           crlf;

           for i:=1 to maxspells do begin
            if i<10 then sdisplay(0,3,0,'#'+commastr(i)+'  ')
                    else sdisplay(0,3,0,'#'+commastr(i)+' ');
            sdisplay(0,col,0,'Spell ');
            sdisplay(0,9,0,ljust(spell_name(i,player.class),justval));
            if player.class in [Cleric,Magician,Sage] then begin
             if player.spell[i,1]=true then begin
              display(0,14,0,' Learned');
             end
             else begin
              display(0,12,0,' Not Learned');
             end;
            end
            else begin
             crlf;
            end;
           end;

           crlf;
           sdisplay(0,2,0,'[');
           sdisplay(0,5,0,'Enter');
           sdisplay(0,2,0,'] for More, ');

           sdisplay(0,2,0,'[');
           sdisplay(0,5,0,'Esc');
           sdisplay(0,2,0,'] to Quit, ');

           menu2('(E)dit value :');

           repeat
            ch:=upcase(getchar);
           until (ch=chr(27)) or (ch='E') or (ch=chr(13));

           case ch of
            'E':begin
                 crlf;
                 display(0,3,0,'# to change');
                 sdisplay(0,2,0,':');
                 {prompt(a,5,false);}
                 val(a,nr,i);
                 if i=0 then begin
                  if (nr>0) and (nr<=maxspells) then begin
                   if player.class in [Cleric,Magician,Sage] then begin
                    if player.spell[nr,1]=false then begin
                     player.spell[nr,1]:=true;
                    end
                    else begin
                     player.spell[nr,1]:=false;
                    end;
                   end;
                  end;
                 end;
                 finger:=1;
                end;
            chr(27):begin
                     if finger=1 then begin
                      load_player('S',player,edman);
                      finger:=0;
                     end;
                    end;
           end;
          until (ch=chr(13)) or (ch=chr(27));
         end;
        end;
   end;
  until ch=chr(27);

end;
end.
