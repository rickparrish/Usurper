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
Unit TCorner; {Usurper - Team Corner}

Interface  {This is the place where the teams make their decisions}

Procedure Team_Corner;

Implementation

Uses Init, Cms, Jakob,
     Mail, Statusc, SortTeam,
     Post_to, Revival, News,
     TeamRec, SendItem, Various,
     Various2, Various3, Relation,
     Online, File_Io;

Const local_maxy=200; {max number of teams the routines will handle}
var
   justval : integer;
   nice2   : array [1..local_maxy] of ^s25;
   refresh : boolean;

Procedure Get_Mem;  {initialize temporary pointer vars}
begin

 for justval:=1 to local_maxy do begin
  new(nice2[justval]);
  nice2[justval]^:=emptystr;
 end; {for i:= .end.}

end; {get_mem *end*}

Procedure Disposal; {dispose temporary pointer vars}
begin

 for justval:=1 to local_maxy do begin
  dispose(nice2[justval]);
 end; {for i:= .end.}

end; {disposal *end*}

Procedure Meny; {Team Corners Main Menu}
const offset = 24;
begin

 clearscreen;
 crlf;
 d(5,'-*- Adventurers Team Corner -*-');
 crlf;

 menu2(ljust('(T)eam Rankings',offset));
 menu('(P)assword change');

 menu2(ljust('(I)nfo on Teams',offset));
 menu('(E)xamine member');

 menu2(ljust('(M)essages to teammates',offset));
 menu('(Y)our team status');

 menu2(ljust('(J)oin team',offset));
 menu('(*) Resurrect teammember');

 menu2(ljust('(C)reate team',offset));
 menu('(!) Send message to other team');

 menu2(ljust('(Q)uit team',offset));
 menu('(1) Send items to member');

 menu2(ljust('(A)pply for membership',offset));
 menu('(2) Sack Member');

 menu2(ljust('(S)tatus',offset));
 menu('(O)ther Team, check');

 menu('(R)eturn');

end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;
   crlf;
   sd(config.textcolor,'Team Corner ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,'Team (R,T,P,I,S,M,Y,J,*,C,!,Q,A,1,2,E,O,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure Send_This_Letter_To(var letter:mailrec;var pl0 : userrec);
begin

 sd(config.textcolor,'Copy sent to ');
 sd(global_plycol,pl0.name2);
 d(config.textcolor,'.');

 post(MailSend,
      pl0.name2,
      pl0.ai,
      false,
      mailrequest_nothing,
      player.name2,
      letter.mess[1],
      letter.mess[2],
      letter.mess[3],
      letter.mess[4],
      letter.mess[5],
      letter.mess[6],
      letter.mess[7],
      letter.mess[8],
      letter.mess[9],
      letter.mess[10],
      letter.mess[11],
      letter.mess[12],
      letter.mess[13],
      letter.mess[14],
      letter.mess[15]);

end; {send_this_letter_to *end*}

Function Give_Me_A_Team(const exclude_team:s40) : s40;
var
    i,
    j,
    k,
    size : word;

    x : byte;

    s : s40;

    abort,
    found : boolean;

    pl0 : ^UserRec;

begin

 {init pointer vars}
 new(pl0);

 {reset mem pointers}
 for i:=1 to local_maxy do begin
  nice2[i]^:='';
 end; {for i= .end.}

 {get user-input}
 s:=get_string(20);

 abort:=false;
 found:=false;

 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end;

  for j:=1 to size do begin

   load_character(pl0^,i,j);

   if (findsub(s,pl0^.team)) and
      (pl0^.name1<>global_delname1) and
      (pl0^.name2<>global_delname2) and
      (pl0^.team<>'') and
      (pl0^.team<>exclude_team) and
      (pl0^.deleted=false) then begin

    x:=0;

    for k:=1 to local_maxy do begin
     if nice2[k]^=pl0^.team then begin
      x:=1;
      break;
     end;
    end; {for k:= .end.}

    if x=0 then begin
     if confirm(utec+pl0^.team+config.textcol1,'N')=true then begin
      s:=pl0^.team;
      found:=true;
     end
     else begin

      for k:=1 to local_maxy do begin
       if (nice2[k]^='') then begin
        nice2[k]^:=pl0^.team;
        break;
       end;
      end; {for k:= .end.}

      if confirm('Continue search','Y')=false then begin
       abort:=true;
       s:='';
       break;
      end;

     end;
    end;
   end;

   if (found) or (abort) then break

  end; {for j:= .end.}

  if (found) or (abort) then break;

 end; {for i:= .end.}


 {dispose pointer vars}
 dispose(pl0);

 {return result}
 if not found then s:='';
 give_me_a_team:=s;

end; {Give_Me_A_Team *end*}

Procedure Team_Corner;
const never = false;
var
   cho   : char;

   s,
   ss,
   s2 : s70;

   poor_guy : s30;

   k,
   size : word;

   xx, i, j, x : longint;

   motivation,
   resurr,
   make_team,
   abort,
   found,
   already,
   done,
   break_out : boolean;

   death : integer;

   pl0,
   pl11 : UserRec; {users}

   Letter : MailRec; {letter}

begin

 {init pointer variables}
 get_mem;

 {fetching "Resurrect teammates?" option from .CFG}
 resurr:=false;
 s:=cfg_string(36);
 if upcasestr(s)='YES' then resurr:=true;

 {Main Loop *START*}
 repeat

  {update online location, only if necessary}
  if onliner.location<>onloc_teamcorner then begin
   refresh:=true;
   onliner.location:=onloc_teamcorner;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {display menu}
  display_menu(true,true);

  {get user-input}
  cho:=upcase(getchar);

  {evaluate user-input}
  case cho of
   '?':begin {display menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'R':begin {return to the Inn}
        disposal;
        crlf;
        exit;
       end;
   'S':begin {status}
        clearscreen;
        status(player);
        crlf;
       end;
   'A':begin {apply for membership in a team}
        if player.team<>'' then begin
         crlf;
         sd(12,'You are already a member of the ');
         sd(global_teamcol,player.team);
         d(12,' crew!');
         crlf;
        end
        else begin
         crlf;
         crlf;
         d(config.textcolor,'What gang would you like to join?');
         sd(config.textcolor,':');

         {get team-name}
         s:=give_me_a_team('');

         if s<>'' then begin
          crlf;
          sd(config.textcolor,'Informing '+utec+s+config.textcol1+' crew...');

          {mail all team members in S}
          Team_Report_All(s,        {team to send message to}
                          '',       {exclude player name}
                          '',       {letter head}
                          mailrequest_jointeam, {mailrequest_constant}
                          player.name2,           {line1}
                          player.id,              {line2}
                          long2str(player.recnr), {line3}
                          s);                     {line4}

          {online mail to all members in S}
          Team_Online_Report_All(s,'',uplc+player.name2+config.textcol1+' applied for membership in your team.');

          d(15,'done.');
          d(config.textcolor,'They will get back to you.');
         end;

        end;

       end;
   'E':begin {examine team member}
        crlf;

        if player.team<>'' then begin

         done:=false;
         repeat
          found:=false;
          crlf;
          d(config.textcolor,'Who would you like to examine ? (enter '+config.textcol2+'?'+config.textcol1
		    +' to see your team)');
          sd(config.textcolor,':');

          s:=get_string(20);

          if s='?' then begin
           display_members(player.team,true);
          end
          else begin
           done:=true;
           for i:=1 to 2 do begin
            case i of
             1: size:=fs(FsPlayer);
             2: size:=fs(FsNpc);
            end;

            for j:=1 to size do begin
             load_character(pl0,i,j);

             if (findsub(s,pl0.name2)) and
                (pl0.name2<>player.name2) and
                (pl0.deleted=false) and
                (pl0.team=player.team) then begin

              sd(global_plycol,pl0.name2);
              if confirm(' ','n')=true then begin
               clearscreen;
               status(pl0);
               found:=true;
              end
              else begin
               if confirm('Continue search','Y')=false then begin
                found:=true;
               end;
              end;

             end;

             if found then break;

            end; {for j=.end.}

            if found then break;

           end; {for i= .end.}
          end;

         until done;

        end
        else begin
         crlf;
         d(12,'You don''t belong to a team.');
        end;
       end;
   '1':begin {send stuff to team member}
        if player.team='' then begin
         crlf;
         d(12,'You don''t belong to a team.');
        end
        else begin
         disposal;
         team_transfer;
         get_mem;
         crlf;
        end;
       end;
   '2':begin {SACK team member}
        if player.team='' then begin
         crlf;
         d(12,'You don''t belong to a team.');
        end
        else begin

         done:=false;
         break_out:=false;
         repeat
          crlf;
          crlf;
          d(config.textcolor,'Who must be SACKED? (enter '+config.textcol2+'?'+config.textcol1+' to see your team)');
          sd(config.textcolor,':');
          s:=get_string(20);

          poor_guy:='';

          if s='?' then begin
           display_members(player.team,true);
          end
          else begin
           done:=true;
           xx:=0;
           for i:=1 to fs(FsPlayer) do begin
            if xx=0 then begin

             load_character(pl0,1,i);

             if (findsub(s,pl0.name2)) and
                (pl0.name2<>player.name2) and
                (pl0.name2<>global_delname2) and
                (pl0.deleted=false) and
                (pl0.team=player.team) then begin

              if confirm(uplc+pl0.name2+config.textcol1,'n')=true then begin

               {add shadow player}
               if add_shadow(SAdd,pl0,player.name2,'being SACKED from team',0)=false then begin
                crlf;
                d(15,'You can''t get in touch with '+uplc+pl0.name2+uwhite+' right now.');
                d(15,'Try again later.');
                crlf;
                break;
               end;

               if pl0.hps>0 then begin
                crlf;
                sd(config.textcolor,'You approach ');
                sd(global_plycol,pl0.name2);
                d(config.textcolor,' and let '+sex[pl0.sex]);
                d(config.textcolor,'know that you no longer desire '+sex[pl0.sex]+'!');
                sd(global_plycol,pl0.name2);
                d(config.textcolor,' looks surprised, but soon leaves');
                d(config.textcolor,'without saying a word...');
                crlf;
                pause;
               end
               else begin
                crlf;
                sd(config.textcolor,'As ');
                sd(global_plycol,pl0.name2);
                d(config.textcolor,' is dead. It''s only');
                d(config.textcolor,'a formal matter of clearing '+sex3[pl0.sex]+' name from the papers.');
                d(global_talkcol,' Hell, '+sex2[pl0.sex]+' was no good anyway '+config.textcol1+', you think for yourself.');
                crlf;
                pause;
               end;

               x:=1;
               xx:=1;

               {mail the poor guy who got sacked}
               post(MailSend,
               pl0.name2,
               pl0.ai,
               false,
               mailrequest_nothing,
               '',
               umailheadc+'Team'+config.textcol1,
               mkstring(4,underscore),
               'You were '+ulred+'sacked'+config.textcol1+' from the team by '+uplc+player.name2+config.textcol1+'!',
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

               {update variables}
               pl0.team:=emptystr;
               pl0.cturf:=false;
               pl0.gym_owner:=0;

               {save updated (former) teammate}
               user_save(pl0);

               {remove offline player}
               add_shadow(SRemove,pl0,'','',0);

               {used by routine at the end, which informs the other
                team members of what happened}
               poor_guy:=pl0.name2;

               {news paper}
               newsy(true,'Internal Gang Turbulence!',
               ' '+uplc+player.name2+config.textcol1+' sacked '+uplc+pl0.name2+config.textcol1+' from '+utec
                 +player.team+config.textcol1+'!',
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
               if confirm('Continue search','Y')=false then begin
                break_out:=true;
               end;
              end;
             end;
            end;

            if break_out then break;

           end; {for i:= .end.}

           if break_out=false then begin
            {search among the NPCs}
            for i:=1 to fs(FsNPC) do begin
             if xx=0 then begin

              {load character}
              load_character(pl0,2,i);

              if (findsub(s,pl0.name2)) and
                 (pl0.name2<>player.name2) and
                 (pl0.name2<>global_delname2) and
                 (pl0.team=player.team) and
                 (pl0.deleted=false) then begin

               if confirm(uplc+pl0.name2+config.textcol1+' ','n')=true then begin

                if is_online(pl0.name2,online_player)=true then begin
                 crlf;
                 d(12,'You can''t sack a character who is online.');
                 crlf;
                 break;
                end;

                if pl0.hps>0 then begin
                 crlf;
                 sd(config.textcolor,'You call ');
                 sd(global_plycol,pl0.name2);
                 d(config.textcolor,' to the team HQ.');
                 d(config.textcolor,'When you try to explain '+sex3[pl0.sex]+' dismissal '+sex2[pl0.sex]+' only');
                 d(config.textcolor,'gets angry and demands to get some compensation');
                 d(config.textcolor,'for your brute decision!');

                 {what sum should the fired subject demand for compensation}
                 x:=random(pl0.level)+2;
                 x:=x*5000;

                 crlf;
                 sd(global_plycol,pl0.name2);
                 sd(config.textcolor,' wants ');
                 sd(14,commastr(x));
                 d(config.textcolor,' '+many_money(x)+'!');

                 if confirm('Pay the scoundrel','n')=true then begin
                  if player.gold>=x then begin
                   crlf;
                   sd(config.textcolor,'You pay the demanded sum and ');
                   d(global_plycol,pl0.name2);
                   d(config.textcolor,'leaves the room with a smile on '+sex3[pl0.sex]+' face.');
                   crlf;

                   decplayermoney(player,x);
                   incplayermoney(pl0,x);

                   pause;
                  end
                  else begin
                   crlf;
                   d(12,'You can''t afford it!');
                   crlf;
                   pause;
                  end;
                  end
                 else begin
                  crlf;
                  sd(global_talkcol,'Greedy Hog! ');
                  sd(global_plycol,pl0.name2);
                  d(config.textcolor,' screams before');
                  d(config.textcolor,sex2[pl0.sex]+' rushes out, slamming the door shut behind '+sex[pl0.sex]+'.');
                  d(config.textcolor,'You somehow feel that this joker may stir some trouble');
                  d(config.textcolor,'in the future.');
                  crlf;
                  pause;
                 end;
                end
                else begin

                 crlf;
                 sd(config.textcolor,'As ');
                 sd(global_plycol,pl0.name2);
                 d(config.textcolor,' is dead as a stone, you');
                 d(config.textcolor,'quickly remove '+sex3[pl0.sex]+' name from the team records.');
                 d(config.textcolor,sex2[pl0.sex]+' can''t complain from '+sex3[pl0.sex]+' current position.');
                 crlf;
                 pause;
                end;

                x:=1;
                xx:=1;

                {remove player team related flags}
                pl0.team:=emptystr;
                pl0.cturf:=false;
                pl0.gym_owner:=0;

                {worsen pl0:s attitude to player}
                Update_Relation(Relation_Worsen,2,pl0,player,false,false);

                {save NPC}
                user_save(pl0);

                {used by routine at the end, which informs the other
                team members of what happened}
                poor_guy:=pl0.name2;

                {news-paper}
                newsy(true,'Internal Gang Turbulence!',
                ' '+uplc+player.name2+config.textcol1+' sacked '+uplc+pl0.name2+config.textcol1+' from '+utec+player.team
                  +config.textcol1+'!',
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
                if confirm('Continue search','Y')=false then begin
                 break_out:=true;
                end;
               end;
              end;
             end;

             if break_out then break;

            end; {for i:= .end.}

           end;

          end;

          if poor_guy<>'' then begin
           {a team-member has been sacked. we must inform the other
            team-members}

           for i:=1 to 2 do begin

            case i of
             1: size:=fs(FsPlayer);
             2: size:=fs(FsNpc);
            end; {case .end.}

            for j:=1 to size do begin

             {load character}
             load_character(pl0,i,j);

             if (player_active(pl0,false)) and
                (pl0.team=player.team) and
                (pl0.name2<>player.name2) then begin

              if is_online(pl0.name2,online_player)=true then begin
               {send online mess}
               online_send_to_player(pl0.name2,online_player,uplc+player.name2+ulred+' sacked '+uplc+poor_guy+config.textcol1
                                     +' from the Team!');
              end
              else begin

               {mail team-mate}
               post(MailSend,
               pl0.name2,
               pl0.ai,
               false,
               mailrequest_nothing,
               '',
               umailheadc+'Team Turbulence'+config.textcol1,
               mkstring(15,underscore),
               uplc+player.name2+ulred+' sacked '+uplc+poor_guy+config.textcol1+' from the Team!',
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

            end; {for j:= .end.}
           end; {for i:= .end.}

           {reset mem var}
           poor_guy:='';
          end;

         until done;

        end;
       end;
   '*':begin {Resurrect dead comrade(s)}

        if player.team='' then begin
         crlf;
         d(12,'You don''t belong to a team.');
        end
        else begin

         if resurr=true then begin
          resurrect;
         end
         else begin
          crlf;
          d(12,'Resurrection is not allowed!');
         end;

        end;

       end;
   'O':begin {view OTHER team}

        crlf;
        crlf;
        d(config.textcolor,'Which gang would you like to see?');
        sd(config.textcolor,':');

        {get team-name}
        s:=give_me_a_team(player.team);

        if s<>'' then begin
         motivation:=true;
         for i:=1 to fs(FsPlayer) do begin
          load_character(pl0,1,i);
          if pl0.team=s then begin
           display_member(pl0,motivation);
           if motivation=true then motivation:=false;
          end;
         end; {for i= .end.}

         for i:=1 to fs(FsNPC) do begin
          load_character(pl0,2,i);
          if pl0.team=s then begin
           display_member(pl0,motivation);
           if motivation=true then motivation:=false;
          end;
         end; {for i= .end.}
         crlf;

        end;

       end;
   'Y':begin {see YOUR team}

        if player.team<>'' then begin
         display_member(player,true);
         display_members(player.team,false);
        end
        else begin
         crlf;
         crlf;
         d(12,'You don''t belong to a team.');
        end;

       end;
   'T':begin {team rankings}
        disposal;
        crlf;
        crlf;
        d(5,'Usurper Team Rankings                    Scores');
        d(5,'===============================================');
        sort_teams(false,false,false,false);
        get_mem;
       end;
   'P':begin  {change team password}
        crlf;
        crlf;
        if player.team<>'' then begin
         if confirm('Change the Team Password','n')=true then begin
          crlf;
          d(config.textcolor,'Enter old password');
          sd(config.textcolor,':');
          ss:=get_stringSec(20,'*');

          if ss=player.teampw then begin
           repeat
            crlf;
            d(config.textcolor,'Enter new password');
            sd(config.textcolor,':');
            s:=get_StringSec(20,'*');
           until length(s)>2;

           crlf;
           d(config.textcolor,'Reenter for verification');
           sd(config.textcolor,':');
           ss:=get_stringsec(20,'*');

           if (s=ss) and (s=player.teampw) then begin
            d(config.textcolor,'Password remains the same.');
           end;

           if (s=ss) and (s<>player.teampw) then begin
            d(15,'Password successfully changed!');

            {set new team password}
            player.teampw:=s;

            {*inform teammates of password change*}
            for i:=1 to fs(FsPlayer) do begin
             load_character(pl0,1,i);

             if (pl0.team=player.team) and
                (pl0.name2<>player.name2) and
                (pl0.deleted=false) then begin

              pl0.teampw:=player.teampw;
              user_save(pl0);

              if pl0.ai='H' then begin
               if is_online(pl0.name2,online_player) then begin
                online_send_to_player(pl0.name2,online_player,broadcast_changeteampw+player.teampw);
               end
               else begin
                post(MailSend,
                 pl0.name2,
                 pl0.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 umailheadc+'Team-Info'+config.textcol1,
                 mkstring(9,underscore),
                 uplc+player.name2+config.textcol1+' changed the Team password.',
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

             end;
            end; {for i:= .end.}

            {changing npc members password to}
            for i:=1 to fs(FsNPC) do begin
             load_character(pl0,2,i);

             if (pl0.team=player.team) and (pl0.name2<>player.name2) and
                (pl0.deleted=false) then begin
              pl0.teampw:=player.teampw;
              user_save(pl0);
             end;
            end; {for i= .end.}

           end
           else begin
            crlf;
            d(config.textcolor,'Verification failed. Try again.');
           end;
          end
          else begin
           crlf;
           d(config.textcolor,'Wrong password!');
           crlf;
          end;
         end;
        end
        else begin
         crlf;
         d(5,'You don''t belong to a team.');
        end;
       end;

   'Q':begin {QUIT team}
        crlf;
        crlf;
        if player.team<>'' then begin

         d(12,'Quit Team');
         d(5,mkstring(9,underscore));

         if confirm('Really Quit '+utec+player.team+config.textcol1,'N')=true then begin
          crlf;
          d(15,'You have left the Team!');
          crlf;

          {news paper}
          Newsy(true,'Gang Deserter!',
          ' '+uplc+player.name2+config.textcol1+' the '+classnames[player.class]+' left '+utec+player.team+config.textcol1+'.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

          s:=player.team;
          death:=0;

          if player.cturf=true then begin
           death:=1;
          end;

          x:=0;
          for i:=1 to fs(FsPlayer) do begin

           if load_character(pl0,1,i) then begin

            if (pl0.team=s) and (pl0.name2<>player.name2) then begin
             x:=1;
             break;
            end;
           end;

          end; {for i= .end.}

          {removing NPC teammembers}
          if x=0 then begin

           team_record(player.team);

           {this code also exists in npcmaint.pas and various2.pas (deactivate_player)
           these should perhaps be united in one single proc. }
           player.cturf:=false;
           player.teampw:=emptystr;
           player.team:=emptystr;
           player.gym_owner:=0;

           for i:=1 to fs(FsNPC) do begin

            if load_character(pl0,2,i) then begin

             if pl0.team=s then begin
              pl0.team:=emptystr;
              pl0.cturf:=false;
              pl0.gym_owner:=0;
              user_save(pl0);
             end;
            end;

           end; {for i:= .end.}

           d(15,'Team CEASED to exist!');

           player.team:=emptystr;

           {News Paper}
           newsy(true,config.textcol1+'Team ceased to exist!',
           utec+' '+s+config.textcol1+' has no members left! We can only hope',
           ' that other teams will be more successful.',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {send note to all online players about this}
           online_send_to_all('TEAM '+utec+s+config.textcol1+' has been disbanded!',player.name2,'');

           if death>0 then begin
            {news}
            newsy(true,config.textcol1+'Town free from Gang control!',
            ' Due to the latest gang collapse, the Town is currently free from',
            ' any gang in control. How long will this last?',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
           end;
          end
          else begin

           {remove player team releated flags}
           player.cturf    :=false;
           player.teampw   :=emptystr;
           player.team     :=emptystr;
           player.gym_owner:=0;

           {skriver ett brev till ”vriga att player.name2 deserterade}
           for j:=1 to fs(FsPlayer) do begin
            load_character(pl0,1,j);

            {online message}
            if (is_online(pl0.name2,online_player)) and
               (pl0.name2<>player.name2) and
               (pl0.team=s) then begin
             online_send_to_player(pl0.name2,online_player,uplc+player.name2+config.textcol1+' has left the team!');
            end;

            if (pl0.team=s) and (pl0.name2<>player.name2) then begin
             {inform offline teammmate}
             post(MailSend,
             pl0.name2,
             pl0.ai,
             false,
             mailrequest_nothing,
             '',
             umailheadc+'Team'+config.textcol1,
             mkstring(4,underscore),
             uplc+player.name2+config.textcol1+' the '+classnames[player.class]+' has left the team!',
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
          end;
          user_save(player);
         end;
        end
        else begin
         crlf;
         d(5,'You don''t belong to a team!');
        end;
       end;
   'I':begin {info on teams, see teammembers in all gangs}
        disposal;
        sort_teams(false,true,false,false);
        get_mem;
       end;
   '!':begin {send message to other team}

        crlf;
        crlf;
        d(5,'Which Team would you like to send a message to?');
        sd(config.textcolor,':');

        {get team name}
        s:=give_me_a_team('');

        if s<>'' then begin
         crlf;
         sd(5,'Message to ');
         sd(global_teamcol,s);
         d(5,'.');

         letter.mess[1]:='';
         create_letter(letter,
                       s,
                       player.name2,
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


         if letter.mess[1]<>'' then begin
          {look for members members}
          for i:=1 to fs(FsPlayer) do begin
           load_character(pl0,1,i);
           if (pl0.team=s) and
              (pl0.deleted=false) and
              (pl0.name2<>global_delname2) and
              (pl0.name2<>player.name2) then begin
            send_this_letter_to(letter,pl0);
           end;
          end; {for i= .end.}

          for i:=1 to fs(FsNPC) do begin
           load_character(pl0,2,i);
           if (pl0.team=s) and
              (pl0.deleted=false) and
              (pl0.name2<>global_delname2) and
              (pl0.name2<>player.name2) then begin

            send_this_letter_to(letter,pl0);

           end;

          end; {for i= .end.}

         end;
        end;

       end;
   'M':begin {Message to own team}
        crlf;
        if player.team='' then begin
         crlf;
         d(12,'You are not a teammember!');
        end
        else begin
         crlf;
         if confirm('Send a message to your teammates','n')=true then begin
          crlf;
          d(5,'Team Message');

          letter.mess[1]:='';
          create_letter(letter,
                        player.team,
                        player.name2,
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


          if letter.mess[1]<>'' then begin

           {look for members}
           for i:=1 to fs(FsPlayer) do begin
            load_character(pl0,1,i);
            if (pl0.team=player.team) and
               (pl0.deleted=false) and
               (pl0.name2<>player.name2) then begin
             send_this_letter_to(letter,pl0);
            end;
           end; {for i= .end.}

           for i:=1 to fs(FsNPC) do begin
            load_character(pl0,2,i);
            if (pl0.team=player.team) and
               (pl0.deleted=false) and
               (pl0.name2<>player.name2) then begin
             send_this_letter_to(letter,pl0);
            end;
           end; {for i= .end.}

          end;

         end;
        end;
       end;
   'J':begin {join a team}

        {the king/queen may not join a team}
        if player.king=true then begin
         crlf;
         if player.sex=1 then s:='KING'
                         else s:='QUEEN';

         d(12,'The '+s+' may not join any team!');
         crlf;
         pause;
        end
        else if player.team<>'' then begin
         crlf;
         crlf;
         sd(12,'You are already a member of ');
         sd(global_teamcol,player.team);
         d(12,'!');
         crlf;
        end
        else begin
         crlf;
         crlf;
         d(config.textcolor,'Which gang would you like to join?');
         crlf;
         sd(config.textcolor,':');

         s:=Give_Me_A_Team('');

         if s<>'' then begin

          {load a member in team S}
          load_teammember(s,pl0);

          {is team full?}
          x:=team_members(pl0.team);

          if x>=global_maxteammembers then begin
           crlf;
           d(12,'Sorry, this team is full!');

           {inform online team members of failed attempt}
           Team_Online_Report_All(pl0.team,'',uplc+player.name2+' '+ulred+'failed'+config.textcol1+' to join your team!');

           {inform offline team members of failed attempt}
           Team_Report_All(pl0.team,'','Turned down',
           mailrequest_nothing,
           uplc+player.name2+config.textcol1+' the '+classnames[player.class]+' attempted to join your team.',
           'The attempt failed since your team is full!',
           '',
           '');

          end
          else begin
           crlf;
           d(config.textcolor,'Enter password');
           s:=emptystr;
           sd(config.textcolor,':');
           s:=get_stringsec(20,'*');

           if s=pl0.teampw then begin
            crlf;
            sd(config.textcolor,'Correct! you are now a member of '+utec+pl0.team+config.textcol1+'!');
            crlf;
            crlf;

            {set player variables}
            transfer_teamstatus(pl0,player);

            {save user}
            user_save(player);

            {news-paper}
            newsy(true,
            'New Gang Member!',
            ' '+uplc+player.name2+config.textcol1+' joined '+utec+player.team+config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            {write a message to all members to tell them about
             the new member}

            for i:=1 to fs(FsPlayer) do begin
             load_character(pl0,1,i);

             {if team-mate is online then we send him a online message}
             if (player_active(pl0,false)=true) and
                (pl0.team=player.team) and
                (pl0.name2<>player.name2) then begin

              if is_online(pl0.name2,online_player)=true then begin
               online_send_to_player(pl0.name2,online_player,uplc+player.name2+config.textcol1+' joined your team!');
              end
              else begin
               {mail}
               post(MailSend,
               pl0.name2,
               pl0.ai,
               false,
               mailrequest_nothing,
               '',
               umailheadc+'Team'+config.textcol1,
               mkstring(4,underscore),
               uplc+player.name2+config.textcol1+' joined the Team!',
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

            end; {for i:= .end.}

           end
           else begin
            crlf;
            d(12,'Wrong password!');

            {inform online team members of failed attempt}
            Team_Online_Report_All(pl0.team,'',uplc+player.name2+' '+ulred+'failed'+config.textcol1+' to join your team!');

            {inform offline team members of failed attempt}
            Team_Report_All(pl0.team,'','Intruder',
            mailrequest_nothing,
            uplc+player.name2+config.textcol1+' the '+classnames[player.class]+' entered the wrong password',
            'required to join your team.',
            '',
            '');

           end;
          end;
         end;
        end;

       end;
   'C':begin {create team}
        crlf;
        crlf;
        if player.king=true then begin
         crlf;
         if player.sex=1 then s:='KING'
                         else s:='QUEEN';

         d(15,'The '+s+' may not create a team!');
         crlf;
         pause;
        end
        else if player.team<>'' then begin
         crlf;
         sd(12,'You are already a member of ');
         sd(global_teamcol,player.team);
         d(12,'!');
         crlf;
        end
        else if confirm('Create a New Team','n')=true then begin
         crlf;
         crlf;
         d(5,'Team Creation');
         d(5,mkstring(13,underscore));
         sd(config.textcolor,'So, ');
         sd(global_plycol,player.name2);
         d(config.textcolor,'. You want to create a team for you and your');
         d(config.textcolor,'brave comrades. Well then, choose a teamname and password');
         d(config.textcolor,'and go and round up some fellows.');
         xx:=0;
         repeat
          make_team:=true;
          crlf;
          d(config.textcolor,'Choose a teamname (max 25 characters)');
          sd(config.textcolor,':');
          s:=get_string(25);

           if s='' then begin
            make_team:=false;
            break;
           end;

          if length(s)<3 then begin
           crlf;
           d(config.textcolor,'Teamname must contain at least 3 letters.');
           s:=emptystr;
           continue;
          end;

          for i:=1 to fs(FsPlayer) do begin
           load_character(pl0,1,i);
           if (upcasestr(pl0.team)=upcasestr(s)) and
              (pl0.deleted=false) then begin
            d(config.textcolor,'Sorry, but this teamname already exists!');
            s:=emptystr;
           end;
          end; {for i:= .end.}

          for i:=1 to fs(FsNPC) do begin
           load_character(pl0,2,i);
           if (upcasestr(pl0.team)=upcasestr(s)) and
              (pl0.deleted=false) then begin
            d(config.textcolor,'Sorry, but this teamname already exists!');
            s:=emptystr;
           end;
          end; {for i:= .end.}

           sd(global_teamcol,s);
           if confirm('','N')=false then begin
            s:=emptystr;
           end;
         until s<>'';

         ss:=emptystr;

         if make_team then begin
          repeat
           crlf;
           d(config.textcolor,'Choose a team password');
           sd(config.textcolor,':');
           ss:=get_stringsec(10,'*');
           if length(ss)<3 then begin
            d(config.textcolor,'Password too short.');
ss:=emptystr;
           end;
           if ss<>'' then begin
            d(config.textcolor,'Please verify (type password again)');
            sd(config.textcolor,':');
            s2:=get_stringsec(10,'*');
            if s2<>ss then begin
             d(12,'Passwords don''t match.');
             ss:=emptystr;
            end;
           end;
          until ss<>'';

          crlf;
          d(14,'Congratulations!');
          sd(global_teamcol,s);
          d(config.textcolor,' has been created by you!');

          d(config.textcolor,'Hopefully your new team will be victorious in many battles to come.');
          d(config.textcolor,'(Remember that a team can have a maximum of '+commastr(global_maxteammembers)+' members)');
          crlf;

          player.team:=s;
          player.teampw:=ss;
          player.gym_owner:=0;

          user_save(player);

          {news-paper}
          newsy(true,
          'New Team Created!',
          ' '+uplc+player.name2+config.textcol1+' created '+utec+s+config.textcol1+'.',
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
          d(15,'Aborted.');
         end;
        end;
       end;

  end; {case .end.}

 until never;
 {Main Loop *END*}

 {dispose of temporary pointer variables}
 disposal;

end; {Team_Corner *end*}

end. {Unit .end.}
