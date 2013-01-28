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


Unit LevMast; {Usurper - Level Masters}

Interface

Procedure Level_Masters;

Implementation

Uses DDplus, Init, Cms,
     Jakob, Statusc, News,
     Various, Various2, Various3,
     Online, File_Io;

      {Level Masters}
const maxmasters=10;
      master :array[1..maxmasters] of string[9]=(
       'Akrappa',
       'Singuman',
       'Ishana',
       'Dzarrgo',
       'Agni',
       'Apollonia',
       'Sachmez',
       'Umilak',
       'Asanga',
       'Gregorius');

var
   sagee : s70;
   refresh : boolean;

Procedure Meny;
var justval : integer;
    i : byte;
    s : s70;
begin

 clearscreen;
 s:='Residence of '+sagee;
 d(5,s);
 d(5,mkstring(length(s),underscore));

 for i:=1 to maxmasters do begin
  if sagee=master[i] then begin
   display_text('LEVEL_MASTER_#'+commastr(i));
  end;
 end; {for i:= .end.}

 justval:=12;

 crlf;
 menu2(ljust('(R)eturn',justval));
 menu2('(L)evel Raise  ');
 menu('(H)elp team member');

 menu2(ljust('(S)tatus',justval));
 menu('(C)rystal Ball');

end; {Meny .end.}

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['L',
                       'S',
                       'C',
                       'R',
                       ReturnKey,
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   crlf;
   sd(config.textcolor,'Masters (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin

   crlf;
   sd(config.textcolor,'Masters (L,S,C,R,H,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;
end;

Function Master_Identification (mast :char): s70;
var s :s70;
begin
 s:='Akrappa';
 case mast of
  '1': s:=master[1];
  '2': s:=master[2];
  '3': s:=master[3];
  '4': s:=master[4];
  '5': s:=master[5];
  '6': s:=master[6];
  '7': s:=master[7];
  '8': s:=master[8];
  '9': s:=master[9];
  '0': s:=master[10];
 end;
 master_identification:=s;
end;

Procedure Level_Masters;
var
    s : s90;

    ch : char;

    x, yy, z : longint;

    zz : byte;

    i : integer;

    done,
    found,
    no_more,
    leave_level_masters : boolean;

    j,
    size : word;

    player0 : UserRec;

begin

 clearscreen;
 d(5,'Visit the wise men :');
 crlf;

 s:=master_identification(player.master);

 d(7,'(Press Enter to visit your current master : '+s+')');
 crlf;
 menu('[1] '+master[1]+', The Wise.');
 menu('[2] '+master[2]+', Bearer of Light and Fire.');
 menu('[3] '+master[3]+', The Last Northern Princess.');
 menu('[4] '+master[4]+', The Ancient Stone Lord.');
 menu('[5] '+master[5]+', The Shadow Dweller.');
 menu('[6] '+master[6]+', last Pupil of Sagan, the Sage.');
 menu('[7] '+master[7]+', The Great and Evil Witchmaster.');
 menu('[8] '+master[8]+', The Demon Tamer.');
 menu('[9] '+master[9]+', The Mysterious.');
 menu('[0] '+master[10]+', The Patriarch.');
 menu('[A] Abort');

 sd(config.textcolor,'Choice :');

 repeat
  ch:=upcase(getchar);
 until ch in ['A','0','1','2','3','4','5','6','7','8','9',ReturnKey];

 crlf;

 if (ch=ReturnKey) and (player.master<>'1') and (player.master<>'2') and
    (player.master<>'3') and (player.master<>'4') and
    (player.master<>'5') and (player.master<>'6') and
    (player.master<>'7') and (player.master<>'8') and
    (player.master<>'9') and (player.master<>'0') then begin
  player.master:='1';
 end;

 if ch=ReturnKey then ch:=player.master;

 case ch of
  'A':begin
       crlf;
       d(config.textcolor,'You walk away..');
       exit;
      end;
  '1': sagee:=master[1];
  '2': sagee:=master[2];
  '3': sagee:=master[3];
  '4': sagee:=master[4];
  '5': sagee:=master[5];
  '6': sagee:=master[6];
  '7': sagee:=master[7];
  '8': sagee:=master[8];
  '9': sagee:=master[9];
  '0': sagee:=master[10];
 end; {cas .end.}

 if ch<>player.master then begin
  crlf;
  sd(7,'You have not choosen Your normal Master : ');
  case player.master of
   '1': sd(14,master[1]);
   '2': sd(14,master[2]);
   '3': sd(14,master[3]);
   '4': sd(14,master[4]);
   '5': sd(14,master[5]);
   '6': sd(14,master[6]);
   '7': sd(14,master[7]);
   '8': sd(14,master[8]);
   '9': sd(14,master[9]);
   '0': sd(14,master[10]);
  end; {case .end.}
  crlf;

  if confirm('Do you wish to learn from '+sagee+' instead','n')=true then begin
   yy:=player.level*30000;
   d(config.textcolor,'This will cost You '+uyellow+commastr(yy)+config.textcol1+' '+many_money(yy)+'.');

   if player.gold<yy then begin
    d(config.textcolor,'And You can''t afford it!');
    pause;
    exit;
   end;

   if confirm('Pay','N')=false then begin
    exit;
   end;

   DecPlayerMoney(player,yy);

   player.master:=ch;
   crlf;
   d(15,'You have a new Master!');
   crlf;

   newsy(true,
   'Change of Master',
   ' '+uplc+player.name2+config.textcol1+' has choosen a new Master!',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');
   pause;

  end
  else begin
   exit;
  end;
 end;

 leave_level_masters:=false;

 repeat

  {update online location, if necessary}
  if (onliner.location<>onloc_master) then begin
   refresh:=true;
   onliner.doing:='visiting '+sagee;
   onliner.location:=onloc_master;
   add_onliner(OUpdateLocation,onliner);
  end;

  if player.ear=1 then begin
   who_is_here;
  end;

  display_menu(true,true);

  {get user-input}
  ch:=upcase(getchar);

  case ch of
   '?':begin {display menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'R':begin {leave level masters *start*}
        crlf;
        crlf;
        d(config.textcolor,'You leave your masters hut.');
        leave_level_masters:=true;
       end;  {leave level masters *end*}
   'S':begin {player status}
        status(player);
       end;
   'H':begin {help team member to raise a level, or two}
        crlf;
        if player.team='' then begin
         crlf;
         d(12,'You are not in a team!');
         sd(global_talkcol,'I can only summon your team mates!');
         sd(config.textcolor,', ');
         sd(global_plycol,sagee);
         d(config.textcolor,' says.');
        end
        else begin

         done:=false;
         repeat
          crlf;
          d(global_talkcol,'So, who should be summoned? (enter ? to see your team)');
          sd(config.textcolor,':');
          s:=get_string(20);
          s:=upcasestr(s);

          z:=0;
          found:=false;
          no_more:=false;

          if s='?' then begin
           {display members}
           display_members(player.team,true);
          end
          else begin
           done:=true;
           for i:=1 to 2 do begin
            size:=1;
            case i of
             1: size:=fs(fsplayer);
             2: size:=fs(fsnpc);
            end;

            for j:=1 to size do begin
             if (found) or (no_more) then begin
              break;
             end;

             load_character(player0,i,j);

             if (findsub(s,player0.name2)) and
                (player0.name2<>player.name2) and
                (player0.deleted=false) and
                (player0.name2<>global_delname2) and
                (player0.team=player.team) then begin

              x:=level_raise(player0.level,player0.exp);
              sd(global_plycol,player0.name2);

              if confirm(' ','n')=true then begin
               z:=i;
               found:=false;
               if is_online(player0.name2,online_player) then begin
                crlf;
                sd(global_talkcol,'Imbecill! ');
                sd(global_plycol,player0.name2);
                d(global_talkcol,' is wandering the streets and can''t be summoned!');
                pause;
               end
               else if player0.hps<1 then begin
                crlf;
                sd(global_talkcol,'Sorry! ');
                sd(global_plycol,player0.name2);
                d(global_talkcol,' is dead and can''t be summoned!');
                pause;
               end
               else if x<>0 then begin
                crlf;
                sd(global_plycol,player0.name2);
                sd(global_talkcol,' needs ');
                sd(15,commastr(x));
                d(global_talkcol,' experience points before '+sex2[player0.sex]+' can make a level!');
                pause;
               end
               else if player0.location=offloc_prison then begin
                crlf;
                sd(global_talkcol,'Impossible! ');
                sd(global_plycol,player0.name2);
                d(global_talkcol,' is in jail right now! Summoning is not possible!');
                pause;
               end
               else begin
                found:=true;
               end;
              end
              else begin
               if confirm('Continue Search','y')=false then begin
                no_more:=true;
               end;
              end;
             end;

            end; {for j:= .end.}

            if (found) or (no_more) then begin
             break;
            end;

           end; {for i:= .end.}
          end;

         until done;

         if found then begin {team mate found, summoning in process}

          if add_shadow(SAdd,player0,player.name2,'summoned by '+uplc+sagee+config.textcol1,0)=false then begin
           {unable to add player0}
           crlf;
           d(global_plycol,player0.name2+config.textcol1+' is busy right now!');
           pause;
          end
          else begin

           crlf;

           s:=player0.name2;
           zz:=1;
           sd(global_plycol,sagee);
           d(config.textcolor,' throws some green powder in the air, and a few seconds');
           sd(config.textcolor,'later ');
           sd(global_plycol,s);
           d(config.textcolor,' arrives in a puff of smoke!');
           pause;
           crlf;

           sd(global_plycol,sagee);
           d(config.textcolor,' inspects the new guest ...');
           if player.master<>player0.master then begin
            sd(global_talkcol,'This is not one of my pupils, ');
            sd(global_plycol,sagee);
            sd(config.textcolor,' says and points at ');
            sd(global_plycol,player0.name2);
            d(config.textcolor,'.');
            crlf;

            d(global_talkcol,'But I can teleport '+sex[player0.sex]+' to '+sex3[player0.sex]+' Master');

            if confirm('Teleport','Y')=true then begin
             sd(global_plycol,player0.name2);
             sd(config.textcolor,' was teleported to ');
             d(global_plycol,master_identification(player0.master));

             crlf;
             sd(config.textcolor,'You wait ..');

             make_delay_dots(2,4,300);

             crlf;

             if player0.ai='H' then found:=true
                               else found:=false;

             raise_player(player0,true,found,false,true,player.name2);

             sd(global_plycol,player0.name2);
             d(config.textcolor,' has returned! (a bit dizzy, and a bit stronger!)');
             sd(global_plycol,player0.name2);
             d(config.textcolor,' hugs you, waves farewell and disappears out through the door.');
            end
            else begin
             d(global_talkcol,'No, forget it!');
            end;
           end
           else begin
            sd(global_plycol,player0.name2);
            d(config.textcolor,' bows deeply before '+sex3[player0.sex]+' teacher.');
            d(config.textcolor,uplc+sagee+config.textcol1+' and '+uplc+player0.name2+config.textcol1+' then walk upstairs.');

            crlf;
            sd(config.textcolor,'You wait ..');
            make_delay_dots(2,4,300);

            crlf;

            if player0.ai='H' then found:=true
                              else found:=false;

            raise_player(player0,true,found,false,true,player.name2);

            sd(global_plycol,player0.name2);
            d(config.textcolor,' has returned!');
            d(config.textcolor,uplc+player0.name2+config.textcol1+' hugs you, waves farewell and disappears out through'
              +' the door.');
           end;

           add_shadow(SRemoveShadows,player,'','going to sleep...',0);
          end;
         end
         else if (z=0) and (no_more=false) then begin
          d(15,'Sorry, couldn''t find that character.');
          crlf;
          pause;
         end;
        end;

       end;
   'C':begin {Crystal Ball, info on other player}
        crlf;
        d(config.textcolor,'So, who do you wish to know more about ?');
        sd(config.textcolor,':');
        s:=get_string(20);
        s:=upcasestr(s);

        z:=0;
        zz:=0;
        no_more:=false;
        for i:=1 to 2 do begin

         size:=1;
         case i of
          1: size:=fs(FsPlayer);
          2: size:=fs(FsNpc);
         end;

         for j:=1 to size do begin
          if zz=0 then begin
           load_character(player0,i,j);

           if (findsub(s,player0.name2)) and
              (player0.name2<>player.name2) and
              (player0.deleted=false) and
              (player0.name2<>global_delname2) then begin

            sd(global_plycol,player0.name2);
            if confirm(' ','n')=true then begin
             z:=i;
              if player0.king=true then begin
              d(global_talkcol,'You will get no information of the King! '+uplc+sagee+config.textcol1+' declares.');
              d(global_talkcol,'Such information must not fall into enemy hands!');
              crlf;
              {a:='Empty';}
              pause;
             end
             else begin
              {*can the player pay for this service}
              z:=player0.level*500;
              sd(global_talkcol,'This little service will cost you ');
              d(14,commastr(z)+utalkc+' '+many_money(z)+'.');
              if player.gold<z then begin
               d(global_talkcol,'And you don''t have that kind of '+config.moneytype+'.');
               crlf;
               pause;
               zz:=1;
              end;
              if player.gold>=z then begin
               if confirm('Pay','n')=true then begin
                DecPlayerMoney(player,z);

                s:=player0.name2;
                zz:=1;
                d(config.textcolor,uplc+sagee+config.textcol1+' mumbles a couple of spells and then gives you '+uplc+s
                  +config.textcol1+'!');
                status(player0);
                break;

               end;
              end;
             end;
            end
            else begin
             if confirm('Continue Search','y')=false then begin
              no_more:=true;
              break;
             end;
            end;
           end;
          end
          else begin
           break;
          end;
         end; {for j:= .end.}

         if no_more then break;

        end; {for i:= .end.}

        if z=0 then begin
         d(15,'Sorry, couldn''t find that character.');
         crlf;
         pause;
        end;

       end;
   'L':begin {level raise *start*}
        crlf;

        if player.level>99 then begin
         crlf;
         d(config.textcolor,uplc+sagee+config.textcol1+' clears his throat and speaks : '+utalkc+'You cannot receive further');
         d(global_talkcol,'levels from me. You must seek help elsewhere from now on.');
         d(global_talkcol,'But I think you can go far if you follow your instincts.');
         d(global_talkcol,'But now you must leave me, I am old and tired.');
         crlf;
         pause;
        end
        else begin
         crlf;
         sd(global_plycol,sagee);
         d(config.textcolor,' looks at you carefully; ');
         crlf;
         d(global_talkcol,'You are a fine looking '+race_display(2,player.race,0));

         x:=level_raise(player.level,player.exp);

         if x<>0 then begin
          d(global_talkcol,'but you are not yet fully qualified to receive a raise to level '+commastr(player.level+1)+'.');
          d(global_talkcol,'You need '+uwhite+commastr(x)+utalkc+' experience points!');
          crlf;
          pause;
          z:=0;
         end
         else begin

          {Level Raise!}
          raise_player(player,true,false,true,true,'');

         end;
        end;
       end; {level raise *end*}

  end; {case .end.}

 until leave_level_masters=true;

end; {Level_Masters *end*}

end. {Unit LevMast .end.}
