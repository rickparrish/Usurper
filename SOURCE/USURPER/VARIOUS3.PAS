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



Unit Various3; {Usurper - Various Routines III}

Interface

Uses Init, File_Io;

{Player}
Procedure Team_Rescue(var ply:UserRec);
Procedure Attack_Guest(npckill,teamkill:boolean); {Attack Guest at the Dormitory}
Procedure Reduce_Player_Resurrections(var ply:userrec; typeinfo:boolean);
Function Look_For_Person(const name,alias:s30; var ai:char) : word;
Function Look_for_Alias(const alias:s30; ai:char) : word;
Function Look_for_ID(const TargetID:s15; ai:char;var ReturnFileId:byte) : word;
Function Get_Random_Character(var ply:userrec ; const plytype:byte) : boolean;
Function Player_Active (const pl:userrec; const hps_req:boolean) : boolean;
Function Select_Character(var ply : UserRec;const hitpoints_required:boolean):boolean;

{Quests}
Procedure Add_Quest(var quest:QuestRec); {adds a quest to the data-base}


{Team}
Function Put_Team_Online(const team:s25; const doing : string; const one_already,inform:boolean) : boolean;
Function Attack_Team : s30; {attack another team}
Function Pick_TeamName(const exclude_team:s30) : s30; {let user pick teamname}
Function Get_TeamName : s70;
Function Team_Active (var pl1,pl2,pl3,pl4 : userrec): byte;
Function Team_Members(const team:s40) : byte;
Procedure Load_TeamMember(const team:s40; var ply:userrec);
Procedure Transfer_TeamStatus(var source,target:userrec);
Procedure Team_Save(var pl1,pl2,pl3,pl4,pl5,pl6,pl7,pl8,pl9 : userrec);
Procedure Team_Report(const name: s30;lines:byte;lin1,lin2,lin3,lin4:s100);
Procedure Team_Report_All(const team,exclude,header:s40;request_constant:word;const lin1,lin2,lin3,lin4:s100);
Procedure Team_Online_Report_All(const team:s40;const excluded,message:s90);
Procedure Display_Member(var gnugge : userrec; topbar : boolean);
Procedure Display_Members(const team:s30;topbar:boolean);

{Bard routines}
Procedure Init_Bard_Song_Data(var Bardsong:Bardtype);

{Prison}
Procedure List_of_Prisoners;

{Misc}
Procedure Display_Game_Settings(const uversion : string);
procedure settings_header(const head : string);

Implementation

Uses CMS, Jakob, {$IFDEF MSDOS}InitOver,{$ENDIF} Various,
     Various2, PlvsPlc, PlComp,
     Mail, News, SortTeam,
     Relation, Online;


{display settings routines uses setcol and setcol2}
const setcol = ulcyan; {what color the settings should be displayed in}
      setcol2=11; {same as above but numerical}


{*** VARIOUS3 ***}
procedure settings_header(const head : string);
begin {display game settings routine}
 d(10,head);
 d(2,cool_string(length(head),'=','-',10,2));

end; {settings_header .end.}

Procedure Load_TeamMember(const team:s40; var ply:userrec);
var
    i,
    j,
    size : word;

    found : boolean;

begin

 {tries to load a teammember in team TEAM}

 found:=false;
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   if load_character(ply,i,j)=true then begin

    if (ply.team=team) and
       (ply.team<>'') and
       (player_active(ply,false)=true) then begin
     found:=true;
    end;
   end;

   if found then break;
  end; {for j:= .end.}
  if found then break;
 end; {for i:= .end.}

end; {load_teammember *end*}

Procedure Transfer_TeamStatus(var source,target:userrec);
begin
 {makes character TARGET a member of character SOURCEs team}
 target.team     :=source.team;
 target.teampw   :=source.teampw;
 target.cturf    :=source.cturf;
 target.teamrec  :=source.teamrec;
 target.gym_owner:=source.gym_owner;
end; {transfer_teamstatus *end*}

Procedure Team_Save; {Save Team}
begin

 pl1.gnollp:=0;
 pl2.gnollp:=0;
 pl3.gnollp:=0;
 pl4.gnollp:=0;
 pl5.gnollp:=0;
 pl6.gnollp:=0;
 pl7.gnollp:=0;
 pl8.gnollp:=0;
 pl9.gnollp:=0;

 if (pl1.name1<>'') and (pl1.name2<>'') then user_save(pl1);
 if (pl2.name1<>'') and (pl2.name2<>'') then user_save(pl2);
 if (pl3.name1<>'') and (pl3.name2<>'') then user_save(pl3);
 if (pl4.name1<>'') and (pl4.name2<>'') then user_save(pl4);
 if (pl5.name1<>'') and (pl5.name2<>'') then user_save(pl5);
 if (pl6.name1<>'') and (pl6.name2<>'') then user_save(pl6);
 if (pl7.name1<>'') and (pl7.name2<>'') then user_save(pl7);
 if (pl8.name1<>'') and (pl8.name2<>'') then user_save(pl8);
 if (pl9.name1<>'') and (pl9.name2<>'') then user_save(pl9);

end; {SAVE_TEAM **END**}

Function Get_Teamname; {returns a teamname}
var
    result : s70;

    txt : text;
begin

 {init}
 result:='';

 {create if non existant}
 if f_exists(global_tnames)=false then begin
  create_teamnamefile;
 end;

 {get random line(team) from textfile}
 result:=get_random_line_from_textfile(global_tnames);

 {return result}
 Get_TeamName:=result;

end; {get_teamname *end*}

Procedure Team_Report; {Sends report to team-member with name NAME}
var
    i : word;
    pl0 : UserRec;

begin

 case lines of
  1:begin
     lin2:=emptystr;
     lin3:=emptystr;
     lin4:=emptystr;
    end;
  2:begin
     lin3:=emptystr;
     lin4:=emptystr;
    end;
  3:begin
     lin4:=emptystr;
    end;
 end; {case .end.}

 {name=player who shall receive message in lines nice[1-lines]}

 for i:=1 to fs(FsPlayer) do begin;

  {load character}
  if load_character(pl0,1,i)=true then begin

   if (pl0.name2=name) and
      (player_active(pl0,false)=true) then begin

    {mail team-member}
    post(MailSend,
    pl0.name2,
    pl0.ai,
    false,
    mailrequest_nothing,
    '',
    umailheadc+'Team'+config.textcol1,
    mkstring(4,underscore),
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

end; {Team_Report *end*}

Procedure Team_Online_Report_All(const team:s40;const excluded,message:s90);
var
     i : word;
   counter : byte;
   pl0 : ^UserRec;

begin
 {sends MESSAGE to all online players in team TEAM}

 {init}
 new(pl0);
 counter:=0;
 if excluded<>'' then inc(counter);

 for i:=1 to fs(FsPlayer) do begin

  {load character}
  if load_character(pl0^,1,i)=true then begin

   if (pl0^.team=team) and
      (player_active(pl0^,false)=true) and
      (pl0^.name2<>excluded) and
      (is_online(pl0^.name2,online_player)=true) then begin

    {send message to team-member}
    online_send_to_player(pl0^.name2,online_player,message);

    inc(counter);
    if counter>=global_maxteammembers then break;
   end;
  end;
 end; {for i:= .end.}

 {dispose pointer vars}
 dispose(pl0);

end; {team_online_report_all *end*}

Procedure Team_Report_All(const team,exclude,header:s40;request_constant:word;const lin1,lin2,lin3,lin4:s100);
{Sends report to all team-members in team TEAM, excludes player with
  name EXCLUDE}
var
    i : word;

    counter : byte;

    pl0 : ^UserRec;

begin

 {init}
 new(pl0);
 counter:=0;
 if exclude<>'' then inc(counter);

 {send message to ALL human players in team TEAM}
 for i:=1 to fs(FsPlayer) do begin;

  {load character}
  if load_character(pl0^,1,i)=true then begin

   if (pl0^.team=team) and
      (player_active(pl0^,false)=true) and
      (pl0^.name2<>exclude) then begin

    {mail team-member}
    post(MailSend,
    pl0^.name2,
    pl0^.ai,
    false,
    request_constant,
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

    inc(counter);
    if counter>=global_maxteammembers then break;

   end;
  end;

 end; {for i:= .end.}

 {dispose pointer vars}
 dispose(pl0);

end; {Team_Report_All *end*}

Function Pick_TeamName(const exclude_team:s30) : s30; {let user pick teamname}
var

    i, j, k, x,
    size,
    currentmax : word;

    s,
    result : s30;

    ply : userrec;

    go_ahead,
    break_out : boolean;

    infos : array [1..global_maxplayers] of ^s30;

begin

 {init}
 result:='';
 currentmax:=0;
 go_ahead:=true;
 break_out:=false;

 crlf;
 repeat
  crlf;
  d(config.textcolor,'Select Team ('+config.textcol2+'?'+config.textcol1+' for list)');
  sd(config.textcolor,':');
  s:=get_string(30);

  if s='?' then begin
   sort_teams(false,true,false,false);
  end;

 until s<>'?';

 for i:=1 to 2 do begin
  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end;

  for j:=1 to size do begin

   if load_character(ply,i,j)=true then begin

    if (findsub(s,ply.team)) and
       (ply.team<>'') and
       (ply.king=false) and
       (ply.team<>exclude_team) and
       (ply.name2<>player.name2) and
       (player_active(ply,false)=true) then begin

     x:=0;

     if currentmax>0 then begin

      for k:=1 to currentmax do begin
       if infos[k]^=ply.team then begin
        x:=1;
        break;
       end;
      end; {for k:= .end.}

     end;

     if x=0 then begin
      if confirm(utec+ply.team+config.textcol1,'N')=true then begin
       result:=ply.team;
       break_out:=true;
      end
      else begin

       {setup a new string}
       inc(currentmax);
       new(infos[currentmax]);
       infos[currentmax]^:=ply.team;

       if confirm('Continue search','Y')=false then begin
        break_out:=true;
       end;

      end;
     end;

    end;
   end;

   if break_out then break;

  end; {for j:= .end.}

  if break_out then break;

 end; {for i:= .end.}

 if currentmax>0 then begin
  for i:=1 to currentmax do begin
   dispose(infos[i]);
  end;
 end;

 {return result}
 pick_teamname:=result;

end; {pick_teamname *end*}

Function Attack_Team : s30; {attack another team}
var result : s30;
    s,a : s30;
    motivation : boolean;
    i,j,k,x,y,size : word;
    currentmax:word;
    player0 : ^UserRec;

    xx,yy : longint;

    infos : array [1..global_maxplayers] of ^s30;

begin

 {init}
 result:='';
 s:='';
 currentmax:=0;
 new(player0);


 if player.tfights<1 then begin
  crlf;
  crlf;
  d(12,'You have used all your fights! (come back tomorrow)');
 end
 else begin
  crlf;
  crlf;
  d(config.textcolor,'Gang to wipe out');
  sd(config.textcolor,':');
  a:=get_string(30);

  s:=emptystr;
  motivation:=true;
  for i:=1 to 2 do begin
   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end;

   for j:=1 to size do begin
    if s='' then begin

     if load_character(player0^,i,j)=true then begin

      if (findsub(a,player0^.team)) and
         (player0^.team<>'') and
         (player0^.team<>player.team) and
         (player_active(player0^,true)=true) and
         (player0^.allowed=true) then begin

       x:=0;

       if currentmax>0 then begin

        for k:=1 to currentmax do begin
         if infos[k]^=player0^.team then begin
          x:=1;
          break;
         end;
        end; {for k:= .end.}

       end;

       if x=0 then begin
        sd(global_teamcol,player0^.team);
        if confirm(' ','n')=true then begin
         s:=player0^.team;
        end
        else begin

         {setup a new string}
         inc(currentmax);
         new(infos[currentmax]);
         infos[currentmax]^:=player0^.team;

         if confirm('Continue search','y')=false then begin
          motivation:=false;
          break;
         end;

        end;
       end;
      end;

     end;
    end
    else begin
     break;
    end;

    if (motivation=false) or (s<>'') then begin
     break;
    end;

   end; {for j:= .end.}

   if (motivation=false) or (s<>'') then begin
    break;
   end;

  end; {for i:= .end.}

  if s<>'' then begin

   {check if players is allowed to fight this team}
   if config.teamdiff<5000 then begin
    xx:=0;
    yy:=0;
    x:=0;
    y:=0;

    for i:=1 to 2 do begin
     case i of
      1: size:=fs(FsPlayer);
      2: size:=fs(FsNpc);
     end;

     for j:=1 to size do begin
      if x+y>9 then break;

      if load_character(player0^,i,j)=true then begin

       if player0^.team=player.team then begin
        inc(xx,player0^.level);
        inc(x);
       end;

       if player0^.team=s then begin
        inc(yy,player0^.level);
        inc(y);
       end;
      end;

     end; {for j:= .end.}
     if x+y>9 then break;
    end; {for j:= .end.}

    if xx-yy>config.teamdiff then begin
     crlf;
     d(15,'That would be too easy!');
     s:=emptystr;
    end;
   end;

   if s<>'' then begin
    dec(player.tfights);

    {update onliner.doing}
    onliner.doing:='fighting '+utec+s+config.textcol1;
    add_onliner(OUpdateLocation,onliner);

   end;
  end;
 end;

 {dispose}
 dispose(player0);

 if currentmax>0 then begin
  for i:=1 to currentmax do begin
   dispose(infos[i]);
  end;
 end;

 result:=s;
 {return result}
 attack_team:=result;

end; {attack_team *end*}

Procedure Team_TopBar(const team:s30);
var a2 : s90;
begin
 crlf;
 crlf;
 d(global_teamcol,upcasestr(team));
 crlf;
 a2:='Player        Status  Level  Class    Weapon  Armor  Potions    HitPoints';
 d(5,a2);
 d(5,mkstring(length(a2),'='));
end;

Procedure Display_Members; {display team members in team TEAM}
var i,j : word;
   size : word;
   pl0 : UserRec;
begin

 if topbar then begin
  team_topbar(team);
 end;

 for i:=1 to 2 do begin
  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end;

  for j:=1 to Size do begin

   {load character}
   if load_character(pl0,i,j)=true then begin

    if (pl0.team=team) and
       (pl0.name2<>player.name2) and
       (player_active(pl0,false)=true) then begin

     {display member}
     display_member(pl0,false);
    end;
   end;
  end; {for j:= .end.}
 end; {for i:= .end.}

end;

Procedure Display_Member; {display team member}

var a2 : string[90];
    justval : byte;

begin

 if topbar then begin
  team_topbar(gnugge.team);
 end;

 justval:=14;

 {name}
 sd(global_plycol,ljust(gnugge.name2,justval));

 {status}
 justval:=8;
 if (gnugge.hps>0) and (is_online(gnugge.name2,online_player)) then begin
  sd(15,ljust('Online',justval));
 end
 else if gnugge.location=offloc_prison then begin
  sd(13,ljust('Prison',justval));
 end
 else if gnugge.hps>0 then begin
  if gnugge.location=offloc_home then begin
   sd(15,'Home');
  end
  else begin
   sd(14,ljust('Alive',justval));
  end;
 end
 else if gnugge.hps=-9000 then begin
  sd(4,ljust('Drugged',justval));
 end
 else if gnugge.hps<1 then begin
  sd(4,ljust('Dead',justval));
 end;

 {level}
 justval:=5;
 sd(config.textcolor,rjust(commastr(gnugge.level),justval));
 sd(config.textcolor,'  ');

 {class}
 justval:=10;
 sd(config.textcolor,ljust(classnames[gnugge.class],justval));

 {weapon/armor}
 justval:=5;
 if config.classic then begin
  sd(config.textcolor,rjust(commastr(gnugge.wpow*11),justval));
  sd(config.textcolor,'  ');
  sd(config.textcolor,rjust(commastr(gnugge.apow*11),justval));
  sd(config.textcolor,'  ');
 end
 else begin
  sd(config.textcolor,rjust(commastr(gnugge.weappow),justval));
  sd(config.textcolor,'  ');
  sd(config.textcolor,rjust(commastr(gnugge.armpow),justval));
  sd(config.textcolor,'  ');
 end;

 {potions}
 justval:=7;
 sd(config.textcolor,rjust(commastr(gnugge.healing),justval));

 {hitpoints}
 justval:=13;
 a2:=commastr(gnugge.hps)+'/'+commastr(gnugge.maxhps);

 sd(config.textcolor,rjust(a2,justval));
 crlf;

end;

Function Team_Members(const team:s40) : byte;
var
    i,
    j,
    size : word;

    result : byte;

    pl0 : UserRec;

begin
 {simply counts the member in team TEAM}

 result:=0;
 for i:=1 to 2 do begin
  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   if load_character(pl0,i,j)=true then begin

    if (pl0.team=team) and
       (pl0.team<>'') and
       (player_active(pl0,false)=true) then begin
     inc(result);
    end;
   end;
  end; {for j:= .end.}
 end; {for i:= .end.}

 {return result}
 team_members:=result;

end; {team_members *end*}

Function Team_Active (var pl1,pl2,pl3,pl4 : userrec): byte;
var c : byte;
begin

 c:=1;

 if player_active(pl1,true) then inc(c);
 if player_active(pl2,true) then inc(c);
 if player_active(pl3,true) then inc(c);
 if player_active(pl4,true) then inc(c);

 {return result}
 team_active:=c;

end; {team_active *end*}


Function Select_Character(var ply : UserRec;const hitpoints_required:boolean):boolean;

{lets the user choose a player/npc
 return FALSE if user aborted/didn't choose}

var

    i,
    j,
    size : word;

    s : s30;

    found,
    abort : boolean;

begin

 {init}
 found:=false;
 abort:=false;

 {get string}
 sd(config.textcolor,':');
 s:=get_string(20);

 {searching among the humans and NPCs}
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   {load character}
   if load_character(ply,i,j)=true then begin

    if (findsub(s,ply.name2)) and
       (player_active(ply,hitpoints_required)=true) and
       (ply.name2<>player.name2) then begin

     if confirm(uplc+ply.name2+config.textcol1,'N')=true then begin
      found:=true;
     end
     else begin
      if confirm('Continue search','Y')=false then begin
       abort:=true;
      end;
     end;

    end;
   end;
   if (abort) or (found) then break;
  end; {for j:= .end.}
  if (abort) or (found) then break;
 end; {for i:= .end.}

 {}
 if (found=false) and (abort=false) then begin
  Could_Not_Locate_Character;
 end;

 {return result}
 Select_Character:=found;

end; {select_character *end*}

Function Put_Team_Online(const team:s25; const doing : string; const one_already,inform:boolean) : boolean;
      {put every teammember in TEAM online, returns false if we
       fail to put a member online}
var
    result : boolean;
    left_to_add : byte;

    i,j,
    size : word;

    ply : userrec;

begin

 {init}
 result:=false;

 left_to_add:=global_maxteammembers;
 if one_already then dec(left_to_add);

 {searching among the humans and NPCs}
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   {load character}
   if load_character(ply,i,j)=true then begin

    if (left_to_add>0) and
       (ply.team=team) and
       (player_active(ply,true)=true) then begin

     if add_shadow(SAdd,ply,player.name2,'Tug of War competition',0)=true then begin
      if inform then begin
       d(global_plycol,ply.name2+config.textcol1+' has arrived!');
      end;
      dec(left_to_add);
     end;

    end;
   end;

   if left_to_add<1 then break;
  end; {for j:= .end.}
  if left_to_add<1 then break;
 end; {for i:= .end.}

 if left_to_add<1 then result:=true
                  else result:=false;

 {return result}
 put_team_online:=result;

end; {put_team_online *end*}

Function Get_Random_Character(var ply:userrec; const plytype:byte) : boolean;
var      {plytype=1 Human,plytype=2 Npc, plytype=3 random}
    done,
    result : boolean;

    tries,
    pltype : byte;

    nr,
    size : word;

begin

 {determine if we should read player from user- or npcfile}
 pltype:=plytype;
 if pltype=3 then pltype:=random(2)+1;

 {determine size of file}
 case pltype of
  1:   size:=fs(FsPlayer);
  else size:=fs(FsNpc);
 end; {case .end.}

 tries:=0;
 done:=false;
 result:=false;
 repeat
  inc(tries);

  {lets get a random number from size}
  nr:=random(size)+1;

  {load character}
  if load_character(ply,pltype,nr)=true then begin

   if (player_active(ply,true)=true) and
      (ply.name2<>player.name2) and
      (ply.location<>offloc_prison) then begin

    done:=true;
    result:=true;

   end;
  end;

 until done or (tries>25);

 {return result}
 get_random_character:=result;

end; {get_random_character *end*}

Function Look_For_Person(const name,alias:s30; var ai:char) : word;
var result : word;

 {look for player with alias ALIAS and/or realname NAME.
  ai='H' look among humans, ai='C' look among Npcs, ai='A' look among both
  function returns record # (0 if not found)
  function returns AI with correct value (H,C) if person was found
  }

procedure Look_for_person2(charfile:byte);
var i : word;
   size : word;
   ok : boolean;
   pl0 : UserRec;

begin

 ok:=false;
 case charfile of
  1: size:=fs(FsPlayer);
  2: size:=fs(FsNpc);
 end; {case .end.}

 for i:=1 to size do begin

  if load_character(pl0,charfile,i)=true then begin

   if (player_active(pl0,false)=true) then begin

    ok:=true;
    if (alias<>'') and (pl0.name2<>alias) then ok:=false;
    if (name<>'') and (pl0.name1<>name) then ok:=false;

    if ok then begin
     case charfile of
      1: ai:='H';
      2: ai:='C';
     end; {case .end.}
     result:=i;
     break;
    end;
   end;
  end;
 end; {for i:= .end.}

end;

begin

 {init}
 result:=0;

 case ai of
  'A':begin {look in both player and npc files}
       look_for_person2(1);
       if result=0 then begin
        look_for_person2(2);
       end;
      end;
  'H': look_for_person2(1);
  'C': look_for_person2(2);
 end; {case .end.}

 {return result}
 look_for_person:=result;

end; {look_for_person2 *end*}

Function Look_for_ID(const TargetID:s15; ai:char;var ReturnFileId:byte) : word;
var
    found : boolean;

    number,
    size, i, j : word;

    pl0 : UserRec;

begin

 {looks for TARGETID among the player and npc files}
 {returns the record # and ReturnFileId (1=playerfile,2=npcfile)}

 number:=0;
 ReturnFileId:=1;

 found:=false;
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(Fsplayer);
   2: size:=fs(fsNpc);
  end; {case .end.}

  for j:=1 to Size do begin

   if load_character(pl0,i,j)=true then begin

    if (pl0.ID=TargetID) and
       (player_active(pl0,false)=true) then begin
     ReturnFileId:=i;
     number:=j;
     found:=true;
     break;
    end;

   end;

   if found=true then break;

  end; {for j:= .end.}

  if found=true then break;

 end; {for i:= .end.}

 {return result}
 look_for_id:=number;

end; {look for ID *END*}

Function Look_For_Alias(const alias:s30; ai:char) : word;
var
    found : boolean;

    loadfile, charfile : byte;

    pl0 : UserRec;

    size, i, j : word;
    number : word;

begin

 {looks for ALIAS among the player and npc files}
 {returns the record #}
 number:=1;

 {where should we look first? it depends on the ai of course}
 if ai='H' then begin
  charfile:=1;
 end
 else begin
  charfile:=2;
 end;

 found:=false;
 for i:=1 to 2 do begin

  if charfile=1 then begin
   size:=fs(Fsplayer);
   loadfile:=1;
   charfile:=2;
  end
  else begin
   size:=fs(fsNpc);
   loadfile:=2;
   charfile:=1;
  end;

  for j:=1 to Size do begin
   if load_character(pl0,loadfile,j)=true then begin

    if (pl0.name2=alias) and
       (player_active(pl0,false)=true) then begin

     number:=j;
     found:=true;
     break;
    end;

   end;
  end; {for j:= .end.}

  if found then break;

 end; {for i:= .end.}

 {return result}
 look_for_alias:=number;

end; {look for alias **END**}

Procedure Attack_Guest; {Attack Guest at the Dormitory}
var

    ch, cho : char;

    size: word;

    i,
    j,
    x,
    ii : longint;


    steal_potions : boolean;
    steal_money   : boolean;


    s,
    s1,
    header,
    headline : s100;

    ok,
    done,
    abort,
    found,
    npcpunk : boolean;

    pl0 : ^UserRec;

begin

 {new}
 new(pl0);

 crlf;
 crlf;
 case random(4) of
  0: d(config.textcolor,'Who''s gonna taste steel?');
  1: d(config.textcolor,'Who shall you fight?');
  2: d(config.textcolor,'Who shall you kill?');
  3: d(config.textcolor,'Who must die?');
 end; {case .end.}

 {get user-input}
 sd(config.textcolor,':');
 s:=get_string(30);
 s:=upcasestr(s);

 found:=false;
 abort:=false;

 npcpunk:=false;

 {searching among the humans and NPCs}
 ii:=2;
 if not npckill then dec(ii);

 for i:=1 to ii do begin

  case i of
   1:begin
      size:=fs(FsPlayer);
      npcpunk:=false;
     end;
   2:begin
      size:=fs(FsNpc);
      npcpunk:=true;
     end;
  end; {case .end.}

  if abort=false then begin

   for j:=1 to size do begin

    if found=false then begin

     if load_character(pl0^,i,j)=true then begin

      if (pl0^.king=false) and
         (pl0^.name2<>player.name2) and
         (player_active(pl0^,true)=true) and
         (pl0^.location=offloc_dormitory) then begin

       if (findsub(s,pl0^.name2)) and
          (s<>player.name2) then begin

        if is_online(pl0^.name2,online_player)=false then begin
         if confirm(uplc+pl0^.name2+config.textcol1,'N')=true then begin

          {fair fight pre-calc}
          x:=player.level-pl0^.level;

          if Is_Player_Married(player.name2,player.id)=pl0^.name2 then begin
           cannot_attack_husband(player,pl0^);
          end
          else if (x>config.leveldiff) and (config.leveldiff<>0) then begin
           d(12,'Nah, that wouldn''t be a fair fight!');
          end
          else if (player.team=pl0^.team) and (player.team<>'') and (teamkill=false) then begin
           d(12,'You are not allowed to attack your own teammates!');
          end
          else if pl0^.location=offloc_prison then begin
           sd(global_plycol,pl0^.name2);
           d(config.textcolor,' is residing in prison!');
          end
          else if pl0^.location=offloc_home then begin
           sd(global_plycol,pl0^.name2);
           d(config.textcolor,' is home!');
          end
          else begin
           s:=pl0^.name2;
           found:=true;
           break;
          end;
         end
         else begin
          if confirm('Continue Search','Y')=false then begin
           abort:=true;
           found:=true;
           break;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
   end; {for j:= .end.}
  end;
 end; {for i:= .end.}

 crlf;
 if (found=false) and (abort=false) then begin
  Could_Not_Locate_Challengable_Character;
 end
 else if (found=true) and (abort=false) then begin

  {set online locations}
  onliner.location:=onloc_dormfight;
  onliner.doing   :='fighting '+uplc+pl0^.name2+config.textcol1;
  add_onliner(OUpdateLocation,onliner);

  if add_shadow(SAdd,pl0^,player.name2,'fighting '+uplc+player.name2+config.textcol1,0)=false then begin
   {unable to add pl0}
   d(global_plycol,pl0^.name2+ulred+' has left the Dormitory!');
   pause;
  end
  else begin

   cho:='?';
   repeat

    if cho='?' then begin

     crlf;
     sd(config.textcolor,'So, you wanna get rid of ');
     sd(global_plycol,pl0^.name2);
     sd(config.textcolor,'!');
     crlf;
     menu('(A)bort');
     menu2('(P)ick-pocket');

     if player.pickpocketattempts<1 then begin
      d(12,' **You have no attempts left**')
     end
     else begin
      d(15,' **You have '+commastr(player.pickpocketattempts)+' attempts left**')
     end;

     menu('(M)urder');
     menu('(W)ake up and challenge');
     crlf;
     sd(config.textcolor,'Make your Move :');

    end;

    {get user input}
    cho:=upcase(getchar);

    if (cho='P') and (player.pickpocketattempts<1) then begin
     crlf;
     crlf;
     d(12,'You have no attempts left. Try again tomorrow!');
     pause;
     cho:='?';

    end
    else if (cho='P') and (pl0^.gold<1) and (pl0^.healing<1) then begin
     crlf;
     crlf;
     sd(config.textcolor,'Nah, ');
     sd(global_plycol,pl0^.name2);
     d(config.textcolor,' has nothing of value.');
     pause;
     cho:='?';
    end
    else if cho=ReturnKey then begin
     cho:='?';
    end;

   until cho in ['A','M','W','P'];

   crlf;
   case cho of
    'A':begin {abort}
         crlf;
         d(global_talkcol,'Well, you can take care of this wimp later');
        end;
    'P':begin {pick-pocket}

         {decrease daily number of pick pockets attempts}
         dec(player.pickpocketattempts);

         {update player}
         user_save(player);

         {should player be able to steal healing potions as well?}
         steal_potions:=false;
         steal_money:=false;

         if pl0^.healing>0 then begin
          steal_potions:=true;
         end;

         if pl0^.gold>0 then begin
          steal_money:=true;
         end;

         crlf;
         sd(config.textcolor,'You sneak up beside ');

         sd(global_plycol,pl0^.name2+'s ');
         d(config.textcolor,'bed...');
         crlf;

         {if victim has both potions and money then player must choose}
         if (steal_money) and steal_potions then begin
          done:=false;
          repeat
           crlf;
           d(config.textcolor,'What do you go for?');
           menu('(P)otions');
           menu('(G)old');
           sd(config.textcolor,':');

           {get user-input}
           ch:=upcase(getchar);

           case ch of
            'P':begin {steal potions}
                 crlf;
                 d(15,'Potions');
                 crlf;
                 sd(global_plycol,pl0^.name2);
                 d(config.textcolor,' keeps '+sex3[pl0^.sex]+' belt with Potions stuck under '+sex3[pl0^.sex]+' pillow.');
                 crlf;
                 steal_potions:=true;
                 steal_money:=false;
                 done:=true;
                end;
            'G':begin {steal gold}
                 crlf;
                 d(15,'Gold');
                 d(10,'You are greedy..');
                 steal_money:=true;
                 steal_potions:=false;
                 done:=true;
                end;

           end; {case .end.}

          until done;

         end;

         if steal_money then begin
          sd(config.textcolor,'You cautiously lift ');
          sd(global_plycol,pl0^.name2+'s');
          sd(config.textcolor,' hand from '+sex3[pl0^.sex]+' purse');

          make_delay_dots(2,8,600);
          crlf;
         end;

         if steal_potions then begin
          sd(config.textcolor,'You cautiously lift '+uplc+pl0^.name2+'s'+config.textcol1+' head from the pillow.');
          make_delay_dots(2,8,600);
          crlf;
         end;

         {chance of success}
         if random(3)=0 then ok:=true
                        else ok:=false;


         if ok then begin
          {successfull attempt}

          if steal_money then begin
           sd(config.textcolor,'You took ');
           sd(14,commastr(pl0^.gold));
           d(config.textcolor,' '+many_money(pl0^.gold)+'!');
           crlf;
           d(15,'Good work!');
           pause;
          end
          else if steal_potions then begin
           sd(config.textcolor,'You took ');
           sd(14,commastr(pl0^.healing));
           d(config.textcolor,' healing potions!');
           crlf;
           d(15,'Good work!');
           pause;
          end;

          if steal_money then begin
           {inc player money}
           IncPlayerMoney(player,pl0^.gold);
          end
          else if steal_potions then begin
           player.healing:=player.healing+pl0^.healing;
          end;

          {set news-paper headline}
          case random(2) of
           0: headline:='Pick-Pockets at the Dormitory';
           1: headline:='Cleptomaniac on the lose!';
          end; {case .end.}

          if steal_money then begin
           {News-Paper}
           Newsy(true,
           headline,
           ' '+uplc+pl0^.name2+config.textcol1+' woke up at the Dormitory, noticing '+sex3[pl0^.sex]+' purse missing.',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');
          end
          else if steal_potions then begin
           {News Paper}
           Newsy(true,
           headline,
           ' '+uplc+pl0^.name2+config.textcol1+' woke up at the Dormitory, noticing that many',
           ' of '+sex3[pl0^.sex]+' Healing Potions were missing!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');
          end;

          {set mail headline}
          case random(2) of
           0: headline:='Thieves!';
           1: headline:='Kleptomaniac!';
          end; {case .end.}

          if steal_money then begin
           {mail victim}
           post(MailSend,
           pl0^.name2,
           pl0^.ai,
           false,
           mailrequest_nothing,
           '',
           ulred+headline+config.textcol1,
           mkstring(length(headline),underscore),
           'Some malicious character emptied your purse while you',
           'were sleeping. The thief got away with '+uyellow+commastr(pl0^.gold)+config.textcol1+' '+many_money(pl0^.gold)+'.',
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
          end
          else if steal_potions then begin
           {mail victim}
           post(MailSend,
           pl0^.name2,
           pl0^.ai,
           false,
           mailrequest_nothing,
           '',
           ulred+headline+config.textcol1,
           mkstring(length(headline),underscore),
           'Some unscrupulous character put his arm under your pillow last night while you',
           'were sleeping. The thief got away with '+uwhite+commastr(pl0^.healing)+config.textcol1+' potions.',
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
          end;

          {update victims record}
          if steal_money then begin
           pl0^.gold:=0;
          end
          else if steal_potions then begin
           pl0^.healing:=0;
          end;

          {update offline player}
          user_save(pl0^);

         end
         else begin

          case random(2) of
           0:begin
              {sleeping guest woke up! attempt failed}
              crlf;
              sd(12,'Oh no! ');
              sd(global_plycol,pl0^.name2);
              d(12,' woke up! And '+sex2[pl0^.sex]+' is angry...');
              pause;
             end;
           1:begin
              {sleeping guest was never asleep! attempt failed}
              crlf;
              sd(12,'Suddenly ');
              sd(global_plycol,pl0^.name2);
              d(12,' opens '+sex3[pl0^.sex]+' eyes!');
              d(global_talkcol,' I was never asleep! I have been watching you! Thieving scoundrel!');
              pause;
             end;
          end; {case .end.}

          {worsen pl0:s attitude to player}
          Update_Relation(Relation_Worsen,2,pl0^,player,false,false);

          repeat
           player_computer(player,pl0^,false,4);
          until (player.hps<1) or (pl0^.hps<1);

          {evaluate fight}
          if (player.hps<1) and (pl0^.hps<1) then begin

           {both died}

           {set news-paper headline}
           case random(3) of
            0: headline:='Pick-Pockets at the Dormitory';
            1: headline:='Cleptomaniac on the lose!';
            2: headline:='Skinners at the Dormitory';
           end; {case .end.}

           if steal_money then begin
            {News Paper}
            Newsy(true,
            headline,
            ' '+uplc+player.name2+config.textcol1+' was caught trying to steal money from '+uplc+pl0^.name2+config.textcol1
               +'.',
            ' '+uplc+pl0^.name2+config.textcol1+' woke up and fought '+uplc+player.name2+config.textcol1+'.',
            ' '+ulred+'They were both killed!'+config.textcol1,
            '',
            '',
            '',
            '',
            '',
            '');
           end
           else if steal_potions then begin
            {News Paper}
            Newsy(true,
            headline,
            ' '+uplc+player.name2+config.textcol1+' was caught trying to steal healing potions from '+uplc+pl0^.name2
               +config.textcol1+'.',
            ' '+uplc+pl0^.name2+config.textcol1+' woke up and fought '+uplc+player.name2+config.textcol1+'.',
            ' '+ulred+'They were both killed!'+config.textcol1,
            '',
            '',
            '',
            '',
            '',
            '');
           end;

           {set mail headline}
           case random(2) of
            0: headline:='Thieves!';
            1: headline:='Kleptomaniac!';
           end; {case .end.}

           {mail to offline player}
           if steal_money then begin
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+headline+config.textcol1,
            mkstring(length(headline),underscore),
            uplc+player.name2+config.textcol1+' tried to snatch your purse while you',
            'were sleeping. You woke up and fought '+sex[player.sex]+'!',
            ulred+'You killed each other!'+config.textcol1,
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
           end
           else if steal_potions then begin
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+headline+config.textcol1,
            mkstring(length(headline),underscore),
            uplc+player.name2+config.textcol1+' put '+sex3[player.sex]+' under your pillow while you',
            'were sleeping. You woke up and fought '+sex[player.sex]+'!',
            ulred+'You killed each other!'+config.textcol1,
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
           end;

           sd(12,'Both you and ');
           sd(global_plycol,pl0^.name2);
           d(12,' suffer from fatal wounds.');
           d(12,'There is darkness...');

           {update offline player}
           user_save(pl0^);

           if config.dormpocketattackallow=false then begin
            player.allowed:=false;
           end;

           {update "killedby" variable in relations data file}
           killed_by_stats(player,pl0^);

           {update "killedby" variable in relations data file}
           killed_by_stats(pl0^,player);

           {update player}
           user_save(player);

           reduce_player_resurrections(player,true);

           pause;
           normal_exit;

          end
          else if player.hps<1 then begin

           {player died}
           {don't allow player to enter more this day}
           player.hps:=0;

           reduce_player_resurrections(player,true);

           if config.dormpocketattackallow=false then begin
            {player.allowed:=false;}
           end;

           s1:='';

           if steal_money then begin
            if player.gold>0 then begin
             {player is robbed of his money}
             incplayermoney(pl0^,player.gold);
             sd(global_plycol,pl0^.name2);
             d(12,' took your '+many_money(player.gold)+'!');
             {create string to be used in the mail to victor}
             s1:='You took '+uyellow+commastr(player.gold)+config.textcol1+' '+many_money(player.gold)
              +' from the corpse.';
            end;
           end
           else if steal_potions then begin
            if player.healing>0 then begin
             {player is robbed of his potions}
             inc(pl0^.healing,player.healing);
             sd(global_plycol,pl0^.name2);
             d(12,' took your healing potions!');
             {create string to be used in the mail to victor}
             s1:='You took '+uwhite+commastr(player.healing)+config.textcol1+' potions from the corpse.';
            end;
           end;

           if steal_money then begin
            {News Paper}
            Newsy(true,
            'Thieves at the Dormitory!',
            ' '+ulred+player.name2+config.textcol1+' was caught trying to steal money from',
            ' '+uplc+pl0^.name2+config.textcol1+', who woke up and killed '+ulred+player.name2+config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
           end
           else if steal_potions then begin
            {News-Paper}
            Newsy(true,
            'Muggers at the Dormitory!',
            ' '+uplc+player.name2+config.textcol1+' was caught trying to steal Healing Potions from',
            ' '+uplc+pl0^.name2+config.textcol1+', who woke up and killed '+ulred+player.name2+config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
           end;

           if steal_money then begin
            {mail to victor}
            s:='Thieves!';
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+s+config.textcol1,
            mkstring(length(s),underscore),
            uplc+player.name2+config.textcol1+' tried to snatch your purse while you',
            'were sleeping. You woke up and fought '+sex[player.sex]+'!',
            ulred+player.name2+config.textcol1+' bled and died.',
            s1,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
           end
           else if steal_potions then begin
            {mail to victor}
            s:='Muggers!';
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+s+config.textcol1,
            mkstring(length(s),underscore),
            uplc+player.name2+config.textcol1+' tried to get away with your Healing Potions while you',
            'were sleeping. You woke up and fought '+sex[player.sex]+'!',
            ulred+player.name2+config.textcol1+' fell, bled and died.',
            s1,
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


           if steal_money then begin
            IncPlayermoney(pl0^,player.gold);

            player.gold:=0;
           end
           else if steal_potions then begin

            inc(pl0^.healing,player.healing);

            player.healing:=0;

           end;

           {update "killedby" variable in relations data file}
           killed_by_stats(pl0^,player);

           {save player}
           user_save(pl0^);

           d(config.textcolor,'You draw your last breath knowing your head will be put');
           d(config.textcolor,'on a pole outside the Town, to warn others from following');
           d(config.textcolor,'in your path...');
           pause;

           normal_exit;

          end
          else begin

           {offline player died}
           crlf;
           crlf;
           d(15,'Yippiie!');

           if steal_money then begin
            sd(config.textcolor,'You take ');
            sd(14,commastr(pl0^.gold));
            d(config.textcolor,' '+many_money(pl0^.gold)+' from the corpse.');
           end
           else if steal_potions then begin
            sd(config.textcolor,'You take ');
            sd(15,commastr(pl0^.healing));
            d(config.textcolor,' Healing Potions from the corpse.');
           end;

           {give some darkness points}
           x:=random(25)+20;

           sd(config.textcolor,'Your soul darkens for ');
           sd(15,commastr(x));
           d(config.textcolor,' points!');

           Give_Darkness(player,x);

           d(config.textcolor,'You quickly withdraw from the scene...');

           {News Paper}
           Newsy(true,
           'Murder at the Dormitory!',
           ' '+ulred+pl0^.name2+config.textcol1+' was found murdered in '+sex3[pl0^.sex]+' bed this morning!',
           ' The guests and staff at the Dorm are horrifed.',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           if steal_money then begin
            {mail to victor}
            s:='Thieves!';
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+s+config.textcol1,
            mkstring(length(s),underscore),
            uplc+player.name2+config.textcol1+' tried to snatch your purse while you',
            'were sleeping. You woke up and fought '+sex[player.sex]+'!',
            uplc+player.name2+config.textcol1+' killed you!',
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
           end
           else if steal_potions then begin
            {mail to victor}
            s:='Muggers!';
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+s+config.textcol1,
            mkstring(length(s),underscore),
            uplc+player.name2+config.textcol1+' tried to steal your Healing Potions while you',
            'were sleeping. You woke up and fought '+sex[player.sex]+'!',
            uplc+player.name2+config.textcol1+' killed you!',
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
           end;

           {update player vars}

           if steal_money then begin
            IncPlayerMoney(player,pl0^.gold);
            pl0^.gold:=0;
            pl0^.hps:=0;
           end
           else if steal_potions then begin
            Inc(player.healing,pl0^.healing);
            pl0^.healing:=0;
            pl0^.hps:=0;
           end;

           {update "killedby" variable in relations data file}
           killed_by_stats(player,pl0^);

           {update other player}
           user_save(pl0^);

           pause;

          end;

         end;

        end; {pick-pocket END}

    'M':begin {murder}
         if player.pfights<1 then begin
          d(config.textcolor,'Sorry, but you have run out of player fights.');
          pause;
         end
         else if player.darknr<1 then begin
          d(config.textcolor,'Sorry, but you have run out of Dark Deeds.');
          pause;
         end
         else begin
          clearscreen;
          d(12,'Dirty deed!');
          sd(config.textcolor,'You sneak up to ');
          sd(global_plycol,pl0^.name2+'s');
          d(config.textcolor,' bed and ready your weapon.');

          d(config.textcolor,sex2[pl0^.sex]+chr(39)+'s laying there sleeping like an innocent child.');
          crlf;

          d(config.textcolor,'Do you dare to try to kill '+sex[pl0^.sex]+
            ' in cold blood, while '+sex2[pl0^.sex]+chr(39)+'s asleep?');
          menu('(Y)eah, that '+race_display(2,pl0^.race,0)+chr(39)+'s a gonner!');
          menu('(C)hicken out');
          sd(config.textcolor,':');

          {get user-input}
          repeat
           cho:=upcase(getchar);
          until cho in ['Y','C'];

          x:=random(4);

          if (cho='Y') and (x<>0) then begin

           sd(config.textcolor,'Just before you reach ');
           sd(global_plycol,s);
           d(config.textcolor,', the foul creature wakes up and jumps');
           d(config.textcolor,'out of '+sex3[pl0^.sex]+' bed.');
           sd(global_talkcol,'So you don''t dare to face me in the open you COWARD! ');
           sd(global_plycol,s);
           d(config.textcolor,' screams.');
           d(config.textcolor,'Everybody in the dormitory is awake and gathered around you.');
           d(config.textcolor,'You realize that soon you will be fighting for your life.');
           crlf;
           crlf;

           {news-paper}
           newsy(true,
           'Attempted Murder!',
           ' The evil '+urac+race_display(2,player.race,0)+uplc+' '+player.name2+config.textcol1+' tried to murder '+uplc
            +pl0^.name2+config.textcol1+'!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           header:='Attempt on Your Life!';

           {Post mail to attempted murder victim}
           post(MailSend,
           pl0^.name2,
           pl0^.ai,
           false,
           mailrequest_nothing,
           '',
           umailheadc+header+config.textcol1,
           mkstring(length(header),underscore),
           uplc+player.name2+config.textcol1+' tried to murder you while you were sleeping!',
           'But you woke up just before the creep was about to strangle you!',
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

           pause;

           {worsen pl0:s attitude to player}
           Update_Relation(Relation_Worsen,2,pl0^,player,false,false);

           {darkness}
           dec(player.darknr);

           Give_Darkness(player,50);

           {teammate coming to the rescue?}
           team_rescue(pl0^);

           {player vs victim}
           player_vs_player(pl0^);

           player.gnollp:=0;
           x:=0;

          end
          else if (cho='Y') and (x=0) then begin

           d(7,'Evil Deed');
           show_usurper_data(picture_DEATH_HEAD,false);
           crlf;
           sd(config.textcolor,'You quickly strangle ');
           sd(global_plycol,s);
           d(config.textcolor,' and then leave the room before');
           d(config.textcolor,'anyone notice anything. As you leave the dormitory you');
           sd(config.textcolor,'hear screaming; ');
           sd(global_talkcol,'Murder! Murder! ');
           sd(global_plycol,s);
           d(config.textcolor,' has been murdered!"');
           d(config.textcolor,'You smile, and disappear out on the street...');
           crlf;
           pause;

           d(15,'** Successful Murder **');
           x:=random(75)*pl0^.level;
           sd(config.textcolor,'You receive ');
           sd(15,commastr(x));
           d(config.textcolor,' experience points for this vicious deed!');

           incplayerexp(player,x);

           x:=random(25)+20;

           sd(config.textcolor,'Your soul darkens for ');
           sd(15,commastr(x));
           d(config.textcolor,' hell points!');

           Give_Darkness(player,x);

           dec(player.darknr);

           {player.pfights:=player.pfights-1;}
           crlf;
           pause;
           crlf;

           {news-paper}
           newsy(true,
           'Murder!',
           ' Somebody put '+sex3[player.sex]+' hands around '+uplc+pl0^.name2+'s'+config.textcol1+' throat and squeezed!',
           ' Rumours has it that the '+urac+race_display(2,player.race,0)+uplc+' '
           +player.name2+config.textcol1+' had something to do with it!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {save offline player}
           pl0^.hps:=0;
           user_save(pl0^);

           if npcpunk=false then begin
            header:='Your Death';

            {mail opponent}
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+header+config.textcol1,
            mkstring(length(header),underscore),
            'You were murdered by '+uplc+player.name2+config.textcol1+'!',
            'It was a cowards deed! You were killed in your sleep!',
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

           end;
          end;
         end;
        end;

    'W':begin {Wake up and challenge}

         if player.pfights<1 then begin
          d(config.textcolor,'You have no player fights left.');
          crlf;
          pause;
         end
         else begin

          {teammate coming to rescue?}
          team_rescue(pl0^);

          crlf;
          crlf;
          d(7,'You kick '+uplc+s+ulgray+' out of '+sex3[pl0^.sex]+' bed and challenge '+sex[pl0^.sex]+'!');
          d(7,'"Wake up you sloppy pig! Time to die!" You scream in '+sex3[pl0^.sex]+' ear.');
          d(global_plycol,s+ulgray+' doesn''t seem to be very frightened of your threats.');
          d(7,sex2[pl0^.sex]+' grins as '+sex2[pl0^.sex]+' straps on '+sex3[pl0^.sex]+' equipment...');
          d(7,sex3[pl0^.sex]+' '+race_display(2,pl0^.race,0)+' buddies cheer when '
              +sex2[pl0^.sex]+' makes a couple of');

          if pl0^.rhand+pl0^.lhand>0 then begin
           d(7,'slick moves with '+sex3[pl0^.sex]+' weapon!');
          end
          else begin
           d(7,'kicks and punches to show you who''s the master!');
          end;
          crlf;
          pause;

          {worsen pl0:s attitude to player}
          Update_Relation(Relation_Worsen,2,pl0^,player,false,false);

          {the fight!}
          player_vs_player(pl0^);

          player.gnollp:=0;

         end;
        end;

   end; {case .end.}

   {remove shadow player, (sleeper) }
   add_shadow(SRemove,pl0^,'','',0);

  end; {for i:= .end.}

 end;

 {dispose pointer vars}
 dispose(pl0);

end; {Attack_Guest **END**}

Procedure Team_Rescue(var ply:UserRec);
var
    i,j,size : word;
    k,l : byte;
    mate : UserRec;
    s : s70;
    ok,begg : boolean;

    roster  : array[1..4] of s30; {keep plys team-mates}
    rosterx : array[1..4] of byte; {1=player file,2=npc file}
    rosternr: array[1..4] of word; {filex, position in file}

begin

 {player has attacked ply at the Dorm, should one of ply:s team-mates
  come to the rescue?}

 {init vars}
 for i:=1 to 4 do begin
  roster[i]   :='';
  rosterx[i]  :=0;
  rosternr[i] :=0;
 end; {for i:= .end.}

 if (random(2)<>0) or
    (ply.team='') or
    (ply.team=player.team) then begin
  {not this time!}
  exit;
 end;

 {look for plys team mates}
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end;

  for j:=1 to size do begin

   {load character}
   if load_character(mate,i,j)=true then begin

    {is this a team-mate}
    if (mate.team=ply.team) and
       (mate.king=false) and
       (mate.name2<>ply.name2) and
       (mate.name2<>player.name2) and
       (player_active(mate,true)=true) and
       (mate.location=offloc_dormitory) and
       (mate.allowed=true) then begin

     {fill roster}
     for k:=1 to 4 do begin
      if roster[k]='' then begin

       roster[k]  :=mate.name2;
       rosterx[k] :=i;
       rosternr[k]:=j;

       break;
      end;
     end; {for k:= .end.}

    end;
   end;

  end; {for j:= .end.}

  {we break out if member roster is filled}
  if (roster[1]<>'') and (roster[2]<>'') and
     (roster[3]<>'') and (roster[4]<>'') then begin
   break;
  end;

 end; {for i:= .end.}

 {count found members}
 k:=0;
 for i:=1 to 4 do begin
  if roster[i]<>'' then inc(k);
 end; {for i:= .end.}

 if k>0 then begin
  {randomly choose who's coming to the rescue}

  ok:=false;
  repeat

   j:=random(k)+1;

   l:=0;
   for i:=1 to 4 do begin
    if roster[i]<>'' then begin
     inc(l);

     if j=l then begin
      ok:=true;
      break;
     end;

    end;
   end; {for i:= .end.}

  until ok;

  {load mate}
  if load_character(mate,rosterx[j],rosternr[j])=true then begin

   if add_shadow(SAdd,mate,player.name2,'fighting '+uplc
                 +player.name2+config.textcol1+'!',0)=true then begin

    {where is }
    case random(7) of
     0: s:='under the bed!';
     1: s:='near the bed!';
     2: s:='in a closet!';
     3: s:='under the floor!';
     4: s:='in a basket!';
     5: s:='in a coffin!';
     6: s:='under the blanket!';
    end;

    {shit text}
    d(12,'Damn!');
    d(global_plycol,ply.name2+'s'+config.textcol1+' team-mate '+uplc+mate.name2+config.textcol1+' was hiding');
    d(config.textcolor,s+' Now you must fight '+sex[mate.sex]+' too!');
    pause;

    {player versus team-mate}
    repeat
     begg:=player_computer(player,mate,false,4);
    until (player.hps<1) or (mate.hps<1);

    {evaluate fight}
    if (player.hps<1) and (mate.hps<1) then begin
     {both died}

     {news-paper}
     newsy(true,
     'Friends',
     ' '+uplc+player.name2+config.textcol1+' stalked '+uplc+ply.name2+config.textcol1+' at the Dormitory.',
     ' '+uplc+ply.name2+config.textcol1+' was sleeping and would have been killed if it hadn''t',
     ' been for the brave '+uplc+mate.name2+config.textcol1+' who rushed to '+sex3[mate.sex]+' friend''s',
     ' rescue. Both the evil '+uplc+player.name2+config.textcol1+' and '+uplc+mate.name2+config.textcol1+' were killed.',
     '',
     '',
     '',
     '',
     '');

     {mail ply}
     s:='Assassination Attempt';
     post(MailSend,
     ply.name2,
     ply.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+s+config.textcol1,
     mkstring(length(s),underscore),
     uplc+player.name2+config.textcol1+' tried to kill you in your bed!',
     'Your friend '+uplc+mate.name2+config.textcol1+' fought the evil-doer!',
     'Both '+ulred+player.name2+config.textcol1+' and '+ulred+mate.name2+' were killed!',
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

     {mail mate}
     post(MailSend,
     mate.name2,
     mate.ai,
     false,
     mailrequest_nothing,
     '',
     umailheadc+'Team'+config.textcol1,
     mkstring(4,underscore),
     the_bad+uplc+player.name2+config.textcol1+' attacked your team-mate '+uplc+ply.name2+config.textcol1+' in the Dormitory!',
     'You engaged '+uplc+player.name2+config.textcol1+'!',
     'You killed '+uplc+player.name2+config.textcol1+'!',
     ulred+'Unfortunately you died of your wounds only moments later...'+config.textcol1,
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     {update "killedby" variable in relations data file}
     killed_by_stats(player,mate);
     killed_by_stats(mate,player);

     {save mate}
     user_save(mate);

     {exit preparations}
     d(12,'It''s dangerous to attack people who have friends...');
     d(12,'Darkness...');

     {player.allowed:=true;}
     reduce_player_resurrections(player,true);
     pause;
     normal_exit;

    end
    else if player.hps<1 then begin
     {player died}

     {news-paper}
     newsy(true,
     'Helping Hand',
     ' '+uplc+player.name2+config.textcol1+' stalked '+uplc+ply.name2+config.textcol1+' at the Dormitory.',
     ' '+uplc+ply.name2+config.textcol1+' was sleeping and would have been killed if it hadn''t',
     ' been for the brave '+uplc+mate.name2+config.textcol1+' who rushed to '+sex3[mate.sex]+' friend''s',
     ' rescue. The evil '+ulred+player.name2+config.textcol1+' was defeated!',
     '',
     '',
     '',
     '',
     '');

     {mail ply}
     s:='Assaulted!';
     post(MailSend,
     ply.name2,
     ply.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+s+config.textcol1,
     mkstring(length(s),underscore),
     uplc+player.name2+config.textcol1+' tried to kill you in your bed!',
     'Your friend '+uplc+mate.name2+config.textcol1+' fought the evil-doer!',
     ulred+player.name2+config.textcol1+' was killed!',
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

     {mail mate}
     post(MailSend,
     mate.name2,
     mate.ai,
     false,
     mailrequest_nothing,
     '',
     umailheadc+'Team'+config.textcol1,
     mkstring(4,underscore),
     the_bad+uplc+player.name2+config.textcol1+' attacked your team-mate '+uplc+ply.name2+config.textcol1+' in the Dormitory!',
     'You engaged '+uplc+player.name2+config.textcol1+'!',
     'You killed '+ulred+player.name2+config.textcol1+'!',
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

     {save mate}
     user_save(mate);

     {update "killedby" variable in relations data file}
     killed_by_stats(mate,player);

     {exit preparations}
     d(12,'It''s dangerous to attack people in teams...');
     d(12,'Darkness...');

     {player.allowed:=true;}
     reduce_player_resurrections(player,true);
     pause;
     normal_exit;

    end
    else begin
     {mate died}

     {news-paper}
     newsy(true,
     'Not enough',
     ' '+uplc+player.name2+config.textcol1+' stalked '+uplc+ply.name2+config.textcol1+' at the Dormitory.',
     ' '+uplc+ply.name2+config.textcol1+' was sleeping and would have been killed if it hadn''t',
     ' been for the brave '+uplc+mate.name2+config.textcol1+' who rushed to '+sex3[mate.sex]+' friend''s',
     ' rescue. Unfortunately '+ulred+mate.name2+config.textcol1+' was defeated.',
     '',
     '',
     '',
     '',
     '');

     {mail ply}
     s:='Assaulted!';
     post(MailSend,
     ply.name2,
     ply.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+s+config.textcol1,
     mkstring(length(s),underscore),
     uplc+player.name2+config.textcol1+' tried to kill you in your bed!',
     'Your friend '+uplc+mate.name2+config.textcol1+' fought the evil-doer!',
     'Unfortunately '+ulred+mate.name2+config.textcol1+' was butchered!',
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

     {mail mate}
     post(MailSend,
     mate.name2,
     mate.ai,
     false,
     mailrequest_nothing,
     '',
     umailheadc+'Team'+config.textcol1,
     mkstring(4,underscore),
     the_bad+uplc+player.name2+config.textcol1+' attacked your team-mate '+uplc+ply.name2+config.textcol1+' in the Dormitory!',
     'You engaged '+uplc+player.name2+config.textcol1+'!',
     'You were butchered!',
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

     {save mate}
     user_save(mate);

     {update "killedby" variable in relations data file}
     killed_by_stats(player,mate);

     {remove offline player}
     add_shadow(SRemove,mate,'','',0);
    end;

   end;

  end;

 end;

end; {Team_Rescue **END*}

Function Player_Active (const pl:userrec; const hps_req:boolean) : boolean;
{returns true if pl is alive and not deleted}
var result : boolean;
begin

 if (pl.name1<>global_delname1) and
    (pl.name2<>global_delname2) and
    (pl.name2<>'') and
    (pl.name1<>'') and
    (pl.deleted=false) then begin

  result:=true;
  if (hps_req) and (pl.hps<1) then result:=false;

 end
 else begin
  result:=false;
 end;

 {return result}
 player_active:=result;
end; {player_active *end*}

Procedure Init_Bard_Song_Data(var Bardsong:Bardtype);
var i : byte;
begin

 for i:=1 to global_bardlines do begin
  bardsong[i]:='';
 end;

end; {init_bard_song_data *end*}

Function config_nr(const nr:word) : s70;
var result : s70;
begin
 {used by the "display settings routines"}

 {ulgray,udgray}

 result:=udgray+'  (#'+commastr(nr)+')';

 {return result}
 config_nr:=result;

end; {config_nr}

Procedure Settings_Relations;
begin

 crlf;
 crlf;
 settings_header('relations');

 {npc relations activated, duplicated in NPC settings}
 d(config.textcolor,'Player Relations are activated.');
 if Config.AllowNpcMarry=true then begin
  sd(config.textcolor,'NPC Relations are activated (they can marry and have kids).');
 end
 else begin
  sd(config.textcolor,'NPC Relations are currently '+ulred+'DISABLED'+config.textcol1+'.');
 end;
 d(2,config_nr(153));

 {minimum age to marry, default is 18}
 sd(config.textcolor,'Minimum age to Marry is '+setcol+commastr(config.MinimumAgetoMarry)+config.textcol1+'.');
 d(2,config_nr(166));

 {acts of intimacy/day a player has}
 sd(config.textcolor,'Players have '+setcol+commastr(config.IntimacyActs)+config.textcol1+' Intimacy acts per day.');
 d(2,config_nr(189));

 {homo/bi relations allowed}
 if config.allowhomorelations=false then begin
  sd(config.textcolor,'Homo/Bi relations are '+ulred+'NOT'+config.textcol1+' allowed.');
 end
 else begin
  sd(config.textcolor,'Homo/Bi relations are allowed'+config.textcol1+'.');
 end;
 d(2,config_nr(190));


 {Adult Options YES/no}
 if config.allowadultoptions=false then begin
  sd(config.textcolor,'Adult Options are '+ulred+'NOT'+config.textcol1+' allowed.');
 end
 else begin
  sd(config.textcolor,'Adult Options are allowed'+config.textcol1+'.');
 end;
 d(2,config_nr(194));


 {put moodswings in the news? 0=no,1=yes}
 if config.RelationChangesNews=1 then
  sd(config.textcolor,'Relation changes between players are logged in the News.')
 else sd(config.textcolor,'Relation changes between players are '+ulred+'not'+config.textcol1+' logged in the News.');
 d(2,config_nr(173));

 {# human of children allowed}
 sd(config.textcolor,'Human players are allowed to have a maximum of '+setcol+commastr(config.MaxHumanChildren)
  +config.textcol1+' children.');
 d(2,config_nr(174));

 {# of npc children allowed **this display is duplicated in settings_npc}
 sd(config.textcolor,'NPCs are allowed to have a maximum of '+setcol+commastr(config.MaxNPCChildren)
  +config.textcol1+' children.');
 d(2,config_nr(175));


end; {settings_relations .end.}

Procedure Settings_Home;
begin
 crlf;
 crlf;
 settings_header('home');

 {items allowed in home}
 sd(config.textcolor,'Player can store '+setcol+commastr(config.homeitems)+config.textcol1+' items at Home.');
 d(2,config_nr(197));


end; {settings_home .end.}

Procedure Settings_Immortals;
begin

 crlf;
 crlf;
 settings_header('immortals');

 d(config.textcolor,'The Gods are activated.');

 {log immortal entries in the news}
 if config.log_divine_entrance then begin
  sd(config.textcolor,'Immortal entries are logged in the News.');
 end
 else begin
  sd(config.textcolor,'Immortal entries are '+ulred+'NOT'+config.textcol1+' logged in the News.');
 end;
 d(2,config_nr(164));

end; {settings_immortals *end*}

Procedure Settings_Team;
begin

 crlf;
 crlf;
 settings_header('team');

 {team fights per day, #13}
 sd(config.textcolor,'Team Fights allowed every day is '+setcol+cfg_string(13));
 d(2,config_nr(13));

 {allow teammates to attack each other, #35}
 if upcasestr(cfg_string(35))='YES' then begin
  sd(config.textcolor,'Team-mates are allowed to attack each other in single combat');
 end
 else begin
  sd(config.textcolor,'Team-mates are not allowed to attack each other in single combat');
 end;
 d(2,config_nr(35));

 {allow resurrection of team-mates?, #36}
 if upcasestr(cfg_string(36))='YES' then begin
  sd(config.textcolor,'Resurrection of Team-mates is allowed');
 end
 else begin
  sd(config.textcolor,'Resurrection of Team-mates is not allowed');
 end;
 d(2,config_nr(36));

 {allow Npcs to create teams?, #42 DUPLICATED in NPCS}
 if upcasestr(cfg_string(42))='YES' then begin
  sd(config.textcolor,'NPCs are allowed to form teams');
 end
 else begin
  sd(config.textcolor,'NPCs are not allowed to form teams');
 end;
 d(2,config_nr(42));

 {allow teams to fight in the dungeons?, #47  DUPLICATED in dungeons}
 if upcasestr(cfg_string(47))='YES' then begin
  sd(config.textcolor,'Teams are allowed to fight in the Dungeons');
 end
 else begin
  sd(config.textcolor,'Teams are not allowed to fight in the Dungeons');
 end;
 d(2,config_nr(47));

 {team difficulty in dungeons 1..20, #48}
 sd(config.textcolor,'Team difficulty in the Dungeons is '+setcol+cfg_string(48)+config.textcol1+' (1-20, default is 5)');
 d(2,config_nr(48));

 {town reward, #89}
 {cfg_string(89); makes no sense showing this..would give a false impression
  of what players get}

 {allow NPC teams to attack other teams, #94  DUPLICATED in npcs}
 if upcasestr(cfg_string(94))='YES' then begin
  sd(config.textcolor,'NPC Teams are allowed to challenge other teams.');
 end
 else begin
  sd(config.textcolor,'NPC Teams are not allowed to challenge other teams.');
 end;
 d(1,config_nr(94));

end; {settings_team .end.}

Procedure Settings_King;
var
    s : s30;
begin

 crlf;
 crlf;
 settings_header('royal');

 {Usurp the Throne, Level needed}
 if config.minlevelking=0 then begin
  sd(config.textcolor,'Nobody is allowed to become King or Queen.');
 end
 else begin
  sd(config.textcolor,'To become King you must be at least a level ');
  sd(setcol2,commastr(config.minlevelking));
  sd(config.textcolor,' character.');
 end;
 d(2,config_nr(121));

 {Usurp the Throne, soul needed}
 case config.soulneededking of
  1: sd(config.textcolor,'To become King you must be '+setcol+'GOOD'+config.textcol1+'.');
  2: sd(config.textcolor,'To become King you must be '+setcol+'EVIL'+config.textcol1+'.');
  3: sd(config.textcolor,'To become King you can be '+setcol+'GOOD'+config.textcol1+' or '+setcol+'EVIL'+config.textcol1+'.');
 end; {case .end.}
 d(2,config_nr(122));


 {put public opinion polls of the royals in the news?}
 if Config.Print_KingPolls then begin
  sd(config.textcolor,'Player opinions of the Royals are printed in the News.');
 end
 else begin
  sd(config.textcolor,'Player opinions of the Royals are '+ulred+'NOT'+config.textcol1+' printed in the News.');
 end;
 d(2,config_nr(158));

 {resurrect the King when castle is infiltrated?}
 if Config.ResurrectTheKing then begin
  sd(config.textcolor,'The King is resurrected when his Castle is attacked.');
 end
 else begin
  sd(config.textcolor,'The King is '+ulred+'NOT'+config.textcol1+' resurrected when his Castle is infiltrated.');
 end;
 d(2,config_nr(149));

 {allow the king to imprison players}
 if Config.allowKingToImprison=0 then begin
  sd(config.textcolor,'The King is '+ulred+'NOT'+config.textcol1+' allowed to imprison players.');
 end
 else begin
  sd(config.textcolor,'The King is allowed to imprison players for '+setcol+commastr(config.allowkingtoimprison)
   +config.textcol1+' day(s).');
 end;
 d(2,config_nr(138));

 {allow the King to close shops}
 if config.AllowCloseShops then begin
  sd(config.textcolor,'The King is allowed to open and close Shops.');
 end
 else begin
  sd(config.textcolor,'The King is '+ulred+'NOT'+config.textcol1+' allowed to open and close Shops.');
 end;
 d(2,config_nr(151));


 {allow the King to "take away" a child from its parents and place it in the
  Royal Orphanage}
 if config.allowroyaladoption>1 then s:=' children'
                                else s:=' child';

 if config.AllowRoyalAdoption=0 then begin
  sd(config.textcolor,'The King is '+ulred+'NOT'+config.textcol1+' allowed to place Children in the Royal Orphanage.');
 end
 else begin
  sd(config.textcolor,'The King can place '+setcol+commastr(config.allowroyaladoption)+config.textcol1
   +s+' in the Royal Orphanage per day.');
 end;
 d(2,config_nr(185));

 {allow the king to feed the wolves with X children per day}
 if config.allowfeedingthewolves>1 then s:=' children'
                                   else s:=' child';

 if Config.allowFeedingTheWolves=0 then begin
  sd(config.textcolor,'The King is '+ulred+'NOT'+config.textcol1+' allowed to toss children to the Wolves.');
 end
 else begin
  sd(config.textcolor,'The King is allowed to toss '+setcol+commastr(config.allowfeedingthewolves)+config.textcol1
   +s+' to the Wolves every day.')
 end;
 d(2,config_nr(183));

 {allow the king to Ban and Dissolve X Relationships per day}
 if Config.MarryActionsPerDay=0 then begin
  sd(config.textcolor,'The King is '+ulred+'NOT'+config.textcol1+' allowed to Ban or Dissolve marriages.');
 end
 else begin
  sd(config.textcolor,'The King can ban and dissolve '+setcol+commastr(config.marryactionsperday)+config.textcol1
   +' marriages every day.')
 end;
 d(2,config_nr(184));

 {(#182) allow npc to usurp throne, duplicated in settings_npc}
 if Config.AllowNpcUsurping=true then begin
  sd(config.textcolor,'NPCs are allowed to usurp the Royal Throne.');
 end
 else begin
  sd(config.textcolor,'NPCs are '+ulred+'NOT'+config.textcol1+' allowed to usurp the Royal Throne.');
 end;
 d(2,config_nr(182));



end; {settings_king *end*}


Procedure Settings_Miscellaneous;
begin

 crlf;
 crlf;
 settings_header('miscellaneous');

 {Game mode}
 if config.classic then sd(config.textcolor,config.textcol1+'Usurper is running in '+setcol+'CLASSIC'
                          +config.textcol1+' mode.')
 else sd(config.textcolor,config.textcol1+'Usurper is running in '+setcol+'NEW'
         +config.textcol1+' mode.');
 d(2,config_nr(91));


 {Punishment for dropping carrier}
 case Config.PunishCarrierDroppers of
  0: sd(config.textcolor,'Players are not punished for dropping carrier in fights');
  1: sd(config.textcolor,'Players are punished for dropping carrier in fights');
 end; {case .end.}
 d(2,config_nr(152));

 {x days of inactivity deletes player}
 sd(config.textcolor,'Players are deleted after '+setcol+cfg_string(7)+config.textcol1+' days of inactivity');
 d(2,config_nr(7));

 {days to keep unread mail}
 sd(config.textcolor,'Unread mail is deleted after '+setcol+commastr(config.maxmail)+config.textcol1+' day(s)');
 d(2,config_nr(4));

 {days to keep items in player market}
 sd(config.textcolor,'Items at Player Market are deleted after '+setcol+commastr(config.maxmarket)+config.textcol1+' day(s)');
 d(2,config_nr(3));

 {player resurrections}
 sd(config.textcolor,'Players have '+setcol+commastr(config.resurrections)+config.textcol1+' resurrections every day.');
 d(2,config_nr(191));

 {pick-pocket attempts # day}
 sd(config.textcolor,'Players have '+setcol+commastr(config.pickpocketattempts)+config.textcol1
                              +' Pick-Pocket attempts every day.');
 d(2,config_nr(195));


 {bank robbery attempts # day}
 sd(config.textcolor,'Players have '+setcol+commastr(config.bankrobberyattempts)+config.textcol1
                              +' Bank Robbery attempts every day.');
 d(2,config_nr(198));


end; {settings_miscellaneous .end.}

Procedure Settings_Dungeons;
begin

 crlf;
 crlf;
 settings_header('dungeons');

 {Dungeon Difficulty, (#10)}
 sd(config.textcolor,'Dungeon Difficulty is ');
 sd(setcol2,cfg_string(10));
 d(config.textcolor,' (1 easy...5 medium...10 hard)'+config_nr(10));

 {dungeon fights per day, (#6)}
 d(config.textcolor,'Players have '+setcol+cfg_string(6)+config.textcol1+' dungeon fights every day'+config_nr(6));

 {allow teams to fight in the dungeons?, (#47)  DUPLICATED in teams}
 if upcasestr(cfg_string(47))='YES' then begin
  d(config.textcolor,'Teams are allowed to fight in the Dungeons'+config_nr(47));
 end
 else begin
  d(config.textcolor,'Teams are not allowed to fight in the Dungeons'+config_nr(47));
 end;

 {Quaffing healing potions option, in the dungeons 1-3,  (#22)}
 crlf;
 d(config.textcolor,'Quaffing Healing Potions in the Dungeons :'+config_nr(22));

 case config.quaffopt of
  1: d(config.textcolor,' Player quaffs potions and then auto-attacks.');
  2: d(config.textcolor,' Player quaffs potions and then monster attacks.');
  3: d(config.textcolor,' Player quaffs potions and then chose option.');
 end;


end; {settings_dungeons .end.}

Procedure Settings_npcs; {display computer player settings}
begin

 crlf;
 crlf;
 settings_header('computer players (npcs)');


 {(#8) npcs are vicious 0.passive 1.random 2.annoying 3.persecution}
 sd(config.textcolor,'NPCs are set to be ');
 if cfg_string(8)='0' then d(setcol2,'passive')
 else if cfg_string(8)='1' then sd(setcol2,'randomly disturbing')
 else if cfg_string(8)='2' then sd(setcol2,'annoying')
 else if cfg_string(8)='3' then sd(setcol2,'aggressive')

 else begin
  sd(setcol2,'passive');
 end;
 d(1,config_nr(8));


 {allow Npcs to create teams?, #42 DUPLICATED in TEAMS!!}
 if upcasestr(cfg_string(42))='YES' then begin
  d(config.textcolor,'NPCs are allowed to form teams'+config_nr(42));
 end
 else begin
  d(config.textcolor,'NPCs are not allowed to form teams'+config_nr(42));
 end;

 {allow NPC teams to attack other teams, #94  DUPLICATED in teams}
 if upcasestr(cfg_string(94))='YES' then begin
  sd(config.textcolor,'NPC Teams are allowed to challenge other teams');
 end
 else begin
  sd(config.textcolor,'NPC Teams are not allowed to challenge other teams');
 end;
 d(1,config_nr(94));

 {(#153) npc relations activated, duplicated in Relations settings}
 if Config.AllowNpcMarry=true then begin
  sd(config.textcolor,'NPC Relations are activated (they can marry and have kids).');
 end
 else begin
  sd(config.textcolor,'NPC Relations are currently DISABLED.');
 end;
 d(1,config_nr(153));

 {(#175) npc children allowed **this display is duplicated in
  settings_relations}
 d(config.textcolor,'NPCs are allowed to have a maximum of '+setcol+commastr(config.MaxNPCChildren)
  +config.textcol1+' children.'+config_nr(175));

 {(#182) allow npc to usurp throne, duplicated in settings_king}
 if Config.AllowNpcUsurping=true then begin
  sd(config.textcolor,'NPCs are allowed to usurp the Royal Throne.');
 end
 else begin
  sd(config.textcolor,'NPCs are '+ulred+'NOT'+config.textcol1+' allowed to usurp the Royal Throne.');
 end;
 d(2,config_nr(182));

 {(#186) allow npcs to believe in GODs}
 if Config.NPCBelievers=true then begin
  sd(config.textcolor,'NPCs are allowed to have faith. They will interact with the Gods.');
 end
 else begin
  sd(config.textcolor,'NPCs are '+ulred+'NOT'++config.textcol1++' allowed to interact with the Gods.');
 end;
 d(1,config_nr(153));


 crlf;

end; {settings_npcs .end.}

Procedure Settings_System; {display tech-settings}
begin
 crlf;
 crlf;
 settings_header('system');

 {Node}
 d(config.textcolor,'You are running on Node '
   +setcol+global_cnode);

 {registered}
 if global_registered then begin
  d(config.textcolor,'Game is registered to '+setcol+cfg_string(1)+config.textcol1
    +' and '+setcol+cfg_string(2));
 end
 else begin
  d(config.textcolor,'This is a '+ulred+'Unregistered'+config.textcol1+' copy');
 end;

 {Share}
 if global_ushare then d(setcol2,'SHARE'+config.textcol1+' is loaded. Filesharing routines are active');

 {Doordriver in user}
 d(config.textcolor,'Doordriver detected is '+setcol+'DDPLUS 7.1');

 {Multi Node Processing every X second}
 if config.multicheck>0 then begin
  sd(config.textcolor,'Multi-Node activity is processed every '+setcol+commastr(config.multicheck)
    +config.textcol1+' second.');
 end
 else begin
  sd(config.textcolor,'Multi-Node processing has been '+ulred+'DISABLED.');
 end;
 d(2,config_nr(98));

 {disconnected after X minutes of inactivity, (#178)}
 if config.inactivity>0 then begin
  sd(config.textcolor,'Players are disconnected after '+setcol+commastr(config.inactivity)+config.textcol1
   +' minutes of inactivity.');
 end
 else begin
  sd(config.textcolor,'Players are '+ulred+'NOT'+config.textcol1+' disconnected for inactivity.');
 end;
 d(1,config_nr(178));

 {LockMethod}
 sd(config.textcolor,'LockMethod used is ');
 case config.netshareMethod of
  Filelocking  : sd(setcol2,'File locking.');
  Recordlocking: sd(setcol2,'Record locking.');
 end;
 d(2,config_nr(139));

 {Lock-Delay}
 sd(config.textcolor,'Delay between File/Record-Locking attempts is '
   +setcol+commastr(Config.LockDelay)+config.textcol1+' milliseconds.');
 d(2,config_nr(140));

{$IFDEF MSDOS}
 {EMS/XMS}
 if over_ems then d(setcol2,'EMS'+config.textcol1+' memory utilized for speed.');
 if over_xms then d(setcol2,'XMS'+config.textcol1+' memory utilized for speed.');
{$ENDIF}

 {memory availible}
 d(config.textcolor,'Free Memory Available in the Heap: '+setcol+commastr(memavail));
 crlf;
end; {system_tech .end.}

Procedure Display_Game_Settings; {display game settings - view/edit mode}
var                              {called from usurper.pas}
    ch : char;

    s : s90;



begin

 ch:='?';
 repeat

  if ch='?' then begin
   clearscreen;

   s:=' Usurper Game Settings ';
   d(5,cool_string(length(s),'=','-',5,10));
   d(3,s);
   d(5,cool_string(length(s),'=','-',5,10));
   crlf;

   menu2('(S)ystem    ');
   menu2('(I)mmortals  ');
   menu('(H)ome');

   menu2('(D)ungeon   ');
   menu('(K)ing');

   menu2('(R)elations ');
   menu('(M)iscellaneous');

   menu2('(T)eam      ');
   menu('(C)omputer players');

   menu('(Q)uit');
  end;

  crlf;
  sd(config.textcolor,'Game Settings ('+config.textcol2+'?'+config.textcol1+' for menu) :');


  {get user-input}
  ch:=upcase(getchar);

  case ch of
   'S':begin {system info}
        settings_system;
       end;

   'H':begin {home}
        settings_home;
       end;
   'M':begin {miscellaneous}
        settings_miscellaneous;
       end;

   'C':begin {computer players/npcs}
        settings_npcs;
       end;

   'T':begin {team}
        settings_team;
       end;

   'D':begin {dungeons}
        settings_dungeons;
       end;

   'K':begin {king}
        settings_king;
       end;

   'R':begin {relations}
        settings_relations;
       end;

   'I':begin {Immortals}
        settings_immortals;
       end;

  end; {case .end.}

 until ch='Q';

end; {display_game_settings *end*}

Procedure List_of_Prisoners; {displays list_of_prisoners in Royal Castle}
var {called from prisonf.pas and godworld.pas}

    i, j, k, size, x  : word;
    line_counter : byte;

    abort : boolean;

    daystr : string[4];

    prisoner : userrec;

begin

 d(5,'Prisoners');
 d(5,mkstring(9,underscore));

 k:=0;
 line_counter:=2;
 abort:=false;
 for i:=1 to 2 do begin

  size:=1;
  case i of
   1: size:=fs(fsplayer);
   2: size:=fs(fsnpc);
  end;

  for j:=1 to size do begin

   load_character(prisoner,i,j);

   if (prisoner.name2<>player.name2) and
      (player_active(prisoner,false)=true) and
      (prisoner.location=offloc_prison) and
      (prisoner.name2<>'') then begin

    inc(k);

    sd(global_plycol,prisoner.name2);
    sd(config.textcolor,' the '+race_display(2,prisoner.race,0));

    if is_online(prisoner.name2,online_player) then begin
     sd(14,' (awake)');
    end
    else if prisoner.hps<1 then begin
     sd(config.textcolor,' ('+ulred+'dead'+config.textcol1+')');
    end
    else begin
     sd(config.textcolor,' (sleeping)');
    end;

    {days left in prison}
    x:=prisoner.daysinprison;
    if x=0 then x:=1;
    if x=1 then daystr:='day'
           else daystr:='days';

    d(config.textcolor,' ('+uwhite+commastr(x)+config.textcol1+' '+daystr+' left)');

    inc(line_counter);
    if line_counter>global_screenlines-2 then begin
     line_counter:=0;
     if confirm('Continue','Y')=false then begin
      abort:=true;
     end;
    end;

   end;

   if abort then break;
  end; {for j:= .end.}
  if abort then break;
 end; {for i:= .end.}

 if (k=0) and (abort=false) then begin
  d(12,'No prisoners here right now!');
 end;

end; {list_of_prisoners .end.}

Procedure Reduce_Player_Resurrections;
var res : s20;
begin
 {decreases player PLYs ressurections. if TYPEINFO is TRUE then display how}

 {many ressurections are left}
 if ply.resurrections>0 then begin
  dec(ply.resurrections);
 end;

 if ply.resurrections<1 then begin
  ply.allowed:=false;
 end;

 if typeinfo then begin
  if ply.resurrections=1 then begin
   res:='resurrection';
  end
  else begin
   res:='resurrections';
  end;

  d(config.textcolor,'You have '+uwhite+commastr(ply.resurrections)+config.textcol1+' '+res+' left today.');
 end;

end; {reduce_player_resurrections .end.}


Function Empty_QuestSlot : longint;
var i : longint;
    AQuest : QuestRec;
    saved : boolean;
begin

 {find a deleted record in Quest-file}

 saved:=false;
 empty_questslot:=1;

 for i:=1 to fs(FsQuest) do begin

  {load quest}
  load_quest(Fload,aquest,i);

  {is quest deleted?}
  if aquest.deleted=true then begin
   empty_questslot:=i;
   saved:=true;
   break;
  end;

 end; {for i:= .end.}

 {no empty quest-slot found, we place the quest at the end of file}
 if NOT saved then begin
  Empty_QuestSlot:=fs(FsQuest)+1;
 end;

end; {empty_questslot *end*}


Procedure Add_Quest(var quest:QuestRec); {adds a quest to the data-base}
begin
 Load_Quest(fsave,quest,Empty_QuestSlot);
end;



end. {Unit Various3 .end.}
