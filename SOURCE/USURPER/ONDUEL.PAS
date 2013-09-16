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



Unit OnDuel; {Usurper - Online Duel between two players}

Interface

Procedure Online_Duel(the_challenger : boolean);
                      {the_challenger = true, player is the challenger}
Implementation

Uses Jakob, Init,
     news, statusc, online,
     spellsu, cast, swapeq,
     various, various2, various3,
     relation, file_io, SysUtils;

      {Command Constants used to communicate between nodes}
const Cm_ReadyForInput = '='; {ready to receive command from other node}
      Cm_Nothing       = '^'; {dummmy, empty}
var
    mesleepy, hesleepy, adios, imp, challenger : boolean;

    nr1,nr2: longint;

    outmessage : array [1..2] of s70;
    s      : string;
    oppo   : s70;
    sayfile: string[120];

    txt : text;

    enemy : userrec;
    commy : comrec;

Function After_Battle(winner,loser : s70) : s90;
var s : s90;
begin

 winner:=uplc+winner+config.textcol1;
 loser:=uplc+loser+config.textcol1;

 case random(6) of
  0: s:='Hehe! Gotcha!, '+winner+' laughs.';
  1: s:='That was a piece of cake!, '+winner+' declares.';
  2: s:='It was a nice fight..., '+winner+' remarks.';
  3: s:=''+winner+' is cheating!, '+loser+' shrieks.';
  4: s:=''+winner+' is a bastard!, '+loser+' screams.';
  5: s:='I''ll get you next time '+winner+'!, '+loser+' says.';
 end; {case .end.}

 {Convert string to Standard ANSI}
 after_battle:=uconv(s);

end; {after_battle *end*}

Procedure Put_Other(incom : char);
var i : byte;
    bye : boolean;
    sleepcounter : longint;

begin

 bye:=false;
 sleepcounter:=0;

 if imp=true then i:=1
             else i:=0;
 repeat

  inc(sleepcounter);

  {jakob}
  Sleep(global_lockdelay);

  loadsave_com(Fload,Commy,i,'');

  if commy.com=Cm_ReadyForInput then begin
   bye:=true;
  end;

  if f_exists(onliner.comfile)=false then begin
   sd(global_plycol,enemy.name2);
   d(12,' has lost '+sex3[enemy.sex]+' connection!');
   hesleepy:=true;
   adios:=true;
   bye:=true;
  end;

  if sleepcounter>global_online_maxwaits_bigloop then begin
   d(12,'The fight has been called off!');
   d(12,'You have not responded fast enough! (press ENTER)');
   mesleepy:=true;
   adios:=true;
   bye:=true;
  end;

 until bye;

 Lock_OnDuelFile(FLock);
 Load_OnDuelFile(FLoad,Commy,i);

 commy.com :=incom;
 commy.nr1 :=nr1;
 commy.nr2 :=nr2;

 Load_OnDuelFile(FSave,Commy,i);
 Lock_OnDuelFile(FUnLock);

end; {put_other}

Procedure Put_Own(incom : char);
var i : byte;
begin

 if imp=true then i:=0
             else i:=1;
 commy.com:=incom;
 commy.nr1:=nr1;
 commy.nr2:=nr2;

 loadsave_com(FSave,Commy,i,'');

end; {put_own *end*}

Function Get_Com( k1,k2,k3,k4,k5,k6,k7,k8,k9 : char ): char;
var i : byte;
    sleepcounter : longint;
begin
 sleepcounter:=0;
 if imp=true then i:=0
             else i:=1;

 {init incoming orders}
 commy.com:=cm_nothing;

 repeat
  inc(sleepcounter);

  {jakob}
  Sleep(global_lockdelay);


  if f_exists(sayfile) then begin
   if open_txtfile(treset,txt,sayfile) then begin
    readln_from_text(txt,s);
    if s<>'' then begin {opponent said something}
     crlf;
     if s[1]+s[2]+s[3]='-/-' then begin
      s[1]:=' ';
      s[2]:=' ';
      s[3]:=' ';

      sd(global_plycol,enemy.name2);
      d(config.textcolor,' says :');
      d(global_talkcol,' '+s);
     end
     else begin {oppent has mocked player}
      d(15,' '+s);
     end;

    end;
    close_text(txt);
    open_txtfile(tdelete,txt,sayfile);
    crlf;

    {reset sleep counter}
    sleepcounter:=0;

    sd(config.textcolor,'waiting ... ');
   end;
  end; {sayfile .end.}

  if f_exists(onliner.comfile) then begin
   loadsave_com(Fload,Commy,i,'');
  end
  else begin
   sd(global_plycol,enemy.name2);
   d(config.textcolor,' has lost '+sex3[enemy.sex]+' connection!');
   adios:=true;
   hesleepy:=true;
   sleepcounter:=global_online_maxwaits_bigloop;
  end;

  {shit
  d(15,'Waiting for on of these orders : '+k1+','+k2+','+k3+','+k4+','+k5+','+k6+','+k7+','+k8+','+k9);
   }
 until (commy.com in [k1,k2,k3,k4,k5,k6,k7,k8,k9]) or (sleepcounter>=global_online_maxwaits_bigloop);

 if sleepcounter>=global_online_maxwaits_bigloop then begin
  adios:=true;
  hesleepy:=true;
  sd(global_plycol,oppo);
  d(config.textcolor,' has fled the field! (fight is aborted)');
  d(config.textcolor,'The coward! We must get '+sex[enemy.sex]+' soon!');
 end
 else begin
  {shit}
  {d(10,'Incoming order is : "'+commy.com+'"');
  }
  get_com:=commy.com;
 end;

 outmessage[1]:=commy.mess[1];
 outmessage[2]:=commy.mess[2];

 nr1:=commy.nr1;
 nr2:=commy.nr2;

end; {get_com *end*}


Procedure Online_Duel;
var
    abort : boolean;
    done : boolean;

    zz : longint;
    i : longint;

    ch, cho : char;

    error : integer;

    waits,
    round : word;

    s,
    beggar : s70;

    nomore, grepe : boolean;
    fs1,fs2 : longint;
    ComFile     : file of ComRec;     {** Comm file for duels **}
    dummy : byte;

begin

 {checking if loser is allowed to play more today}
 nomore:=false;
 s:=cfg_string(92);
 if UpperCase(s)='NO' then begin
  nomore:=true;
 end;

 User_save(player);
 {finding player positions in playerfile}

 fs1:=0;
 fs2:=0;
 for i:=1 to fs(FsPlayer) do begin
  load_character(enemy,1,i);
  if enemy.name2=onliner.name then begin
   fs1:=i;
  end;
  if enemy.name2=onliner.bname then begin
   fs2:=i;
  end;

  if (fs1<>0) and (fs2<>0) then begin
   break;
  end;
 end;

 {init}
 challenger:=the_challenger;
 imp     :=the_challenger;
 beggar  :=emptystr;
 hesleepy:=false;
 mesleepy:=false;
 adios   :=false;
 oppo    :=onliner.bname;
 round   :=0;
 sayfile :=onliner.comfile; {file which holds chat between players}
 error   :=0; {file error messages}

 i:=pos('.TMP',onliner.comfile);
 delete(sayfile,i,4);
 sayfile:=sayfile+'.SAY';

 {file that keeps track of filelocking}

 if challenger=true then begin
  commy.com:=Cm_Nothing;
  commy.mess[1]:=emptystr;
  commy.mess[2]:=emptystr;
  commy.nr1:=0;
  commy.nr2:=0;

  assign(comfile,onliner.comfile);
  {$I-}rewrite(comfile);{$I+}
  error:=IoResult;
  if error<>0 then unable_to_create(onliner.comfile,error);

  {$I-}write(comfile,commy);{$I+}
  error:=IoResult;
  if error<>0 then unable_to_write(onliner.comfile,error);

  {$I-}write(comfile,commy);{$I+}
  error:=IoResult;
  if error<>0 then unable_to_write(onliner.comfile,error);

  {$I-}close(comfile);{$I+}
  error:=IoResult;
  if error<>0 then unable_to_close(onliner.comfile,error);

 end
 else begin

  grepe:=false;
  waits:=0;
  abort:=false;
  repeat
   Sleep(global_lockdelay);
   inc(waits);

   {wait until attacker has created a COM file}
   if not grepe then begin
    sd(config.textcolor,'Preparing to fight...(press ');
    sd(10,'A');
    sd(config.textcolor,' to abort)');

    grepe:=true;
   end
   else begin

    {waiting sign}
    sd(config.textcolor,'.');

    {check if user has pressed A}
    if ukeypressed then begin
     ch:=upcase(getchar);
     if ch='A' then begin
      crlf;
      d(12,'abort.');
      abort:=true;
     end;
    end;

    Sleep(1);

   end;

   if waits>global_online_maxwaits then abort:=true;

  until (f_exists(onliner.comfile)) or (abort);

  if abort then begin
   d(12,'Unable to establish connection..');
   exit;
  end;

  crlf;
 end;

 {Battle Loop **start**}
 repeat
  inc(round);
  d(config.textcolor,'Round # '+uwhite+commastr(round));

  if challenger=true then begin
   load_character(enemy,1,fs2);

   {dra av av f”r fiendens kastade och l†ngverkande spells}
   cast_spell(false,2,2,enemy,player,imp,dummy);

   d(3,'Your hps : '+commastr(player.hps)+'/'+commastr(player.maxhps));
   d(3,oppo+'s hps : '+commastr(enemy.hps)+'/'+commastr(enemy.maxhps));
   crlf;

   sd(config.textcolor,'waiting for ');
   sd(global_plycol,oppo+'s');
   d(config.textcolor,' move...');

   put_own(Cm_ReadyForInput); {putting myself in "ready for input" mode}
   cho:=get_com('A','H','Q','S','B','C','1',cm_nothing,cm_nothing);

  end
  else begin { if challenger = false }

   {load opponent}
   load_character(enemy,1,fs2);
   ch:='?';

   repeat

    {online duel Menu}
    if ch='?' then begin
     d(3,'Your hps : '+commastr(player.hps)+'/'+commastr(player.maxhps));
     d(3,oppo+'s hps : '+commastr(enemy.hps)+'/'+commastr(enemy.maxhps));

     menu2('(A)ttack  ');
     menu2('(H)eal  ');
     menu2('(Q)uick Heal ');
     menu2('(E)xpress your feelings ');
     menu2('(M)ock opponent');
     crlf;
     menu2('(S)tatus  ');
     menu2('(B)eg for Mercy  ');

     if player.class in [Cleric,Magician,Sage] then begin
      menu2('(C)ast Spell  ');
     end;

     if player.class=Paladin  then menu2('(1) Soul Strike  ');
     if player.class=Assassin then menu2('(1) Backstab  ');
     crlf;
     sd(config.textcolor,':');
    end;

    {get user-input}
    ch:=upcase(getchar);

    case ch of
     'S':begin {status}
          status(player);
         end;
     'M':begin {mock opponent}
          crlf;
          sd(config.textcolor,'Mock ');
          sd(global_plycol,enemy.name2);
          d(config.textcolor,'!');

          menu('(S)pit');
          menu('(L)augh at '+enemy.name2+'s funny clothes');
          menu('(F)art');
          menu('(M)ake funny faces');
          menu('(T)hrow dirt');

          sd(config.textcolor,':');
          repeat
           ch:=upcase(getchar);
          until ch in ['S','L','F','M','T'];

          s:=emptystr;
          crlf;
          case ch of
           'S':begin {spit}
                sd(config.textcolor,'You spit in ');
                sd(global_plycol,enemy.name2+'s');
                d(config.textcolor,' hair!  HAHA! That was fun!');
                s:=player.name2+' spits in your hair!';
               end;
           'L':begin {laugh}
                sd(config.textcolor,'You tell ');
                sd(global_plycol,enemy.name2);
                d(config.textcolor,' what ugly clothes '+sex2[enemy.sex]+' is wearing.');
                s:=player.name2+' laughs at your clothes!';
               end;
           'F':begin {fart}
                sd(config.textcolor,'You let a rip-roarer go off near ');
                sd(global_plycol,enemy.name2);
                d(config.textcolor,'....!    Ohh what a stench!');
                s:=player.name2+' farts in your direction!';
               end;
           'M':begin {make funny faces}
                sd(config.textcolor,'You display your ugliest faces before ');
                sd(global_plycol,enemy.name2);
                d(config.textcolor,'..!');
                s:=player.name2+' makes funny faces to ridicule YOU!';
               end;
           'T':begin {throw dirt}
                sd(config.textcolor,'You pick up some mud and throw it at ');
                sd(global_plycol,enemy.name2);
                d(config.textcolor,'..!');
                s:=player.name2+' threw some dirt at you!';
               end;
          end;

          if s<>'' then begin
           i:=0;
           while (f_exists(sayfile)) and (i<500) do begin
            Sleep(global_lockdelay);
            inc(i);
           end;

           if open_txtfile(trewrite,txt,sayfile) then begin
            write_to_text(txt,s);
            close_text(txt);
           end
           else begin
            d(12,'You couldn''t express your feelings.');
           end;
           Sleep(global_lockdelay);
          end;

          ch:='?';

         end;
     'E':begin {express yourself, say something}
          crlf;
          sd(config.textcolor,'Say what : ');
          s:=get_string(70);
          if s<>'' then begin
           i:=0;
           while (f_exists(sayfile)) and (i<500) do begin
            Sleep(global_lockdelay);
            inc(i);
           end;

           s:='-/-'+s;
           open_txtfile(trewrite,txt,sayfile);
           write_to_text(txt,s);
           close_text(txt);
           Sleep(global_lockdelay);
          end;
          ch:='?';
         end;
     'C':begin {cast spell}
          ch:=' ';
          if player.class in [Cleric,Magician,Sage] then begin
           cast_spell(false,1,2,player,enemy,imp,dummy);
           if player.casted=true then begin
            user_save(enemy);
            ch:='C';
           end
           else begin
            ch:=' ';
           end;
          end;
         end;
     '1':begin  {special attack: backstab/soul strike}
          ch:=' ';
          if player.class=Paladin then begin
           if player.hps<2 then begin
            crlf;
            d(12,'Sorry, too few hitpoints left!');
           end
           else begin
            ch:='1';
           end;
          end
          else if player.class=Assassin then begin
           if config.classic then begin
            if player.weapon=0 then begin
             crlf;
             d(12,'You don''t have a weapon!');
            end
            else begin
             ch:='1';
            end;
           end
           else begin
            if (player.rhand+player.lhand)=0 then begin
             crlf;
             d(config.textcolor,'You don''t have a weapon!');
            end
            else begin
             ch:='1';
            end;
           end;
          end;
         end;
    end;

   until ch in ['A','H','Q','B','C','1'];

   {load opponent}
   load_character(enemy,1,fs2);

   enemy.absorb:=0;

   {evaluate user-input}
   case ch of
    'Q':begin {quick healing}
         quick_healing(player);
        end;
    'C':begin
         {}
        end;
    '1':begin
         case player.class of
          Assassin:begin
                    nr1:=0;
                    nr2:=0;

                    d(config.textcolor,'You try to Backstab '+enemy.name2+'!');
                    if random(3)=0 then begin
                     d(config.textcolor,'You manage to cut '+enemy.name2+'!');
                     d(config.textcolor,enemy.name2+' screams in pain!');
                     nr1:=player.maxhps div 3;
                    end
                    else begin
                     d(config.textcolor,'But you miss!');
                     d(config.textcolor,enemy.name2+' laughs at your pathetic attempt.');
                    end;
                    if nr1<1 then nr1:=0;
                    dec(enemy.hps,nr1);
                   end;
           Paladin:begin
                    nr1:=0;
                    crlf;
                    d(config.textcolor,'How many hitpoints to use (max '+commastr(player.hps-1)+')');
                    sd(config.textcolor,':');
                    zz:=get_number(0,player.hps-1);
                    if (zz>0) and (zz<=player.hps) then begin
                     dec(player.hps,zz);
                     if zz>0 then begin
                      nr1:=soul_effect(player,zz);
                     end;
                     sd(12,'Soulstrike hits ');
                     sd(global_plycol,oppo);
                     sd(config.textcolor,' for ');
                     sd(15,commastr(nr1));
                     d(config.textcolor,' points!');
                    end
                    else begin
                     d(config.textcolor,'Aborted.');
                    end;
                    dec(enemy.hps,nr1);
                   end;
         end;
        end;
    'A':begin {attack}
         d(15,'ATTACK!');
         player.punch:=normal_attack(false,player);
         normal_defence(enemy);

         nr1:=player.punch-enemy.absorb;
         if nr1<1 then nr1:=0;
         dec(enemy.hps,nr1);

         if nr1<1 then begin
          sd(15,'You missed ');
          sd(global_plycol,oppo);
          d(config.textcolor,'!');
         end
         else begin
          sd(15,'You slash ');
          sd(global_plycol,oppo);
          sd(config.textcolor,' for ');
          sd(15,commastr(nr1));
          d(config.textcolor,' points!');
         end;

         outmessage[1]:=emptystr;
         outmessage[2]:=emptystr;
        end;

   end; {case .end.}

   user_save(enemy);
   user_save(player); {pucko 0.13}

   {write command to other node}
   put_other(ch);
  end;


  {-*- Evaluate Round -*-}

  if challenger=true then begin

   {load self}
   load_character(player,1,fs1);

   crlf;
   case cho of
    'Q':begin {quaff healing potions}
         sd(global_plycol,oppo);
         d(12,' quaffed some healing potions.');
        end;
    '1':begin
         case enemy.class of
          Assassin:begin
                    if nr1>0 then begin
                     sd(global_plycol,oppo);
                     sd(12,' backstabbed You for ');
                     sd(15,commastr(nr1));
                     d(12,' points!');
                    end
                    else begin
                     sd(global_plycol,oppo);
                     d(12,' tried to backstab You, but failed!');
                    end;
                   end;
           Paladin:begin
                    if nr1>0 then begin
                     sd(12,'Soulstrike hits You for ');
                     sd(15,commastr(nr1));
                     d(12,' points!');
                    end
                    else begin
                     sd(global_plycol,oppo);
                     d(12,' tried a Soulstrike against You!');
                     d(12,'But it FAILED!');
                    end;
                   end;
         end;
        end;
    'A':begin {attack}
         if nr1>0 then begin
          sd(global_plycol,oppo);
          sd(12,' slash You for ');
          sd(15,commastr(nr1));
          d(12,' points!');
         end
         else begin
          sd(global_plycol,oppo);
          d(12,' attacked You, but missed!');
         end;
        end;
    'C':begin {cast spell}

         sd(global_plycol,oppo);

         case random(4) of
          0: sd(config.textcolor,' waves '+sex3[enemy.sex]+' hands and ');
          1: sd(config.textcolor,' looks at you with a strange expression and ');
          2: sd(config.textcolor,' kisses '+sex3[enemy.sex]+' good luck charm and ');
          3: sd(config.textcolor,' swings a rod before '+sex[enemy.sex]+' and ');
         end;

         sd(config.textcolor,'utters : ');
         case player.castin of
          'A': i:=1;
          'B': i:=2;
          'C': i:=3;
          'D': i:=4;
          'E': i:=5;
          'F': i:=6;
          'G': i:=7;
          'H': i:=8;
          'I': i:=9;
          'J': i:=10;
          'K': i:=11;
          'L': i:=12;
         end;
         s:=spell_utter(enemy.class,i);
         d(global_talkcol,s);
         d(5,outmessage[1]);
         d(5,outmessage[2]);
        end;
    'B':begin {beg for mercy}
         sd(global_plycol,oppo);
         d(12,' begs for mercy!');
         sd(config.textcolor,'Spare ');
         sd(global_plycol,oppo+'s');

         if confirm(' miserable life','n')=true then begin
          crlf;
          sd(global_plycol,oppo);
          d(config.textcolor,' kneels before you.');
          sd(global_talkcol,'You are my master!');
          sd(config.textcolor,', ');
          sd(global_plycol,oppo);
          d(config.textcolor,' says.');

          put_other('+');
          beggar:=oppo;
          adios:=true;
         end
         else begin
          d(global_talkcol,'NO WAY!');
          put_other('-');
         end;
        end;

   end; {case .end.}

  end
  else begin {if challenger = false}
   case ch of
    'A':begin
         {}
        end;
    'B':begin {beg for mercy}
         d(15,'HAVE MERCY!');
         sd(15,'You kneel before ');
         sd(global_plycol,oppo);
         d(15,'.');
         d(15,'You plead for mercy!');
         crlf;
         sd(global_plycol,oppo);
         d(15,' looks at you...');

         put_own(Cm_ReadyForInput);
         cho:=get_com('+','-',cm_nothing,cm_nothing,cm_nothing,cm_nothing,
                              cm_nothing,cm_nothing,cm_nothing);

         case cho of
          '+':begin
               sd(global_plycol,oppo);
               d(config.textcolor,' has decided to spare your life!');
               d(config.textcolor,'Run while you still can....');
               beggar:=onliner.name;
               adios:=true;
              end;
          '-':begin
               sd(global_plycol,oppo);
               d(config.textcolor,' is not in a forgiving mood! FIGHT OR DIE!');
               crlf;
              end;
         end;
        end;

   end; {case .end.}

  end;

  {swap rolls, attacker becomes defender and vice verse}
  if challenger=true then begin
   challenger:=false;
  end
  else begin
   challenger:=true;
  end;

  if (enemy.hps<1) and (player.hps<1) then begin
   sd(15,'Both You and ');
   sd(global_plycol,oppo);
   d(15,' are DEAD!');
   crlf;
   adios:=true;
  end
  else if enemy.hps<1 then begin
   {add enemy as shadow player, so he can''t return before he has been
    frisked and removed of his earthly belongings.}

   add_shadow(SAdd,enemy,player.name2,'being frisked',0);

   {win text}
   sd(global_plycol,oppo);
   d(config.textcolor,' is DEAD!');
   d(14,'GOOD WORK!');
   crlf;

   {experience points for win}
   nr1:=random(50)+250;
   nr1:=nr1*enemy.level;
   sd(config.textcolor,'You are rewarded with ');
   sd(14,commastr(nr1));
   d(config.textcolor,' experience points!');
   inc(player.exp,nr1);

   {take opponents money}
   nr1:=enemy.gold;
   enemy.gold:=0;
   if nr1<1 then nr1:=0;
   sd(config.textcolor,'You take ');
   sd(14,commastr(nr1));
   sd(config.textcolor,' '+many_money(nr1)+' from ');
   sd(global_plycol,oppo);
   d(config.textcolor,'.');

   IncPlayerMoney(player,nr1);

   {swap equipment}
   Swap_Objects(player,enemy,true);

   {defeat/win rating}
   inc(enemy.p_defeats);
   inc(player.p_kills);

   {update "killedby" variable in relations data file}
   killed_by_stats(player,enemy);

   {allowed in}
   if nomore then begin
    Reduce_Player_Resurrections(player,true);
    Reduce_Player_Resurrections(enemy,false);
   end;

   {save users}
   user_save(enemy);
   user_save(player);
   adios:=true;

   {remove shadow}
   add_shadow(SRemove,enemy,'','',0);

  end
  else if player.hps<1 then begin
   d(12,'You are DEAD!');
   crlf;
   d(config.textcolor,'You fade away into the great abyss of darkness...');
   d(config.textcolor,'Don''t worry too much about your earthly belongings.');
   d(config.textcolor,'You are being frisked...');
   crlf;
   xplose(player);
   pause;
   adios:=true;
  end;

 until (adios) or (f_exists(onliner.comfile)=false);
 {Battle Loop **end**}

 {The Battle is Over!}

 if f_exists(onliner.comfile) then begin
  {remove the temporary file com file}
  if the_challenger then begin
   {read comfile until "O + OVER" has been found}
   done:=false;
   repeat
    loadsave_com(Fload,Commy,1,'');
    if (commy.com='O') and (commy.mess[1]='OVER') then begin
     done:=true;
    end;
   until done;

   delete_file(onliner.comfile);

   if f_exists(sayfile) then begin
    delete_file(sayfile);
   end;

  end
  else begin
   {writing signing off sign, so challenger may erase the file}
   commy.com:='O';
   commy.mess[1]:='OVER';
   loadsave_com(FSave,Commy,1,'');
  end;
 end; {if online.comfile exists}

 {enemy has fallen asleep at his terminal...}
 if round=1 then s:=''
            else s:='s';

 if hesleepy=true then begin
  {news-paper}
  newsy(true,
  'Online Duel',
  ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+oppo+config.textcol1+'!',
  ' '+uplc+oppo+config.textcol1+' chickened out after '+commastr(round)+' round'+s+'!',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
 end
 {player has fallen a sleep at his terminal...}
 else if mesleepy=true then begin
  {news-paper}
  newsy(true,
  'Online Duel',
  ' '+uplc+player.name2+config.textcol1+' challenged '+oppo+'!',
  ' '+uplc+player.name2+config.textcol1+' chickened out after '+commastr(round)+' round'+s+'!',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
 end
 {did someone beg for mercy?}
 else if beggar<>'' then begin
  if the_challenger=true then begin
   {news-paper}
   newsy(true,
   'Online Duel',
   ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+oppo+config.textcol1+'!',
   ' '+uplc+beggar+config.textcol1+' begged for mercy...and was spared!',
   ' It was all over in '+commastr(round)+' round'+s+'.',
   '',
   '',
   '',
   '',
   '',
   '');
  end;
 end
 {are both players dead?}
 else if (enemy.hps<1) and (player.hps<1) then begin
  if the_challenger=true then begin
   {news-paper}
   newsy(true,
   'Online Duel',
   ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+oppo+config.textcol1+'!',
   ' both players died!',
   ' ',
   ' The fight lasted for '+commastr(round)+' round'+s+'.',
   '',
   '',
   '',
   '',
   '');
  end;

  normal_exit;
 end
 {is enemy dead?}
 else if enemy.hps<1 then begin
  if the_challenger=true then begin
   {news-paper}
   newsy(true,
   'Online Duel',
   ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+oppo+config.textcol1+'!',
   ' '+uplc+oppo+config.textcol1+' was killed after a bloody duel!',
   ' '+after_battle(player.name2,enemy.name2),
   ' The fight lasted for '+commastr(round)+' round'+s+'.',
   '',
   '',
   '',
   '',
   '');
  end;
 end
 {is player dead?}
 else if player.hps<1 then begin
  {news-paper}
  newsy(true,
  'Online Duel',
  ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+oppo+config.textcol1+'!',
  ' '+uplc+player.name2+config.textcol1+' was killed.',
  ' '+after_battle(enemy.name2,player.name2),
  ' The fight lasted for '+commastr(round)+' round'+s+'.',
  '',
  '',
  '',
  '',
  '');

  normal_exit;
 end;

 pause;
 crlf;

end; {Online_Duel *end*}

end. {Unit Onduel .end.}
