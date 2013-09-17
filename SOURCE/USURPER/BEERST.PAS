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


Unit BeerSt; {Usurper - Stealing Beer Barrels}

Interface

Procedure Beer_Stealing; {Stealing beer barrels}

Implementation

Uses Init, Cms, Jakob,
     Statusc, Mail, News,
     Various, Various2, Various3,
     Online, File_Io, SysUtils;

var
    ch : char;
    xx, yy, cost, stolen : longint;
    capable, knockdogs, knocksons, target, pstam, poor, risk : integer;
    arrived, turbo : boolean;
    i : longint;
    cstam, newdogs, dogoffset, barrels, dogs : integer;

    s, s2, polare : s70;

    doggy : array [1..40] of s15;

    refresh,
    male, npc : boolean;

    son      : array [1..10] of s30;
    sonstam  : array [1..10] of integer;
    sonarriv : array [1..10] of boolean;

    pl0      : ^UserRec;

Procedure Disposal;
begin
 dispose(pl0);
end; {disposal *end*}

Procedure Meny;
begin
 turbo:=false;
 arrived:=false;
 polare:='';

 clearscreen;
 crlf;
 d(5,'-*- Stealing '+config.innkeeper+'s Beer -*-');
 crlf;
 d(config.textcolor,'You must try to carry off with as much Beer as possible from');
 d(config.textcolor,config.innkeeper+'s Inn without being noticed.');
 crlf;

 menu('(G)o and steal some barrels');
 menu('(S)tatus');
 menu('(R)eturn from crime scene');
end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'G',
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
   sd(config.textcolor,'Stealing (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin
   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,'Stealing (G,R,S,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Function Orkar(styrka : word) : word; {how many barrels can player lift}
var
   n : word;
begin

 n:=1;

 if styrka>5  then inc(n);
 if styrka>10 then inc(n);
 if styrka>15 then inc(n);

 if styrka>75  then inc(n);
 if styrka>150 then inc(n);
 if styrka>250 then inc(n);
 if styrka>350 then inc(n);
 if styrka>450 then inc(n);
 if styrka>550 then inc(n);
 if styrka>650 then inc(n);
 if styrka>750 then inc(n);
 if styrka>850 then inc(n);
 if styrka>950 then inc(n);

 orkar:=n;

end; {orkar *end*}

Procedure Init_Names;
begin
new(pl0);
  son[1]:='Tim'; son[2]:='Dim'; son[3]:='Kim';
 son[4]:='Tom'; son[5]:='Bim'; son[6]:='Jim';
 son[7]:='Gum'; son[8]:='Nim'; son[9]:='Nippe';
 son[10]:='Ola';

 doggy[1]:='Dallas';  doggy[2]:='Pluto';    doggy[3]:='Biff';
 doggy[4]:='Moon';    doggy[5]:='Bert';     doggy[6]:='Mimi';
 doggy[7]:='Patrick'; doggy[8]:='Djenghis'; doggy[9]:='Alex';
 doggy[10]:='Blood';  doggy[11]:='Nixon';   doggy[12]:='Geronimo';
 doggy[13]:='Bull';   doggy[14]:='Stomp';   doggy[15]:='Tina';
 doggy[16]:='Epstein';doggy[17]:='Bart';    doggy[18]:='Ivan';
 doggy[19]:='Thunder';doggy[20]:='Crimson'; doggy[21]:='Raistlin';
 doggy[22]:='Lord';   doggy[23]:='Satan';   doggy[24]:='Nick';
 doggy[25]:='Pharao'; doggy[26]:='Chill';   doggy[27]:='Rex';
 doggy[28]:='Sputnik';doggy[29]:='Hooly';   doggy[30]:='Ymer';
 doggy[31]:='Rutger'; doggy[32]:='Sam';     doggy[33]:='Moongrowl';
 doggy[34]:='Nina';   doggy[35]:='Gully';   doggy[36]:='Torpedo';
 doggy[37]:='Zing';   doggy[38]:='Bokaj';   doggy[39]:='Hades';
 doggy[40]:='Revelation';

end; {init_Names_Stam *end*}

procedure Prep_Steal;
begin
knockdogs:=0;
 knocksons:=0;

 for i:=1 to 10 do begin
  sonarriv[i]:=false;
 end;

 
 

 for i:=1 to 39 do begin
  s2:=doggy[i];
  xx:=i+random(40-i);
  doggy[i]:=doggy[xx];
  doggy[xx]:=s2;
 end;

 for i:=1 to 9 do begin
  s2:=son[i];
  xx:=i+random(10 - i);
  son[i]:=son[xx];
  son[xx]:=s2;
 end; {for i:= .end.}

 sonstam[1]:=15; sonstam[2]:=20; sonstam[3]:=30;
 sonstam[4]:=40; sonstam[5]:=50; sonstam[6]:=55;
 sonstam[7]:=60; sonstam[8]:=70; sonstam[9]:=10;
 sonstam[10]:=100;

end;


Procedure Beer_Stealing;

procedure solo_dogs_news;
                         begin
                         newsy(true,
                         'Burglary Attempt!',
                         ' '+uplc+player.name2+config.textcol1+' tried to steal Beer from the Inn!',
                         ' Fortunately, a bunch of watchdogs took care of the thief!',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '');
end;

procedure run_away;
begin
                       sd(15,'RUN!');
                       crlf;
                       d(config.textcolor,'You run for your life!!!');
                       sd(4,'BUT THE DOGS ARE AFTER YOU!...');
                       Sleep(600);
                       sd(4,'.....');
                       Sleep(600);
                       crlf;
                       crlf;
                       d(config.textcolor,'You managed to get away!');
                       s:='';
                       if poor>0 then begin
                        d(config.textcolor,'But in the distance you can hear '+uplc+polare+'s'+config.textcol1
                          +' terrifying screams!');
                        d(config.textcolor,'The dogs probably got hold of something...');
                        s:=' Poor '+uplc+polare+config.textcol1+' was left behind, chased by another bunch of dogs!';
                       end;
                       crlf;
                      
                       newsy(true,
                       'Burglary Attempt!',
                       ' '+uplc+player.name2+config.textcol1+' tried to steal Beer from the Inn!',
                       ' '+uplc+player.name2+config.textcol1+' fled in panic, chased by a bunch of watchdogs!',
                       s,
                       '',
                       '',
                       '',
                       '',
                       '',
                       '');

                       pause;
                       end;
                       
procedure battle_dogs;
begin
pstam:=player.stamina;
risk:=2;
                       if (player.classid=Assassin) or (player.classid=Jester) then risk:=risk+2;
                       if player.agility>10 then inc(risk);
                       if player.agility>20 then inc(risk);
                       if player.agility>30 then inc(risk);
                       if player.agility>50 then inc(risk);
                       if player.agility>70 then inc(risk);
                       if player.agility>90 then inc(risk);

                       repeat
                        pause;

                        if random(2)=0 then begin
                         d(4,'HIT! You managed to knock one out!');
                         
                         dec(dogs);
                         inc(knockdogs);
                        end;

                        if dogs>0 then begin
                         for i:=1 to dogs do begin
                          sd(3,doggy[i]);
                          case random(3) of
                           0: sd(config.textcolor,' tries to bite you!');
                           1: sd(config.textcolor,' charges you!');
                           2: sd(config.textcolor,' takes a jump at you!');
                          end;
                          crlf;
                          if random(risk)=0 then begin
                           case random(2) of
                            0: d(4,'And you didn''t manage to get away!');
                            1: d(4,'ARGH! That damn dog is glued to your leg!');
                           end;
                           dec(pstam);
                          end;
                         end;
                        end;
                       until (dogs<1) or (pstam<1);
end;


begin
 Init_Names;
 repeat

    if onliner.location<>onloc_outsideinn then begin
   refresh:=true;
   onliner.location:=onloc_outsideinn;
   onliner.doing:=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  display_menu(true,true);

  ch:=upcase(getchar);

  case ch of
   '?':begin {menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'G':begin {steal barrels}

         {update online location}
         onliner.location:=onloc_onaraid;
         onliner.doing   :=location_desc(onliner.location);
         add_onliner(OUpdateLocation,Onliner);

        
        if player.darknr<1 then begin
         crlf;
         {no dark deeds left}
         no_dark_deeds;
         pause;
        end
        else begin
          dogs:=random(2)+5;
          if player.level>10 then dogs:=dogs+random(5)+2;
          if player.level>20 then dogs:=dogs+random(5)+2;
          if player.level>30 then dogs:=dogs+random(5)+2;
          if player.level>40 then dogs:=dogs+random(5)+2;
          if player.level>50 then dogs:=dogs+random(5)+2;
          if player.level>60 then dogs:=dogs+random(5)+2;
          if player.level>70 then dogs:=dogs+random(5)+2;

          if dogs>40 then dogs:=40;

          dec(player.darknr);

          crlf;
          crlf;
          d(5,'Theft Preparations');
          d(config.textcolor,'How will you prepare for this burglary ?');

          ch:='?';
          repeat
           if ch='?' then begin
            menu('(1) Bring a teammate');
            menu('(2) Buy some bones for the watchdogs');
            menu('(3) Bring a wooden club (the cheap alternative)');
            menu('(4) Help!');
            menu('(0) Abort');
            sd(config.textcolor,':');
           end;

           repeat
            ch:=upcase(getchar);
           until ch in ['1','2','3','4','0'];
           crlf;

           if ch='0' then begin
            inc(player.darknr); {didn't use after all}
            
            exit;
           end;

           if (ch='1') and (player.team='') then begin
            d(12,'But you are not in a team!');
            pause;
            ch:='?';
           end;

           if ch='4' then begin
            crlf;
            d(11,'Help - Thievery at the Inn');
            d(10,'The first problem that you will encounter when');
            d(10,'you raid the Inn is the watchdogs.');
            d(10,'You can choose to either bring a teammate along,');
            d(10,'or do the job yourself.');
            d(10,'Your teammate''s job will be to distract the watchdogs.');
            d(10,'This is a nice and quite safe option, but');
            d(10,'you must share your loot with your mate...');
            d(10,'So, if you are greedy you can go alone, but you might');
            d(10,'want to bring the dogs some fresh bones.');
            crlf;
            pause;
            d(10,'If you don''t want to have any expenditures at all,');
            d(10,'then you can choose to bring a club instead of bones.');
            d(10,'You may be able to knock all dogs out before they can make');
            d(10,'any significant noise! THIS IS EXTREMELY RISKY!');
            d(10,'(However, you receive experience for every dog you knock out)');
            crlf;
            d(10,'If you make it past the dogs, you then get a chance');
            d(10,'to load the beer-barrels on to your cart.');
            d(10,'The more barrels you can bring on, the more profit you make.');
            d(10,'But the risk for getting caught increases for every barrel');
            d(10,'you carry!');
            crlf;
            d(10,'Don''t let your greed get you caught!');
            
            pause;
            ch:='?';
           end;

           Prep_Steal;
           
           if ch='2' then begin
            ch:='?';
            crlf;
            d(5,'Buy some Bones');
            cost:=dogs*350;
            sd(config.textcolor,'You have ');
            sd(14,commastr(player.gold));
            sd(config.textcolor,' '+many_money(player.gold)+'.');
            crlf;

            d(config.textcolor,'You need '+commastr(dogs)+' bones');
            d(config.textcolor,'Each bone costs 350 '+many_money(350)+'.');
            sd(config.textcolor,'Total cost of the bones is ');
            sd(14,commastr(cost));
            sd(config.textcolor,' '+many_money(cost)+'.');
            crlf;
            if player.gold<cost then begin
             crlf;
             d(config.textcolor,'And you don''t have that kind of '+config.moneytype+'!');
             crlf;
             pause;
            end
            else begin
             if confirm('Buy Bones ','N')=true then begin
              decplayermoney(player,cost);
              ch:='2';
             end;
            end;
           end;

           if ch='1' then begin
            polare:='';
            for i:=1 to fs(FsPlayer) do begin
             load_character(pl0^,1,i);

             if (pl0^.name2<>'') and
                (pl0^.name2<>global_delname2) and
                (pl0^.deleted=false) and
                (pl0^.name2<>player.name2) and
                (pl0^.team<>'') and
                (pl0^.team=player.team) and
                (pl0^.hps>0) and
                (pl0^.allowed=true) and
                (pl0^.location<>offloc_prison) and
                (is_online(pl0^.name2,online_player)=false) then begin

              sd(global_plycol,pl0^.name2);
              if confirm(' ','n')=true then begin

               if add_shadow(SAdd,pl0^,player.name2,'stealing beer barrels',0)=false then begin
                {unable to add pl0}
                d(global_plycol,pl0^.name2+config.textcol1+' is busy right now!');
                pause;
               end
               else begin

                polare:=pl0^.name2;
                npc:=false;
                break;
               end;

              end;
             end;
            end;

            if polare='' then begin
             for i:=1 to fs(FsNpc) do begin
              load_character(pl0^,2,i);

              if (pl0^.name2<>'') and
                 (pl0^.name2<>global_delname2) and
                 (pl0^.deleted=false) and
                 (pl0^.name2<>player.name2) and
                 (pl0^.team=player.team) and
                 (pl0^.team<>'') and
                 (pl0^.hps>0) and
                 (pl0^.allowed=true) and
                 (pl0^.location<>offloc_prison) and

                 (is_online(pl0^.name2,online_player)=false) then begin

               sd(global_plycol,pl0^.name2);
               if confirm(' ','n')=true then begin
                if add_shadow(SAdd,pl0^,player.name2,'stealing beer barrels',0)=false then begin
                 {unable to add pl0}
                 d(global_plycol,pl0^.name2+config.textcol1+' is busy right now!');
                 pause;
                end
                else begin
                 polare:=pl0^.name2;
                 npc:=true;
                 
                 break;
                end;

               end;
              end;
             end;
            end;

            if polare<>'' then begin
            if pl0^.sex=1 then male:=true
                               else male:=false;
                 cstam:=pl0^.stamina;
                  
             ch:='1';
             dogs:=dogs*2;
             if dogs>40 then begin
              dogs:=40;
             end;
            end
            else begin
d(config.textcolor,'No teammate found!');; crlf;

             ch:='?';
            end;
           end;

          until ch in ['1','2','3'];

          crlf;
          poor:=0;
          case ch of
           '1':begin
                d(config.textcolor,'Late at night, you and '+uplc+polare+config.textcol1+
                                   ' sneak up behind the Inn''s storage');
                d(config.textcolor,'room. There are '+commastr(dogs)+' dogs in the yard, watching everything');
                d(config.textcolor,'that moves...');
                d(config.textcolor,'They look mean and dangerous, capable of tearing you apart in a few seconds.');
                crlf;
                pause;
                d(global_plycol,polare+config.textcol1+' sneaks up to the main entrance to distract the dogs,');
                d(config.textcolor,'so you can start to steal the barrels...');
                crlf;
                pause;
                d(global_plycol,polare+config.textcol1+' is quite frightened...');
                                crlf;
                pause;
                crlf;
                turbo:=true;
                for i:=1 to dogs do begin
                 sd(3,doggy[i]);
                 sd(config.textcolor,' watches '+uplc+polare+config.textcol1+'...');

                 Sleep(500);
                 if random(3)=0 then begin
                  if male=true then sd(4,' but ignores him!')
                               else sd(4,' but ignores her!');

                 end
                 else begin
                  if male=true then sd(14,' and runs after him!')
                               else sd(14,' and runs after her!');
                  inc(poor);
                  dec(dogs);
                 end;
                 crlf;
                end;
                crlf;
                crlf;
                pause;

                if dogs>0 then begin
                 if dogs>1 then d(config.textcolor,'You are still facing '+uwhite+commastr(dogs)+config.textcol1
                                  +' angry dogs!')
                           else  d(config.textcolor,'You are still facing '+uwhite+commastr(dogs)+config.textcol1
                                   +' angry dog!');
                 crlf;
                 menu('(R)un for your life!');
                 menu('(F)ight it out with the dogs!');
                 sd(config.textcolor,':');
                 repeat
                  ch:=upcase(getchar);
                 until ch in ['R','F'];

                 case ch of
                  'R':begin
                       run_away;
                       break;
                      end;
                  'F':begin
                       sd(15,'I AIN''T AFRAID OF NO DOGS!');
                       crlf;
                       battle_dogs;
                       if pstam<1 then begin
                        crlf;
                        d(4,'You are too exhausted to struggle any more!!');
                        d(4,'You fade away into the darkness...listening to');
                        d(4,'the dogs barking...');

                        if turbo=false then solo_dogs_news
                                                else begin
                         newsy(true,
                         'Burglary Attempt!',
                         ' '+uplc+player.name2+config.textcol1+' and '+uplc+polare+config.textcol1
                            +' tried to steal Beer from the Inn!',
                         ' Fortunately, a bunch of watchdogs took care of '+uplc+player.name2+config.textcol1+'.',
                         ' '+uplc+polare+config.textcol1+' fled, and got away.',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '');
                        end;
{player.allowed:=false;}
                        player.hps:=0;
                        Reduce_Player_Resurrections(player,true);

                       crlf;
                        crlf;
                        pause;

                        disposal;
                        normal_exit;
                       end
                       else begin
                        crlf;
                        crlf;
                        d(14,'VICTORY!');
                        d(config.textcolor,'You managed to knock the dogs out!');
                        d(config.textcolor,'Let''s continue...');

                        crlf;
                        crlf;
                        pause;
                       end;
                      end;
                 end;
                 pause;
                end
                else begin
                 crlf;
                 d(config.textcolor,'The coast is clear! LET''S STEAL!');
                 crlf;
                 pause;
                end;
               end;
           '2':begin
                d(config.textcolor,'Late at night, you sneak up behind the Inn''s storage room.');
                d(config.textcolor,'There are '+commastr(dogs)+' dogs in the yard, watching closely');
                d(config.textcolor,'every stranger. You take the bones out from your bag...');
                crlf;
                pause;
                d(config.textcolor,'You throw the bones into the yard, where the dogs are...');
                crlf;
                pause;
                for i:=1 to dogs do begin
                 sd(3,doggy[i]);
                 sd(config.textcolor,' sniffs...');
                 Sleep(600);
                 if random(3)=0 then begin
                  sd(4,' but ignores the bones!');
                 end
                 else begin
                  sd(14,' and chews on a bone!');
                  dec(dogs);
                 end;
                 crlf;
                end;
                crlf;
                crlf;
                pause;
                if dogs>0 then begin
                 if dogs>1 then d(config.textcolor,'You are still facing '+commastr(dogs)+' angry dogs!')
                           else  d(config.textcolor,'You are still facing '+commastr(dogs)+' angry dog!');
                 crlf;
                 menu('(R)un for your life!');
                 menu('(F)ight it out with the dogs!');
                 sd(config.textcolor,':');
                 repeat
                  ch:=upcase(getchar);
                 until (ch='R') or (ch='F');
                 crlf;
                 case ch of
                  'R':begin
                       run_away;
                       break;
                      end;
                  'F':begin
                       sd(15,'WHO''S AFRAID OF PUPPYS!');
                       crlf;
                       battle_dogs;
                       if pstam<1 then begin
                        crlf;
                        d(4,'You are too exhausted to struggle any more!!');
                        d(4,'You fade away into the darkness...listening to');
                        d(4,'the dogs barking...');
solo_dogs_news;
                        {player.allowed:=false;}
                        player.hps:=0;
                        Reduce_Player_Resurrections(player,true);

                        disposal;
                        crlf;
                        crlf;
                        pause;
                        normal_exit;
                       end
                       else begin
                        crlf;
                        crlf;
                        d(14,'VICTORY!');
                        d(config.textcolor,'You managed to knock the dogs out!');
                        d(config.textcolor,'Let''s continue...');

                        crlf;
                        crlf;
                        pause;
                       end;
                      end;
                     end;
                     pause;
                    end;
               end;
           '3':begin
                d(config.textcolor,'Late at night, you sneak up behind the Inn''s storage room.');
                d(config.textcolor,'There are '+commastr(dogs)+' dogs in the yard, watching closely');
                d(config.textcolor,'every stranger. You get a close grip on your club...');
                crlf;
                pause;
                d(5,'YOU RUSH THE DOGS WITH YOUR CLUB HELD HIGH!');
                crlf;
                for i:=1 to dogs do begin
                 d(4,doggy[i]+' is watching you angrily!');
                end;

                crlf;
                pause;
                battle_dogs;
                if pstam<1 then begin
                 crlf;
                 d(4,'You are too exhausted to struggle any more!!');
                 d(4,'You fade away into the darkness...listening to');
                 d(4,'the dogs barking...');

                 {news-paper}
                 solo_dogs_news;
                 {player.allowed:=false;}
                 player.hps:=0;
                 Reduce_Player_Resurrections(player,true);
                 disposal;

                 crlf;
                 crlf;
                 pause;
                 normal_exit;
                end
                else begin
                 crlf;
                 crlf;
                 d(14,'VICTORY!');
                 d(config.textcolor,'You managed to knock the dogs out!');
                 d(config.textcolor,'Let''s continue!');
                 crlf;
                 crlf;
                 pause;
                end;
               end;
          end;

          {the saga continues}
          crlf;
          barrels:=(player.level*5)+(random(10));
          if polare<>'' then barrels:=barrels+random(20);

          d(config.textcolor,'You sneak in to the Storage Room. There are '+uwhite+commastr(barrels)+config.textcol1
            +' barrels in here!');

          xx:=0;
          newdogs:=0;
          dogoffset:=0;
          stolen:=0;
          repeat
           inc(xx);
           if (random(2)=0) and (poor>0) then begin
            d(config.textcolor,'You can hear distant barking in the night...');
            if (arrived=true) and (cstam>0) then begin
             d(global_plycol,polare+config.textcol1+' looks a bit afraid!');
            end;
           end;
           if (xx=1) and (turbo=true) and (arrived=true) then begin
            d(global_plycol,polare+config.textcol1+' is standing beside you, eager to steal some barrels!');
           end;
           if (cstam>0) and (arrived=false) and (turbo=true) and (poor>0) and (xx>7) and (random(2)=0) then begin
            crlf;
            d(global_plycol,polare+config.textcol1+' has arrived, looking rather tired.');
            d(global_talkcol,'I finally managed to lose those dogs!');
            crlf;
            pause;
            arrived:=true;
           end;
           if (turbo=true) and (arrived=false) and (poor>0) and (xx>7) and (random(3)=0) then begin
            d(config.textcolor,'In the distance you can hear a terrifying scream!');
            dec(cstam,3);
            crlf;
            pause;
            if cstam<1 then turbo:=false;
           end;
           crlf;
           sd(5,'You have stolen ');
           sd(3,commastr(stolen));
           sd(5,' barrels so far (');
           sd(3,commastr(barrels));
           sd(5,' barrels left)');
           crlf;

           if pstam<10 then d(4,'You should flee!')
                       else d(4,'You are in good health.');

           if arrived=true then begin
            if (cstam<10) and (cstam>0) then begin
             d(global_plycol,polare+ured+' is in BAD SHAPE!')
            end
            else if cstam>=10 then begin
             d(global_plycol,polare+ured+' is in good health.');
            end
            else begin
             d(global_plycol,polare+'s'+ured+' mutilated body is laying on the ground.');
            end;
            if (cstam<5) and (cstam>0) and (random(4)=0) then begin
             sd(global_talkcol,'Lets get out of here!'+config.textcol1+', ');
             sd(config.textcolor,', '+uplc+polare+config.textcol1+' screams!');
             crlf;
            end;
           end;

           menu('(G)rab some barrels');
           menu('(F)lee with the loot');
           sd(config.textcolor,':');

           repeat
            ch:=upcase(getchar);
           until ch in ['G','F'];
           crlf;

           if ch='G' then begin
            capable:=orkar(player.strength);

            if capable>barrels then begin
             capable:=barrels;
            end;

            if capable=1 then begin
             d(config.textcolor,'You grab a barrel and place it in the cart.');
            end
            else begin
             sd(config.textcolor,'You grab ');
             sd(5,commastr(capable));
             d(config.textcolor,' barrels and place them in the cart.');
            end;

            dec(barrels,capable);
            inc(stolen,capable);

            if (arrived=true) and (cstam>0) and (barrels>0) then begin

             capable:=orkar(pl0^.strength);
             if capable>barrels then begin
              capable:=barrels;
             end;

             if capable>1 then begin
              d(global_plycol,polare+config.textcol1+' grabs '+uwhite+commastr(capable)+config.textcol1
                +' barrels and places them in the cart.');
             end
             else begin
              d(global_plycol,polare+config.textcol1+' grabs a barrel and places it in the cart.');
             end;

             dec(barrels,capable);
             inc(stolen,capable);
            end;
            case random(3) of
             0: d(config.textcolor,'PHEW! Your back hurt!');
             1: d(config.textcolor,'That was heavy!');
             2: d(config.textcolor,'Another one?');
            end;
            inc(xx);
            crlf;
            pause;
           end;

           if (xx>5) and (random(4)=0) then begin
            {a son arrives...}
            for i:=1 to 10 do begin
             if sonarriv[i]=false then begin
              sonarriv[i]:=true;
              d(config.textcolor,'Suddenly You hear someone coming out from the house!');
              sd(4,'OH NO! It''s ');
              sd(3,son[i]);
              sd(4,', one of '+config.innkeeper+'''s sons!');
              crlf;
              d(4,'My God! He looks ANGRY!');
              pause;
              break;
             end;
            end;
           end;

           if (xx>3) and (random(3)=0) and (poor>0) then begin
            {a dog arrives}
            inc(newdogs);
            dec(poor);
            sd(config.textcolor,'You hear barking....');
            Sleep(600);
            sd(config.textcolor,'....');
            sd(config.textcolor,'it''s coming closer!...');
            Sleep(700);
            sd(config.textcolor,'....');
            crlf;
            d(4,'OH NO! A dog has returned!');
           end;

           {s”nerna sl†r till!}
           for i:=1 to 10 do begin
            target:=1;
            if (sonarriv[i]=true) and (sonstam[i]>0) then begin
             if (cstam<1) or (polare='') then begin
              sd(3,son[i]+' attacks You... ');
             end
             else begin
              if random(2)=0 then begin
               sd(3,son[i]+' attacks You... ');
              end
              else begin
               sd(3,son[i]+' attacks '+uplc+polare+ucyan+'... ');
               target:=2;
              end;
             end;
             Sleep(600);
             if random(3)=0 then begin
              sd(4,'and hits!');
              case target of
               1: dec(pstam);
               2: dec(cstam);
              end;
             end
             else begin
              sd(3,'But misses!');
             end;
             crlf;
            end;
           end;

           {nytillkomna hundar sl†r till}
           if newdogs>0 then begin
            for i:=dogoffset+1 to dogoffset+newdogs do begin
             sd(config.textcolor,doggy[i]+' attacks... ');
             Sleep(600);
             if (arrived=true) and (cstam>0) then begin
              case random(2) of
               0:begin
                  sd(config.textcolor,'You!');
                  crlf;
                  if random(2)=0 then begin
                   d(12,'Ouch! That hurt!');
                   dec(pstam,2);
                  end
                  else begin
                   d(12,doggy[i]+' missed!');
                  end;
                 end;
               1:begin
                  sd(global_plycol,polare+config.textcol1+'!');
                  crlf;
                  if random(2)=0 then begin
                   d(12,polare+' was bitten!');
                   dec(cstam,2);
                   if cstam<1 then d(12,polare+' IS LAYING STUNNED ON THE GROUND!');
                  end
                  else begin
                   d(14,polare+' managed to avoid the attack!');
                  end;
                 end;
              end;
             end
             else begin
              sd(config.textcolor,'You!');
              crlf;
              if random(2)=0 then begin
               d(12,'Ouch! That hurt!');
               dec(pstam);
              end
              else begin
               d(12,doggy[i]+' missed!');
              end;
             end;
            end;
           end;

           {spelare f†r m”jlighet att sl† mot jyckar}
           if (newdogs>0) and (pstam>0) then begin
            if (arrived=true) and (cstam>0) then begin
             sd(global_plycol,polare+config.textcol1+' attacks a dog!....');
             Sleep(600);
             if random(2)=0 then begin
              sd(4,'But misses!');
             end
             else begin
              sd(4,'And Hits! The dog goes down!');
              dec(newdogs);
              inc(knockdogs);
              inc(dogoffset);
             end;
             crlf;
           end;
           if newdogs>0 then begin
            sd(config.textcolor,'You charge a dog!....');
            Sleep(600);
            if random(2)=0 then begin
             sd(4,'But miss!');
            end
            else begin
             sd(4,'Hit! The dog goes down!');
             dec(newdogs);
             inc(dogoffset);
             inc(knockdogs);
            end;
            crlf;
           end;
          end;

          {spelare f†r m”jlighet att sl† s”ner}
          if pstam>0 then begin
           for i:=1 to 10 do begin
            if (sonstam[i]>0) and (sonarriv[i]=true) then begin
             sd(config.textcolor,'You charge '+son[i]+'!...');
             Sleep(500);
             if random(2)=0 then begin
              sd(4,'And hit!');
              dec(sonstam[i],2);
             end
             else begin
              sd(config.textcolor,'But miss!');
             end;
             crlf;
             if sonstam[i]<1 then begin
              d(15,'He goes down!');
              inc(knocksons);
             end;
             break;
            end;
           end;
          end;

          {polare kan sl† om han lever}
          if (cstam>0) and (arrived=true) then begin
           for i:=1 to 10 do begin
            if (sonstam[i]>0) and (sonarriv[i]=true) then begin
             sd(global_plycol,polare+config.textcol1+' attacks '+son[i]+'!...');
             Sleep(500);
             if random(2)=0 then begin
              sd(4,'And hits!');
              dec(sonstam[i],2);
             end
             else begin
              sd(config.textcolor,'But misses!');
             end;
             crlf;
             if sonstam[i]<1 then begin
              d(15,'He goes down!');
              inc(knocksons);
             end;
             break;
            end;
           end;
          end;
         until (barrels<1) or (pstam<1) or (ch='F');

         if pstam<1 then begin
          crlf;
          d(config.textcolor,'You didn''t make it all the way!');
          if (polare<>'') and (turbo=true) and (cstam>0) then begin
           d(config.textcolor,'Before you close your eyes, you can see '+uplc+polare+config.textcol1);
           if newdogs>0 then begin
            d(config.textcolor,'running off with the cart, chased by mad dogs...')
           end
           else begin
            d(config.textcolor,'running off with the cart.');
           end;
           xx:=stolen*500;

           if (xx>0) and (npc=false) then begin

            incplayermoney(pl0^,xx);

            user_save(pl0^);

            post(MailSend,
            polare,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+'Thievery!'+config.textcol1,
            umailheadc+mkstring(9,underscore)+config.textcol1,
            'You joined '+uplc+player.name2+config.textcol1+' on a burglary tour!',
            'You earned '+uyellow+commastr(xx)+config.textcol1+' '+many_money(xx)+'!',
            'Unfortunately '+uplc+player.name2+config.textcol1+' died!',
            'You got '+sex3[player.sex]+' share of the loot though! (hehe)',
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
            newsy(true,
            'Successful Burglary!',
            ' '+uplc+player.name2+config.textcol1+' and '+uplc+polare+config.textcol1+' stole barrels from the Inn!',
            ' '+uplc+polare+config.textcol1+' got away with the loot!',
                        ' '+uplc+player.name2+config.textcol1+' wasn''t so lucky!',
'',
            '',
            '',
            '',
            '',
            '');
           end;
           crlf;
           crlf;
           pause;
           disposal;
           normal_exit;
          end
          else begin
           if (turbo=true) and (cstam<1) then begin
            if random(3)=0 then s:=' (Nice Dogs!)'
                           else s:='';

            newsy(true,
            'Pathetic Thieves!',
            ' '+uplc+player.name2+config.textcol1+' and '+uplc+polare+config.textcol1+' tried to steal Beer barrels'
               +' from the Inn.',
            ' They were both finished off by the watchdogs!',
            s,
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
            'Worthless Thieves!',
            ' '+uplc+player.name2+config.textcol1+' tried to steal Beer barrels from the Inn.',
            ' '+sex2[player.sex]+' was caught in a pathetic attempt!',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
           end;
          end;
          disposal;
          crlf;
          crlf;
          pause;
          normal_exit;
         end
         else begin
          crlf;

          if (turbo=true) and (cstam>0) then begin
           d(config.textcolor,'You and '+uplc+polare+config.textcol1+' take off with'+' your loot!')
          end
          else begin
           d(config.textcolor,'You run off with the loot!');
          end;

          xx:=stolen*500;
          sd(14,commastr(stolen));
          sd(config.textcolor,' stolen barrels gives you ');
          sd(14,commastr(xx));
          sd(config.textcolor,' '+many_money(xx)+'!');
          crlf;

          yy:=0;          
          if knockdogs+knocksons>0 then begin
           if knockdogs>0 then begin
           sd(config.textcolor,'You managed to knock out ');
           sd(14,commastr(knockdogs));
           sd(config.textcolor,' dogs.');
           crlf;
           end;
           if knocksons>0 then begin
           sd(config.textcolor,'You managed to knock out ');
           sd(14,commastr(knocksons));
           sd(config.textcolor,' sons!');
           crlf;
           end;
           yy:=player.level*((25*knockdogs)+(50*knocksons));
           sd(config.textcolor,'This gives you ');
           sd(14,commastr(yy));
           sd(config.textcolor,' experience points!');
          end;

          crlf;
          pause;

          if turbo=true then begin
           if (xx>0) and (cstam>0) then begin
            if male=true then d(config.textcolor,'Of course you must give '+uplc+polare+config.textcol1+' his share!')
                         else d(config.textcolor,'Of course you must give '+uplc+polare+config.textcol1+' her share!');
            xx:=xx div 2;
            
           end;
           if (cstam>0) and (yy>0) then yy:=yy div 2;
           if npc=false then begin

            if cstam>0 then begin
             incplayermoney(pl0^,xx);
             inc(pl0^.exp,yy);
            
            user_save(pl0^);

             post(MailSend,
             pl0^.name2,
             pl0^.ai,
             false,
             mailrequest_nothing,
             '',
             umailheadc+'Thievery!'+config.textcol1,
             mkstring(9,underscore),
             'You joined '+uplc+player.name2+config.textcol1+' on a burglary tour!',
             'You earned '+uyellow+commastr(xx)+config.textcol1+' '+many_money(xx)+'!',
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
            else begin
             post(MailSend,
             pl0^.name2,
             pl0^.ai,
             false,
             mailrequest_nothing,
             '',
             umailheadc+'Thievery!'+config.textcol1,
             mkstring(9,underscore),
             'You joined '+uplc+player.name2+config.textcol1+' on a burglary tour!',
             'The watchdogs got you! You earned nothing!',
             uplc+player.name2+config.textcol1+' got all the loot! ('+uyellow+commastr(xx*2)+config.textcol1+')',
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

          if polare<>'' then begin
           s:='';
           s2:='';
           if cstam<1 then begin
            s2:=' '+uplc+player.name2+config.textcol1+' got away with the loot!';
                       s:=' '+uplc+polare+config.textcol1+' wasn''t so lucky!';
end
           else begin
            s:=' They got away with '+uwhite+commastr(stolen)+config.textcol1+' barrels!';
            if stolen<1 then s2:=' (they proved to be lousy thieves)';
           end;
           newsy(true,
           'Successful Burglary!',
           ' '+uplc+player.name2+config.textcol1+' and '+uplc+polare+config.textcol1+' stole Beer barrels from the Inn!',
           s,
           s2,
           '',
           '',
           '',
           '',
           '',
           '');
          end
          else begin
           newsy(true,
           'Successful Burglary!',
           ' '+uplc+player.name2+config.textcol1+' stole Beer barrels from the Inn!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');
          end;

          incplayermoney(player,xx);
          if yy>0 then begin
           inc(player.exp,yy);
          end;
         end;
         crlf;
         pause;

         if polare<>'' then begin
          add_shadow(SRemove,pl0^,'','',0);
         end;

       end;
    end;
  end;
  

 until ch='R';

 crlf;
 disposal;

 {remove beer stealing friend, or rather teammember who followed}
 if polare<>'' then begin
  add_shadow(SRemove,pl0^,'','',0);
 end;

end; {Beer_Stealing *end*}

end. {Unit BeerSt .end.}
