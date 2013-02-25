{$IFNDEF MSDOS}
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


Unit Gym; {Usurper - the Gym}

Interface

Uses Init;

type BarrelRec = Record {Barrel Lifter top list, record structure}
      name   : s30; {player name}
      id     : s15; {player id}
      level  : longint; {player level}
      race   : races;  {player race}
      class  : classes; {player class}
      deleted: boolean; {has record been deleted}
      datee  : udate; {date when record was set}
      barrels: SmallWord; {how many barrels did player lift}
     end;

const gymcol = ulcyan; {color to use when displaying "The Gym"}

{-visiting the gym-}
Procedure The_Gym;

{-taking over the gym-}
Procedure Take_Over_The_Gym(const gym_owners : s30);
Function Gym_Owning_Team : s40; {team controlling the Gym}

{-barrel masters-}
Procedure Init_Barrel_Master(var barrel_guy:barrelRec);

Implementation

Uses Cms, Jakob, News,
     Various, Various2, Various3,
     Statusc, Spellsu, Relation,
     Mail, Online, File_Io;

const local_place = 'The Gym';
           oilcol = ubrown; {massage oil color}

const tugdesc = 'Tug of War competition'; {this will show as status in the
                 "doing online" descriptive text...in the 'whos online' list}

var
    refresh : boolean;

Procedure Init_Barrel_Master(var barrel_guy:barrelRec);
begin {change in file_io.pas if you decide to change struct here}

 with barrel_guy do begin
  name   :='';
  id     :='';
  level  :=1;
  race   :=human;
  class  :=Warrior;
  deleted:=true;        {has record been deleted?}
  datee  :=todays_date; {date}
  barrels:=0;           {how many barrels did player lift}
 end; {with .end.}

end; {init_barrel_master *end*}

Function Barrel_Fame_Rating(name,id : s30;
                            level : longint;
                            ply_race : races;
                            ply_class : classes;
                            lifted : word) : integer;
var
    i,
    result : word;

    go_on,
    replace_old_score : boolean;

    {an array of barrel champions!}
    barrel_star : array[1..global_maxbarrelmasters+1] of BarrelRec;

procedure sort_barrel_masters; {sort routine}
var gap,i,j,k : integer;
    temp_barrel : barrelRec;
begin

 {sort classes}
 gap:=global_maxbarrelmasters+1;
 while gap>0 do begin
  for i:=(gap+1) to global_maxbarrelmasters+1 do begin
   j:=i-gap;
   while (j>0) do begin
    k:=j+gap;
    if barrel_star[j].barrels>=barrel_star[k].barrels then begin
     j:=0;
    end
    else begin
     temp_barrel:=barrel_star[j];
     barrel_star[j]:=barrel_star[k];
     barrel_star[k]:=temp_barrel;
     j:=j-gap;
    end;
   end;
  end; {for i:= .end.}
  gap:=gap div 2;
 end; {while .end.}

end; {sort_barrel_masters *end*}

var counter : word;
begin

 {does "name" qualify to the "barrel hall of fame"? result=rank place}
 result:=0;

 {init}
 for i:=1 to global_maxbarrelmasters+1 do begin
  init_barrel_master(barrel_star[i]);
 end;

 for i:=1 to fs(fsbarrel) do begin
  if i>global_maxbarrelmasters then break;
  load_barrel(fload,barrel_star[i],i);
 end; {for i:= .end.}

 {check if player already exists on the fame list}
 go_on:=true;
 replace_old_score:=false;
 for i:=1 to global_maxbarrelmasters do begin
  if (barrel_star[i].name=name) and
     (barrel_star[i].id=id) then begin
   if barrel_star[i].barrels>=lifted then begin
    go_on:=false;
   end
   else begin
    {replace players old score with his new score}
    replace_old_score:=true;
    barrel_star[i].barrels:=lifted;
    barrel_star[i].datee:=todays_date;
   end;
  end;
  if (go_on=false) or (replace_old_score=true) then break;
 end; {for i:= .end.}

 if (go_on=true) and (replace_old_score=false) then begin
  i:=global_maxbarrelmasters+1;
  barrel_star[i].name:=name;
  barrel_star[i].id     :=id;
  barrel_star[i].level  :=level;
  barrel_star[i].race   :=ply_race;
  barrel_star[i].class  :=ply_class;
  barrel_star[i].deleted:=false; {has record been deleted}
  barrel_star[i].datee  :=todays_date; {date}
  barrel_star[i].barrels:=lifted; {how many barrels}
 end;

 if go_on=true then begin
  {sort array}
  sort_barrel_masters;
  {did player qualify?}
  for i:=1 to global_maxbarrelmasters do begin
   if (barrel_star[i].name=name) and
      (barrel_star[i].id=id) then begin
    result:=i;
    break;
   end;
  end; {for i:= .end.}

  {write array to disk?}
  if result>0 then begin
   counter:=0;

   for i:=1 to global_maxbarrelmasters do begin
    if (barrel_star[i].name<>'') and (barrel_star[i].barrels>0) then begin
     inc(counter);
     load_barrel(fsave,barrel_star[i],counter);
    end;
   end; {for i:= .end.}

  end;

 end;

 {return result}
 barrel_fame_rating:=result;

end; {barrel_fame_rating *end*}


Procedure Tug_of_War; {two teams pulling each end of a rope}
{ we use the constant global_maxteammembers to set maximum crew }
type TugofWarRec = Record {Tug-of-War participant}
      name    : s30; {name}
      ai      : char; {ai}
      filtyp  : byte; {filtyp (1,2)}
      recnr   : SmallWord; {record #}
      id      : s15; {id}
      team    : s30; {teamname}
      strength: SmallWord; {strength}
      {when you change this structure..don't forget initialize functions
       and swap routine!}
     end;

var

    {team arrays, note that the mail postings need to be modified when
     global_maxteammembers change}
    home_team : array[1..global_maxteammembers] of TugOfWarRec;
    away_team : array[1..global_maxteammembers] of TugOfWarRec;

    temp : userrec;


Procedure Init_Tug_Member(var member:TugOfWarRec; const plu:userrec);
begin {sets up a tug-of-war competitor with data from plu userrec}
 member.name    :=plu.name2;
 member.ai      :=plu.ai;
 member.filtyp  :=plu.filtyp;
 member.recnr   :=plu.recnr;
 member.id      :=plu.id;
 member.team    :=plu.team;
 member.strength:=plu.strength;
end; {init_tug_member *end*}

Procedure Init_Teams(const which:byte);
var                 {1=init home team, 2=away team, 3=both}
     i : byte;
begin

 for i:=1 to global_maxteammembers do begin

  if which in [1,3] then begin
   {home team}
   home_team[i].name:='';
   home_team[i].ai:='C';
   home_team[i].filtyp:=1;
   home_team[i].recnr:=1;
   home_team[i].id:='';
   home_team[i].team:='';
   home_team[i].strength:=0;
  end;

  if which in [2,3] then begin
   {away team}
   away_team[i].name:='';
   away_team[i].ai:='C';
   away_team[i].filtyp:=1;
   away_team[i].recnr:=1;
   away_team[i].id:='';
   away_team[i].team:='';
   away_team[i].strength:=0;
  end;

 end; {for i:= .end.}

 if which in [1,3] then begin
  init_tug_member(home_team[1],player);
 end;

end; {init_teams *end*}

Function Add_Tug_Participant(const team:byte; const ply:userrec) : boolean;
var
   result : boolean;
   k : byte;
begin

 {init}
 result:=false;

 for k:=1 to global_maxteammembers do begin

  case team of
   1:begin
      if home_team[k].name='' then begin
       {put ply in team-array}
       init_tug_member(home_team[k],ply);
       result:=true;
       break;
      end;
     end;
   2:begin
      if away_team[k].name='' then begin
       {put ply in team-array}
       init_tug_member(away_team[k],ply);
       result:=true;
       break;
      end;
     end;
  end; {case .end.}

 end; {for k:= .end. }

 {return result}
 Add_Tug_Participant:=result;

end; {Add_Tug_Participant .end.}

Procedure Remove_Tug_Team(const hometeam:boolean;leavinggym:byte);
 {leavinggym=1, leaving without competing
            =2, leaving after a draw
            =3, leaving after a win
            =4, leaving after a lost }

var ii : byte;
    first_mess : boolean;

procedure first_message;
begin
 if not first_mess then begin
  first_mess:=true;
  d(11,'Removing Team-Members');
 end;
end;


procedure random_goodbye;
begin

 if leavinggym>0 then begin
  {leavinggym=1, leaving without competing
            =2, leaving after a draw
            =3, leaving after a win
            =4, leaving after a lost }
  case leavinggym of
   1: d(global_plycol,temp.name2+config.textcol1+' left the Gym.');
   2: d(global_plycol,temp.name2+config.textcol1+' left the Gym, not really satisfied with the result.');
   3: d(global_plycol,temp.name2+config.textcol1+' left the Gym triumphantly!.');
   4: d(global_plycol,temp.name2+config.textcol1+' left the Gym in tears.');
  end; {case .end.}
 end
 else begin
  case random(4) of
   0: d(global_plycol,temp.name2+config.textcol1+' left the Gym.');
   1: d(global_plycol,temp.name2+config.textcol1+' was kicked out!');
   2: d(global_plycol,temp.name2+config.textcol1+' left the Gym '+ulred+'frustrated!');
   3: d(global_plycol,temp.name2+config.textcol1+' swears to get back at you for this!');
   4: d(global_plycol,temp.name2+config.textcol1+' left the Gym feeling '+ulred+'rejected!');
  end;
 end;

end; {random_goodbye *end*}

var counter : byte;
begin

 first_mess:=false;
 counter:=0;

 {remove home/away team players. They are removed ONLINE and from TUG-TEAMS}
 for ii:=1 to global_maxteammembers do begin

  if (hometeam=true) and (home_team[ii].name<>'') and (ii>1) then begin
   first_message;
   temp.name2:=home_team[ii].name;
   add_shadow(SRemove,temp,'','',0);
   random_goodbye;
   home_team[ii].name:='';
   inc(counter);
  end;

  if (hometeam=false) and (away_team[ii].name<>'') then begin
   first_message;
   temp.name2:=away_team[ii].name;
   add_shadow(SRemove,temp,'','',0);
   random_goodbye;
   away_team[ii].name:='';
   inc(counter);
  end;

 end; {for i:= .end.}

 if counter>1 then begin
  d(config.textcolor,'-----')
 end;

end; {remove_tug_team *end*}

Function Bring_In_Team(const hometeam:boolean;team_name:s70) : boolean;
var      {we the boys in team TEAM_NAME online}
    result : boolean;

    i,j,k, size : word;

    done : boolean;
    ply : userrec;

begin

 {init}
 result:=false;

 crlf;
 if hometeam then d(15,'Searching for your crew...')
             else d(15,'Searching for other team...');

 done:=false;
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   if load_character(ply,i,j)=true then begin

    if (ply.team=team_name) and
       (ply.team<>'') and
       (ply.name2<>'') and
       (ply.deleted=false) and
       (is_online(ply.name2,online_player)=false) then begin

     if add_shadow(SAdd,ply,player.name2,tugdesc,0)=true then begin

      if hometeam then begin
       d(global_plycol,ply.name2+config.textcol1+' arrived for your team!');

       {find empty spot to put ply in team array}
       add_tug_participant(1,ply);

      end
      else begin {away team}
       d(global_plycol,ply.name2+config.textcol1+' arrived for other team!');
       {find empty spot to put ply in team array}
       add_tug_participant(2,ply);
      end;

      {are we completely done collecting team?}
      if hometeam then begin
       done:=true;
       for k:=1 to global_maxteammembers do begin
        if away_team[k].name='' then begin
         done:=false;
         break;
        end;
       end; {for k:= .end. }

      end
      else begin
       done:=true;

       for k:=1 to global_maxteammembers do begin
        if away_team[k].name='' then begin
         done:=false;
         break;
        end;
       end; {for k:= .end. }

      end;

     end;

    end;
   end;

   if done then break;

  end; {for j:= .end.}

  if done then break;

 end; {for i:= .end.}

 {did we get a full team?}
 if done then result:=true
         else result:=false;

 {return result}
 bring_in_team:=result;

end; {Bring_In_Team *end*}

Function Teams_Ready : boolean; {are teams filled with people ready to fight}
var
   i : word;
   result : boolean;
begin

 result:=true;
 for i:=1 to global_maxteammembers do begin
  if (home_team[i].name='') or (away_team[i].name='') then begin
   result:=false;
   break;
  end;
 end; {for i:= .end.}

 {return result}
 teams_ready:=result;

end; {teams_ready *end*}

Function Pick_Random_Team(const hometeam:boolean) : boolean;
var      {we pick random teams, mixed npcs and human players}
    done,
    result : boolean;

    i : word;

    tries : byte;

    ply : userrec;


begin

 {init}
 result:=false;

 crlf;
 if hometeam then begin
  d(15,'Searching for people join your Tug-Team...');
  remove_tug_team(true,1);
 end
 else begin
  d(15,'Searching for scoundrels to join other team...');
  remove_tug_team(false,1);
 end;

 done:=false;
 tries:=0;
 repeat

  inc(tries);

  if get_random_character(ply,3)=true then begin
   {can't be online if to participate in Tug-of-War}

   {add shadow player}
   if add_shadow(SAdd,ply,player.name2,tugdesc,0)=true then begin
    if hometeam then begin

     d(global_plycol,ply.name2+config.textcol1+' arrived for your team!');
     {find empty spot to put ply in team array}
     for i:=1 to global_maxteammembers do begin
      if home_team[i].name='' then begin
       {put ply in team-array}
       init_tug_member(home_team[i],ply);
       break;
      end;
     end; {for i:= .end. }

    end
    else begin {away team}
     d(global_plycol,ply.name2+config.textcol1+' arrived for other team!');
     {find empty spot to put ply in team array}
     for i:=1 to global_maxteammembers do begin
      if away_team[i].name='' then begin
       {put ply in team-array}
       init_tug_member(away_team[i],ply);
       break;
      end;
     end; {for i:= .end. }

    end;
   end;

  end;

  {are we done collecting teammembers?}
  done:=true;
  for i:=1 to global_maxteammembers do begin
   if hometeam then begin
    if home_team[i].name='' then begin
     done:=false;
     break;
    end;
   end
   else begin
    if away_team[i].name='' then begin
     done:=false;
     break;
    end;
   end;
  end; {for i:= .end.}

 until (done) or (tries>global_maxteammembers*3);

 {did we get a full team?}
 if done then result:=true
         else result:=false;

 {return result}
 pick_random_team:=result;

end; {Pick_Random_Team *end*}


const max_team_power = 26; {also length of rope for each team}
var team1_power, team2_power : longint;

procedure display_rope_bar;
const rope_char = '-';
      rope_col = 15; {rope color}
      team_char = 'O';
      goal_char = '|';
begin {displays pulled rope}

 {***                          |                                  ****}
 {you<<<<<<<<<<<<<<<<<<<<<<<<<<->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>them}
 {                             |                                      }

 {calculate length of rope depending on power}
 d(11,mkstring(31,' ')+goal_char);
 sd(rope_col,mkstring(max_team_power-team1_power,' '));
 sd(14,mkstring(global_maxteammembers,team_char));
 sd(rope_col,mkstring(team1_power,rope_char));

 sd(11,goal_char);
 sd(rope_col,mkstring(team2_power,rope_char));
 d(12,mkstring(global_maxteammembers,team_char));
 d(11,mkstring(31,' ')+goal_char);


end; {display_rope_bar *end*}

procedure update_power(teamnr:byte);
const force = 4;
begin

 case teamnr of
  1:begin
     inc(team1_power,force);
     dec(team2_power,force);
    end;
  2:begin
     inc(team2_power,force);
     dec(team1_power,force);
    end;
 end; {case .end.}

 if team1_power>max_team_power then team1_power:=max_team_power;
 if team1_power<0 then team1_power:=0;

 if team2_power>max_team_power then team2_power:=max_team_power;
 if team2_power<0 then team2_power:=0;


end; {update_power *end*}

procedure display_team(const hometeam:boolean);
var ii : byte;
begin {displays how many persons are still missing before tug-team is
      complete}
 if hometeam then begin

  for ii:=1 to global_maxteammembers do begin
   if home_team[ii].name<>'' then begin
    d(global_plycol,home_team[ii].name);
   end
   else begin
    d(12,'*missing*');
   end;
  end;

 end
 else begin

  for ii:=1 to global_maxteammembers do begin
   if away_team[ii].name<>'' then begin
    d(global_plycol,away_team[ii].name);
   end
   else begin
    d(12,'*missing*');
   end;
  end;

 end;

end; { display_team *end*}

function tug_team_active(const team:s30) : boolean;
var
   i : byte;
   result : boolean;

begin

 {init}
 result:=false;

 for i:=1 to global_maxteammembers do begin
  if (away_team[i].name<>'') and (away_team[i].team<>'') and
     (away_team[i].team=team) then begin
   result:=true;
   break;
  end;
 end; {for i:= .end.}

 {return result}
 tug_team_active:=result;

end; {tug_team_active *end*}

procedure pull_rope_once;
begin

 case random(3) of
  0:begin {team1 win}
     d(14,'You are pulling them in!!');
     update_power(1);
    end;
  1:begin {team2 win}
     d(12,'The other Team caught you off-guard!');
     update_power(2);
    end;
  2:begin {draw}
     d(11,'Both team struggle...');
    end;
 end; {case .end.}

end; {pull_rope_once *end*}

procedure view_tug_teams;
var

   ch : char;
   i : word;

   x, x2 : byte;

   go_ahead,
   ready : boolean;

   tempName : s30; {name}
   tempAI : char; {ai}
   tempFILTYP : byte; {filnr}
   tempRECNR : word; {recnr}
   tempId : s15; {id}
   tempTeam : s30; {teamname}
   tempStrength : word; {strength}

   relation : relationRec;
begin

 crlf;

 repeat
  crlf;
  {home team}
  d(14,'Your Team');
  for i:=1 to global_maxteammembers do begin
   if home_team[i].name<>'' then begin
    if i=1 then d(11,commastr(i)+'. '+uplc+'You')
           else d(11,commastr(i)+'. '+uplc+home_team[i].name);
   end
   else begin
    d(11,commastr(i)+'. '+ulred+'*missing*');
   end;
  end; {for i:= .end.}

  {away team}
  crlf;
  d(14,'Other Team');
  for i:=1 to global_maxteammembers do begin
   if away_team[i].name<>'' then begin
    d(11,commastr(i)+'. '+uplc+away_team[i].name);
   end
   else begin
    d(11,commastr(i)+'. '+ulred+'*missing*');
   end;
  end; {for i:= .end.}

  crlf;
  menu2('(A)dd ');
  menu2('(D)rop ');
  menu2('(S)wap ');
  menu2('(R)eturn :');

  {get user-input}
  ch:=upcase(getchar);

  crlf;
  {evaluate user-input}
  case ch of
   'S':begin {swap players}

        ready:=false;
        repeat

         crlf;
         d(config.textcolor,'Person from Your team (1-5, 0=abort)');
         sd(config.textcolor,':');
         x:=get_number(0,5);

         case x of
          0: ready:=true;
          1:begin
             d(12,'You can''t swap yourself!');
             pause;
            end;
          2..5:begin
                if home_team[x].name<>'' then begin
                 if confirm(uplc+home_team[x].name+config.textcol1,'Y')=true then begin
                  ready:=true;
                 end;
                end;
               end;
         end; {case .end.}

        until ready;

        if x>0 then begin
         ready:=false;
         repeat

          crlf;
          d(config.textcolor,'Person from Other Team (1-5, 0=abort)');
          sd(config.textcolor,':');
          x2:=get_number(0,5);

          case x2 of
           0: ready:=true;
           1..5:begin
                 if away_team[x2].name<>'' then begin
                  if confirm(uplc+away_team[x2].name+config.textcol1,'Y')=true then begin
                   ready:=true;
                  end;
                 end;
                end;
          end; {case .end.}

         until ready;

         {ready to swap?}
         if (x>0) and (x2>0) then begin
          if confirm('Swap '+uplc+home_team[x].name+config.textcol1+' and '+uplc+away_team[x2].name
               +config.textcol1,'Y')=true then begin

           {set temp values}
           tempName:=home_team[x].name; {name}
           tempAI:=home_team[x].AI; {ai}
           tempFILTYP:=home_team[x].filtyp; {filtyp}
           tempRECNR:=home_team[x].recnr; {recnr}
           tempId:=home_team[x].id; {id}
           tempTeam:=home_team[x].team; {teamname}
           tempStrength:=home_team[x].strength; {strength}

           {set home_team}
           home_team[x].Name:=away_team[x2].name; {name}
           home_team[x].AI:=away_team[x2].AI; {AI}
           home_team[x].FILTYP:=away_team[x2].FILTYP; {FILTYP}
           home_team[x].RECNR:=away_team[x2].RECNR; {RECNR}
           home_team[x].Id:=away_team[x2].id; {id}
           home_team[x].Team:=away_team[x2].team; {teamname}
           home_team[x].Strength:=away_team[x2].strength; {strength}

           {set away team}
           away_team[x2].Name:=tempname; {name}
           away_team[x2].AI:=tempai; {ai}
           away_team[x2].FILTYP:=tempfiltyp; {filtyp}
           away_team[x2].RECNR:=temprecnr; {recnr}
           away_team[x2].Id:=tempid; {id}
           away_team[x2].Team:=tempteam; {teamname}
           away_team[x2].Strength:=tempstrength; {strength}


          end;

         end;

        end;

       end; {swap .end.}

   'A':begin {add player}
        {are both teams full?`}
        if teams_ready then begin
         d(12,'Both teams are full!');
         pause;
        end
        else begin

         d(config.textcolor,'Who shall be invited?');
         if Select_Character(temp,true)=true then begin
          {critera:
           is target team full?
           player may not already be online
           player may hate player
           }
          if is_online(temp.name2,online_player)=true then begin
           d(12,temp.name2+' is busy.');
           pause;
          end
          else begin

           ready:=false;
           repeat
            crlf;
            d(config.textcolor,'What Team shall '+uplc+temp.name2+config.textcol1+' be in?');

            {which team should we put this selected player in?}
            menu('(Y)our team  ');
            menu('(O)ther team ');
            menu2('(R)eturn :');

            {get user-input}
            ch:=upcase(getchar);

            {evaluate user-input}
            case ch of
             'R':begin {return}
                  ready:=true;
                 end;
             'Y','O':begin {put selected character in one of the team}

                  go_ahead:=true;
                  if ch='Y' then begin

                   {load relation}
                   social_relation(player,temp,relation);

                   {correct relation}
                   correct_relation(player.name2,relation);

                   {is the relation bad?}
                   if relation.relation2 in [
                                      global_RelationEnemy,
                                      global_RelationAnger,
                                      global_RelationHate] then begin
                    {bad relation! selected player will not compete with player!}
                    crlf;
                    d(2,relation_string(true,temp.name2,player.name2,relation.relation2));
                    d(global_plycol,temp.name2+ulred+' will never fight your your cause!!');
                    go_ahead:=false;
                    pause;
                   end;
                  end;

                  if go_ahead then begin
                   if add_shadow(SAdd,temp,player.name2,tugdesc,0)=true then begin

                    {find empty spot to put ply in team array}
                    if ch='Y' then i:=1
                              else i:=2;

                    if add_tug_participant(i,temp)=true then begin
                     crlf;
                     d(15,'Done! '+uplc+temp.name2+config.textcol1+' has arrived!');
                     pause;
                     ready:=true;
                    end
                    else begin
                     crlf;
                     d(12,'Team is full!');
                     add_shadow(SRemove,temp,'','',0);
                     pause;
                    end;
                   end
                   else begin
                    crlf;
                    d(12,'Unable to summon '+temp.name2+'!');
                    pause;
                   end;

                  end;

                 end;
            end; {case .end.}

           until ready;
          end;
         end;

        end;
       end; {add player .end.}

   'D':begin {drop player}

        {are there any players to drop?}
        ready:=false;

        for i:=1 to global_maxteammembers do begin

         if (i>1) and (home_team[i].name<>'') then begin
          ready:=true;
          break;
         end;

         if away_team[i].name<>'' then begin
          ready:=true;
          break;
         end;

        end; {for :=i .end.}

        if not ready then begin
         crlf;
         d(12,'Both teams are empty! (except for yourself)');
         pause;
        end
        else begin
         ready:=false;
         repeat
          crlf;
          d(config.textcolor,'Drop player from ');
          menu2('(Y)our team or ');
          menu2('(O)ther team ');
          menu2('(R)eturn ');
          sd(config.textcolor,':');
          ch:=upcase(getchar);
          crlf;

          case ch of
           'R':begin
                ready:=true;
               end;
           'Y':begin {your team, drop}
                crlf;
                d(config.textcolor,'Person to drop from Your Team (2-5, 0=abort)');
                sd(config.textcolor,':');
                x2:=get_number(0,5);

                case x2 of
                 1: d(12,'Idiot! You can''t drop yourself!');
                 2..5:begin
                       if home_team[x2].name<>'' then begin
                        if confirm(uplc+home_team[x2].name+config.textcol1,'Y')=true then begin
                         {drop}
                         d(global_plycol,home_team[x2].name+config.textcol1+' was sent home!');
                         temp.name2:=home_team[x2].name;
                         add_shadow(SRemove,temp,'','',0);
                         home_team[x2].name:='';
                        end;
                       end
                       else begin
                        d(12,'Idiot!');
                       end;
                      end;
                end; {case .end.}

               end;
           'O':begin {other team, drop}
                crlf;
                d(config.textcolor,'Person to drop from Other Team (1-5, 0=abort)');
                sd(config.textcolor,':');
                x2:=get_number(0,5);

                case x2 of
                 1..5:begin
                       if away_team[x2].name<>'' then begin
                        if confirm(uplc+away_team[x2].name+config.textcol1,'Y')=true then begin
                         {drop}
                         d(global_plycol,away_team[x2].name+config.textcol1+' was sent home!');
                         temp.name2:=away_team[x2].name;
                         add_shadow(SRemove,temp,'','',0);
                         away_team[x2].name:='';
                        end;
                       end
                       else begin
                        d(12,'Idiot!');
                       end;
                      end;
                end; {case .end.}

               end;
          end; {case .end.}

         until ready

        end;

       end; {drop player .end.}
  end; {case .end.}

 until ch='R';

end; {view_tug_teams *end*}

const tug_menu_header ='Tug-of-War! '+ulred+'*competition*';
const pull_key='P';
const max_bouts = 79; {max "pull-ropes" before its called a draw}
var
    ch : char;

    home_team_result,
    away_team_result : byte;


    i,
    bout : word;

    x : longint;

    s : s70;

    pl0 : userrec;

    done,
    go_ahead : boolean;

begin {*Tug_Of_War*}

 {init values}
 ch:='?';

 {init teams, and put player at first record in the "home team"}
 init_teams(3);

 init_teams(1);
 init_teams(2);

 repeat

  {display menu}
  if ch='?' then begin
   clearscreen;

   crlf;
   crlf;
   d(2,tug_menu_header);
   crlf;

   if teams_ready then begin
    menu('('+pull_key+')ull!');
   end
   else begin
    {shadow the option when menu option is not available}
    d(7,'(P)ull!');
   end;
   menu('(V)iew - Edit team');

   menu('(B)ring in your crew');
   menu('(I)nvite other team');
   menu('(G)et random team');

{   d(config.textcolor,'Free Memory Available in the Heap: '+ulcyan+commastr(memavail));
}

   {menu('(D)rop player');
   menu('(S)elect player');}


   menu('(R)eturn');

  end;

  crlf;
  sd(config.textcolor,'Tug-of-War ('+config.textcol2+'?'+config.textcol1+' for menu) :');

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user-input}
  case ch of
   'I':begin {invite other team}

        s:=pick_teamname(player.team);
        if s<>'' then begin
         if tug_team_active(s)=true then begin
          crlf;
          d(12,'Idiot! The '+utec+s+ulred+' are already here!');
         end
         else begin
          bring_in_team(false,s);
         end;
        end;

       end; {invite other team *end*}
   'B':begin {bring in own team}

        if player.team='' then begin
         crlf;
         crlf;
         d(12,'Idiot! You''re not member of a team!');
         pause;
        end
        else begin

         {put teammembers online}
         crlf;
         crlf;
         d(config.textcolor,'Fetching your team...');

         bring_in_team(true,player.team);

        end;
       end; {bring in own team *end*}

   'G':begin {get randomly selected team(s) }

        done:=false;
        ch:='?';
        repeat

         if ch='?' then begin

          crlf;
          crlf;
          d(11,'Select Random Teams');
          crlf;
          menu('(Y)our team');
          menu('(O)ther team');
          menu('(B)oth');
          menu('(V)iew/edit teams');
          menu('(R)eturn');
         end;

         crlf;
         sd(config.textcolor,'Random Teams ('+config.textcol2+'?'+config.textcol1+' for menu) :');

         {get user-input}
         ch:=upcase(getchar);

         {evaluate user-input}
         case ch of
          'R':begin {return}
               ch:='?';
               done:=true;
              end;
          'V':begin {view teams}
               view_tug_teams;
              end;
          'Y':begin {randomly select "home team"}
               pick_random_team(true);
              end;
          'O':begin {randomly select "away team"}
               pick_random_team(false);
              end;
          'B':begin {randomly select both teams}

               crlf;
               go_ahead:=true;
               if teams_ready then begin
                crlf;
                if confirm('Both Teams are filled with people! Replace them','Y')=false then begin
                 go_ahead:=false;
                end;
               end;

               if go_ahead then begin
                pick_random_team(true);
                pick_random_team(false);
               end;

              end;

         end; {case .end.}

        until done;

       end;

   'V':begin {view teams}

        view_tug_teams;

       end;

   'R':begin {return}

        crlf;
        crlf;
        d(12,'You leave.');
        crlf;

        remove_tug_team(true,1);
        remove_tug_team(false,1);

       end;
   pull_key:begin {pull, start competition}

        if not teams_ready then begin
         crlf;
         crlf;
         d(12,'Teams are not complete! Invite more people!');
         crlf;
         ch:=' ';
        end;

       end;

  end; {case .end.}

 until ch in [pull_key,'R'];

 {affects leaving comments from winning/losing teams
  see procedure Remove_Tug_Team and the leavinggym variable}
 home_team_result:=1;
 away_team_result:=1;


 if (teams_ready) and (ch=pull_key) then begin

  {mail invited players}
  crlf;
  sd(config.textcolor,'Preparing everybody....');
  for i:=1 to global_maxteammembers do begin

   if (home_team[i].name<>'') and (i>1) then begin
    {mail}
    post(MailSend,
    home_team[i].name,
    home_team[i].ai,
    false,
    mailrequest_nothing,
    '',
    ulcyan+'Tug-of-War Competition'+config.textcol1,
    mkstring(22,underscore),
    uplc+player.name2+config.textcol1+' inivited you to a Tug-of-War Competition!',
    'You were selected to fight in '+uplc+player.name2+'s'+config.textcol1+' Team.',
    'Your Team : '+uplc+home_team[1].name,
    '            '+home_team[2].name,
    '            '+home_team[3].name,
    '            '+home_team[4].name,
    '            '+home_team[5].name,
    ' '+config.textcol1,
    'Other Team : '+uplc+away_team[1].name,
    '             '+away_team[2].name,
    '             '+away_team[3].name,
    '             '+away_team[4].name,
    '             '+away_team[5].name);
   end;

   if away_team[i].name<>'' then begin

    {mail}
    post(MailSend,
    away_team[i].name,
    away_team[i].ai,
    false,
    mailrequest_nothing,
    '',
    ulcyan+'Tug-of-War Competition'+config.textcol1,
    mkstring(22,underscore),
    uplc+player.name2+config.textcol1+' inivited you to a Tug-of-War Competition!',
    'You were selected to fight against '+uplc+player.name2+config.textcol1+' Team.',
    'Your Team : '+uplc++away_team[1].name,
    '            '+away_team[2].name,
    '            '+away_team[3].name,
    '            '+away_team[4].name,
    '            '+away_team[5].name,
    ' '+config.textcol1,
    'Other Team : '+uplc+home_team[1].name,
    '             '+home_team[2].name,
    '             '+home_team[3].name,
    '             '+home_team[4].name,
    '             '+home_team[5].name);
   end;


  end; {for i:= .end.}
  d(15,'DONE!');

  d(15,'Pull!');

  {when running a test version you don't want the gym sessions to decrease}
  if global_utest=false then begin
   dec(player.gym_sessions);
  end;

  {init team powers}
  team1_power:=max_team_power;
  team2_power:=max_team_power;
  bout:=0;
  repeat

   inc(bout);

   {display rope status bar}
   display_rope_bar;

   {get at it!}
   pull_rope_once;

   pause;
   crlf;

  until (team1_power<1) or (team2_power<1) or (bout>max_bouts);



  if bout>max_bouts then begin

   {a draw!}
   d(15,'A Draw!');
   d(15,'Both Teams are exhausted...');
   d(15,'You shake hands on a match well performed.');
   sd(15,'Hang on while the stats are being updated...');

   {2=draw
    3=win
    4=loss
   set going away comments...see remove_tug_team proc above}
   home_team_result:=2;
   away_team_result:=2;

   {rewards, experience}
   for i:=1 to global_maxteammembers do begin

    if (home_team[i].name<>'') and (i>1) then begin

     if load_character(pl0,home_team[i].filtyp,home_team[i].recnr)=true then begin

      {experience points reward}
      x:=pl0.level*150;
      IncPlayerExp(pl0,x);

      {save character}
      user_save(pl0);

      {mail}
      post(MailSend,
      home_team[i].name,
      home_team[i].ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+'Competition Reward'+config.textcol1,
      mkstring(18,underscore),
      'The Tug-of-War arranged by '+uplc+player.name2+config.textcol1+' ended in a DRAW.',
      'You earned '+uwhite+commastr(x)+config.textcol1+' experience points!',
      'The game ended after '+uwhite+commastr(bout)+config.textcol1+' rounds.',
      'Your Team: '+uplc+home_team[1].name,
      '           '+uplc+home_team[2].name,
      '           '+uplc+home_team[3].name,
      '           '+uplc+home_team[4].name,
      '           '+uplc+home_team[5].name,
      config.textcol1+'Other Team:'+uplc+away_team[1].name,
      '           '+uplc+away_team[2].name,
      '           '+uplc+away_team[3].name,
      '           '+uplc+away_team[4].name,
      '           '+uplc+away_team[5].name);

     end;

    end;

    if away_team[i].name<>'' then begin


     {load character}
     if load_character(pl0,away_team[i].filtyp,away_team[i].recnr)=true then begin

      {experience points reward}
      x:=pl0.level*150;
      IncPlayerExp(pl0,x);

      {save character}
      user_save(pl0);

      {mail}
      post(MailSend,
      away_team[i].name,
      away_team[i].ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+'Competition Reward'+config.textcol1,
      mkstring(18,underscore),
      'The Tug-of-War arranged by '+uplc+player.name2+config.textcol1+' ended in a DRAW.',
      'You earned '+uwhite+commastr(x)+config.textcol1+' experience points!',
      'The game ended after '+uwhite+commastr(bout)+config.textcol1+' rounds.',
      'Your Team: '+uplc+away_team[1].name,
      '           '+uplc+away_team[2].name,
      '           '+uplc+away_team[3].name,
      '           '+uplc+away_team[4].name,
      '           '+uplc+away_team[5].name,
      config.textcol1+'Other Team:'+uplc+home_team[1].name,
      '           '+uplc+home_team[2].name,
      '           '+uplc+home_team[3].name,
      '           '+uplc+home_team[4].name,
      '           '+uplc+home_team[5].name);

     end;

    end;

   end; {for i:= .end.}

   {news-paper}
   newsy(false,
   'Tug-of-War',
   ' '+uplc+player.name2+config.textcol1+' arranged a TUG-Of-War Competition.',
   ' It ended in a DRAW!',
   ' Team1 :',
   '  '+uplc+home_team[1].name,
   '  '+uplc+home_team[2].name,
   '  '+uplc+home_team[3].name,
   '  '+uplc+home_team[4].name,
   '  '+uplc+home_team[5].name,
   config.textcol1+' Team2 :');

   {the newsfile continues here...}
   newsy(true,
   '  '+uplc+away_team[1].name,
   '  '+uplc+away_team[2].name,
   '  '+uplc+away_team[3].name,
   '  '+uplc+away_team[4].name,
   '  '+uplc+away_team[5].name,
   '',
   '',
   '',
   '',
   '');

  end {DRAW .END.}
  else if team2_power<1 then begin

   {team 1 won!}
   d(14,'You Won!');
   d(config.textcolor,'The Crowd goes crazy over your performance!');
   sd(15,'Hang on while the stats are being updated...');

   {2=draw
    3=win
    4=loss
   set going away comments...see remove_tug_team proc above}
   home_team_result:=3;
   away_team_result:=4;

   {rewards, experience..but only to the winning Team!}
   for i:=1 to global_maxteammembers do begin

    if (home_team[i].name<>'') and (i>1) then begin

     {load character}
     if load_character(pl0,home_team[i].filtyp,home_team[i].recnr)=true then begin

      {experience points reward}
      x:=pl0.level*250;
      IncPlayerExp(pl0,x);

      {save character}
      user_save(pl0);

      {mail}
      post(MailSend,
      home_team[i].name,
      home_team[i].ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+'Competition Won'+config.textcol1,
      mkstring(15,underscore),
      'The Tug-of-War arranged by '+uplc+player.name2+config.textcol1+' was won by your team!',
      'You earned '+uwhite+commastr(x)+config.textcol1+' experience points!',
      'The game ended after '+uwhite+commastr(bout)+config.textcol1+' rounds.',
      'Your Team: '+uplc+home_team[1].name,
      '           '+uplc+home_team[2].name,
      '           '+uplc+home_team[3].name,
      '           '+uplc+home_team[4].name,
      '           '+uplc+home_team[5].name,
      config.textcol1+'Other Team:'+uplc+away_team[1].name,
      '           '+uplc+away_team[2].name,
      '           '+uplc+away_team[3].name,
      '           '+uplc+away_team[4].name,
      '           '+uplc+away_team[5].name);

     end;

    end;

    if away_team[i].name<>'' then begin

     {load character}
     if load_character(pl0,away_team[i].filtyp,away_team[i].recnr)=true then begin

      {experience points reward}
      x:=0;
      IncPlayerExp(pl0,x);

      {save character}
      user_save(pl0);

      {mail}
      post(MailSend,
      away_team[i].name,
      away_team[i].ai,
      false,
      mailrequest_nothing,
      '',
      ulred+'Competition Lost'+config.textcol1,
      mkstring(16,underscore),
      'The Tug-of-War arranged by '+uplc+player.name2+config.textcol1+' ended in a defeat for your Team!',
      'You earned '+ulred+'no'+config.textcol1+' experience points.',
      'The game was lost after '+uwhite+commastr(bout)+config.textcol1+' rounds.',
      'Your Team: '+uplc+away_team[1].name,
      '           '+uplc+away_team[2].name,
      '           '+uplc+away_team[3].name,
      '           '+uplc+away_team[4].name,
      '           '+uplc+away_team[5].name,
      config.textcol1+'Other Team:'+uplc+home_team[1].name,
      '           '+uplc+home_team[2].name,
      '           '+uplc+home_team[3].name,
      '           '+uplc+home_team[4].name,
      '           '+uplc+home_team[5].name);

     end;

    end;

   end; {for i:= .end.}


   {news-paper}
   newsy(false,
   'Tug-of-War',
   ' '+uplc+player.name2+config.textcol1+' arranged a TUG-Of-War Competition.',
   ' '+uplc+player.name2+'s'+config.textcol1+' team won!',
   ' Winning Team',
   '  '+uplc+home_team[1].name,
   '  '+uplc+home_team[2].name,
   '  '+uplc+home_team[3].name,
   '  '+uplc+home_team[4].name,
   '  '+uplc+home_team[5].name,
   config.textcol1+' Losing Team');

   {the newsfile continues here...}
   newsy(true,
   '  '+uplc+away_team[1].name,
   '  '+uplc+away_team[2].name,
   '  '+uplc+away_team[3].name,
   '  '+uplc+away_team[4].name,
   '  '+uplc+away_team[5].name+config.textcol1,
   '',
   '',
   '',
   '',
   '');


  end {WON .END.}
  else begin {LOSE .START.}

   {team 2 won!}
   d(12,'You lost!!');
   d(config.textcolor,'You can hear the Crowd booing your lousy performance!');
   sd(15,'Hang on while the stats are being updated...');

   {2=draw
    3=win
    4=loss
   set going away comments...see remove_tug_team proc above}
   home_team_result:=4;
   away_team_result:=3;

   {rewards, experience..but only to the winning Team!}
   for i:=1 to global_maxteammembers do begin

    if (home_team[i].name<>'') and (i>1) then begin

     {load character}
    { d(14,'loading '+home_team[i].name);
     pause;
     }

     {load character}
     if load_character(pl0,home_team[i].filtyp,home_team[i].recnr)=true then begin

      {experience points reward}
      x:=0;
      IncPlayerExp(pl0,x);

      {save character}
      user_save(pl0);

      {mail}
      post(MailSend,
      home_team[i].name,
      home_team[i].ai,
      false,
      mailrequest_nothing,
      '',
      ulred+'Competition Lost'+config.textcol1,
      mkstring(16,underscore),
      'The Tug-of-War arranged by '+uplc+player.name2+config.textcol1+' ended in a defeat for your Team!',
      'You earned '+ulred+'no'+config.textcol1+' experience points.',
      'The game was lost in the '+uwhite+commastr(bout)+config.textcol1+' round.',
      'Your Team: '+uplc+home_team[1].name,
      '           '+uplc+home_team[2].name,
      '           '+uplc+home_team[3].name,
      '           '+uplc+home_team[4].name,
      '           '+uplc+home_team[5].name,
      config.textcol1+'Other Team:'+uplc+away_team[1].name,
      '           '+uplc+away_team[2].name,
      '           '+uplc+away_team[3].name,
      '           '+uplc+away_team[4].name,
      '           '+uplc+away_team[5].name);

     end;

    end;

    if away_team[i].name<>'' then begin

      {load character}
     {d(14,'loading '+home_team[i].name);
     pause;
      }

     {load character}
     if load_character(pl0,away_team[i].filtyp,away_team[i].recnr)=true then begin

      {experience points reward}
      x:=pl0.level*250;
      IncPlayerExp(pl0,x);

      {save character}
      user_save(pl0);

      {mail}
      post(MailSend,
      away_team[i].name,
      away_team[i].ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+'Competition Won'+config.textcol1,
      mkstring(15,underscore),
      'The Tug-of-War arranged by '+uplc+player.name2+config.textcol1+' was won by your Team!',
      'You earned '+uwhite+commastr(x)+config.textcol1+' experience points!',
      'The game ended in the '+uwhite+commastr(bout)+config.textcol1+' round.',
      'Your Team: '+uplc+away_team[1].name,
      '           '+uplc+away_team[2].name,
      '           '+uplc+away_team[3].name,
      '           '+uplc+away_team[4].name,
      '           '+uplc+away_team[5].name,
      config.textcol1+'Other Team:'+uplc+home_team[1].name,
      '           '+uplc+home_team[2].name,
      '           '+uplc+home_team[3].name,
      '           '+uplc+home_team[4].name,
      '           '+uplc+home_team[5].name);

     end;

    end;

   end; {for i:= .end.}

   {news-paper}
   newsy(false,
   'Tug-of-War',
   ' '+uplc+player.name2+config.textcol1+' arranged a TUG-Of-War Competition.',
   ' '+uplc+player.name2+'s'+config.textcol1+' team lost!',
   ' Winning Team',
   '  '+uplc+away_team[1].name,
   '  '+uplc+away_team[2].name,
   '  '+uplc+away_team[3].name,
   '  '+uplc+away_team[4].name,
   '  '+uplc+away_team[5].name,
   config.textcol1+' Losing Team');

   {the newsfile continues here...}
   newsy(true,
   '  '+uplc+home_team[1].name,
   '  '+uplc+home_team[2].name,
   '  '+uplc+home_team[3].name,
   '  '+uplc+home_team[4].name,
   '  '+uplc+home_team[5].name+config.textcol1,
   '',
   '',
   '',
   '',
   '');


  end; {LOSE .END.}

  d(15,'DONE!');

 end;

 {remove shadow players}
 remove_tug_team(true,home_team_result);
 remove_tug_team(false,away_team_result);

end; {tug_of_war *end*}

Procedure Dumb_Bells;
begin
 d(config.textcolor,'This feature is not implemented yet.');
end; {dumb_bells *end*}

Procedure Lift_Barrels;
var x : longint;
    brls : longint;
begin

 brls:=random(player.level)+random(player.strength);
 crlf;
 d(config.textcolor,'You managed to lift '+uwhite+commastr(brls)+config.textcol1+' barrels!');
 pause;

 {did player make it to the hall of fame}
 x:=barrel_fame_rating(player.name2,player.id,player.level,player.race,
                       player.class,brls);

 if x>0 then begin
  d(15,'Congratulations!!');
  d(15,'You made it to #'+commastr(x)+' in the BARREL HALL OF FAME!');

  newsy(true,
       config.textcol1+'Barrel Champion!',
       ' '+uplc+player.name2+config.textcol1+' lifted '+uwhite+commastr(brls)+config.textcol1+' beer barrels!',
       ' '+uplc+player.name2+config.textcol1+' entered position '+uwhite+commastr(x)+config.textcol1+' in the '+ulcyan
          +'Barrel Hall of Fame'+config.textcol1+'!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');



 end
 else begin
  d(12,'You didn''t make it to the hall of fame.');
 end;

 {decrease player gym_sessions}
 dec(player.gym_sessions);

end; {lift_barrels *end*}

Function Fix_Last_Kill(const w:string):string;
var result,temp : string;
    done : boolean;
    x,lastpos : integer;
begin

 {replace the last "," with "and" ... just to look make it look better in the news}
 result:=w;
 temp:=w;
 lastpos:=0; x:=0;
 done:=false;
 repeat
  x:=pos(', ',temp);
  if x<>0 then begin
   lastpos:=x;
   {delete}
   temp[x]:='x';
   temp[x+1]:='x';
  end
  else done:=true;

 until done;

 if lastpos<>0 then begin
  {replace ", " with "and"}
  result[lastpos]:=' ';
  result[lastpos+1]:='a';
  insert('nd ',result,lastpos+2);
 end;

 {return result}
 fix_last_kill:=result;

end; {fix_last_kill *end*}

Function Crushed_Verb : s20;
var s : s20;
begin
 {successful attempt 'ephitet'}
 case random(7) of
  0: s:='eliminated';
  1: s:='massacred';
  2: s:='destroyed';
  3: s:='stomped';
  4: s:='crushed';
  5: s:='humiliated';
  6: s:='defeated';
 end; {case .end.}
 {return result}
 crushed_verb:=s;

end; {crushed_verb *end*}

Function Maim_Verb : s20;
var s : s20;
begin
 case random(7) of
  0: s:='maimed';
  1: s:='crippled';
  2: s:='downed';
  3: s:='knocked out';
  4: s:='stomped';
  5: s:='humiliated';
  6: s:='floored';
 end; {case .end.}

 {return result}
 maim_verb:=s;

end; {maim_verb *end*}

Function Gym_Owning_Team : s40;
var
   s : s40; {returns name of TEAM controlling the Gym}

   pl0 : UserRec;

   size,
   i,j : word;

   found : boolean;

begin

 {init}
 s:='';

 found:=false;
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(Fsplayer);
   2: size:=fs(fsNpc);
  end;

  for j:=1 to size do begin

   if load_character(pl0,i,j)=true then begin

    if (pl0.gym_owner>0) and
       (pl0.team<>'') and
       (pl0.deleted=false) and
       (pl0.name1<>global_delname1) and
       (pl0.name2<>global_delname2) then begin

     s:=pl0.team;
     found:=true;
     break;

    end;
   end;
  end; {for j:= .end.}

  if found then break;

 end; {for i:= .end.}

 {return result}
 gym_owning_team:=s;

end; {gym_owning_team *end*}

Procedure Meny;
const offset = 18;
      offset2= 26;
var s : s90;
    x : byte;
begin

 clearscreen;
 crlf;
 d(5,local_place);
 d(5,mkstring(length(local_place),underscore));
 crlf;
 d(config.textcolor,'The private Gym for tough people with an attitude.');
 d(config.textcolor,'Working out and flexing your muscles could earn you a position');
 d(config.textcolor,'in this town, some day.');
 d(global_plycol,config.gymMasseur+config.textcol1+', the masseur, is watching you.');
 crlf;

 menu2(ljust('(L)ist members',offset));
 menu2(ljust('(W)ork out',offset2));
 if player.gym_owner>0 then begin
  menu('(A)bandon control');
 end
 else crlf;

 menu2(ljust('(B)arrel Masters',offset));
 if player.sex=1 then x:=2
                 else x:=1;
 menu2(ljust('(T)ug-of-war competition',offset2));
 if player.gym_owner>0 then begin
  menu('(D)istribute club-card');
 end
 else crlf;

 menu2(ljust('(S)tatus',offset));
 menu2(ljust('(M)assage',offset2));
 if player.gym_owner>0 then begin
  menu('(E)xclude member');
 end
 else crlf;

 menu2(ljust('(R)eturn',offset));
 menu('(Q)uit as member');

end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,local_place+' ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin

   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,local_place+' (L,B,E,A,T,W,D,M,Q,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

procedure display_barrel_masters;
var
  Barrel_Master : BarrelRec; {barrel lifters top list, record}
  i, counter : word;
  s : s100;
begin

 d(11,'=*=Barrel Masters=*=');
 counter:=0;
 for i:=1 to fs(fsbarrel) do begin

  load_barrel(fload,barrel_master,i);

  if (barrel_master.name<>'') and
     (barrel_master.barrels>0) and
     (barrel_master.deleted=false) then begin
   inc(counter);

   {#}
   s:=commastr(counter)+'.';
   while length(s)<4 do begin
    s:=s+' ';
   end;
   sd(15,s);

   {name}
   sd(global_plycol,ljust(barrel_master.name,15));

   {barrels}
   sd(15,rjust(commastr(barrel_master.barrels),9));

   if barrel_master.barrels=1 then s:='barrel '
                              else s:='barrels';
   sd(7,' '+s);

   {date}
   s:=fix_date(barrel_master.datee);
   sd(9,'         ['+s+']');

   crlf;
  end;

 end; {for i:= .end.}

 if counter=0 then begin
  d(12,'No champions found!');
 end;

 crlf;

end; {display_barrel_masters *end*}


Procedure The_Gym; {the gym}
var
   ok,
   found,
   abort,
   leave_gym : boolean;

   ch : char;

   i,
   j,
   size : word;

   x,cost : longint;

   lines,
   tries,
   fileid,
   counter : byte;

   my_oil : s70;
   s : s100;

   pl0 : ^UserRec;

Procedure Disposal; {dispose of pointer variables before leaving proc.}
begin
 dispose(pl0);
end;

var finished : boolean;

begin {Main proc START}

 {init pointer vars}
 new(pl0);

 crlf;
 d(14,'You enter the Gym');

 leave_gym:=false;
 repeat

  {update online location, only if necessary}
  if onliner.location<>onloc_the_gym then begin
   refresh:=true;
   onliner.location:=onloc_the_gym;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {display menu}
  display_menu(true,true);

  {get user-input}
  ch:=upcase(getchar);

  {player might have had his club card revoked online}
  if (player.gym_owner=0) and (player.gym_card=0) then begin
   crlf;
   d(12,'Strong hands lift you out on the street!');
   d(12,'Never dare show your ugly face in the Gym again!');
   d(12,'You have been banned from this location!');
   ch:='R';
  end;

  {evaluate user-input}
  case ch of
   '?':begin {display menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'R':begin {return}
        leave_gym:=true;
       end;
   'Q':begin {quit membership}
        crlf;
        crlf;
        if player.gym_owner>0 then begin
         {player is one of the owners}
         d(12,'You are one of the owners! You idiot!');
         pause;
        end
        else begin
         if confirm('Really leave the Gym','N')=false then begin
          crlf;
          d(14,'You decide to stay a while...');
          crlf;
         end
         else begin
          crlf;
          d(12,'You shred your membership card and leave the Gym...!');
          crlf;

          {news-paper}
          newsy(true,
          'Troublemaker leaves!',
          ' '+uplc+player.name2+config.textcol1+' was not satisfied with the '+gymcol+'Gym'+config.textcol1+' facilities.',
          ' '+the_bad+race_display(2,player.race,0)+' burned '+sex3[player.sex]+' membership card!',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

          {find gym_owners (team name)}
          for i:=1 to fs(FsPlayer) do begin

           if load_character(pl0^,1,i)=true then begin

            if (pl0^.gym_owner>0) and
               (pl0^.name2<>global_delname2) and
               (pl0^.name1<>global_delname1) and
               (pl0^.team<>'') and
               (pl0^.deleted=false) then begin

             {inform the owners}
             Team_Report_All(pl0^.team,  {team to send message to}
                             pl0^.name2, {player name to exclude}
                             'Lost Member',  {news-header}
                             mailrequest_nothing, {mailrequest_constant}
                             uplc+player.name2+config.textcol1+' has left the '+gymcol+'Gym'+config.textcol1+'!',
                             uplc+player.name2+config.textcol1+' burned '+sex3[player.sex]+' membership card!',
                             '',
                             '');

             {online mail to all members in pl0^.team}
             Team_Online_Report_All(pl0^.team,'',uplc+player.name2+config.textcol1+' quit being a member at the '+gymcol
                                    +'Gym'+config.textcol1+'!');

             {let's break out of here. we are done}
             break;
            end;
           end;
          end; {for i:= .end.}

          d(15,'Goodbye!');

          {update player stats}
          player.gym_card:=0;
          user_save(player);

          crlf;
          leave_gym:=true;
         end;
        end;

       end;
   'T':begin {tug-of-war}

        crlf;
        crlf;
        if player.gym_sessions<1 then begin
         no_gym_sessions;
        end
        else begin
         tug_of_war;
        end;

       end; {tug-of-ware *end*}
   'W':begin {work out}
        crlf;
        if player.gym_sessions<1 then begin
         no_gym_sessions;
         pause;
        end
        else begin
         finished:=false;
         repeat

          crlf;
          crlf;

          {dumb-bell - hantel}

          {skivst†ng?}

          d(5,'Muscle & Competition');
          sd(2,mkstring(11,' '));menu('(D)umb-bell practice');
          sd(2,mkstring(11,' '));menu('(L)ift beer-barrels');
          sd(2,mkstring(11,' '));menu('(H)all of Fame Barrels');
          sd(2,mkstring(11,' '));menu('(R)eturn');
          sd(config.textcolor,'Train how :');

          {get user-input}
          ch:=upcase(getchar);

          {evaluate user-input}
          case ch of
           'R': finished:=true;
           'D':begin
                crlf;
                if confirm('Lift Dumb-bells','Y')=true then begin
                 if player.gym_sessions<1 then begin
                  no_gym_sessions;
                 end
                 else begin
                  dumb_bells;
                 end;
                end;

               end;
           'H':begin {hall of fame barrels}
                crlf;
                crlf;
                display_barrel_masters;
                pause;
               end;
           'L':begin {lift barrels}

                crlf;
                if confirm('Lift Barrels','Y')=true then begin
                 if player.gym_sessions<1 then begin
                  no_gym_sessions;
                 end
                 else begin
                  lift_barrels;
                 end;
                end;

               end;
          end; {case .end.}

         until finished;

        end;

       end; {work out .end.}

   'A':begin {abandon gym control}
        crlf;
        crlf;
        if player.gym_owner=0 then begin
         d(12,'You are not the owner!');
        end
        else begin
         if confirm('Leave Control of the '+gymcol+'Gym'+config.textcol1,'N')=false then begin
          d(15,'that was a wise decision!');
         end
         else begin
          {leave gym control}
          crlf;
          d(15,'You take your crew and leave the '+gymcol+'Gym'+uwhite+' for others to control...');
          d(15,'You leave with a membership card for each team member...');

          {inform team members}
          for i:=1 to 2 do begin

           case i of
            1: size:=fs(FsPlayer);
            2: size:=fs(FsNpc);
           end; {case .end.}

           for j:=1 to size do begin
            if load_character(pl0^,i,j)=true then begin

             if (pl0^.deleted=false) and
                (pl0^.team=player.team) and
                (pl0^.name2<>player.name2) then begin

              {update player stats}
              pl0^.gym_owner:=0;
              pl0^.gym_card:=1;

              user_save(pl0^);

              if is_online(pl0^.name2,online_player)=true then begin
               online_send_to_player(pl0^.name2,online_player,BroadCast_RemoveGym);
              end;

              {mail}
              post(MailSend,
              pl0^.name2,
              pl0^.ai,
              false,
              mailrequest_nothing,
              '',
              ulred+'Gym Rule Ended!'+config.textcol1,
              mkstring(15,underscore),
              uplc+player.name2+config.textcol1+' resigned your team from '+gymcol+'Gym'+config.textcol1+' control!',
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
              '',
              '');

             end;
            end;
           end; {for j:= .end.}
          end; {for i:= .end.}

          {update player stats}
          player.gym_owner:=0;
          player.gym_card:=1;
          user_save(player);

          {inform all nodes}
          online_send_to_all('Team '+utec+player.team+config.textcol1+' resigned as '+gymcol+'GYM'+config.textcol1
                             +' owners!',player.name2,player.name2);

          {news-paper}
          newsy(true,
          'Gym without control!',
          ' '+uplc+player.name2+config.textcol1+' resigned as '+gymcol+'Gym'+config.textcol1+' owner.',
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
   'M':begin {massage}
        crlf;
        {cost}
        cost:=player.level*450;
        ok:=false;

        {everybody but the owners must pay a fee for massage}
        if player.massage>=Config.MassageVisits then begin
         d(12,'You have already had your daily dose of massage!');
        end
        else if player.gym_owner=0 then begin
         crlf;
         if confirm('Pay '+uyellow+commastr(cost)+config.textcol1+' for a Massage','N')=true then begin
          if player.gold>=cost then begin
           d(config.textcolor,'You cough up the '+config.moneytype+'.');
           decplayermoney(player,cost);
           ok:=true;
          end
          else begin
           d(12,'You don''t have enough '+config.moneytype+'!');
          end;
         end
         else begin
          crlf;
          d(14,'Bah, why take a stupid massage!?');
          crlf;
         end;
        end
        else begin
         ok:=true;
        end;

        if ok then begin

         {choose oil}
         repeat
          crlf;
          crlf;
          d(config.textcolor,'What kind of '+oilcol+'Oil'+config.textcol1+' do you want?');
          menu('(W)hite Water - a real soul smoother. could improve your relations.');
          menu('(T)ox Utha''t - body enhancer. your mind and relations may suffer.');
          menu('(A)bort');
          sd(config.textcolor,'Select:');

          {get user-input}
          ch:=upcase(getchar);

         until ch in ['W','T','A'];

         {evaluate user-input}
         case ch of
          'W': my_oil:='White Water';
          'T': my_oil:='Tox Utha''t';
          'A': my_oil:='Abort';
         end; {case .end.}
         d(15,my_oil);

         if ch<>'A' then begin
          {updating player record}
          inc(player.massage);
          user_save(player);

          {getting a massage / restoring hitpoints /}
          crlf;
          d(global_plycol,config.gymmasseur+config.textcol1+' the masseur leads you to a secluded room downstairs.');
          sd(config.textcolor,'You undress and stretch out on a wooden barrack-bed...');
          make_delay_dots(config.textcolor,5,500);
          crlf;
          crlf;
          d(global_plycol,config.gymmasseur+config.textcol1+' makes his appearance a few minutes later, carrying ');
          d(config.textcolor,'a pail with '+oilcol+my_oil+config.textcol1+'.');
          crlf;

          {#1 - session}
          sd(global_plycol,config.gymmasseur+config.textcol1+' starts off by smearing your body with '+oilcol+my_oil
           +config.textcol1+'.');
          make_delay_dots(config.textcolor,5,500);
          crlf;
          {hitpoints max out}
          sd(14,'Ahhh..nice feeling...');
          d(15,'Your Hitpoints maxed out!');
          player.hps:=player.maxhps;
          {mana max out}
          if spell_user(player) then begin
           crlf;
           sd(14,'Ahhh..nice feeling...');
           d(15,'Your Mana maxed out!');
           player.mana:=player.maxmana;
          end;

          {#2 - session}
          crlf;
          sd(config.textcolor,'With his gentle hands, '+uplc+config.gymmasseur+config.textcol1
           +' relieves your body of its stiffness'
                              +'...');
          make_delay_dots(config.textcolor,5,500);
          crlf;

          {effects from 2nd session depends on Oil type.}
          {white water - gives healing potions and improved relations}
          {tox uthat - gives strength and worsened relations}
          case ch of
           'W':begin {white water}
                sd(14,'Ahhh..great feeling...');
                d(15,'Your pouch with Healing Potions is bulging!');

                if player.healing<config.maxheals then begin
                 player.healing:=config.maxheals+5;
                end
                else begin
                  player.healing:=player.healing+200;
                end;

                if x=0 then begin

                 {improve relation with player or Npc?}
                 tries:=0;
                 ok:=false;
                 repeat
                  ok:=false;
                  FileId:=random(2)+1;

                  case fileid of
                   1: x:=random(fs(fsplayer))+1;
                   2: x:=random(fs(fsnpc))+1;
                  end; {case .end.}

                  inc(tries);

                  {load character}
                  if load_character(pl0^,FileId,x)=true then begin

                   if (pl0^.name2<>player.name2) and
                      (pl0^.deleted=false) and
                      (pl0^.name1<>global_delname1) and
                      (pl0^.name2<>global_delname2) then begin
                    ok:=true;
                   end;
                  end;

                 until (ok) or (tries>25);

                 if ok then begin
                  crlf;
                  d(config.textcolor,'A name suddenly pops into your head; '+uplc+pl0^.name2+config.textcol1+'!');
                  d(config.textcolor,'Your mind is filled '+uyellow+'nice'+config.textcol1+' pictures of you and '+uplc
                                     +pl0^.name2+config.textcol1+' having a good time.');
                  d(15,'Your relation with '+uplc+pl0^.name2+uwhite+' improved!');

                  {improve pl0:s attitude to player}
                  Update_Relation(Relation_Better,1,pl0^,player,false,false);

                  {improve players attitude to pl0}
                  Update_Relation(Relation_Better,1,player,pl0^,false,false);

                 end;

                end;

               end; {white water *end*}
           'T':begin {tox uthat}
                sd(14,'Ahhh..great feeling...');
                d(15,'Your body is hardened by the oil!');

                if player.strength<32000 then begin
                 inc(player.strength,random(2)+1);
                end;

                {x:=0; {fusk!}
                if x=0 then begin

                 {worsen relation with player or Npc?}
                 tries:=0;
                 ok:=false;
                 repeat
                  ok:=false;
                  FileId:=random(2)+1;
                  case fileid of
                   1: x:=random(fs(fsplayer))+1;
                   2: x:=random(fs(fsnpc))+1;
                  end; {case .end.}

                  inc(tries);

                  {load character}
                  if load_character(pl0^,FileId,x)=true then begin

                   if (pl0^.name2<>player.name2) and
                      (pl0^.deleted=false) and
                      (pl0^.name1<>global_delname1) and
                      (pl0^.name2<>global_delname2) then begin
                    ok:=true;
                   end;
                  end;

                 until (ok) or (tries>25);

                 if ok then begin
                  crlf;
                  d(config.textcolor,'A name suddenly pops into your head; '+uplc+pl0^.name2+config.textcol1+'!');
                  d(config.textcolor,'Your mind is filled '+ulgray+'dark'+config.textcol1+' thoughts of you inflicting'
                                      +' pain on '+uplc+pl0^.name2+config.textcol1+'!');
                  d(global_plycol,pl0^.name2+config.textcol1+' is scum and must die!');

                  d(15,'Your relation with '+uplc+pl0^.name2+uwhite+' is sinking into a bottomless pit!');

                  {worsen players attitude to pl0}
                  Update_Relation(Relation_Worsen,2,player,pl0^,true,false);

                 end;

                end;

               end;
          end; {case .end.}

          {news-paper}
          Newsy(true,
          'Massage',
          ' '+uplc+player.name2+config.textcol1+' the '+race_display(2,player.race,0)+', enjoyed massage at the '+gymcol
             +'Gym'+config.textcol1+'.',
          ' '+uplc+player.name2+config.textcol1+' used '+oilcol+my_oil+config.textcol1+' oil to relax '
             +sex3[player.sex]+' body.',
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
   'D':begin {distribute club-card}

        if player.gym_owner=0 then begin
         crlf;
         crlf;
         d(12,'Fool! You are not the owner!');
         pause;
        end
        else begin

         crlf;
         crlf;
         d(config.textcolor,'Who should get a Member Card?');
         sd(config.textcolor,':');

         s:=get_string(20);

         found:=false;
         abort:=false;

         {searching among the humans and NPCs}
         for i:=1 to 2 do begin

          case i of
           1: size:=fs(FsPlayer);
           2: size:=fs(FsNpc);
          end; {case .end.}

          for j:=1 to size do begin

           if load_character(pl0^,i,j)=true then begin

            if (findsub(s,pl0^.name2)) and
               (pl0^.deleted=false) and
               (pl0^.name2<>player.name2) then begin

             if confirm(uplc+pl0^.name2+config.textcol1,'N')=true then begin

              {is the other player a OWNER?}
              if pl0^.gym_owner>0 then begin
               crlf;
               d(12,'Fool! '+uplc+pl0^.name2+ulred+' is one of the owners!');
              end
              {is the other player a MEMBER?}
              else if pl0^.gym_card>0 then begin
               crlf;
               d(global_plycol,pl0^.name2+ulred+' is a already a member!');
              end
              else begin
               {we have found our target}
               found:=true;
               break;
              end;
             end
             else begin
              if confirm('Continue search','Y')=false then begin
               abort:=true;
               break;
              end;
             end;
            end;
            if (found) or (abort) then break;
           end;

          end; {for j:= .end.}
          if (found) or (abort) then break;
         end; {for i:= .end.}

         {target found - let us hand out a membership card}
         if found then begin
          crlf;
          d(global_plycol,pl0^.name2+config.textcol1+' has access to the '+gymcol+'Gym'+config.textcol1+'!');

          {update other player}
          pl0^.gym_card:=1;
          user_save(pl0^);

          if is_online(pl0^.name2,online_player)=true then begin
           online_send_to_player(pl0^.name2,online_player,BroadCast_NewGymCard);
           online_send_to_player(pl0^.name2,online_player,uplc+player.name2+config.textcol1+' gave you access to the '+gymcol
                                    +'Gym'+config.textcol1+'!');
          end;

          {inform owners teammates}
          Team_Report_All(player.team,  {team to send message to}
                          player.name2, {player name to exclude}
                          'The Gym',    {news-header}
                          mailrequest_nothing, {mailrequest_constant}
                          uplc+player.name2+config.textcol1+' gave '+uplc+pl0^.name2
                              +config.textcol1+' access to the '+gymcol+'Gym'+config.textcol1+'.',
                          '',
                          '',
                          '');

          {mail other player}
          post(MailSend,
          pl0^.name2,
          pl0^.ai,
          false,
          mailrequest_nothing,
          '',
          uyellow+'Gym Access'+config.textcol1,
          mkstring(10,underscore),
          uplc+player.name2+config.textcol1+' gave you access to the '+gymcol+'Gym'+config.textcol1+'!',
          'You a place to work out!',
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

          {news-paper}
          Newsy(true,
          'The Gym',
          ' '+uplc+pl0^.name2+config.textcol1+' was given access to the '+gymcol+'Gym'+config.textcol1+' by '+uplc
             +player.name2+config.textcol1+'.',
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
   'B':begin {barrel masters / strongest character in the game}

        crlf;
        crlf;

        display_barrel_masters;


        if confirm('Do you want to try your luck','N')=true then begin
         if player.gym_sessions<1 then begin
          no_gym_sessions;
         end
         else begin
          lift_barrels;
         end;
        end;

       end; {barrel_masters *end*}
   'E':begin {exclude member}

        if player.gym_owner=0 then begin
         crlf;
         crlf;
         d(12,'Fool! You are not the owner of this Gym!');
         pause;
        end
        else begin

         crlf;
         crlf;
         d(config.textcolor,'Who should lose his club-card?');
         sd(config.textcolor,':');

         s:=get_string(20);

         found:=false;
         abort:=false;

         {searching among the humans and NPCs}
         for i:=1 to 2 do begin

          case i of
           1: size:=fs(FsPlayer);
           2: size:=fs(FsNpc);
          end; {case .end.}

          for j:=1 to size do begin

           if load_character(pl0^,i,j)=true then begin

            if (findsub(s,pl0^.name2)) and
               (pl0^.deleted=false) and
               (pl0^.name2<>player.name2) and
               (pl0^.gym_card>0) then begin

             if confirm(uplc+pl0^.name2+config.textcol1,'N')=true then begin

              {is the other player a owner?}
              if pl0^.gym_owner>0 then begin
               crlf;
               d(12,'Fool! You can''t ban one of the owners!');
              end
              else begin
               {we have found our target}
               found:=true;
               break;
              end;
             end
             else begin
              if confirm('Continue search','Y')=false then begin
               abort:=true;
               break;
              end;
             end;
            end;
            if (found) or (abort) then break;
           end;
          end; {for j:= .end.}
          if (found) or (abort) then break;
         end; {for i:= .end.}

         {target found}
         if found then begin
          crlf;
          d(global_plycol,pl0^.name2+config.textcol1+' has been kicked out from the '+gymcol+'Gym'+config.textcol1+'!');

          {update other player}
          pl0^.gym_card:=0;
          user_save(pl0^);

          if is_online(pl0^.name2,online_player)=true then begin
           online_send_to_player(pl0^.name2,online_player,BroadCast_RemoveGymCard);
           online_send_to_player(pl0^.name2,online_player,uplc+player.name2+config.textcol1+' kicked you out from the '
            +gymcol+'Gym'+config.textcol1+'!');
          end;

          {inform owners teammates}
          Team_Report_All(player.team,  {team to send message to}
                          player.name2, {player name to exclude}
                          'The Gym',    {news-header}
                          mailrequest_nothing, {mailrequest_constant}
                          uplc+player.name2+config.textcol1+' kicked '+uplc+pl0^.name2
                              +'s'+config.textcol1+' sorry butt out of the '+gymcol+'Gym'+config.textcol1+'!',
                          uplc+pl0^.name2+config.textcol1+' has no place to work out anymore.',
                          '',
                          '');

          {mail other player}
          post(MailSend,
          pl0^.name2,
          pl0^.ai,
          false,
          mailrequest_nothing,
          '',
          ulred+'Kicked out!'+config.textcol1,
          mkstring(11,underscore),
          uplc+player.name2+config.textcol1+' revoked your access to the '+gymcol+'Gym'+config.textcol1+'!',
          'You have no place to work out!',
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

          {news-paper}
          Newsy(true,
          'Brutal Methods at the Gym',
          ' '+uplc+pl0^.name2+config.textcol1+' was kicked out from the '+gymcol+'Gym'+config.textcol1+' by '+uplc
             +player.name2+config.textcol1+'.',
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
   'L':begin {list members}
        crlf;
        crlf;
        s:='People with access to the Gym';
        d(5,s);
        d(5,mkstring(length(s),underscore));

        counter:=0;
        lines:=2;
        abort:=false;
        for i:=1 to 2 do begin

         case i of
          1: size:=fs(FsPlayer);
          2: size:=fs(FsNpc);
         end; {case .end.}

         for j:=1 to size do begin

          {load character}
          if load_character(pl0^,i,j)=true then begin

           if (pl0^.deleted=false) and
              (pl0^.name2<>global_delname2) and
              (pl0^.name1<>global_delname1) and
              (pl0^.name2<>player.name2) then begin

            if (pl0^.gym_owner>0) or
               (pl0^.gym_card>0) then begin

             {counter}
             inc(counter);

             {#}
             sd(7,commastr(counter)+'. ');

             {name and race}
             sd(global_plycol,pl0^.name2+config.textcol1+' the '+race_display(2,pl0^.race,0)+'.');

             {owner/member}
             if pl0^.gym_owner>0 then begin
              sd(14,'   *OWNER*');
             end
             else if pl0^.gym_card>0 then begin
              sd(6,'   member');
             end;

             crlf;

             {pause}
             inc(lines);
             if lines>global_screenlines-2 then begin
              lines:=0;
              if confirm('Continue','Y')=false then begin
               abort:=true;
               break;
              end;
             end;

            end;
           end;
          end;

         end; {for j:= .end.}
         if abort then break;
        end; {for i:= .end.}

       end; {list members *end*}

  end; {case .end.}

 until leave_gym;

 crlf;
 crlf;
 d(14,'You leave the Gym');
 crlf;

 {discard pointer vars}
 disposal;

end; {The_Gym *END*}

Procedure Take_Over_The_Gym(const gym_owners:s30);
type FistFighterRec = Record {guy in fistfight}
      name : s30; {name}
      id   : s15;{id tag}
      sex  : byte; {sex}
      human:boolean; {true if this is a human controlled fighter}
      filnr: byte; {1=player file, 2=npc file}
      recnr: SmallWord; {record position}
      ai   : char; {'H'uman or 'C'omputer}
      attacking_team:boolean; {belong to the attacking team?}
      level   : SmallInt; {level}
      stamina : SmallInt; {stamina}
      strength: SmallInt; {strength}
      punch_effect:byte; {how many points are fighters punches worth}
      my_slayer: s30; {who knocked out this fighter}
      my_exp   : longint; {experience earned during fight}
      my_fate  : string[100]; {knocked out by whom? empty string means that he survived}
      my_kills : string[100]; {the guys fighter knocked out}
      mykills  : byte; {number of people fighter took out}
      me_nailed: SmallWord; {fighter was nailed in this round}
      move     : byte; {attackers currently selected combat move}
      skill    : array[1..global_maxcombat] of SmallInt; {close-combat skills}
     end; {fistfighter *end*}
var
    ch : char;

    i,
    j,
    size : word;

    s : s70;

  enemy_counter,
  friend_counter : byte;

  done,
  found : boolean;

  pl0 : UserRec;

  {defending team}
  defender: array[1..global_maxteammembers] of FistFighterRec;
  {attacking team}
  attacker: array[1..global_maxteammembers] of FistFighterRec;

  attack_power,
  defend_power : longint;

  target : byte;

  fight_over : boolean;


procedure disposal2;
begin
 {dispose of pointer variables}
end; {disposal2 *end*}

procedure boost_team_power(var power:longint; const fighter:fistfighterrec);
var k : byte;
begin

 if fighter.name='' then exit;

 {close combat skills}
 for k:=1 to global_maxcombat do begin
  power:=power+fighter.skill[k];
 end;

 {bonus for strength}
 power:=power+fighter.strength div 10;

 {bonus for stamina}
 power:=power+fighter.stamina div 7;

end; {boost_team_power .end.}

procedure init_fighter(var fighter:fistfighterrec);
var k : byte;
begin

 with fighter do begin
  name:='';
  id:='';
  level:=0;
  strength:=0;
  punch_effect:=0;
  stamina:=0;
  my_slayer:='';
  mykills:=0;
  my_exp:=0;
  for k:=1 to global_maxcombat do begin
   skill[k]:=0;
  end;
 end; {with .end.}

end; {init_fighter .end.}

procedure swap_fist_fighter(var f1,f2:fistfighterrec);
var temp : fistfighterrec;
begin
  temp:=f1;
  f1:=f2;
  f2:=temp;
end; {swap_fist_fighter *end*}

procedure setup_fighter(const ply:userrec;var fighter:fistfighterrec;
                        const filenr:word;attacking_team:boolean);
var k : byte;
begin

 {setting up a fistfighter}
 with fighter do begin
  name  :=ply.name2;
  id    :=ply.id;
  sex   :=ply.sex;
  if (ply.name2=player.name2) and (ply.id=player.id) then human:=true
                                                     else human:=false;
  filnr :=filenr;
  recnr :=ply.recnr; {position in userfile}
  ai    :=ply.ai;
  attacking_team:=attacking_team;
  level :=ply.level; {level}
  stamina :=ply.stamina; {stamina}
  strength:=ply.strength; {strength}
  punch_effect:=0; {punch effect}
  my_exp  :=0; {experience earned during fight}
  my_fate  :=''; {knocked out by whom? empty string means that he survived}
  my_kills  :=''; {names of the people the fighter managed to knock cold}
  me_nailed:=0; {i was nailed in this round}
  move:=0;
  for k:=1 to global_maxcombat do begin
   skill[k]:=ply.skill[k]; {close-combat skills}
  end;
 end; {with .end.}

end; {setup_fighter .end.}

{player tries to take over the Gym from team OWNERS}
var
    save_need,
    swap_needed,
    attackers_killed,
    defenders_killed,
    kamikaze_raid, {set to true if player attempts to take on the owning team on his own!}
    player_knocked : boolean;

    player_nemesis,
    target_name,target_name2:s30;
    kick_hit_string,
    kick_missed_string : s15;

    exp_earned : longint;
    fight_round : word;

    counter : byte;

    team_result : s100;
    my_experience : s90;
    evil_name,
    evil_team : s20;

    {news-paper array, displaying bout results}
    crew_news: array[1..global_maxteammembers] of s90;

begin {take_over_the_gym}

 {owners might be dead or in prison}
 {there will be a fight if at least 1 person from OWNERS can show}

 {player doing}
 {update online location}
 onliner.location:=onloc_gymfists;
 onliner.doing   :=location_desc(onliner.location);
 add_onliner(OUpdateLocation,onliner);

 {is there already a fight in progress?}
 if anybody_on_location(onloc_gymfists,player.name2) then begin
  d(12,'There is already a fight going on here!');
  d(12,'Come back later!');
  disposal2;
  exit;
 end;

 {init}
 for i:=1 to global_maxteammembers do begin
  init_fighter(defender[i]);
  init_fighter(attacker[i]);
 end; {for i:= .end.}
 player_knocked:=false;
 kamikaze_raid:=true;

 {there is no fight if a Gym Owner is online!}
 found:=false;

 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   {load character}
   if load_character(pl0,i,j)=true then begin

    if (pl0.team=gym_owners) and
       (pl0.team<>player.team) and
       (pl0.deleted=false) and
       (pl0.name2<>player.name2) and
       (pl0.gym_owner>0) and
       (is_online(pl0.name2,online_player)=true) then begin
     found:=true;
    end;
   end;

  if found then break;
  end; {for j:= .end.}
  if found then break;
 end; {for i:= .end.}

 if found then begin
  d(12,'Sorry, Gym owners currently online. Wait until they have left.');
  crlf;
  disposal2;
  exit;
 end;

 {lets begin with adding player to the team roster}
 setup_fighter(player,attacker[1],1,true);
 {the above-----------------------^ will not work if a local
  player enters with a npc character (then it should read 2!}

 {lets add as many of OWNERS and PLAYER members as we can, if "no show"
  then player wins on walk-over}
 enemy_counter:=0;
 friend_counter:=1;
 done:=false;
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   {load character}
   if load_character(pl0,i,j)=true then begin

    if (pl0.team=gym_owners) or (pl0.team=player.team) then begin

     if (pl0.name2<>player.name2) and
        (pl0.id<>player.id) and
        (pl0.deleted=false) then begin

      if (pl0.team=gym_owners) and (pl0.gym_owner>0) then begin
       if add_shadow(SAdd,pl0,player.name2,'FISTFIGHT IN THE GYM',0)=true then begin
        inc(enemy_counter);
        setup_fighter(pl0,defender[enemy_counter],i,false);
       end;
      end
      else if pl0.team=player.team then begin
       if add_shadow(SAdd,pl0,player.name2,'FISTFIGHT IN THE GYM',0)=true then begin
        kamikaze_raid:=false; {player has at least one friend!}
        inc(friend_counter);
        setup_fighter(pl0,attacker[friend_counter],i,true);
       end;
      end;

      if enemy_counter+friend_counter>=((global_maxteammembers*2)-1) then begin
       done:=true;
      end;

     end;
    end;
   end;

   if done then break;

  end; {for j:= .end.}
  if done then break;
 end; {for i:= .end.}

 {Walk-Over}
 if enemy_counter=0 then begin
  {swap leader ship}

  d(15,'The members in '+utec+gym_owners+uwhite+' are dead, incapacitated or otherwise');
  d(15,'unable to defend their turf! The '+gymcol+'GYM'+uwhite+' is yours! CONGRATULATIONS!');
  sd(config.textcolor,'informing the crew and the public...');

  {updating player stats}
  player.gym_owner:=1;
  player.gym_card:=0;
  user_save(player);

  {inform all nodes}
  online_send_to_all('The '+utec+player.team+config.textcol1+' crew took over the '+gymcol+'Gym'+config.textcol1
                     +'!',player.name2,player.name2);

  {inform former gang}
  {inform new gang}

  for i:=1 to 2 do begin

   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end; {case .end.}

   for j:=1 to size do begin

    if load_character(pl0,i,j)=true then begin

     if (pl0.team=player.team) or (pl0.team=gym_owners) then begin
      if (pl0.deleted=false) and
         (pl0.name2<>player.name2) then begin

       if pl0.team=player.team then begin
        {winning team}

        {update player stats}
        pl0.gym_owner:=1;
        pl0.gym_card:=0;
        user_save(pl0);

        if is_online(pl0.name2,online_player)=true then begin
         online_send_to_player(pl0.name2,online_player,BroadCast_AddGym);
         online_send_to_player(pl0.name2,online_player,uplc+player.name2+config.textcol1+' took over the '+gymcol+'Gym'
                                                +config.textcol1+'!');

        end;

        {mail player}
        post(MailSend,
        pl0.name2,
        pl0.ai,
        false,
        mailrequest_nothing,
        '',
        gymcol+'GYM CONTROL!'+config.textcol1,
        mkstring(12,underscore),
        uplc+player.name2+config.textcol1+' led the team to an amazing take-over!',
        'Without bloodshed you were able to grab the '+gymcol+'GYM'+config.textcol1+' from the '+utec+gym_owners
             +config.textcol1+' crew.',
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
       else if pl0.team=gym_owners then begin
        {losing team}

        {update player stats}
        pl0.gym_owner:=0;
        pl0.gym_card:=0;
        user_save(pl0);

        if is_online(pl0.name2,online_player)=true then begin
         online_send_to_player(pl0.name2,online_player,BroadCast_RemoveGym);
         online_send_to_player(pl0.name2,online_player,uplc+player.name2+config.textcol1+' took over the '+gymcol+'Gym'
                                                +config.textcol1+'!');

        end;

        {mail player}
        post(MailSend,
        pl0.name2,
        pl0.ai,
        false,
        mailrequest_nothing,
        '',
        ulred+'LOST GYM CONTROL!'+config.textcol1,
        mkstring(17,underscore),
        uplc+player.name2+config.textcol1+' led '+sex3[player.sex]+' team to an amazing victory!',
        'They were able to take-over the '+gymcol+'GYM'+config.textcol1+' without resistance from your gang!',
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

   end; {for j:= .end.}
  end; {for i:= .end.}

  case random(5) of
   0: s:='idiots';
   1: s:='wimps';
   2: s:='morons';
   3: s:='nerds';
   4: s:='half-wits';
  end; {case .end.}

  {news-paper}
  Newsy(true,'New Gym owners!',
  ' '+uplc+player.name2+config.textcol1+' and '+sex3[player.sex]+' crew took over the '+gymcol+'Gym'+config.textcol1
     +' without bloodshed!',
  ' The '+s+' in the '+utec+gym_owners+config.textcol1+' gang were unable to defend their turf!',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
  d(14,'done!');

  disposal2;
  exit;
 end;

 {Fist-Fight}
 clearscreen;
 crlf;
 d(config.textcolor,'You are facing the '+utec+gym_owners+config.textcol1+' crew.');
 for i:=1 to global_maxteammembers do begin
  if defender[i].name<>'' then begin
   {d(global_plycol,enemy[i].name+config.textcol1+' is waving '+sex3[enemy[i].sex]+' fists.')
   }
  end;
 end; {for i:= .end.}


 {odds}
 attack_power:=0;
 defend_power:=0;
 for i:=1 to global_maxteammembers do begin
  boost_team_power(defend_power,defender[i]);
  boost_team_power(attack_power,attacker[i]);
 end; {for i:= .end.}

 d(15,'Your punch power is '+commastr(attack_power));
 d(15,'Their punch power is '+commastr(defend_power));

 {estimate chances}
 if attack_power>defend_power then begin
  d(11,'You are strong enough to whip their butt!');
 end
 else if defend_power>attack_power then begin
  d(11,'They are going to whip your butt!');
 end
 else begin
  {even}
  d(11,'It''s going to be a close fight!');
 end;

 {menu}
 done:=false;
 repeat
  menu('(B)reak some bones');
  menu('(F)lee!');
  sd(config.textcolor,':');
  ch:=upcase(getchar);
  crlf;

  case ch of
   'B':begin {break bones}
        crlf;
        d(15,'Here we go!');
        done:=true;
       end;
   'F':begin {flee}
        crlf;
        d(14,'Chicken!');
        {remove all shadow players created by player}
        add_shadow(SRemoveShadows,player,'','going to sleep',0);
        done:=true;
       end;
  end; {case .end.}

  crlf;
 until done;

 {fight *start*}
 if ch='B' then begin

  fight_over:=false;
  fight_round:=0;
  player_knocked:=false;
  repeat

   inc(fight_round);

   {let team in turn make their move}
   for i:=1 to global_maxteammembers do begin
    if (attacker[i].name<>'') and (attacker[i].stamina>0) then begin
     {computer attacker picks a target}

     {are there any defenders left?}
     found:=false;
     for j:=1 to global_maxteammembers do begin
      if defender[j].stamina>0 then begin
       found:=true;
       break;
      end;
     end;

     done:=false;
     target:=0;

     if found=true then begin
      repeat
       found:=false;
       for j:=1 to global_maxteammembers do begin
        if (defender[j].name<>'') and (defender[j].stamina>0) then begin
         if random(4)=0 then begin
          target:=j;
          found:=true;
          break;
         end;
        end;
       end; {for j:= .end.}

       if found then done:=true;
      until done;
     end;

     {attacker has found a target}
     if target>0 then begin
      if attacker[i].human=true then begin

       target_name:=uplc+defender[target].name+config.textcol1;

       {human attack}
       sd(global_plycol,'You'+config.textcol1+' are facing '+target_name+'! ');

       {select move}
       attacker[i].move:=random(global_maxcombat)+1;

       {punch_effect}
       attacker[i].punch_effect:=random(attacker[i].skill[attacker[i].move])+3;

       case attacker[i].move of
        1:begin {tackle}
          sd(config.textcolor,'You tackle '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        2:begin {drop-kick}
          sd(config.textcolor,'You send off a drop-kick against '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        3:begin {uppercut}
          sd(config.textcolor,'You attempt an upper-cut against '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        4:begin {bite}
          sd(config.textcolor,'You make a desperate attempt to bite '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='PAIN!';
          kick_missed_string:='NO EFFECT';
          end;
        5:begin {leg-sweep}
          sd(config.textcolor,'You deliver a vicious leg-sweep aimed at '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='IT WORKED!';
          kick_missed_string:='MISS';
          end;
        6:begin {joint-break}
          sd(config.textcolor,'You attempt to break a bone in '+target_name2
                           +config.textcol1+' body!');
          kick_hit_string:='CRACK!';
          kick_missed_string:='MISS';
          end;
        7:begin {knife-hand}
          sd(config.textcolor,'You explode a knife-hand at '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        8:begin {nerve punch}
          sd(config.textcolor,'You send off a nerve punch against '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='STUNNED!';
          kick_missed_string:='NO EFFECT';
          end;
        9:begin {choke-hold}
          sd(config.textcolor,'You sneak up behind '+target_name+config.textcol1
                           +' for a devestating choke-hold!');
          kick_hit_string:='CHOKE!';
          kick_missed_string:='FAILED';
          end;
       10:begin {head-bash}
          sd(config.textcolor,'You try to head-bash '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
       11:begin {pull-hair}
          sd(config.textcolor,'You grab hold of '+target_name2+config.textcol1+' hair!');
          kick_hit_string:='PAIN!';
          kick_missed_string:='NO EFFECT';
          end;
       12:begin {kick}
           case random(3) of
            0:sd(config.textcolor,'You try to kick '+target_name+config.textcol1+' in the head!');
            1:sd(config.textcolor,'You try to kick '+target_name+config.textcol1
                               +' in the groin!');
            2:sd(config.textcolor,'You try to kick '+target_name+config.textcol1+' in the back!');
           end; {case .end.}
           kick_hit_string:='HIT!';
           kick_missed_string:='MISS';
          end;
       13:begin {straight-punch}
          sd(config.textcolor,'You send off a straight-punch at '+target_name+config.textcol1+'!');
          kick_hit_string:='SMACK!';
          kick_missed_string:='MISS';
          end;
       14:begin {ram}
          sd(config.textcolor,'You attempt to ram '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
       end; {case .end.}

      end
      else begin
       {computer attack}
       if defender[target].human then begin
        target_name:=uplc+'You';
        target_name2:='Your';
       end
       else begin
        target_name:=uplc+defender[target].name;
        target_name2:=target_name+'s';
       end;

       {computer must decide what move to try}
       attacker[i].move:=random(global_maxcombat)+1;

       {punch_effect}
       attacker[i].punch_effect:=random(attacker[i].skill[attacker[i].move])+3;

       case attacker[i].move of
        1:begin {tackle}
          sd(global_plycol,attacker[i].name+config.textcol1+' tackles '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        2:begin {drop-kick}
          sd(global_plycol,attacker[i].name+config.textcol1+' sends off a drop-kick against '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        3:begin {uppercut}
          sd(global_plycol,attacker[i].name+config.textcol1+' attempts an upper-cut against '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        4:begin {bite}
          sd(global_plycol,attacker[i].name+config.textcol1+' makes a desperate attempt to bite poor '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='PAIN!';
          kick_missed_string:='NO EFFECT';
          end;
        5:begin {leg-sweep}
          sd(global_plycol,attacker[i].name+config.textcol1+' delivers a vicious leg-sweep aimed at '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='IT WORKED!';
          kick_missed_string:='MISS';
          end;
        6:begin {joint-break}
          sd(global_plycol,attacker[i].name+config.textcol1+' makes a bold attempt to break a bone in '+target_name2
                           +config.textcol1+' body!');
          kick_hit_string:='CRACK!';
          kick_missed_string:='MISS';
          end;
        7:begin {knife-hand}
          sd(global_plycol,attacker[i].name+config.textcol1+' directs a nasty knife-hand towards '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
        8:begin {nerve punch}
          sd(global_plycol,attacker[i].name+config.textcol1+' sends off a nerve punch against '+target_name
                           +config.textcol1+'!');
          kick_hit_string:='STUNNED!';
          kick_missed_string:='NO EFFECT';
          end;
        9:begin {choke-hold}
          sd(global_plycol,attacker[i].name+config.textcol1+' sneaks up behind '+target_name+config.textcol1
                           +' for a devestating choke-hold!');
          kick_hit_string:='CHOKE!';
          kick_missed_string:='FAILED';
          end;
       10:begin {head-bash}
          sd(global_plycol,attacker[i].name+config.textcol1+' tries to head-bash '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
       11:begin {pull-hair}
          sd(global_plycol,attacker[i].name+config.textcol1+' grab hold of '+target_name2+config.textcol1+' hair!');
          kick_hit_string:='PAIN!';
          kick_missed_string:='NO EFFECT';
          end;
       12:begin {kick}
           case random(3) of
            0:sd(global_plycol,attacker[i].name+config.textcol1+' tries to kick '+target_name+config.textcol1+' in the head!');
            1:sd(global_plycol,attacker[i].name+config.textcol1+' tries to kick '+target_name+config.textcol1
                               +' in the groin!');
            2:sd(global_plycol,attacker[i].name+config.textcol1+' tries to kick '+target_name+config.textcol1+' in the back!');
           end; {case .end.}
           kick_hit_string:='HIT!';
           kick_missed_string:='MISS';
          end;
       13:begin {straight-punch}
          sd(global_plycol,attacker[i].name+config.textcol1+' sends off a straight-punch at '+target_name+config.textcol1+'!');
          kick_hit_string:='SMACK!';
          kick_missed_string:='MISS';
          end;
       14:begin {ram}
          sd(global_plycol,attacker[i].name+config.textcol1+' attempts to ram '+target_name+config.textcol1+'!');
          kick_hit_string:='HIT!';
          kick_missed_string:='MISS';
          end;
       end; {case .end.}

      end;

      {attack result}
      make_delay_dots(config.textcolor,5,1);
      if random(2)=0 then begin
       d(15,kick_hit_string);

       if attacker[i].punch_effect>8 then begin
        d(15,'*POWER HIT!*');
       end;

       {defenders stamina goes down}
       dec(defender[target].stamina,attacker[i].punch_effect);

       if defender[target].stamina<1 then begin

        {set attacker history values}
        if attacker[i].my_kills<>'' then begin
         attacker[i].my_kills:=attacker[i].my_kills+', ';
        end;
        attacker[i].my_kills:=attacker[i].my_kills+uplc+defender[target].name+config.textcol1;
        attacker[i].mykills:=attacker[i].mykills+1;
        {set attacker exp}
        exp_earned:=defender[target].level*250;
        attacker[i].my_exp:=attacker[i].my_exp+exp_earned;

        {set defender history values}
        defender[target].me_nailed:=fight_round;
        defender[target].my_slayer:=attacker[i].name;
        defender[target].my_fate:=uplc+attacker[i].name+config.textcol1+
                                  ' knocked you out!';

        if defender[target].human then begin
         {player was knocked out!}
         show_usurper_data(picture_DEATH_HEAD,false);
         d(12,'**YOU ARE OUT!**');
         player_knocked:=true;
         player_nemesis:=attacker[i].name;
        end
        else begin
         {computer player was knocked out}
         show_usurper_data(picture_DEATH_HEAD,false);
         {player did it!}
         if attacker[i].human then begin
          d(14,'YOU KNOCKED OUT '+defender[target].name+'!');
          d(14,'YOU RECEIVE '+uwhite+commastr(exp_earned)+uyellow+' EXPERIENCE POINTS!');
         end
         else begin
          d(12,defender[target].name+' WAS KNOCKED OUT!');
         end;
        end;
       end;
      end
      else begin
       {attackers move failed/missed}
       d(12,kick_missed_string);
      end;
     end;

    end;
   end; {for i:= .end.}

   {swap teams}
   for i:=1 to global_maxteammembers do begin
    swap_fist_fighter(attacker[i],defender[i]);
   end; {for i:= .end.}

   {is fight over?}
   attackers_killed:=true;
   defenders_killed:=true;
   for i:=1 to global_maxteammembers do begin
    if (attacker[i].name<>'') and (attacker[i].stamina>0) then begin
     attackers_killed:=false;
    end;
    if (defender[i].name<>'') and (defender[i].stamina>0) then begin
     defenders_killed:=false;
    end;
   end; {for i:= .end.}

   if (attackers_killed=true) or (defenders_killed=true) then begin
    fight_over:=true;
   end;

  until fight_over;

  {correct teams/swap them if necessary}
  swap_needed:=false;
  if (attackers_killed=false) and (player_knocked=true) then begin
   swap_needed:=true;
  end
  else if (attackers_killed=true) and (player_knocked=false) then begin
   swap_needed:=true;
  end;

  if swap_needed=true then begin
   attackers_killed:=false;
   defenders_killed:=true;
   for i:=1 to global_maxteammembers do begin
    swap_fist_fighter(attacker[i],defender[i]);
   end; {for i:= .end.}
  end;

  if attackers_killed then begin
   crlf;
   d(12,'YOU LOST! YOU ARE NOT ONLY SLOW IN COMBAT, BUT YOUR JUDGMENTAL');
   d(12,'SKILL STINKS!');
  end
  else begin
   crlf;
   d(14,'YOU BEAT THEM! CONGRATULATIONS!');
  end;

  {news-paper}
  if attackers_killed then begin
   {attacker lost}
   {creating crew_news[x] strings}
   counter:=0;
   for i:=1 to global_maxteammembers do crew_news[i]:='';
   for i:=1 to global_maxteammembers do begin
    if (attacker[i].name<>'') and (attacker[i].stamina<1) then begin
      inc(counter);

    
      crew_news[counter]:=ulred+'  -'+uplc+attacker[i].name+config.textcol1+' was '+maim_verb+' by '+uplc+attacker[i].my_slayer
                          +config.textcol1+'!';
    end;
   end; {for i:= .end.}

   if kamikaze_raid then begin
    s:=' '+uplc+player.name2+config.textcol1+' tried to grab control of the Gym.';
   end
   else begin
    s:=' '+uplc+player.name2+config.textcol1+' and '+sex3[player.sex]+' team attempted to grab control of the Gym.';
   end;

   newsy(true,
   'Fist-Fight at the Gym!',
   s,
   ' '+utec+gym_owners+config.textcol1+' engaged '+uplc+player.name2+'s'+config.textcol1+' crew in a wild brawl!',
   ' '+ulred+player.name2+'s pitiful attempt for power failed miserably!'+config.textcol1,
   ' '+ulred+player.name2+'s crew was '+crushed_verb+':'+config.textcol1,
   crew_news[1],
   crew_news[2],
   crew_news[3],
   crew_news[4],
   crew_news[5]);

  end
  else begin
   {news-paper}
   {attacker lost}
   {creating crew_news[x] strings}
   counter:=0;
   for i:=1 to global_maxteammembers do crew_news[i]:='';
   for i:=1 to global_maxteammembers do begin
    if (defender[i].name<>'') and (defender[i].stamina<1) then begin
      inc(counter);
      crew_news[counter]:=ulred+'  -'+uplc+defender[i].name+config.textcol1+' was '+maim_verb+' by '+uplc+defender[i].my_slayer
                          +config.textcol1+'!';
    end;
   end; {for i:= .end.}

   if kamikaze_raid then begin
    s:=' '+uplc+player.name2+config.textcol1+' tried to grab control of the Gym.';
   end
   else begin
    s:=' '+uplc+player.name2+config.textcol1+' and '+sex3[player.sex]+' team attempted to grab control of the Gym.';
   end;

   newsy(true,
   'New Gym Owners!',
   s,
   ' '+utec+gym_owners+config.textcol1+' engaged '+uplc+player.name2+'s'+config.textcol1+' crew in a wild brawl!',
   ' '+uplc+player.name2+'s'+config.textcol1+' attempt for power was a success!',
   ' The '+utec+gym_owners+config.textcol1+' crew was '+crushed_verb+':',
   crew_news[1],
   crew_news[2],
   crew_news[3],
   crew_news[4],
   crew_news[5]);

  end;

  {mail team-members}
  for i:=1 to global_maxteammembers do begin

   if (defender[i].name<>'') and (defender[i].human=false) then begin

    if defender[i].my_fate='' then begin
     defender[i].my_fate:='You stood the whole fight! Well done!';
    end;
    if defender[i].my_kills='' then begin
     defender[i].my_kills:=ulred+'You failed to knock out any of your opponents.'+config.textcol1;
    end
    else begin
     if defender[i].mykills>1 then begin
      {replace the last "," with "and"}
      defender[i].my_kills:=fix_last_kill(defender[i].my_kills);
     end;
     defender[i].my_kills:='You floored '+defender[i].my_kills+'.';
    end;

    {set team_result string}
    if defenders_killed then begin
     team_result:=ulred+'Your crew was stomped out! YOU LOST CONTROL OF THE GYM!'+config.textcol1;
    end
    else begin
     team_result:=uyellow+'Your team crushed the opposition! You keep the Gym!'+config.textcol1;
    end;

    {set gained experience string}
    if defender[i].my_exp>0 then begin
     my_experience:='You earned '+uwhite+commastr(defender[i].my_exp)+config.textcol1+' experience points from this fight!';
    end
    else begin
     my_experience:='';
    end;

    {name calling, attacking team-leader}
    case random(5) of
     0: evil_name:='evil';
     1: evil_name:='cowardly';
     2: evil_name:='vicious';
     3: evil_name:='mean';
     4: evil_name:='dirty';
    end; {case .end.}

    {name calling, attacking team}
    case random(4) of
     0: evil_team:='band of misfits';
     1: evil_team:='band of cutthroats';
     2: evil_team:='band of evil-doers';
     3: evil_team:='band';
    end; {case .end.}

    post(MailSend,
    defender[i].name,
    defender[i].ai,
    false,
    mailrequest_nothing,
    '',
    ulcyan+'Fist-Fight!'+config.textcol1,
    cool_string(11,'=','-',10,5),
    'The '+evil_name+' '+race_display(2,player.race,0)+' '+uplc+player.name2+config.textcol1+' gathered '+sex3[player.sex]
          +' '+evil_team+' to erase',
    'your crew from the Gym! You were engaged in a fist-fight!',
    defender[i].my_fate,
    defender[i].my_kills,
    my_experience,
    team_result,
    '',
    '',
    '',
    '',
    '',
    '',
    '');

   end;

   if (attacker[i].name<>'') and (attacker[i].human=false) then begin

    if attacker[i].my_fate='' then begin
     attacker[i].my_fate:='You stood the whole fight! Well done!';
    end;
    if attacker[i].my_kills='' then begin
     attacker[i].my_kills:=ulred+'You failed to knock out any of your opponents.'+config.textcol1;
    end
    else begin
     if attacker[i].mykills>1 then begin
      {replace the last "," with "and"}
      attacker[i].my_kills:=fix_last_kill(attacker[i].my_kills);
     end;
     attacker[i].my_kills:='You floored '+attacker[i].my_kills+'.';
    end;

    {set team_result string}
    if attackers_killed then begin
     team_result:=ulred+'Your crew was stomped out!'+config.textcol1;
    end
    else begin
     team_result:=uyellow+'Your team crushed the opposition! You are in control of the Gym!'+config.textcol1;
    end;

    {set gained experience string}
    if attacker[i].my_exp>0 then begin
     my_experience:='You earned '+uwhite+commastr(attacker[i].my_exp)+config.textcol1+' experience points from this fight!';
    end
    else begin
     my_experience:='';
    end;

    post(MailSend,
    attacker[i].name,
    attacker[i].ai,
    false,
    mailrequest_nothing,
    '',
    ulcyan+'Fist-Fight!'+config.textcol1,
    cool_string(11,'=','-',10,5),
    'Your team-leader '+uplc+player.name2+config.textcol1+' called on you to help your team',
    'take over the Gym! You engaged the '+utec+gym_owners+config.textcol1+' crew.',
    attacker[i].my_fate,
    attacker[i].my_kills,
    my_experience,
    team_result,
    '',
    '',
    '',
    '',
    '',
    '',
    '');

   end;

  end; {for i:= .end.}

 end;
 {fight *end*}

 if player_knocked then begin
  d(config.textcolor,'You dream of the stars...');
 end;

 {remove shadow players, from both teams}
 for i:=1 to global_maxteammembers do begin

  if (defender[i].name<>'') and
     (defender[i].name<>player.name2) and
     (defender[i].id<>player.id) then begin

   if load_character(pl0,defender[i].filnr,defender[i].recnr)=true then begin

    save_need:=false;
    {update with new xp?}
    if defender[i].my_exp>0 then begin
     IncPlayerExp(pl0,defender[i].my_exp);
     save_need:=true;
    end;

    {if attackers were successful then we must update the gym flags}
    if defenders_killed=true then begin
     pl0.gym_owner:=0;
     pl0.gym_card:=0;
     save_need:=true;
    end;

    if save_need=true then begin
     user_save(pl0);
    end;

    {remove offline player}
    add_shadow(SRemove,pl0,'','',0);
   end;

  end;

  if (attacker[i].name<>'') and
     (attacker[i].name<>player.name2) and
     (attacker[i].id<>player.id) then begin

   if load_character(pl0,attacker[i].filnr,attacker[i].recnr)=true then begin
    save_need:=false;

    {update with new xp?}
    if attacker[i].my_exp>0 then begin
     IncPlayerExp(pl0,attacker[i].my_exp);
     save_need:=true;
    end;

    if defenders_killed=true then begin
     pl0.gym_owner:=1;
     pl0.gym_card:=0;
     save_need:=true;
    end;

    if save_need=true then begin
     user_save(pl0);
    end;

    {remove shadow player}
    add_shadow(SRemove,pl0,'','',0);

   end;
  end;

 end; {for i:= .end.}

 if player_knocked=true then begin

  {mail player of his misfortune}
  s:='Fist-Fight';
  post(MailSend,
  player.name2,
  player.ai,
  false,
  mailrequest_nothing,
  '',
  ulred+s+config.textcol1,
  mkstring(length(s),underscore),
  'You were floored by '+uplc+player_nemesis+config.textcol1+' in a fist-fight.',
  'You failed in your attempt to take control of the '+gymcol+'Gym'+config.textcol1+'.',
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

 end;

end; {take_over_the_gym *end*}

end. {Unit GYM .end.}
