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



Unit DungevC; {Usurper - Dungeon Events [1/2]}

Interface {This unit contains some of the events that take place
           in the dungeons. see also dungev2.pas}

Uses Init;

Function Dungeon_Event( var  pl1,
                             pl2,
                             pl3,
                             pl4 : userrec) : boolean;

Implementation

Uses Cms, Jakob, Invent,
     Uman, Npc_Chec, PlvsMon,
     SpellsU, Various, Various2,
     Various3, Dungev2, News,
     Mail, File_Io;

Procedure Dead_Check(var pl : userrec);
begin {checks if player pl1 is dead}

 if pl.hps<=0 then begin
  d(12,pl.name2+' is dead!');
 end;

end; {dead_check *end*}


Procedure ManNeeding_Healing(pl1,pl2,pl3,pl4 : userrec);

procedure walk_away;
begin
 d(config.textcolor,'You decide to walk away from this situation.');
 d(config.textcolor,'You have better things to do than caring for the wounded.');
 crlf;
end;

procedure Murder;
var player0 : ^UserRec;
    i, x : longint;

begin
 d(global_talkcol,'Kill the weak!');
 d(config.textcolor,'Since the man is incapacitated this kill is one of');
 d(config.textcolor,'your easier tasks. You draw a dagger from the mans');
 d(config.textcolor,'belt and cut his throat. For once you manage to get a clean cut...');
 d(config.textcolor,'With the stranger still gurgling in his death struggle');
 d(config.textcolor,'You search his belongings for valuable items...');
 pause;

 x:=random(2000)+250;
 incplayermoney(player,x);
 sd(config.textcolor,'You find ');
 sd(14,commastr(x));
 d(config.textcolor,' '+many_money(x)+' in his purse. Pretty disappointing.');

 x:=random(100)+100;
 incplayerexp(player,x);
 sd(config.textcolor,'You receive ');
 sd(15,commastr(x));
 d(config.textcolor,' experience points for this murder.');

 d(config.textcolor,'You find nothing else of value.');
 d(config.textcolor,'His clothes are worthless rags, and his only weapon');
 d(config.textcolor,'was the dagger, you used to snuff him with.');

 {reaction from team}
 new(player0);
 for i:=1 to 4 do begin
  case i of
   1: player0^:=pl1;
   2: player0^:=pl2;
   3: player0^:=pl3;
   4: player0^:=pl4;
  end; {case .end.}

  if player_active(player0^,true) then begin
   if player0^.chiv>500 then begin
    sd(global_plycol,player0^.name2);
    d(config.textcolor,' didn''t like this!');
   end
   else begin
    sd(global_plycol,player0^.name2);
    d(config.textcolor,' congratulates you to the successful assault.');
   end;
  end;

 end;
 dispose(player0);

 pause;
 d(15,'Disgraceful attack on a DEFENCELESS man!');
 pre_darkness;
 give_darkness(player,100);

end; {murder *end*}

procedure give_up(const stranger,warleader:s70);
var x : longint;
begin
 d(global_talkcol,'He''s hiding over there!');
 sd(config.textcolor,'You show the trolls where ');
 sd(15,stranger);
 d(config.textcolor,' is hiding.');
 sd(15,stranger);
 d(config.textcolor,' is captured and put in chains.');

 x:=random(5000)+500;
 incplayermoney(player,x);

 sd(config.textcolor,'You receive ');
 sd(14,commastr(x));
 sd(config.textcolor,' '+many_money(x)+' for your cooperation with ');
 sd(15,warleader);
 d(config.textcolor,'.');

 pause;

 sd(15,'You failed your mission when you betrayed ');
 sd(global_plycol,stranger);
 d(15,'!');
 dec(player.quests); {failed quest}
 dungeonquest.magicshoppe:=false;

 pre_darkness;
 x:=random(100)+50;
 give_darkness(player,x);

 pause;

end; {give_up *end*}

procedure do_battle(const warleader:s70); {fight troll war-party *start*}
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

 foes:=global_maxmon;

 for i:=1 to foes do begin
  case random(3) of
   0: s:='Troll';
   1: s:='Lumber-Troll';
   2: s:='Mountain-Troll';

  end;

  case random(3) of
   0:begin
      weapon:='Club';
      armor:='Chain-mail';
     end;
   1:begin
      weapon:='Club';
      armor:='Chain-mail';
     end;
   2:begin
      weapon:='Axe';
      armor:='Leather';
     end;
  end; {case .end.}

  hps:=global_dungeonlevel*7;

  if i=1 then begin
   s:=warleader; {the warleader}
   hps:=hps*2;
  end;

  create_monster(i,              {#}
                 s,              {name}
                 hps,            {hps}
                 global_dungeonlevel*3,          {strength}
                 global_dungeonlevel*3,          {defence}
                 'bloody liar!', {phrase}
                 false,          {grabweap}
                 false,          {grabarm}
                 weapon,         {weapon-string}
                 armor,          {armor-string}
                 false,          {poisoned-should be false}
                 false,          {disease -should be false}
                 global_dungeonlevel*3,          {punch}
                 global_dungeonlevel*2,          {armpow}
                 global_dungeonlevel*2);         {weappow}

 end; {for i:= .end.}

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
        'Doomed Attempt',
        ' '+uplc+player.name2+config.textcol1+' tried to hide a courier from',
        ' a troll war-party. '+uplc+player.name2+config.textcol1+' was killed.',
        '',
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

  {news-paper}
  newsy(true,
        'Heroism',
        ' '+uplc+player.name2+config.textcol1+s+' rescued a man from the',
        ' claws of a raiding war-party. The trolls were cut down to.',
        ' the last man.',
        '',
        '',
        '',
        '',
        '',
        '');



  {player survided, now some interaction with the saved girl}
  crlf;
  crlf;
  crlf;
  s:='You wiped out the war party! EXCELLENT WORK!';
  d(14,mkstring(length(s),'*'));
  d(15,s);
  d(5,'This event will be remembered.');

  x:=100+random(100);

  give_chivalry(player,x);

  sd(config.textcolor,'You receive ');
  sd(15,commastr(x));
  d(config.textcolor,' chivalry points for this fight!');

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
  end; {case .end.}

  if (alivebefore=true) and (player_active(player0^,true)=true) then begin

   {team mate survived the fight!}
   {inform player}
   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Heroism'+config.textcol1,
   mkstring(23,underscore),
   'You fought under '+uplc+Player.name2+config.textcol1+' to rescue',
   'a man from being captured by a troll war-party. You fought',
   'excellent and helped to slaughter the trolls.',
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
   case random(4) of
    0: s:='You were stabbed in the back by a wily troll.';
    1: s:='A club smashed your head in!';
    2: s:='In the battle, some swine cut your throat!';
    3: s:='In the battle, a troll broke your neck!';
   end; {case .end.}

   {inform player}
   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Dungeon Party & Your Death'+config.textcol1,
   mkstring(26,underscore),
   'You fought under '+uplc+Player.name2+config.textcol1+' to rescue a man',
   'from being apprehended by a wild bunch of war trolls.',
   s,
   'At least you got a decent funeral.',
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

end; {do_battle (fight troll war-party) *end*}

{Dungeon_Event *START*}

const stranger = 'Rodrik'; {strangers namn}
      bandit   = 'Rugwar'; {bandits name, if you change here, change in magic shoppe to!}
      master   = 'D. Yamanga'; {strangers emplyer}
      warleader= 'Udralf'; {leader for war party, occasionally appearing in this mission}
      need = 5; {healing potions needed by wounded man}

var ch : char;
    i : longint;
    hostile : byte;
    goahead : boolean;
    player0 : ^UserRec;

begin

 clearscreen;
 crlf;
 crlf;

 d(3,'-=Encounter=-');
 d(config.textcolor,'Laying on a flat rock a man tries to call for your');
 d(config.textcolor,'attention. When you come closer you can see that he');
 d(config.textcolor,'is suffering from several wounds, seemingly inflicted');
 d(config.textcolor,'by wild animals.');
 crlf;
 d(config.textcolor,'You also notice that the man has purse brimming over with');
 d(config.textcolor,'silver tied to his belt');

 pause;

 ch:=menu_choices('(T)alk to the stranger','(M)urder him','(W)alk away','','');

 case ch of
  'T':begin {talk to stranger *start*}
       crlf;
       d(config.textcolor,'The man is tall and square-shouldered. He has long blond');
       d(config.textcolor,'hair and is probably in his thirties.');
       d(config.textcolor,'Dressed in rags you could easily take him for a vagrant, but');
       d(config.textcolor,'you can tell from his distinct features that he''s from a');
       d(config.textcolor,'fine family.');
       pause;

       crlf;
       d(config.textcolor,'The man speaks: ');
       d(global_talkcol,' Please give me some healing potions!');

       ch:=menu_choices('(G)ive some potions','(M)urder him','(W)alk away','','');

       case ch of
        'G':begin
             goahead:=false;
             if player.healing<need then begin
              d(config.textcolor,'You don''t have enough potions!');
              {check if teammates have any potions}
              new(player0);
              for i:=1 to 4 do begin
               case i of
                1: player0^:=pl1;
                2: player0^:=pl2;
                3: player0^:=pl3;
                4: player0^:=pl4;
               end;

               if player_active(player0^,true)=true then begin
                if player0^.healing>=need then begin
                 sd(global_plycol,player0^.name2);
                 sd(config.textcolor,' gave the man ');
                 sd(15,commastr(need));
                 d(config.textcolor,' potions.');
                 dec(player0^.healing,need);
                 case i of
                  1: pl1:=player0^;
                  2: pl2:=player0^;
                  3: pl3:=player0^;
                  4: pl4:=player0^;
                 end;

                 {send a message to teammate who saved the man}
                 post(MailSend,
                 player0^.name2,
                 player0^.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 umailheadc+'Dungeon Party & Medical Help'+config.textcol1,
                 mkstring(28,underscore),
                 'You were lead by '+uplc+Player.name2+config.textcol1+' to aid a',
                 'wounded man. You gave him '+uwhite+commastr(need)+config.textcol1+' healing potions.',
                 'The man recovered thanks to you!',
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

                 goahead:=true;
                 break;
                end;
               end;
              end;
              dispose(player0);
             end
             else begin {player had healings}
              goahead:=true;
              dec(player.healing,need);
             end;

             if goahead then begin {the man has been given his potions}
              sd(config.textcolor,'The man takes ');
              sd(15,commastr(need));
              d(config.textcolor,' potions, and is somewhat recovered.');

              d(config.textcolor,'He thanks you and starts to tell you an amazing story');
              d(config.textcolor,'on how he ended up here :');
              pause;
              crlf;
              sd(global_talkcol,' My name is ');
              d(14,stranger);
              sd(global_talkcol,' I was working as a military advisor for ');
              sd(15,master);
              d(global_talkcol,' when his');

              sd(global_talkcol,' Keep was attacked by ');
              sd(15,bandit+'s');
              d(global_talkcol,' band.');

              d(global_talkcol,' I managed to flee and brought with me some');
              sd(global_talkcol,' vital document concerning ');
              sd(15,bandit+'s');
              d(global_talkcol,' criminal');

              d(global_talkcol,' activity in the area.');
              d(global_talkcol,' It''s imperative that these document get through');
              d(global_talkcol,' to the royal court!');
              crlf;
              pause;

              sd(14,stranger);
              d(config.textcolor,' catches his breath and then asks you if he can');
              d(config.textcolor,'confide these paper with you.');

              ch:=menu_choices('(A)ccept','(M)urder '+stranger,'(W)alk away','','');

              case ch of
               'A':begin {accept mission *start*}
                    crlf;
                    d(config.textcolor,'Your instructions are :');
                    d(config.textcolor,'Bring the papers to the Magic Shoppe.');
                    d(config.textcolor,'Show them to the shopkeeper and you will receive further');
                    d(config.textcolor,'instructions there.');
                    crlf;
                    pause;

                    {starting mission!}
                    dungeonquest.magicshoppe:=true;

                    {if random proves true then tempt player to lose
                     quest for the sake of money or threat...hehe}


                    if random(2)=0 then begin
                     {scouts from bandit king arrives}
                     sd(global_plycol,stranger);
                     d(config.textcolor,' suddenly hides behind a large boulder.');
                     d(config.textcolor,'You soon realize why...! A war party has appeared,');
                     d(config.textcolor,'almost without making a sound.');
                     sd(config.textcolor,'The war-trolls are painted with ');
                     sd(15,bandit+'s');
                     d(config.textcolor,' symbol;');
                     d(12,'a red shield with two turtles.');
                     pause;

                     crlf;
                     sd(config.textcolor,'Their leader ');
                     sd(15,warleader);
                     d(config.textcolor,', a tall and mighty beast, orders halt.');
                     d(config.textcolor,'His men inspect the camp and the surroundings. Finally');
                     d(config.textcolor,'he walks up to you and stares at you with his');
                     d(config.textcolor,'burning red eyes :');
                     d(global_talkcol,' We are looking for a wounded man who');
                     d(global_talkcol,' should be in the vicinity. Our hounds');
                     d(global_talkcol,' got bits of him, but we suspect that he''s');
                     d(global_talkcol,' still alive. Our trackers have traced him');
                     d(global_talkcol,' here. Have you seen him?');
                     pause;

                     ch:=menu_choices('(Y)es he is here!','(N)o, I haven''t seen him!','','','');


                     case ch of
                      'Y':begin {Yes he is here}
                           give_up(stranger,warleader);
                          end;
                      'N':begin {No! He is not here!}
                           d(15,'No, I haven''t seen anybody looking like that.');
                           pause;
                           crlf;
                           sd(15,warleader);
                           d(config.textcolor,' looks at you... :');
                           sd(global_talkcol,' You know that my master ');
                           sd(15,master);
                           d(global_talkcol,' would greatly reward the one who');
                           d(global_talkcol,' could locate this man for us. But my masters');
                           d(global_talkcol,' patience is limited. He eats his enemies alive.');
                           d(global_talkcol,' and he HATES liars!');
                           crlf;

                           ch:=menu_choices('(G)ive up '+stranger,
                                            '(I) don''t know what you''re talking about!',
                                            '(A)re you deaf you stupid troll bastard! I haven''t seen anything!',
                                            '(C)harge the war-party',
                                            '');

                           hostile:=4;
                           if ch='A' then begin
                            d(config.textcolor,'The troll chief didn''t like that coming from you!');

                            ch:='I';
                            dec(hostile);
                           end;

                           case ch of
                            'G':begin
                                 give_up(stranger,warleader);
                                end;
                            'I':begin
                                 if random(hostile)=1 then begin
                                  d(15,'Oh no! The trolls are going to attack!');
                                  d(15,'You should have given up '+stranger);
                                  do_battle(warleader);
                                 end
                                 else begin
                                  sd(config.textcolor,'Still suspicious ');
                                  sd(15,warleader);
                                  sd(config.textcolor,' finally decides to move on.');
                                  d(config.textcolor,'The war-party disappears just as quietly');
                                  d(config.textcolor,'as they arrived.');
                                  pause;
                                  crlf;

                                  sd(15,stranger);
                                  d(config.textcolor,' comes forward from his hiding place');
                                  d(config.textcolor,'he thanks you for your courage to stand up to');
                                  d(config.textcolor,'the trolls.');
                                  crlf;

                                 end;

                                end;
                            'C':begin
                                 d(15,'CHARGE!');
                                 d(config.textcolor,'You can take the trolls by surprise!');

                                 do_battle(warleader);
                                end;
                           end;

                          end;
                     end;

                    end;

                    {Player has withstand and fought off temptations to}
                    {fail the mission}
                    if DungeonQuest.magicshoppe=true then begin
                     sd(config.textcolor,'You shake hands with ');
                     sd(global_plycol,stranger);
                     d(config.textcolor,' and wish him good luck on his journey.');
                     sd(config.textcolor,'He is off to see his family in ');
                     sd(14,'Rovanion');
                     d(config.textcolor,', before he joins');

                     sd(config.textcolor,'the remaining forces of ');
                     sd(15,master);
                     d(config.textcolor,' hiding in the mountains.');

                     crlf;
                     d(15,'(Don''t forget your mission!)');
                     pause;
                    end;

                   end;  {accept mission *end*}
               'M':begin
                    murder;
                   end;
               'W':begin
                    walk_away;
                   end;
              end;


             end
             else begin {the man was never given any help}
              d(config.textcolor,'Unable to give the man any help, he dies.');
              d(config.textcolor,'You leave him where you found him.');
              d(config.textcolor,'There is no time for funerals.');
              crlf;
             end;

            end;
        'M':begin
             murder;
            end;
        'W':begin
             walk_away;
            end;
       end;

      end;  {talk to stranger *end*}
  'M':begin {murder *start*}
       murder;
      end;  {murder *end*}
  'W':begin {walk away *start*}
       walk_away;
      end;  {walk away *end*}
 end;

end;

Procedure Harassed_Woman(var pl1,pl2,pl3,pl4:userrec);
const maxleaders = 3;
      leader : array[1..maxleaders] of s70=('Margulf',
                                            'Stompa',
                                            'Radrik');

var ch   : char;
    boss,
    foes,
    greet : byte;
    hps : longint;

procedure rape_girl; {outrageous behaviour}
const maxages = 5;
      age : array[1..maxages] of s70=('fifteen',
                                      'sixteen',
                                      'seventeen',
                                      'eighteen',
                                      'nineteen');
var i,x : longint;
    newswritten : boolean;
    girl_dead : boolean;
    player0 : ^UserRec;
begin

 i:=random(maxages)+1; {set age of girl}

 crlf;
 crlf;
 crlf;

 d(config.textcolor,'The luscious girl is probably not older than '+age[i]+'.');
 d(config.textcolor,'Her skirt is torn and you can see that she has cried her');
 d(config.textcolor,'way through the harsh treatment.');

 sd(config.textcolor,'The gruffly men of ');
 sd(global_plycol,leader[boss]);
 d(config.textcolor,' is a bunch of outlaw degenerates.');
 d(config.textcolor,'They are standing in a ring around the girl, laughing and');
 d(config.textcolor,'humiliating her.');

 sd(global_plycol,leader[boss]+'s');
 d(config.textcolor,' men are known for their fondness of young human females.');
 d(config.textcolor,'One of them is already laying on top of the girl now.');

 pause;

 sd(config.textcolor,'As a favour to you ');
 sd(global_plycol,leader[boss]);
 d(config.textcolor,' shoves aside the orcs nearest to the girl and says:');
 d(global_talkcol,' she is yours!');

 ch:=menu_choices('(S)atisfy your lust','(R)ough her up','(W)alk away','','');

 newswritten:=false;
 girl_dead:=false;

 case ch of
  'S':begin {rape time *start*}
       if player.sex=2 then begin
        {lesbian}
        d(15,'Lesbian manoeuvres!');
        d(config.textcolor,'Everybody seems to be very interested in how you are going to');
        d(config.textcolor,'play with your female companion.');
       end;
       d(10,'You strip the girl.');

       {if drug addict then everything goes wrong}
       if player.addict>50 then begin
        crlf;
        d(config.textcolor,'Because of your drug habits you can''t get your stuff together.');
        d(config.textcolor,'You crawl away from the crowd, while everybody is laughing their');
        d(config.textcolor,'pants off at your expense (impotent bastard).');
        pause;
       end
       else begin {rape continues}
        d(config.textcolor,'The young girls soft and white flesh drives you crazy!');
        d(config.textcolor,'You soon indulge to your inner desires, not minding the');
        d(config.textcolor,'bystanders.');
        d(config.textcolor,'The girl puts up a struggle but is overwhelmed by your');
        d(config.textcolor,'weight. She manages to scratch you on the cheek before');
        d(config.textcolor,'you get an erection.');

        {earn some experience}
        x:=player.level*225;
        incplayerexp(player,x);
        sd(config.textcolor,'You receive ');
        sd(15,commastr(x));
        d(config.textcolor,' experience points.');

        newsy(true,
        'Evil-Doer',
        ' '+uplc+player.name2+config.textcol1+' assaulted and raped a lone',
        ' girl in the dungeons! This shocking act was commited before',
        ' many witnesses, and has been reported to the Royal Court.',
        '',
        '',
        '',
        '',
        '',
        '');

        pause;
       end;

      end; {rape time *end*}
  'R':begin {rough her up *start*}
       d(config.textcolor,'Instead of taking advantage of the girl sexually, you');
       d(config.textcolor,'decide to satisfy your sadistic inclinations.');
       d(config.textcolor,'You unstrap your belt and start a violent beating of');
       d(config.textcolor,'the girl.');

       {if players mental stability is low then he/she might kill the girl}
       if (player.mental<50) and (random(2)=0) then begin
        d(15,'Your mental instability is getting the better of you!');
        d(config.textcolor,'Your dimmed brain has collapsed, and in a moment of');
        d(config.textcolor,'excitement you strangle the girl with your bare hands.');
        d(config.textcolor,'(crazy fool!)');

        dec(player.mental,5);
        if player.mental<0 then player.mental:=0;

        newsy(true,
        'Evil-Doer',
        ' '+uplc+player.name2+config.textcol1+' assaulted and strangled a lone',
        ' girl in the dungeons! This insane act was commited before',
        ' a huge crowd, and has been reported to the local authorities.',
        '',
        '',
        '',
        '',
        '',
        '');

        newswritten:=true;
        girl_dead:=true;

       end;


       if newswritten=false then begin
        newsy(true,
        'Evil-Doer',
        ' '+uplc+player.name2+config.textcol1+' assaulted and beat up a young',
        ' girl lost in the dungeons! This revolting act was witnessed',
        ' and has been reported to the local authorities.',
        '',
        '',
        '',
        '',
        '',
        '');
       end;

       pause;
       d(config.textcolor,'After the job is done you receive sporadic applause from');
       d(config.textcolor,'the surrounding Orcs.');
       sd(global_plycol,leader[boss]);
       d(config.textcolor,' comes forward and shakes your blood-stained hand.');
       pause;
      end;  {rough her up *end*}
  'W':begin {walk away *start*}
       d(config.textcolor,'You walk away in disgust.');
       {scorned only if male character}
       if player.sex=1 then begin
        sd(config.textcolor,'You receive a torrent of abuse from ');
        sd(global_plycol,leader[boss]+'s');
        d(config.textcolor,' men. In their eyes you are not a man.');
       end;
      end;  {walk away *end*}
 end; {case ch of END}

 {team mates decide if they are going to be good or bad, regardless of what
  their immoral leader has acheived}

 new(player0);
 for i:=1 to 4 do begin
  case i of
   1: player0^:=pl1;
   2: player0^:=pl2;
   3: player0^:=pl3;
   4: player0^:=pl4;
  end;

  if player_active(player0^,true) then begin
   if (player0^.dark>100) and (random(2)=0) then begin
    {why not! (opportunist)}
    sd(global_plycol,player0^.name2);
    d(config.textcolor,' waits for '+sex3[player0^.sex]+' turn and then drag');
    d(config.textcolor,'the woman behind a rock and abuses her.');

    {post a message to rapist}
    post(MailSend,
    player0^.name2,
    player0^.ai,
    false,
    mailrequest_nothing,
    '',
    umailheadc+'Dungeon Party & Rape'+config.textcol1,
    mkstring(20,underscore),
    'You were lead by '+uplc+Player.name2+config.textcol1+' to aid in',
    'the rape of an innocent girl. Your evil genes had no',
    'problems of accepting this hideous act.',
    'You had plenty of fun with the luscious girl.',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

    Give_Darkness(player0^,225);

    pause;
   end
   else begin {refuse to participate}
    sd(global_plycol,player0^.name2);
    d(config.textcolor,' takes a step back and says, with tears in '+sex3[player0^.sex]+' eyes : ');
    d(global_talkcol,' I will have no part in this!');

    {post a message to 'had the opportunity to rape but declined' guy/female}
    post(MailSend,
    player0^.name2,
    player0^.ai,
    false,
    mailrequest_nothing,
    '',
    umailheadc+'Dungeon Party & Rape'+config.textcol1,
    mkstring(20,underscore),
    'You were lead by '+uplc+Player.name2+config.textcol1+' to aid in',
    'the rape of an innocent girl. Your good character halted',
    'you to participate in this act of violence. Maybe you should',
    'quit this gang of bandits you are hanging out with!',
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
   end
  end;

  case i of
   1: pl1:=player0^;
   2: pl2:=player0^;
   3: pl3:=player0^;
   4: pl4:=player0^;
  end;

 end;
 dispose(player0);


 crlf;
 sd(config.textcolor,'You decide to leave ');
 sd(global_plycol,leader[boss]+'s');
 sd(config.textcolor,' camp before it gets too late...');
 pause;


end; {rape_girl *END*}

procedure fight_orcs(evil_minded:boolean); {fight the orcish scum}
{if evil_minded=true then player tried to join the orcs in the beginning, but was turned down by them}
var i : byte;
    x : longint;
    s, s2, msg1, msg2 : s70;
    weapon,armor : s70;

    alivebefore,
    alivebefore1,alivebefore2,alivebefore3,alivebefore4:boolean;
    player0 : ^userrec;

begin

 Reset_Monsters;
 Reset_Spells(pl1,pl2,pl3,pl4);

 for i:=1 to foes do begin
  case random(2) of
   0: s:='Orc';
   1: s:='Half-Orc';
  end;

  case random(3) of
   0:begin
      weapon:='Sword';
      armor:='Leather';
     end;
   1:begin
      weapon:='Spear';
      armor:='Chain-mail';
     end;
   2:begin
      weapon:='Axe';
      armor:='Cloth';
     end;
  end;

  hps:=global_dungeonlevel*5;

  if i=1 then begin
   s:=leader[boss]; {the boss}
   hps:=hps*2;
  end;

  create_monster(i,              {#}
                 s,              {name}
                 hps,            {hps}
                 global_dungeonlevel*2,          {strength}
                 global_dungeonlevel*2,          {defence}
                 'trespasser!',  {phrase}
                 false,          {grabweap}
                 false,          {grabarm}
                 weapon,         {weapon-string}
                 armor,          {armor-string}
                 false,          {poisoned-should be false}
                 false,          {disease -should be false}
                 global_dungeonlevel*3,          {punch}
                 global_dungeonlevel*2,          {armpow}
                 global_dungeonlevel*2);         {weappow}

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

 if (global_killed) and (evil_minded) then begin
  newsy(true,
        'Evil Doer Dies',
        ' '+uplc+player.name2+config.textcol1+' was massacred by bandits.',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '');
 end
 else if global_killed then begin
  newsy(true,
        'Desperate Attempt',
        ' '+uplc+player.name2+config.textcol1+' tried to rescue a girl being',
        ' raped by bandits. Unfortunately '+uplc+player.name2+config.textcol1+' was killed.',
        '',
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

  {news-paper}
  newsy(true,
        'Heroism',
        ' '+uplc+player.name2+config.textcol1+s+' rescued a girl from being',
        ' raped by bandits. The outlaws were massacred.',
        '',
        '',
        '',
        '',
        '',
        '',
        '');

  {player survived, now some interaction with the saved girl}
  if not evil_minded then begin
  crlf;
  crlf;
  crlf;
  s:='You saved the GIRL! OUTSTANDING WORK!';
  d(14,mkstring(length(s),'*'));
  d(15,s);
  d(5,'This event will not go unnoticed.');


  x:=100+random(100);

  give_chivalry(player,x);

  sd(config.textcolor,'You receive ');
  sd(15,commastr(x));
  d(config.textcolor,' chivalry points for this act of decency!');

  pause;

  d(config.textcolor,'You wrap a blanket around the exhausted woman, who has');
  d(config.textcolor,'viewed the battle from a safe distance.');
  d(config.textcolor,'After a short recovery, the girl picks up a dagger from');
  sd(config.textcolor,'one of the fallen Orcs. She finds the body of ');
  d(global_plycol,leader[boss]);
  d(config.textcolor,'and starts to desecrate the already-mutilated corpse.');
  pause;

  crlf;
  sd(config.textcolor,'Realizing that this place is far from safe, with ');
  d(global_plycol,leader[boss]+'s');
  d(config.textcolor,'friends nearby, you escort the girl to safer surroundings,');
  d(config.textcolor,'and leave her just outside the Glargmont clearing.');
  pause;

 end
 else begin
   d(config.textcolor,'You look around the ravine for the girl...');
   d(config.textcolor,'But she is gone! (Too bad for you!)');
   pause;
 end
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
   if not evil_minded then begin
   s2:='Dungeon Party & Heroism';
   msg1:='You were lead by '+uplc+Player.name2+config.textcol1+' to rescue a girl from';
   msg2:='being raped. You fought well and killed all enemies.';

   case random(3) of
    0: s:='You got a million thanks from the girl.';
    1: s:='You even got a kiss from the girl!';
    2: s:='You even got a hug from the girl!';
   end;
   end else begin
   s2:='Disgraceful Behaviour!';
   s:='';
   msg1:='You were lead by '+uplc+Player.name2+config.textcol1+' to defile a girl.';
   msg2:='She got away during a fight with some orcs.';
   
   end;
   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s2+config.textcol1,
   mkstring(length(s2),underscore),
   msg1,
   msg2,
   s,
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
   if not evil_minded then begin
   s2:='Dungeon Party & Your Death';
   msg1:='You were lead by '+uplc+Player.name2+config.textcol1+' to rescue a girl from';
   msg2:='being raped by a gang of Orcs.';
   end else begin
   s2:='Dungeon Party & Your Death';
   msg1:='You were lead by '+uplc+Player.name2+config.textcol1+' to defile a girl.';
   msg2:='';
   end;
   case random(4) of
    0: s:='You were stabbed in the back by a wily half-orc.';
    1: s:='A spear penetrated your back!';
    2: s:='In the battle, some swine cut your throat!';
    3: s:='In the battle, some genius cut your throat!';
   end;

   post(MailSend,
   player0^.name2,
   player0^.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s2+config.textcol1,
   mkstring(length(s2),underscore),
   msg1,
   msg2,
   s,
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

 end; {for i:= .end.}
 dispose(player0);

end; {fight_orcs *END*}

var evil_minded : boolean;
begin {RAPE_GIRL event *START*.... a woman is being harassed by local militia}

 foes:=random(5)+5; {decide how many enemies}
 if foes>global_maxmon then foes:=global_maxmon;
 evil_minded:=false;

 crlf;
 crlf;
 crlf;

 {whos in charge of the orcs}
 boss:=random(maxleaders)+1;

 d(11,'Encounter');
 d(config.textcolor,'In a ravine nearby you notice a young woman being');
 sd(config.textcolor,'harassed by a pack of orcish riff-raff (you can see at least ');
 sd(7,+commastr(foes));
 d(config.textcolor,' orcs here).');
 d(config.textcolor,'They are having fun and are probably going to rape her soon...');
 crlf;

 ch:=menu_choices('(R)escue the Woman','(J)oin the Orcs','(L)eave','','');

 case ch of
  'R':begin {rescue woman *start*}
       evil_minded:=false;

       d(15,'Rescue!');
       d(config.textcolor,'You charge down the ravine! Screaming all the way, trying');
       d(config.textcolor,'to make an impression on the confused lot down there...');
       crlf;
       d(config.textcolor,'When you close in on the orc party, you notice that their');
       sd(config.textcolor,'leader is the notorious ');
       sd(global_plycol,leader[boss]);         {renowned = ryktbar}
       d(config.textcolor,'.');
       pause;
       fight_orcs(evil_minded);

      end;  {rescue woman *end*}
  'J':begin {join orcs *start*}
       evil_minded:=true;

       d(15,'Join in on the fun!');

       if team_active(pl1,pl2,pl3,pl4)>1 then begin
        d(config.textcolor,'You and your team move down in the ravine...')
       end
       else begin
        d(config.textcolor,'You move down in the ravine...');
       end;

       d(config.textcolor,'When you close in on the orc party, you notice that their');
       sd(config.textcolor,'leader is the notorious ');
       sd(global_plycol,leader[boss]);         {renowned = ryktbar}
       d(config.textcolor,'.');
       pause;

       {how should the orcish riff-raff meet the player party?}
       greet:=random(3)+1;
       case greet of
        1:begin {suspicious *start*}
           sd(global_plycol,leader[boss]);
           d(config.textcolor,' and a couple of his men meet you half way, armed and');
           sd(config.textcolor,'angry-looking. ');
           sd(global_plycol,leader[boss]);
           d(config.textcolor,' speaks :');
           d(global_talkcol,' This is our party! Leave before I get upset!');

           ch:=menu_choices('(I)nsist','(A)ttack','(L)eave','','');

           case ch of
            'I':begin {insist start}
                 d(config.textcolor,'You beg to be in on the rape of the girl.');

                 case random(2) of
                  0:begin
                     sd(global_plycol,leader[boss]);
                     d(config.textcolor,' looks at you. He then shakes his head and');
                     d(config.textcolor,'draws a sword from his belt :');
                     d(global_talkcol,' You '+race_display(3,player.race,0)+' never learn, do you?');
                     pause;
                     fight_orcs(evil_minded);
                    end;
                  1:begin
                     sd(global_plycol,leader[boss]);
                     d(config.textcolor,' smiles and shakes your hand!');
                     d(config.textcolor,'The moody leader inivites you to his camp.');
                     pause;
                     rape_girl;
                    end;
                 end;
                end;  {insist end}
            'A':begin {attack start}
                 d(15,'TAKE NO PRISONERS!');
                 fight_orcs(evil_minded);
                end;  {attack end}
            'L':begin {leave start}
                 sd(config.textcolor,'You take ');
                 sd(global_plycol,leader[boss]+'s');
                 d(config.textcolor,' advice and withdraw from the scene.');
                 d(config.textcolor,'The orcs soon return to their ugly business.');
                 pause;
                end;  {leave end}
           end;

          end;  {suspicious *end*}
        2:begin {hostile *start*}
           d(15,'Idiot! They are HOSTILE!');
           sd(config.textcolor,'You are being attacked by ');
           sd(global_plycol,leader[boss]+'s');
           d(config.textcolor,' party!');
           pause;
           fight_orcs(evil_minded);
          end;  {hostile *end*}
        3:begin {friendly *start*}
           sd(global_plycol,leader[boss]);
           d(config.textcolor,' seems to be in a good mood. He invites you to his');
           d(config.textcolor,'camp down in the ravine. He lets you know of the latest');
           d(config.textcolor,'news from his people.');
           d(config.textcolor,'You then make your way to the poor girl.');
           pause;
           rape_girl;
          end;  {friendly *end*}
       end;

       {goodness penalty for raping the girl!}
       if evil_minded then begin
        pre_darkness;
        Give_Darkness(player,150);
       end;

      end;  {join orcs *end*}
  'L':begin {leave *start*}
       d(config.textcolor,'You leave the ravine with the poor girl''s agonizing screams');
       d(config.textcolor,'ringing in your ears...');
       pause;

       {goodness penalty for leaving the poor woman!}
       if player.chiv>0 then begin
        d(15,'Your Chivalry went down after this cowardly behaviour!');
        player.chiv:=player.chiv-75;
        if player.chiv<0 then player.chiv:=0;
       end;

      end;  {leave *end*}

 end;

end; {RAPE_GIRL event *END*}

Function Find_Item_Event(var pl1,pl2,pl3,pl4 : userrec) : boolean;
var
    i, j, found : longint;

    active : integer;

    gtyp : objtype;
    player0 : ^userrec;
    objekt  : ^orec;

begin

 new(objekt);  {player finds item in dungeons}

 Find_Item_Event:=false;if config.classic=false then begin
  Find_Item_Event:=true;
  for i:=1 to 15 do begin
   case i of
    1: gtyp:=Head;
    2: gtyp:=Body;
    3: gtyp:=Arms;
    4: gtyp:=Hands;
    5: gtyp:=Fingers;
    6: gtyp:=Legs;
    7: gtyp:=Feet;
    8: gtyp:=Waist;
    9: gtyp:=Neck;
    10: gtyp:=Face;
    11: gtyp:=Shield;
    12: gtyp:=Food;
    13: gtyp:=Drink;
    14: gtyp:=Weapon;
    15: gtyp:=Abody;
   end; {case .end.}

   found:=0;
   for j:=1 to global_maxhittas do begin

    if (hittas[i,j]=true) and (random(4)=0) then begin
     load_objekt(objekt^,gtyp,j);
     if (global_dungeonlevel>=objekt^.minlev) and (global_dungeonlevel<=objekt^.maxlev) then begin
      found:=j;
      break;
     end;
    end;

   end; {for j:= .end.}

   if found>0 then begin
    break;
   end;
  end;

  if found>0 then begin
   crlf;
   crlf;
   d(14,'Item found!');

   active:=team_active(pl1,pl2,pl3,pl4);

   if active>1 then begin
    active:=random(active)+1;
   end;

   if active>1 then begin
    {Offline Player finds an item}

    {init pointer var}
    new(player0);

    case active of
     2: player0^:=pl1;
     3: player0^:=pl2;
     4: player0^:=pl3;
     5: player0^:=pl4;
    end; {case .end.}

    d(global_plycol,player0^.name2+config.textcol1+' has found ');
    d(global_itemcol,objekt^.name);

    case random(4) of
     0:begin
        sd(global_talkcol,'Ha! It''s MINE!');
        sd(config.textcolor,', ');
        sd(global_plycol,player0^.name2);
        d(config.textcolor,' declares.');
       end;
     1:begin
        sd(global_talkcol,'I think I''ll keep it!');
        sd(config.textcolor,', ');
        sd(global_plycol,player0^.name2);
        d(config.textcolor,' says.');
       end;
     2:begin
        sd(global_talkcol,'Hahaha');
        sd(config.textcolor,', ');
        sd(global_plycol,player0^.name2);
        d(config.textcolor,' laughs.');
       end;
     3:begin
        sd(global_talkcol,'I wonder what this can be worth?');
        sd(config.textcolor,', ');
        sd(global_plycol,player0^.name2);
        d(config.textcolor,' ponders.');
       end;

    end; {case .end.}

    {offline character evaluates new item}
    check_inventory(player0^,found,objekt^.ttype,true,1);

    case active of
     2: pl1:=player0^;
     3: pl2:=player0^;
     4: pl3:=player0^;
     5: pl4:=player0^;
    end; {case .end.}

    {dispose pointer var}
    dispose(player0);

   end
   else if active=1 then begin

    {Online Player finds an item}
    d(config.textcolor,'You have found : ');
    d(global_itemcol,' '+objekt^.name);
    crlf;

    if confirm('Pick it up ','N')=true then begin
     i:=inventory_empty(player);
     if i=0 then begin
      d(config.textcolor,'Inventory is full!');
      if confirm('Drop something ','Y')=true then begin
       drop_item(player);
      end;
     end;

     i:=inventory_empty(player);

     if i>0 then begin
      sd(config.textcolor,'You place the ');
      sd(global_itemcol,objekt^.name);
      d(config.textcolor,' in your backpack');
      player.item[i]:=found;
      player.itemtype[i]:=objekt^.ttype;
      pause;
     end;

    end;
   end;
  end;
 end;

 {dispose pointer vars}
 dispose(objekt);

end; {find_item_event *end*}

Function Dungeon_Event;
var

    j, xx, x, y, i : longint;

    foes,
    rendezvous : byte;

    ch         : char;

    ciao,
    goahead,
    visit,
    done      : boolean;


    s, s2 : s70;

    player0 : ^userrec;
    objekt  : ^orec;

begin

 global_escape:=false;
 dungeon_event:=false;
 new(objekt);

 x:=random(8);
 if (x=0) and (player.wellwish=false) and (global_auto_probe=Nowhere) then begin

  {*WISHING WELL START*}

  crlf;
  d(14,'You have come across a Wishing WELL!');

  if confirm('Take this Golden Opportunity','y')=true then begin
   crlf;
   d(5,'$------------------$');
   d(5,'$-> Wishing Well <-$');
   d(5,'$------------------$');

   menu2('(1) Strength   ');
   menu('(7) Stamina');

   menu2('(2) Defence    ');
   menu('(8) Agility');

   menu2('(3) Money      ');
   menu('(9) Charisma');

   menu2('(4) Healings   ');
   menu('(0) Dexterity');

   menu2('(5) Hitpoints  ');
   menu('(W)isdom');

   menu2('(6) Experience ');
   menu('(M)ana');

   menu('(A)bort wish');

   sd(config.textcolor,':');

   ciao:=false;
   repeat

    {get user-input}
    ch:=upcase(getchar);
    visit:=true;

    {evaluate user-input}
    case ch of
     'A':begin
          d(config.textcolor,'Abort.');
          ciao:=true;
          visit:=false;
         end;
     '1':begin
          x:=1;
          inc(player.strength,random(3) + 1);
          crlf;
          d(config.textcolor,'Your Strength has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     '2':begin
          x:=random(5)+2;
          inc(player.defence,x);
          crlf;
          sd(config.textcolor,'Your defence capabilities increased by ');
          sd(15,commastr(x));
          d(config.textcolor,' points!');
          crlf;
          pause;
          ciao:=true;
         end;
     '3':begin
          x:=player.level*random(1200)+1;
          incplayermoney(player,x);
          crlf;
          sd(config.textcolor,'Your pockets are filled with ');
          sd(14,commastr(x));
          d(config.textcolor,' '+many_money(x)+'!');
          crlf;
          pause;
          ciao:=true;
         end;
     '4':begin
          x:=random(25)+20;
          inc(player.healing,x);
          crlf;
          sd(config.textcolor,'Your supply of Healing Potions increased by ');
          sd(15,commastr(x));
          d(config.textcolor,' !');
          crlf;
          pause;
          ciao:=true;
         end;
     '5':begin
          x:=random(5)+2;
          inc(player.maxhps,x);
          player.hps:=player.maxhps;
          crlf;
          d(config.textcolor,'Your Hitpoints have increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     '6':begin
          x:=random(1000)+300;
          if player.level>20 then begin
           x:=x*(random(10)+1);
          end;
          incplayerexp(player,x);
          crlf;
          d(config.textcolor,'Your Experience has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     '7':begin
          x:=random(2)+1;
          inc(player.stamina,x);
          crlf;
          d(config.textcolor,'Your Stamina has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     '8':begin
          x:=random(2)+1;
          inc(player.agility,x);
          crlf;
          d(config.textcolor,'Your Agility has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     '9':begin
          x:=random(3)+1;
          inc(player.charisma,x);
          crlf;
          d(config.textcolor,'Your Charisma has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     '0':begin
          x:=random(3)+1;
          inc(player.dex,x);
          crlf;
          d(config.textcolor,'Your Dexterity has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     'W':begin {wisdom}
          x:=random(3)+1;
          inc(player.wisdom,x);
          crlf;
          d(config.textcolor,'Your Wisdom has increased!');
          crlf;
          pause;
          ciao:=true;
         end;
     'M':begin {mana}
          if player.maxmana>=32000 then begin
           crlf;
           d(12,'YOU HAVE REACHED YOUR MAXIMUM MANA CAPACITY!');
           pause;
           ciao:=true;
          end
          else begin
           x:=random(4)+1;
           inc(player.maxmana,x);
           player.mana:=player.maxmana;
           crlf;
           d(config.textcolor,'Your MANA has increased!');
           crlf;
           pause;
           ciao:=true;
          end;
         end;

    end; {case .end.}

   until ciao;

   if visit then begin
    dungeon_event:=true;
    player.wellwish:=true;
   end;

  end;
 exit;
 end; {**WISHING WELL END**}

 {*Should player (and team) be caught in something... an event}
 
 {if random(1)=0 then begin {cheat, jakob}

 if random(8)=1 then begin
  dungeon_event:=true;

  rendezvous:=random(11);
  {rendezvous:=10; {cheat, jakob}
  case Rendezvous of

   0:begin {**OLD MAN WITH MAP START**}
      clearscreen;
      show_usurper_data(picture_OLD_MAN,true);
      crlf;
      crlf;
      case random(3) of
       0:begin
          d(11,'*An old man approaches you*');
          d(config.textcolor,'He gives you a treasure map and then leaves.');
          crlf;
         end;
       1:begin
          d(11,'*MAP FOUND*');
          d(config.textcolor,'You have found an old map!');
          crlf;
         end;
       2:begin
          d(11,'*An old woman stops you*');
          d(config.textcolor,'She gives you a map. She says it will make you rich.');
          d(config.textcolor,'You can see that the old Hag has a purse, with '+config.moneytype+' perhaps?');
          crlf;
          menu('(L)et the woman go');
          menu('(C)ut her throat');
          sd(config.textcolor,':');
          repeat
           ch:=upcase(getchar);
          until ch in ['L','C'];
          crlf;

          case ch of
           'L':begin {let the woman go}
                d(config.textcolor,'You let the woman disappear in the shadows.');
               end;
           'C':begin {cut the womans throat}
                d(config.textcolor,'The poor womans deathcry echoes through the mountain.');
                d(config.textcolor,'Your hands are covered in warm blood...');
                d(config.textcolor,'You can hear your heart pounding. You enjoyed it.');
                crlf;

                give_darkness(player,50);

                case random(2) of
                 0:begin
                    sd(config.textcolor,'The womans purse was empty!');
                   end;
                 1:begin
                    xx:=player.level*random(5000);
                    incplayermoney(player,xx);
                    sd(config.textcolor,'You found ');
                    sd(14,commastr(xx));
                    d(config.textcolor,' '+many_money(xx)+'!');
                    crlf;
                    pause;
                    crlf;
                   end;
                end;
               end;

          end; {case .end.}

         end;

      end;

      if confirm('Follow Map','N')=false then begin
       d(global_talkcol,'I have better things to do!');
      end
      else begin
       case random(3) of
        0:begin {gold}
           crlf;
           d(14,'**Treasure**');
           d(config.textcolor,'You have found a Treasure!');
           i:=global_dungeonlevel;
           xx:=i*1500+(random(5000));
           sd(config.textcolor,'You find ');
           sd(14,commastr(xx));
           d(config.textcolor,' '+many_money(xx)+'!');
           incplayermoney(player,xx);
           xx:=i*200+(random(5000));
           sd(config.textcolor,'You gained ');
           sd(15,commastr(xx));
           d(config.textcolor,' experience points!');
           incplayerexp(player,xx);
           crlf;
           pause;
          end;
        1:begin {kanske en olycka}
           crlf;
           sd(config.textcolor,'You travel many hours before reaching your destination...');
           delay2(600);
           crlf;
           d(config.textcolor,'Finally! Before you lies a huge cave with only one small entrance.');
           d(config.textcolor,'The treasure should be in here.');
           case random(3) of
            0: d(config.textcolor,'The Cave appears to be empty. But you can never be sure...');
            1: d(config.textcolor,'Skulls and bones are laying outside the Cave. Danger ahead!');
            2: d(config.textcolor,'You can hear some noise from the Cave. Something is in there.');
           end;

           crlf;
           if confirm('Dare you enter the Cave','Y')=true then begin
            crlf;
            sd(config.textcolor,'Entering a room filled with ');
            d(15,'GIANT WORMS!');

            Reset_Monsters;
            Reset_Spells(pl1,pl2,pl3,pl4);

            foes:=global_maxmon-random(7);
            if foes<3 then foes:=3;

            for i:=1 to foes do begin
             monster[i]^.hps:=player.level*5;
             if monster[i]^.hps<25 then monster[i]^.hps:=35;
             monster[i]^.phrase:='sssss!';
             case random(2) of
              0: monster[i]^.name:='Giant-Worm';
              1: monster[i]^.name:='Sleeze-Worm';
             end;
             monster[i]^.grabweap:=false;
             monster[i]^.grabarm:=false;
             case random(2) of
              0: monster[i]^.weapon:='Poison';
              1: monster[i]^.weapon:='Nothing';
             end;
             monster[i]^.poisoned:=false;
             monster[i]^.disease:=false;
             monster[i]^.strength:=player.level*2;
             monster[i]^.punch:=player.level*70;
            end;

            global_escape:=false;
            global_begged:=false;
            global_nobeg:=true;

            player_vs_monsters(pl_vs_monster,pl1,pl2,pl3,pl4);

            if global_killed=false then begin
             crlf;
             pause;
             clearscreen;
             crlf;
             crlf;

             sd(14,' ');
             d(14,'** SUCCESSFUL BATTLE **');
             crlf;
             d(config.textcolor,'After having slaughtered all of the beasts,');
             d(config.textcolor,'You seek the cave for treasure. You find some weapon and');
             sd(config.textcolor,'gold. It''s all worth ');

             {size of treasure}
             xx:=player.level*1500;

             sd(14,commastr(xx));
             d(config.textcolor,' '+many_money(xx)+'.');
             crlf;
             incplayermoney(player,xx);

            end
            else begin {failed mission}
             {haha...byebye}
            end;


           end
           else begin
            crlf;
            d(config.textcolor,'You decide to walk away from this potentially dangerous place.');
            crlf;
           end;

          end;
        2:begin {ingenting}
           crlf;
           d(3,'You found nothing..');
          end;
       end;
      end;
     end; {** OLD MAN WITH MAP END ***}


   1:begin {** WOUNDED WARRIOR START**}
      clearscreen;
      crlf;
      crlf;
      d(12,'Wounded Warrior!');
      d(5,'');
      d(config.textcolor,'A man is laying on the ground. You can see that he is mortally wounded.');
      d(config.textcolor,'The ground has all the signs of battle where the warrior made');
      d(config.textcolor,'his last stand. You listen to him :');
      crlf;
      d(global_talkcol,' A group of orcish riff-raff ambushed me outside Khartan!');
      d(global_talkcol,' I tried to escape but they had me cornered here...');
      pause;
      crlf;
      d(global_talkcol,' I think the bandits are travelling north, toward Monluth.');
      d(global_talkcol,' They were probably Stemuih-Kha renegades or deserters.');
      d(global_talkcol,' I was on my way with important letters from the King.');
      d(global_talkcol,' It''s vital that they are delivered, this to prevent');
      d(global_talkcol,' the kingdom from being teared apart in a civilwar!');
      crlf;
      pause;
      menu('(L)eave this mess');
      menu('(R)ob the dying man');
      menu('(T)ake a royal oath and pursue the villains');
      sd(config.textcolor,':');

      repeat
       ch:=upcase(getchar);
      until ch in ['L','R','T'];
      crlf;

      case ch of
       'L':begin
            crlf;
            d(config.textcolor,'You leave the warrior to die in the damp cave.');
            d(config.textcolor,'(the gods won''t approve of this!)');
            crlf;
            pause;
           end;
       'R':begin
            crlf;
            d(config.textcolor,'You frisk the warrior of all of his belongings.');
            x:=random(5000)+random(5000)+random(600);
            sd(config.textcolor,'All together you get ');
            sd(14,commastr(x));
            d(config.textcolor,' '+many_money(x)+'.');

            crlf;
            d(config.textcolor,'The man dies just before you leave');
            d(config.textcolor,'(you dirty thief!)');
            incplayermoney(player,x);
            pause;
          end;
      'T':begin {the royal oath! horray!}
           crlf;

           if team_active(pl1,pl2,pl3,pl4)>1 then begin
            d(config.textcolor,'You and your team swear to avenge this cowardly deed!');
           end
           else begin
            d(config.textcolor,'You swear to avenge this cowardly deed!');
           end;
           d(config.textcolor,'You promise to deliver the letters, if it so should take');
           d(config.textcolor,'you to the deepest dungeons of hell.');
           crlf;
           pause;
           d(config.textcolor,'Soon afterwards the warrior fades away and dies from his wounds.');
           d(config.textcolor,'You bury him with his weapons and then set after the orchish band...');
           pause;

           {jakten p† breven b”rjar}
           foes:=global_maxmon-random(7);

           crlf;
           sd(config.textcolor,'You follow the trail that leads deep into the mountain...');
           delay2(900);
           crlf;
           d(config.textcolor,'After many hours of tracking you spot the orcish gang, camped');
           sd(config.textcolor,'in a narrow ravine. You can see at least ');
           sd(15,commastr(foes));
           d(config.textcolor,' orcs in the area.');

           d(config.textcolor,'It is time for battle.');
           pause;
           crlf;

           Reset_Monsters;
           Reset_Spells(pl1,pl2,pl3,pl4);

           for i:=1 to foes do begin
            monster[i]^.hps:=player.level*5;
            if monster[i]^.hps<25 then monster[i]^.hps:=35;
            case random(3) of
             0: monster[i]^.phrase:='Ambush!';
             1: monster[i]^.phrase:='Attack!';
             2: monster[i]^.phrase:='Enemies!';
            end;
            case random(2) of
             0: monster[i]^.name:='Orc';
             1: monster[i]^.name:='Half-Orc';
            end;
            monster[i]^.grabweap:=false;
            monster[i]^.grabarm:=false;
            case random(3) of
             0: monster[i]^.weapon:='Spear';
             1: monster[i]^.weapon:='Sword';
             2: monster[i]^.weapon:='Axe';
            end;
            monster[i]^.poisoned:=false;
            monster[i]^.disease:=false;
            monster[i]^.strength:=player.level*2;
            monster[i]^.punch:=player.level*100;
           end;

           global_escape:=false;
           global_begged:=false;
           global_nobeg:=true;

           player_vs_monsters(pl_vs_monster,pl1,pl2,pl3,pl4);

           if global_killed=false then begin
            crlf;
            pause;
            clearscreen;
            crlf;
            crlf;

            sd(14,' ');
            d(14,mkstring(25,chr(196)));
            d(14,'** SUCCESSFUL MISSION **');
            d(14,mkstring(25,chr(196)));
            crlf;
            d(config.textcolor,'After having slaughtered all of the orcish riff-raff,');
            d(config.textcolor,'You seek the camp for the royal letters. You find them');
            d(config.textcolor,'on one of the orc leaders.');
            pause;
            crlf;

            {storlek p† bel”ningen}
            xx:=player.level*500;

            sd(12,'The Royal Council');
            sd(config.textcolor,' has rewarded you with ');
            sd(15,commastr(xx));
            sd(config.textcolor,' '+many_money(xx));
            d(config.textcolor,' for your heroic effort.');
            crlf;

            incplayermoney(player,xx);

            if random(1)=0 then begin {hittar ICE-MAP!}
             sd(config.textcolor,'You have also found a secret map over the ');
             d(11,'ICE-CAVES!');
             d(config.textcolor,'(press ? in the dungeons to check this out)');
             global_icemap:=true;
             pause;
            end;

            reset_spells(pl1,pl2,pl3,pl4);
           end
           else begin {failed mission}
            {haha...byebye...avslutningsrutiner i dungeonc.pas}
           end;

          end;
      end;

     end; {**WOUNDED WARRIOR END**}

   2:begin {**TREASURE CHEST START**}
      clearscreen;
      crlf;
      crlf;
      d(15,'    **Discovery!**');
      crlf;

      draw_picture('TREASURE-CHEST');

      crlf;
      case random(5) of
       0: s:='black';
       1: s:='red';
       2: s:='green';
       3: s:='brown';
       4: s:='dusty';
      end;

      d(config.textcolor,'You have found a '+s+' chest.');
      d(config.textcolor,'There are some inscriptions on the front :');
      d(config.textcolor,'(elf runes)');

      y:=random(3); {best„mmer vad som d”ljer sig i kistan}

      case y of
       0:begin
           s:='Sghara Xavhanji Zheet';
          s2:='Open this and die!';
         end;
       1:begin
          s:='Moonh Ihmloth!';
         s2:='I will heal you.';
         end;
       2:begin
          s:='Xavath Erhna Riuh';
         s2:='Ancient wisdom lays in here';
         end;
      end;

      {enast Elves kan tyda dessa tecken}
      visit:=false;
      if player.race=Elf then begin
       visit:=true;
      end
      else begin {kolla om elf finns i teamet}
       if (pl1.name2<>'') and (pl1.hps>0) and (pl1.race=elf) then begin
        sd(11,pl1.name2);
        d(config.textcolor,' interprets the signs...');
        visit:=true;
       end
       else if (pl2.name2<>'') and (pl2.hps>0) and (pl2.race=elf) then begin
        sd(11,pl2.name2);
        d(config.textcolor,' interprets the signs...');
        visit:=true;
       end
       else if (pl3.name2<>'') and (pl3.hps>0) and (pl3.race=elf) then begin
        sd(11,pl3.name2);
        d(config.textcolor,' interprets the signs...');
        visit:=true;
       end
       else if (pl4.name2<>'') and (pl4.hps>0) and (pl4.race=elf) then begin
        sd(11,pl4.name2);
        d(config.textcolor,' interprets the signs...');
        visit:=true;
       end;
      end;

      if visit then begin
       d(global_talkcol,' '+s2);
      end
      else begin
       d(global_talkcol,' '+s2);
      end;

      crlf;
      if confirm('Open Chest','Y')=true then begin
       crlf;
       sd(15,'Kreeeek.....');
       delay2(300);
       crlf;

       case y of
        0:begin {deadly gas!}
           d(12,'Ssssssss...!! It''s poisonous gas!');
           d(config.textcolor,'You try to escape this deadly threat....');

           xx:=random(player.level);
           if xx<5 then xx:=5;

           if random(2)=0 then begin
            sd(12,'But it''s too late! ');
            sd(config.textcolor,'You lose ');
            sd(15,commastr(xx));
            d(config.textcolor,' hitpoints.');
            dec(player.hps,xx);
           end
           else begin
            d(config.textcolor,'You managed to get away from the gas!');
           end;

           if (pl1.name2<>'') and (pl1.hps>0) and (random(2)=0) then begin
            d(config.textcolor,pl1.name2+' suffers from the gas.');
            dec(pl1.hps,xx);
            dead_check(pl1);
           end;
           if (pl2.name2<>'') and (pl2.hps>0) and (random(2)=0) then begin
            d(config.textcolor,pl2.name2+' suffers from the gas.');
            dec(pl2.hps,xx);
            dead_check(pl2);
           end;
           if (pl3.name2<>'') and (pl3.hps>0) and (random(2)=0) then begin
            d(config.textcolor,pl3.name2+' suffers from the gas.');
            dec(pl3.hps,xx);
            dead_check(pl3);
           end;
           if (pl4.name2<>'') and (pl4.hps>0) and (random(2)=0) then begin
            d(config.textcolor,pl4.name2+' suffers from the gas.');
            dec(pl4.hps,xx);
            dead_check(pl4);
           end;

           if player.hps<=0 then begin
            d(12,'YOU ARE DEAD!');
            global_killed:=true;
            pause;
           end;

          end;
        1:begin {potions}
           d(config.textcolor,'The chest is filled with healing potions!');
           d(config.textcolor,'You grab as many as you can carry...');
           xx:=random(player.level)+1;
           xx:=xx*2;
           sd(config.textcolor,'You took ');
           sd(15,commastr(xx));
           d(config.textcolor,' potions.');
           player.healing:=player.healing+xx;

          end;
        2:begin {scroll}
           {type of scroll}
           y:=random(3);
           case y of
            0:begin {blessing scroll}
               d(config.textcolor,'You have found a scroll! It reads :');
               d(15,' Utter : '+utalkc+'XAVARANTHE JHUSULMAX VASWIUN'+config.textcol1);
               d(15,' And you will receive a blessing.');
               crlf;
              end;
            1:begin {summons a gang of undeads}
               d(config.textcolor,'You have found a scroll! It reads :');
               d(15,' Utter : '+utalkc+'ZASHNIVANTHE ULIPMAN NO SEE'+config.textcol1);
               d(15,' And you will see ancient power rise again.');
               crlf;
              end;
            2:begin {secret cave}
               d(config.textcolor,'You have found a scroll! It reads :');
               d(15,' Utter : '+utalkc+'RANTVANTHI SHGELUUIM VARTHMIOPLXH'+config.textcol1);
               d(15,' And you will be given opportunities.');
               crlf;
              end;
           end;

           if confirm('Recite the Scroll','Y')=true then begin
            crlf;
            case y of
             0:begin {blessing scroll}
                xx:=random(500)+50;
                give_chivalry(player,xx);

                d(config.textcolor,'You feel a cool breeze, and your heart feels a bit stronger!');

                if player_active(pl1,true) then give_chivalry(pl1,xx);
                if player_active(pl2,true) then give_chivalry(pl2,xx);
                if player_active(pl3,true) then give_chivalry(pl3,xx);
                if player_active(pl4,true) then give_chivalry(pl4,xx);

               end;
             1:begin {summonar ett g„ng undeads}
                d(config.textcolor,'The earth trembles and through a crack in the ground you see');
                d(config.textcolor,'shadows stream up against the lights from your torch.');
                d(config.textcolor,'You have unleashed the undead!');
                pause;

                Reset_Monsters;
                Reset_Spells(pl1,pl2,pl3,pl4);

                foes:=global_maxmon-random(7);
                if foes<3 then foes:=3;

                for i:=1 to foes do begin
                 monster[i]^.hps:=player.level*5;
                 if monster[i]^.hps<25 then monster[i]^.hps:=35;
                 monster[i]^.phrase:='...';
                 case random(2) of
                  0: monster[i]^.name:='Undead';
                  1: monster[i]^.name:='Zombie';
                 end;
                 monster[i]^.grabweap:=false;
                 monster[i]^.grabarm:=false;
                 case random(2) of
                  0: monster[i]^.weapon:='Sword';
                  1: monster[i]^.weapon:='Nothing';
                 end;
                 monster[i]^.poisoned:=false;
                 monster[i]^.disease:=false;
                 monster[i]^.strength:=player.level*2;
                 monster[i]^.punch:=player.level*70;
                end;

                global_escape:=false;
                global_begged:=false;
                global_nobeg:=true;

                player_vs_monsters(pl_vs_monster,pl1,pl2,pl3,pl4);

                if global_killed=false then begin
                 clearscreen;
                 crlf;
                 crlf;
                 sd(14,' ');
                 d(14,'** SUCCESSFUL BATTLE **');
                 crlf;
                 d(config.textcolor,'After having slaughtered all of the Undead,');
                 d(config.textcolor,'You seek the remains for treasure. You find nothing.');
                 d(config.textcolor,'You should be lucky you''re still alive.');
                 pause;
                 crlf;

                end;

               end;
             2:begin {secret cave}
                d(config.textcolor,'A secret door appears from behind a large boulder.');
                sd(config.textcolor,'A sign on the door reads : ');
                d(14,' A place for Rest and Test');
                crlf;
                if confirm('Enter','Y')=true then begin
                 crlf;
                 sd(15,'Kreeeek.....');
                 delay2(600);

                 crlf;
                 d(config.textcolor,'It seems as if you have entered a backdoor into a great Cavern.');
                 pause;

                 Uman_Cave;

                end
                else begin
                 crlf;
                 d(config.textcolor,'You walk away.');
                end;

               end;
            end;

           end
           else begin
            d(config.textcolor,'You close the chest and leave.');
           end;
          end;
       end; {case .end.}
      end
      else begin
       crlf;
       d(config.textcolor,'You leave the chest.');
      end;

     end; {**TREASURE CHEST END**}


   3:begin {SURROUNDED BY STRANGERS}
      strangers(pl1,pl2,pl3,pl4);
     end; {SURROUNDED BY STRANGERS}

   4:begin {Find item}
      Dungeon_Event:=Find_Item_Event(pl1,pl2,pl3,pl4);
     end;
   5:begin {Harassed Woman}
      Harassed_Woman(pl1,pl2,pl3,pl4);
     end;

   6:begin {Man needing healing -QUEST-}
      Dungeon_Event:=false;
      if DungeonQuest.magicshoppe=false then begin
       Dungeon_Event:=true;
       ManNeeding_Healing(pl1,pl2,pl3,pl4);
      end;
     end;
   7:begin {merchant with goods}
      merchant(pl1,pl2,pl3,pl4);
     end;
   8:begin {beggar wants money, but gets a broken neck}
      beggar(pl1,pl2,pl3,pl4);
     end;
   9:begin {witchdoctor}
      Dungeon_Event:=witch_doctor;
     end;
  10:begin {sniff glue}
      sniffing_glue(pl1,pl2,pl3,pl4);
     end;
  15:begin {**MONSTER JOIN START**}

     { crlf;
      d(config.textcolor,'You are approached by a Orc, who offers to join you!');
      if confirm('Allow him','Y')=false then begin
       crlf;
       d(config.textcolor,'You dismiss the creature.');
      end
      else begin
       d(config.textcolor,'OK. The creature has joined you!');
      end;
        }
     end; {**MONSTER JOIN END**}

            {satan}
            {charma monster}
            {t”rstig man ber om vatten...egentligen ett test om godhet??}
            {man guarding cave...don''t go inside!}
            {windbag}
            {knight in white shiny armor. guarding a gate}
            {man hanging off a cliff. help or push}
            {knock off wino, please don't leave me alone he whimpered}
            {more harrasment av kvinnor}
            {astrolog beh”ver ingredienser, quest}
            {obnoxious man = otrevlig man}
            {saker du inte gjort sl”fock : teamet f†r dela p† rewards
                                   man b”r inte uppleva samma quest
                                   fler g†nger samma entry, eller?}





         {a girl standing at the mouth of the cave beckoned him in}
         {old hag}
         {walking about on crutches}
         {hostages}
         {settlers goes down on their knees and beg not to be slaughtered}
         {enter a dungeon and then sleeping gas, robbed of everything! trick!}
         {smuggle drugs to the drug palace}
         {wounded or hurt dog,cat bear}
         {handicapped child}
         {angry giant}
         {sadistic madman}
         {vestal}
         {You find a sack brimming over with gold!}
         {you have found a sack! open it! something is making noise from it}
         {anybody moves and I'll execute every motherfucking last one of you!}
         {female beggar, different ways to die}
         {the witch-doctor has cursed our cattle}
         {br„nna ner en stuga, bara f”r att dj„vlas}
         {drink this bottle, or I'll kill you!!}
         {do you find me attractive? (asks the old hag) }
         {riddlemaster, answer my riddles or face the fire of ork}
         {crazy man says : "kiss the dirt or else!"}

  end; {case .end.}
 end;

 {dispose of pointer variable}
 dispose(objekt);

end; {Dungeon_Event *end*}

end.{Unit DungEvc .end.}
