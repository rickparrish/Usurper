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
Unit Whores; {Usurper - Where the Boys and Men amuse themselves}

Interface

Procedure Whore_House;

Implementation

Uses Init, Cms, Jakob,
     News, Statusc, Mail,
     Various, Various2, Various3,
     Relation, Online;

var refresh : boolean;

Procedure Meny;
begin

 clearscreen;
 crlf;
 d(5,'The Beauty Nest, driven by Clarissa the half-elf');
 d(5,'+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-');
 crlf;
 d(config.textcolor,'As you enter the worndown old whorehouse at the end of the mainstreet,');
 d(config.textcolor,'you notice all kinds of strange creatures running up and down the');
 d(config.textcolor,'stairs. Everyone in company with a female, or two.');
 d(config.textcolor,'You make your way to the selection room where about twenty female');
 d(config.textcolor,'creatures watch you as you enter. They are mostly human and elf girls.');
 crlf;
 d(config.textcolor,'A fat ugly trollwoman suddenly appears, it is Clarissa.');
 d(global_talkcol,' Looking for some pleasure handsome?');
 d(config.textcolor,'(you have '+uyellow+commastr(player.gold)+config.textcol1+' '+many_money(player.gold)+')');
 crlf;
 menu('(I)nspect girls');
 menu('(S)tatus');
 menu('(R)eturn to street');


end;

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'I',
                       'S',
                       '?']);}

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
   sd(config.textcolor,'Beauty Nest ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin

   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,'Beauty Nest (R,I,S,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;
end;

Procedure Whore_House;
var
   cho : char;
   x, yy : longint;
   adios : boolean;
   s : s90;
   my_whore : s70;

begin

 yy:=0;
 cho:='?';
 adios:=false;

 repeat

  if onliner.location<>onloc_whores then begin
   refresh:=true;
   onliner.location:=onloc_whores;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  display_menu(true,true);

  cho:=upcase(getchar);

  case cho of
   '?':begin
       if player.expert=true then display_menu(true,false)
                             else display_menu(false,false);
       end;
   'R':begin
        adios:=true;
        crlf;
        crlf;
       end;
   'S':begin
        status(player);
       end;
   'I':begin
        if player.darknr<1 then begin
         crlf;
         d(config.textcolor,'You are tired and have used up your dark deeds for today.');
         d(config.textcolor,'Return tomorrow for sexual entertainment.');
         crlf;
         pause;
        end
        else begin
         clearscreen;
         d(config.textcolor,'Clarissa introduces you to the whores :');
         crlf;

         sd(5,'1) ');
         sd(10,'Elly the Mutant');
         d(config.textcolor,', a kind of a mix between a troll and swampmonster.');

         sd(5,'2) ');
         sd(10,'Lusha');
         d(config.textcolor,', an old trollwoman. Black as night and utterly disgusting!');

         sd(5,'3) ');
         sd(10,'Irma');
         d(config.textcolor,', a young frightened gnoll girl. Taken slave by Orcs.');

         sd(5,'4) ');
         sd(10,'Elynthia');
         d(config.textcolor,', a middleaged shabby dwarfwoman.');

         sd(5,'5) ');
         sd(10,'Melissa');
         d(config.textcolor,', beautiful elf girl, right from the slavemarket!');

         sd(5,'6) ');
         sd(10,'Sarah');
         d(config.textcolor,', innocent looking 15 year old girl. Human.');

         sd(5,'7) ');
         sd(10,'Sonya');
         d(config.textcolor,', 45 year old elf woman. She is big and beautiful.');

         sd(5,'8) ');
         sd(10,'Arabella');
         d(config.textcolor,', a prime example from what the human race can produce.');

         sd(5,'9) ');
         sd(10,'Loretta');
         d(config.textcolor,', hottest in the house! 24 year old Elf princess.');

         crlf;
         sd(config.textcolor,'Pick a girl or ');

         sd(config.textcolor,'[');
         sd(5,Config.ReturnEnter);
         sd(config.textcolor,'] : ');

         repeat
          cho:=upcase(getchar);
         until cho in [ReturnKey,'1','2','3','4','5','6','7','8','9'];

         yy:=0;
         case cho of
          ReturnKey:begin
                     d(15,'NO THANKS!');
                     crlf;
                    end;
          '1':begin
               my_whore:='Elly';

               clearscreen;
               crlf;
               d(config.textcolor,'The mutant woman takes you upstairs and into a small and dirty room.');
               d(global_plycol,my_whore+config.textcol1+' wants to see '+uyellow+'500'+config.textcol1+' '+many_money(500)
                 +' before you'+' can get what you want.');

               if confirm('Pay '+uplc+my_whore+config.textcol1,'n')=true then begin
                if player.gold<500 then begin
                 crlf;
                 d(config.textcolor,'When she sees that you don not posess this amount, she starts to scream');
                 d(config.textcolor,'for '+uplc+'Clarissa'+config.textcol1+' to throw you out. '+utalkc+'Ha! this dork can''t'
                     +' pay!'+config.textcol1+' she shouts down');
                 d(config.textcolor,'the stairs. You feel like a dork to...');
                 crlf;
                 pause;
                 adios:=true;
                end;
                if player.gold>=500 then begin
                 crlf;
                 d(config.textcolor,'You give the greedy whore the '+config.moneytype+'. '+uplc+my_whore+config.textcol1
                  +' then gives you');
                 d(config.textcolor,'an hour of sexual satisfaction....You feel tired when you');
                 d(config.textcolor,'leave and hope that you don''t will get any disease');
                 d(config.textcolor,'from the whore...you promise yourself to strangle the bitch');
                 d(config.textcolor,'if that should be the case.');
                 crlf;
                 pause;
                 yy:=1;
                 x:=random(5)+25;
                 x:=x*player.level;
                 d(14,'**Whore Visit**');
                 d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                 player.exp:=player.exp+x;

                 x:=random(30)+15;

                 d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');

                 Give_Darkness(player,x);

                 dec(player.darknr);

                 decplayermoney(player,500);

                 crlf;
                 pause;
                 adios:=true;
                end;
               end
               else begin
                crlf;
                d(global_talkcol,'Well, have it your way dork!'+config.textcol1);
               end;
              end;
          '2':begin
                my_whore:='Lusha';

                clearscreen;
                d(global_plycol,my_whore+config.textcol1+' takes your hand and lead you upstairs into a room.');
                d(config.textcolor,'She demands to see the '+uyellow+'2000'+config.textcol1+' '+many_money(2000)+' first!');
                if confirm('Pay '+uplc+my_whore+config.textcol1,'n')=true then begin
                 if player.gold<2000 then begin
                  crlf;
                  d(config.textcolor,utalkc+'You little rascal!'+uplc+' '+my_whore+config.textcol1+' screams. A couple of '
                    +'trolls');
                  d(config.textcolor,'arrive and throw you out in the muddy street. '+utalkc+'Come back when'+config.textcol1);
                  d(global_talkcol,'you can pay!'+uplc+' Clarissa'+config.textcol1+' shouts before she close the door.');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=2000 then begin
                  crlf;
                  d(config.textcolor,'You give her the '+config.moneytype+'. Then she undress you and');
                  d(config.textcolor,'give you a couple of hours filled with troll-sex.');
                  d(config.textcolor,'You leave with a smile on your face. That was good!');
                  d(config.textcolor,'You just hope that '+uplc+my_whore+config.textcol1+' is still free from diseases...');
                  crlf;
                  pause;
                  yy:=2;

                  x:=random(10)+50;
                  x:=x*player.level;
                  d(14,'**Whore Visit**');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');
                  player.exp:=player.exp+x;
                  x:=random(30)+25;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');

                  Give_Darkness(player,x);
                  dec(player.darknr);

                  decplayermoney(player,2000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Alright with me, honey!'+config.textcol1);
                end;
               end;
           '3':begin
                my_whore:='Irma';

                clearscreen;
                crlf;
                d(config.textcolor,'The gnoll girl lead you up to the rooms on the second floor.');
                d(global_talkcol,'Do you have '+uyellow+'5,000'+utalkc+' in '+config.moneytype+'?'+uplc+' '+my_whore
                  +config.textcol1+' asks.');
                if confirm('Pay the Gnoll-girl','n')=true then begin
                 if player.gold<5000 then begin
                  crlf;
                  d(global_talkcol,'But '+uplc+player.name2+utalkc+'! You have not enough '+config.moneytype
                    +' to enjoy my body'+config.textcol1);
                  d(global_plycol,my_whore+config.textcol1+' says. '+utalkc+'Get out from here and don''t take up my'
                    +config.textcol1);
                  d(global_talkcol,'valuable time, you pathetic '+race_display(2,player.race,0)+'!'+config.textcol1);
                  d(config.textcolor,'She slams the door in your face, and you stand there like a sheep...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=5000 then begin
                  crlf;
                  d(config.textcolor,'With a deep sigh you give her the '+config.moneytype+'. '+utalkc+
                    'You are robbing me blind'+config.textcol1);
                  d(config.textcolor,'you cry...But you soon feel better when '+uplc+my_whore+config.textcol1+' gives you');
                  d(config.textcolor,'a lesson in fearless Gnoll-sex. Afterwards you don''t regret');
                  d(config.textcolor,'paying a lesser fortune for this exciting adventure, and you promise');
                  d(config.textcolor,'yourself to return to '+uplc+my_whore+config.textcol1+'...');
                  crlf;
                  pause;
                  yy:=3;

                  x:=random(25)+100;
                  x:=x*player.level;

                  d(14,'**Whore Visit**');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  inc(player.exp,x);

                  x:=random(60)+50;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');

                  Give_Darkness(player,x);
                  dec(player.darknr);

                  decplayermoney(player,5000);
                  crlf;

                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Fine, maybe later...');
                end;
               end;
           '4':begin
                my_whore:='Elynthia';
                clearscreen;
                crlf;
                d(global_plycol,my_whore+config.textcol1+' gives you a tired smile and then guides you to her room.');
                d(global_talkcol,'Alright Jimbo, show me '+uyellow+'10,000'+utalkc+' in pure '+config.moneytype+'!'
                  +config.textcol1+' the dwarf-slut demands.');

                if confirm('Pay '+uplc+my_whore+uyellow+' 10,000'+config.textcol1,'n')=true then begin
                 if player.gold<10000 then begin
                  crlf;
                  d(global_talkcol,'Hey you damn Clown! You don''t have the '+config.moneytype+' to get my pleasure!'
                     +config.textcol1);
                  d(config.textcolor,'You stand there looking like a fool. '+utalkc+'So so, get out here and make');
                  d(global_talkcol,'some '+config.moneytype+' and then come back! Mama '+uplc+my_whore+config.textcol1
                    +' will take care of you then!'+config.textcol1);
                  d(config.textcolor,'You conclude that you are a poor '+race_display(2,player.race,0)+' without '
                    +config.moneytype+'...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=10000 then begin
                  crlf;
                  d(config.textcolor,'With a deep sigh you give her the '+config.moneytype+'. '+utalkc
                    +'You are robbing me blind!'+config.textcol1);
                  d(config.textcolor,'you cry...But you soon feel better when '+uplc+my_whore+config.textcol1+' gives you');
                  d(config.textcolor,'a lesson in fearless Gnoll-sex. Afterwards you don''t regret');
                  d(config.textcolor,'paying a lesser fortune for this exciting adventure, and you promise');
                  d(config.textcolor,'yourself to return to '+uplc+my_whore+config.textcol1+'...');
                  crlf;
                  pause;
                  yy:=4;
                  x:=random(50)+100;
                  x:=x*player.level;
                  crlf;

                  d(14,'**Whore Visit**');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  inc(player.exp,x);

                  x:=random(90)+50;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');
                  Give_Darkness(player,x);

                  dec(player.darknr,1);
                  decplayermoney(player,10000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'It''s ok honey!');
                end;
               end;
           '5':begin
                my_whore:='Melissa';
                clearscreen;
                crlf;
                d(config.textcolor,'Your knees start to shake when you see '+uplc+my_whore+config.textcol1+' approaching.');
                d(config.textcolor,'Gee, this lady don''t belong here! You think for');
                d(config.textcolor,'yourself. '+utalkc+'My services cost '+uyellow+'20,000 '+config.textcol1
                  +many_money(20000)+uplc+' '+my_whore+config.textcol1+' says.');
                if confirm('Pay '+uplc+my_whore+config.textcol1,'n')=true then begin
                 if player.gold<20000 then begin
                  crlf;
                  d(global_talkcol,'It seems like you don''t have the '+config.moneytype+'!'+uplc+' '+my_whore
                    +config.textcol1+' whispers.');
                  d(global_talkcol,'Maybe later my brave warrior... '+config.textcol1+'You just stand there for along '
                    +'time longing');
                  d(config.textcolor,'for the elf-girl. You could pay just too looking at her! Those elves sure');
                  d(config.textcolor,'are filled with hot magic, you conclude before you leave...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=20000 then begin
                  crlf;
                  d(config.textcolor,'You gladly give the beautiful woman the '+config.moneytype+'. '+uplc
                    +my_whore+config.textcol1+' put them');
                  d(config.textcolor,'under the bed and then puts out the light. '+uplc+'I hope you will approve');
                  d(config.textcolor,'of my ways'+config.textcol1+' she says in a sad voice. A couple of hours later you');
                  d(config.textcolor,'feel totally refreshed. It must be that elf-magic...');
                  d(global_plycol,my_whore+config.textcol1+' gives you a glance before you leave...');
                  crlf;
                  pause;
                  yy:=5;
                  x:=random(75)+100;
                  x:=x*player.level;

                  d(14,'**Whore Visit**');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  player.exp:=player.exp+x;
                  x:=random(50)+150;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');

                  Give_Darkness(player,x);
                  dec(player.darknr,1);

                  decplayermoney(player,20000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Pig!');
                end;
               end;
           '6':begin
                my_whore:='Sarah';
                clearscreen;
                crlf;
                d(global_plycol,my_whore+config.textcol1+' examines you and seems to be quite pleased with what she sees.');
                d(global_talkcol,'Come with me and we have some fun stranger!'+config.textcol1+' Yeah, you bet we gonna');
                d(config.textcolor,'have fun, you think for yourself. '+uyellow+'30,000'+utalkc+' in '+many_money(30000)
                  +' first!'+uplc+' '+my_whore+config.textcol1+' reminds you.');

                if confirm('Pay the Whore','n')=true then begin
                 if player.gold<30000 then begin
                  crlf;
                  d(global_plycol,'Hey Baby! Come back when you got the '+config.moneytype+'!'+config.textcol1);
                  d(config.textcolor,'You feel like a fool...Why the hell did I came here for');
                  d(config.textcolor,'without cash, you think for yourself. You promise yourself');
                  d(config.textcolor,'to return later with wealth and glory...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=30000 then begin
                  crlf;
                  d(config.textcolor,'You hand '+uplc+my_whore+config.textcol1+' the '+config.moneytype
                   +' which she carefully hides in her');
                  d(config.textcolor,'clothes. '+utalkc+'Come over here sailor!'+config.textcol1+' she then says in a caring'
                    +' voice.');
                  d(config.textcolor,'You approach the bed and she starts to undress you...');
                  d(config.textcolor,'You awake early in the morning and try to recollect your evening');
                  d(config.textcolor,'with '+uplc+my_whore+config.textcol1+', but it''s all like a dream filled with '
                    +'pleasure...');
                  crlf;
                  pause;

                  yy:=6;
                  x:=random(100)+100;
                  x:=x*player.level;
                  crlf;
                  d(14,'**Whore Visit**');
                  d(14,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  inc(player.exp,x);

                  x:=random(100)+100;

                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');

                  Give_Darkness(player,x);
                  dec(player.darknr,1);
                  decplayermoney(player,30000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Have it your way...');
                end;
               end;
           '7':begin
                my_whore:='Sony';
                clearscreen;
                crlf;
                d(config.textcolor,'This must be the first whore you''ve seen that smokes a pipe!');
                d(config.textcolor,'Hell, you thought that elves didn''t smoke...but this proves to be somehting special!');

                d(global_talkcol,'Ok kid, wanna have some fun with mother '+uplc+my_whore+utalkc+'? show me '+uyellow
                  +'40,000'+utalkc+' '+many_money(40000)+'!'+config.textcol1);

                if confirm('Pay','n')=true then begin
                 if player.gold<40000 then begin
                  crlf;
                  d(global_talkcol,'Sorry kid, no pesetas no pleasure!'+uplc+' '+my_whore+config.textcol1
                   +' declares in a tired voice.');
                  d(config.textcolor,'Well, to pay '+uyellow+'40,000'+config.textcol1+' '+many_money(40000)
                    +' for an old smoking elf, that sounds crazy!');
                  d(config.textcolor,'What does she except to get for that kind of appearance you wonder as you walk down the'
                    +' stairs.');
                  d(config.textcolor,'Bye bye '+uplc+my_whore+config.textcol1+'!...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=40000 then begin
                  crlf;
                  d(global_plycol,my_whore+config.textcol1+' grabs the '+config.moneytype+' before you can say '+utalkc
                    +'Prosit'+config.textcol1+'!');
                  d(global_talkcol,'Let mother show you how to do...'+config.textcol1+' she then says in a commanding');
                  d(config.textcolor,'voice. You let your wild lusts burst in the night...');
                  d(config.textcolor,'In the morning you wake up with a big smile on your face.');
                  d(global_talkcol,'Come back when you can kid '+uplc+my_whore+config.textcol1+' whispers before you go.');
                  crlf;
                  pause;
                  yy:=7;
                  x:=random(150)+110;
                  x:=x*player.level;

                  d(14,'**Whore Visit**');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  inc(player.exp,x);

                  x:=random(200)+100;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');
                  Give_Darkness(player,x);
                  dec(player.darknr,1);
                  decplayermoney(player,40000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Come back when you have changed your mind!');
                end;
               end;
           '8':begin
                my_whore:='Arabella';
                clearscreen;
                crlf;
                d(config.textcolor,'The madonna-like '+uplc+my_whore+config.textcol1+' lead you up the stairway.');
                d(config.textcolor,'Could it be the stairway to heaven?, you wonder...She is like an angel!');
                crlf;
                d(global_talkcol,'Dear Sire, will you please show me your capital first'+config.textcol1);
                if confirm('Pay '+uplc+my_whore+uyellow+' 70,000'+config.textcol1,'n')=true then begin
                 if player.gold<70000 then begin
                  crlf;
                  d(global_talkcol,'I am sorry my dear young man. But you seem to have a cash problem?'+uplc+' '+my_whore
                    +config.textcol1+' says with a smile.');
                  d(config.textcolor,'You promise to be back with more '+config.moneytype+' and then leave...');
                  d(config.textcolor,'Bye bye '+uplc+my_whore+config.textcol1+'!...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=70000 then begin
                  crlf;
                  d(global_plycol,my_whore+config.textcol1+' grabs the '+config.moneytype+' before you get the chance to'
                  +' anything.');
                  d(global_talkcol,'Let mother show you how to go about'+config.textcol1+' she then says in a commanding');
                  d(config.textcolor,'voice. You let your wild lusts burst in the night...');
                  d(config.textcolor,'In the morning you wake up with a big smile on your face.');
                  d(global_talkcol,'Come back when you can kid'+uplc+' '+my_whore+config.textcol1+' whispers before you go.');
                  crlf;
                  pause;
                  yy:=8;
                  x:=random(250)+200;
                  x:=x*player.level;
                  crlf;

                  d(14,'**Whore Visit**');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  inc(player.exp,x);
                  x:=random(300)+100;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');
                  Give_Darkness(player,x);
                  dec(player.darknr,1);
                  decplayermoney(player,70000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Come back to me soon!');
                end;
               end;
           '9':begin
                my_whore:='Loretta';
                clearscreen;
                crlf;
                d(global_plycol,my_whore+', '+config.textcol1+'"the best for the best" you think for yourself.');
                d(config.textcolor,'The queen of queens in the Beauty Nest. Not too many men have');
                d(config.textcolor,'ever tasted her pale human skin between their lips...');
                if confirm('Pay '+uplc+my_whore+uyellow+' 100,000'+config.textcol1,'n')=true then begin
                 if player.gold<100000 then begin
                  crlf;
                  d(global_talkcol,'No '+config.moneytype+', no '+my_whore+'!'+uplc+' Clarissa'+config.textcol1+' says!');
                  d(config.textcolor,'You sigh, and leave with your head deep between your shoulders.');
                  d(config.textcolor,'Bye sweet jewel...');
                  crlf;
                  pause;
                  adios:=true;
                 end;
                 if player.gold>=100000 then begin
                  crlf;
                  d(global_talkcol,'So, a '+race_display(2,player.race,0)+' has come to visit me'+uplc+' '+my_whore
                    +config.textcol1+' says in a');
                  d(config.textcolor,'dreaming voice. '+utalkc+'I will give you a night to remember! '+config.textcol1
                    +'she then says with');
                  d(config.textcolor,'a strange look in her eyes. Gee, she must be on drugs, you think for');
                  d(config.textcolor,'yourself. Drugs or not, '+uplc+my_whore+config.textcol1+' gives you a new perspective of'
                    +' what pleasure two');
                  d(config.textcolor,'individuals can give each other...well at least what one part can give the');
                  d(config.textcolor,'other...');
                  crlf;
                  pause;
                  yy:=9;
                  x:=random(300)+150;
                  x:=x*player.level;

                  d(14,'***Whore Visit***');
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

                  inc(player.exp,x);
                  x:=random(150)+500;
                  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' darkness points!');
                  Give_Darkness(player,x);
                  dec(player.darknr,1);
                  decplayermoney(player,100000);
                  crlf;
                  pause;
                  adios:=true;
                 end;
                end
                else begin
                 d(global_talkcol,'Bye!');
                end;
               end;
          end;
        end;
       end;
  end;

 until adios=true;

 if yy>0 then begin

  {inform spouse if married}
  s:=is_player_married(player.name2,player.id);
  if s<>'' then begin

   {lets load the relation to see if spouse is human, otherwise no need
    to post mail - jakob is lazy hasn't implemented that yet}

   {mail spouse}
   post(MailSend,
   s,
   'H',
   false,
   mailrequest_nothing,
   '',
   ulred+'HOW COULD HE?'+config.textcol1,
   mkstring(13,underscore),
   uplc+player.name2+config.textcol1+' has been '+ulred+'unfaithful'+config.textcol1+' to you!',
   uplc+player.name2+config.textcol1+' enjoyed himself at the '+ucyan+'Whore-House'+config.textcol1+'!',
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


  {write about visit in the news}
  if random(3)=0 then begin
   clearscreen;
   crlf;
   d(config.textcolor,'Just as you leave the Beauty-Nest you start to feel pain in your');
   d(config.textcolor,'genitals! By Gandalfs beard! The bleeding whores are infected!');
   d(config.textcolor,'You intend to rush back and slain the whole lot of them, but');
   d(config.textcolor,'then you suddenly feel sharp and burning heat in your abdomen.');
   crlf;
   d(config.textcolor,'You rush to the Dormitory and call for some healers...');
   d(config.textcolor,'You start to get dizzy from the decoctations of orbs that the');
   d(config.textcolor,'monks give you. The last thing you notice is the rowdy group');
   d(config.textcolor,'of adventurers who stand around your bed, all with smiles on');
   d(config.textcolor,'on their faces... '+utalkc+'Haha! '+uplc+player.name2+utalkc+' won''t walk for a');
   d(global_talkcol,'couple of days...hehe! If ya like women ya gotta take the');
   d(global_talkcol,'consequences...!');
   crlf;

   {news-paper}
   newsy(true,
   'Lover Boy!',
   ' '+uplc+player.name2+config.textcol1+' got laid at the Beauty-Nest, unfortunately the',
   ' whore had a sexual disease! '+ulred+player.name2+config.textcol1+' got hospitalized!',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   post(MailSend,
        player.name2,
        player.ai,
        false,
        mailrequest_nothing,
        '',
        'In Bed with a Disease',
        mkstring(21,underscore),
        'You got a sexual disease at the Beauty-Nest.',
        '(you got what was coming to you! Don''t play with fire!)',
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

   {player.allowed:=false;}
   Reduce_Player_Resurrections(player,true);

   player.hps:=0;
   pause;
   crlf;
   show_usurper_data(picture_death_head,false);
   d(config.textcolor,'Darkness....');
   crlf;
   pause;
   normal_exit;
  end
  else begin

   s:='';
   case random(5) of
    0: s:=uplc+player.name2+config.textcol1+' had a night filled with pleasures.';
    1: s:=uplc+player.name2+config.textcol1+' practiced safe sex.';
    2: s:=uplc+player.name2+config.textcol1+' proved to be a real tiger in bed!';
    3: s:=uplc+player.name2+config.textcol1+' treated '+uplc+my_whore+config.textcol1+' bad.';
    4: s:=uplc+player.name2+config.textcol1+' is a real stud!';
   end;

   {news-paper}
   newsy(true,
   'Lover Boy',
   ' '+uplc+player.name2+config.textcol1+' spent the night with '+uplc+my_whore+config.textcol1+', the whore.',
   ' '+s,
   '',
   '',
   '',
   '',
   '',
   '',
   '');
  end;
 end;

end; {Whore_House *end*}

end. {Unit Whores .end.}
