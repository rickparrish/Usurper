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
Unit Recruite; {Usurper - Recruite / Bribe NPc characters to your team}

Interface

Procedure Recruite_NPC;

Implementation

Uses Init, Cms, Jakob,
     Statusc, Mail, News,
     Various, Various2, Various3,
     Relation, Online, File_Io;

Var refresh : boolean;

Procedure Meny;
begin
 clearscreen;
 crlf;
 d(5,'-*- Hall of Recruitment -*-');
 crlf;
 d(config.textcolor,'The hall is filled with men and women, eager to join you');
 d(config.textcolor,'in your quest. You can expect a lot of shady characters hanging');
 d(config.textcolor,'around here to. Be wary of your company.');
 crlf;
 menu('(L)ist hardy males/females');
 menu('(E)xamine Character');
 menu('(H)ire or Bribe character');
 menu('(S)tatus');
 menu('(R)eturn');

end; {meny *end*}

Procedure Menu_Display( force: boolean; short : boolean );
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;
   crlf;
   sd(config.textcolor,'Recruitment (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,'Recruit (L,E,H,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {menu_display *end*}

Procedure Recruite_NPC;
var
    cho : char;

    found,
    abort,
    go_ahead : boolean;

    s,
    a,
    traitor : s70;

    i,
    j,
    size,
    record_nr : word;
    record_type : byte;

    yy,
    xx,
    loyalty : longint;

    Player0,
    Player1 : ^UserRec;


    Relation : RelationRec;

begin

 {init pointer vars}
 new(player0);
 new(player1);

 {intro text}
 crlf;
 d(config.textcolor,'You enter the recruitment area. Everybody in here seems');
 d(config.textcolor,'to be occupied with making deals and bragging about their');
 d(config.textcolor,'latest feat.');

 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_recruit then begin
   refresh:=true;
   onliner.location:=onloc_recruit;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {display menu}
  menu_display(true,true);

  {get user-input}
  cho:=upcase(getchar);

  {evaluate user-input}
  case cho of
   '?':begin {menu}
        if player.expert=true then menu_display(true,false)
                              else menu_display(false,false);
       end;
   'S':begin {status}
        status(player);
        crlf;
       end;
   'E':begin {examine NPC}
        crlf;
        crlf;
        d(config.textcolor,'Who would you like to Examine ?');
        sd(config.textcolor,':');

        {get search string}
        s:=get_string(25);

        for i:=1 to fs(FsNpc) do begin
         load_character(player0^,2,i);

         if (findsub(s,player0^.name2)) and
            (player0^.deleted=false) and
            (player0^.name2<>player.name2) then begin

          if confirm(uplc+player0^.name2+config.textcol1,'N')=true then begin
           clearscreen;
           status(player0^);
           break;
          end
          else begin
           crlf;
           if confirm('Continue Search','Y')=false then break
          end;
         end;
        end; {for i:= .end.}

       end;

   'H':begin {Hire / Bribe Npc to your team}

        if player.team='' then begin
         crlf;
         d(config.textcolor,'You don''t belong to a team!');
        end
        else begin
         crlf;
         crlf;
         d(config.textcolor,'Who would you like to recruit ?');
         sd(config.textcolor,':');

         s:=get_string(20);

         {init}
         record_nr:=0;
         record_type:=0;
         found:=false;
         abort:=false;

         for i:=1 to 2 do begin

          case i of
           1: size:=fs(FsPlayer);
           2: size:=fs(FsNpc);
          end; {case .end.}

          for j:=1 to size do begin

           {load character}
           load_character(player0^,i,j);

           if (findsub(s,player0^.name2)) and
              (player0^.ai='C') and
              (player0^.name2<>player.name2) and
              (player0^.hps>0) and
              (player0^.deleted=false) and
              (player0^.name1<>global_delname1) and
              (player0^.name2<>global_delname2) then begin

            if confirm(uplc+player0^.name2+config.textcol1,'N')=true then begin
             if player0^.team=player.team then begin
              sd(global_plycol,player0^.name2);
              d(12,' is already in your team!');
             end
             else if is_online(player0^.name2,online_player) then begin
              sd(global_plycol,player0^.name2);
              d(12,' is busy right now. Try again later.');
             end
             else begin
              record_type:=i;
              record_nr:=j;
              found:=true;
             end;
            end
            else begin
             if confirm('Continue Search','Y')=false then begin
              abort:=true;
             end;
            end;
           end;
           if (found) or (abort) then break;
          end; {for j:= .end.}
          if (found) or (abort) then break;
         end; {for i:= .end.}

         if (not abort) and (not found) then begin
          could_not_locate_character;
         end;

         {Lets load our target}
         if record_nr>0 then begin
          {is team full already+}
          xx:=0;

          go_ahead:=true;
          for i:=1 to 2 do begin

           case i of
            1: size:=fs(FsPlayer);
            2: size:=fs(FsNpc);
           end; {case .end.}

           for j:=1 to size do begin

            load_character(player0^,i,j);

            if (player.team=player0^.team) and
               (player0^.deleted=false) and
               (player0^.name2<>global_delname2) then begin

             inc(xx);

             if xx>4 then begin
              d(12,'Your team is full!');
              crlf;
              go_ahead:=false;
             end;
            end;

            if not go_ahead then break;
           end; {for j:= .end.}
           if not go_ahead then break;
          end; {for i:= .end.}

          if go_ahead then begin

           {loading right character, #record_nr}

           {load character}
           load_character(player0^,record_type,record_nr);

           if add_shadow(SAdd,player0^,player.name2,'negotiating with '+uplc+player.name2+config.textcol1,0)=false then begin
            {unable to add player0}
            crlf;
            d(global_plycol,player0^.name2+config.textcol1+' is busy right now!');
            pause;
           end
           else begin

            if player0^.king then begin
             d(12,'The '+kingstring(player0^.sex)+' scorns your pathetic attempt to interfere with the Royal affairs!');
             d(12,'Your relation with the Royals is not improving..');
             {worsen pl0:s attitude to player}
             Update_Relation(Relation_Worsen,2,player0^,player,false,false);

             pause;
            end
            {npc belongs to another team!}
            else if player0^.team<>'' then begin

             sd(global_plycol,player0^.name2);
             sd(config.textcolor,' belongs to ');
             d(global_teamcol,player0^.team);

             if confirm('Try to BRIBE '+sex[player0^.sex]+' over to your team','n')=true then begin
              d(config.textcolor,'How much do you offer (max '+uyellow+commastr(player.gold)+config.textcol1+' '
               +many_money(player.gold)+')');
              sd(config.textcolor,':');

              {get bribe}
              xx:=get_number(0,player.gold);

              if (xx>0) and (xx<=player.gold) then begin

               {how much should the NPC:n request / in gold}
               loyalty:=player0^.loyalty;
               yy:=player0^.maxhps*8000;
               yy:=yy+(loyalty*5000);

               if xx<yy then begin
                crlf;
                sd(global_plycol,player0^.name2);
                d(config.textcolor,' laughs at your pathetic offer!');
                crlf;

                {News Paper}
                newsy(true,
                'Bribe Attempt!',
                ' '+uplc+player.name2+config.textcol1+' tried to bribe '+uplc+player0^.name2+config.textcol1+'!',
                ' But '+uplc+player0^.name2+config.textcol1+' refused to leave '+sex3[player0^.sex]+' team!',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

                {inform team-members of bribe attempt}
                Team_Report_All(player0^.team, {team to send message to}
                                '', {player name to exclude}
                                'Bribe Attempt', {news-header}
                                mailrequest_nothing, {mailrequest_constant}
                                uplc+player.name2+config.textcol1+' tried to bribe '+uplc+player0^.name2
                                    +config.textcol1+'!',
                                uplc+player0^.name2+config.textcol1+' rejected the bribe.',
                                '',
                                '');

               end
               else begin

                if xx>yy then begin
                 yy:=xx;
                end;

                {a turncoat!}
                sd(global_plycol,player0^.name2);
                sd(config.textcolor,' agrees to switch sides if you pay '+sex[player0^.sex]+' ');
                sd(14,commastr(yy));
                d(config.textcolor,' '+many_money(yy)+'!');

                crlf;
                if confirm('Pay the Dog','n')=true then begin
                 decplayermoney(player,yy);
                 incplayermoney(player0^,yy);

                 a:=player0^.team;
                 player0^.team   :=player.team;
                 player0^.loyalty:=player0^.loyalty div 2;
                 player0^.teampw :=player.teampw;
                 player0^.cturf  :=player.cturf;
                 player0^.teamrec:=player.teamrec;

                 if player0^.loyalty<0 then player0^.loyalty:=0;

                 {save user}
                 user_save(player0^);

                 crlf;
                 sd(global_plycol,player0^.name2);
                 d(config.textcolor,' now fights for your cause!');

                 {News Paper}
                 newsy(true,
                 'Traitor!',
                 ' '+uplc+player0^.name2+config.textcol1+' was bribed into '+utec+player0^.team+config.textcol1+'.',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '');

                 traitor:=player0^.name2;

                 {writing a letter to the others about player0^ deserting}
                 for j:=1 to fs(FsPlayer) do begin

                  {load character}
                  load_character(player1^,1,j);

                  if (player1^.team=a) then begin

                   if is_online(player1^.name2,online_player)=true then begin
                    {send online info}
                    online_send_to_player(player1^.name2,online_player,uplc+traitor+config.textcol1+' has left your team!');
                   end
                   else begin
                    {mail}
                    post(MailSend,
                    player1^.name2,
                    player1^.ai,
                    false,
                    mailrequest_nothing,
                    '',
                    umailheadc+'Team'+config.textcol1,
                    mkstring(4,underscore),
                    uplc+traitor+config.textcol1+' was bribed by a rival gang!',
                    'The scoundrel left your great team for an handful of '+many_money(2)+'!',
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

                 end; {for j:= .end.}

                end
                else begin
                 d(12,'Aborted.');
                 crlf;
                end;
               end;
              end
              else begin
               d(15,'Get real!');
               crlf;
              end;
             end;
            end
            else begin

             {npc is not with another team}

             if (player.dark>1500) and (player0^.class=Paladin) then begin
              {NPC paladins don't like evil characters!}
              crlf;
              d(global_talkcol,'Get out of my face, You scum!');
              d(global_plycol,player0^.name2+config.textcol1+' looks at you with contempt!');
              d(config.textcolor,'(It is maybe not such a good idea to approach');
              d(config.textcolor,'Paladins when your character is as dark as it is)');
              crlf;
              pause;
             end
             else if (player.dark>500) and (player0^.class=paladin) and (player.race=troll) then begin
              {NPC paladins don't like Trolls!}
              crlf;
              d(global_talkcol,'Get lost you pagan troll!');
              d(global_plycol,player0^.name2+config.textcol1+' looks at you with contempt!');
              d(config.textcolor,'(Paladins don''t like trolls. Thats the way it is.)');
              crlf;
              pause;
             end
             else begin

              {load relation}
              social_relation(player,player0^,relation);

              {correct relation}
              correct_relation(player.name2,relation);

              {is the relation bad?}
              if relation.relation2 in [
                                        global_RelationEnemy,
                                        global_RelationAnger,
                                        global_RelationHate] then begin
               crlf;
               d(2,relation_string(true,player0^.name2,player.name2,relation.relation2));

               crlf;
               d(12,'Get out of my face!');
               pause;
              end
              else begin

               yy:=player0^.maxhps*400;

               crlf;
               sd(config.textcolor,'You approach '+uplc+player0^.name2);
               d(config.textcolor,' and ask '+sex[player0^.sex]+' if '+sex2[player0^.sex]+' wants to join your gang.');
               sd(global_plycol,player0^.name2+config.textcol1+' demands ');
               sd(14,commastr(yy));
               d(config.textcolor,' '+many_money(yy)+' to join!');

               if player.gold<yy then begin
                d(config.textcolor,'But you don''t have that kind of '+config.moneytype+'!');
                crlf;
                pause;
               end
               else begin
                if confirm('Pay','n')=true then begin

                 decplayermoney(player,yy);
                 incplayermoney(player0^,yy);
                 player0^.team     :=player.team;
                 player0^.teampw   :=player.teampw;
                 player0^.gym_owner:=player.gym_owner;

                 {save user}
                 user_save(player0^);

                 crlf;
                 sd(global_plycol,player0^.name2);
                 d(config.textcolor,', the '+race_display(2,player0^.race,0)+', now fights for your team!');
                 crlf;

                 {news-paper}
                 case random(2) of
                  0:begin
                     {news-paper}
                     newsy(true,
                     'Gang Recruitment',
                     ' '+uplc+player.name2+config.textcol1+' persuaded '+uplc+player0^.name2+config.textcol1
                        +' to switch sides.',
                     ' '+utec+player.team+config.textcol1+' increase their strength!',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');
                    end;
                  1:begin
                     {news-paper}
                     newsy(true,
                     'Gang Recruitment',
                     ' '+uplc+player.name2+config.textcol1+' persuaded '+uplc+player0^.name2+config.textcol1
                        +' to switch sides.',
                     ' '+utec+player.team+config.textcol1+' is growing in strength.',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');
                    end;
                 end; {case .end.}
                end
                else begin
                 crlf;
                 case random(10) of
                  0: d(global_talkcol,'Have it your way Punk!');
                  1: d(global_talkcol,'Greedy Pig!');
                  2: d(global_talkcol,'See you later!');
                  3: d(global_talkcol,'Can''t afford it huh?');
                  4: d(global_talkcol,'Well, keep in touc!');
                  5: d(global_talkcol,'Grrr...');
                  6: d(global_talkcol,'Hey! And don''t come back!');
                  7: d(global_talkcol,'Suit yourself.');
                  8: d(global_talkcol,'Moron...');
                  9: d(global_talkcol,'Well, you look like garbage to me anyway...');
                 end; {case .end.}
                 crlf;
                end;
               end;
              end;
             end;
            end;

            {remove shadow player PL0}
            add_shadow(SRemove,player0^,'','',0);

           end;
          end;
         end;
        end;
       end;
   'L':begin {List of Characters}

        {header}
        clearscreen;
        d(5,'Character       Hps  Race      Class         Status   Team');

        xx:=1;
        abort:=false;
        for i:=1 to 2 do begin

         case i of
          1: size:=fs(FsPlayer);
          2: size:=fs(FsNpc);
         end; {case .end.}

         for j:=1 to size do begin

          {load character}
          load_character(player0^,i,j);

          if (player0^.ai='C') and
             (player0^.deleted=false) and
             (player0^.ID<>player.ID) then begin

           {name}
           s:=player0^.name2+'                          ';
           sd(global_plycol,copy(s,1,16));

           {hps}
           str(player0^.maxhps,s);
           s:=s+'          ';
           sd(config.textcolor,copy(s,1,5));

           {race}
           s:=race_display(1,player0^.race,0)+'       ';
           sd(config.textcolor,copy(s,1,10));

           {class}
           s:=classnames[player0^.class]+'            ';
           sd(config.textcolor,copy(s,1,11));

           {status}
           if player0^.hps>0 then begin
            sd(config.textcolor,'   (Alive)');
           end
           else begin
            sd(12,'   (Dead) ');
           end;

           {team name}
           sd(global_teamcol,'  '+player0^.team);
           crlf;

           {pause?}
           inc(xx);
           if xx>global_screenlines-2 then begin
            xx:=0;
            if confirm('Continue','Y')=false then begin
             abort:=true;
            end;
           end;

          end;

          if abort then break;
         end; {for j:= .end.}
         if abort then break;
        end; {for i:= .end.}
       end;

  end; {case .end.}

 until cho='R';

 {text}
 crlf;
 sd(config.textcolor,'You leave the ');
 sd(10,'Recruitment Hall');
 d(config.textcolor,'.');

 {dispose pointer vars}
 dispose(player0);
 dispose(player1);

end; {Recruite_NPC *end*}

end. {Unit Recruite .end.}
