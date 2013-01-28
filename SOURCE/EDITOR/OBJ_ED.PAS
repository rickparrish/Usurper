{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}
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

Unit Obj_Ed;

Interface

Procedure Object_Editor;

Implementation
Uses init, jakobe, get_num,
     obj_aff2;

var
   check, notabene, suck, inv,  ok, changes : boolean;

   mad,
   justval,
   i,
   j,
   mcol,
   col,
   start : integer;

   tmprand,
   rand,
   cc,x : longint;


   s,
   objfile : s70;

   newtype,
   memtype : objtype;

   tmpobjekt : objektrec;
   ofil : file of objektrec;

Procedure File_Operations;
var
    ch3 : char;
    tempfile : file of objektrec;
    nr1, nr2, sz : longint;

begin

 ch3:='?';
 repeat
  if ch3='?' then begin
   clearscreen;
   crlf;
   crlf;
   sdisplay(0,10,0,'Object ');
   display(0,15,0,'File Operations');
   sdisplay(0,2,0,'(currently working with file : ');
   sdisplay(0,5,0,objfile);
   display(0,2,0,')');
   crlf;

   menu('(I)mport objects');
   menu('(E)xport objects');
   menu('(C)hange workfile');

   sdisplay(0,2,0,'[');
   sdisplay(0,5,0,'Esc');
   display(0,2,0,']');
   sdisplay(0,2,0,':');
  end;

  repeat
   ch3:=upcase(getchar);
  until ch3 in ['I','E','C',chr(27)];

  case ch3 of
   chr(27):begin
        break;
       end;
   'C':begin
        crlf;
        display(0,15,0,'Change Workfile.');
        display(0,2,0,'Enter filename');
        sdisplay(0,2,0,':');
        prompt(s,70,false);
        s:=upcasestr(s);

        if not exist(s) then begin
         crlf;
         display(0,15,0,'ERROR!');
         display(0,2,0,'File does not exist.');
         crlf;
         pause;
        end
        else if s='' then begin
         crlf;
         display(0,15,0,'Aborted.');
         crlf;
         pause;
        end
        else begin
         assign(ofil,s);
         reset(ofil);
         close(ofil);

         rand:=1;
         reset(ofil);
         seek(ofil,rand-1);
         read(ofil,objekt);

         crlf;
         display(0,2,0,'Done.');
         pause;
        end;
       end;
   'E':begin
        crlf;
        display(0,15,0,'Export objects from current file.');
        display(0,2,0,'Enter filename');
        sdisplay(0,2,0,':');
        prompt(s,70,false);
        s:=upcasestr(s);

        if exist(s) then begin
         crlf;
         display(0,15,0,'ERROR!');
         display(0,2,0,'File already exists.');
         crlf;
         pause;
        end
        else begin
         assign(tempfile,s);

         reset(ofil);
         sz:=filesize(ofil);
         close(ofil);


         display(0,2,0,'Enter range to export');
         sdisplay(0,2,0,'From # (1-'+commastr(sz)+') :');
         prompt(s,10,false);

         val(s,nr1,j);
         if (j<>0) or (nr1<1) or (nr1>sz) then begin
          nr1:=0;
         end;

         sdisplay(0,2,0,'To   # ('+commastr(nr1)+'-'+commastr(sz)+') :');
         prompt(s,10,false);

         val(s,nr2,j);
         if (j<>0) or (nr2<1) or (nr2>sz) then begin
          nr2:=0;
         end;

         if (nr1>0) and (nr1<=nr2) then begin
          rewrite(tempfile);
          reset(ofil);
          for i:=nr1 to nr2 do begin
           seek(ofil,i-1);
           read(ofil,tmpobjekt);
           write(tempfile,tmpobjekt);
           display(0,2,0,'Exporting .. '+tmpobjekt.name);
          end;
          close(ofil);
          close(tempfile);

          crlf;
          display(0,2,0,'Done!');
          crlf;
          pause;

         end
         else begin
          crlf;
          display(0,2,0,'Aborted.');
         end;

        end;

       end;
   'I':begin
        crlf;
        display(0,15,0,'Import objects from other file.');
        display(0,2,0,'Enter filename');
        sdisplay(0,2,0,':');
        prompt(s,70,false);
        s:=upcasestr(s);

        if exist(s) then begin
         assign(tempfile,s);
         reset(tempfile);

         {$I-}
         x:=filesize(tempfile);
         read(tempfile,tmpobjekt);
         {$I+}

         if IOResult=0 then begin
          crlf;
          display(0,15,0,'Ok.');
          sdisplay(0,2,0,'File ');
          sdisplay(0,5,0,s);
          sdisplay(0,2,0,' contains ');
          sdisplay(0,15,0,commastr(x));
          display(0,2,0,' objects.');

          if confirm('Import them to '+objfile+' ','N')=true then begin
           reset(ofil);
           seek(ofil,filesize(ofil));

           reset(tempfile);
           for i:=1 to x do begin
            read(tempfile,tmpobjekt);
            write(ofil,tmpobjekt);
            display(0,2,0,'Importing .. '+tmpobjekt.name);
           end;

           crlf;
           display(0,2,0,'Done!');
           crlf;
           pause;
          end;

          reset(tempfile);
          close(tempfile);
          pause;
         end
         else begin
          crlf;
          display(0,15,0,'ERROR!');
          display(0,2,0,'Bad File Format.');
          crlf;
          pause;
         end;
        end
        else begin
         crlf;
         display(0,15,0,'ERROR!');
         display(0,2,0,'File does not exist.');
         crlf;
         pause;
        end;

       end;
  end;

  ch3:='?';
 until ch3='R';

end;

Procedure Dependencies2;
begin

 {* terst„ller RAND objektet p† alla som det tagits ifr†n *}
 {* NPC & USER FILERNA *}

 suck:=false;

 for mad:=1 to 2 do begin
  case mad of
   1:begin
      assign(playerfile,'USERS.DAT');
      s:='USERS.DAT';
     end;
   2:begin
      assign(playerfile,'NPCS.DAT');
      s:='NPCS.DAT';
     end;
  end;

  if exist(s) then begin
  reset(playerfile);
  for i:=1 to filesize(playerfile) do begin
   read(playerfile,player);

   suck:=false;

   if player.lhand=rand then begin
    objekt_affect(1,rand,weapon,player);
    suck:=true;
   end;

   if player.rhand=rand then begin
    objekt_affect(1,rand,weapon,player);
    suck:=true;
   end;

   if player.head=rand then begin
    objekt_affect(1,rand,head,player);
    suck:=true;
   end;

   if player.body=rand then begin
    objekt_affect(1,rand,body,player);
    suck:=true;
   end;

   if player.arms=rand then begin
    objekt_affect(1,rand,arms,player);
    suck:=true;
   end;

   if player.lfinger=rand then begin
    objekt_affect(1,rand,fingers,player);
    suck:=true;
   end;

   if player.rfinger=rand then begin
    objekt_affect(1,rand,fingers,player);
    suck:=true;
   end;

   if player.legs=rand then begin
    objekt_affect(1,rand,legs,player);
    suck:=true;
   end;

   if player.feet=rand then begin
    objekt_affect(1,rand,feet,player);
    suck:=true;
   end;

   if player.waist=rand then begin
    objekt_affect(1,rand,waist,player);
    suck:=true;
   end;

   if player.neck=rand then begin
    objekt_affect(1,rand,neck,player);
    suck:=true;
   end;

   if player.neck2=rand then begin
    objekt_affect(1,rand,neck,player);
    suck:=true;
   end;

   if player.face=rand then begin
    objekt_affect(1,rand,face,player);
    suck:=true;
   end;

   if player.shield=rand then begin
    objekt_affect(1,rand,shield,player);
    suck:=true;
   end;

   if player.hands=rand then begin
    objekt_affect(1,rand,hands,player);
    suck:=true;
   end;

   if player.abody=rand then begin
    objekt_affect(1,rand,abody,player);
    suck:=true;
   end;

   if suck=true then begin
    reset(playerfile);
    seek(playerfile,i-1);
    write(playerfile,player);
   end;

  end;
  close(playerfile);
  end;
 end;

end;

Procedure Dependencies1(checktype:objtype);
var
   dobjekt : objektrec;
   weap : boolean;
   arm  : boolean;
   mad : integer;
   suck : boolean;
   otempfil : file of objektrec;

begin

 {* Kollar MONSTER filen, NPC filen, USER filen *}

 crlf;

 display(0,15,0,'Checking Dependencies....');

 case checktype of
  Head    : assign(otempfil,objf1);
  Body    : assign(otempfil,objf2);
  Arms    : assign(otempfil,objf3);
  Hands   : assign(otempfil,objf4);
  Fingers : assign(otempfil,objf5);
  Legs    : assign(otempfil,objf6);
  Feet    : assign(otempfil,objf7);
  Waist   : assign(otempfil,objf8);
  Neck    : assign(otempfil,objf9);
  Face    : assign(otempfil,objf10);
  Shield  : assign(otempfil,objf11);
  Food    : assign(otempfil,objf12);
  Drink   : assign(otempfil,objf13);
  Weapon  : assign(otempfil,objf14);
  Abody   : assign(otempfil,objf15);
 end;

 reset(otempfil);
 seek(otempfil,rand-1);
 read(otempfil,dobjekt);

 {*MONSTER FILEN*}

 if (dobjekt.ttype=Weapon) or (dobjekt.ttype=Body) then begin
  weap:=false;
  arm:=false;
  if (dobjekt.ttype=Weapon) and (objekt.ttype<>Weapon) then weap:=true;
  if (dobjekt.ttype=Body) and (objekt.ttype<>Body) then arm:=true;

  if (weap=true) or (arm=true) then begin
   display(0,15,0,'Checking Monsters...');
   reset(monsterfile);
   for i:=1 to filesize(monsterfile) do begin
    read(monsterfile,monster);

    if (monster.weapnr=rand) and (weap=true) then begin
     display(0,15,0,'Removing '+monster.name+' weapon.');
     monster.weapnr:=0;

     reset(monsterfile);
     seek(monsterfile,i-1);
     write(monsterfile,monster);

    end;

    if (monster.armnr=rand) and (arm=true) then begin
     display(0,15,0,'Removing '+monster.name+' armor.');
     monster.armnr:=0;

     reset(monsterfile);
     seek(monsterfile,i-1);
     write(monsterfile,monster);

    end;
   end;
   close(monsterfile);
  end;
 end;

 {* NPC & USER FILERNA *}
 for mad:=1 to 2 do begin
  case mad of
   1:begin
      assign(playerfile,'USERS.DAT');
      s:='USERS.DAT';
     end;
   2:begin
      assign(playerfile,'NPCS.DAT');
      s:='NPCS.DAT';
     end;
  end;

  if exist(s) then begin
   reset(playerfile);
   for i:=1 to filesize(playerfile) do begin
    read(playerfile,player);
    suck:=false;

    if player.lhand=rand then begin
     objekt_affect(2,rand,weapon,player);
     suck:=true;
    end;

    if player.rhand=rand then begin
     objekt_affect(2,rand,weapon,player);
     suck:=true;
    end;

    if player.head=rand then begin
     objekt_affect(2,rand,head,player);
     suck:=true;
    end;

    if player.body=rand then begin
     objekt_affect(2,rand,body,player);
     suck:=true;
    end;

    if player.arms=rand then begin
     objekt_affect(2,rand,arms,player);
     suck:=true;
    end;

    if player.lfinger=rand then begin
     objekt_affect(2,rand,fingers,player);
     suck:=true;
    end;

    if player.rfinger=rand then begin
     objekt_affect(2,rand,fingers,player);
     suck:=true;
    end;

    if player.legs=rand then begin
     objekt_affect(2,rand,legs,player);
     suck:=true;
    end;

    if player.feet=rand then begin
     objekt_affect(2,rand,feet,player);
     suck:=true;
    end;

    if player.waist=rand then begin
     objekt_affect(2,rand,waist,player);
     suck:=true;
    end;

    if player.neck=rand then begin
     objekt_affect(2,rand,neck,player);
     suck:=true;
    end;

    if player.neck2=rand then begin
     objekt_affect(2,rand,neck,player);
     suck:=true;
    end;

    if player.face=rand then begin
     objekt_affect(2,rand,face,player);
     suck:=true;
    end;

    if player.shield=rand then begin
     objekt_affect(2,rand,shield,player);
     suck:=true;
    end;

    if player.hands=rand then begin
     objekt_affect(2,rand,hands,player);
     suck:=true;
    end;

    if player.abody=rand then begin
     objekt_affect(2,rand,abody,player);
     suck:=true;
    end;

    if suck=true then begin
     reset(playerfile);
     seek(playerfile,i-1);
     write(playerfile,player);
    end;

   end;
   close(playerfile);
  end;
 end;

 reset(otempfil);
 close(otempfil);

end;

Procedure Get_Description ( mode : integer );

var
   line : integer;

begin

 crlf;

 case mode of
  1:begin
     repeat
      display(0,9,0,'Enter Description  (max 5 lines) ');
      display(0,15,0,'This is the text that the player will see every time he');
      display(0,15,0,'looks at the object.');
      display(0,15,0,'(Note that Objects also can have Hidden Descriptions)');
      crlf;

      display(0,15,0,'Current text :');
      crlf;
      for i:=1 to 5 do begin
       sdisplay(0,2,0,' ['+commastr(i)+']');
       display(0,7,0,' '+objekt.desc1[i]);
      end;

      crlf;
      display(0,2,0,'Line [#] to Edit, [W] for whole text or [Esc] to continue');
      sdisplay(0,2,0,':');

      repeat
       ch:=upcase(getchar);
      until ch in ['1','2','3','4','5','W',chr(27)];

      if ch in ['1','2','3','4','5'] then begin
       case ch of
        '1': line:=1;
        '2': line:=2;
        '3': line:=3;
        '4': line:=4;
        '5': line:=5;
       end;
       crlf;
       if objekt.desc1[line]<>'' then begin
        sdisplay(0,5,0,'Old Line ');
        display(0,14,0,commastr(line));
        display(0,15,0,':'+objekt.desc1[line]);
       end;
       sdisplay(0,5,0,'New Line ');
       display(0,14,0,commastr(line));
       sdisplay(0,2,0,':');
       {prompt(objekt.desc1[line],70,false);  {jakob}
       changes:=true;
      end;

      if ch='W' then begin
       crlf;
       display(0,15,0,'Enter new Description');
       line:=1;
       repeat
        sdisplay(0,2,0,'['+commastr(line)+']:');
        {prompt(objekt.desc1[line],70,false);   {jakob}
        inc(line);
       until line>5;
       changes:=true;
      end;

     until ch=chr(27);

    end;
  2:begin
     repeat
      display(0,9,0,'Enter Hidden Description  (max 5 lines) ');
      display(0,15,0,'This is the text that the player will see when he');
      display(0,15,0,'identifies the Object in the Magic Shop.');
      crlf;

      display(0,15,0,'Current text :');
      crlf;
      for i:=1 to 5 do begin
       sdisplay(0,2,0,' ['+commastr(i)+']');
       display(0,7,0,' '+objekt.desc2[i]);
      end;

      crlf;
      display(0,2,0,'Line [#] to Edit, [W] for whole text or [Esc] to continue');
      sdisplay(0,2,0,':');

      repeat
       ch:=upcase(getchar);
      until ch in ['1','2','3','4','5','W',chr(27)];

      if ch in ['1','2','3','4','5'] then begin
       case ch of
        '1': line:=1;
        '2': line:=2;
        '3': line:=3;
        '4': line:=4;
        '5': line:=5;
       end;
       crlf;
       if objekt.desc2[line]<>'' then begin
        sdisplay(0,5,0,'Old Line ');
        display(0,14,0,commastr(line));
        display(0,15,0,':'+objekt.desc2[line]);
       end;
       sdisplay(0,5,0,'New Line ');
       display(0,14,0,commastr(line));
       sdisplay(0,2,0,':');
       {prompt(objekt.desc2[line],70,false); {jakob}
       changes:=true;
      end;

      if ch='W' then begin
       crlf;
       display(0,15,0,'Enter new Description');
       line:=1;
       repeat
        sdisplay(0,2,0,'['+commastr(line)+']:');
        {prompt(objekt.desc2[line],70,false);}
        inc(line);
       until line>5;
       changes:=true;
      end;

     until ch=chr(27);

    end;
 end;

 ch:=' ';

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

Function Get_Cure ( oldcure : cures ) : Cures;
var
   tmpcure : cures;
begin

  display(0,3,0,'Determine if the Object can heal any Diseases :');

  menu('[1] None');
  menu('[2] All known Diseases (very powerful)');
  menu('[3] Blindness');
  menu('[4] Plague');
  menu('[5] Smallpox');
  menu('[6] Measles');
  menu('[7] Leprosy');
  menu('[0] Abort');
  sdisplay(0,2,0,':');

  repeat
   ch:=upcase(getchar);
  until ch in ['1','2','3','4','5','6','7','0'];

  tmpcure:=oldcure;

  case ch of
   '1': tmpcure:=Nothing;
   '2': tmpcure:=All;
   '3': tmpcure:=Blindness;
   '4': tmpcure:=Plague;
   '5': tmpcure:=Smallpox;
   '6': tmpcure:=Measles;
   '7': tmpcure:=Leprosy;
  end;

  get_cure:=tmpcure;
  ch:=' ';

end;

Function Get_Type ( oldtype : objtype ) : ObjType;
var
   tmptype : objtype;

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

Function Get_String (s1,s2,s3,s4,s5,oldval : s70) : s70;
 var tcol : integer;
     st : s70;
begin

 tcol:=15;
 get_string:=oldval;

 display(0,15,0,'Old Text');
 display(0,2,0,':'+oldval);
 crlf;

 if s1<>'' then display(0,tcol,0,s1);
 if s2<>'' then display(0,tcol,0,s2);
 if s3<>'' then display(0,tcol,0,s3);
 if s4<>'' then display(0,tcol,0,s4);
 if s5<>'' then display(0,tcol,0,s5);

 sdisplay(0,2,0,':');

 prompt(st,30,false);
 if st<>'' then begin
  get_string:=st;
  finger:=1;
 end;

end;

Procedure Object_Editor;

var
   show : integer;
   memstring : s70;
   memboolean : boolean;
   memnumeric : longint;
   memtype : objtype;
   memcure : cures;
   slask : s70;

begin

 objfile:=objf1;

 clearscreen;

 changes:=false;
 notabene:=true;

 if exist(objf1)=false then begin
  display(0,14,0,'ATTENTION!');
  d(objf1+' file not found.');
  d('Reset the datafiles if you haven'+chr(39)+'t done so yet.');
  crlf;
  pause;
  exit;
 end;

 rand:=1;
 assign(ofil,objf1);
 reset(ofil);
 seek(ofil,rand-1);
 read(ofil,objekt);

 repeat
  clearscreen;

  display(0,9,0,'[* Usurper Object Editor *]');

  crlf;
  menu2('[+] Next Object  ');
  menu2('[-] Previous Object  ');

  menu2('[J] Jump to #  ');
  menu('[L] List of Objects');

  col:=13;

  menu2('[*] Working with Object Type : ');
  case objekt.ttype of
   Head    : s:='Head       ';
   Body    : s:='Body       ';
   Arms    : s:='Arms       ';
   Hands   : s:='Hands      ';
   Fingers : s:='Fingers    ';
   Legs    : s:='Legs       ';
   Feet    : s:='Feet       ';
   Waist   : s:='Waist      ';
   Neck    : s:='Neck       ';
   Face    : s:='Face       ';
   Shield  : s:='Shield     ';
   Food    : s:='Food       ';
   Drink   : s:='Drink      ';
   Weapon  : s:='Weapon     ';
   Abody   : s:='Around Body';
  end;
  sdisplay(0,col,0,s+'  ');

  menu2('[F]ile op. (import,export)');

  crlf;

  sdisplay(0,12,0,'   [# ');
  sdisplay(0,14,0,commastr(rand));
  sdisplay(0,12,0,' of ');
  sdisplay(0,14,0,commastr(filesize(ofil)));
  display(0,12,0,' ]');

  justval:=22;
  mcol:=2;

  sdisplay(0,3,0,'#1 ');
  sdisplay(0,mcol,0,'Object Name    : ');
  sdisplay(0,15,0,ljust(objekt.name,justval));

  sdisplay(0,3,0,'#14 ');
  sdisplay(0,mcol,0,'Attack Value : ');
  if objekt.attack>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.attack));

  sdisplay(0,3,0,'#2 ');
  sdisplay(0,mcol,0,'Type of Object : ');
  case objekt.ttype of
   Head    : s:='Head';
   Body    : s:='Body';
   Arms    : s:='Arm';
   Hands   : s:='Hand';
   Fingers : s:='Finger';
   Legs    : s:='Leg';
   Feet    : s:='Feet';
   Waist   : s:='Waist';
   Neck    : s:='Neck';
   Face    : s:='Face';
   Shield  : s:='Shield';
   Food    : s:='Food';
   Drink   : s:='Drink';
   Weapon  : s:='Weapon';
   Abody   : s:='Around Body';
  end;
  sdisplay(0,13,0,ljust(s,justval));

  sdisplay(0,3,0,'#15 ');
  sdisplay(0,mcol,0,'Armor Value  : ');
  if objekt.armor>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.armor));

  sdisplay(0,3,0,'#3 ');
  sdisplay(0,mcol,0,'Value in Gold  : ');
  sdisplay(0,15,0,ljust(commastr(objekt.value),justval));

  sdisplay(0,3,0,'#16 ');
  sdisplay(0,mcol,0,'Mana         : ');
  if objekt.mana>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.mana));

  sdisplay(0,3,0,'#4 ');
  sdisplay(0,mcol,0,'Cure Disease   : ');
  s:='';
  case objekt.cure of
   Nothing   : s:='None';
   All       : s:='All Known Diseases';
   Blindness : s:='Blindness';
   Plague    : s:='Plague';
   Smallpox  : s:='Smallpox';
   Measles   : s:='Measles';
   Leprosy   : s:='Leprosy';
  end;
  if s<>'None' then sdisplay(0,14,0,ljust(s,justval))
               else sdisplay(0,15,0,ljust(s,justval));

  sdisplay(0,3,0,'#17 ');
  sdisplay(0,mcol,0,'Wisdom       : ');
  if objekt.wisdom>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.wisdom));

  sdisplay(0,3,0,'#5 ');
  sdisplay(0,mcol,0,'Cursed         : ');
  if objekt.cursed=true then sdisplay(0,15,0,ljust('Yes',justval))
                        else sdisplay(0,12,0,ljust('No',justval));

  sdisplay(0,3,0,'#18 ');
  sdisplay(0,mcol,0,'Dexterity    : ');
  if objekt.dex>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.dex));

  sdisplay(0,3,0,'#6 ');
  sdisplay(0,mcol,0,'Min Lev to be Found : ');
  sdisplay(0,15,0,ljust(commastr(objekt.minlev),justval-5));

  sdisplay(0,3,0,'#19 ');
  sdisplay(0,mcol,0,'Charisma     : ');
  if objekt.charisma>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.charisma));

  sdisplay(0,3,0,'#7 ');
  sdisplay(0,mcol,0,'Max Lev to be Found : ');
  sdisplay(0,15,0,ljust(commastr(objekt.maxlev),justval-5));

  sdisplay(0,3,0,'#20 ');
  sdisplay(0,mcol,0,'Agility      : ');
  if objekt.agility>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.agility));

  sdisplay(0,3,0,'#8 ');
  sdisplay(0,mcol,0,'Available in Shop   : ');
  if objekt.shop=true then sdisplay(0,15,0,ljust('Yes',justval-5))
                      else sdisplay(0,12,0,ljust('No',justval-5));

  sdisplay(0,3,0,'#21 ');
  sdisplay(0,mcol,0,'Stamina      : ');
  if objekt.stamina>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.stamina));

  sdisplay(0,3,0,'#9 ');
  sdisplay(0,mcol,0,'Found in Dungeons   : ');
  if objekt.dng=true then sdisplay(0,15,0,ljust('Yes',justval-5))
                     else sdisplay(0,12,0,ljust('No',justval-5));

  sdisplay(0,3,0,'#22 ');
  sdisplay(0,mcol,0,'Hitpoints    : ');
  if objekt.hps>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.hps));

  sdisplay(0,3,0,'#10 ');
  sdisplay(0,mcol,0,'Strength Needed    : ');
  sdisplay(0,15,0,ljust(commastr(objekt.str_need),justval-5));

  sdisplay(0,3,0,'#23 ');
  sdisplay(0,mcol,0,'Strength     : ');
  if objekt.strength>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.strength));

  sdisplay(0,3,0,'#11 ');
  sdisplay(0,mcol,0,'Good Object        : ');
  if objekt.good=true then sdisplay(0,9,0,ljust('Yes',justval-5))
                      else sdisplay(0,15,0,ljust('No',justval-5));

  sdisplay(0,3,0,'#24 ');
  sdisplay(0,mcol,0,'Evil Object  : ');
  if objekt.evil=true then display(0,9,0,ljust('Yes',justval-5))
                      else display(0,15,0,ljust('No',justval-5));

  sdisplay(0,3,0,'#12 ');
  sdisplay(0,mcol,0,'Hidden Description : ');
  sdisplay(0,15,0,ljust('                   ',justval-5));

  sdisplay(0,3,0,'#25 ');
  sdisplay(0,mcol,0,'Defence      : ');
  if objekt.defence>0 then sdisplay(0,15,0,'+');
  display(0,15,0,commastr(objekt.defence));

  sdisplay(0,3,0,'#13 ');
  sdisplay(0,mcol,0,'Description   : ');
  display(0,15,0,ljust('                   ',justval));

  for i:=1 to 5 do begin
   sdisplay(0,2,0,'   ['+commastr(i)+']');
   display(0,7,0,' '+objekt.desc1[i]);
  end;

  sdisplay(0,2,0,'[');
  sdisplay(0,5,0,'Esc');
  sdisplay(0,2,0,'] to Exit  ');

  menu2('[E]dit Value  ');
  menu2('[C]reate New Object  ');
  menu2('[S]earch  ');
  menu2('[O]wner Check');

  crlf;
  sdisplay(0,2,0,':');

  repeat
   ch:=upcase(getchar);
  until (ch=chr(27))
                     or (ch='E')
                     or (ch='F')
                     or (ch='C')
                     or (ch='J')
                     or (ch='L')
                     or (ch='S')
                     or (ch='O')
                     or (ch='*')
                     or (ch='+')
                     or (ch='-');


  if ch in ['J', 'S', '+', '-'] then begin
   if changes=true then begin
    if confirm('Save changes ','Y')=true then begin

     Dependencies1(objekt.ttype);

     reset(ofil);
     seek(ofil,rand-1);
     write(ofil,objekt);
     changes:=false;

     Dependencies2;

    end;
   end
   else begin
    changes:=false;
   end;
  end;

  case ch of
   'F':begin
        file_operations;
        reset(ofil);
       end;
   'C':begin
        crlf;
        if confirm('Would You like to Create a New Object ','N')=true then begin

         crlf;
         display(0,15,0,'A copy of the current Object will be added to the file.');
         display(0,15,0,'You may then Edit the New Object as you wish.');
         crlf;

         display(0,15,0,'Where the Objects will turn up if you make them available in the Shops :');
         display(0,15,0,' * Weapons                     - Weapon Store');
         display(0,15,0,' * Rings, Neck and Waist items - Magic Store');
         display(0,15,0,' * General Items               - Healing Center Store');
         display(0,15,0,' * All others                  - Armor Store');

         crlf;
         if confirm('Create New Object ','N')=true then begin
          reset(ofil);
          start:=filesize(ofil);
          reset(ofil);

          seek(ofil,start);

          objekt.name:='* New Object *';

          write(ofil,objekt);

          rand:=start+1;
          reset(ofil);
          seek(ofil,rand-1);
          read(ofil,objekt);

         end;
        end;
       end;
   'E':begin
        if notabene=true then begin
         crlf;
         display(0,15,0,'Note :');
         display(0,15,0,'Before you start editing away; It can be wise to');
         display(0,15,0,'make an [O]wner check first. You can then see if any');
         display(0,15,0,'monsters and players own this object. Players might');
         display(0,15,0,'get upset when you turn their stuff into something else.');
         display(0,15,0,'Monsters may own this object as their belongings are predefined.');
         crlf;
         if confirm('Turn OFF this Reminder Text ','N')=true then notabene:=false;
        end;

        crlf;
        display(0,3,0,'# to change');
        sdisplay(0,2,0,':');
        prompt(s,5,false);
        val(s,cc,i);
        if i=0 then begin
         case cc of
          1:begin
             memstring:=objekt.name;
             objekt.name:=get_string('Enter new name for Object',
                                     '',
                                     '',
                                     '',
                                     '',
                                     objekt.name);
             if objekt.name<>memstring then changes:=true;
            end;

          2:begin
             memtype:=objekt.ttype;
             objekt.ttype:=get_type(objekt.ttype);
             if objekt.ttype<>memtype then changes:=true;
            end;

          3:begin
             memnumeric:=objekt.value;
             objekt.value:=get_numeric('Object Value in Gold',
                                       '',
                                       '',
                                       '',
                                       '',
                                       0,
                                       2000000000,
                                       objekt.value);
             if objekt.value<>memnumeric then changes:=true;
            end;
          4:begin
             memcure:=objekt.cure;
             objekt.cure:=get_cure(objekt.cure);
             if objekt.cure<>memcure then changes:=true;
            end;
          5:begin
             memboolean:=objekt.cursed;
             objekt.cursed:=get_boolean('Shall the Object be Cursed?',
                                        'Cursed objects cannot be dropped or removed.',
                                        'Player with a cursed object can have it removed',
                                        'with help from Jadu The Fat.',
                                        '');
             if objekt.cursed<>memboolean then changes:=true;
            end;
          6:begin
             memnumeric:=objekt.minlev;
             objekt.minlev:=get_numeric('The Lowest Dungeon level a player must be on to be',
                                        'able to find this object.',
                                        '',
                                        '',
                                        '',
                                        1,
                                        99,
                                        objekt.minlev);
             if objekt.minlev<>memnumeric then changes:=true;
            end;
          7:begin
             memnumeric:=objekt.maxlev;
             objekt.maxlev:=get_numeric('The Highest Dungeon level a player can be on to be',
                                        'able to find this object.',
                                        '',
                                        '',
                                        '',
                                        1,
                                        99,
                                        objekt.maxlev);
             if objekt.maxlev<>memnumeric then changes:=true;
            end;
          8:begin
             memboolean:=objekt.shop;
             objekt.shop:=get_boolean('Shall the Object be available to players in the shops?',
                                      'When you create special objects like Monster Weapons,',
                                      'it is a good idea to toggle this option to NO.',
                                      'If you also toggle the "Find in Dungeons" option to NO,',
                                      'then you have a "Monster-only" weapon.');
             if objekt.shop<>memboolean then changes:=true;
            end;
          9:begin
             memboolean:=objekt.dng;
             objekt.dng:=get_boolean('Shall Players be able to find the Object in the Dungeons?',
                                      'When you create special objects like Monster Weapons,',
                                      'it is a good idea to toggle this option to NO.',
                                      'If you also toggle the "Available in Shop" option to NO,',
                                      'then you have a "Monster-only" weapon.');
             if objekt.dng<>memboolean then changes:=true;
            end;
         10:begin
             memnumeric:=objekt.str_need;
             objekt.str_need:=get_numeric('Strength Needed to Use Object. By setting this',
                                               'to a high value you can prevent low level characters',
                                               'from using the object.',
                                               '',
                                               '',
                                               0,
                                               32000,
                                               objekt.str_need);
             if objekt.str_need<>memnumeric then changes:=true;
            end;
         11:begin
             memboolean:=objekt.good;
             objekt.good:=get_boolean('If this value is set to YES then player must have a positive',
                                      'chivalry value and not be evil.',
                                      'If the player is evil then he can''t use the object.',
                                      '',
                                      '');
             if objekt.good<>memboolean then changes:=true;
             if (objekt.evil=true) and (objekt.good=true) then begin
              display(0,15,0,'Attention!');
              display(0,2,0,'You have this object set to be both GOOD and EVIL');
              display(0,2,0,'This is a forbidden combination,');
              crlf;
              objekt.good:=false;
              pause;
             end;
            end;
         12: get_description(2);
         13: get_description(1);

         14:begin
             memnumeric:=objekt.attack;
             objekt.attack:=get_numeric('Object Attack Value',
                                        'Increases/Decreases Player Attacks when used.',
                                        '',
                                        '',
                                        '',
                                        -32000,
                                        32000,
                                        objekt.attack);
             if objekt.attack<>memnumeric then changes:=true;
            end;
         15:begin
             memnumeric:=objekt.armor;
             objekt.armor:=get_numeric('Object Armor Value',
                                       'Increases/Decreases Players Armor when used.',
                                       '',
                                       '',
                                       '',
                                       -32000,
                                       32000,
                                       objekt.armor);
             if objekt.armor<>memnumeric then changes:=true;
            end;
         16:begin
             memnumeric:=objekt.mana;
             objekt.mana:=get_numeric('Object Mana Value',
                                      'Increases/Decreases Players Mana when used.',
                                      '',
                                      '',
                                      '',
                                      -32000,
                                      32000,
                                      objekt.mana);
             if objekt.mana<>memnumeric then changes:=true;
            end;
         17:begin
             memnumeric:=objekt.wisdom;
             objekt.wisdom:=get_numeric('Object Wisdom Value',
                                        'Increases/Decreases Players Wisdom when used.',
                                        '',
                                        '',
                                        '',
                                        -32000,
                                        32000,
                                        objekt.wisdom);
             if objekt.wisdom<>memnumeric then changes:=true;
            end;
         18:begin
             memnumeric:=objekt.dex;
             objekt.dex:=get_numeric('Object Dexterity Value',
                                     'Increases/Decreases Players Dexterity when used.',
                                     '',
                                     '',
                                     '',
                                     -32000,
                                     32000,
                                           objekt.dex);
             if objekt.dex<>memnumeric then changes:=true;
            end;
         19:begin
             memnumeric:=objekt.charisma;
             objekt.charisma:=get_numeric('Object Charisma Value',
                                          'Increases/Decreases Players Charisma when used.',
                                          '',
                                          '',
                                          '',
                                          -32000,
                                          32000,
                                          objekt.charisma);
             if objekt.charisma<>memnumeric then changes:=true;
            end;
         20:begin
             memnumeric:=objekt.agility;
             objekt.agility:=get_numeric('Object Agility Value',
                                         'Increases/Decreases Players Agility when used.',
                                         '',
                                         '',
                                         '',
                                         -32000,
                                         32000,
                                         objekt.agility);
             if objekt.agility<>memnumeric then changes:=true;
            end;
         21:begin
             memnumeric:=objekt.stamina;
             objekt.stamina:=get_numeric('Object Stamina Value',
                                         'Increases/Decreases Players Stamina when used.',
                                         '',
                                         '',
                                         '',
                                         -32000,
                                         32000,
                                         objekt.stamina);
             if objekt.stamina<>memnumeric then changes:=true;
            end;
         22:begin
             memnumeric:=objekt.hps;
             objekt.hps:=get_numeric('Object HitPoints Value',
                                     'Increases/Decreases Players Hitpoints when used.',
                                     '',
                                     '',
                                     '',
                                     -32000,
                                     32000,
                                     objekt.hps);
             if objekt.hps<>memnumeric then changes:=true;
            end;
         23:begin
             memnumeric:=objekt.strength;
             objekt.strength:=get_numeric('Object Strength Value',
                                          'Increases/Decreases Players Strength when used.',
                                          '',
                                          '',
                                          '',
                                          -32000,
                                          32000,
                                          objekt.strength);
             if objekt.strength<>memnumeric then changes:=true;
            end;
         24:begin
             memboolean:=objekt.evil;
             objekt.evil:=get_boolean('If this value is set to YES then player must be evil to be',
                                      'able to use hte object.',
                                      'If the player has a good character then he can''t use it.',
                                      '',
                                      '');
             if objekt.evil<>memboolean then changes:=true;
             if (objekt.evil=true) and (objekt.good=true) then begin
              display(0,15,0,'Attention!');
              display(0,2,0,'You have this object set to be both GOOD and EVIL');
              display(0,2,0,'This is a forbidden combination,');
              crlf;
              objekt.evil:=false;
              pause;
             end;

            end;
         25:begin
             memnumeric:=objekt.defence;
             objekt.defence:=get_numeric('Object Defence Value',
                                         'Increases/Decreases Players Defence when used.',
                                         '',
                                         '',
                                         '',
                                         -32000,
                                         32000,
                                         objekt.defence);
             if objekt.defence<>memnumeric then changes:=true;
            end;
         end;
        end;
       end;
   '*':begin
        memtype:=objekt.ttype;
        newtype:=Get_Type(objekt.ttype);

        if newtype<>memtype then begin
         case newtype of
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

         rand:=1;
         reset(ofil);
         seek(ofil,rand-1);
         read(ofil,objekt);

        end;

       end;
   'O':begin
        show:=0;
        crlf;
        sdisplay(0,15,0,'Listing Current Owners of Object : ');
        display(0,3,0,objekt.name);

        crlf;

        if exist('monster.dat') then begin
         reset(monsterfile);
         for i:=1 to filesize(monsterfile) do begin
          read(monsterfile,monster);
          if (monster.armnr=rand) or (monster.weapnr=rand) then begin
            display(0,9,0,'Monster : '+monster.name+' (#'+commastr(i)+')');
            inc(show);
            if show>13 then begin
             show:=0;
             pause;
            end;
          end;
         end;
         close(monsterfile);
        end;

        for mad:=1 to 2 do begin
         check:=true;
         case mad of
          1:begin
             if exist('USERS.DAT') then begin
              assign(playerfile,'USERS.DAT');
              reset(playerfile);
             end
             else begin
              check:=false;
             end;
            end;
          2:begin
             if exist('NPCS.DAT') then begin
              assign(playerfile,'NPCS.DAT');
              reset(playerfile);
             end
             else begin
              check:=false;
             end;
            end;
         end;

         if check=true then begin
          reset(playerfile);
          for i:=1 to filesize(playerfile) do begin
           read(playerfile,player);

           suck:=false;
           inv:=false;

           if (player.lhand=rand) or
              (player.rhand=rand) or
              (player.head=rand) or
              (player.body=rand) or
              (player.arms=rand) or
              (player.lfinger=rand) or
              (player.rfinger=rand) or
              (player.legs=rand) or
              (player.feet=rand) or
              (player.waist=rand) or
              (player.neck=rand) or
              (player.neck2=rand) or
              (player.face=rand) or
              (player.shield=rand) or
              (player.hands=rand) or
              (player.abody=rand) then begin

            suck:=true;
           end;

           for j:=1 to maxitem do begin
            if player.item[j]=rand then begin
             inv:=true;
            end;
           end;

           if (suck=true) or (inv=true) then begin
            sdisplay(0,3,0,'Player : '+player.name2+' (#'+commastr(i)+')');
            if suck=true then begin
             sdisplay(0,5,0,' *Wearing*');
            end;
            if inv=true then begin
             sdisplay(0,5,0,' *Inventory*');
            end;

            crlf;
            inc(show);
            if show>13 then begin
             show:=0;
             pause;
            end;
           end;

          end;
          close(playerfile);
         end;
        end;
        crlf;
        pause;

       end;
   'S':begin
        memnumeric:=rand;

        crlf;
        display(0,15,0,'Enter Search String');
        sdisplay(0,15,0,':');
        prompt(slask,30,false);
        slask:=upcasestr(slask);

        reset(ofil);
        for i:=1 to filesize(ofil) do begin
         read(ofil,tmpobjekt);
         s:=upcasestr(tmpobjekt.name);
         if length(s)>length(slask) then begin
          delete(s,length(slask)+1,99);
         end;
         if slask=s then begin
          sdisplay(0,3,0,'(#'+commastr(i)+') ');
          sdisplay(0,15,0,tmpobjekt.name+' ');
          if confirm('','N')=true then begin
           rand:=i;
           break;
          end
          else begin
           if confirm('Continue Search ','Y')=false then break;
          end;
         end;
        end;

        if rand<>memnumeric then begin
         reset(ofil);
         seek(ofil,rand-1);
         read(ofil,objekt);
        end
        else begin
         pause;
        end;

       end;
   'L':begin
        cc:=0;
        clearscreen;
        crlf;
        display(0,5,0,'Object List');
        crlf;

        sdisplay(0,15,0,'This listing includes ');
        case objekt.ttype of
         Head    : s:='Head';
         Body    : s:='Body';
         Arms    : s:='Arm';
         Hands   : s:='Hand';
         Fingers : s:='Finger';
         Legs    : s:='Leg';
         Feet    : s:='Feet';
         Waist   : s:='Waist';
         Neck    : s:='Neck';
         Face    : s:='Face';
         Shield  : s:='Shield';
         Food    : s:='Food';
         Drink   : s:='Drink';
         Weapon  : s:='Weapon';
         Abody   : s:='Around Body';
        end;
        sdisplay(0,13,0,'*'+s+' Objects*');
        crlf;
        crlf;

        start:=1;
        reset(ofil);
        seek(ofil,start-1);
        for i:=start to filesize(ofil) do begin
         read(ofil,tmpobjekt);

         sdisplay(0,3,0,'#'+commastr(i)+' ');
         sdisplay(0,15,0,tmpobjekt.name);
         s:='';
         case tmpobjekt.ttype of
          Head    : s:='Head';
          Body    : s:='Body';
          Arms    : s:='Arms';
          Hands   : s:='Hands';
          Fingers : s:='Fingers';
          Legs    : s:='Legs';
          Feet    : s:='Feet';
          Waist   : s:='Waist';
          Neck    : s:='Neck';
          Face    : s:='Face';
          Shield  : s:='Shield';
          Food    : s:='Food';
          Drink   : s:='Drink';
          Weapon  : s:='Weapon';
          Abody   : s:='Around Body';
         end;
         sdisplay(0,9,0,'  ['+s+']');
         crlf;
         cc:=cc+1;
         if cc>15 then begin
          if confirm('Continue ','Y')=false then break;
          cc:=0;
         end;
        end;
        crlf;
        pause;
       end;
   '+':begin
        ok:=false;
        reset(ofil);
        tmprand:=rand;
        repeat
         if tmprand<filesize(ofil) then begin
          tmprand:=tmprand+1;
          seek(ofil,tmprand-1);
          read(ofil,tmpobjekt);
          ok:=true;
          break;
         end
         else begin
          break;
         end;
        until ok=true;

        if ok=true then begin
         rand:=tmprand;
         objekt:=tmpobjekt;
        end;

       end;
   '-':begin
        ok:=false;
        tmprand:=rand;
        repeat

         if filepos(ofil)=0 then begin
          reset(ofil);
         end;

         if tmprand>1 then begin
          tmprand:=tmprand-1;
          seek(ofil,tmprand-1);
          read(ofil,tmpobjekt);
          ok:=true;
          break;
         end
         else begin
          break;
         end;
        until ok=true;

        if ok=true then begin
         rand:=tmprand;
         objekt:=tmpobjekt;
        end;

       end;
   'J':begin
        crlf;
        reset(ofil);
        x:=filesize(ofil);

        sdisplay(0,2,0,'There are ');
        sdisplay(0,15,0,commastr(x));
        display(0,2,0,' Objects in the file.');

        crlf;
        sdisplay(0,2,0,'Edit #');
        sdisplay(0,7,0,'  [1 - '+commastr(x)+']');crlf;
        sdisplay(0,2,0,':');
        {prompt(a,4,false);}
        val(a,tmprand,i);
        if (i=0) and (tmprand>0) and (tmprand<x+1) then begin
         seek(ofil,tmprand-1);
         read(ofil,objekt);
         changes:=false;
         rand:=tmprand;
        end;
       end;
  end;

 until ch=chr(27);

 ch:=' ';

 if changes=true then begin
  crlf;
  if confirm('Save changes ','Y')=true then begin

   Dependencies1(objekt.ttype);

   reset(ofil);
   seek(ofil,rand-1);
   write(ofil,objekt);
   close(ofil);

   Dependencies2;

  end;
 end;

end;
end.
