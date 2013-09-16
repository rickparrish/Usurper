{$I DEFINES.INC}

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


Unit VarGods; {Usurper - various God routines}

Interface

Uses Init, InitGods;

{God stuff}
Function God_Search(const user_name:string) : boolean;
Function God_Title(const level:word):string;
Function God_Believers(const godname:string;listem:boolean):word;
Function Select_A_God(var tgod : godrec;const excludename : s70;const numbered:boolean) : boolean;
Function God_Active(const tgod : godrec) : boolean;
Function Verify_Gods_Existance(const name:string) : boolean;
Function Get_Random_God(var name:s30) : boolean;
Function How_Many_Believers(const god0:godrec) : word;
Function Load_God_By_Name(const name:s30; var goddy:godrec) : boolean;
Function Player_Has_A_God(const name:s90) : boolean;

Function Sacrifice_Gold_Return(const ingold:longint) : longint;

Procedure God_Maintenance; {run every day}
Procedure Become_God(const user_name:string;insex:byte);
Procedure God_Status(const goddy:godrec);
Procedure List_Gods(const numbered:boolean);
Procedure Inform_Disciples(const god1 : godrec; const header : s40; const lin1,lin2,lin3,lin4:s100);
Procedure List_Altars(const called_from_mortal_world : boolean);
Procedure The_Great_Creators_Place; {the god boss!}

Implementation

Uses Crt, DDplus, CMS,
     Jakob, Various, Various3,
     News, Online, Mail,
     GenNews, File_IO, SysUtils;

const bossplace ='Rurforium';

Function God_Active(const tgod:godrec) : boolean;
var result : boolean;
begin

 if (tgod.deleted) or (tgod.name='') then result:=false
                                     else result:=true;

 {return result}
 god_active:=result;

end; {god_active *end*}

Function Get_Random_God(var name:s30) : boolean;
const max_tries = 25;
var
   done,
   result : boolean;

   tries : byte;

   size,
   nr : word;

   god0 : godrec;

begin {get random active God and return name of god in the NAME variable
       we also return true or false depending on the success of the
       operation}

 {init}
 result:=false;
 done:=false;
 tries:=0;
 size:=fs(fsgod);

 {does the god-file exist?}
 if f_exists(global_godfil) then begin

  repeat

   {lets get a random number from size}
   nr:=random(size)+1;

   {load character}
   if load_god(fload,god0,nr)=true then begin

    if god_active(god0) then begin

     {set vars}
     name:=god0.name;
     done:=true;
     result:=true;

    end;

   end;

   inc(tries);

  until done or (tries>max_tries);
 end;

 {return result}
 get_random_god:=result;

end; {get_random_god *end*}

Function Verify_Gods_Existance(const name:string) : boolean;
var
    result : boolean;
    i : word;

    tgod : godrec;

begin {verify that a God by the name NAME exists, and is not deleted}

 {init}
 result:=false;

 for i:=1 to fs(FsGod) do begin

  {load god}
  if load_god(fload,tgod,i)=true then begin

   if (UpperCase(tgod.name)=UpperCase(name)) and
      (tgod.deleted=false) then begin
     result:=true;
     break;
   end;
  end;

 end; {for i:= .end.}

 {return result}
 Verify_Gods_Existance:=result;

end; {Verify_Gods_Existance *end*}

Function Select_A_God(var tgod : godrec;const excludename : s70;const numbered:boolean) : boolean;
         {returns false if no God is selected}
var
    i : word;

    s : s70;

    result : boolean;
begin

 {
  let the user pick a God that is not deleted
   }

 {init}
 result:=false;

 repeat

  d(config.textcolor,'Select Immortal (press '+config.textcol2+'?'+config.textcol1+' for list)');
  sd(config.textcolor,':');

  s:=get_string(20);

  if s='?' then begin
   list_gods(numbered);
  end;

 until s<>'?';

 for i:=1 to fs(FsGod) do begin

  {load god}
  if load_god(fload,tgod,i)=true then begin

   if (findsub(s,tgod.name)) and
      (tgod.deleted=false) and
      (tgod.name<>excludename) then begin

    if confirm(ugodc+tgod.name+config.textcol1,'N')=true then begin
     result:=true;
     break;
    end
    else begin

     if confirm('Continue search','Y')=false then begin
      break;
     end;

    end;
   end;
  end;

 end; {for i:= .end.}

 {return result}
 select_a_god:=result;

end; {select_a_god *end*}

Function God_Believers(const godname:string;listem:boolean):word;
var
    result,
    size,
    i,
    j    : word;

    pl0    : ^UserRec;

    s: s100;

begin {how many followers has deity GODNAME?, we list the followers if LISTEM is true}

 {init}
 result:=0;
 new(pl0);

 if listem then begin

  s:='Followers of '+godname;
  d(5,cool_string(length(s),'=','-',5,10));
  d(3,s);
  d(5,cool_string(length(s),'=','-',5,10));

 end;

 {search player and npc file}
 for i:=1 to 2 do begin

   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end;

   for j:=1 to size do begin
    load_character(pl0^,i,j);

    if (pl0^.deleted=false) and
       (pl0^.god<>'') and
       (pl0^.god=godname) then begin

     inc(result);

     if listem then begin
      d(14,commastr(result)+'. '+uplc+pl0^.name2)
     end;

    end;

   end; {for j:= .end.}

  end; {for i:= .end.}

 {remove pointer variables}
 dispose(pl0);
 {return result}
 god_believers:=result;

end; {god_believers *end*}

Function God_Search(const user_name:string) : boolean;
var
    result : boolean;

    i,
    nr,
    counter : word;

begin

 {does user_name have any divine characters?}
 {NOTE: if a user have several divine characters, he must then
  choose which one he would like to play}

 {init}
 result:=false;
 counter:=0;

 for i:=1 to fs(FsGod) do begin

  {load god}
  load_god(fload,god,i);


  if (god.deleted=false) and
     (UpperCase(god.realname)=UpperCase(user_name)) then begin

   inc(counter);

   if counter=1 then begin
    d(5,'Pick your immortal');
   end;

   sd(12,commastr(counter)+'. ');
   d(global_godcol,god.name);

  end;

 end; {for i:= .end.}

 if counter>0 then begin
  d(12,'0. Abort');

  sd(config.textcolorH,':');

  nr:=get_number(0,counter);

  if nr>0 then begin
   {load god #nr}
   counter:=0;
   for i:=1 to fs(FsGod) do begin

    load_god(fload,god,i);

    if (god.deleted=false) and
       (UpperCase(god.realname)=UpperCase(user_name)) then begin

     inc(counter);

     if counter=nr then begin
      result:=true;
      break;
     end;

    end;
   end; {for i:= .end.}
  end;

 end;

 {return result}
 god_search:=result;

end; {god_search *end*}

Procedure Become_God;
var
    slot : word;
    alias : s30;
    done, found : boolean;
    i : word;


    tempgod : godrec;

begin

 {a player enters this proc when he has completed the last dungeon monster}

 clearscreen;
 crlf;
 crlf;
 sd(config.textcolorH,'You ascend to Heaven...');
 Make_Delay_Dots(config.textcolorH,15,300);
 crlf;
 sd(config.textcolorH,'You grovel on your hands and knees before the great ');
 sd(global_godcol,global_supreme_creator);
 d(config.textcolorH,'.');
 crlf;


 {get alias}
 repeat

  d(global_talkcol,'So, what name do you want to be known by?');
  sd(config.textcolorH,':');
  alias:=get_string(22);

  if length(alias)<3 then begin
   d(config.textcolorH,'Your divine name must have at least 3 letters.');
   continue;
  end;
  crlf;
  sd(config.textcolorH,'Reading the ancient scrolls...');

  {*Search for dupe aliases among the Gods*}
  found:=false;
  done:=false;

  for i:=1 to fs(FsGod) do begin

   load_god(fload,god,i);

   if (UpperCase(alias)=UpperCase(god.name)) or
      (UpperCase(alias)='SYSOP') or
      (UpperCase(alias)=UpperCase(global_supreme_creator)) then begin

    crlf;
    d(12,'I''m sorry, but this name is already being used.');
    crlf;
    found:=true;
    break;

   end;
  end; {for i:= .end.}

  if found then continue;

  crlf;
  sd(global_godcol,alias);
  if confirm(' is what you want','Y')=true then begin
   done:=true;
  end
  else begin
   crlf;
  end;
  crlf;

 until done;

 {Setup God record}


 With God do begin
  realname :=User_Name; {real (user/bbs) name}
  name     :=alias; {alias}
  id       :=player.id; {player.id sec tag}
  recnr    :=1; {rec # in file}
  age      :=random(5)+2; {age}
  sex      :=insex;
  ai       :='H';
  level    :=1; {level}
  exp      :=1; {experience}
  deedsleft:=config.gods_deedsleft; {deeds left today}
  deleted  :=false; {deleted}
  believers:=0; {believers, disciples, players who worships this god}
  darkness :=player.dark; {good points}
  goodness :=player.chiv; {dark points}
 end;

 {Save God}
 {trying to find an EMPTY slot to SAVE new God in}
 slot:=0;
 for i:=1 to fs(FsGod) do begin
  load_god(fload,tempgod,i);
  if tempgod.deleted=true then begin
   slot:=i;
   break;
  end;
 end; {for i:= .end}

 if slot>0 then begin
  d(config.textcolor,'Empty slot found....');

  god.recnr:=slot;
  load_god(fsave,god,slot);

 {debug stuff
  d(15,'RealnName: '+god.realname);
  d(15,'Alias: '+god.name);
  d(15,'Recnr: '+commastr(god.recnr));
  pause;
 }

 end
 else begin
  slot:=fs(FsGod)+1;
  god.recnr:=slot;
  load_god(fsave,god,slot);
 end;

 {news-paper}
 newsy(true,
 config.textcol1+'Divinity!',
 ' '+ugodc+god.name+config.textcol1+' became immortal and entered the Divine Realm!',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

 {put the news in the Holy log-file}
 Generic_News(HolyNews,
 true,
 ' '+ugodc+god.name+config.textcol1+' became Immortal!',
 ' '+ugodc+god.name+config.textcol1+' defeated the Supreme Being!',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

 {send message to online players and gods}
 online_send_to_all(uwhite+'*NEW GOD*'+uplc+' '+god.name+config.textcol1+' has become a God!',god.name,'');

end; {become_god *end*}

Function God_Level_Raise(const tempgod:godrec) : word;
var result : word;
    currexp : longint;
begin {calculates and returns the levels tempgod should have based on
       his experience}

 {init}
 result:=1;
 currexp:=tempgod.exp;

 {check exp}
 if currexp>5000 then result:=2;
 if currexp>15000 then result:=3;
 if currexp>50000 then result:=4;
 if currexp>70000 then result:=5;
 if currexp>90000 then result:=6;
 if currexp>110000 then result:=7;
 if currexp>550000 then result:=8;
 if currexp>1000500 then result:=9;

 {return result}
 god_level_raise:=result;

end; {god_level_raise *end*}

Function God_Title(const level:word):string;
var s : s20; {gives back the rank of a certain God level}
begin

 case level of
  1 : s:='Lesser Spirit';
  2 : s:='Minor Spirit';
  3 : s:='Spirit';
  4 : s:='Major Spirit';
  5 : s:='Minor Deity';
  6 : s:='Deity';
  7 : s:='Major Deity';
  8 : s:='DemiGod';
  9: s:='God';

 end; {case of .end.}

 {return result}
 god_title:=s;

end; {god_title *end*}

Procedure List_Gods; {displays ranking list of gods to screen}
var
    i,
    nr,
    counter : word;

    line_counter : byte;

    s : s70;

    abort : boolean;

    tempgod : godrec;

begin {input parameter : numbered}

 {display god rankings to screen}

 crlf;
 s:='   Immortals                Rank                Followers  ';
 d(5,cool_string(length(s),'=','-',5,10));
 d(3,s);
 d(5,cool_string(length(s),'=','-',5,10));

 counter:=0;
 line_counter:=3;
 abort:=false;
 for i:=1 to fs(FsGod) do begin

  if load_god(fload,tempgod,i)=true then begin

   if god_active(tempgod)=true then begin

    inc(counter);

    {#}
    if numbered then begin
     sd(9,ljust(commastr(counter),3));
    end;

    {name}
    sd(global_godcol,ljust(tempgod.name,25));

    {level}
    sd(config.textcolorH,ljust(god_title(tempgod.level)+commastr(tempgod.level),13));

    {believers}
    nr:=god_believers(tempgod.name,false);

    if nr=0 then begin
     sd(8,rjust('-',10));
    end
    else begin
     sd(7,rjust(commastr(nr),10));
    end;


    crlf;

    inc(line_counter);
    if line_counter>global_screenlines-2 then begin
     line_counter:=0;
     if confirm('Continue','Y')=false then begin
      abort:=true;
     end;
    end;

   end;
  end;

  if abort then break;

 end; {for i:= .end}

end; {list_gods *end*}

Procedure God_Status;
begin

 clearscreen;
 crlf;
 crlf;

 {name}
 sd(config.textcolorH,'You are ');
 d(global_godcol,goddy.name);

 {level}
 sd(config.textcolorH,'Rank .. ');
 d(7,god_title(goddy.level)+' (level '+commastr(goddy.level)+')');

 {believers}
 sd(config.textcolorH,'Believers .. ');
 d(7,commastr(goddy.believers));

 {deeds left}
 sd(config.textcolorH,'Deeds left .. ');
 d(7,commastr(goddy.deedsleft));

 {havre}
 sd(config.textcolorH,'Havre .. ');
 d(7,commastr(goddy.exp));


end; {god_status *end*}

Procedure God_Maintenance; {runs every day}
var
    memy : byte;

    mem : integer;

    i : word;

    xx : longint;

    rr : real;

    temp_god : godrec;

begin

 {we exit if no gods exist}
 if f_exists(global_godfil)=false then exit;

 xx:=fs(FsNPC);
 mem:=xx;

 {BIG_LOOP *start*}
 memy:=wherey;
 for i:=1 to fs(FsGod) do begin

  xx:=mem;
  rr:=i;

  if xx>0 then begin
   rr:=rr / xx;
   xx:=round(rr*100);
  end
  else begin
   xx:=0;
  end;

  {progress indicator}
  sgoto_xy(1,memy);
  sd(global_mainttxt,'Immortal activity ('+commastr(xx)+'%)');

  {load god}
  load_god(fload,temp_god,i);

  if god_active(temp_god)=true then begin

   {new deeds}
   temp_god.deedsleft:=config.gods_deedsleft;

   {give believer exp}
   incgodexp(temp_god,temp_god.believers);

   {save god}
   load_god(fsave,temp_god,i);

  end;

 end; {for i:= .end.}
 {BIG_LOOP *end*}

end; {god_maintenance *end*}


Function Sacrifice_Gold_Return(const ingold:longint) : longint;
var result : longint;
begin {given the ingold value this routine returns the power increase
       a god will receive from the amount. used in temple.pas}

 result:=1;
 if ingold<=20 then begin
  result:=1;
 end
 else if (ingold>=21) and (ingold<=2000) then begin
  result:=2;
 end
 else if (ingold>=2001) and (ingold<=45000) then begin
  result:=3;
 end
 else if (ingold>=45001) and (ingold<=150000) then begin
  result:=4;
 end
 else if (ingold>=150001) and (ingold<=900000) then begin
  result:=5;
 end
 else if (ingold>=900001) and (ingold<=15000000) then begin
  result:=6;
 end
 else if (ingold>=15000001) and (ingold<=110000000) then begin
  result:=7;
 end
 else if ingold>=110000001 then begin
  result:=8;
 end;

{
  150001..680000:result:=5;
  681001..1500000: result:=6;
  1500001..150000000: result:=7;

 {return result}
 sacrifice_gold_return:=result;

end; {sacrifice_gold_return .end.}

Function Player_Has_A_God;
var result : boolean;
 i : word;

 goddy : godrec;

begin {checks is NAME has immortal characters}

 {init vars}
 result:=false;

 for i:=1 to fs(FsGod) do begin

  {load god}
  if load_god(fload,goddy,i)=true then begin

   if (UpperCase(goddy.realname)=UpperCase(name)) and
      (goddy.deleted=false) then begin
     result:=true;
     break;
   end;
  end;

 end; {for i:= .end.}

 {return result}
 player_has_a_god:=result;

end; {player_has_a_god .end.}


Function Load_God_By_Name(const name:s30; var goddy:godrec) : boolean;
var result : boolean;
 i : word;

begin {attempts to load a god by NAME}

 {init vars}
 result:=false;

 for i:=1 to fs(FsGod) do begin

  {load god}
  if load_god(fload,goddy,i)=true then begin

   if (UpperCase(goddy.name)=UpperCase(name)) and
      (goddy.deleted=false) then begin
     result:=true;
     break;
   end;
  end;

 end; {for i:= .end.}

 {return result}
 load_god_by_name:=result;

end; {load_god_by_name .end.}

Function How_Many_Believers(const god0:godrec) : word;
var
        i,
        j,
        size,
        result : word;
begin

 {init}
 result:=0;

 {searching among the humans and NPCs}
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   {load character}
   if load_character(player,i,j)=true then begin

    if (player_active(player,false)=true) and
       (player.god=god.name) then begin

     {found a believer!}
     inc(result);

    end;
   end;
  end; {for j:= .end.}
 end; {for i:= .end.}

 {return result}
 How_Many_Believers:=result;
end; {How_Many_Believers *end*}

Procedure Meny;
begin

 {text}
 clearscreen;
 crlf;
 d(5,'-**- '+bossplace+' -**-');
 crlf;
 d(config.textcolorH,'You are standing before '+ugodc+global_supreme_creator+config.textcol1h+'.');
 d(config.textcolorH,'Your presence is barely noticed.');

 crlf;

 menu('(A)sk for power');
 menu('(S)tatus');
 menu('(R)eturn');

end; {meny *end*}


Procedure Display_Menu(refresh,force,short : boolean);
begin

 if short then begin
  if (refresh) and (player.auto_meny) then begin
   refresh:=false;
   meny;
  end;

  crlf;
  sd(config.textcolorH,bossplace+' ('+config.textcol2H+'?'+config.textcol1H+' for menu) :');
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure the_great_creators_place;
var refresh : boolean;

var
    end_boss_visit : boolean;

    ch : char;

    x : word;

begin {the boss god!}

 crlf;
 crlf;
 d(config.textcolorH,'You enter '+ubrown+bossplace+config.textcol1h+'.');

 {location begins here}
 end_boss_visit:=false;
 repeat

  if onliner.location<>onloc_heaven_boss then begin
   refresh:=true;
   onliner.location:=onloc_heaven_boss;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {display menu}
  display_menu(refresh,true,true);

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user-input}
  case ch of
   '?':begin {menu}
        if player.expert=true then display_menu(refresh,true,false)
                              else display_menu(refresh,false,false);
       end;
   'S':begin {status}
        god_status(god);
       end;
   'R':begin {return}
        end_boss_visit:=true;
       end;
   'A':begin {ask for power}

        x:=god_level_raise(god);

        if x=god.level then begin
         crlf;
         crlf;

         case random(2) of
          0:begin
             d(12,'Puny worm! You are not worthy of the higher powers!');
             d(12,'Prove yourself before you come here!');
            end;
          1:begin
             d(12,'Get out of my sight lesser being!');
             d(12,'Hmmppff!');
            end;
         end; {case .end.}
         pause;

        end
        else if x>god.level then begin

         {level raise}
         crlf;
         crlf;
         d(global_godcol,global_supreme_creator+config.textcol1h+' looks at you and nods.');
         d(global_talkcol,'"Reap the rewards of your work '+ugodc+god.name+utalkc+'!"');

         {update god}
         inc(god.level);
         load_god(fsave,god,god.recnr);

         {inform nodes}
         online_send_to_all(uplc+god.name+'s'+config.textcol1+' powers are growing!',god.name,'');

         {news-paper}
         newsy(true,
         config.textcol1+'Divine Ranks!',
         ' '+ugodc+god.name+config.textcol1+' has been granted a new rank; '+ulgreen+god_title(god.level)+config.textcol1+'!',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '');

         {inform disciples}
         Inform_Disciples(god,'Your God Increased '+sex3[god.sex]+' Powers!',
          ugodc+god.name+ulred+' gained a level in heaven!',
          '',
          '',
          '');

         pause;

         crlf;
         d(15,'*Congratulations*');
         d(config.textcolorH,'You are now ranked '+uwhite+god_title(god.level));


        end;

       end; {ask for power .end.}

  end; {case .end}

 until end_boss_visit;

 crlf;
 crlf;
 d(config.textcolorH,'Your mind shifts toward other matters.');

end; {the_great_creators_place *end*}

Procedure List_Altars;
var
    i,
    nr,
    counter : word;

    line_counter : byte;

    god0 : godrec;

begin

 counter:=0;
 line_counter:=0;
 for i:=1 to fs(FsGod) do begin

 {load god}
 if load_god(fload,god0,i)=true then begin

  if god_active(god0) then begin
   inc(counter);

   if counter=1  then begin
    if called_from_mortal_world then begin
     d(5,'You see Altars of different deitys...');
    end
    else begin
     d(5,'You examine your fellow Gods...');
    end;
    inc(line_counter);
   end;

   sd(7,'['+ugodc+god0.name+ulgray+']');

   {#believers}
   nr:=god_believers(god0.name,false);

   if nr=0 then begin
    sd(8,'  (not worshipped)');
   end
   else if nr=1 then begin
    sd(7,'  ('+commastr(nr)+' believer)');
   end
   else begin
    sd(7,'  ('+commastr(nr)+' believers)');
   end;

   crlf;
   inc(line_counter);
   if line_counter>global_screenlines-2 then begin
    line_counter:=0;
    if confirm('Continue','Y')=false then begin
     break;
    end;
   end;

  end;
 end;

end; {for i:= .end.}

end; {list_altars *end*}

Procedure Inform_Disciples(const god1 : godrec; const header : s40; const lin1,lin2,lin3,lin4:s100);
{Sends report to all discples of god GOD1}
var
    i : word;

    pl0 : ^UserRec;

begin

 {init}
 new(pl0);

 {send message to ALL human players in team TEAM}
 for i:=1 to fs(FsPlayer) do begin

  {load character}
  if load_character(pl0^,1,i)=true then begin

   if (pl0^.god=god1.name) and
      (player_active(pl0^,false)=true) then begin

    {mail disciple}
    post(MailSend,
    pl0^.name2,
    pl0^.ai,
    false,
    mailrequest_Nothing,
    '',
    umailheadc+header+config.textcol1,
    mkstring(length(header),underscore),
    lin1,
    lin2,
    lin3,
    lin4,
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

   end;
  end;

 end; {for i:= .end.}

 {dispose pointer vars}
 dispose(pl0);

end; {Team_Report_All *end*}


end. {Unit Vargods .end.}
