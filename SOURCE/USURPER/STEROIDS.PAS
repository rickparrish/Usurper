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


Unit Steroids; {Usurper - Steroids}

Interface

Procedure Steroid_Store;

Implementation

Uses Init, Cms, Jakob,
     Various, Various3, Statusc,
     News, Online, File_IO;

var refresh : boolean;
    owner : s40;

Procedure Meny;
var s : s90;
begin

 s:='Lizards Training Center, run by '+owner;

 crlf;
 d(5,'Lizards Training Center, run by '+uplc+owner+umag+')');
 d(5,mkstring(length(s),underscore));
 crlf;
 d(config.textcolor,'Lizards is not exactly known for its friendly atmosphere.');
 d(config.textcolor,'However, you can get what you want without any questions being');
 d(config.textcolor,'asked. The creatures that lurk around here obviously belong to');
 d(config.textcolor,'the lower sediments of society.');
 d(config.textcolor,'Among these gentlemens big muscles often make a difference.');
 d(config.textcolor,'No wonder then, that you can buy pills here.');
 d(config.textcolor,'You walk to the register desk.');
 crlf;
 menu('(L)ist Vitamines');
 menu('(B)uy');
 menu('(S)tatus');
 menu('(R)eturn to street');

end;

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'L',
                       'B',
                       'S',
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    clearscreen;
    meny;
   end;
   crlf;
   sd(config.textcolor,'Lizards ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,'Lizards (R,L,B,S,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   clearscreen;
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure Steroid_Store;

const sternr=10;

var
   steroid : array[1..sternr] of ^s70;
   sterprice : array[1..sternr] of ^longint;
   comment : array[1..sternr] of ^s70;

   xx, i, x : longint;

   cho : char;

   s : s70;

   justval : integer;

   leave_store : boolean;

begin

 {this global variable handled player who drop carrier to cheat}
 global_PlayerInSteroids:=true; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}


 {init pointer variables}
 for i:=1 to sternr do begin
  new(steroid[i]);
  new(sterprice[i]);
  new(comment[i]);
 end;

 {get shop-keepers name from .cfg #179}
 owner:=cfg_string(179);
 if owner='' then owner:='Rand the Human';

 steroid[1]^:='Teddy Bears';
 steroid[2]^:='Ape Hormones';
 steroid[3]^:='Centurion-X';
 steroid[4]^:='Godzilla Red';
 steroid[5]^:='Slave 9000';
 steroid[6]^:='Pulsatormium';
 steroid[7]^:='Implementor';
 steroid[8]^:='Dragon White';
 steroid[9]^:='Neon Kicker';
 steroid[10]^:='D.E.M.O.N.';

 sterprice[1]^:=1500;
 sterprice[2]^:=7000;
 sterprice[3]^:=20000;
 sterprice[4]^:=50000;
 sterprice[5]^:=70000;
 sterprice[6]^:=120000;
 sterprice[7]^:=175000;
 sterprice[8]^:=210000;
 sterprice[9]^:=350000;
 sterprice[10]^:=500000;

 comment[1]^:='Effective prep when taken during a long period.';
 comment[2]^:='Cheap and primitive strength almost for free!';
 comment[3]^:='Often used by Troll warriors. Aggressive impact.';
 comment[4]^:='Superb muscle booster. Nasty sideffects though.';
 comment[5]^:='Used to raise young slaves stamina and output.';
 comment[6]^:='Druids fabricate. That should warn you...';
 comment[7]^:='Miracle maker. Can also turn you old very fast.';
 comment[8]^:='Be experienced before you take this stuff...';
 comment[9]^:='Fly to madness or salvation with these pills.';
 comment[10]^:='What can this be? Why don'+chr(39)+'t you try it?';

 leave_store:=false;
 crlf;
 crlf;
 d(config.textcolor,'You enter the '+ulcyan+'Steroid'+config.textcol1+' shop.');
 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_steroids then begin
   refresh:=true;
   onliner.location :=onloc_steroids;
   onliner.doing    :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {display menu}
  display_menu(true,true);

  {get user-input}
  cho:=upcase(getchar);

  {evaluate user-input}
  case cho of
   '?':begin
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'R':begin
        leave_store:=true;
        crlf;
        crlf;
        d(config.textcolor,'Come back soon!');
        crlf;
       end;
   'S':begin
        status(player);
       end;
   'B':begin
        crlf;
        d(3,'Enter Item # to buy');
        sd(config.textcolor,':');
        x:=get_number(0,sternr);
        if (x<1) or (x>sternr) then x:=0;
        if x=0 then begin
         d(15,'Wrong number birdbrain!');
         d(15,'(valid numbers are 1..'+commastr(sternr)+')');
        end
        else begin
         i:=x;
         sd(config.textcolor,'Buy some ');
         sd(5,steroid[i]^);

         if confirm('','n')=true then begin
          if player.mental<10 then begin
           crlf;
           d(config.textcolor,'You may not buy Steriods with your current status!');
           d(config.textcolor,'It may kill you! Try to stay healthy!');
           crlf;
           pause;
           break;
          end;

          if player.gold<sterprice[i]^ then begin
           d(config.textcolor,'You don''t have enough '+config.moneytype+'!');
           pause;
          end
          else begin
           crlf;
           d(config.textcolor,'After have seen your '+config.moneytype+', '+owner+' picks up a tiny package');
           d(config.textcolor,'behind his counter. You hand the slimy human the '+config.moneytype+'.');
           d(config.textcolor,'Inside the package you find a little box containing a couple');
           d(config.textcolor,'of pills. You quickly swallow them down with a glass of water.');
           crlf;
           pause;
           crlf;

           d(config.textcolor,'Glugg..');
           delay2(800);
           d(config.textcolor,'Slurp..');
           delay2(800);
           d(config.textcolor,'Mmmmm..');
           delay2(800);
           d(config.textcolor,'Slurp..');
           delay2(800);
           d(config.textcolor,'Glugg..');
           delay2(800);
           d(config.textcolor,'....Gulp!');
           delay2(1000);

           {pay for pill}
           decplayermoney(player,sterprice[i]^);

           crlf;
           pause;
           crlf;
           d(config.textcolor,'Mmmm...that was easy! You sit down a while to check out');
           d(config.textcolor,'your condition. At first you feel nothing...');
           crlf;
           pause;

           xx:=random(11);
           if (xx=0) and (i>0) then begin
            crlf;
            d(config.textcolor,'Oh my god....something is wrong!');
            d(config.textcolor,'What the hell was in those pills you just took?');
            d(config.textcolor,'Bad mixture! Arghhhh! You fade away....');
            crlf;
            show_usurper_data(picture_death_head,false);
            d(config.textcolor,'Darkness...');

            {news-paper}
            newsy(true,
            'Bad Steroids!',
            ' '+uplc+player.name2+config.textcol1+' bought a package of steroids to build up '+sex3[player.sex]+' body.',
            ' Unfortunately the stuff was bad, and '+uplc+player.name2+config.textcol1+' died.',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            crlf;
            {player.allowed:=false;}
            Reduce_Player_Resurrections(player,true);
            pause;

            global_PlayerInSteroids:=false; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}
            normal_exit;
           end
           else begin

            case i of
             0 : x:=2+random(2);
             1 : x:=4+random(4);
             2 : x:=6+random(6);
             3 : x:=8+random(8);
             4 : x:=10+random(10);
             5 : x:=12+random(12);
             6 : x:=14+random(16);
             7 : x:=16+random(20);
             8 : x:=18+random(25);
             9 : x:=26+random(55);
            end;

            {x:=x-random(player.mental);
            if x<=0 then x:=50;}
            if player.strength<32000 then begin
             player.strength:=player.strength+x;
            end;

            crlf;
            d(config.textcolor,'Successful Body Build-up!');
            d(config.textcolor,'*************************');
            d(config.textcolor,'Your strength increase with '+uwhite+commastr(x)+config.textcol1+'!');
            crlf;


            case i of
             0 : x:=2+random(2);
             1 : x:=4+random(4);
             2 : x:=6+random(6);
             3 : x:=8+random(8);
             4 : x:=10+random(10);
             5 : x:=12+random(12);
             6 : x:=14+random(16);
             7 : x:=16+random(18);
             8 : x:=18+random(20);
             9 : x:=26+random(25);
            end;

            if player.race=Gnome then begin
             x:=x-2;
             if x<=0 then x:=0;
            end;
            player.mental:=player.mental-x;
            if player.mental<0 then player.mental:=0;

            case random(5) of
             0 : s:=uplc+player.name2+config.textcol1+' shot '+sex4[player.sex]+' full with steroids.';
             1 : s:=uplc+player.name2+config.textcol1+' bought loads with steroids.';
             2 : s:=uplc+player.name2+config.textcol1+' increased his strength with steroids.';
             3 : s:=uplc+player.name2+config.textcol1+' got bigger and meaner with some pills.';
             4 : s:=uplc+player.name2+config.textcol1+' gave '+sex3[player.sex]+' body a dose of steroids.';
            end;

            {news-paper}
            newsy(true,
            'Body Builder',
            ' '+s,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

           end;

           user_save(player);
           pause;

           {player.allowed:=false;}
           Reduce_Player_Resurrections(player,true);
           global_PlayerInSteroids:=false; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}
           normal_exit;

          end;
         end
         else begin
          cho:='A';
         end;
        end;
       end;
   'L':begin {list steroids}
        clearscreen;
        crlf;
        d(6,'   Steroid         Cost     Comment');
        for i:=1 to sternr do begin
         justval:=3;
         sd(10,ljust(commastr(i),justval));
         justval:=16;
         sd(5,ljust(steroid[i]^,justval));
         justval:=9;
         sd(14,ljust(commastr(sterprice[i]^),justval));
         d(config.textcolor,comment[i]^);
        end;

       end;
  end; {case .end.}

 until Leave_Store;
 crlf;

 {player is no longer in Steroid Shop. We reset "drop carrier checking"
   flag}
 global_PlayerInSteroids:=false; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}

 {dispose pointer vars}
 for i:=1 to sternr do begin
  dispose(steroid[i]);
  dispose(sterprice[i]);
  dispose(comment[i]);
 end;

end; {Steroid_Store *end*}

end. {Unit Steroids .end.}
