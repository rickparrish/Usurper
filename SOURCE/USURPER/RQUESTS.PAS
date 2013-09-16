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


Unit RQuests; {Usurper - Royal Quest Room}

Interface

         {** Note that some of the code/thinkning is duplicated in
             Kmaint.pas (the npc ruler code) }

Procedure Royal_Quests; {Quest Master}

Implementation

Uses Init, Cms, Jakob,
     Statusc, Various, Various2,
     Various3, News, Mail,
     File_io, Online;

var
    refresh : boolean;

Procedure Meny;
const offset = 22;
begin

 clearscreen;
 crlf;
 crlf;
 d(5,'-*- Quest Master -*-');
 d(config.textcolor,'You have entered Master '+uplc+config.questmaster+'s'+config.textcol1+' chambers.');
 d(config.textcolor,'He keeps record of all Quests in the Realm.');
 d(config.textcolor,'You should always consult with '+uplc+config.questmaster+config.textcol1+' before');
 d(config.textcolor,'sending someone on a mission.');
 crlf;

 menu2(ljust('(I)nitiate a Quest',offset));
 menu('(Q)uest Masters');

 menu('(A)bort a Quest');
 menu('(L)ist of quests');

 menu('(S)tatus');
 menu('(R)eturn to Great Hall');

end;

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   crlf;
   sd(config.textcolor,'Quest Master ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin

   crlf;
   sd(config.textcolor,'Quest Master (I,A,L,Q,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end;




Procedure Royal_Quests; {Main procedure}
var
   ch : char;

   i, j, y,
   counter : word;

   x: longint;

   done,
   found,
   no_more,
   go_ahead : boolean;

   minrange,
   maxrange : word;
   monsters : word;

   s : s100;

   Pl0 : ^UserRec;
   King : KingRec;
   Quest : QuestRec;
mtemp1 : array [1..global_maxmon] of s70;
 mtemp2 : array [1..global_maxmon] of integer;


begin

 {init pointer variables}
 new(pl0);

 {intro text}
 clearscreen;
 crlf;
 crlf;
 d(config.textcolor,'You enter the Chambers of Quest Master '+uplc+config.questmaster+config.textcol1);
 crlf;

 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_questmaster then begin
   refresh:=true;
   onliner.location:=onloc_questmaster;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  {menu}
  display_menu(true,true);

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user input}
  case ch of
   '?':begin {menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'Q':begin {list of top quest masters}
        quest_rankings;
       end;
   'L':begin {list of quests}
        list_quests(true); {display quests, true=include claimed quests}
       end;
   'A':begin {abort a Quest}
        list_quests(true); {display quests, true=include claimed quests}
       end;
   'I':begin {initiate a quest}

        crlf;
        crlf;

        if Config.AllowKingtoInitQuests=false then begin
         d(12,'The Super-God has ruled that no Quests can be issued!');
         crlf;
         pause;
         crlf;
        end
        else begin

         {check if king has any new quests left today (sysop configurable)
          check to see if the quest database already is full}
         load_king(fload,king);

         go_ahead:=true;
         if King.QuestsLeft<1 then begin
          d(12,'Sorry, You have already setup the maximum number of Quests today!');
          crlf;
          pause;
          go_ahead:=false;
         end
         else if (fs(fsquest)>=65000) or
                 (fs(fsquest)>=Config.MaxQuestsAllowed) then begin

          no_more:=true;

          {check for deleted/completed quests in the database}
          for i:=1 to fs(fsquest) do begin
           {load quest}
           load_quest(fload,quest,i);

           if quest.deleted then begin
            no_more:=false;
            break;
           end;
          end; {for i:= .end.}

          {database is full}
          if no_more then begin
           d(12,'Sorry, no more quests can be created right now.');
           d(12,'The database is full.');
           crlf;
           go_ahead:=false;
          end;

         end;

         {setup a new quest}
         if (go_ahead=true) and
            (confirm('Setup a New Quest','Y')=true) then begin

          {text}
          crlf;
          d(14,'*New Quest*');

          {init quest}
          new_quest(quest);

          {id # number}
          quest.id:=crypt(20); {unique identification # number}

          {initiator}
          quest.initiator:=player.name2;

          {date}
          quest.date:=todays_date;

          {quest-type}
          quest.questtype:=SingleQuest;

          {quest-target}
          quest.questtarget:=qMonster;

          {quest-difficulty}
          quest.difficulty:=0;

          if quest.questtarget=qMonster then begin
           {set difficulty, which decides how many monsters player should encounter}
           crlf;
           d(6,'Set Quest difficulty (1-10) default is 5.');
           d(6,'A higher diffuculty means that the player will encounter');
           d(6,'more and nastier monsters.');
           sd(3,'Diff (1-10) [5]:');
           x:=get_number2(1,10,5);

           quest.difficulty:=x;

           {set how many monsters player will encounter, depending on
            difficulty.
            also set file ranges, where to get monsters from; the higher
            the more dangerous}

           case quest.difficulty of
            1:begin

               {# of monsters}
               monsters:=1;

               {min and maxrange, where in monster file to fetch monsters}
               minrange:=1;
               maxrange:=100;

              end;
            2:begin
               monsters:=3;
               minrange:=101;
               maxrange:=200;

              end;
            3:begin
               monsters:=4;
               minrange:=201;
               maxrange:=300;

              end;
            4:begin
               monsters:=6;
               minrange:=301;
               maxrange:=400;

              end;
            5:begin
               monsters:=7;
               minrange:=401;
               maxrange:=500;

              end;
            6:begin
               monsters:=9;
               minrange:=501;
               maxrange:=600;

              end;
            7:begin
               monsters:=10;
               minrange:=601;
               maxrange:=700;

              end;
            8:begin
               monsters:=12;
               minrange:=701;
               maxrange:=800;

              end;
            9:begin
               monsters:=14;
               minrange:=801;
               maxrange:=900;

              end;
            10:begin
                monsters:=17;
                minrange:=901;
                maxrange:=999;
               end;
           end; {case .end.}

           {safety catch}
           if monsters>global_maxmon then monsters:=global_maxmon;

           {collect some monsters}
           done:=false;
           counter:=0;
           repeat

            {pick random monster}
             x:=random(maxrange - minrange + 1)+minrange;


            {lets see if we already have this type of monster}
            found:=false;
            for i:=1 to global_maxmon do begin
             if quest.monsters[i,1]=x then begin
              inc(quest.monsters[i,2]);
              inc(counter);
              found:=true;
              break;
             end;
            end; {for i:= .end.}

            if found=false then begin
             {find an empty slot to put new monster in}
             for i:=1 to global_maxmon do begin
              if quest.monsters[i,1]=0 then begin
               quest.monsters[i,1]:=x;
               inc(quest.monsters[i,2]);
               inc(counter);
               found:=true;
               break;
              end;
             end; {for i:= .end.}
            end;

            if found=false then begin
             {no empty slot found! we just increase the number of monsters}
             inc(quest.monsters[1,2]);
             inc(counter);
            end;

            {are we done?}
            if counter=monsters then begin
             done:=true;
            end;

           until done;

           {display monsters}
           d(15,'player must defeat');
             for i:=1 to global_maxmon do begin
   mtemp1[i]:='';
   mtemp2[i]:=0;
  end;

  for i:=1 to global_maxmon do begin
   found:=false;
   if quest.monsters[i, 1]>0 then begin
                 load_monster(quest.monsters[i,1],1);
for j:=1 to global_maxmon do begin
     if mtemp1[j]=monster[1]^.name then begin
      inc(mtemp2[j],quest.monsters[i,2]);
      found:=true;
      break;
     end;
    end;
    if found=false then begin
     for j:=1 to global_maxmon do begin
      if mtemp1[j]='' then begin
       mtemp1[j]:=monster[1]^.name;
       inc(mtemp2[j],quest.monsters[i,2]);
       break;
      end;
     end;
    end;
   end;
  end; {for i:= .end.}

  x:=0;
  y:=0;
  for i:=1 to global_maxmon do begin
   if mtemp1[i]<>'' then begin
    inc(y);
    if y<>1 then begin
     sd(global_moncol,', ');
    end;

    inc(x);
    if x>3 then begin
     x:=0;
     crlf;
    end;

    if mtemp2[i]=1 then sd(global_moncol,mtemp1[i])
                   else sd(global_moncol,commastr(mtemp2[i])+' '+mtemp1[i]);
    if mtemp2[i]>1 then begin
     sd(global_moncol,'s');
    end;

   end;
  end;

           pause;

          end; {if quest.questtarget = monster .end.}


          {deleted}
          quest.deleted:=false;

          {comment}
          quest.comment:=emptystr;
          crlf;
          if confirm('Add a comment to the Quest','Y')=true then begin
           sd(config.textcolor,':');
           quest.comment:=get_string(58);
          end;

          {name of player occupying quest}
          quest.occupier:=emptystr;

          {# of days player has occupied quest}
          quest.occdays:=0;

          {# of days player has to complete the quest}
          crlf;
          d(15,'How many day(s) should a player have to complete the quest.');
          d(15,'(before it''s considered a failure)');
          crlf;

          sd(3,'Days (1-15) [2]:');
          x:=get_number2(1,15,2);

          quest.daystocomple:=x;

          {has offer been refused 1=delete,2=add to list}
          quest.offerrefused:=0;

         
          {min level required to take quest}
          quest.minlevel:=1;

          crlf;
          if confirm('Set Minimum Character level to claim Quest','N')=true then begin
           sd(3,'Minimum (1-100) [1]:');
           x:=get_number2(1,100,1);

           quest.minlevel:=x;
          end;

          {max level required to take quest}
          quest.maxlevel:=100;
          if confirm('Set Maximum Character level to claim Quest','N')=true then begin
           sd(3,'Maximum ('+commastr(quest.minlevel)+'-100) [100]:');
           x:=get_number2(quest.minlevel,100,100);

           if x=0 then x:=100;

           quest.maxlevel:=x;
          end;

          {display min and max level}
          crlf;
          d(config.textcolor,'Characters between level '+uwhite+commastr(quest.minlevel)+config.textcol1+' and '
              +uwhite+commastr(quest.maxlevel)+config.textcol1+' are allowed to claim this Quest.');


          {h„r kan man ju l„gga till. Race/Class/Quests completed needed to
           claim quest}

          {reward size}
          crlf;
          d(15,'How big should the REWARD be (0=nothing,1=low,2=medium,3=high).');
          crlf;

          sd(3,'Reward (1-3) [2]:');
          x:=get_number2(0,3,2);

          quest.reward:=x; {nothing,low,medium,high}

          {reward type}
          quest.rewardtype:=qExp;
          if confirm('Quest Reward is '+uwhite+'Experience points'+config.textcol1+' is this ok','Y')=false then begin
           done:=false;
           repeat
            crlf;
            d(3,'Set REWARD type:');
            menu('(E)xperience points');
            menu('(M)oney');
            menu('(H)ealing Potions');
            menu('(D)arkness');
            menu('(C)hivalry');
            menu('(N)othing');
            sd(config.textcolor,':');

            {get user-input}
            ch:=upcase(getchar);

            {evaluate user-input}
            case ch of
             'E':begin {experience points}
                  d(15,'experience');
                  quest.rewardtype:=qExp;
                  done:=true;
                 end;
             'M':begin {money}
                  d(15,config.moneytype);
                  quest.rewardtype:=qMoney;
                  done:=true;
                 end;
             'H':begin {healing potions}
                  d(15,'potions');
                  quest.rewardtype:=qPotions;
                  done:=true;
                 end;
             'D':begin {darkness}
                  d(15,'darkness');
                  quest.rewardtype:=qDarkness;
                  done:=true;
                 end;
             'C':begin {chivalry}
                  d(15,'chivalry');
                  quest.rewardtype:=qChivalry;
                  done:=true;
                 end;
             'N':begin {nothing}
                  d(15,'nothing');
                  quest.rewardtype:=qNothing;
                  done:=true;
                 end;
            end;

           until done;
           crlf;
          end;

          {penalty}
          quest.penalty:=0; {nothing,low,medium,high}
          if confirm('Should failure be punished','N')=true then begin
           crlf;
           {penalty size}
           crlf;
           d(15,'How big should the PENALTY be (0=nothing,1=low,2=medium,3=high).');
           crlf;

           sd(3,'Penalty (1-3) [1]:');
           x:=get_number2(0,3,1);
           quest.penalty:=x; {nothing,low,medium,high}

           {penalty type}
           quest.penaltyType:=qExp;
           if confirm('Quest Penalty is '+uwhite+'Experience points'+config.textcol1+' is this ok','Y')=false then begin
            done:=false;
            repeat
             crlf;
             d(3,'Set PENALTY type:');
             menu('(E)xperience points');
             menu('(M)oney');
             menu('(H)ealing Potions');
             menu('(D)arkness');
             menu('(C)hivalry');
             menu('(N)othing');
             sd(config.textcolor,':');

             {get user-input}
             ch:=upcase(getchar);

             {evaluate user-input}
             case ch of
              'E':begin {experience points}
                   d(15,'experience');
                   quest.penaltytype:=qExp;
                   done:=true;
                  end;
              'M':begin {money}
                   d(15,config.moneytype);
                   quest.penaltytype:=qMoney;
                   done:=true;
                  end;
              'H':begin {healing potions}
                   d(15,'potions');
                   quest.penaltytype:=qPotions;
                   done:=true;
                  end;
              'D':begin {darkness}
                   d(15,'darkness');
                   quest.penaltytype:=qDarkness;
                   done:=true;
                  end;
              'C':begin {chivalry}
                   d(15,'chivalry');
                   quest.penaltytype:=qChivalry;
                   done:=true;
                  end;
              'N':begin {nothing}
                   d(15,'nothing');
                   quest.penaltytype:=qNothing;
                   done:=true;
                  end;
             end; {case .end.}

            until done;
            crlf;
           end;


          end;

          {is this quest forced upon occupier}
          quest.forced:=false;

          {offer this quest to a certain player}
          quest.offerto:=emptystr;
          if confirm('Make it a public Quest','Y')=false then begin
           crlf;
           d(15,'Who should this quest be proposed to?');
           sd(config.textcolor,':');

           s:=get_string(20);


           done:=false;
           for i:=1 to fs(fsplayer) do begin
            if done then break;
            load_character(pl0^,1,i);

            if (findsub(s,pl0^.name2)) and
               (pl0^.king=false) and
               (pl0^.name2<>global_delname2) and
               (pl0^.name2<>player.name2) and
               (pl0^.deleted=false) then begin

             if confirm(uplc+pl0^.name2+config.textcol1,'n')=true then begin
              if pl0^.ai='C' then begin
               d(global_plycol,pl0^.name2+config.textcol1+' is not interested!');
               pause;
              end
              else begin

               {force the quest upon receiver?}
               if Config.ForceQuests=true then begin

                if confirm('Force '+uplc+pl0^.name2+config.textcol1+' to accept the Quest','N')=true then begin
                 quest.forced:=true;
                end;

               end;

               {send proposal to character PL0}
               d(15,'Ok. Proposal has been sent to '+uplc+pl0^.name2+config.textcol1+'.');
               crlf;

               post(MailSend,
               pl0^.name2,
               pl0^.ai,
               false,
               mailrequest_QuestOffer,
               player.name2,
               quest.id, {first message line has the Quest ID # number}
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
               '',
               '',
               '');

               {if recipent is online}
               if is_online(pl0^.name2,online_player) then begin
                online_send_to_player(pl0^.name2,online_player,uplc+player.name2+config.textcol1+' has offered you a '+uquestc
                 +'QUEST'+config.textcol1+'!');
               end;

               done:=true;
              end;

             end
             else begin
              if confirm('Continue Search','Y')=false then begin
               done:=true;
              end;
             end;
            end;
           end; {for i:= .end.}

          end;

          if confirm('Save Quest','Y')=false then begin
           crlf;
           d(15,'Aborted.');
          end
          else begin

           crlf;

           d(config.textcolor,'You give the Quest scroll to '+uplc+config.questmaster);
           sd(global_plycol,config.questmaster+config.textcol1+' announces the quest...');

           {add new quest to database}
           add_quest(quest);

           {update king record}
           load_king(fload,king);
           Dec(king.QuestsLeft);
           load_king(fsave,king);

           case player.sex of
            1: s:='King';
            2: s:='Queen';
           end;

           {news-paper}
           Newsy(true,
           'New Quest',
           ' '+s+' '+uplc+player.name2+config.textcol1+' initiated a '+uquestc+'Quest'+config.textcol1+'!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {inform other nodes}
           online_send_to_all(uplc+player.name2+config.textcol1+' initiated a '+uquestc+'QUEST'+config.textcol1+'!'
                             ,player.name2,'');

           {quest has been added}
           crlf;
           crlf;
           d(15,'Done. (let them come and claim it!)');

          end;

          crlf;
         end;

        end;

       end;
  end; {case .end.}

 until ch='R';

 {exit text}
 crlf;
 crlf;
 d(config.textcolor,'You take the winding Staircase down to the Great Hall..');
 crlf;

 {dispose pointer variables}
 dispose(pl0);

end; {Royal_Quests *end*}

end. {RQuests .end.}

{type QuestRec = Record Royal initiated Quests}

  {    Initiator   : s30; {name of (KING/QUEEN) who set this quest}
  {    date        : string[6]; {init date}
  {    QuestType   : QuestTypes; {single or team effort}
  {    QuestTarget : QuestTargets; {monsters,assassinatio,seduce,claim town,gang war}
  {    deleted     : boolean; {is this quest deleted}
  {    comment     : s90; {comment by initiator}
  {    occupier    : s30; {is quest taken at this moment/name of the person}
  {    occdays     : SmallWord; {quest has been occupied for X days}
  {    daystocomple: SmallWord; {days given to complete quest before failed}

  {    offerto     : s30; {is this quest an offer a player}
  {    offerrefused: byte; {if offer is refused (1=delete,2=add to list}
  {    forced      : boolean; {is quest forced upon OCCUPIER}
  {    minlevel    : SmallWord; {min level required to take on quest}
  {    maxlevel    : SmallWord; {max level required to take on quest}

  {    reward      : byte; {low,medium,high}
  {    rewardtype  : qrewardtypes;

      penalty     : byte; {low,medium,high}
  {   penaltytype : qrewardtypes;

      {player record should also save number of quests completed by user}
      {also failed, perhaps}




