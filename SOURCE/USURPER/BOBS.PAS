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


Unit Bobs; {Usurper - Bobs Beer}

Interface

Procedure Bobs_Inn;

Implementation

Uses Init, Cms, Jakob,
     Statusc, Brawlc, News,
     Drinking, Mail, PlvsMon,
     Various, Various2, Various3,
     Online, File_Io;

var
    refresh : boolean;

    justval : integer;

    pl : array [1..4] of ^Userrec; {User Records}


Procedure Meny;
begin
 clearscreen;
 crlf;
 d(5,'-*- '+config.bobsplace+' -*-');
 crlf;
 d(config.textcolor,'This place is the rendezvous for every lowlife in town.');
 d(config.textcolor,'Unexperienced characters should not enter here alone.');
 d(config.textcolor,'If you are looking for trouble, here it is!');
 d(config.textcolor,'As you enter the hut, there is a short moment of silence.');
 d(config.textcolor,'But things soon get back to normal when your entrance');
 d(config.textcolor,'has been noticed.');
 crlf;
 menu2('(B)rawl      ');
 menu('(C)ompete in Beer Drinking');
 menu2('(D)ance      ');
 menu('(T)hievery');
 menu('(S)tatus');
 menu('(R)eturn');

end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['B',
                       'C',
                       'D',
                       'T',
                       'R',
                       chr(13),
                       'S',
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;
   crlf;
   sd(config.textcolor,config.bobsplace+' (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,config.bobsplace+' (B,C,D,T,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure Man_In_Robes;
var ch : char;
    i,x : longint;
begin
 {strange man in robes approaches!}
   crlf;
   dec(player.darknr);
   d(10,'You are approached by a stranger in robes!');
   d(15,'He offers you to see some fine wares he has in store.');
   crlf;
   d(config.textcolor,'The stranger smiles at you. His face is well hidden though, and');
   d(config.textcolor,'you can''t really figure out if this is someone to trust...');
   crlf;
   if confirm('Follow the stranger outside ','N')=true then begin

    {update player location}
    onliner.location:=onloc_bobthieves;
    onliner.doing   :=location_desc(onliner.location);
    add_onliner(OUpdateLocation,onliner);

    crlf;
    d(config.textcolor,'You follow the stranger out into the nearby alley...');
    delay2(800);
    crlf;

    x:=random(3);
    {x:=2; {FUSK}
    case x of
     0:begin {shakedown!}
        d(12,'SHAKEDOWN!');
        d(config.textcolor,'A bunch of rough characters suddenly appear from the shadows.');
        d(config.textcolor,'The stranger smirks and pulls out a long knife from his robes!');
        d(15,'"Alright, give us your '+config.moneytype+' or be sorry!"');

        ch:='?';
        repeat
         if ch='?' then begin
          crlf;
          d(10,'Your move?');
          menu('(G)ive them your cash ('+commastr(player.gold)+' '+many_money(player.gold)+')');
          menu('(D)efend yourself!');
          sd(config.textcolor,':');
         end;
         ch:=upcase(getchar);
        until ch in ['D','G'];

        case ch of
         'D':begin
              new(pl[1]);
              new(pl[2]);
              new(pl[3]);
              new(pl[4]);

              crlf;
              reset_monsters;
              for i:=1 to 5 do begin
               monster[i]^.name:='thug';
               monster[i]^.hps:=player.hps-random(25);
               monster[i]^.strength:=player.strength-random(25);
               monster[i]^.defence:=50;
               monster[i]^.phrase:='Give us your '+config.moneytype+'!';
               monster[i]^.grabweap:=false;
               monster[i]^.grabarm:=false;
               monster[i]^.weapon:='Warp dagger';
               monster[i]^.weappow:=player.level*50;
               monster[i]^.armpow:=player.level*50;
               monster[i]^.poisoned:=false;
               monster[i]^.disease:=false;
               monster[i]^.punch:=500;

               if i=1 then begin
                monster[i]^.name:='Thug Leader';
                monster[i]^.hps:=monster[i]^.hps+random(200);
                monster[i]^.weapon:='Evil dagger';
                monster[i]^.punch:=70;
               end;
               if monster[i]^.hps<20 then monster[i]^.hps:=20+random(10);
               if monster[i]^.strength<20 then monster[i]^.strength:=20+random(10);
              end;

              global_begged:=false;
              global_nobeg:=true;

              pl[1]^.name2:='';
              pl[2]^.name2:='';
              pl[3]^.name2:='';
              pl[4]^.name2:='';

              player_vs_monsters(2,pl[1]^,pl[2]^,pl[3]^,pl[4]^);

              if global_killed=false then begin
               for i:=1 to 12 do begin
                player.spell[i,2]:=false;
               end;
               d(15,'GOOD WORK!');
               d(config.textcolor,'The streets are a bit safer now!');

               newsy(true,
               'Cleaner',
               ' '+uplc+player.name2+config.textcol1+' fought a band of rogues outside '+config.bobsplace+'!',
               ' '+uplc+player.name2+config.textcol1+' was victorious!',
               '',
               '',
               '',
               '',
               '',
               '',
               '');

              end
              else begin

               {news-paper}
               newsy(true,
               'Dead end!',
               ' '+uplc+player.name2+config.textcol1+' was tricked in '+config.bobsplace+'. The stubborn fool refused',
               ' to give '+sex3[player.sex]+' '+config.moneytype+' to a band of thugs.',
               ' '+uplc+player.name2+config.textcol1+' was killed!',
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
               umailheadc+'Last breath'+config.textcol1,
               mkstring(11,underscore),
               'You were killed by a band of thieves outside '+config.bobsplace+'.',
               'They took all your '+config.moneytype+'.',
               'You ended up with a dagger in the back...',
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

               d(config.textcolor,'You are dead....!');
               d(config.textcolor,'Kiss your precious '+config.moneytype+' goodbye!');
               player.hps:=0;
               player.gold:=0;
               normal_exit;
              end;

              dispose(pl[1]);
              dispose(pl[2]);
              dispose(pl[3]);
              dispose(pl[4]);

             end;
         'G':begin
              player.gold:=0;
              crlf;
              sd(15,'"Wise decision peasant!"');
              d(config.textcolor,', the leader of the scoundrels says as you hand over the '+config.moneytype+'.');
              crlf;
              delay2(300);
              d(config.textcolor,'Suddenly you are alone in the alley. You think for yourself that');
              d(config.textcolor,'perhaps you should have fought those men. Would it have been worth it?');
              pause;
             end;
        end;

       end; {ShakeDown END}
     1:begin {vitamin offer START}
        x:=player.level*10000;
        d(config.textcolor,'The stranger offers you a vitamin cure which he claims could');
        d(config.textcolor,'enhance your strength.');
        sd(config.textcolor,'The man wants ');
        sd(14,commastr(x));
        d(config.textcolor,' '+many_money(x)+' for the cure.');
        if player.gold<x then begin
         d(config.textcolor,'When you explain that you don''t have the '+config.moneytype+' he is asking');
         d(config.textcolor,'the stranger leaves.');
        end
        else begin
         crlf;
         if confirm('Buy a bottle','N')=TRUE then begin
          decplayermoney(player,x);
          d(config.textcolor,'You hand over the '+config.moneytype+' and recieve a bottle filled with');
          sd(config.textcolor,'something which looks like syrup......');
          delay2(800);
          crlf;
          sd(global_talkcol,'Down the hatch!');
          delay2(1000);
          crlf;
          crlf;
          x:=3+random(3);
          d(config.textcolor,'You wake up a short moment later. You are laying in the');
          d(config.textcolor,'alley. All your belongings are left untouched.');
          sd(config.textcolor,'Your strength went up by ');
          sd(15,commastr(x));
          d(config.textcolor,' !');
          pause;

         end
         else begin
          d(15,'"NO THANKS!"');
         end;
        end;
       end; {vitamin offer END}
     2:begin {teleport to UMAN cave START}
        x:=player.level*1500;
        d(config.textcolor,'The stranger says that he will guide you to the UMAN caves');
        sd(config.textcolor,'for only ');
        sd(14,commastr(x));
        d(config.textcolor,' '+many_money(x)+'.');

        if player.gold<x then begin
         d(config.textcolor,'When you explain that you don''t have the '+config.moneytype+',');
         d(config.textcolor,'the stranger leaves.');
        end
        else begin
         decplayermoney(player,x);
         crlf;
         d(config.textcolor,'You hand over the '+config.moneytype+' and start following the stranger...');
         crlf;
         pause;
         global_auto_probe:=UmanCave;
        end;
       end; {teleport to UMAN cave END}

    end; {case .end.}

   end
   else begin
    crlf;
    d(15,'NO THANKS!');
   end;


end; {man_in_robes *end*}

Procedure Bobs_Inn;
Var

    escaped:boolean;
    xx, y, x, reward : longint;

    male : boolean;

    pstam, cstam, cstammax, i, justval, diff : longint;

    a, a2, s, ts, ok , no : ^s70;

    rr : ^real;

    ch : char;

begin

 new(rr);
 new(a);
 new(a2);
 new(s);
 new(ts);
 new(ok);
 new(no);

 repeat

  if (random(5) = 0) and (player.darknr>0) and (player.gold>=1000) then begin
   man_in_robes;
   if global_auto_probe<>Nowhere then
    break;
  end

  {spaghetti incident?}
  else if (random(2)=0) and (player.darknr>0) then begin
   crlf;
   crlf;
   dec(player.darknr);
   d(14,'Insulted !?');

   {discovery}
   case random(31) of
    0:begin
      s^:='Mighty John';
      cstam:=player.stamina;
      male:=true;
      ts^:='human';
      ok^:='Ok, but DON''T mess with me again!';
      no^:='Haha! Prepare to fight!';
      end;
    1:begin
      s^:='Mary Joe';
      cstam:=player.stamina;
      male:=false;
      ts^:='mutant';
      ok^:='Alright, run and hide WIMP!';
      no^:='Oh no...you''re gonna take what''s coming to ya!';
      end;
    2:begin
      s^:='Hobbes';
      cstam:=250;
      male:=true;
      ts^:='dwarf';
      ok^:='We all make mistakes!';
      no^:='Grrrrr!';
      end;
    3:begin
      s^:='Sony Blue';
      cstam:=56;
      male:=true;
      ts^:='elf';
      ok^:='Run loser!';
      no^:='No way! Stand and fight!';
      end;
    4:begin
      s^:='Rex';
      cstam:=100;
      male:=true;
      ts^:='mutant';
      ok^:='Kiss my leather boots too!';
      no^:='Too late sucker!';
      end;
    5:begin
      s^:='Sandra';
      cstam:=70;
      male:=false;
      ts^:='human';
      ok^:='Next time I''ll mess ya up bad honey!';
      no^:='Fistfight!';
      end;
    6:begin
      s^:='Nick';
      cstam:=15;
      male:=true;
      ts^:='orc';
      ok^:='Get out of here before I change my mind!';
      no^:='I need practice! hehe!';
      end;
    7:begin
      s^:='Banco';
      cstam:=350;
      male:=true;
      ts^:='troll';
      ok^:='Hohoho...Get lost WORM!';
      no^:='You have crossed the line punk!';
      end;
    8:begin
      s^:='Holly';
      cstam:=40;
      male:=true;
      ts^:='human';
      ok^:='Get lost scum!';
      no^:='I''m gonna trash you to pieces!';
      end;
    9:begin
      s^:='Soufie';
      cstam:=30;
      male:=false;
      ts^:='gnoll';
      ok^:='Get lost goofy!';
      no^:='Too late for nice talk!';
      end;
   10:begin
      s^:='Fat Pa';
      cstam:=219;
      male:=true;
      ts^:='troll';
      ok^:='Get lost creep!';
      no^:='Hehehehe! NO WAY!';
      end;
   11:begin
      s^:='Ma Teng';
      cstam:=45;
      male:=true;
      ts^:='mutant';
      ok^:='Apology accepted!';
      no^:='BUTT-KICKING TIME!';
      end;
   12:begin
      s^:='Lucky';
      cstam:=65;
      male:=false;
      ts^:='hobbit';
      ok^:='Ssssss...';
      no^:='Nope! Stand up and fight!';
      end;
   13:begin
      s^:='Oneeyed Rose';
      cstam:=30;
      male:=false;
      ts^:='dwarf';
      ok^:='Hahaha...get lost COWARD!';
      no^:='BAHAHA! I don''t think you realize who I am!';
      end;
   14:begin
      s^:='Fat Irma';
      cstam:=50;
      male:=false;
      ts^:='human';
      ok^:='Mehehe!! Crawl back mama before you get into trouble!';
      no^:='Yihhaaa! I need a sandbag like you to train with!';
      end;
   15:begin
      s^:='Sherkh';
      cstam:=50;
      male:=true;
      ts^:='gnome';
      ok^:='Ok.';
      no^:='No way partner! Time to slug it out with me!';
      end;
   16:begin
      s^:='Nitt';
      cstam:=15;
      male:=true;
      ts^:='gnoll';
      ok^:='Coward!';
      no^:='Haha! Fight me instead!!';
      end;
   17:begin
      s^:='Ehsan Kahn';
      cstam:=95;
      male:=true;
      ts^:='human';
      ok^:='Run along then!';
      no^:='No, we must fight!';
      end;
   18:begin
      s^:='Blue';
      cstam:=95;
      male:=false;
      ts^:='Half-elf';
      ok^:='Grrrrr!';
      no^:='Grrrrr!';
      end;
   19:begin
      s^:='Highlord';
      cstam:=125;
      male:=true;
      ts^:='Half-elf';
      ok^:='I accept your apology!';
      no^:='I''m afraid it''s too late for that!';
      end;
   20:begin
      s^:='Sbort Afsghar';
      cstam:=162;
      male:=true;
      ts^:='orc';
      ok^:='Alright, run along my friend!';
      no^:='Mohahaa! NO WAY!';
      end;
   21:begin
      s^:='Valin Junior';
      cstam:=262;
      male:=true;
      ts^:='dwarf';
      ok^:='Go in peace!';
      no^:='You are DEAD!';
      end;
   22:begin
      s^:='Marty';
      cstam:=35;
      male:=true;
      ts^:='mutant';
      ok^:='Get lost hairbag!';
      no^:='FIGHT OR PERISH!';
      end;
   23:begin
      s^:='Trudi';
      cstam:=55;
      male:=false;
      ts^:='hobbit';
      ok^:='You were lycky this time...';
      no^:='My name is TRUDI! I love fighting!';
      end;
   24:begin
      s^:='Conway';
      cstam:=155;
      male:=true;
      ts^:='human';
      ok^:='It''s your lucky day!';
      no^:='Fight!';
      end;
   25:begin
      s^:='Morgan Razorblade';
      cstam:=175;
      male:=true;
      ts^:='orc';
      ok^:='Escape while you can...';
      no^:='Your subordinance must come to an end!';
      end;
   26:begin
      s^:='Mufti';
      cstam:=40;
      male:=true;
      ts^:='mutant';
      ok^:='Get lost loser!';
      no^:='You must be punished!';
      end;
   27:begin
      s^:='Carla';
      cstam:=100;
      male:=false;
      ts^:='elf';
      ok^:='Get out of my face!';
      no^:='Bah! Liar!';
      end;
   28:begin
      s^:='Mino';
      cstam:=15;
      male:=true;
      ts^:='half-elf';
      ok^:='Oh my! Getting nervous, are we?';
      no^:='Let''s solve this problem with our fists!';
      end;
   29:begin
      s^:='Rooney';
      cstam:=75;
      male:=true;
      ts^:='mutant';
      ok^:='Sissy!';
      no^:='Pay the price for your rudness!';
      end;
   30:begin
      s^:='Kaya the Evil';
      cstam:=275;
      male:=false;
      ts^:='troll';
      ok^:='You get away this time!';
      no^:='Traitor! You must be punished!';
      end;
   31:begin
      s^:='Crazy Moe';
      cstam:=130;
      male:=true;
      ts^:='human';
      ok^:='Mehehe!! Crawl back mama before you get into trouble!';
      no^:='Yihhaaa! I need a sandbag like you to train with!';
      end;
   end;

   case random(5) of
    0: d(config.textcolor,'A '+ts^+' taps you gently on your head!');
    1: d(config.textcolor,'A '+ts^+' spills some beer on your clothes!');
    2: d(config.textcolor,'A '+ts^+' laughs at your clothes!');
    3: d(config.textcolor,'A '+ts^+' spits in your hair!');
    4: d(config.textcolor,'A '+ts^+' pukes at your clothes!');
   end;

   case random(3) of
    0: d(config.textcolor,'Many guests laugh at you!');
    1: d(config.textcolor,'There is a sudden silence in the room!');
    2: d(config.textcolor,'Everybody is looking your way!');
   end;

   if confirm('Are you gonna put up with this treatment','Y')=false then begin
    crlf;
    d(14,'Yeah! REVENGE!');
    crlf;
    sd(config.textcolor,'You walk up to the '+uplc+ts^+config.textcol1+' and tap ');

    if male=true then sd(config.textcolor,'him on the shoulder...')
                 else sd(config.textcolor,'her on the shoulder...');

    crlf;pause;
    d(config.textcolor,'The '+ts^+' turns to you and says : ');
    case random(6) of
     0: d(global_talkcol,'  What is it WORM?');
     1: d(global_talkcol,'  Wanna make something out of this?');
     2: d(global_talkcol,'  Do you want to say something?');
     3: d(global_talkcol,'  Yeah?');
     4: d(global_talkcol,'  Ohhh! I am really SCARED!  Hahaha!');
     5: d(global_talkcol,'  What do you want '+race_display(2,player.race,0)+'?');
    end;
    crlf;

    sd(config.textcolor,'It''s ');
    sd(global_plycol,s^);
    sd(config.textcolor,' that you have run across!');
    crlf;
    sd(config.textcolor,'Your chances : ');

    pstam:=player.stamina;
    cstammax:=cstam;
    reward:=cstam*100+random(500);
    diff:=cstam-pstam;

    a2^:='YOU ARE MAD!';

    if diff<100 then a2^:='Don''t even think about it!';
    if diff<90 then  a2^:='The chances are VERY VERY small!';
    if diff<80 then  a2^:='You''re gonna get messed up!';
    if diff<70 then  a2^:='No way you can win this!';
    if diff<60 then  a2^:='Are you mad?';
    if diff<50 then  a2^:='Feel lucky punk?';
    if diff<40 then  a2^:='Very risky!';
    if diff<35 then  a2^:='Risky!';
    if diff<30 then  a2^:='Can get rough...';
    if diff<20 then  a2^:='You can''t lose!';
    if diff<10 then  a2^:='Almost too easy...';
    if diff<0  then  a2^:='Piece of Cake!';
    if diff<-10 then a2^:='You can do it blindfolded!';

    sd(5,a2^);
    crlf;
    crlf;

    d(config.textcolor,'Make your move :');
    menu('(E)lbow in the face');
    menu('(S)traight punch in the stomach');
    menu('(T)rip the scumbag');
    menu('(B)ite ear');
    menu('(A)pologize for disturbing '+s^);
    sd(config.textcolor,':');

    escaped:=false;
    repeat
     ch:=upcase(getchar);
    until ch in ['E','S','T','B','A'];

    if ch='A' then begin
     if random(2)=0 then begin
      crlf;
      d(14,'"'+no^+'"');
     end
     else begin
      crlf;
      d(14,'"'+ok^+'"');
      escaped:=true;
      pause;
     end;
    end;

    crlf;

    if cstam<5 then cstam:=5;

    case ch of
     'E':begin
          case random(2) of
           0:begin
             sd(12,'Bullseye! Your elbow almost crushed');
             if male=true then sd(12,' his nose!')
                          else sd(12,' her nose!');
             crlf;
             cstam:=cstam-random(3);
             end;
           1: d(global_plycol,s^+config.textcol1+' managed to avoid your attack!');
          end;
         end;
     'S':begin
          case random(2) of
           0:begin
             sd(12,'Dynamite! '+uplc+s^+config.textcol1+' staggers from your unexpected attack!');
             cstam:=cstam-random(3);
             end;
           1: d(config.textcolor,uplc+s^+config.textcol1+' saw that one coming!');
          end;
         end;
     'T':begin
          case random(2) of
           0:begin
             sd(12,'Success! '+s^+' falls heavily to the floor!');
             cstam:=cstam-random(3);
             end;
           1: d(config.textcolor,s^+' managed to retreat from your assault!');
          end;
         end;
     'B':begin
          case random(2) of
           0:begin
             sd(global_plycol,s^+ulred+' screams loud when');
             if male=true then sd(12,' you get a bite of his ear!')
             else sd(12,' you get a bite of her ear!');
             crlf;
             cstam:=cstam-random(3);
             end;
           1: d(global_plycol,s^+ulred+' managed to avoid your clumsy attack!');
          end;
         end;
    end;

    if not escaped then begin
    repeat
     repeat
      ch:='?';

      rr^:=pstam / player.stamina;
      xx:=round(rr^*100);

      {d(commastr(pstam)+' / '+commastr(player.stamina));
      d(commastr(xx));}

      a^:='Excellent Health';
      if xx<100 then a^:='You have some small wounds and bruises';
      if xx<80 then a^:='You have some wounds';
      if xx<70 then a^:='You are pretty hurt!';
      if xx<50 then a^:='You are in bad shape!';
      if xx<30 then a^:='You have some BIG and NASTY wounds!';
      if xx<20 then a^:='You are in an awful condition!';
      if xx<5 then a^:='You are bleeding from wounds ALL over your body!';

      crlf;
      sd(3,'Your status : ');
      sd(12,a^);
      crlf;

      rr^:=cstam / cstammax;
      xx:=round(rr^*100);

      a^:='Excellent Health';
      if xx<100 then a^:='Small wounds and bruises';
      if xx<80 then a^:='Some wounds';
      if xx<70 then a^:='Pretty hurt!';
      if xx<50 then a^:='Bad shape!';
      if xx<30 then a^:='Some BIG and NASTY wounds!';
      if xx<20 then a^:='Awful condition!';
      if xx<5 then a^:='AWFUL CONDITION!';

      sd(global_plycol,s^+ucyan+' status : ');
      sd(12,a^);
      crlf; crlf;
      sd(config.textcolor,'Action ('+ulgreen+'?'+config.textcol1+' for moves) :');

      repeat
       ch:=upcase(getchar);
      until (ch in ['A'..'N']) or (ch='?');

      crlf;

      if ch='?' then begin
       crlf;
       for i:=1 to 14 do begin
        sd(5,chr(64+i));
        if length(bash_name(i))<>32 then begin
         a^:='                        ';
         x:=length(bash_name(i));
         x:=18-x;
         sd(config.textcolor,') ');
         sd(global_bashcol,bash_name(i)+copy(a^,1,x));
         sd(config.textcolor,bash_rank(player.skill[i]));
        end;
        crlf;
       end;
      end;
     until ch in ['A'..'N'];

     crlf;
     case ch of
     'A':begin
         crlf;
         d(config.textcolor,'Here goes...You take a run and charge '+uplc+s^+config.textcol1+' for a tackle!');
         if random(hitchance(player.skill[1]))<>0 then begin
          if male=true then d(global_plycol,s^+config.textcol1+' evades your attack! You stumble past him!')
          else d(global_plycol,s^+config.textcol1+' evades your attack! You stumble past her!');
         end
         else begin
          d(config.textcolor,'Your tackle hit '+uplc+s^+config.textcol1+' VERY hard!');
          d(global_plycol,s^+config.textcol1+' loses sense of all directions!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'B':begin
         d(config.textcolor,'BANZAI! You rush '+uplc+s^+config.textcol1+' and try a Drop-Kick!');
         if random(hitchance(player.skill[2]))<>0 then begin
          if male=true then d(global_plycol,s^+config.textcol1+' simply jumps aside, and you fly past him!')
          else d(global_plycol,s^+config.textcol1+' simply jumps aside, and you fly past her!');
         end
         else begin
          d(config.textcolor,'Your kick hit '+uplc+s^+config.textcol1+' hard!');
          if male=true then d(config.textcolor,'He goes down!')
          else d(config.textcolor,'She goes down!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'C':begin
         d(config.textcolor,'You try an uppercut against '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[3]))<>0 then begin
          d(global_plycol,s^+config.textcol1+' elegantly blocks your assault!');
         end
         else begin
          d(config.textcolor,'You hit '+uplc+s^+config.textcol1+' right on the chin!');
          if male=true then d(config.textcolor,'He goes down!')
          else d(config.textcolor,'She goes down!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'D':begin
         d(config.textcolor,'You throw yourself against '+uplc+s^+config.textcol1+' with a fearsome battlecry!');
         if random(hitchance(player.skill[4]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' elegantly avoids your clumsy assault!');
         end
         else begin
          if male=true then d(global_plycol,s^+config.textcol1+' screams in horror as you bite him hard!')
          else d(global_plycol,s^+config.textcol1+' screams in horror as you bite her hard!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'E':begin
         d(config.textcolor,'You try a Leg-Sweep against '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[5]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' manages to avoid the assault!');
          crlf;
         end
         else begin
          if male=true then d(global_plycol,s^+config.textcol1+' falls heavily to the floor as you sweep away his legs!')
          else d(global_plycol,s^+config.textcol1+' falls heavily to the floor as you sweep away her legs!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'F':begin
         d(config.textcolor,'You try to get a good grip on '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[6]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' blocks your attack!');
         end
         else begin
          if male=true then d(global_plycol,s^+config.textcol1+' screams in pain as you crack a bone in his body! Hehe!')
          else d(global_plycol,s^+config.textcol1+' screams in pain as you crack a bone in her body! Hehe!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'G':begin
         d(config.textcolor,'You let your right hand go off in an explosive stroke against '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[7]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' blocks your attack!');
         end
         else begin

          if male=true then d(global_plycol,s^+config.textcol1+' looks surprised when your punch hit him hard in the chest!')
          else d(global_plycol,s^+config.textcol1+' looks surprised when your punch hit her hard in the chest!');
          if male=true then d(config.textcolor,'He goes down to his knees, moaning!')
          else d(config.textcolor,'She goes down to her knees, moaning!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'H':begin
         d(config.textcolor,'You send off a stroke against your foe!');
         if random(hitchance(player.skill[8]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' avoids your attack with elegance!');
          d(config.textcolor,'Instead you collect a counterattack against your upper body!');
          cstam:=cstam-(random(4)+4);
         end
         else begin
          d(global_plycol,s^+config.textcol1+' is stunned from your effective punch!');
          if male=true then d(config.textcolor,'He goes down!')
          else d(config.textcolor,'She goes down!');
          cstam:=cstam-(random(4)+4);
          
         end;
         end;
     'I':begin
         d(config.textcolor,'You try to get your hands around '+uplc+s^+'s'+config.textcol1+' throat!');
         if random(hitchance(player.skill[9]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' takes a couple of ballet steps, and avoids your attack!');
         end
         else begin
          if male=true then d(global_plycol,s^+'''s'+config.textcol1+' face turns red when he chokes!')
          else d(global_plycol,s^+'''s'+config.textcol1+' face turns red when she chokes!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'J':begin
         d(config.textcolor,'You try a Headbash against '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[10]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' quickly takes a few steps back!');
         end
         else begin
          d(config.textcolor,'You hit '+uplc+s^+'''s'+config.textcol1+' head with a massive blow!');
          if male=true then d(config.textcolor,'He goes down bleeding from some nasty wounds!')
          else d(config.textcolor,'She goes down bleeding from some nasty wounds!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'K':begin
         d(config.textcolor,'You try to grab hold of '+uplc+s^+'''s'+config.textcol1+' hair!');
         if random(hitchance(player.skill[11]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' manages to evade your attack!');
         end
         else begin
          if male=true then d(config.textcolor,'You get a firm grip of his hair! You drag him around the room!')
          else d(config.textcolor,'You get a firm grip of her hair! You drag her around the room!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'L':begin
         d(config.textcolor,'You try a Kick against '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[12]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' blocks it!');
         end
         else begin
          if male=true then d(config.textcolor,'He staggers under your blow!')
          else d(config.textcolor,'She staggers under your blow!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'M':begin
         d(config.textcolor,'You try a Punch against '+uplc+s^+config.textcol1+'!');
         if random(hitchance(player.skill[13]))<>0 then begin
          d(config.textcolor,'But '+uplc+s^+config.textcol1+' blocks it!');
         end
         else begin
          if male=true then d(config.textcolor,'You hit him right on the chin! He is dazed!')
          else d(config.textcolor,'You hit her right on the chin! She is dazed!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     'N':begin
         d(config.textcolor,'You rush '+uplc+s^+config.textcol1+' with your head lowered!');
         if random(hitchance(player.skill[14]))<>0 then begin
          if male=true then d(config.textcolor,'But he manages to jump aside just before you reach him!')
          else d(config.textcolor,'But she manages to jump aside just before you reach her!');
         end
         else begin
          if male=true then d(config.textcolor,'You hit '+uplc+s^+config.textcol1+' right in Solar-Plexus!'
                              +' You send him flying!')
          else d(config.textcolor,'You hit '+uplc+s^+config.textcol1+' right in Solar-Plexus! You send her flying!');
          cstam:=cstam-(random(4)+4);
         end;
         end;
     end;

     {enemy move}
     x:=random(14)+1;
     if male=true then a2^:='He'
                  else a2^:='She';

     case x of
      1: d(config.textcolor,a2^+' tries to tackle you!');
      2: d(config.textcolor,a2^+' tries a drop-kick against you!');
      3: d(config.textcolor,a2^+' tries an uppercut against your head!');
      4: d(config.textcolor,a2^+' tries to bite you in the leg!');
      5: d(config.textcolor,a2^+' goes for a leg-sweep against you!');
      6: d(config.textcolor,a2^+' tries to break your arm!');
      7: d(config.textcolor,a2^+' sends off a Nifehand, aimed at your chest!');
      8: d(config.textcolor,a2^+' sends off a nervepunch!');
      9: d(config.textcolor,'The bastard tries to strangle you!');
      10: d(config.textcolor,a2^+' goes for a Headbash! Watch it!');
      11: d(config.textcolor,a2^+' tries to pull your hair!');
      12: d(config.textcolor,a2^+' goes for a kick, aimed at your body!');
      13: d(config.textcolor,a2^+' goes for a straight punch in your face!');
      14: d(config.textcolor,a2^+' comes rushing at you in high speed! RAM!');
     end; {case .end.}

     y:=1;
     if pstam>5 then y:=y+1;
     if (player.class=Assassin) or (player.class=Jester) then y:=y+1;
     if player.agility>50 then y:=y+1;
     if player.agility>200 then y:=y+1;
     if player.agility>700 then y:=y+1;
     if player.agility>1300 then y:=y+1;
     if player.level>50 then y:=y+1;
     if player.level>95 then y:=y+1;

     if random(y)<2 then begin
      d(config.textcolor,'You didn''t manage to evade!');
      
      case x of
       1:d(config.textcolor,'The hard tackle sends you across the floor! You lose your breath!');
       2:d(config.textcolor,'You stagger under the impact from the kick!');
       3:d(config.textcolor,'The stroke lands neately on your chin! You see stars and moons!');
       4:begin
          if male=true then d(config.textcolor,'His bite goes deep in your leg! You are bleeding!')
          else d(config.textcolor,'Her bite goes deep in your leg! You are bleeding!');
         end;
       5:d(config.textcolor,'You fall heavily to the floor!');
       6:d(config.textcolor,'Cracck... Something just broke in your body! You are hurt bad!');
       7:begin
          if male=true then d(config.textcolor,'You lose your breath when his steelhand goes right in your chest!')
          else d(config.textcolor,'You lose your breath when her steelhand goes right in your chest!');
         end;
       8:d(config.textcolor,'The stroke hits a nerve! You are stunned!');
       9:begin
          if male=true then d(config.textcolor,'He got you in a chokehold! You can''t breathe!')
          else d(config.textcolor,'She got you in a chokehold! You can''t breathe!');
         end;
       10:d(config.textcolor,'BONK! You are feeling dizzy! Your head aches!');
       11:d(config.textcolor,'Arrgghhh! That really hurt! What a dirty trick!');
       12:d(config.textcolor,'The well-placed kick lands right in solar-plexus! Ouch!');
       13:d(config.textcolor,'The punch lands right on your nose! You lose sense of all directions!');
       14:begin
           if male=true then d(config.textcolor,'His attack sends you sprawling! You fall to the floor!')
           else d(config.textcolor,'Her attack sends you sprawling! You fall to the floor!');
          end;
      end;
      pstam:=pstam-(random(6)+4);

     end;

     {fusk}
     {d(15,commastr(pstam));
     d(15,commastr(cstam));}

    until (pstam<=0) or (cstam<=0);

    if pstam<=0 then begin
     d(config.textcolor,'Your head starts to spin, and you feel darkness...');
     d(config.textcolor,'All your strength is gone!');
     d(config.textcolor,'Before you slide into unconsciousness you feel how you are being');
     d(config.textcolor,'frisked...');
     crlf;

     case random(2) of
      0:begin
         newsy(true,
         'Dork',
         ' '+uplc+player.name2+config.textcol1+' tried to show off at '+config.bobsplace+'.',
         ' '+sex2[player.sex]+' was knocked out after a short fight against '+uplc+s^+config.textcol1+', the '+ts^+'.',
         '',
         '',
         '',
         '',
         '',
         '',
         '');
        end;
      1:begin
         newsy(true,
         'Brawl at '+config.bobsplace+'!',
         ' '+uplc+player.name2+config.textcol1+' accepted a challenge in '+config.bobsplace+'.',
         ' The violence ended when '+uplc+player.name2+config.textcol1+' was knocked out',
         ' by '+uplc+s^+config.textcol1+', the '+ts^+'.',
         '',
         '',
         '',
         '',
         '',
         '');
        end;
     end;
     player.gold:=0;
     pause;

     post(MailSend,
     player.name2,
     player.ai,
     false,
     mailrequest_nothing,
     '',
     umailheadc+'Defeat!'+config.textcol1,
     mkstring(7,underscore),
     'You were knocked out in '+config.bobsplace+'!',
     'Better train some more before starting a brawl!',
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

     normal_exit;

    end
    else begin
     crlf;d(14,'Victory!');
     d(config.textcolor,'You have defeated '+s^+'!');
     sd(config.textcolor,'You frisk your foe and find ');
     sd(14,commastr(reward));
     sd(config.textcolor,' '+many_money(reward)+'!');crlf;

     xx:=player.level*(random(60)+10);
     sd(config.textcolor,'You also receive ');
     sd(14,commastr(xx));
     sd(config.textcolor,' experience points!');
     crlf; 
     incplayermoney(player,reward);
     player.exp:=player.exp+xx;

     newsy(true,
     'Fistfighter!',
     ' '+uplc+player.name2+config.textcol1+' fought a staggering battle at '+config.bobsplace+'.',
     ' It turned out to be a new victory in '+sex3[player.sex]+' promising career!',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     pause;
    end;
end
   end
   else begin
    crlf;
    d(5,'You leave things as they are...');
    d(5,'Wise perhaps, but not very brave.');
    if player.charisma>5 then player.charisma:=player.charisma-random(3);
    pause;
   end;
   crlf;
  end;

  if onliner.location<>onloc_bobsbeer then begin
   refresh:=true;
   onliner.location :=onloc_bobsbeer;
   onliner.doing    :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  display_menu(true,true);

  ch:=upcase(getchar);

  case ch of
   '?':begin
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin
       clearscreen;
       status(player);
       end;
   'D':begin
        crlf; crlf;
        d(5,'You strut your stuff!');
        d(config.textcolor,'Many adventurers look your way.');
        d(config.textcolor,'They don''t seem to appreciate your performance!');
        d(config.textcolor,'You are being ridiculed!');
        crlf;
        pause;
       end;
   'T':begin
       if player.thiefs<1 then begin
        d(5,'You have tried enough for today.');
       end
       else begin
        y:=10;
        if player.class=Assassin then y:=y-1;
        if player.dex>10 then dec(y);
        if player.dex>20 then dec(y);
        if player.dex>40 then dec(y);
        if player.dex>80 then dec(y);
        if player.dex>140 then dec(y);
        if player.dex>260 then dec(y);
if player.dex>400 then dec(y);
        if player.dex>500 then dec(y);
        if player.dex>650 then dec(y);

        s^:='Master Thief!';
        case y of
         0: s^:='Master Thief';
         1: s^:='Extremely Good!';
         2: s^:='Skilled Pick-Pocket';
         3: s^:='Pick Pocket';
         4: s^:='Very Good';
         5: s^:='Good';
         6: s^:='Pretty Good';
         7: s^:='Average';
         8: s^:='Poor';
         9: s^:='Bad';
        10: s^:='Worthless';
        end;
        crlf;
        sd(config.textcolor,'Your thieving skill is ');
        sd(14,s^);
        crlf;

        if confirm('Do you dare to attempt thievery in here','n')=true then begin

         player.thiefs:=player.thiefs-1;
         if (y=0) or (random(y)=0) then begin
          xx:=random(3000)+500;
          xx:=xx*player.level;
          incplayermoney(player,xx);
          d(config.textcolor,'Success! You managed to steal '+commastr(xx)+' '+many_money(xx)+'!');
          crlf;
          pause;
         end
         else begin
          d(config.textcolor,'Failure!! Your clumsy attempt was detected!');
          if random(5)=0 then begin
           d(config.textcolor,'You were caught! You must spend the night in jail!');
           d(config.textcolor,'Come back tomorrow.');
           crlf;

           newsy(true,
           'Thief Caught!',
           ' '+uplc+player.name2+config.textcol1+' was caught stealing!',
           ' '+uplc+player.name2+config.textcol1+' was thrown in jail!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {player.allowed:=false;}
           Reduce_Player_Resurrections(player,true);
           pause;
           normal_exit;
          end
          else begin
           d(config.textcolor,'You managed to escape!');
           crlf;
           pause;
          end;
         end;
        end;
       end;
       end;
   'B':begin {slagsm†l! BRAWL!}
        if player.brawls<1 then begin
         crlf;
         d(5,'You are too exhausted!');
         crlf;
        end
        else begin
         crlf;
         if confirm('Start a fight ','n')=true then begin
          brawl;
         end;
        end;

       end;
   'C':begin {drinking competition}

        if player.chivnr<1 then begin
         crlf;
         d(12,'You are too exhausted!');
         pause;
         break;
        end;

        crlf;
        crlf;

        if confirm('Initiate a Beerdrinking contest','N')=true then begin
         dec(player.chivnr);
         drinking_competition;
        end;

       end;

  end; {case .end.}

 until ch='R';
 crlf;

 {dispose pointer variables}
 dispose(rr);
 dispose(a);
 dispose(a2);
 dispose(s);
 dispose(ts);
 dispose(ok);
 dispose(no);

end; {Bobs_Inn *end*}

end. {Unit Bobs .end.}
