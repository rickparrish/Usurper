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
Unit BrawlC; {Usurper - Bar Brawl at Bobs Bar}

Interface

Function Brawl : boolean;

Implementation

Uses Init, Jakob, News,
     Various, Various2, Various3,
     File_Io;

const foe_col = 10; {enemy color}
var
    ted,
    knocks,
    stamina : integer;

    losers_out,
    stunned,
    greppad : boolean;

    rr : real;

    foess,
    yy,
    xx,
    i,
    y,
    x,
    j : longint;

    gr,
    gr2 : integer;

    a,
    s : s70;

    ch : char;

    foes : array[1..10] of ^integer;

Function Foe_Count : integer;
begin
 foe_count:=foes[1]^+
            foes[2]^+
            foes[3]^+
            foes[4]^+
            foes[5]^+
            foes[6]^+
            foes[7]^+
            foes[8]^+
            foes[9]^+
            foes[10]^;
end;

Procedure Menu_Foes(racenr : integer;
                    many : boolean);
var s : string[15];
    p : byte;
begin

 case racenr of
  1:begin
     s:='(h)uman';
     p:=2;
    end;
  2:begin
     s:='h(o)bbit';
     p:=3;
    end;
  3:begin
     s:='(e)lf';
     p:=2;
    end;
  4:begin
     s:='h(a)lf-elf';
     p:=3;
    end;
  5:begin
     s:='(d)warf';
     p:=2;
    end;
  6:begin
     s:='(t)roll';
     p:=2;
    end;
  7:begin
     s:='o(r)c';
     p:=3;
    end;
  8:begin
     p:=2;
     s:='(g)nome';
    end;
  9:begin
     p:=3;
     s:='g(n)oll';
    end;
 10:begin
     p:=2;
     s:='(m)utant';
    end;
 end; {case .end.}

 if many=true then begin
  if racenr=3 then begin
   p:=2;
   s:='(e)lves';
  end
  else if racenr=4 then begin
   p:=3;
   s:='h(a)lf-elves';
  end
  else if racenr=5 then begin
   p:=2;
   s:='(d)warves';
  end
  else begin
   s:=s+'s';
  end;
 end;

 menu3(s,p);

end; {menu_foes *end*}

Procedure Brawl_Result(const ch : char );
begin

 case ch of
  '1':begin
       global_dungeonlevel:=1;
       d(config.textcolor,'You grab a chair...');
      end;
  '2':begin
       global_dungeonlevel:=2;
       d(config.textcolor,'You grab a stool...');
      end;
  '3':begin
       global_dungeonlevel:=3;
       d(config.textcolor,'You grab a bottle...');
      end;
  '4':begin
       global_dungeonlevel:=0;
       d(config.textcolor,'You roll up your sleeves...');
      end;
 end; {case .end.}

 crlf;
 pause;
end; {brawl_result *end*}

Procedure Init_Fight;
begin

 {fetching "Losers gonna get kicked out" from .CFG #86}
 losers_out:=false;
 s:=cfg_string(86);
 if upcasestr(s)='NO' then begin
  losers_out:=true;
 end;

 dec(player.brawls);
 knocks:=0;


 for i:=1 to 10 do begin
  new(foes[i]);
  foes[i]^:=0;
 end;

 repeat
  crlf;
  if random(4)=0 then begin
   d(global_plycol,config.bobsbartender+' the Bartender'+config.textcol1+' looks at you suspiciously...');
   crlf;
  end;

  d(config.textcolor,'Well then, choose your weapon :');
  menu('(1) Chair');
  menu('(2) Stool');
  menu('(3) Bottle');
  menu('(4) Fists');
  sd(config.textcolor,':');

  {get user-input}
  ch:=upcase(getchar);

 until ch in ['1','2','3','4'];

 global_dungeonlevel:=0;
 crlf;
 brawl_result(ch);

 {*create opponents based on player level*}
 yy:=player.level*5;
 if yy>60 then yy:=60;
 if player.level>30 then yy:=player.level+random(10);

 if player.class in [Barbarian,Paladin,Warrior] then begin
  inc(yy,random(7));
 end;

 {spread yy:s on different races}
 xx:=yy;
 repeat
  i:=random(10)+1;
  inc(foes[i]^);
  dec(xx);
 until xx<=0;

 foess:=yy;
 ted:=0;

 repeat
  crlf;
  d(config.textcolor,'There is a grim bunch of '+uwhite+commastr(yy)+config.textcol1+' characters in here.');
  d(config.textcolor,'How do you wanna start the brawl ?');
  menu('(S)pill Beer');
  menu('(C)rack a bottle');
  menu('(P)ush');
  menu('(T)rip');
  menu('(I)nsult');
  sd(config.textcolor,':');

  {get user-input}
  ch:=upcase(getchar);

 until ch in ['S','C','P','T','I'];
 crlf;

 case ch of
  'S':begin
       d(config.textcolor,'You take your beer and pour it over one of the ugliest-');
       d(config.textcolor,'looking characters sitting at a table!');
      end;
  'C':begin
       d(config.textcolor,'You grab an empty bottle, and simply smash it over the head');
       d(config.textcolor,'of one of the guests!');
      end;
  'P':begin
       d(config.textcolor,'You push one of the standing guests so he falls to');
       d(config.textcolor,'the ground with a surprised look in his face!');
      end;
  'T':begin
       d(config.textcolor,'You make a large troll fly by gently putting out your left');
       d(config.textcolor,'foot! Trouble has arrived!');
      end;
  'I':begin
       d(config.textcolor,'With words that would make your mother wash your mouth, you');
       d(config.textcolor,'let the nearest guest hear what a particular swine he is!');
      end;
 end; {case .end.}

 {should Ted the Bartender get involved in the fight?}
 if random(2)=0 then begin
  crlf;
  d(global_plycol,config.bobsbartender+' the Bartender'+config.textcol1+' immediately grabs a wooden club and jumps');
  d(config.textcolor,'over the counter to if possible prevent the wrecking of the bar!');
  crlf;
  d(global_talkcol,'Get that troublemaker!!'+config.textcol1+', he screams, and points at YOU!');
  ted:=1;
  inc(foess);
 end;

 {news-paper}
 newsy(false,
 'Bar-Fight!',
 ' '+uplc+player.name2+config.textcol1+' started a brawl in '+config.bobsplace+'!',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

 crlf;
 pause;

 stamina:=player.stamina;
 stunned:=false;
 greppad:=false;

end; {init_fight *end*}

Function Brawl : boolean; {the brawl routine!}
begin

 Init_Fight;

 {*start brawl*}

 repeat
  {should anyone try to escape?}
  if random(5)=0 then begin
   y:=random(10)+1;
   if foes[y]^>0 then begin
    sd(config.textcolor,'A ');
    sd(foe_col,race_display(2,Elf,y));
    d(config.textcolor,' PANICS and tries to ESCAPE!');
    if random(2)=0 then begin
     d(config.textcolor,'He managed to sneak out! What a coward!');
     dec(foess);
     dec(foes[y]^);
    end
    else begin
     d(config.textcolor,'He didn''t make it! (hehe)');
    end;
   end;
   crlf;
   pause;
  end;

  {should a new guest enter?}
  if random(5)=0 then begin
   y:=random(10)+1;
   sd(config.textcolor,'The door to the Inn opens and a ');
   sd(foe_col,race_display(2,Elf,y));
   d(config.textcolor,' enters!');

   if random(2)=0 then begin
    sd(config.textcolor,'The ');
    sd(foe_col,race_display(2,elf,y));
    d(config.textcolor,' immediately throws himself into the fight!');
    inc(foess);
    inc(foes[y]^);
   end
   else begin
    d(config.textcolor,'But he disappears when he sees what''s going on!');
   end;
   crlf;
   pause;
  end;

  {should something come flying?}
  if random(3)=0 then begin
   x:=ted+foe_count;
   if x>0 then begin
    case random(3) of
     0: s:='chair';
     1: s:='stool';
     2: s:='bottle';
    end;
    d(config.textcolor,'Suddenly a '+s+' comes flying!');

    x:=random(x);
    if x=0 then begin
     d(config.textcolor,'It''s aimed for you!');
     y:=2;
     if player.class=Jester  then inc(y);
     if stamina<2 then dec(y);
     if player.agility>50 then inc(y);
     if player.agility>200 then inc(y);
     if player.agility>700 then inc(y);
     if player.agility>1300 then inc(y);

     d(config.textcolor,'Try to :');
     menu('(G)rab the '+s);
     menu('(D)uck');
     sd(config.textcolor,':');

     repeat
      ch:=upcase(getchar);
     until (ch='G') or (ch='D');

     case ch of
      'D':begin
          d(config.textcolor,'You duck and...');
          end;
      'G':begin
          if (y>=5) and (random(2)=0) then begin
           d(config.textcolor,'With the speed of a Ninja warrior, you manage to grab the');
           d(config.textcolor,'flying '+s+'! You have made a deep impression on your opponents!');
           crlf;
           y:=9999;
           pause;
          end
          else begin
           d(config.textcolor,'In a pathetic attempt you try to catch the flying '+s+'!');
           d(config.textcolor,'But you are not even close!! It''s too late to escape...');
           crlf;
           pause;
           y:=1;
          end;
          end;
     end; {case .end.}

     if (random(y+2)=0) and (y<>9999) then begin
      d(config.textcolor,'DONK! You are hit over the head....');
      dec(stamina,2);
     end
     else begin
      if y<>9999 then begin
       d(config.textcolor,'You manage to avoid the '+s+' by throwing yourself to the floor!');
       crlf;
       pause;
      end;
     end;
    end
    else begin
     s:='';
     for i:=1 to 10 do begin
      if (foes[i]^>0) and (s='') then begin
       s:=race_display(2,elf,i);
       break;
      end;
     end;
     if s<>'' then begin
      d(config.textcolor,'It''s aimed for a '+s+'!');
      if random(4)=0 then begin
       sd(config.textcolor,'The ');
       sd(foe_col,s);
       d(config.textcolor,' didn''t manage to duck!');
       d(config.textcolor,'He is hit over the head, and goes down!');
       dec(foes[i]^);
      end
      else begin
       sd(config.textcolor,'But the ');
       sd(foe_col,s);
       d(config.textcolor,' managed to avoid the flying object!');
      end;
     end;
    end;
   end;
  end;

  {Ted active?}
  if ted>0 then begin
   sd(global_plycol,config.bobsbartender);
   d(config.textcolor,' swings his Club! He looks angrily at you!');
   y:=0;
   if stamina>5 then inc(y);
   if player.class=Jester then inc(y);
   if player.agility>50   then inc(y);
   if player.agility>200  then inc(y);
   if player.agility>700  then inc(y);
   if player.agility>1300 then inc(y);
   if stunned=true then y:=1;
   if greppad=true then y:=1;

   if random(y)=0 then begin
    case random(5) of
     0: d(config.textcolor,'You are hit over the head!');
     1: d(config.textcolor,'A fearsome stroke lands on your shoulder!');
     2: d(config.textcolor,'A stroke lands on your leg!');
     3: d(config.textcolor,'You are hit over the arms!');
     4: d(config.textcolor,'Oouuchh! You receive a blow in the chest!');
    end;
    d(config.textcolor,'You were too slow!');
    dec(stamina);
    if stamina<=0 then begin
     newsy(true,
     ' '+uplc+player.name2+config.textcol1+' was knocked out by '+uplc+config.bobsbartender+' the Bartender'
        +config.textcol1+'!',
     ' ('+uplc+player.name2+config.textcol1+' managed to knock out '+commastr(knocks)+' foes)',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     crlf;
     pause;
     normal_exit;
    end;
   end
   else begin
    case random(4) of
     0:begin
        sd(14,'You easily avoid ');
        sd(global_plycol,config.bobsbartender+'s');
        d(14,' attack!');
       end;
     1:begin
        sd(14,'You evade ');
        sd(global_plycol,config.bobsbartender+'s');
        d(14,' fearsome attack!');
       end;
     2:begin
        sd(14,'You avoid ');
        sd(global_plycol,config.bobsbartender+'s');
        d(14,' attack with some difficulties!');
       end;
     3:begin
        sd(global_plycol,config.bobsbartender+'s');
        d(14,' stroke whistles pass you! Gee! That was close!');
       end;
    end; {case .end.}
   end;
  end;

  {should we arrange DIRTY FIGHT party?}
  if foe_count>2 then begin
   if (random(4)=0) and (greppad=false) then begin
    yy:=0;
    repeat
     for i:=1 to 10 do begin
      if (foes[i]^>0) and (random(2)=0) then begin
       inc(yy);

       case yy of
        1:begin
           sd(config.textcolor,'A ');
           sd(foe_col,race_display(2,elf,i));
           d(config.textcolor,' grabs your left arm!');
          end;
        2:begin
           sd(config.textcolor,'A ');
           sd(foe_col,race_display(2,elf,i));
           d(config.textcolor,' grabs your right arm!');
          end;
        3:begin
           sd(config.textcolor,'A ');
           sd(foe_col,race_display(2,elf,i));
           d(config.textcolor,' starts to beat you up!');

           s:=race_display(2,elf,i);
          end;
       end; {case .end.}
       break;
      end;
     end; {for i:= .end.}
    until yy=3;

    dec(stamina);
    d(12,'You are DEFENCELESS!');
    crlf;
    greppad:=true;

    pause;
   end;
  end;

  {other brawlers make their moves}
  for i:=1 to 10 do begin
   if foes[i]^>0 then begin
    if random(4)=0 then begin
     sd(config.textcolor,'A chicken ');
     sd(foe_col,race_display(2,elf,i));
     d(config.textcolor,' hides in the shadows!');
    end
    else begin
     sd(config.textcolor,'A ');
     sd(foe_col,race_display(2,elf,i));
     d(config.textcolor,' charges!');

     if (random(2)=0) or (foe_count<=1) then begin
      if (stunned=false) and (greppad=false) then begin
       x:=random(14)+1;
       case x of
        1: d(config.textcolor,'He tries to tackle you!');
        2: d(config.textcolor,'He tries a drop-kick against you!');
        3: d(config.textcolor,'He tries an uppercut against your head!');
        4: d(config.textcolor,'He tries to bite you in the leg!');
        5: d(config.textcolor,'He goes for a leg-sweep against you!');
        6: d(config.textcolor,'He tries to break your arm!');
        7: d(config.textcolor,'He sends off a Nicehand, aimed at your chest!');
        8: d(config.textcolor,'He sends off a nervepunch!');
        9: d(config.textcolor,'The bastard tries to strangle you!');
        10: d(config.textcolor,'He goes for a Headbash! Watch it!');
        11: d(config.textcolor,'He tries to pull your hair!');
        12: d(config.textcolor,'He goes for a kick, aimed at your body!');
        13: d(config.textcolor,'He goes for a straight punch in your face!');
        14: d(config.textcolor,'He comes rushing at you in high speed! RAM!');
       end; {case .end.}
       y:=1;
       if stamina>5 then inc(y);
       if player.class=Jester then inc(y);
       if player.agility>50   then inc(y);
       if player.agility>200  then inc(y);
       if player.agility>700  then inc(y);
       if player.agility>1300 then inc(y);
       if player.level>50     then inc(y);
       if player.level>95     then inc(y);

       if random(y)=0 then begin
        d(config.textcolor,'You didn''t manage to evade!');
        if x=8 then stunned:=true;
        case x of
         1: d(12,'The hard tackle sends you across the floor! You lose your breath!');
         2: d(12,'You stagger under the impact from the kick!');
         3: d(12,'The stroke lands neately on your chin! You see stars and moons!');
         4: d(12,'His bite goes deep in your leg! You are bleeding!');
         5: d(12,'You fall heavily to the floor!');
         6: d(12,'Cracck... Something just broke in your body! You are hurt bad!');
         7: d(12,'You lose your breath when his steelhand goes right in your chest!');
         8: d(12,'The stroke hits a nerve! You are stunned!');
         9: d(12,'He got you in a chokeholt! You can''t breathe!');
         10:d(12,'BONK! You are feeling dizzy! Your head aches!');
         11:d(12,'Arrgghhh! That really hurt! What a dirty trick!');
         12:d(12,'The well placed kick lands right in solar-plexus! Ouch!');
         13:d(12,'The punch lands right on your nose! You lose sense of all directions!');
         14:d(12,'His attack sends you sprawling! You fall to the floor!');
        end;
        stamina:=stamina-(random(3)+1);

        if stamina<=0 then begin
         d(config.textcolor,'Your head starts to spin, and you feel darkness...');
         d(config.textcolor,'All your strength is gone!');
         d(config.textcolor,'Before you slide into unconsciousness you feel how you are being');
         d(config.textcolor,'frisked...');
         crlf;

         newsy(true,
         ' '+uplc+player.name2+config.textcol1+' was taken out by a '+race_display(2,elf,i)+'!',
         ' Robbed and beaten, '+uplc+player.name2+config.textcol1+' was thrown out in the gutter!',
         ' ('+uplc+player.name2+config.textcol1+' managed to knock out '+commastr(knocks)+' foes)',
         '',
         '',
         '',
         '',
         '',
         '',
         '');

         player.gold:=0;
         pause;
         clearscreen;
         crlf;
         d(config.textcolor,'After a long time you wake up from your disgraceful experience.');
         d(config.textcolor,'You find yourself laying in the gutter, outside '+config.bobsplace+'.');
         d(config.textcolor,'All your valuables are gone, and you feel dizzy.');
         crlf;
         pause;

         for i:=1 to 10 do begin
          dispose(foes[i]);
         end;
         brawl:=false;
         exit;

        end;
       end
       else begin
        case x of
         1:d(config.textcolor,'A quick jump aside, and you avoid the fearsome tackle!');
         2:d(config.textcolor,'With a swift shift in position you avoid the kick! Nice!');
         3:d(config.textcolor,'You quickly move your head and avoid being hit!');
         4:d(config.textcolor,'With an elegant bodyroll you evade the sneaky attack!');
         5:d(config.textcolor,'With a high jump you avoid the attempt to sweep your legs!');
         6:d(config.textcolor,'You block the grim attack with a slick hands-off parry!');
         7:d(config.textcolor,'You manage to throw yourself aside and avoid the fearsome stroke!');
         8:d(config.textcolor,'With a couple of ballet-steps you evade the stroke!');
         9:d(config.textcolor,'You block the attempt at your throat with your hands!');
         10:d(config.textcolor,'You quickly jump aside and avoid the bash!');
         11:d(config.textcolor,'You quickly take a step back to avoid the attack!');
         12:d(config.textcolor,'You manage to parry the kick!');
         13:d(config.textcolor,'With elegance you block the stroke with your forearmes!');
         14:d(config.textcolor,'You throw yourself aside and manage to avoid being rammed!');
        end;
       end;

      end
      else if (stunned=true) and (random(2)=0) then begin
       dec(stamina,2);
       d(config.textcolor,'He kicks you hard!');
      end
      else if (greppad=true) and (random(2)=0) then begin
       dec(stamina,2);
       d(config.textcolor,'He punches you hard in the stomach!');
      end
      else begin
       for j:=1 to 10 do begin
        if (foes[j]^>0) and (i+1<>j) then begin
         x:=random(14)+1;
         a:=race_display(2,elf,j);
         case x of
          1: d(config.textcolor,'He tries to tackle a '+a+'!');
          2: d(config.textcolor,'He tries a drop-kick against a '+a+'!');
          3: d(config.textcolor,'He tries a uppercut against a '+a+'!');
          4: d(config.textcolor,'He tries to bite a '+a+'!');
          5: d(config.textcolor,'He goes for a leg-sweep against a '+a+'!');
          6: d(config.textcolor,'He tries to cripple a '+a+'!');
          7: d(config.textcolor,'He sends off a nicehand, aimed at a '+a+'!');
          8: d(config.textcolor,'He sends off a nervepunch, aimed at a '+a+'!');
          9: d(config.textcolor,'He tries a chokeholt against a '+a+'!');
          10: d(config.textcolor,'He goes for a Headbash against a '+a+'!');
          11: d(config.textcolor,'He tries to pull a '+a+'s hair!');
          12: d(config.textcolor,'He goes for a kick, aimed at a '+a+'!');
          13: d(config.textcolor,'He goes for a straight punch against a '+a+'!');
          14: d(config.textcolor,'He comes rushing at a '+a+' in high speed! RAM ATTACK!');
         end;
         if random(3)=0 then begin
          sd(config.textcolor,'The ');
          sd(foe_col,a);
          d(config.textcolor,' goes down, unconscious!');
          dec(foes[j]^);
         end
         else begin
          d(config.textcolor,'But misses!');
         end;
         break;
        end;
       end;
      end;
     end;
    end;
   end;
  end; {for i:= .end.}

  if (ted+foe_count>0) and (stunned=false) and (greppad=false) then begin

   crlf;

   d(config.textcolor,'You look around the room, eager to fight!');
   d(config.textcolor,'You can see :');

   gr:=0;
   gr2:=0;
   if ted=1 then begin
    sd(global_plycol,'*-'+config.bobsbartender+', ');
   end;

   for i:=1 to 10 do begin
    if foes[i]^>0 then begin
     inc(gr);
     inc(gr2);
     if gr2>5 then begin
      gr2:=0;
      crlf;
     end;
     if (gr>1) and (gr<11) then sd(config.textcolor,', ');
     sd(config.textcolor,commastr(foes[i]^)+' ');

     if foes[i]^=1 then menu_foes(i,false);
     if foes[i]^>1 then menu_foes(i,true);
    end;
   end;

   crlf;
   sd(config.textcolor,'Choose opponent :');

   repeat
    s:='nope';

    {Get User-Input}
    ch:=upcase(getchar);

    {Evaluate User-Input}
    if (ch='*') and (ted=0) then ch:=' ';

    if ch in ['H','O','E','A','D','T','R','G','N','M','*'] then begin
     case ch of
      'H': x:=1;
      'O': x:=2;
      'E': x:=3;
      'A': x:=4;
      'D': x:=5;
      'T': x:=6;
      'R': x:=7;
      'G': x:=8;
      'N': x:=9;
      'M': x:=10;
      '*': x:=99;
     end; {case .end.}

     if x<>99 then begin
      if foes[x]^>0 then s:='yep';
     end
     else begin
      s:='yep';
     end;

    end;
   until s='yep';

   crlf;
   if x<>99 then begin
    d(config.textcolor,'You charge a '+race_display(2,elf,x)+'!');
   end
   else begin
    d(config.textcolor,'You charge '+uplc+config.bobsbartender+' the Bartender'+config.textcol1+'!');
   end;

   rr:=stamina;
   rr:=rr / player.stamina;
   xx:=round(rr*100);

   a:='You are in Excellent condition';
   if xx<100 then a:='You have some small wounds and bruises';
   if xx<80 then a:='You have some wounds';
   if xx<70 then a:='You are pretty hurt!';
   if xx<50 then a:='You are in a bad shape!';
   if xx<30 then a:='You have some BIG and NASTY wounds!';
   if xx<20 then a:='You are in an awful condition!';
   if xx<5 then a:='You are bleeding from wounds ALL over your body!';

   d(config.textcolor,a);
   xx:=x;

   repeat
    crlf;
    sd(config.textcolor,'Action (');
    sd(14,'A');
    sd(config.textcolor,'..');
    sd(14,'N');
    sd(config.textcolor,' = Move, ');
    sd(14,'?');
    sd(config.textcolor,'=Help, ');
    sd(14,'0');
    sd(config.textcolor,'=Flee ');

    if global_dungeonlevel>0 then begin
     sd(config.textcolor,', ');
     sd(14,'T');
     sd(config.textcolor,'=Throw object):');
    end
    else begin
     sd(config.textcolor,')');
     sd(config.textcolor,':');
    end;

    {Get User-Input}
    ch:=upcase(getchar);


    {Evaluate User-Input}

    {Display Moves - and user skill}
    if ch='?' then begin
     crlf;

     d(15,'Your Skills :');
     d(config.textcolor,mkstring(12,underscore));

     for i:=1 to global_maxcombat do begin
      sd(config.textcolor,'(');
      sd(5,chr(64+i));
      sd(config.textcolor,') ');
      sd(global_bashcol,ljust(bash_name(i),15));

      y:=11;
      case player.skill[i] of
       0..2  : y:=11;
       3..8  : y:=3;
       9..14 : y:=12;
       15..16: y:=14;
       17    : y:=15;
      end; {case .end.}

      d(y,'- '+bash_rank(player.skill[i]));
     end;

    end; {close combat skills .end.}

    if (ch='T') and (global_dungeonlevel=0) then begin
     ch:='Ž';
    end;

   until ch in ['0','A','B','C','D','E','F','G','H','I','J','K',
                'L','M','N','T'];

   crlf;
   x:=xx;
   if x<>99 then begin
    s:='the '+race_display(2,elf,x);
   end
   else begin
    s:=uplc+config.bobsbartender+' the Bartender'+config.textcol1;
   end;

   case ch of
    'T':begin

        case global_dungeonlevel of
         1: a:='chair';
         2: a:='stool';
         3: a:='bottle';
        end;
        d(config.textcolor,'You aim and throw the '+a+' at '+s+'!');
        global_dungeonlevel:=0;
        if random(3)=0 then begin
         d(14,'The '+a+' hits '+s+'!');
         d(14,s+' loses sense of all directions!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end
        else begin
         d(config.textcolor,s+' manage to duck!');
         if random(10)=0 then begin
          d(config.textcolor,'He manages to catch the '+a+'!');
          d(config.textcolor,'He trows it back at you!');
          crlf;
          pause;
          if random(4)=0 then begin
           d(12,'KLONK! You were hit! That really hurt!');
           crlf;
           dec(stamina);
           pause;
          end
          else begin
           d(config.textcolor,'You manage to avoid the flying object!');
           crlf;
           pause;
          end;
         end;
         pause;
        end;
        end;
    'A':begin
        crlf;
        d(config.textcolor,'Here goes...You take run and then charge '+s+' and try a tackle!');
        if random(hitchance(player.skill[1]))<>0 then begin
         d(config.textcolor,s+' evade your attack! You stumble past him!');
         pause;
        end
        else begin
         d(14,'Your tackle hits '+s+' VERY hard!');
         d(14,s+' loses sense of all directions!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'B':begin
        d(config.textcolor,'BANZAI! You rush '+s+' and try a Drop-Kick!');
        if random(hitchance(player.skill[2]))<>0 then begin
         d(config.textcolor,s+' simply jumps aside, and you fly past him!');
         pause;
        end
        else begin
         d(14,'Your kick hits '+s+' hard!');
         d(14,'He goes down!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'C':begin
        d(config.textcolor,'You try an uppercut against '+s+'!');
        if random(hitchance(player.skill[3]))<>0 then begin
         d(config.textcolor,s+' elegantly blocks your assault!');
         pause;
        end
        else begin
         d(14,'You hit '+s+' right on the chin!');
         d(14,'He goes down!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'D':begin
        d(config.textcolor,'You trow yourself against '+s+' with a fearsome battlecry!');
        if random(hitchance(player.skill[4]))<>0 then begin
         d(config.textcolor,'But '+s+' elegantly avoid your clumsy assault!');
         pause;
        end
        else begin
         d(14,s+' screams in horror as you bite him hard!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'E':begin
        d(config.textcolor,'You try a Leg-Sweep against '+s+'!');
        if random(hitchance(player.skill[5]))<>0 then begin
         d(config.textcolor,'But '+s+' manage to avoid the assault!');
         crlf;
         pause;
        end
        else begin
         d(14,s+' falls heavily to the floor as you sweep away his legs!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'F':begin
        d(config.textcolor,'You try to get a grip on '+s+'!');
        if random(hitchance(player.skill[6]))<>0 then begin
         d(config.textcolor,'But '+s+' blocks your attack!');
         pause;
        end
        else begin
         d(14,s+' screams in pain as you crack a bone in his body! Hehe!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'G':begin
        d(config.textcolor,'You let your right hand go off in an explosive stroke against '+s+'!');
        if random(hitchance(player.skill[7]))<>0 then begin
         d(config.textcolor,'But '+s+' blocks your attack!');
         pause;
        end
        else begin
         d(14,s+' looks surprised when your punch hit him hard in the chest!');
         d(14,'He goes down on his knees, moaning!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'H':begin
        d(config.textcolor,'You send off a stroke against your foe!');
        if random(hitchance(player.skill[8]))<>0 then begin
         d(config.textcolor,'But '+s+' avoids your attack with elegance!');
         pause;
        end
        else begin
         d(14,s+' is stunned from your effective punch!');
         d(14,'He goes down!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'I':begin
        d(config.textcolor,'You try to get your hands around '+s+'s throat!');
        if random(hitchance(player.skill[9]))<>0 then begin
         d(config.textcolor,'But '+s+' takes a couple of ballet steps, and avoid your attack!');
         pause;
        end
        else begin
         d(14,s+'s face turns red when he chokes!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'J':begin
        d(config.textcolor,'You try a Headbash against '+s+'!');
        if random(hitchance(player.skill[10]))<>0 then begin
         d(config.textcolor,'But '+s+' quickly takes a few steps back!');
         pause;
        end
        else begin
         d(14,'You hit '+s+'s head with a massive blow!');
         d(14,'He goes down bleeding from some nasty wounds!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'K':begin
        d(config.textcolor,'You try to grab hold of '+s+'s hair!');
        if random(hitchance(player.skill[11]))<>0 then begin
         d(config.textcolor,'But '+s+' manage to evade your attack!');
         pause;
        end
        else begin
         d(14,'You get a firm grip of his hair! You drag him around the room!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'L':begin
        d(config.textcolor,'You try a Kick against '+s+'!');
        if random(hitchance(player.skill[12]))<>0 then begin
         d(config.textcolor,'But '+s+' manage to block it!');
         pause;
        end
        else begin
         d(14,'He staggers under your blow!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'M':begin
        d(config.textcolor,'You try a Punch against '+s+'!');
        if random(hitchance(player.skill[13]))<>0 then begin
         d(config.textcolor,'But '+s+' manage to block it!');
         pause;
        end
        else begin
         d(14,'You hit him right on the chin! He is dazed!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    'N':begin
        d(config.textcolor,'You rush '+s+' with your head lowered!');
        if random(hitchance(player.skill[14]))<>0 then begin
         d(config.textcolor,'But the he manages to jump aside just before you reach him!');
         pause;
        end
        else begin
         d(14,'You hit '+s+' right in Solar-Plexus! You send him flying!');
         if x<>99 then dec(foes[x]^);
         if x=99 then ted:=0;
         inc(knocks);
         pause;
        end;
        end;
    '0':begin
        if random(stamina)=0 then begin
         d(config.textcolor,'You make a dash for the door!');
         d(12,'But it''s blocked!');
         crlf;
         pause;
        end
        else begin
         d(config.textcolor,'You make it out through a window! (chicken!)');
         newsy(true,
         ' '+uplc+player.name2+config.textcol1+' fled the fight! (what a chicken!)',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '');

         crlf;
         pause;
         
         for i:=1 to 10 do begin
          dispose(foes[i]);
         end;

         brawl:=false;
         exit;

        end;
        end;
   end; {case .end.}

  end;

  if foe_count<3 then begin
   greppad:=false;
  end;

  if greppad=true then begin
   d(config.textcolor,'You must get out of this! They are beating the hell out of you!');
   crlf;
   pause;
   if random(2)=0 then begin
    d(12,'You didn''t manage to get loose!');
   end
   else begin
    d(15,'You managed to get away!');
    greppad:=false;
   end;
  end;

  if stunned=true then begin
   d(12,'You are laying on the floor stunned!');
   crlf;

   s:='';
   for i:=1 to 10 do begin
    if (foes[i]^>0) and (random(3)=0) then begin
     s:=race_display(2,elf,i);
     break;
    end;
   end; {for i:= .end.}

   if s<>'' then begin
    d(config.textcolor,'A '+s+' approaches! He grins evilly and ');
    case random(4) of
     0: d(12,'kicks you in the head!');
     1: d(12,'kicks you in the chest!');
     2: d(12,'jumps on your head!');
     3: d(12,'punches you in the face!');
    end;
    stamina:=stamina-random(2)+1;
    d(12,'You suffer from your wounds!');
    crlf;

   end;

   pause;
   stunned:=false;
  end;

  {give back stamina}
  {if stamina<player.stamina then stamina:=stamina+1;}

 until ((ted+foe_count)<=0) or (stamina<=0);

 {player is out of stamina! (end of fight)}
 if stamina<=0 then begin

  {make news}
  newsy(true,
  ' '+uplc+player.name2+config.textcol1+' was knocked out! (loser)',
  ' '+uplc+player.name2+config.textcol1+' managed to knock out '+ulgray+commastr(knocks)+config.textcol1+' foes.',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

  player.gold:=0;
  if losers_out=true then begin
   {player.allowed:=false;}
   Reduce_Player_Resurrections(player,true);
   player.hps:=0;
  end;

  crlf;
  d(15,'You have been knocked unconscious!');
  d(15,'Better luck next time Conan!');
  d(config.textcolor,'Darkness...');
  pause;
  normal_exit;

 end
 else begin

  {news-paper}
  s:=upcasestr(sex2[player.sex]);
  newsy(true,
  ' '+uplc+player.name2+config.textcol1+' managed to knock out '+ulgray+commastr(foess)+config.textcol1+' foes!',
  ' '+s+' cleaned the place out!',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

  crlf;
  d(15,'Good Work! You are a true fighter! You managed to stay on your feet!');
  yy:=foess*350;
  sd(config.textcolor,'You receive ');
  sd(14,commastr(yy));
  d(config.textcolor,' experience points!');

  inc(player.exp,yy);
  case random(4) of
   0: yy:=750;
   1: yy:=500;
   2: yy:=250;
   3: yy:=155;
  end;
  yy:=foess*yy;
  sd(config.textcolor,'You frisk the bodies and find ');
  sd(14,commastr(yy));
  d(config.textcolor,' '+many_money(yy)+'!');
  {get money from frisked bodies}
  incplayermoney(player,yy);
  crlf;
  brawl:=true;
  pause;
 end;

 {dispose pointer vars}
 for i:=1 to 10 do begin
  dispose(foes[i]);
 end;

end; {brawl *end*}

end. {Unit Brawlc .end.}
