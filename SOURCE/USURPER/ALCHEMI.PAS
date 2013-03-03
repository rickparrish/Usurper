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


Unit Alchemi; {Usurper - 'Alchemists only' place}

Interface

Procedure Alchemisty;

Implementation

Uses Init, Cms, Jakob,
     Statusc, News, PlvsMon,
     Various, Various3, Online,
     File_Io;

var refresh : boolean;

Procedure Failed_Quest(level:byte);
begin

 newsy(true,
       'Failed Challenge!',
       ' '+uplc+player.name2+config.textcol1+' failed the '+commastr(level)+' test for the Secret Order.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

 crlf;
 d(12,'Oh No! You have failed the test!');
 d(12,'You may try again tomorrow...');
 crlf;
 {player.allowed:=false;}
 Reduce_Player_Resurrections(player,true);
 pause;
 halt;

end;

Procedure Meny;
var s : string[10];
begin
 clearscreen;
 crlf;
 d(5,'-*- Alchemists Heaven -*-');
 crlf;
 d(config.textcolor,'Scarred by the tooth of time, the old cottage doesn''t look');
 d(config.textcolor,'much. Usilama the once so proud Druid is now the shop-');
 d(config.textcolor,'keeper of the Alchemists Heaven. Here you can buy the stuff');
 d(config.textcolor,'you need for expanding your knowledge of your profession.');
 d(config.textcolor,'Recipes can be learned and practiced. Always remember that');
 d(config.textcolor,'your skills as an Alchemist can be expanded beyond belief...');
 crlf;

 sd(config.textcolor,'Poison currently affecting your weapon : ');

 if player.poison>0 then begin

  s:=alchemist_poison(player);
  sd(15,s);

 end
 else begin
  sd(15,'None');
 end;

 crlf;
 menu('(B)uy Poison');
 menu('(T)he Secret Order');
 menu('(S)tatus');
 menu('(R)eturn to street');

end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['B',
                       'S',
                       'U',
                       'R',
                       chr(13),
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   crlf;
   sd(config.textcolor,'Alchemist Store ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,'Alchemist (B,S,T,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure Alchemisty;
const max_poison = 21;
var
    poison   : array[1..max_poison] of ^s70;
    pcost    : array[1..max_poison] of ^longint;
    strength : array[1..max_poison] of ^integer;

    xx, zz, x, i : longint;
    y : integer;
    s : s70;
    a : s70;
    ch : char;
    pl : array [1..4] of ^Userrec;

begin

 {init pointer vars}
 new(pl[1]);
 new(pl[2]);
 new(pl[3]);
 new(pl[4]);

 for i:=1 to max_poison do begin
  new(poison[i]);
  new(pcost[i]);
  new(strength[i]);
 end; {for i:= .end.}

 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_alchemist then begin
   refresh:=true;
   onliner.location:=onloc_alchemist;
   onliner.doing:=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  display_menu(true,true);

  ch:=upcase(getchar);

  case ch of
   '?':begin {display menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        clearscreen;
        status(player);
       end;
   'T':begin {The Secret Order}
        crlf;
        crlf;

        if player.level<10 then begin
         d(global_plycol,'Usilama'+config.textcol1+' looks at you.');
         d(global_talkcol,'You are not yet worthy to join the Order!');
         d(global_talkcol,'You must at least be a level 10 Alchemist before');
         d(global_talkcol,'we can deal with your application!');
        end
        else begin
         if player.amember=false then begin
          crlf;
          d(config.textcolor,'Usilama looks at you very intensly.');
          d(global_talkcol,'I know that you are not a member of the Secret Order.');
          d(global_talkcol,'Since you have made some progress in your career,');
          d(global_talkcol,'an application for membership could be accepted...');

          pause;
          crlf;
          d(global_talkcol,'So you would like to join the secret order?');
          d(global_talkcol,'You have to pass some tests before you can be approved!');
          d(global_talkcol,'These tests are very dangerous and can easily have you killed!');
          pause;
          crlf;

          d(global_talkcol,'But if you want to become a member of this powerful order,');
          d(global_talkcol,'You should not hesitate. The benefits of the brotherhood cannot');
          d(global_talkcol,'be measured...!');
          pause;

          crlf;
          if confirm('Apply for membership','N')=true then begin

           {QUEST 1}
           crlf;
           d(global_talkcol,'Prepare for the first challenge!');
           crlf;

           reset_monsters;

           case random(3) of
            0:begin
               monster[1]^.name:='Great Boa';
               monster[1]^.hps:=150;
               monster[1]^.strength:=20;
               monster[1]^.defence:=12;
               monster[1]^.phrase:='Ssssssss.....!!';
               monster[1]^.grabweap:=false;
               monster[1]^.grabarm:=false;
               monster[1]^.weapon:='Moon Claw';
               monster[1]^.weappow:=15;
               monster[1]^.poisoned:=false;
               monster[1]^.disease:=false;
               monster[1]^.punch:=100;
              end;
            1:begin
               monster[1]^.name:='Great Boar';
               monster[1]^.hps:=125;
               monster[1]^.strength:=25;
               monster[1]^.defence:=10;
               monster[1]^.phrase:='Mmmmrrrrr..!';
               monster[1]^.grabweap:=false;
               monster[1]^.grabarm:=false;
               monster[1]^.weapon:='Diamond Claw';
               monster[1]^.weappow:=17;
               monster[1]^.poisoned:=false;
               monster[1]^.disease:=false;
               monster[1]^.punch:=80;
              end;
            2:begin
               monster[1]^.name:='Huge Tiger';
               monster[1]^.hps:=110;
               monster[1]^.strength:=30;
               monster[1]^.defence:=14;
               monster[1]^.phrase:='rrrrrrr...';
               monster[1]^.grabweap:=false;
               monster[1]^.grabarm:=false;
               monster[1]^.weapon:='Steel Jaws';
               monster[1]^.weappow:=27;
               monster[1]^.poisoned:=false;
               monster[1]^.disease:=false;
               monster[1]^.punch:=90;
              end;
           end; {case .end.}

           global_begged:=false;
           global_nobeg:=true;

           pl[1]^.name2:='';
           pl[2]^.name2:='';
           pl[3]^.name2:='';
           pl[4]^.name2:='';

           
           player_vs_monsters(pl_vs_alchemist,pl[1]^,pl[2]^,pl[3]^,pl[4]^);

           if player.hps<1 then begin
            failed_quest(2);
           end;

           {QUEST 2}
           crlf;
           crlf;
           d(15,'*****************');
           d(15,'*   WELL DONE!  *');
           d(15,'*  1st mission  *');
           d(15,'*    cleared    *');
           d(15,'*****************');
           crlf;
           pause;

           crlf;
           sd(config.textcolor,'Prepare to face the wicked ');
           sd(14,'Iceman');
           d(config.textcolor,'!');
           crlf;
           d(3,'** You are doing well so far **');
           pause;

           reset_monsters;

           monster[1]^.name:='Iceman';
           monster[1]^.hps:=130;
           monster[1]^.strength:=30;
           monster[1]^.defence:=17;
           monster[1]^.phrase:='Thou shall be frosty!';
           monster[1]^.grabweap:=true;
           monster[1]^.grabarm:=false;
           monster[1]^.weapon:='Ice Spear';
           monster[1]^.weappow:=25;
           monster[1]^.poisoned:=false;
           monster[1]^.disease:=false;
           monster[1]^.punch:=75;

           player_vs_monsters(pl_vs_alchemist,pl[1]^,pl[2]^,pl[3]^,pl[4]^);

           if player.hps<1 then begin
            failed_quest(1);
           end;

           {QUEST 3}
           crlf;
           crlf;
           d(15,'*****************');
           d(15,'*   WELL DONE!  *');
           d(15,'*   2 mission   *');
           d(15,'*    cleared    *');
           d(15,'*****************');
           crlf;
           pause;


           newsy(true,
           '** SECRET ORDER OF ALCHEMY EXPANDS **',
           ' '+uplc+player.name2+config.textcol1+' has been accepted as a member of the secret order.',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           crlf;

           player.amember:=true;
           user_save(player);

           d(15,'"WELL DONE! You have been accepted as a member');
           d(15,'of our secret society.');
           d(15,'As a member of this order you must follow certain');
           d(15,'rules. Neglecting to do so will lead to immediate');
           d(15,'excommunication from the order".');

           crlf;
           pause;

          end
          else begin
           crlf;
           d(config.textcolor,'Usilama looks a bit disappointed.');
           d(global_talkcol,'Well then, You are welcome to try again later.');
           crlf;
          end;
         end
         else begin
          crlf;

          d(config.textcolor,'You enter the secret chamber behind the counter.');
          d(config.textcolor,'You remove the old rug and open the trap-door.');
          d(config.textcolor,'You set fire to a torch and descend down the staircase...');

          crlf;
          pause;
          crlf;
          d(10,'The Secret Alchemist Order');
          d(config.textcolor,'You are standing in a chamber under the store.');
          d(config.textcolor,'The stones in the walls are black as night. Some of them');
          d(config.textcolor,'have inscriptions on them.');
          d(config.textcolor,'A large round table is placed in the middle of the room.');
          d(config.textcolor,'A book is laying on the table.');
          sd(config.textcolor,'A fire is burning in the grate. In front of the fire an ');
          d(global_plycol,'old man');
          d(config.textcolor,'is sitting in a rocking-chair. It looks if he''s sleeping.');
          d(config.textcolor,'The man is holding a poker in his right hand.');
          d(config.textcolor,'There are two exits from here; up or down.');
          crlf;
          ch:='?';

          {update player location}
          onliner.location :=onloc_mystic;
          onliner.doing    :=location_desc(onliner.location);
          add_onliner(OUpdateLocation,onliner);

          repeat

           case ch of
            '?':begin
                 crlf;
                 menu('(E)xamine book');
                 menu('(C)reate poison');
                 menu('(S)tatus');
                 menu('(U)p');
                end;
            'S':begin
                 clearscreen;
                 status(player);
                end;
            'C':begin
                 crlf;
                 crlf;
                 d(5,'Create Poison');
                 d(config.textcolor,'You can create 5 different poisons :');

                 menu('(1) Stone Breaker      ( 50,000)');
                 menu('(2) Warrior Terminator (150,000)');
                 menu('(3) Magic Terrorizer   (250,000)');
                 menu('(4) Evil Disposer      (300,000)');
                 menu('(5) Heart Tracker      (325,000)');
                 menu('(A)bort');
                 sd(config.textcolor,':');

                 repeat
                  ch:=upcase(getchar);
                 until ch in ['A','1','2','3','4','5'];

                 crlf;

                 case ch of
                  '1':begin
                       if player.gold>=50000 then begin
                        player.poison:=75;
                        decplayermoney(player,50000);
                        d(15,'Ok.');
                        sd(15,'You are now in possession of the powerful ');
                        sd(5,'Stone Breaker');
                        d(15,' poison.');
                       end
                       else begin
                        d(12,'You can''t afford it!');
                       end;
                      end;
                  '2':begin
                       if player.gold>=150000 then begin
                        player.poison:=90;
                        decplayermoney(player,150000);
                        d(15,'Ok.');
                        sd(15,'You are now in possession of the powerful ');
                        sd(5,'Warrior Terminator');
                        d(15,' poison.');
                       end
                       else begin
                        d(12,'You can''t afford it!');
                       end;
                      end;
                  '3':begin
                       if player.gold>=250000 then begin
                        player.poison:=120;
                        decplayermoney(player,250000);
                        d(15,'Ok.');
                        sd(15,'You are now in possession of the powerful ');
                        sd(5,'Magic Terrorizer');
                        d(15,' poison.');
                       end
                       else begin
                        d(12,'You can''t afford it!');
                       end;
                      end;
                  '4':begin
                       if player.gold>=300000 then begin
                        player.poison:=150;
                        decplayermoney(player,300000);
                        d(15,'Ok.');
                        sd(15,'You are now in possession of the powerful ');
                        sd(5,'Evil Disposer');
                        d(15,' poison.');
                       end
                       else begin
                        d(12,'You can''t afford it!');
                       end;
                      end;
                  '5':begin
                       if player.gold>=325000 then begin
                        player.poison:=200;
                        decplayermoney(player,325000);
                        d(15,'Ok.');
                        sd(15,'You are now in possession of the powerful ');
                        sd(5,'Heart Tracker');
                        d(15,' poison.');
                       end
                       else begin
                        d(12,'You can''t afford it!');
                       end;
                      end;

                 end;


                end;
            'E':begin
                 crlf;
                 crlf;
                 d(config.textcolor,'It''s the list of all members');
                 crlf;
                 d(15,'**-- Members of the Order --**');

                 x:=0;

                 for i:=1 to fs(FsPlayer) do begin
                  load_character(pl[1]^,1,i);
                  if (pl[1]^.amember) and
                     (pl[1]^.deleted=false) then begin
                   inc(x);
                   d(global_plycol,pl[1]^.name2);
                  end;
                 end; {for i= .end.}

                 for i:=1 to fs(FsNpc) do begin
                  load_character(pl[1]^,2,i);
                  if (pl[1]^.amember) and
                    (pl[1]^.deleted=false) then begin
                   inc(x);
                   d(global_plycol,pl[1]^.name2);
                  end;

                 end; {for i= .end.}

                 sd(config.textcolor,'The Order has a total of ');
                 sd(15,commastr(x));
                 d(config.textcolor,' members.');
                end;
           end;

           crlf;
           sd(config.textcolor,'The Order (E,C,S,U,?) :');

           ch:=upcase(getchar);

          until ch='U';
          crlf;
          crlf;
          d(config.textcolor,'You leave up...');
          crlf;
          ch:=' ';
         end;
        end;
       end;
   'B':begin
       clearscreen;
       crlf;
       d(5,'Poisons currently available :');
       d(5,'-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');

       poison[1]^:='Snake Bite';
       strength[1]^:=4;

       poison[2]^:='Xaminah Stir';
       strength[2]^:=10;

       poison[3]^:='Zargothicia';
       strength[3]^:=14;

       poison[4]^:='Diamond Sting';
       strength[4]^:=17;

       poison[5]^:='Mynthia';
       strength[5]^:=21;

       poison[6]^:='Exxodus';
       strength[6]^:=41;

       poison[7]^:='Wolf Spit';
       strength[7]^:=51;

       poison[8]^:='Joy of Death';
       strength[8]^:=71;

       poison[9]^:='Eusebius Cure';
       strength[9]^:=81;

       poison[10]^:='Yxaxxiantha';
       strength[10]^:=85;

       poison[11]^:='Polluted Lung';
       strength[11]^:=90;

       poison[12]^:='Postheria';
       strength[12]^:=96;

       poison[13]^:='Red Sledge';
       strength[13]^:=100;

       poison[14]^:='Mullamia';
       strength[14]^:=110;

       poison[15]^:='Cobra High';
       strength[15]^:=115;

       poison[16]^:='Stomach Claw';
       strength[16]^:=120;

       poison[17]^:='Fasanathievh';
       strength[17]^:=125;

       poison[18]^:='Urpathxiaveth';
       strength[18]^:=130;

       poison[19]^:='Dragon Flame';
       strength[19]^:=135;

       poison[20]^:='Usilamahs Bite';
       strength[20]^:=140;

       poison[21]^:='Devils Cure';
       strength[21]^:=145;

       pcost[1]^:=1500;
       pcost[2]^:=11000;
       pcost[3]^:=25000;
       pcost[4]^:=100000;
       pcost[5]^:=300000;
       pcost[6]^:=550000;
       pcost[7]^:=850000;
       pcost[8]^:=1250000;
       pcost[9]^:=1500000;
       pcost[10]^:=1900000;
       pcost[11]^:=3000000;
       pcost[12]^:=6000000;
       pcost[13]^:=9000000;
       pcost[14]^:=9100000;
       pcost[15]^:=9200000;
       pcost[16]^:=9300000;
       pcost[17]^:=9400000;
       pcost[18]^:=9500000;
       pcost[19]^:=9600000;
       pcost[20]^:=9700000;
       pcost[21]^:=9900000;

       x:=0;
       xx:=0;
       for i:=1 to max_poison do begin
        if player.level>x then begin
         x:=x+5;
         xx:=xx+1;
         if length(commastr(i)+'.  '+poison[i]^)<32 then begin
          a:='                        ';
          y:=length(commastr(i)+'.  '+poison[i]^);
          y:=28-y;
          sd(9,commastr(i)+'. '+poison[i]^+copy(a,1,y));
         end;
         sd(9,commastr(pcost[i]^));
         crlf;
        end;
       end;

       crlf;
       d(7,'Enter number to buy (1-'+commastr(xx)+')');
       sd(7,':');

       zz:=get_number(0,xx);
       if (zz>0) and (zz<=xx) then begin
        if confirm('Buy the recipe for '+poison[zz]^,'n')=true then begin
         if player.gold<pcost[zz]^ then begin
          d(config.textcolor,'You don''t have enough '+config.moneytype+'!');
          crlf;
          pause;
         end
         else begin;
          decplayermoney(player,pcost[zz]^);

          player.poison:=strength[zz]^;

          crlf;
          d(config.textcolor,'You receive the ingredients for the poison.');
          d(config.textcolor,'After a few hours in the laboratory your poison');
          d(config.textcolor,'is ready to be tested in the real world!');
          crlf;


          newsy(true,
          'Beware!',
          ' '+uplc+player.name2+config.textcol1+', the alchemist, bought poison!',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

          pause;
         end;
        end;
       end
       else begin
        crlf;
       end;
       end;
  end;

 until ch='R';

 {dispose of pointer vars}
 dispose(pl[1]);
 dispose(pl[2]);
 dispose(pl[3]);
 dispose(pl[4]);

 for i:=1 to max_poison do begin
  dispose(poison[i]);
  dispose(pcost[i]);
  dispose(strength[i]);
 end;

 crlf;

end; {Alchemisty *end*}

end. {Unit Alchemi .end.}
