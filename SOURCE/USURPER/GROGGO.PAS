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



Unit Groggo; {Usurper - Groggo the Mad Mage}

Interface

Procedure Groggos_Magic;

Implementation

Uses Init, Cms, Jakob,
     Various2, Statusc, Mail,
     News, Various, Online,
     File_Io;

var
   owner : s70;
   refresh : boolean;

Procedure Meny;
begin
 clearscreen;
 crlf;
 d(5,owner);
 d(5,mkstring(length(owner),underscore));
 sd(global_plycol,owner);
 d(config.textcolor,' is a very very old, and very very mad, magician.');
 d(config.textcolor,'He is not to be trusted in business, and you must be');
 d(config.textcolor,'very cautious when you talk to him. He has a nasty habit');
 d(config.textcolor,'of cursing people and creatures just for the hell of it.');
 sd(config.textcolor,'You try to keep these things in mind when you enter ');
 d(global_plycol,owner+'s');
 d(config.textcolor,'shack...');
 crlf;
 case random(10) of
  0:begin
     sd(global_talkcol,'Yes, what do you want?');
     d(config.textcolor,', the old goat asks.');
    end;
  1:begin
     sd(global_talkcol,'Why are you here?');
     d(config.textcolor,', the old man asks.');
    end;
  2:begin
     sd(global_talkcol,'You have come to the right person');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' declares.');
    end;
  3:begin
     sd(global_talkcol,'I''m waiting...');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' mutters.');
    end;
  4:begin
     sd(global_talkcol,'People who come here often have enemies.');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' mutters.');
    end;
  5:begin
     sd(global_talkcol,'You have a bad breath!');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' remarks.');
    end;
  6:begin
     sd(global_talkcol,'Do you need help?');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' mutters');
    end;
  7:begin
     sd(global_talkcol,'Tell me what you want, or get out of here!');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' screams.');
    end;
  8:begin
     sd(global_talkcol,'You remind me of somebody, and that person is dead!');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' laughs.');
    end;
  9:begin
     sd(global_talkcol,'Filthy '+race_display(2,player.race,0)+'!');
     sd(config.textcolor,', ');
     sd(global_plycol,owner);
     d(config.textcolor,' mumbles when he sees you.');
    end;
 end; {case .end.}

 crlf;
 menu('(R)eturn to street');
 menu('(B)uy Service');
 menu('(S)tatus');

 {g†torna som galningen skall st„lla!}
 {ibland kastar Groggo spells p† den som ska k”pa}
end;

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'S',
                       'B',
                       chr(13),
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
   sd(config.textcolor,owner+'s Hut (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin
   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,owner+'s (R,S,B,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end;

Procedure Groggos_Magic;
var
    tempin : s70;
    a:^string;
    s : ^s70;
    yy, i, x, y : longint;
    ch : char;
    pl0 : ^UserRec;
    found,nogo : boolean;

begin

 new(pl0);
 new(a);
 new(s);

 {h„mtar Groggoss namn fr†n .CFG}
 owner:=cfg_string(21);
 if owner='' then owner:='Groggo';

 repeat

  if onliner.location<>onloc_madmage then begin
   refresh:=true;
   onliner.location:=onloc_madmage;
   onliner.doing:=location_desc(onliner.location);
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
   'B':begin
        crlf;
        crlf;
        sd(global_talkcol,'I need your help ');
        sd(global_plycol,owner);
        sd(global_talkcol,'!');
        d(config.textcolor,', you explain to the old man.');
        crlf;

        case random(9) of
         0:begin
            sd(global_talkcol,'Yes of course!, everybody needs ');
            sd(global_plycol,owner);
            sd(global_talkcol,'!');
            d(config.textcolor,', the old goat replies.');
           end;
         1:begin
            sd(global_talkcol,'Be more specific!');
           end;
         2:begin
            d(global_talkcol,'You have come to the right person!');
           end;
         3:begin
            d(global_talkcol,'And...');
           end;
         4:begin
            d(global_talkcol,'My knowledge and reputation is wellknown!');
           end;
         5:begin
            d(global_talkcol,'Doesn''t surprise me at all, by the looks of you!');
           end;
         6:begin
            d(global_talkcol,'If you can pay, we can do business.');
           end;
         7:begin
            d(global_talkcol,'Don''t we all!');
           end;
         8:begin
            d(global_talkcol,'Alright, I can help everybody.');
           end;
        end; {case .end.}

        sd(global_talkcol,'What kind of service do you need?');
        d(config.textcolor,', the old man asks.');

        repeat
        {gl”m ej att „ndra under oxo, samma sjok!}
        crlf;
        menu('(S)ummon Demon against other player');
        menu('(C)ast Disease');
        menu('(I)nfo');
        menu('(A)bort');
        sd(config.textcolor,':');

        repeat
         {get user input}
         ch:=upcase(getchar);

         if (ch='C') or (ch='S') then begin
          if player.darknr<1 then begin
           {no dark deeds left}
           no_dark_deeds;
           ch:=' ';
           crlf;
           menu('(S)ummon Demon');
           menu('(C)ast Disease');
           menu('(I)nfo');
           menu('(A)bort');
           sd(config.textcolor,':');
          end;
         end;
        until ch in ['I','S','C','A'];

        case ch of
         'I':begin
              crlf;
              d(config.textcolor,'*Risks involved with Disease Spells*');
              d(config.textcolor,owner+' reminds you that there is a small risk');
              d(config.textcolor,'that the spell will misfire. In that');
              d(config.textcolor,'case it will backfire upon its caster.');
              d(config.textcolor,'You won''t get your '+config.moneytype+' back if all fails.');
              d(config.textcolor,owner+' puts himself at great personal risk here.');
              d(config.textcolor,'(Especially when it comes to dealing with clerics,');
              d(config.textcolor,'alchemists and magicians, who have strong');
              d(config.textcolor,'resistance to magic).');
              crlf;
              pause;
              crlf;
              d(config.textcolor,'*Risks involved with Summoned Demons*');
              d(config.textcolor,'There is a small risk that the summoning will fail.');
              d(config.textcolor,'In these cases the Demon can attack random targets. Innocent');
              d(config.textcolor,'Characters can get killed. You won''t get');
              d(config.textcolor,'your '+config.moneytype+' back if this operation fails.');
              crlf;
              pause;
              ch:='-';
             end;
         'C':begin
              crlf;
              d(config.textcolor,'So, who shall get a disease ?');
              sd(config.textcolor,':');

              found:=false;
              nogo:=false;

              tempin:=get_string(20);
              s^:=upcasestr(player.name2);
              a^:=upcasestr(tempin);

              for i:=1 to fs(FsPlayer) do begin
               load_character(pl0^,1,i);

               if (findsub(a^,pl0^.name2)) and (pl0^.name2<>player.name2) and (pl0^.deleted=false) then begin
                sd(global_plycol,pl0^.name2);
                if confirm('','N')=true then begin
                 found:=true;
                 break;
                end
                else begin
                 if confirm('Continue Search','N')=false then begin
                  nogo:=true;
                  break;
                 end;
                end;

               end;
              end;

              if (found=false) and (nogo=false) then begin
               for i:=1 to fs(FsNpc) do begin
                load_character(pl0^,2,i);

                if (findsub(a^,pl0^.name2)) and (pl0^.name2<>player.name2) and (pl0^.deleted=false) then begin
                 sd(global_plycol,pl0^.name2);
                 if confirm('','N')=true then begin
                  found:=true;
                  break;
                 end
                 else begin
                  if confirm('Continue Search','N')=false then break;
                 end;
                end;
               end;
              end;

              if found then begin
               if config.leveldiff<>0 then begin
                x:=player.level-pl0^.level;
                if x>config.leveldiff then begin
                 d(global_talkcol,'Nah, that wouldn''t be fair!');
                 found:=false;
                end;
               end;

               if (pl0^.blind=true) and (pl0^.plague=true) and
                  (pl0^.leprosy=true) and (pl0^.smallpox=true) and
                  (pl0^.measles=true) then begin
                d(global_talkcol,'That fellow already suffers from ALL diseases!');
                found:=false;
               end;

               if (pl0^.class in [Alchemist,Cleric,Magician,Sage]) or
                  (pl0^.disres>75) then begin

                sd(global_talkcol,'There is a great risk of failure here!');
                sd(config.textcolor,', ');
                sd(global_plycol,owner);
                d(config.textcolor,' says.');

                d(global_talkcol,'Your foes class make '+sex[pl0^.sex]+' a difficult target!');

                if confirm('Continue anyway','n')=false then begin
                 found:=false;
                end;

               end;

               if found=true then begin
                yy:=pl0^.level*14000;
                sd(config.textcolor,'This attempt will cost ');
                sd(14,commastr(yy));
                d(config.textcolor,' '+many_money(yy)+'!');
                if confirm('Go ahead and pay','N')=true then begin
                 if player.gold<yy then begin
                  d(12,'You don''t have the '+config.moneytype+'!');
                  found:=false;
                 end;
                end
                else begin
                 found:=false;
                end;
               end;


               if found=true then begin

                {GO AHEAD WITH EVIL DEED}
                dec(player.darknr);

                x:=5;
                case pl0^.class of
                 Alchemist : x:=1;
                 Assassin  : x:=4;
                 Barbarian : x:=8;
                 Bard      : x:=5;
                 Cleric    : x:=3;
                 Jester    : x:=7;
                 Magician  : x:=3;
                 Paladin   : x:=4;
                 Ranger    : x:=6;
                 Sage      : x:=2;
                 Warrior   : x:=7;
                end;

                if pl0^.disres>10 then inc(x);
                if pl0^.disres>30 then inc(x);
                if pl0^.disres>60 then inc(x);
                if pl0^.disres>100 then inc(x);
                if pl0^.disres>150 then inc(x);
                if pl0^.disres>240 then inc(x);

                if random(x)<3 then begin
                 {Successful Spellcasting}
                 crlf;
                 d(config.textcolor,'Groggo looks at you.');
                 sd(global_talkcol,'Very well, I shall cast a Disease Spell');
                 sd(14,'upon this ');
                 sd(global_plycol,pl0^.name2);
                 d(global_talkcol,'!');
                 crlf;

                 decplayermoney(player,yy);

                 s^:='Black Magic used against You!';

                 case random(5) of
                  0:begin
                     pl0^.blind:=true;

                     post(MailSend,
                     pl0^.name2,
                     pl0^.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     umailheadc+s^+config.textcol1,
                     mkstring(length(s^),underscore),
                     'You have been cursed! You are Blind!',
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
                    end;
                  1:begin
                     pl0^.plague:=true;
                     post(MailSend,
                     pl0^.name2,
                     pl0^.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     umailheadc+s^+config.textcol1,
                     mkstring(length(s^),underscore),
                     'You have been cursed! You have the Plague!',
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
                    end;
                  2:begin
                     pl0^.smallpox:=true;
                     post(MailSend,
                     pl0^.name2,
                     pl0^.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     umailheadc+s^+config.textcol1,
                     mkstring(length(s^),underscore),
                     'You have been cursed! You have Smallpox!',
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
                    end;
                  3:begin
                     pl0^.measles:=true;
                     post(MailSend,
                     pl0^.name2,
                     pl0^.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     umailheadc+s^+config.textcol1,
                     mkstring(length(s^),underscore),
                     'You have been cursed! You have the Measles!',
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
                    end;
                  4:begin
                     pl0^.leprosy:=true;
                     post(MailSend,
                     pl0^.name2,
                     pl0^.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     umailheadc+s^+config.textcol1,
                     mkstring(length(s^),underscore),
                     'You have been cursed! You have Leprosy!',
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
                    end;
                 end;
                 user_save(pl0^);
                 pause;
                end
                else begin


                 {Failed Spellcasting}
                 d(config.textcolor,'After have mumbled the standard formulas,');
                 d(config.textcolor,owner+' suddenly stumbles to the ground, white');
                 d(config.textcolor,'in the face...');

                 sd(global_talkcol,'The spell misfired!');
                 d(config.textcolor,', the old man whispers.');

                 crlf;

                 s^:='Failed Black Magic!';

                 post(MailSend,
                 pl0^.name2,
                 pl0^.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 umailheadc+s^+config.textcol1,
                 mkstring(length(s^),underscore),
                 uplc+player.name2+config.textcol1+' tried to cast a disease spell on you!',
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

                 decplayermoney(player,yy);
                 pl0^.blind:=true;

                 {news-paper}
                 newsy(true,
                 'Dirty Attempt!',
                 ' '+uplc+player.name2+config.textcol1+' tried to cast a Disease spell on '+uplc+pl0^.name2
                    +config.textcol1+'!',
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
              end;
              pause;
             end;
         'S':begin
              crlf;
              d(config.textcolor,'So, who shall meet a Demon ?');
              sd(config.textcolor,':');
              tempin:=get_String(30);
              s^:=upcasestr(player.name2);
              a^:=upcasestr(tempin);

              for i:=1 to fs(FsPlayer) do begin
               load_character(pl0^,1,i);

               if (findsub(a^,pl0^.name2)) and
                  (pl0^.name2<>player.name2) and
                  (pl0^.deleted=false) then begin

                sd(global_plycol,pl0^.name2);
                if confirm('','N')=true then begin
                 x:=player.level-pl0^.level;
                 if x>config.leveldiff then begin
                  d(global_talkcol,'Nah, that wouldn''t be fair!');
                  break;
                 end;

                 if pl0^.class in [Alchemist,Cleric,Magician,Sage] then begin
                  sd(global_talkcol,'There is a great risk of failure here!');
                  sd(config.textcolor,', ');
                  sd(global_plycol,owner);
                  d(config.textcolor,' says.');

                  d(global_talkcol,'Your foes class make '+sex[pl0^.sex]+' a difficult target!');

                  if confirm('Continue anyway','n')=false then begin
                   break;
                  end;

                 end;

                 crlf;
                 yy:=pl0^.level*50000;
                 if yy<0 then yy:=9000;

                 d(config.textcolor,'This will cost '+uyellow+commastr(yy)+config.textcol1+' '+many_money(yy)+'!');
                 if confirm('Go ahead and pay','n')=true then begin
                  if player.gold<yy then begin
                   d(12,'You don''t have the '+config.moneytype+'!');
                   break;
                  end;
                 end
                 else begin
                  break;
                 end;
                 decplayermoney(player,yy);
                 dec(player.darknr);

                 x:=5;

                 case pl0^.class of
                  Alchemist : x:=2;
                  Assassin  : x:=5;
                  Barbarian : x:=11;
                  Bard      : x:=6;
                  Cleric    : x:=4;
                  Jester    : x:=8;
                  Magician  : x:=4;
                  Paladin   : x:=5;
                  Ranger    : x:=7;
                  Sage      : x:=3;
                  Warrior   : x:=10;
                 end;

                 if random(x)=0 then begin
                  {Failed Spellcasting}
                  crlf;
                  d(config.textcolor,'After have mumbled the standard formulas,');
                  d(config.textcolor,owner+' suddenly stumbles to the ground, white');
                  d(config.textcolor,'in the face...');

                  sd(global_talkcol,'The spell misfired!');
                  d(config.textcolor,', the old man whispers.');

                  crlf;
                  d(config.textcolor,'You wonder who might stumble over a straying Demon,');
                  d(config.textcolor,'now lurking in the Dungeons...');
                  crlf;

                  {post}
                  post(MailSend,
                  pl0^.name2,
                  pl0^.ai,
                  false,
                  mailrequest_nothing,
                  '',
                  umailheadc+'Fowl Deed!'+config.textcol1,
                  mkstring(10,underscore),
                  uplc+player.name2+config.textcol1+' tried to summon a Demon against you!',
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

                  pl0^.blind:=true;

                  {news-paper}
                  newsy(true,
                  'Nasty Attempt!',
                  ' '+uplc+player.name2+config.textcol1+' tried to summon a Demon against '+uplc+pl0^.name2
                     +config.textcol1+'!',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  {who shall the Demon jump instead?}
                  x:=fs(FsPlayer)-1;
                  if x<1 then begin
                   inc(x);
                  end;

                  y:=0;
                  repeat
                   y:=random(x);
                  until y>0;

                  inc(y);
                  load_character(pl0^,1,y);
                  inc(pl0^.haunt);
                  user_save(pl0^);

                  pause;
                  break;
                 end
                 else begin
                  crlf;
                  d(global_talkcol,'Very well, I shall summon a Demon.');
                  sd(global_talkcol,'It will meet with ');
                  sd(global_plycol,pl0^.name2);
                  sd(global_talkcol,' next time '+sex2[pl0^.sex]);
                  d(global_talkcol,' visits the dungeons!');
                  sd(config.textcolor,', ');
                  sd(global_plycol,owner);
                  d(config.textcolor,' explains.');
                  crlf;

                  {news-paper}
                  newsy(true,
                  'Nightmares',
                  ' '+uplc+pl0^.name2+config.textcol1+' woke up in the middle of the night!',
                  ' '+uplc+pl0^.name2+config.textcol1+' had a terrible nightmare. It involved Demons',
                  ' and danger lurking in the shadows.',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  {post nightmare mail to pl0}
                  post_nightmare(pl0^);

                  inc(pl0^.haunt);

                  user_save(pl0^);

                  pause;
                  break;
                 end;
                end
                else begin
                 if confirm('Continue search','Y')=false then break;
                end;
               end;
              end;
              end;
        end;
        until ch='A';
       end;

  end; {case .end.}

 until ch='R';


 {dispose pointer vars}
 dispose(pl0);
 dispose(a);
 dispose(s);

end; {Groggos_Magic *end*}

end. {Unit Groggo .end.}
