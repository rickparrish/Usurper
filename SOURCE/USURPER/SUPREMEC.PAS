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


Unit SupremeC; {Usurper - The Supreme Being, the last fight for the mortal
                player}

Interface

Uses Init;

Procedure Supreme(var pl1,pl2,pl3,pl4 : userrec);

Implementation

Uses Jakob, Cms, Statusc,
     SortTeam, PlvsMon, Mail,
     News, GenNews, GodWorld,
     Various, Various2, Various3,
     VarGods, Online, File_Io;

Procedure Supreme;

const supcol = ulred; {supreme beings color in the NEWS and MAIL file}
Var
    x, i, gain : longint;
    justval : integer;
    ch : char;
    s : s70;
    a : s70;
    dummy : ^userrec;
    first, second : boolean;
    txt : text;


    memory_sex: byte;
   memory_name1: s70;


begin

 {init pointer vars}
 new(dummy);

 onliner.doing:='on the final Quest!';
 add_onliner(OUpdateLocation,onliner);

 {to handle "carrier-dropping" cheaters}
 global_PlayerInFight:=true;

 clearscreen;
 show_usurper_data(picture_FINAL_DOORS,false);

{ d(config.textcolor,'Slowly descending through the black mountain you suddenly find');
 d(config.textcolor,'yourself standing in front of three large metal doors.');
 d(config.textcolor,'You must choose one of these.');
 crlf;
{ menu('(G)olden door');
 menu('(S)ilver door');
 menu('(B)ronze door');
 }
 sd(config.textcolor,':');

 repeat
  ch:=upcase(getchar);
 until ch in ['G','S','B'];

 crlf;
 sd(config.textcolor,'Krreeek........the rusty door opens');
 delay2(900);
 crlf;

 {good or bad? door choice is important}
 case ch of
  'G':begin
       d(11,'The Old Woman');
       if player.dark>0 then begin
        d(config.textcolor,'"I see that your soul is dark!", the old woman cackles.');
        d(config.textcolor,'"I will not help a sinner like you!", she says and disappears.');
       end
       else begin
        d(config.textcolor,'"I see that your soul is clean!", the old woman cackles.');
        d(config.textcolor,'"I can help you in your final quest if you give me 25 healing potions!"');
        d(config.textcolor,'"the old woman says.');

        if confirm('Give her the potions ','N')=true then begin
         if player.healing>=25 then begin
          dec(player.healing,25);
          d(config.textcolor,'You give the potions to the old woman.');
          d(config.textcolor,'In return she gives you a dusty old lantern.');
          d(15,'"This will help you survive your quest!"');
          d(config.textcolor,'The woman says before she suddenly disappears in a puff of smoke.');
          global_s_lantern:=true;
         end
         else begin
          d(config.textcolor,'You don''t have that many potions!');
          d(config.textcolor,'The old woman shakes her head and leaves.');
          d(config.textcolor,'Somehow you feel uncomfortable...as if you just');
          d(config.textcolor,'missed a great opportunity.');
         end;
        end
        else begin
         sd(15,'"You will be sorry for this adventurer!"');
         d(config.textcolor,', the old woman screams.');
        end;
       end;
      end;
  'S':begin
       d(11,'The Red Turtle');
       if player.chiv>0 then begin
        sd(15,'"You have done some good in your life!"');
        d(config.textcolor,', the turtle says.');
        sd(15,'"I can''t help you just now..."');
        d(config.textcolor,', he says and crawls away.');
       end
       else begin
        sd(15,'"I can help you in your quest adventurer!"');
        d(config.textcolor,', the turtle says.');
        if confirm('Go ahead and listen to the animal ','N')=true then begin
         d(15,'"Answer these two questions right and I might help you" :');

         d(config.textcolor,'1. How many level masters are there in your town');
         sd(config.textcolor,':');
         x:=get_number(0,100);
         first:=false;
         second:=false;
         if x=10 then begin
          d(15,'"Right!"');
          first:=true;
         end
         else begin
          d(15,'"Wrong!"');
         end;

         if first=true then begin
          d(config.textcolor,'2. How old are you?');
          sd(config.textcolor,':');
          x:=get_number(0,1000);

          if x=player.age then begin
           d(15,'"Right!"');
           second:=true;
          end
          else begin
           d(15,'"Wrong!"');
          end;
         end;

         if (first) and (second) then begin
          crlf;
          d(15,'"You have answered the questions correctly."');
          d(15,'"Take this Black Sword, it will help you in your quest."');
          global_s_sword:=true;
          pause;
         end;

        end
        else begin
         sd(15,'"Suit yourself mortal..."');
         d(config.textcolor,', the turtle mutters as it crawls away.');

        end;
       end;
      end;
  'B':begin
       d(11,'The Oracle');
       d(config.textcolor,'The Oracle sits on a pillar and has a white staff in her right hand.');
       d(config.textcolor,'In her left hand the Oracle has a black staff.');

       d(15,'"Greetings adventurer...You may have one of my staffs"');
       menu('(W)hite staff');
       menu('(B)lack staff');
       sd(config.textcolor,':');

       repeat
        ch:=upcase(getchar);
       until ch in ['W','B'];
       crlf;
       case ch of
        'W':begin
             d(15,'"The White Staff!"');
             global_s_wstaff:=true;
            end;
        'B':begin
             d(15,'"The Black Staff!"');
             global_s_bstaff:=true;
            end;
       end;
       pause;

      end;
 end;

 crlf;
 crlf;
 d(config.textcolor,'**Final Encounter**');
 d(config.textcolor,'You have reached the deep, deep gap where Earth breathes...');
 d(config.textcolor,'With your wisdom and experience you soon realize that');
 d(config.textcolor,'this is the final test of your ability.');
 crlf;
 d(config.textcolor,'You have entered a large hall. The ground is filled');
 d(config.textcolor,'with rocks and some sort of sticky oil.');
 d(config.textcolor,'In the center of the hall you can see a stone altar.');
 d(config.textcolor,'Placed on the altar is a cup filled with a strange liquid.');
 d(config.textcolor,'As you examine the surroundings you can feel the presence of');
 d(config.textcolor,'something powerful watching you...');
 crlf;
 pause;
 clearscreen;

 crlf;
 d(config.textcolor,'What will you do with the Cup on the altar ?');
 menu('(D)rink the potion');
 menu('(I)gnore');
 sd(config.textcolor,':');

 repeat
  ch:=upcase(getchar);
 until ch in ['D','I'];

 if ch='D' then begin
  crlf;
  d(config.textcolor,'Klunk..');
  delay2(1000);
  d(config.textcolor,'klunk..');
  delay2(1000);
  d(config.textcolor,'klunk..');
  delay2(1000);
  d(config.textcolor,'klunk..');
  delay2(1000);
  d(config.textcolor,'klunk..');
  delay2(1000);
  d(config.textcolor,'..ahh.."');
  delay2(1000);
  x:=random(4);
  if x=0 then begin
   d(config.textcolor,'Poison!! You lose many hitpoints!');
   player.hps:=1;
  end
  else begin
   d(config.textcolor,'Power Booster! Your hitpoints increase by 500!');
   gain:=32000-player.maxhps;
   if gain < 0 then gain:=0;
   if gain > 500 then gain:=500;
   player.maxhps:=player.maxhps+gain;
   player.hps:=player.maxhps;
  end;
  crlf;
  crlf;
 end;

 pause;
 clearscreen;
 show_usurper_data(picture_SUPREME,true);
 crlf;

 d(4,'The Being watches you..');

 Reset_Monsters;

 global_Nobeg :=true;
 global_escape:=false;

 monster[1]^.name:='Supreme Being';

 {debug cheat}
{ monster[1]^.hps:=2;
 monster[1]^.strength:=1;
}
 
 monster[1]^.hps:=player.strength*9;

 monster[1]^.strength:=player.strength*3;


 Player_vs_Monsters(3,pl1,pl2,pl3,pl4);

 if global_killed=false then begin

  {news-paper}
  newsy(true,
  uyellow+'Heroic Deed!'+config.textcol1,
  ' '+uplc+player.name2+config.textcol1+' encountered the '+supcol+'Supreme Being'+config.textcol1++' and won!',
  ' '+uplc+player.name2+config.textcol1+' ended '+sex3[player.sex]+' career with',
  ' a brilliant victory!',
  '',
  '',
  '',
  '',
  '',
  '');

  {Heroes "they who completed the game" hall-of-fame}
  if open_txtfile(tappend,txt,global_famefile) then begin

   writeln_to_text(txt,' ');

   {#1, writing player name}
   s:=fix_date(todays_date)+' - '+player.name2+' completed the game.';
   writeln_to_text(txt,s);

   {#2, writing class,race,}
   s:='           ('+classnames[player.class]+', '+race_display(2,player.race,0)+')';
   writeln_to_text(txt,s);

   {#3, writing kids}
   if player.kids>0 then begin
    s:='           ('+commastr(player.kids)+' children)';
    writeln_to_text(txt,s);
   end;

   {Close file}
   close_text(txt);

  end
  else begin
   {error}
   unable_to_append(global_famefile);
  end;

  {inform other nodes}
  online_send_to_all(uplc+player.name2+config.textcol1+' completed the GAME!',player.name2,'');

  {inform player god}
  if player.god<>'' then begin

   if is_online(player.god,online_god)=true then begin
    online_send_to_player(player.god,online_god,uplc+player.name2+config.textcol1H+' completed the Final Quest!');
   end;

   {mail god}
   s:='Disciple Gone!';
   post(MailSend,
   player.god,
   'H',
   true,
   mailrequest_nothing,
   '',
   ulred+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+player.name2+config.textcol1+' completed the Final Quest!',
   'Your disciple has joined you in Heaven!',
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

  {this is also the lines in "suicide" routine}
  add_shadow(SRemoveFakess,player,'','going to sleep',0); {remove online players}
  add_shadow(SRemoveShadows,player,'','going to sleep',0); {remove online players}
  add_onliner(ORemoveMe,onliner);

  {remember some vars for creating a god later on}
  memory_sex:=player.sex;
  memory_name1:=player.name1;

  deactivate_player(player); {remove flags}

  if player.king then begin

   {inform royal guards that they have been sacked}
   sack_royal_guards;

   {delete king order file}
   if f_exists(global_kingf) then begin
    delete_file(global_kingf);
   end;

   if player.sex=1 then s:='King'
                   else s:='Queen';

   {kings-news}
   Generic_News(RoyalNews,
   true,
   ' '+config.textcol1+s+' '+ukingc+player.name2+config.textcol1+' completed '+sex3[player.sex]+' last quest and abdicated.',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   player.king:=false;

  end;

  {save user}
  user_save(player);

  clearscreen;
  show_usurper_data(picture_game_finis,true);

  {player must decide if he wants to become a God/Goddess}
  crlf;
  crlf;
  d(5,'After-life');
  d(config.textcolor,'It''s now time to decide if your time on Earth has come');
  d(config.textcolor,'to an end. Our almighty Father has a room for you in his');
  d(config.textcolor,'pantheon. However, your duty has been long and hard on earth.');
  d(config.textcolor,'You might want to stay mortal and enter the last dreamless sleep.');

  crlf;
  menu2('(B)ecome a God');
  if player.sex=2 then begin
   sd(config.textcolor,'dess');
  end;
  crlf;

  menu('(R)est In Peace');
  sd(config.textcolor,':');

  {get user input}
  repeat
   ch:=upcase(getchar);
  until ch in ['B','R'];

  case ch of
   'R':begin {Rest In Peace .start.}

        d(config.textcolor,'Having completed your ultimate mission you feel that');
        d(config.textcolor,'your career has come to an end. With a deep sigh you lay');
        d(config.textcolor,'down on the slippery stones and close your eyes...');
        crlf;
        d(config.textcolor,'Darkness forever...');
        crlf;
        pause;

        {remove playerinfight flag}
        global_PlayerInFight:=false;

        normal_exit;

       end; {Rest In Peace .end.}

   'B':begin {Become a God}

        become_god(memory_name1,memory_sex);

        god_world;

        {remove playerinfight flag}
        global_PlayerInFight:=false;

        normal_exit;
       end;
  end; {case .end.}
 end
 else begin
  {player was killed}
  crlf;
  crlf;
  d(config.textcolor,'You have been slain!');
  player.hps:=0;

  {player.allowed:=false;}
  Reduce_Player_Resurrections(player,true);

  {news-paper}
  newsy(true,
  'Tragic!',
  ' '+uplc+player.name2+config.textcol1+' encountered the '+supcol+'Supreme Being'+config.textcol1+' and was',
  ' destroyed. May the brutal monster be defeated soon.',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

  crlf;
  d(config.textcolor,'Darkness....');
  crlf;
  crlf;

  {mail}
  post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   '*The Final Quest*',
       mkstring(17,underscore),
       'You were slain by the '+supcol+'Supreme Being!'+config.textcol1,
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
       '',
       '');

  pause;

  {remove playerinfight flag}
  global_PlayerInFight:=false;

  normal_exit;

 end;

 {remove playerinfight flag}
 global_PlayerInFight:=false;


end; {Supreme *end*}

end. {Unit SupremeC .end.}