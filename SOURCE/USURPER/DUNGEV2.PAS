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


Unit DungEv2; {Usurper - Dungeon Events, [2/2]}

Interface {More Events in the Dungeons...continued from Dungeon Events,
           dungevc.pas}

Uses Init;

Procedure Merchant(var pl1,pl2,pl3,pl4:UserRec);
Procedure Beggar  (var pl1,pl2,pl3,pl4:UserRec);
Procedure Strangers(var pl1,pl2,pl3,pl4:UserRec);
Function Witch_Doctor : boolean;
Procedure Sniffing_Glue(var pl1,pl2,pl3,pl4:UserRec);

Implementation

Uses Cms, Jakob, Various,
     Various2, Various3, PlvsMon,
     SpellsU, Invent, News,
     Mail, File_Io;

Procedure Sniffing_Glue; {this is not healthy!}
var x : longint;
begin
 clearscreen;
 crlf;
 crlf;
 d(15,'-*Dungeon Event*-');
 d(config.textcolor,'You have found a '+uitemc+'glue'+config.textcol1+' potion!');

 if confirm('Sniff it','Y')=true then begin
  crlf;
  sd(config.textcolor,'You put the potion under your nose...ahhhhh');
  make_delay_dots(config.textcolor,8,550);
  crlf;

  {earn experience points}
  x:=player.level*500;
  incplayerexp(player,x);
  d(15,'YOU EARNED '+commastr(x)+' EXPERIENCE POINTS!');

  {become addicted}
  x:=random(5)+5;
  player.addict:=player.addict+x;
  if player.addict>100 then player.addict:=100;
  d(12,'YOUR DRUG ADDICTION RAISED TO '+commastr(player.addict)+'% !');

  {news-paper}
  newsy(true,
  'Glue Sniffer',
  ' '+uplc+player.name2+config.textcol1+' the '+race_display(2,player.race,0)+' sniffed Glue in the dungeons.',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');



 end
 else begin
  d(15,'A wise decision.');
 end;

end; {sniffing_glue *end*}

Function Witch_Doctor : boolean;
const doctor = 'Mbluta';
var
    ch : char;
    cost : longint;

begin

 cost:=player.level*12500;

 if player.gold>=cost then begin

 clearscreen;
 crlf;
 crlf;
 d(15,'-*Dungeon Event*-');
 d(config.textcolor,'You meet with the evil Witch-Doctor '+uplc+doctor+config.textcol1+'.');
 d(config.textcolor,uplc+doctor+config.textcol1+' wants '+uyellow+commastr(cost)+config.textcol1+' of your hard '
                    +'earned '+many_money(cost)+'.');
 d(config.textcolor,'If you don''t pay he will use his voodoo dolls and make you suffer!');
 crlf;

 ch:=menu_choices('(P)ay','(R)un away','','','');

 case ch of
  'P':begin {pay}
       d(config.textcolor,'Reluctantly you give '+uplc+doctor+config.textcol1+' the '+config.moneytype+'.');
       d(global_plycol,doctor+config.textcol1+' wanders off in the dark labyrinths...');
       decplayermoney(player,cost);

       {news-paper}
       newsy(true,
       'Blackmail in the Dungeons',
       ' '+uplc+player.name2+config.textcol1+' the '+race_display(2,player.race,0)+' was forced to pay a heap of '
          +config.moneytype+' to',
       ' '+uplc+doctor+config.textcol1+' the witch-doctor!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

      end;
  'R':begin {run away}

       case random(2) of
        0:begin {escaped!}
           d(15,'*YOU MANAGE TO FLEE THE EVIL WITCH DOCTOR*');
          end;
        1:begin {escape failed!}
           d(12,'*YOU FAIL TO FLEE THE EVIL WITCH DOCTOR*');
           case random(3) of
            0:begin {lose xp}
               cost:=player.level*1500;
               if cost>player.exp then cost:=player.exp;
               d(12,'YOU LOSE '+commastr(cost)+' EXPERIENCE POINTS!');
               decplayerexp(player,cost);
              end;
            1:begin {lose dungeon fights}
               cost:=random(5)+1;
               if cost>player.fights then cost:=player.fights;
               d(12,'YOU LOSE '+commastr(cost)+' DUNGEON FIGHTS!');
               player.fights:=player.fights-cost;
              end;
            2:begin {lose player fights}
               cost:=random(3)+1;
               if cost>player.pfights then cost:=player.pfights;
               d(12,'YOU LOSE '+commastr(cost)+' PLAYER FIGHTS!');
               player.pfights:=player.pfights-cost;
              end;
           end; {case .end.}

           {news-paper}
           newsy(true,
           'Cursed by Witch-Doctor',
           ' '+uplc+player.name2+config.textcol1+' was cursed when trying to escape from',
           ' '+uplc+doctor+config.textcol1+', the evil witch-doctor!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

          end; {escape failed *end*}
       end; {case .end.}
       
       end 
      end;
witch_doctor:=true;      
 end else witch_doctor:=false;
end; {witch_doctor *end*}

Procedure Strangers; {encounter with strangers}
var foes, y, graves, cleared, danger:byte;
   s,s2 : s70;
   i,x,xx : longint;
   goahead, done : boolean;
   ch : char;
   player0 : ^UserRec;
   objekt : ^ORec;

   enemy_here : boolean;

   hps : longint;
   alivebefore,
   alivebefore1,alivebefore2,alivebefore3,alivebefore4:boolean;

begin

 {init pointer vars}
 new(objekt);   {player finds item in dungeons}

 clearscreen;
 crlf;
 crlf;
 d(7,'Encounter!');

 {number of strangers}
 foes:=random(10)+2;
 if foes<=team_active(pl1,pl2,pl3,pl4) then foes:=foes+3;
 if foes>global_maxmon then foes:=global_maxmon;

 {type of strangers}
 y:=random(4);
 case y of
  0: s2:='orcs';
  1: s2:='trolls';
  2: s2:='rogues';
  3: s2:='dwarves';
 end;

 sd(config.textcolor,'A group of approximately ');
 sd(7,commastr(foes)+' ');
 d(config.textcolor,s2+' is approaching!');

 {reset moners}
 Reset_Monsters;

 {short description of bandits}
      case y of
       0:begin {orcs}
          d(config.textcolor,'They are a poorly armed gang with sticks and clubs.');
          d(config.textcolor,'They don''t seem to have eaten for a very long time...');
          d(config.textcolor,'The leader is a tall beast with long fangs and many');
          d(config.textcolor,'scars in his face.');
          {create the band}
          for i:=1 to foes do begin
           case random(2) of
            0: s:='Orc';
            1: s:='Half-Orc';
           end;
           if i=1 then s:='Orc Leader'; {the boss}

           create_monster(i,              {#}
                          s,              {name}
                          global_dungeonlevel*5,          {hps}
                          global_dungeonlevel*2,          {strength}
                          global_dungeonlevel*2,          {defence}
                          'Husch Husch!', {phrase}
                          false,          {grabweap}
                          false,          {grabarm}
                          'Sword',        {weapon-string}
                          'Leather',      {armor-string}
                          false,          {poisoned-should be false}
                          false,          {disease -should be false}
                          global_dungeonlevel*3,          {punch}
                          global_dungeonlevel*2,          {armpow}
                          global_dungeonlevel*2);         {weappow}

          end;

         end;
       1:begin {trolls}
          d(config.textcolor,'The trolls are armed with clubs and spears. The leader');
          d(config.textcolor,'has a mace, which he is brandishing in front of you.');
          d(config.textcolor,'From the looks of these guys you know that bad news');
          d(config.textcolor,'has arrived.');
          {create the band}
          for i:=1 to foes do begin
           case random(2) of
            0: s:='Troll';
            1: s:='Half-Troll';
           end;
           if i=1 then s:='Troll Leader'; {the boss}

           create_monster(i,              {#}
                          s,              {name}
                          global_dungeonlevel*9,          {hps}
                          global_dungeonlevel*3,          {strength}
                          global_dungeonlevel*3,          {defence}
                          'Gsawha! Stmack!', {phrase}
                          false,          {grabweap}
                          false,          {grabarm}
                          'Club',         {weapon-string}
                          'Skin',         {armor-string}
                          false,          {poisoned-should be false}
                          false,          {disease -should be false}
                          global_dungeonlevel*4,          {punch}
                          global_dungeonlevel*3,          {armpow}
                          global_dungeonlevel*3);         {weappow}

          end;
         end;
       2:begin {rogues}
          d(config.textcolor,'They are brandishing their knives and rapiers.');
          d(config.textcolor,'Even if the band mostly consists of riff-raff, you');
          d(config.textcolor,'can see some southerners among them. These guys are');
          d(config.textcolor,'carrying axes.');

          {create the band}
          for i:=1 to foes do begin
           case random(3) of
            0: s:='Rogue';
            1: s:='Thief';
            2: s:='Pirate'
           end;
           if i=1 then s:='Rogue Leader'; {the boss}

           create_monster(i,              {#}
                          s,              {name}
                          global_dungeonlevel*5,          {hps}
                          global_dungeonlevel*2,          {strength}
                          global_dungeonlevel*2,          {defence}
                          'Shining gold!',{phrase}
                          false,          {grabweap}
                          false,          {grabarm}
                          'Dagger',       {weapon-string}
                          'Leather',      {armor-string}
                          false,          {poisoned-should be false}
                          false,          {disease -should be false}
                          global_dungeonlevel*2,          {punch}
                          global_dungeonlevel*2,          {armpow}
                          global_dungeonlevel*2);         {weappow}

          end;
         end;
       3:begin {dwarves}
          d(config.textcolor,'It''s hard to tell if they are looking for trouble.');
          d(config.textcolor,'They are carrying swords in their belts, and some have axes.');
          d(config.textcolor,'The dwarves are dressed in long fur coats.');
          {create the band}
          for i:=1 to foes do begin
           case random(2) of
            0: s:='Dwarf';
            1: s:='Dwarf';
           end;
           if i=1 then s:='Dwarf Leader'; {the boss}

           create_monster(i,              {#}
                          s,              {name}
                          global_dungeonlevel*6,          {hps}
                          global_dungeonlevel*3,          {strength}
                          global_dungeonlevel*4,          {defence}
                          'Take no prisoners!',{phrase}
                          false,          {grabweap}
                          false,          {grabarm}
                          'Axe',          {weapon-string}
                          'Chain-mail',   {armor-string}
                          false,          {poisoned-should be false}
                          false,          {disease -should be false}
                          global_dungeonlevel*3,          {punch}
                          global_dungeonlevel*3,          {armpow}
                          global_dungeonlevel*3);         {weappow}

          end;
         end;
      end; {case .end.}

      {give the player a chance to run away?}
      goahead:=true;
      crlf;

      ch:=menu_choices('(E)scape!','(C)onfront them','','','');

      if ch='E' then begin
       crlf;
       d(config.textcolor,'You managed to get away.');
       goahead:=false;
      end
      else begin
       d(config.textcolor,'You decide to confront the strangers.');
      end;

      {what do the bandits want from the player(s)}
      if goahead then begin
       case random(2) of
        0:begin {bandits demanding money *start*}
           crlf;
           d(config.textcolor,'Their leader demands that you give him all of your money :');
           d(global_talkcol,'Hand over the '+config.moneytype+' now!');

           s:='f';

           if confirm('Give away your stuff','N')=true then begin

            s:='';
            {the team must decide if they go along with their wimpy leader}
            new(player0);
            for i:=1 to 4 do begin
             case i of
              1: player0^:=pl1;
              2: player0^:=pl2;
              3: player0^:=pl3;
              4: player0^:=pl4;
             end;

             if player_active(player0^,true) then begin
              d(11,player0^.name2+' refuses to give away '+sex3[player0^.sex]+' money!');

              if s='' then begin
               d(15,'You have to refuse!');
              end;
              s:='f';
             end;
            end;
            dispose(player0);

            if s='' then begin
             d(config.textcolor,'You resign yourself and hand over the '+config.moneytype+'.');
             player.gold:=0;
             pl1.gold:=0;
             pl2.gold:=0;
             pl3.gold:=0;
             pl4.gold:=0;

             {put the event in the news}
             newsy(true,
             'Mugging in the Dungeons',
             ' '+uplc+player.name2+config.textcol1+' was robbed by bandits.',
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

           if s='f' then begin

            d(config.textcolor,'Refuse in a gentle manner or be rude?');
            ch:=menu_choices('(G)entle response','(R)ude!','','','');

            global_escape:=false;
            global_begged:=false;
            global_nobeg:=true;

            case ch of
             'R':begin {rude response}
                  d(config.textcolor,'You tell the strangers what a pack of trash they are.');
                  d(config.textcolor,'You let them know that their mothers must have been');
                  d(config.textcolor,'the most ugly creatures ever to have set foot');
                  d(config.textcolor,'on earth.');
                  crlf;
                  pause;
                  d(config.textcolor,'The bandits draw their weapons and attack!');
                  d(15,'FIGHT!');
                  Player_vs_Monsters(pl_vs_monster,pl1,pl2,pl3,pl4);
                 end;
             'G':begin {gentle response}
                  d(config.textcolor,'You make a speech about your poverty, and families');
                  d(config.textcolor,'back home. You beg the strangers to let you pass.');
                  crlf;
                  pause;
                  case random(2) of
                   0:begin {ok let player party pass}
                      d(config.textcolor,'Apparently the bandits bought your story.');
                      d(config.textcolor,'They wave goodbye and soon disappear on a path');
                      d(config.textcolor,'leading '+random_path);
                     end;
                   1:begin {strangers didn't buy that story. fight!}
                      d(config.textcolor,'The bandits laugh at your pathetic lies.');
                      d(config.textcolor,'They draw their weapons and attack!');
                      d(15,'FIGHT!');
                      Player_vs_Monsters(pl_vs_monster,pl1,pl2,pl3,pl4);

                      if global_killed then begin
                       d(15,'Your corpse is frisked.');
                       player.gold:=0;
                      end;

                     end;
                  end;

                 end;
            end;
           end;
          end; {bandits demanding money *end*}
        1:begin {bandits offer Map *start*}
           x:=random(5000)+5000;
           crlf;
           d(config.textcolor,'Their leader offers you a Map to a secret burial-ground.');
           d(config.textcolor,'The stranger speaks of treasures beyond belief.');
           d(config.textcolor,'They would go themselves if it had not been for the guardian');
           d(config.textcolor,'of this place.');
           pause;
           sd(config.textcolor,'The leader of the '+s2+' wants ');
           sd(14,commastr(x));
           d(config.textcolor,' '+many_money(x)+' for the map.');

           if Confirm('Buy the Map','Y')=true then begin
            s:='';
            if player.gold>=x then begin
             d(config.textcolor,'You give the stranger the '+config.moneytype+'.');
             d(config.textcolor,'You now have the map!');
             pause;
             s:='deal';
             decplayermoney(player,x);
            end
            else if player.gold<x then begin
             You_Cant_Afford_It;

             if team_active(pl1,pl2,pl3,pl4)>1 then begin
              s:='(A)sk companion to pay';
             end;

             ch:=menu_choices(s,'(O)ffer something from your backpack','(L)eave','','');

             case ch of
              'A':begin {Ask teammate to pay}
                   new(player0);
                   for i:=1 to 4 do begin
                    case i of
                     1: player0^:=pl1;
                     2: player0^:=pl2;
                     3: player0^:=pl3;
                     4: player0^:=pl4;
                    end;

                    if player_active(player0^,true) then begin
                     if player0^.gold>=x then begin

                      decplayermoney(player0^,x);

                      sd(global_plycol,player0^.name2);
                      d(config.textcolor,' bought the map.');
                      pause;
                      s:='deal';

                      {mail event}
                      post(MailSend,
                      player0^.name2,
                      player0^.ai,
                      false,
                      mailrequest_nothing,
                      '',
                      umailheadc+'Dungeon Event'+config.textcol1,
                      mkstring(13,underscore),
                      'You engaged strangers in the dungeons. '+uplc+Player.name2+config.textcol1,
                      'ordered you to buy a treasure map from them. You obeyed.',
                      'You payed '+uyellow+commastr(x)+config.textcol1+' '+many_money(x)+'.',
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

                      break;
                     end;
                    end;
                   end; {for i:= .end.}
                   dispose(player0);

                   if s<>'deal' then begin
                    d(12,'You missed the opportunity!');
                    d(12,'The stranger left.');
                   end;

                  end;

              'O':begin {offer somehting from the backpack}
                   i:=item_select(player);
                   if i>0 then begin
                    load_objekt(objekt^,player.itemtype[i],player.item[i]);

                    if (objekt^.value>=x) or (random(4)=0) then begin
                     sd(config.textcolor,'The '+s2+' leader accepts the ');
                     sd(global_itemcol,objekt^.name);
                     d(config.textcolor,' as compensation.');
                     d(config.textcolor,'You take the map.');

                     d(config.textcolor,'The strangers leave. You begin to wonder if this');
                     d(config.textcolor,'map really leads somewhere. It could be a trick...');
                     player.item[i]:=0;
                     s:='deal';

                     pause;
                    end
                    else begin
                     d(config.textcolor,'The '+s2+' leader doesn''t look too happy with what');
                     d(config.textcolor,'You had to offer. He and his party leaves!');
                     pause;
                    end;
                   end
                   else begin
                    crlf;
                    d(config.textcolor,'You bid the strangers farewell...');
                   end;
                  end;
              'L':begin {leave}
                   crlf;
                   d(config.textcolor,'You bid the strangers farewell...');
                  end;
             end;

            end;

            {player has payed for the MAP}
            if s='deal' then begin
             crlf;
             crlf;
             if team_active(pl1,pl2,pl3,pl4)=1 then begin
              d(config.textcolor,'You are alone. This mission could prove to be more');
              d(config.textcolor,'dangerous than you expect.');
              pause;
             end;

             d(config.textcolor,'You travel downwards...');
             for i:=1 to 25 do begin
              sd(config.textcolor,'.');
              delay2(150);
             end;
             crlf;

             d(config.textcolor,'After many hours you arrive to the first mark on the map.');
             d(config.textcolor,'The Burial-Ground can be sighted behind a wooden palisade.');
             sd(config.textcolor,'By the looks of the palisade this is ');
             sd(15,'NOT');
             d(config.textcolor,' an abandoned cemetery!');
             d(config.textcolor,'This is your last chance to change your mind.');
             pause;

             ch:=menu_choices('(P)lunder the graves','(L)eave this place!','','','');

             case ch of
              'P':begin {grave plundering}
                   d(config.textcolor,'There is a deathlike silence here... You can almost touch it.');
                   done:=false;
                   graves:=random(15)+5;
                   cleared:=0;
                   danger:=0;
                   enemy_here:=true;
                   xx:=0;
                   repeat
                    if cleared>0 then begin
                     sd(config.textcolor,'You have cleared ');
                     sd(15,commastr(cleared));
                     d(config.textcolor,' graves.');
                    end;
                    sd(config.textcolor,'There are ');
                    sd(15,commastr(graves));
                    d(config.textcolor,' graves left to plunder.');

                    inc(danger);
                    inc(cleared);
                    dec(graves);

                    x:=(player.level*800)+random(1500);
                    xx:=xx+x; {accumulated money}

                    sd(config.textcolor,'You start digging and find ');
                    sd(14,commastr(x));
                    d(config.textcolor,' worth of '+config.moneytype+' in this grave!');

                    {the spirits are getting restless}
                    if (danger>7) and (random(2)=0) and (enemy_here=true) then begin
                     {d(15,'high danger');}
                    end
                    else if (danger>5) and (random(2)=0) and (enemy_here=true)then begin
                     d(11,'You can feel the presence of a spirit!');
                     d(5,'The spirit speaks :');
                     d(global_talkcol,' Leave the graves as they were!');
                     d(global_talkcol,' I am the Guardian of this ground and will not tolerate this behaviour!');
                     pause;
                     ch:=menu_choices('(I)gnore the wimpy spirit','(R)estore everything you have stolen','','','');
                     case ch of
                      'I':begin

                           Reset_Monsters;
                           Reset_Spells(pl1,pl2,pl3,pl4);

                           d(config.textcolor,'You ignore that Windbag and continue with your work!');
                           pause;
                           d(5,'After awhile you can hear the Spirit again :');
                           d(global_talkcol,' It was a long time since somebody dared me...');
                           d(global_talkcol,' But since You like to play with the dead...');
                           d(global_talkcol,' You should meet them in the flesh!');
                           pause;
                           d(15,'Oh no! The corpses and mummies are rising from their graves!');

                           foes:=random(15)+5;
                           if foes>global_maxmon then foes:=global_maxmon;

                           for i:=1 to foes do begin
                            case random(3) of
                             0:begin
                                s:='Mummy';
                                hps:=global_dungeonlevel*3;
                               end;
                             1:begin
                                s:='Corpse';
                                hps:=global_dungeonlevel*4;
                               end;
                             2:begin
                                s:='Knight';
                                hps:=global_dungeonlevel*8;
                               end;
                            end;

                            if i=1 then begin
                             s:='Ancient King'; {the boss}
                             hps:=player.hps*2;
                            end;

                            Create_Monster(i,              {#}
                             s,              {name}
                             hps,            {hps}
                             global_dungeonlevel*3,          {strength}
                             global_dungeonlevel*3,          {defence}
                             'Mmmm..',       {phrase}
                             false,          {grabweap}
                             false,          {grabarm}
                             'Lance',        {weapon-string}
                             'Shimmering Light',  {armor-string}
                             false,          {poisoned-should be false}
                             false,          {disease -should be false}
                             global_dungeonlevel*3,          {punch}
                             global_dungeonlevel*2,          {armpow}
                             global_dungeonlevel*2);         {weappow}
                           end;

                          
                           if player_active(pl1,true) then alivebefore1:=true
                                                      else alivebefore1:=false;
                           if player_active(pl2,true) then alivebefore2:=true
                                                      else alivebefore2:=false;
                           if player_active(pl3,true) then alivebefore3:=true
                                                      else alivebefore3:=false;
                           if player_active(pl4,true) then alivebefore4:=true
                                                      else alivebefore4:=false;

                           global_escape:=false;
                           global_begged:=false;
                           global_nobeg:=true;

                           Player_vs_Monsters(pl_vs_monster,pl1,pl2,pl3,pl4);
                           enemy_here:=false;

                           if player.hps<1 then begin

                            Newsy(true,
                            'The Undead',
                            ' '+uplc+player.name2+config.textcol1+' dug for treasure... but unearthed lot of',
                            ' '+umonc+'undead'+config.textcol1+' creatures!',
                            ' '+uplc+player.name2+config.textcol1+' was slaughtered.',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');

                           end;

                          end;
                      'R':begin
                           xx:=0;
                           done:=true;
                           d(config.textcolor,'You restore the graves to their original state.');
                           d(config.textcolor,'You leave quietly and without hearing from the Spirit.');
                          end;
                     end;
                    end
                    else if (danger>3) and (random(3)=0) and (enemy_here=true) then begin
                     d(11,'You feel that something or someone is watching you...');
                    end;

                    if (global_killed=false) and (done=false) then begin
                     ch:=menu_choices('(N)ext grave','(L)eave','','','');

                     case ch of
                      'L':begin
                           d(config.textcolor,'You leave with your loot');
                           done:=true;
                          end;
                     end;
                    end;

                   until (done) or (graves<1) or (global_killed);

                   if (global_killed=false) and (xx>100) then begin
                    {split the loot}
                    i:=team_active(pl1,pl2,pl3,pl4);
                    dec(i);

                    sd(config.textcolor,'You earned ');
                    sd(14,commastr(xx));
                    d(config.textcolor,' '+many_money(xx)+' on this mission!');

                    if i>1 then begin
                     xx:=xx div i;
                    end;

                    sd(config.textcolor,'Your share is ');
                    sd(14,commastr(xx));
                    d(config.textcolor,' '+many_money(xx)+'!');

                    incplayermoney(player,xx);
                    if player_active(pl1,true) then incplayermoney(pl1,xx);
                    if player_active(pl2,true) then incplayermoney(pl2,xx);
                    if player_active(pl3,true) then incplayermoney(pl3,xx);
                    if player_active(pl4,true) then incplayermoney(pl4,xx);

                    {send a little message to team about this event}
                    new(player0);
                    for i:=1 to 4 do begin
                     case i of
                      1:begin
                         player0^:=pl1;
                         alivebefore:=alivebefore1;
                        end;
                      2:begin
                         player0^:=pl2;
                         alivebefore:=alivebefore2;
                        end;
                     3:begin
                         player0^:=pl3;
                         alivebefore:=alivebefore3;
                        end;
                      4:begin
                         player0^:=pl4;
                         alivebefore:=alivebefore4;
                        end;
                     end;

                     if (alivebefore=true) and
                        (player_active(player0^,true)=true) then begin
                      {team mate is alive}
                      post(MailSend,
                      player0^.name2,
                      player0^.ai,
                      false,
                      mailrequest_nothing,
                      '',
                      umailheadc+'Dungeon Party & Fortune'+config.textcol1,
                      mkstring(24,underscore),
                      'You were lead by '+uplc+Player.name2+config.textcol1+' to plunder graves.',
                      'You successfully fought hordes of the Undeads, awakened by the greed',
                      'and disrespect of '+uplc+player.name2+config.textcol1+'.',
                      'Your earned '+uyellow+commastr(xx)+config.textcol1+' '+many_money(xx)+'.',
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
                     else if (alivebefore=true) and
                             (player_active(player0^,true)=false) then begin
                      {team mate died in the last fight}
                      post(MailSend,
                      player0^.name2,
                      player0^.ai,
                      false,
                      mailrequest_nothing,
                      '',
                      umailheadc+'Dungeon Party & Your Death'+config.textcol1,
                      mkstring(26,underscore),
                      'You were lead by '+uplc+Player.name2+config.textcol1+' to plunder graves.',
                      'You died fighting hordes of Corpses, awakened by the greed',
                      'and disrespect of '+uplc+player.name2+config.textcol1+'.',
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
                     else begin
                      {no news}
                     end;

                    end;
                    dispose(player0);

                    pause;

                   end;

                  end;
              'L':begin
                   crlf;
                   d(config.textcolor,'You leave this scary place.');
                  end;
             end;


            end;

           end
           else begin
            crlf;
            d(config.textcolor,'You bid the strangers farewell...');
           end;

          end; {bandits offer Map *end*}
       end;
      end;

 {dispose pointer vars}
 dispose(objekt);

end;

Procedure Beggar; {beggar wants money}
type Killings = (HeadCrush,KickAround,Kill);
var ch : char;
     x : longint;
     s : s70;
procedure tell_the_news(killing:killings);
var n,t : s70;
begin

 n:='Oscar';
 case random(10) of
  0: n:='Urban';
  1: n:='Godlock';
  2: n:='Poofy';
  3: n:='Trantiw';
  4: n:='Gundlo';
  5: n:='Qasimir';
  6: n:='Smatimor';
  7: n:='Elgon';
  8: n:='Grumbod';
  9: n:='Javva Chin';
 end;

 if team_active(pl1,pl2,pl3,pl4)>1 then begin
  t:=' and '+sex3[player.sex]+' team are the suspects';
 end
 else begin
  t:=' is the suspect';
 end;

 case killing of
  HeadCrush:begin
             newsy(true,
             'Beggar found Murdered',
             ' '+uplc+player.name2+config.textcol1+t+' of killing',
             ' '+uplc+n+config.textcol1+' the beggar. The old mans mutilated body',
             ' was found today (his head had been crushed).',
             ' These obscene killings must come to an end!',
             '',
             '',
             '',
             '',
             '');
            end;
  KickAround:begin
              newsy(true,
              'Beggar assaulted',
              ' '+uplc+player.name2+config.textcol1+t+' of the assault',
              ' and beating of '+ucyan+n+config.textcol1+' the beggar. The old man',
              ' was almost dead when found.',
              ' This senseless violence must stop!',
              '',
              '',
              '',
              '',
              '');
             end;
  Kill:begin
        newsy(true,
        'Beggar Murdered',
        ' '+uplc+player.name2+config.textcol1+t+' of the killing',
        ' of '+ucyan+n+config.textcol1+' the beggar. The poor man',
        ' was found with a pole driven through his body.',
        ' This senseless violence must come to a halt!',
        '',
        '',
        '',
        '',
        '');
       end;

 end;
end;

begin
 crlf;
 crlf;
 crlf;
 d(3,'-=Encounter=-');
 sd(config.textcolor,'A ');
 sd(7,'beggar');
 d(config.textcolor,' blocks your path. He''s holding a wine-bottle in his');
 d(config.textcolor,'right hand, and a cup in his left. The toothless old man');
 d(config.textcolor,'is one of the many beggars flooding the country right now.');
 d(config.textcolor,'You almost feel sorry for the poor bastard...');
 crlf;

 ch:=menu_choices('(G)ive money','(P)ush him aside','(S)tomp him','(K)ill old man','');

 case ch of
  'G':begin {give money *start*}
       crlf;
       d(config.textcolor,'You decide to have mercy with the beggar.');
       sd(config.textcolor,'You have ');
       sd(14,commastr(player.gold));
       d(config.textcolor,' '+many_money(player.gold)+'.');
       sd(config.textcolor,'Give how much :');
       x:=get_number(0,player.gold);

       if x>0 then begin
        decplayermoney(player,x);

        if player.sex=1 then begin
         s:='grandpa';
        end
        else begin
         s:='grandma';
        end;

        d(global_talkcol,'Here you are '+s+'! Don''t spend it all on booze now.');
        if x<random(100)+50 then begin
         d(config.textcolor,'The beggar looks at the few coins you gave him.');
         d(global_talkcol,' This won''t help me far sir! Can you spare some more?');

         ch:=menu_choices('(G)ive more','(C)lub the ungrateful old fart','','','');

         case ch of
          'G':begin {give more money *start*}
               d(config.textcolor,'You decide to give the persistant man some more '+config.moneytype+'.');
               sd(config.textcolor,'You have ');
               sd(14,commastr(player.gold));
               d(config.textcolor,' '+many_money(player.gold)+'.');
               sd(config.textcolor,'Give how much :');
               x:=get_number(0,player.gold);

               if x>0 then begin
                decplayermoney(player,x);

                d(config.textcolor,'The beggar seems very happy. He gives you a hug and then heads off.');

                {give chivalry points}
                pre_charity;
                x:=random(40)+30;
                give_chivalry(player,x);

               end
               else begin
                d(global_talkcol,'NOTHING is what you get! You should never have asked for more!');
                d(config.textcolor,'The beggar is upset and starts to cry. He then produces some obscene');
                d(config.textcolor,'gestures before he leaves.');
                pause;
               end;

              end;  {give more money *end*}
          'C':begin {club beggar *start*}
               d(global_talkcol,'Sure Sure! Old man! I will give you some more alright.');
               d(config.textcolor,'You manage to draw the beggars attention to another direction.');
               d(config.textcolor,'You then pick up a wooden branch from the ground and strikes');
               d(config.textcolor,'it with full power over the beggars head!');
               pause;
               d(15,'KRACK!');
               d(config.textcolor,'The beggars brain is all over the ground. You really hit');
               d(config.textcolor,'a soft spot! haha!');
               d(config.textcolor,'After you have cleaned yourself up you continue your journey...');
               pause;

               {give penalty darkness points}
               pre_darkness;
               x:=random(75)+55;
               give_darkness(player,x);
               tell_the_news(HeadCrush);

          end;  {club beggar *end*}
         end;

        end
        else begin
         d(config.textcolor,'The beggar is greatful. He gives you a hug and heads off.');
         {give chivalry points}
         pre_charity;
         x:=random(40)+30;
         give_chivalry(player,x);
        end;
        pause;
       end
       else begin
        d(global_talkcol,'I changed my mind! Go and find a job you bloody parasite!');
        d(config.textcolor,'The beggar shakes his fist at you.');
        d(config.textcolor,'The old geezer is upset with your rudeness...but what the hell.');
        d(config.textcolor,'You shove him aside and continue your journey.');
        pause;
       end;

      end;  {give money *end*}
  'P':begin {push aside *start*}
       d(config.textcolor,'You gently push the man aside and continue your journey.');
       d(config.textcolor,'From behind you hear the beggar angrily muttering curses.');
       pause;
      end;  {push aside *end*}
  'S':begin {stomp beggar *start*}
       crlf;
       d(global_talkcol,'I''m gonna teach you a lesson old man!');
       d(config.textcolor,'You push the beggar to the ground...');
       d(config.textcolor,'The weak man can''t put up much of a fight against');
       d(config.textcolor,'your superior strength.');
       pause;
       crlf;
       d(config.textcolor,'You kick him around a while and then when he''s almost');
       d(config.textcolor,'unconscious, you finish it with a power-boot against');
       d(config.textcolor,'his head.');
       crlf;
       d(config.textcolor,'You leave the bloody lump of meat laying on the ground,');
       d(config.textcolor,'for the animals to gnaw on.');
       d(config.textcolor,'You feel refreshed after this little excercise!');
       d(config.textcolor,'(you need to wash your boots to)');
       pause;

       {give penalty darkness points}
       pre_darkness;
       x:=random(40)+30;
       give_darkness(player,x);
       tell_the_news(KickAround);
      end;  {stomp beggar *end*}
  'K':begin {kill beggar *start*}
       crlf;
       case random(2) of
        0: d(global_talkcol,'I''m gonna rid the world of all tramps and prostitutes!');
        1: d(global_talkcol,'Suck on this Grandpa!');
       end;

       d(config.textcolor,'You pick up a pole you found earlier and drive it through');
       d(config.textcolor,'body of the defenceless old man!');
       pause;
       crlf;

       d(config.textcolor,'After a short stumbling around, the beggar falls on his knees');
       d(config.textcolor,'desperately trying to remove the pole.');
       d(config.textcolor,'With blood flowing from his stomach and gasping for air,');
       d(config.textcolor,'he dies...');
       d(config.textcolor,'Not too heroic this was, but practice is never bad.');
       crlf;

       pause;
       {give penalty darkness points}
       pre_darkness;
       x:=random(70)+90;
       give_darkness(player,x);
       tell_the_news(Kill);
      end;  {kill beggar *end*}
 end;


end; {Beggar *end*}



Procedure Merchant(var pl1,pl2,pl3,pl4:userrec); {meeting with Merchant *event*}
const dest   = 'Lyngon'; {where the merchant is headed}
      forest = 'Mildha'; {forest where escort mission is going through}
      threat = 'Uldrew'; {big threat in the forest}

Type Terrains = (Mountains,Desert,Forests);
var mission_active:boolean;

procedure fight_scum(terrain:terrains;foes:byte);
var i : byte;
    x,hps : longint;
    s : s70;
    weapon,armor,phrase : s70;

    alivebefore,
    alivebefore1,alivebefore2,alivebefore3,alivebefore4:boolean;
    player0 : ^userrec;

begin

 Reset_Monsters;
 Reset_Spells(pl1,pl2,pl3,pl4);

 for i:=1 to foes do begin
  case terrain of
   Mountains:begin {mountains *start*}
              case random(4) of
               0: s:='Hooded Robber';
               1: s:='Robber';
               2: s:='Thief';
               3: s:='Rogue';
              end;

              case random(3) of
               0:begin
                  weapon:='Club';
                  armor:='Cloth';
                 end;
               1:begin
                  weapon:='Sword';
                  armor:='Leather';
                 end;
               2:begin
                  weapon:='Pole';
                  armor:='Leather';
                 end;
              end;
             end; {mountains *end*}
  Desert:begin {desert *start*}
              case random(2) of
               0: s:='Robber Knight';
               1: s:='Robber Squire';
              end;

              case random(3) of
               0:begin
                  weapon:='Lance';
                  armor:='Chain-Mail';
                 end;
               1:begin
                  weapon:='Sword';
                  armor:='Chain-Mail';
                 end;
               2:begin
                  weapon:='Club';
                  armor:='Leather';
                 end;
              end;
         end; {desert *end*}
  Forests:begin {forest *start*}
              case random(2) of
               0: s:='Tree Hunter';
               1: s:='Green Threat';
              end;

              case random(3) of
               0:begin
                  weapon:='Silver Dagger';
                  armor:='Cloth';
                 end;
               1:begin
                  weapon:='Sling';
                  armor:='Cloth';
                 end;
               2:begin
                  weapon:='Sharp Stick';
                  armor:='Cloth';
                 end;
              end;
         end; {forest *end*}

  end;


  if i=1 then begin
   case terrain of
    Mountains:begin
               s:='Bandit Leader'; {the leader}
               phrase:='Give yourself up!';
               hps:=global_dungeonlevel*6;
               hps:=hps*2;
              end;
    Desert:begin
            s:='*Robber Prince*';
            phrase:='No prisoners!';
            hps:=global_dungeonlevel*8;
            hps:=hps*2;
           end;
    Forests:begin
             s:='*'+threat+'s son*';
             phrase:='Wrong way lads!';
             hps:=global_dungeonlevel*10;
             hps:=hps*3;
            end;

   end;
  end;

  {let's create some monsters!}
  Create_Monster(i,              {#}
                 s,              {name}
                 hps,            {hps}
                 global_dungeonlevel*2, {strength}
                 global_dungeonlevel*2, {defence}
                 phrase,         {phrase}
                 false,          {grabweap}
                 false,          {grabarm}
                 weapon,         {weapon-string}
                 armor,          {armor-string}
                 false,          {poisoned-should be false}
                 false,          {disease -should be false}
                 global_dungeonlevel*2,          {punch}
                 global_dungeonlevel*2,          {armpow}
                 global_dungeonlevel*2);         {weappow}

 end;

 global_begged:=false;
 global_nobeg :=true;
 global_escape:=false;

 if player_active(pl1,true) then alivebefore1:=true
                            else alivebefore1:=false;
 if player_active(pl2,true) then alivebefore2:=true
                            else alivebefore2:=false;
 if player_active(pl3,true) then alivebefore3:=true
                            else alivebefore3:=false;
 if player_active(pl4,true) then alivebefore4:=true
                            else alivebefore4:=false;

 player_vs_monsters(pl_vs_monster,pl1,pl2,pl3,pl4);

 if global_killed then begin
  mission_active:=false;

  newsy(true,
        'Escort Mission',
        ' '+uplc+player.name2+config.textcol1+' defended a Merchant being',
        ' attacked by bandits. After a fierce struggle',
        uplc+' '+player.name2+config.textcol1+' was chopped down.',
        '',
        '',
        '',
        '',
        '',
        '');
 end
 else begin
  {give the team some credits to, if there was a team}
  if (alivebefore1) or (alivebefore2) or (alivebefore3) or (alivebefore4) then begin
   s:=' and '+sex3[player.sex]+' team';
  end
  else begin
   s:='';
  end;

  newsy(true,
        'Escort Mission',
        ' '+uplc+player.name2+config.textcol1+s+' defended a Merchant',
        ' being attacked by robbers. The attack was fended off!',
        ' At last somebody dared to stand up to the criminal',
        ' elements in our country!',
        '',
        '',
        '',
        '',
        '');



  {player survided, now some text}
  crlf;
  crlf;
  crlf;

  x:=random(5000)+1000;

  d(14,'******* Successful Fight *********');
  d(config.textcolor,'After this perfect battle you rest a while...');
  crlf;
  pause;

 end;

 {send a little message to team about this event}
 new(player0);
 for i:=1 to 4 do begin
  case i of
   1:begin
      player0^:=pl1;
      alivebefore:=alivebefore1;
     end;
   2:begin
      player0^:=pl2;
      alivebefore:=alivebefore2;
     end;
   3:begin
      player0^:=pl3;
      alivebefore:=alivebefore3;
     end;
   4:begin
      player0^:=pl4;
      alivebefore:=alivebefore4;
     end;
  end;

  if (alivebefore=true) and (player_active(player0^,true)=true) then begin

   {team mate survived the fight!}
   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Escort Missions'+config.textcol1,
   mkstring(31,underscore),
   'You helped '+uplc+Player.name2+config.textcol1+' to Escort a',
   'Merchant transporting goods through dangerous terrain.',
   'You were attacked by bandits, but fended them off.',
   'Very much thanks to your excellent fighting skills!',
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
  else if (alivebefore=true) and (player_active(player0^,true)=false) then begin
   {team mate died in the fight}
   case random(2) of
    0: s:='You were killed by bandits!';
    1: s:='A club cracked your skull!';
   end;

   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Your Death'+config.textcol1,
   mkstring(26,underscore),
   'You helped '+uplc+Player.name2+config.textcol1+' to Escort a',
   'Merchant transporting goods through dangerous terrain.',
   s,
   'Your death was quick and clean. Try to improve your skills',
   'or skip this worthless team you''re in!',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');
  end
  else begin
   {no news}
  end;

 end;

 dispose(player0);

end;

procedure run_away(terrain:terrains);
var i : byte;
    s,s2 : s70;
    x : integer;
    player0 : ^UserRec;
begin
 crlf;
 d(config.textcolor,'You run away to save your own skin!');
 d(config.textcolor,'In the distance you can hear the scream from the poor merchant.');
 d(config.textcolor,'You can only hope that the robbers spare his life.');
 d(config.textcolor,'(not very likely)');
 crlf;
 d(15,'You failed your Escort Mission when you left the Merchant!');

 pre_darkness;
 x:=random(25)+25;
 give_darkness(player,x);

 s:='';
 s2:=' What a spineless coward!';

 if team_active(pl1,pl2,pl3,pl4)>1 then begin
  s :=' and '+sex3[player.sex]+' team';
  s2:=' What a pathetic bunch of spineless cowards!';
 end;

 {put this withdrawal in the news}
 newsy(true,
       'Cowards!',
       ' '+uplc+player.name2+config.textcol1+s+' was escorting a Merchant through dangerous',
       ' terrain when they were attacked by bandits.',
       ' '+uplc+player.name2+config.textcol1+' turned chicken and ran.',
       s2,
       '',
       '',
       '',
       '',
       '');


 {send a message to team mates about their chicken-leader}
 new(player0);
 for i:=1 to 4 do begin
  case i of
   1:begin
      player0^:=pl1;
     end;
   2:begin
      player0^:=pl2;
     end;
   3:begin
      player0^:=pl3;
     end;
   4:begin
      player0^:=pl4;
     end;
  end;

  if player_active(player0^,true)=true then begin

   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Chicken Leader'+config.textcol1,
   mkstring(30,underscore),
   'You helped '+uplc+Player.name2+config.textcol1+' to escort a',
   'Merchant transporting goods through the dangerous terrain.',
   'Your leader turned chicken when bandits suddenly appeared!',
   'You left the poor merchant to his fate.',
   'This shameful retreat didn''t exactly improve your reputation!',
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
 dispose(player0);

 pause;

 mission_active:=false;

end;

procedure encounter(terrain:terrains);
var ch   : char;
    foes : byte;
begin

 {escorrting merchant through forest, with increasing difficulty}

 case terrain of
  Mountains : foes:=random(5)+2;
  Desert    : foes:=random(6)+3;
  Forests   : foes:=random(9)+4;
 end;

 case terrain of
  Mountains:begin {mountains encounter *start*}

             crlf;
             sd(3,'You have spotted ');
             sd(15,commastr(foes));
             d(3,' mountain robbers blocking your path.');
             d(3,'The robbers all wear hoods to hide their faces.');
             d(3,'They will let you go if you hand over the Merchant to them.');
             crlf;

             ch:=menu_choices('(A)ttack robbers','(R)un away (and leave the poor merchant)','','','');

             case ch of
              'A':begin {attack robbers *start*}
                   fight_scum(mountains,foes);
                  end;  {attack robbers *end*}
              'R':begin {run away *start*}
                   run_away(Mountains);
                  end;  {run away *end*}
             end;

            end; {mountains encounter *end*}
  Desert:begin {desert encounter *start*}
          crlf;
          sd(3,'You have spotted ');
          sd(15,commastr(foes));
          d(3,' robber knights blocking your path.');
          d(3,'The robbers wear hoods to hide their faces.');
          d(3,'They will let you go if you hand over the Merchant to them.');
          crlf;

          ch:=menu_choices('(A)ttack knights','(R)un away (and leave the poor merchant)','','','');

          case ch of
           'A':begin {attack robbers *start*}
                 fight_scum(Desert,foes);
                end;  {attack robbers *end*}
            'R':begin {run away *start*}
                 run_away(Desert);
                end;  {run away *end*}
          end;

         end; {desert encounter *end*}
  Forests:begin {forest encounter *start*}
           foes:=global_maxmon;
           crlf;
           sd(3,'You have spotted ');
           sd(15,threat+'s');
           d(3,' gang! They are the most notorious');
           d(3,'murdering scum on this side of the valley.');
           d(3,'Run away NOW or fight your last battle today!');
           crlf;

           ch:=menu_choices('(A)ttack!','(R)un away','','','');

           case ch of
            'A':begin {attack robbers *start*}
                  fight_scum(Forests,foes);
                 end;  {attack robbers *end*}
             'R':begin {run away *start*}
                  run_away(Forests);
                 end;  {run away *end*}
           end;

          end;  {forest encounter *end*}
 end;

end;

procedure do_battle; {fight merchant *start*}
var i,foes : byte;
    x,hps : longint;
    s : s70;
    weapon,armor : s70;

    alivebefore,
    alivebefore1,alivebefore2,alivebefore3,alivebefore4:boolean;
    player0 : ^userrec;

begin

 Reset_Monsters;
 Reset_Spells(pl1,pl2,pl3,pl4);

 foes:=1; {its only one fucking merchant (excuse my language)}

 for i:=1 to foes do begin
  case random(3) of
   0: s:='Merchant';
   1: s:='Fat Merchant';
   2: s:='Scared Merchant';

  end;

  case random(3) of
   0:begin
      weapon:='Cane';
      armor:='Leather';
     end;
   1:begin
      weapon:='Log';
      armor:='Cloth';
     end;
   2:begin
      weapon:='Pole';
      armor:='Cloth';
     end;
  end;

  hps:=50;

  {if i=1 then begin
   s:=warleader; {the warleader}
  { hps:=hps*2;
  end;}

  create_monster(i,              {#}
                 s,              {name}
                 hps,            {hps}
                 global_dungeonlevel*2,          {strength}
                 global_dungeonlevel*2,          {defence}
                 'help me!',     {phrase}
                 false,          {grabweap}
                 false,          {grabarm}
                 weapon,         {weapon-string}
                 armor,          {armor-string}
                 false,          {poisoned-should be false}
                 false,          {disease -should be false}
                 global_dungeonlevel*2,          {punch}
                 global_dungeonlevel*1,          {armpow}
                 global_dungeonlevel*1);         {weappow}

 end;

 global_escape:=false;
 global_begged:=false;
 global_nobeg:=true;

 if player_active(pl1,true) then alivebefore1:=true
                            else alivebefore1:=false;
 if player_active(pl2,true) then alivebefore2:=true
                            else alivebefore2:=false;
 if player_active(pl3,true) then alivebefore3:=true
                            else alivebefore3:=false;
 if player_active(pl4,true) then alivebefore4:=true
                            else alivebefore4:=false;

 player_vs_monsters(pl_vs_monster,pl1,pl2,pl3,pl4);

 if global_killed then begin
  newsy(true,
        'Laughing Matter',
        ' '+uplc+player.name2+config.textcol1+' assaulted a poor merchant',
        ' but didn''t manage to finish him off!',
        uplc+player.name2+config.textcol1+' was killed.',
        '',
        '',
        '',
        '',
        '',
        '');
 end
 else begin
  {give the team some credits to, if there was a team}
  if (alivebefore1) or (alivebefore2) or (alivebefore3) or (alivebefore4) then begin
   s:=' and '+sex3[player.sex]+' team';
  end
  else begin
   s:='';
  end;

  newsy(true,
        'Unprovoked Violence',
        ' '+uplc+player.name2+config.textcol1+s+' assaulted an unarmed',
        ' merchant doing his business! Who can stop this senseless',
        ' violence. The poor merchant was murdered!',
        '',
        '',
        '',
        '',
        '',
        '');



  {player survided, now some text}
  crlf;
  crlf;
  crlf;

  x:=random(5000)+1000;

  d(14,'******* Poor Mans Death *********');
  d(config.textcolor,'After this shameful assault you search the Mercants belongings...');
  d(config.textcolor,'You find some furs in the cart.');
  sd(config.textcolor,'They are worth ');
  sd(14,commastr(x));
  sd(config.textcolor,' cold coins (');
  sd(12,'BLOOD MONEY!');
  d(config.textcolor,')');

  incplayermoney(player,x);

  d(15,'You will surely pay for this crime later on!');

  pre_darkness;
  x:=100+random(100);
  give_darkness(player,x);

  sd(config.textcolor,'You receive ');
  sd(15,commastr(x));
  d(config.textcolor,' darkness points for this fight!');

  pause;

 end;

 {send a little message to team about this event}
 new(player0);
 for i:=1 to 4 do begin
  case i of
   1:begin
      player0^:=pl1;
      alivebefore:=alivebefore1;
     end;
   2:begin
      player0^:=pl2;
      alivebefore:=alivebefore2;
     end;
   3:begin
      player0^:=pl3;
      alivebefore:=alivebefore3;
     end;
   4:begin
      player0^:=pl4;
      alivebefore:=alivebefore4;
     end;
  end;

  if (alivebefore=true) and (player_active(player0^,true)=true) then begin

   {team mate survived the fight!}
   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Murdering'+config.textcol1,
   mkstring(25,underscore),
   'You helped '+uplc+Player.name2+config.textcol1+' to murder an',
   'innocent Merchant transporting goods through the dungeons.',
   'This shameful act didn''t exactly improve your reputation!',
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
  else if (alivebefore=true) and (player_active(player0^,true)=false) then begin
   {team mate died in the fight}
   case random(2) of
    0: s:='You were killed by an unarmed Merchant!';
    1: s:='A pole cracked your skull!';
   end;

   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Your Death'+config.textcol1,
   mkstring(26,underscore),
   'You helped '+uplc+Player.name2+config.textcol1+' to assault an',
   'innocent Merchant transporting goods through the dungeons.',
   s,
   'Your death wasn''t a pretty sight.',
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
  else begin
   {no news}
  end;

 end;
 dispose(player0);

end; {do_battle (fight merchant) *END*}

procedure walk_away;
begin
 d(config.textcolor,'You decide to leave the merchant in peace.');
 d(config.textcolor,'More important things are pending.');
 crlf;
end;

var ch : char;
   evil: byte;
    del: integer;
     x : longint;
begin

 mission_active:=true;

 crlf;
 crlf;
 d(3,'-=Encounter=-');
 d(config.textcolor,'You have spotted a merchant pulling a handcart.');
 d(config.textcolor,'You can''t see what''s on the cart, but the merchant');
 d(config.textcolor,'is a fat middle-aged man. He seems to be unarmed,');
 d(config.textcolor,'although he of course can carry a concealed weapon.');
 crlf;

 ch:=menu_choices('(T)alk','(A)ssault','(W)alk away','','');

 case ch of
  'T':begin {talk *start*}
       crlf;
       d(config.textcolor,'You stop the man and ask where he''s headed.');
       d(config.textcolor,'The merchant looks afraid but finally clears his throat and speaks :');
       sd(global_talkcol,' I''m headed for ');
       sd(15,dest);
       d(global_talkcol,', a four days march from here.');

       sd(global_talkcol,' I could really use an escort through the ');
       sd(15,forest);
       d(global_talkcol,' forest.');
       d(global_talkcol,' You will get paid of course. The forest is filled with');
       sd(global_talkcol,' all kinds of trouble. Worst of them all; ');
       sd(15,threat);
       d(global_talkcol,'.');
       crlf;

       ch:=menu_choices('(E)scort Merchant','(A)ttack now!','(W)alk away','','');

       case ch of
        'E':begin {escort mission *start*}
             d(15,'You accept to escort the merchant through the forest.');
             crlf;
             d(config.textcolor,'You begin your journey toward the unknown.');

             del :=1000; {travel delay}
             evil:=3;    {risk of meeting bandits}

             {Mountains}
             sd(config.textcolor,'Day one...over the mountains');
             delay2(del);
             crlf;
             if random(evil)=0 then encounter(MOUNTAINS);

             if mission_active=true then begin
              {Desert}
              sd(config.textcolor,'Day two...through the desert');
              delay2(del);
              crlf;
              if random(evil)=0 then encounter(DESERT);
             end;

             if mission_active=true then begin
              {Forest}
              sd(config.textcolor,'Day three...through ');
              sd(15,forest);
              delay2(del);
              crlf;
              if random(evil)=0 then encounter(FORESTS);
             end;

             if mission_active=true then begin
              {arrving at destination}
              sd(config.textcolor,'Day four...arriving to ');
              sd(15,dest);
              delay2(del);
              crlf;

              crlf;
              d(15,'You made it through safe!');

              x:=random(5000)+1500;
              incplayermoney(player,x);

              sd(config.textcolor,'Your salary was ');
              sd(14,commastr(x));
              d(config.textcolor,' '+many_money(x)+'.');

              d(config.textcolor,'You make your way back to the place where you started from.');
              pause;
             end;

            end;  {escort mission *end*}
        'A':begin
             do_battle;
            end;
        'W':begin
             walk_away;
            end;
       end;

      end;  {talk *end}
  'A':begin {attack *start*}
       do_battle;
      end;  {attack *end*}
  'W':begin {walk away *start*}
       walk_away;
      end;  {walk away *end*}

 end; {case .end.}

end; {meeting with Merchant *END*}

end. {Unit Dungev2 .end.}
