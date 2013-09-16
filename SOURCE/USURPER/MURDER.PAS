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



Unit Murder; {Usurper - where you murder innocent people, and get
                        evil points + experience}

Interface

Procedure Murdering;

Implementation

Uses Init, Cms, Jakob,
     Various, Various2, Various3,
     News, PlvsMon, Online;

var
   execute,
   crime : boolean;

   x,
   i : longint;

   cho,
   ch : char;

   s, hang1, hang2, victim : ^s90;

   a2 : s90;

   pl : array[1..4] of ^userrec;

Procedure Murdering;
begin

 {init temporary pointer variables}
 new(s);
 new(victim);
 new(hang1);
 new(hang2);
 for i:=1 to 4 do begin
  new(pl[i]);
 end;

 {update player location}
 onliner.location:=onloc_darkeralley;
 onliner.doing   :=location_desc(onliner.location);
 add_onliner(OUpdateLocation,Onliner);

 clearscreen;
 crlf;
 d(config.textcolor,'You sneak into a dark alley, where you wait for a victim.');
 crlf;

 crime:=false;

 case random(8) of
  0:begin
     d(config.textcolor,'Suddenly a drunk whore stumbles into the alley...');
     crlf;
     menu2('(S)nuff the whore  ');
     menu2('(L)eave the poor woman :');
     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];

     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'You quickly sneak up behind the drunk woman and');
      d(config.textcolor,'put your strong hands around her throat! As she tries');
      d(config.textcolor,'to scream you squeeze harder. After a while you realize');
      d(config.textcolor,'that you are holding a dead body...');
      d(config.textcolor,'You feel tired, but at the same time very satisfied.');
      crlf;
      victim^:='a whore';
      pause;
     end;
    end;
  1:begin
     d(config.textcolor,'Suddenly a crippled man makes his appearance before your eyes...');
     crlf;
     menu2('(S)nuff the man  ');
     menu2('(L)et him live :');

     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];

     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'You kick his cane so he falls to the ground.');
      d(config.textcolor,'Without any hesitation you put a hand over his mouth');
      d(config.textcolor,'and cut his throat with a single slice...');
      d(config.textcolor,'As the warm blood pours between your fingers');
      d(config.textcolor,'you feel excited and somehow reborn...');
      crlf;
      victim^:='a crippled man';
      pause;
     end;
    end;
  2:begin
     d(config.textcolor,'Suddenly a lame woman passes you in her wheelchair...');
     crlf;
     menu2('(S)nuff the lame woman   ');
     menu2('(L)et the woman live :');

     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];
     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'You kick the lame womans wheelchair so it tips over.');
      d(config.textcolor,'As she lays there cursing you for your carelesness');
      d(config.textcolor,'you place her head between your hands...a quick bend');
      d(config.textcolor,'and the lame womans neck snaps like a dry wooden branch.');
      d(config.textcolor,'You feel dirty, but also excited...');
      crlf;
      victim^:='a lame woman';
      pause;
     end;
    end;
  3:begin
     d(config.textcolor,'Suddenly a village-fool strolls into the alley...');
     crlf;
     menu2('(S)nuff the fool  ');
     menu2('(L)et him pass :');
     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];
     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'You command the fool to come over to you.');
      d(config.textcolor,'Finally he expectantly stands before you as he was');
      d(config.textcolor,'going to get a reward or something. You smile and');
      d(config.textcolor,'feel the sharpness of the stone which you have hidden');
      d(config.textcolor,'behind your back. With an explosive stroke you hit');
      d(config.textcolor,'the fool right between his eyes. As he falls to the');
      d(config.textcolor,'ground you finish him off with two more precise strokes.');
      d(config.textcolor,'You are covered with blood after your hideous act...');
      crlf;
      victim^:='a village fool';
      pause;
     end;
    end;
  4:begin
     d(config.textcolor,'Suddenly an old couple make their way through the alley...');
     crlf;
     menu2('(S)nuff the old folks  ');
     menu2('(L)et the poor couple pass :');
     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];
     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'You quickly knock them both unconscious with a');
      d(config.textcolor,'wooden club. You then crush their skulls with two');
      d(config.textcolor,'well directed strokes.');
      d(config.textcolor,'"Hey! that was a pro in action!" you think for yourself.');
      d(config.textcolor,'You search their bodies for '+config.moneytype+'...');
      crlf;
      victim^:='an old couple';
      pause;
     end;
    end;
  5:begin
     d(config.textcolor,'Suddenly a beggar approaches you! "Give something to the poor!" he cries...');
     crlf;
     menu2('(S)nuff the beggar  ');
     menu2('(L)et the poor man go :');
     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];
     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'"Sure old man! Come over here and i will give you');
      d(config.textcolor,'something" you say in a gentle voice. The beggar then gets');
      d(config.textcolor,'a quite surprised look in his face when you drive your dagger');
      d(config.textcolor,'deep into his chest.');
      d(config.textcolor,'You feel comfortable after this quick and clean murder...');
      d(config.textcolor,'"Gee, this guy won'+chr(39)+'t bother anyone anymore!" you');
      d(config.textcolor,'think for yourself...');
      crlf;
      victim^:='a beggar';
      pause;
     end;
    end;
  6:begin
     d(config.textcolor,'A little girl suddenly comes running down the alley...');
     crlf;
     menu2('(S)nuff the child   ');
     menu2('(L)et the child live :');
     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];
     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'Just when the girl passes you, you trip her legs.');
      d(config.textcolor,'As the hardened and notorius murderer you are you don'+chr(39)+'t');
      d(config.textcolor,'listen to the childs snivels and beggings for mercy.');
      d(config.textcolor,'You quickly strangle her and then hide her body in the');
      d(config.textcolor,'shadows. "Heck! That was a brave deed!" you think for');
      d(config.textcolor,'yourself... But you can feel how your soul darkens...');
      crlf;
      victim^:='a little girl';
      pause;
     end;
    end;
  7:begin
     d(config.textcolor,'Suddenly you see a blind man making his way through the alley...');
     crlf;
     menu2('(S)nuff the blind man  ');
     menu2('(L)et him pass :');
     repeat
      cho:=upcase(getchar);
     until cho in ['S','L'];
     crlf;
     if cho='S' then begin
      crime:=true;
      d(7,'Evil Deed');
      show_usurper_data(picture_death_head,false);
      d(config.textcolor,'You greet the blind man and offer you to guide him');
      d(config.textcolor,'through the dark and dangerous alley. He is just');
      d(config.textcolor,'about to thank you for your help when you cut his');
      d(config.textcolor,'throat from ear to ear...');
      d(config.textcolor,'The poor man gurgles for air but soon dies...You search');
      d(config.textcolor,'his body for '+config.moneytype+'.');
      crlf;
      victim^:='a blind man';
      pause;
     end;
    end;
 end;

 if crime then begin
  dec(player.darknr);

  x:=random(4); {RISK/SANNOLIKHET ATT KA FAST}
  {x:=0; {FUSK!}

  if (x=0) and (player.king=false) then begin
   {** Caught and sentenced to Death or Prison **}

   {update player location/doing}
   onliner.doing:='in Jail';
   add_onliner(OUpdateLocation,Onliner);

   {send it to all nodes}
   online_send_to_all(broadcast_senttoprison,onliner.name,'');

   clearscreen;
   crlf;
   d(15,'Arrested!');

   d(config.textcolor,'Damn! Somebody must have seen something, because');
   d(config.textcolor,'before you get to leave the alley both exits are');
   d(config.textcolor,'blocked and filled with guards!');
   d(config.textcolor,'With a couple of crossbows aimed at you, you realize that');
   d(config.textcolor,'resistance is hopeless. Or is it?');

   crlf;
   menu('(S)urrender');
   menu('(F)ight it out with the guards');
   sd(config.textcolor,':');

   repeat
    ch:=upcase(getchar);
   until ch in ['S','F'];


   if ch='F' then begin
    {fight it out with the guards START}
    reset_monsters;

    global_begged:=false;
    global_nobeg:=true;

    x:=random(5)+2;
    for i:=1 to x do begin
     monster[i]^.name:='City guard';
     monster[i]^.hps:=player.level*10+random(30);
     if monster[i]^.hps<30 then begin
      monster[i]^.hps:=30;
     end
     else if monster[i]^.hps>200 then begin
      monster[i]^.hps:=200;
     end;

     monster[i]^.strength:=25;
     monster[i]^.defence:={15} 0;
     monster[i]^.phrase:='Surrender NOW!';
     monster[i]^.grabweap:=false;
     monster[i]^.grabarm:=false;
     monster[i]^.weapon:='Halberd';
     monster[i]^.armor:='Chainmail';
     monster[i]^.weappow:=15+random(15);
     monster[i]^.armpow:=5+random(player.level);
     monster[i]^.poisoned:=false;
     monster[i]^.disease:=false;
     monster[i]^.punch:=55;
    end;

    for i:=1 to 4 do begin
     pl[i]^.name2:='';
     pl[i]^.hps:=0;
    end;

    Player_vs_Monsters(5,pl[1]^,pl[2]^,pl[3]^,pl[4]^);
    if player.hps<1 then begin

     {player.allowed:=false;}
     Reduce_Player_Resurrections(player,true);

     {news-paper}
     newsy(true,
     'Murderer killed by City Guards!',
     ' '+uplc+player.name2+config.textcol1+' was cut down after a ',
     ' fierce fight with the city police.',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     crlf;
     d(config.textcolor,'You are dead for sure now '+player.name2+'!');
     d(config.textcolor,'This little tour of death was a miserable failure!');
     d(config.textcolor,'May your soul burn in hell...');
     crlf;

     pause;
     normal_exit;
    end;

    {news-paper}
    newsy(true,
    'Lunatic on the loose!',
    ' '+uwhite+commastr(x)+config.textcol1+' of the local miltia were massacred by an',
    ' unknown perpetrator. Investigations are being conducted.',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

    crlf;
    sd(config.textcolor,'Good work ');
    sd(global_plycol,player.name2);
    d(config.textcolor,'!');

    crlf;
    d(config.textcolor,'You leave the scene with blood dripping from your hands.');
    d(config.textcolor,'A beautiful evening for dark deeds.');
    d(config.textcolor,'Giving the families of the butchered guards little thought,');
    d(config.textcolor,'you make your way towards the nearest bar to refresh yourself.');

    crlf;
    pause;

    {fight it out with the guards END}
   end
   else begin
    {surrender to the guards}
    d(config.textcolor,'You put your arms in the air and surrender to the royal guard.');
    d(config.textcolor,'You are taken to the Royal Prison.');

    crlf;
    pause;
    crlf;
    d(config.textcolor,'**The Trial**');
    d(config.textcolor,'The kings will are quite clear on the case of murder.');

    d(config.textcolor,'The sentence can only be EXECUTION!');
    d(config.textcolor,'Your case is a formal matter for the judge...');

    execute:=true;

    if random(3)=0 then begin
     execute:=false;

     {update location}
     player.location:=offloc_prison;
     player.daysinprison:=1; {days to spend in prison}

     {set player hps}
     player.hps:=0;
     {player.allowed:=false;}
     Reduce_Player_Resurrections(player,true);

     crlf;
     d(config.textcolor,'With a good portion of luck you manage to manipulate the jury.');
     d(config.textcolor,'You get a prison sentence instead of the death penalty!');
     crlf;
     pause;

     d(config.textcolor,'You are chained and led off to the Royal Prison.');
     d(config.textcolor,'The crowd outside would like to see you lynched, but');
     d(config.textcolor,'the guards manage to protect you.');
     crlf;
     pause;
     crlf;

     d(config.textcolor,'You are thrown in a damp prison dungeon...');
     d(config.textcolor,'Your only company will be the rats and cockroaches.');
     d(config.textcolor,'Return tomorrow and you might be set free.');
     d(config.textcolor,'(or attempt a daring escape)');
     crlf;

     {news-paper}
     newsy(true,
     uplc+player.name2+config.textcol1+' imprisoned!',
     ' The town has been freed from a cold blooded murderer!',
     ' '+uplc+player.name2+config.textcol1+' was caught after having murdered '+victim^+'!',
     ' '+uplc+player.name2+config.textcol1+' was sentenced to death but got away',
     ' with a prison sentence.',
     '',
     '',
     '',
     '',
     '');

     pause;
     normal_exit;
    end;


    if NOT execute then begin
     {prison sentence START}
     {jakob}
     {prison sentence END}
    end
    else begin  {execute = true, hehe}
     d(config.textcolor,'"Thou '+player.name2+' have been sentenced to death by hanging!"');
     d(config.textcolor,'You lower your head when you receive your sentence...');
     crlf;
     pause;
     clearscreen;
     crlf;
     d(15,'The Gallows');
     d(config.textcolor,'The following day you are brought out to the gallow...');
     d(config.textcolor,'As usual a large crowd has gathered to witness the spectacle!');
     d(config.textcolor,'The executioner take you up to the huge wooden gallow.');
     d(config.textcolor,'The rope is thightened to your neck and you feel that');
     d(config.textcolor,'your dark deeds finally have come to an end...');
     crlf;
     d(config.textcolor,'The executioner reads the official sentence :');
     d(config.textcolor,'"The '+race_display(2,player.race,0)+' '+player.name2+' is hereby to be executed');
     d(config.textcolor,'for the vicious murder of '+victim^+'!"');
     crlf;
     pause;

     a2:='""';
     if confirm('Anything to say to the crowd before you die','y')=true then begin
      d(config.textcolor,'Enter Your Message [1 line]');
      sd(config.textcolor,':');
      a2:=get_string(75);
     end;

     crlf;
     d(config.textcolor,'You wait for the hatch to open under your feets...');
     d(config.textcolor,'Kreeekk! The hatch opens and and a second later your life');
     d(config.textcolor,'is gone...The crowd cheer!');
     crlf;
     pause;

     if a2<>'""' then begin
      hang1^:=' '+uplc+player.name2+'s'+config.textcol1+' last words :';
      hang2^:=a2;
     end
     else begin
      hang1^:='';
      hang2^:='';
     end;

     {update doing}
     onliner.doing:='being executed for murder';
     add_onliner(OUpdateLocation,onliner);

     case random(3) of
      0:begin
         case random(4) of
          0: a2:='But the lowlife was caught and hanged! To the townpeoples amusement!';
          1: a2:='Fortunately the scumbag was caught and executed!';
          2: a2:='Justice got hold of '+sex[player.sex]+' though! And the hanging was a fact!';
          3: a2:=sex2[player.sex]+' was arrested, and short after executed!';
         end;

         s^:='The notorious '+urac+race_display(2,player.race,0)+' '+uplc+player.name2+config.textcol1+' murdered '
             +victim^+'!';

         newsy(true,
         'Ruthless Murderer Hanged!',
         s^,
         a2,
         hang1^,
         hang2^,
         '',
         '',
         '',
         '',
         '');
        end;
      1:begin
         newsy(true,
         uplc+player.name2+config.textcol1+' hanged!',
         ' The town has been freed from a cold blooded murderer!',
         ' '+uplc+player.name2+config.textcol1+' was caught after having murdered '+victim^+'!',
         ' '+uplc+player.name2+config.textcol1+' was sentenced to death and executed.',
         hang1^,
         hang2^,
         '',
         '',
         '',
         '');
        end;
      2:begin
         newsy(true,
         uplc+player.name2+config.textcol1+' Executed!',
         ' The town experienced an execution today!',
         ' '+uplc+player.name2+config.textcol1+' was decapitated for a vicious murder.',
         hang1^,
         hang2^,
         '',
         '',
         '',
         '',
         '');
        end;

     end; {case .end.}

     player.hps:=0;
     {player.allowed:=false;}
     Reduce_Player_Resurrections(player,true);
     normal_exit;
    end;
   end;
  end;

  crlf;
  crlf;
  d(11,'** Successful Murder **');

  {experience}
  x:=(20+random(25))*player.level;

  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');
  player.exp:=player.exp+x;
  x:=random(100)+25;
  x:=x*player.level;

  {darkness}
  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');

  Give_Darkness(player,x);

  {gold}
  x:=random(200)+1000;
  d(config.textcolor,'You find '+uyellow+commastr(x)+config.textcol1+' '+many_money(x)+'!');
  incplayermoney(player,x);

  case random(3) of
   0: s^:=' The Town Council has decided to increase funding of the local police.';
   1: s^:=' The local town-people are upset!';
   2: s^:=' A reward has been set for the clearing of this vicious act!';
  end;

  {news-paper}
  newsy(true,
        'Murder',
        ' '+victim^+' was murdered today!',
        s^,
        '',
        '',
        '',
        '',
        '',
        '',
        '');

  crlf;
  pause;
  crlf;
 end;

 {remove pointer vars}
 for i:=1 to 4 do dispose(pl[i]);
 dispose(victim);
 dispose(hang1);
 dispose(hang2);
 dispose(s);

end; {Murdering *end*}

end. {Unit Murder .end.}
