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



Unit GigoloC; {Usurper - Women enjoy men..}

Interface

Procedure Gigolos;

Implementation

Uses Init, Cms, Jakob,
     Statusc, Mail, News,
     Various, Various2, Various3,
     Online;

var refresh : boolean;

Procedure Meny;
begin

 clearscreen;
 crlf;
 d(5,'Hall of Dreams, supervised by Brimer the gnome');
 d(5,'-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*');
 crlf;
 d(config.textcolor,'You enter the lobby of this big and fashionable building.');
 d(config.textcolor,'The furnishing is expensive and gives you the feeling of');
 d(config.textcolor,'a luxury hotel. Subdued music adds to the pleasant');
 d(config.textcolor,'atmosphere and puts you in a relaxed mood.');
 crlf;
 d(config.textcolor,'You are approched by a slim man dressed in black.');
 d(global_talkcol,'Hello, my name is Giovanni. What can I do for you madam?');
 d(config.textcolor,'(you have '+uyellow+commastr(player.gold)+config.textcol1+' '+many_money(player.gold)+')');
 crlf;
 menu('(I)nspect boys');
 menu('(S)tatus');
 menu('(R)eturn to street');

end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;
   crlf;
   sd(config.textcolor,'Gigolos ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin
   if player.ear=1 then begin
    who_is_here;
   end;
   crlf;
   sd(config.textcolor,'Gigolos (R,I,S,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure Gigolos;
var
    cho : char;
    yy, z, x : longint;
    s : string[90];

begin
 z:=0;
 yy:=0;

 repeat

  if onliner.location<>onloc_gigolos then begin
   refresh:=true;
   onliner.location:=onloc_gigolos;
   onliner.doing:=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  display_menu(true,true);

  repeat
   cho:=upcase(getchar);
  until cho in ['R','I','S','?'];

  z:=0;
  case cho of
   '?':begin
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'R':begin
        crlf;
        exit;
       end;
   'S':begin
        status(player);
       end;
   'I':begin
        if player.darknr<1 then begin
         d(config.textcolor,'You are tired and have used up your deeds for today.');
         d(config.textcolor,'Return tomorrow for sexual entertainment.');
         crlf;
         pause;
        end
        else begin
         clearscreen;
         crlf;
         d(config.textcolor,'Giovanni introduces you to the gigolos :');
         crlf;

         sd(5,'1) ');
         sd(10,'Signori');
         d(config.textcolor,', a slender page-like boy with effeminate manners.');

         sd(5,'2) ');
         sd(10,'Tod');
         d(config.textcolor,', blond viking-type stud from the icy Northerns.');

         sd(5,'3) ');
         sd(10,'Mbuto');
         d(config.textcolor,', a dark and muscular slave in his early forties.');

         sd(5,'4) ');
         sd(10,'Merson');
         d(config.textcolor,', a thirtyfour year old gladiator from Scotia.');

         sd(5,'5) ');
         sd(10,'Brian De Roy');
         d(config.textcolor,', poor prince with divine looks. True heartbreaker.');

         sd(5,'6) ');
         sd(10,'Rasputin');
         d(config.textcolor,', skinny but attractive mage. Wears his tophat in bed!');

         sd(5,'7) ');
         sd(10,'Manhio');
         d(config.textcolor,', a tall and eflorescent elf-aristocratic seducer.');

         sd(5,'8) ');
         sd(10,'Jake');
         d(config.textcolor,', a sturdy ranger in his mid twenties. Adored by the local youth.');

         sd(5,'9) ');
         sd(10,'Banco');
         d(config.textcolor,', Lord of Jah. Prime game for every woman at her true senses.');

         crlf;
         sd(config.textcolor,'Pick a Gigolo or ');
         menu2('(A)bort :');

         repeat
          cho:=upcase(getchar);
         until (cho='A') or (cho='1') or (cho='2') or (cho='3') or
               (cho='4') or (cho='5') or (cho='6') or (cho='7') or
               (cho='8') or (cho='9');

         yy:=0;
         case cho of
          'A':begin
               crlf;
              end;
          '1':begin
               clearscreen;
               crlf;
               d(config.textcolor,'Signori leads you up to a little shabby room.');
               d(config.textcolor,'"Show me your 500 in '+config.moneytype+' first", Signori says.');

               if confirm('Pay Signori','n')=true then begin
                if player.gold<500 then begin
                 crlf;
                 sd(global_talkcol,'Then get out of here!');
                 d(config.textcolor,', the little jerk screams at you.');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=500 then begin
                 crlf;
                 d(config.textcolor,'You give dollface his money. Signori then gives you a');
                 d(config.textcolor,'tender lesson in the advanced arts of palace love...');
                 d(config.textcolor,'Approximately two hours later, the boy has managed to put');
                 d(config.textcolor,'you in a state of total exhaustion. You leave the room');
                 d(config.textcolor,'with a smile...This could be worth another visit.');
                 crlf;
                 pause;
                 yy:=1;
                 x:=random(5)+25;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(30)+15;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,500);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                crlf;
                d(config.textcolor,'"Have it your way lady!"');
                crlf;
               end;
              end;
          '2':begin
               clearscreen;
               d(config.textcolor,'You follow Tod to his private chamber.');
               d(config.textcolor,'The major part of the room is occupied by');
               d(config.textcolor,'an enormous bed. Laying on the bed is a huge');
               d(config.textcolor,'beer-skin, looking rather worn-out.');
               d(config.textcolor,'Tod demands to see '+uyellow+'2000 '+config.textcol1+many_money(2000)+' first!');
               crlf;

               if confirm('Pay Tod','n')=true then begin
                if player.gold<2000 then begin
                 crlf;
                 d(config.textcolor,'"Why did you bother then?", Tod looks at you with anger.');
                 d(config.textcolor,'You leave as quickly as you can...');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=2000 then begin
                 crlf;
                 d(config.textcolor,'You give Tod the '+config.moneytype+'. He starts to undress you');
                 d(config.textcolor,'in quite a violent manner. You might have understood that');
                 d(config.textcolor,'this guy is not the tender type. But after your little session,');
                 d(config.textcolor,'you have altered your opinon about this stud. He played along');
                 d(config.textcolor,'just as you wanted him to.');
                 crlf;
                 pause;
                 yy:=2;
                 x:=random(10)+50;
                 x:=x*player.level;

                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(30)+25;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,2000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                d(config.textcolor,'"Its alright with me, ma'+chr(39)+'m"');
               end;
              end;
          '3':begin
               clearscreen;
               d(config.textcolor,'You follow Mbuto downstairs into a dusty cell.');
               d(config.textcolor,'"Do you have '+uyellow+'5,000'+config.textcol1+' in '+config.moneytype+'?" Mbuto mutters.');

               if confirm('Pay','n')=true then begin
                if player.gold<5000 then begin
                 crlf;
                 d(config.textcolor,'"But lady! You have not enough '+config.moneytype+' to enjoy my services"');
                 d(config.textcolor,'mbuto declares. Come back when you have suffient funds"');
                 d(config.textcolor,'Mbuto snores at you and disappears upstairs.');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=5000 then begin
                 crlf;
                 d(config.textcolor,'You give Mbuto the '+config.moneytype+'. He locks the door with a big key.');
                 d(config.textcolor,'The only sources of light in this room are two tall candles.');
                 d(config.textcolor,'Suddenly the tall man blows out the candles and it'+chr(39)+'s pitch dark!');
                 d(config.textcolor,'For a brief moment you regret ever have come down here, but');
                 d(config.textcolor,'Mbutos presence is soon to overwhelming...');
                 crlf;
                 pause;
                 yy:=3;
                 x:=random(25)+100;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(60)+50;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,5000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                d(config.textcolor,'"Fine, maybe later..."');
                crlf;
               end;
              end;
          '4':begin
               clearscreen;
               crlf;
               d(config.textcolor,'You follow Merson up to his quarters.');
               d(config.textcolor,'"My services costs 10,000"  Merson says.');

               if confirm('Pay Merson 10,000','n')=true then begin
                if player.gold<10000 then begin
                 crlf;
                 d(config.textcolor,'"Hey! Se you later then!", Merson says.');
                 d(config.textcolor,'You stand there looking like a fool...');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=10000 then begin
                 crlf;
                 d(config.textcolor,'You give the gladiator the '+config.moneytype+'...');
                 d(config.textcolor,'Merson then asks what type of sex you prefer;');
                 d(config.textcolor,'Since you have read the standard work on this');
                 d(config.textcolor,'subject, Troy Giddos "On Transracial Sexual Intercourse",');
                 d(config.textcolor,'you pick your favourite...');
                 crlf;
                 d(config.textcolor,'After the session you conclude that this was');
                 d(config.textcolor,'an experience well worth its '+config.moneytype+'!');
                 crlf;
                 pause;
                 yy:=4;
                 x:=random(50)+100;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(90)+50;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,10000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                d(config.textcolor,'"It'+chr(39)+'s ok honey!"');
               end;
              end;
          '5':begin
               clearscreen;
               crlf;
               d(config.textcolor,'Brian approaches you with an arrogant look on his face.');
               d(config.textcolor,'"'+uyellow+'20,000 '+config.textcol1+many_money(20000)+' please", Brian says.');

               if confirm('Pay him','n')=true then begin
                if player.gold<20000 then begin
                 crlf;
                 d(config.textcolor,'"It seems like you don''t have the '+config.moneytype+'!" Brian whispers.');
                 d(config.textcolor,'"Maybe later brave lady..." You just stand there for along time longing');
                 d(config.textcolor,'for this man. You could pay just too look at him!');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=20000 then begin
                 crlf;
                 d(config.textcolor,'You gladly give the handsome prince the '+config.moneytype+'. Brian puts them');
                 d(config.textcolor,'in his purse. "This will be one of your outmost experiences" he, ');
                 d(config.textcolor,'says.');
                 crlf;
                 d(config.textcolor,'A couple of hours later you feel totally exhausted. It sure was');
                 d(config.textcolor,'one divine experience...');
                 crlf;
                 pause;
                 yy:=5;
                 x:=random(75)+100;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(50)+150;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,20000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                d(config.textcolor,'"Ohhhhh..."');
               end;
              end;
          '6':begin
               clearscreen;
               crlf;
               d(config.textcolor,'Rasputin examines you and seems to be quite pleased with what he sees.');
               d(config.textcolor,'"Come with me and have some fun beauty!", he says.');
               d(config.textcolor,'"'+uyellow+'30,000'+config.textcol1+' in '+config.moneytype
                 +' first!" Rasputin reminds you.');

               if confirm('Pay Rasputin','n')=true then begin
                if player.gold<30000 then begin
                 crlf;
                 d(config.textcolor,'"Hey Baby! Come back when you got the cash!"');
                 d(config.textcolor,'You feel like a fool...Why the hell did i came here for');
                 d(config.textcolor,', you think for yourself. You promise yourself');
                 d(config.textcolor,'to return better prepared next time...');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=30000 then begin
                 crlf;
                 d(config.textcolor,'You hand Rasputin the '+config.moneytype+' which he carefully hides in his');
                 d(config.textcolor,'clothes. "Come over here!" he then says in a caring voice.');
                 d(config.textcolor,'You approach the bed and the skinny man starts to undress you...');
                 crlf;
                 d(config.textcolor,'You awake early in the morning and try to recollect your evening');
                 d(config.textcolor,'with Rasputin, but it'+chr(39)+'s all like a dream filled with pleasure...');
                 crlf;
                 pause;
                 yy:=6;
                 x:=random(100)+100;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(100)+100;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,30000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                crlf;
                d(config.textcolor,'"Have it your way baby..."');
               end;
              end;
          '7':begin
               clearscreen;
               crlf;
               d(config.textcolor,'"Wanna have some fun with old Manhio? let me see '+uyellow+'40,000 '+config.textcol1
                 +many_money(40000)+'!"');

               if confirm('Pay the elf','n')=true then begin
                if player.gold<40000 then begin
                 crlf;
                 d(config.textcolor,'"I am so sorry miss, please come back later!", Manhio declares in a tired voice');
                 d(config.textcolor,'Bye bye Manhio!...');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=40000 then begin
                 crlf;
                 d(config.textcolor,'Manhio quickly grabs the '+config.moneytype+' before your eyes.');
                 d(config.textcolor,'He then offers you a strange-looking drink. According');
                 d(config.textcolor,'to Manhio, this will increase your performance');
                 d(config.textcolor,'and actually boost your sexual instincts to animal level');
                 crlf;
                 d(config.textcolor,'Two hours later you conclude that this was actually true.');
                 crlf;
                 pause;
                 yy:=7;
                 x:=random(150)+110;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(200)+100;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,40000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                crlf;
                d(config.textcolor,'"Come back when you have changed your mind."');
               end;
              end;
          '8':begin
               clearscreen;
               crlf;
               d(config.textcolor,'Jake leads you up the stairway...');
               d(config.textcolor,'"Miss, would you please show me your capital first"');

               if confirm('Pay Jake 70,000','n')=true then begin
                if player.gold<70000 then begin
                 crlf;
                 d(config.textcolor,'"I am sorry Miss. Later perhaps?", Jake says in a soft voice.');
                 d(config.textcolor,'You promise him to be back with more '+config.moneytype+' and then leave.');
                 d(config.textcolor,'Bye bye Jake!...');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=70000 then begin
                 crlf;
                 d(config.textcolor,'Jake close the door behind you.');
                 d(config.textcolor,'"Let me provide you with pleasure", he says in a commanding');
                 d(config.textcolor,'voice. You then experience some things that you not could');
                 d(config.textcolor,'have imagined in your wildest fantasies...');
                 delay2(800);
                 crlf;
                 d(config.textcolor,'You wake up early in the morning, Jake is gone.');
                 crlf;
                 pause;
                 yy:=8;
                 x:=random(250)+200;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'**Gigolo Visit**');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(300)+100;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,70000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                d(config.textcolor,'"Come back soon!"');
               end;
              end;
          '9':begin
               clearscreen;
               crlf;
               d(config.textcolor,'"Banco, the best for the best" you think for yourself...');
               d(config.textcolor,'The King of Kings in this place. Not too many women');
               d(config.textcolor,'have ever experienced a night with him...');

               if confirm('Pay Banco 100,000','n')=true then begin
                if player.gold<100000 then begin
                 crlf;
                 d(config.textcolor,'"No '+config.moneytype+', no Banco!", Banco says!');
                 d(config.textcolor,'You sigh and leave with your head deep between your shoulders.');
                 d(config.textcolor,'Bye...');
                 crlf;
                 pause;
                 z:=99;
                end;
                if player.gold>=100000 then begin
                 crlf;
                 d(config.textcolor,'"So a '+race_display(2,player.race,0)+' has come to visit me" Banco says in a');
                 d(config.textcolor,'dreaming voice. "I will give you a night to remember he then says with');
                 d(config.textcolor,'a strange look in his eyes.');
                 d(config.textcolor,'Banco gives you a new perspective of what pleasure two');
                 d(config.textcolor,'individuals can give each other...well at least what one part can');
                 d(config.textcolor,'give the other...');
                 crlf;
                 pause;
                 yy:=9;
                 x:=random(300)+150;
                 x:=x*player.level;
                 crlf;
                 d(config.textcolor,'***Gigolo Visit***');
                 d(config.textcolor,'You receive '+commastr(x)+' experience points!');
                 player.exp:=player.exp+x;
                 x:=random(150)+500;
                 d(config.textcolor,'You receive '+commastr(x)+' darkness points!');
                 player.dark:=player.dark+x;
                 player.darknr:=player.darknr-1;
                 decplayermoney(player,100000);
                 crlf;
                 pause;
                 z:=99;
                end;
               end
               else begin
                d(config.textcolor,'"Bye..."');
               end;
              end;
         end;
        end;
       end;
  end;

 until z=99;

 cho:=' ';
 if yy>0 then begin
  {skriv om detta bes”k i nyheterna}

  if random(3)=0 then begin
   clearscreen;
   crlf;
   d(config.textcolor,'You have been infected by a deadly virus!');
   d(config.textcolor,'Prepare to face the consequences....DEATH!"');
   crlf;

   {news-paper}
   newsy(true,
   'In Bed with '+uplc+player.name2+config.textcol1+'!',
   ' '+uplc+player.name2+config.textcol1+' was contaminated by a Gigolo!',
   ' '+uplc+player.name2+config.textcol1+' died...',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {mail player}
   post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   'Disease',
   umailheadc+mkstring(7,underscore)+config.textcol1,
   'You got a sexual disease at the Gigolo Hotel.',
   '(be better prepared next time!)',
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
   d(config.textcolor,'Darkness....');
   crlf;
   pause;
   halt;
  end
  else begin
   {news-paper}
   newsy(true,
   'Prime Queen!',
   ' '+uplc+player.name2+config.textcol1+' spent the night with a gigolo.',
   ' (and some good '+config.moneytype+' to!)',
   '',
   '',
   '',
   '',
   '',
   '',
   '');
  end;
  cho:='?';
 end;

end; {Gigolos *end*}

end. {Unit GigoloC .end.}
