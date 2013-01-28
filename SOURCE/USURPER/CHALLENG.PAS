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



Unit Challeng; {Usurper - Challenges}

Interface

Procedure Challenges;

Implementation

Uses Init, Cms, Jakob, News,
     GenNews, Dorm, Gym,
     GangWars, SortTeam, Onduel,
     Bounty, Castle, Teamrec,
     Various, Various2, Various3,
     Temple, Challkng, Prisonf,
     Statusc, PlyQuest, Relation,
     Mail, Online, File_Io;

var  refresh : boolean;


Procedure Meny;
const offset = 20;
begin

 clearscreen;
 crlf;
 d(5,'-*- '+config.anchor+', conjuction of destinies -*-');
 crlf;
 d(config.textcolor,'To the north you can see the Castle in all its might.');
 d(config.textcolor,'The Dormitory lies to the west.');
 d(config.textcolor,'The Red Fields are to the east.');
 d(config.textcolor,'It''s time to be brave.');
 crlf;

 menu2(ljust('(D)ormitory',offset));
 menu2(ljust('(B)ounty hunting',offset));
 menu('(Q)uests');

 menu2(ljust('(G)ang war',offset));
 menu2(ljust('(O)nline war',offset));
 menu2(ljust('(A)ltar of the Gods',offset));
 crlf;

 menu2(ljust('(C)laim town',offset));
 menu('(F)lee town control');
 {menu('(L)ove corner');}

 menu2(ljust('(S)tatus',offset));
 menu2(ljust('(K)ings Castle',offset));
 menu('(T)he Gym');

 menu(ljust('(R)eturn to town',offset));

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
   sd(config.textcolor,config.anchor+' (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,config.anchor+' (D,B,Q,G,O,A,C,F,S,K,T,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure View_Royal_Guard;
var
    i,
    c,
    firstlook : byte;

    j,
    k,
    size : word;

    found : boolean;

    Pl0 : UserRec;
    King : KingRec;

begin


 crlf;

 {load king}
 load_king(fload,king);

 c:=1;
 d(14,'The Royal Guard');
 for i:=1 to global_kingguards do begin
  if king.guard[i]<>'' then begin

   {lets find this guard in the player/npc file}
   if king.guardai[i]='H' then firstlook:=1
                          else firstlook:=2;


   found:=false;
   for j:=1 to 2 do begin
    if found then break;
    case firstlook of
     1:begin
        firstlook:=2;
        size:=fs(fsplayer);
       end;
     2:begin
        firstlook:=1;
        size:=fs(fsnpc);
       end;
    end; {case .end.}

    for k:=1 to size do begin
     if found then break;
     load_character(pl0,j,k);
     if pl0.name2=king.guard[i] then begin
      found:=true;
      break;
     end;
    end; {for k:= .end.}

   end; {for j:= .end.}

   {display guard}
   if found then begin

    {#}
    sd(3,'#'+commastr(c)+' ');

    {name}
    sd(global_plycol,pl0.name2);

    {level}
    sd(config.textcolor,' (the level '+commastr(pl0.level)+' '+race_display(2,pl0.race,0)+')');

    crlf;
    {inc counter}
    inc(c);

   end;

  end;
 end; {for i:= .end.}


 if c=1 then begin
  d(15,'No Guards!');
 end;

 crlf;
 pause;

end; {view_royal_guard *end*}

Procedure Challenges; {MAIN **START**}
const never : boolean =false;

var
    ch,
    cho : char;

    i,
    j,
    y,
    x,
    cc : longint;

    size : word;

    k : byte;


    s,s2 : s100;

    go,
    male,
    abort,
    found,
    great,
    allow  : boolean;


    {record structs}
    Pl0  : UserRec;
    Only : OnlineRec;
    King : KingRec;


begin


 crlf;
 if global_auto_probe=NoWhere then begin
  d(5,'You turn to seek your luck on the roads just outside town...');
 end;

 {MAIN-LOOP **start**}
 repeat

  {updating online location, only if necessary}
  if onliner.location<>onloc_anchorroad then begin
   refresh:=true;
   onliner.location:=onloc_anchorroad;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  case global_auto_probe of
   NoWhere:begin
            display_menu(true,true);
            {get user-input}
            cho:=upcase(getchar);
           end;
   Slottet:begin
            cho:='K';
           end;
   Dormy:begin
          cho:='D';
         end;
   MainStreet:begin
               d(15,'Must go to MainStreet.');
               exit;
              enD;
  end; {case .end.}


  {evaluate user-input}
  case cho of
   'S':begin {status}
        status(player);
        crlf;
       end;
   'Q':begin {quests}
        player_quest;
       end;
   'T':begin {the gym, for owners and members only}

        crlf;

        {load owners [team]}
        s:=gym_owning_team;

        {the Gym is for owners and members only}
        if (player.gym_owner>0) or
           (player.gym_card>0) then begin
         the_gym;
        end
        else begin

         ch:='?';
         repeat {"outside the gym" loop *start*}

          {updating online location, only if necessary}
          if onliner.location<>onloc_outsidegym then begin
           onliner.location:=onloc_outsidegym;
           onliner.doing   :=location_desc(onliner.location);
           add_onliner(OUpdateLocation,onliner);
          end;

          if ch='?' then begin
           clearscreen;
           crlf;
           d(5,'Outside the Gym');

           if s='' then begin
            d(15,'The Gym is free to take over!');
           end
           else if (s<>'') and (s=player.team) then begin
            d(14,'The Gym is owned by your gang!');
            player.gym_owner:=1;
            the_gym;
           end
           else begin
            d(config.textcolor,'The Gym is in the hands of '+utec+s+config.textcol1+'.');
           end;

           if (s<>'') and (s=player.team) then begin
            d(config.textcolor,'Welcome to '+gymcol+'The Gym'+config.textcol1+'.');
            d(config.textcolor,'The club is for your gang and members only.');
           end
           else begin
            d(config.textcolor,'The Gym is for owners and members only.');
            d(config.textcolor,'Get your sorry butt out of here NOW! (unless you want it kicked)');
           end;
           crlf;
           menu('(A)pply for membership');
           menu('(T)ake over the Gym! (fistfight)');
           menu('(R)eturn  ');
           crlf;
          end;

          sd(config.textcolor,'Outside the Gym ('+config.textcol2+'?'+config.textcol1+' for menu):');

          {get user-input}
          ch:=upcase(getchar);
          crlf;

          {evaluate user-input}
          if (ch='A') and (player.gym_card>0) then begin
           d(12,'Hey bird-brain! You already ARE a member here!');
           pause;
           ch:=' ';
          end
          else if (ch='A') and (player.gym_card=0) and (s='') then begin
           d(12,'The is nobody to send the application to! The Gym is not owned by anyone right now!');
           d(12,'Why don''t you take over the Gym now when you have the chance!?');
           pause;
          end
          else if (ch='T') and (player.team='') then begin
           d(12,'You must be in a Team to be able to take over the Gym!');
           pause;
           ch:=' ';
          end
          else if (ch='T') and (s<>'') then begin
           crlf;
           d(12,'FIGHT!');
           if confirm('Take on the '+utec+s+config.textcol1+' crew','N')=false then begin
            d(12,'CHICKEN!');
            ch:=' ';
           end;
          end
          else if (ch='T') and (s='') then begin
           {take over the gym without opposition [the gym is not owned by anyone]}
           crlf;
           d(15,'YOU ARE IN CHARGE OF '+gymcol+'THE GYM'+uwhite+' NOW! CONGRATULATIONS!');
           d(15,'Informing your crew...');

           {update team variables}
           s:=player.team;
           player.gym_owner:=1;
           player.gym_card:=0;
           user_save(player);

           {mail team-mates}
           for i:=1 to 2 do begin

            case i of
             1: size:=fs(FsPlayer);
             2: size:=fs(FsNpc);
            end; {case .end.}

            for j:=1 to size do begin

             {load character}
             load_character(pl0,i,j);

             if (pl0.deleted=false) and
                (pl0.team=player.team) and
                (pl0.name2<>player.name2) then begin

              pl0.gym_owner:=1;
              pl0.gym_card:=0;
              user_save(pl0);

              if is_online(pl0.name2,online_player)=true then begin
               {send online mess}
               online_send_to_player(pl0.name2,online_player,BroadCast_AddGym);
               online_send_to_player(pl0.name2,online_player,uplc+player.name2+config.textcol1+' took over the '+gymcol+'Gym'
                                     +config.textcol1+'!');
              end
              else begin
               {mail team-mate}
               post(MailSend,
               pl0.name2,
               pl0.ai,
               false,
               mailrequest_nothing,
               '',
               uyellow+'Gym Take-Over!'+config.textcol1,
               mkstring(14,underscore),
               uplc+player.name2+config.textcol1+' led your crew in the take-over of '+gymcol+'The Gym'+config.textcol1+'!',
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

           {news-paper}
           Newsy(true,
           'New Gym Owners!'+config.textcol1,
           ' The '+utec+player.team+config.textcol1+' crew took over the '+gymcol+'Gym'+config.textcol1+'.',
           ' Old members may have to re-apply for new membership cards.',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           pause;

           {enter the gym}
           the_gym;

           ch:='R';

          end;

         until ch in ['R','A','T'];

         {evaluate membership}
         case ch of
          'R':begin
                if player.gym_owner=0 then begin
                 d(11,'I''ll be back!');
                end;
              end;
          'T':begin {take over the Gym, fistfight!}
               take_over_the_gym(s);
              end;
          'A':begin {apply for membership}

               if s='' then begin
                d(12,'Not possible.');
               end
               else begin
                crlf;
                s2:=' Gym Access ';
                d(13,cool_string(length(s),'=','-',13,9));
                d(10,s2);
                d(13,cool_string(length(s),'=','-',13,9));

                d(config.textcolor,'You take an application form and start filling it out...');
                sd(config.textcolor,'Posting your application to the '+utec+s+config.textcol1+' crew...');

                {mail team-mates}
                for i:=1 to 2 do begin

                 case i of
                  1: size:=fs(FsPlayer);
                  2: size:=fs(FsNpc);
                 end; {case .end.}

                 for j:=1 to size do begin

                  {load character}
                  load_character(pl0,i,j);

                  if (player_active(pl0,false)) and
                     (pl0.gym_owner>0) and
                     (pl0.team<>'') and
                     (pl0.team=s) and
                     (pl0.name2<>player.name2) then begin

                   if is_online(pl0.name2,online_player)=true then begin
                    {send online mess}
                    online_send_to_player(pl0.name2,online_player,uplc+player.name2+ulred+' has sent you an application'
                                          +' for '+gymcol+'Gym'+config.textcol1+' membership.');
                   end;

                   {mail team-mate}
                   post(MailSend,
                   pl0.name2,
                   pl0.ai,
                   false,
                   mailrequest_GymMembership,
                   player.name2,
                   player.id, {contains player.id to ease identification}
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
                   '',
                   '',
                   '');
                  end;
                 end; {for j:= .end.}
                end; {for i:= .end.}
                d(15,'Done.');
                crlf;
                d(config.textcolor,'The '+utec+s+config.textcol1+' crew will get back to you.');
                crlf;
                pause;
               end;
              end; {apply for membership *end*}
         end; {case .end.}

        end;

       end;
   'A':begin {altar of the gods}
        temple_of_the_gods;
       end;
   'K':begin {kings castle}

        crlf;
        crlf;

        if not player.king then begin

         {player is not king}
         global_auto_probe:=NoWhere;

         crlf;
         d(config.textcolor,'You journey the winding road up to the gates of the Castle.');
         d(config.textcolor,'..');
         crlf;
         sd(config.textcolor,'Seeking the King...');

         s:='';
         male:=true;

         if get_king(pl0)=true then begin
          s:=pl0.name2;
          if pl0.sex=2 then male:=false;
         end;

         if s<>'' then begin
          crlf;
          crlf;
          sd(config.textcolor,'The almighty '+race_display(2,pl0.race,0)+' ');
          sd(global_plycol,s);
          d(config.textcolor,' is sitting comfortably on the throne.');
          d(config.textcolor,'It''s about time somebody removed this self-righteous dictator!');
         end;

        end;

        go:=false;

        {the player is the king}
        if player.king then begin
         if player.team<>'' then player.team:='';

         if f_exists(global_kingf)=false then begin
          {king.dat file is missing}

          {init king record}
          load_king(fload,king);

          {set player impression}
          king.name:=player.name2;
          king.ai  :=player.ai;
          king.sexy:=player.sex;

          {save king record}
          load_king(fsave,king);

         end
         else begin
          load_king(fload,king);

          if (king.name<>player.name2) or (king.ai<>'H') then begin

           king.name:=player.name2;
           king.ai  :='H';
           king.sexy:=player.sex;

           load_king(fsave,king);

          end;

         end;

         show_usurper_data(picture_CROWN,false);
         d(15,'Welcome your highness!');
         the_castle;

        end
        else begin {a throne pretender has arrived}

         {set online location}
         onliner.location:=onloc_outcastle;
         onliner.doing   :=location_desc(onliner.location);
         add_onliner(OUpdateLocation,onliner);

         repeat

          load_king(fload,king);

          {castle menu}
          crlf;
          crlf;
          d(10,'You are standing outside the Castle');

          menu('(T)he Royal Guard');
          menu('(P)rison');
          menu('(D)onate to the Royal Purse');
          menu('(I)nfiltrate the Castle');
          menu('(R)eturn to town');
          crlf;
          sd(config.textcolor,'Outside the Castle ('+config.textcol2+'?'+config.textcol1+' for menu) :');

          ch:=upcase(getchar);

         until ch in ['I','T','P','D','R'];
         crlf;

         case ch of
          'R':begin {return to town}
               crlf;
               d(config.textcolor,'You decide to head back..');
              end;
          'D':begin {donate to the royal purse}

               if player.king then begin
                crlf;
                crlf;
                d(12,'Donate from inside the Castle instead!');
                pause;
               end
               else begin

                crlf;
                crlf;
                d(config.textcolor,'You decide to give a helping hand to the Royal Family.');
                d(config.textcolor,'Benevolence towards the Monarchy might prove to be a');
                d(config.textcolor,'good investment for the future.');
                crlf;
                d(config.textcolor,'You have '+uyellow+commastr(player.gold)+config.textcol1+' '+many_money(player.gold)+'.');
                d(config.textcolor,'How much will you donate?');
                sd(config.textcolor,':');

                {get value}
                x:=get_number(0,player.gold);

                if x=0 then begin
                 crlf;
                 d(12,'Grr! Get out of here!');
                end
                else if x>0 then begin
                 if confirm('Donate '+uyellow+commastr(x)+config.textcol1+' '+many_money(x),'Y')=true then begin

                  {update king record}
                  load_king(fload,king);
                  if IncKingTreasury2(king,x) = false then begin
                   d(12,'They Royal Purse can not accept such an amount!');
                   pause;
                  end
                  else begin
                   DecPlayerMoney(player,x);
                   load_king(fsave,king);

                   crlf;
                   d(config.textcolor,'Your donation has been recorded.');
                   d(config.textcolor,kingstring(king.sexy)+' '+uplc+king.name+config.textcol1+' has been informed.');


                   case player.sex of
                    1: s:='Boy';
                    2: s:='Girl';
                   end;

                   {news-paper}
                   Newsy(true,
                   'Glory '+s,
                   ' '+uplc+player.name2+config.textcol1+' donated '+uyellow+commastr(x)+config.textcol1
                      +' '+many_money(x)+' to the Royal Purse!',
                   ' The Royal Family is grateful.',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '');

                   {inform the King about the donor}
                   if (king.ai='H') and (king.name<>'') then begin

                    if is_online(king.name,online_player) then begin
                     online_send_to_player(king.name,online_player,uplc+player.name2+config.textcol1+' donated '+uyellow
                      +commastr(x)+config.textcol1+' '+many_money(x)+' to the Royal Purse!');
                    end
                    else begin

                     s:=config.moneytype+' Donor';

                     post(MailSend,
                     king.name,
                     king.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     uyellow+s+config.textcol1,
                     mkstring(length(s),underscore),
                     uplc+player.name2+config.textcol1+' donated '+uyellow+commastr(x)+config.textcol1
                        +' '+many_money(x)+' to the Royal Purse!',
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

                 end;

                end;
               end;

              end;
          'P':begin {free royal prisoners}
               free_prisoner;
              end;
          'T':begin {Royal Guard}
               crlf;
               load_king(fload,king);

               found:=false;
               for i:=1 to global_kingguards do begin
                if king.guard[i]=player.name2 then begin
                 j:=i;
                 found:=true;
                 break;
                end;
               end; {for i:= .end.}

               {is player a guard / or does he want to apply for duty}
               if found then begin

                {set online location}
                onliner.location:=onloc_guardoffice;
                onliner.doing   :=location_desc(onliner.location);
                add_onliner(OUpdateLocation,onliner);

                repeat
                 {the Royal Guard Office}

                 {quit guard job}
                 crlf;
                 crlf;
                 d(5,'The Royal Office');
                 menu('(Q)uit your Guard job');
                 menu('(V)iew guard');
                 menu('(R)eturn');


                 crlf;
                 sd(config.textcolor,'Royal Office (');
                 sd(config.hotkeycolor,'?');
                 sd(config.textcolor,' for menu) :');

                 {get user-input}
                 ch:=upcase(getchar);

                 case ch of

                  'Q':begin {quit guard job}
                       {text}
                       crlf;
                       d(config.textcolor,'You resign from your employment.');
                       crlf;

                       {news-paper}
                       Newsy(true,
                       'Royal Staff Angered'+config.textcol1,
                       ' The '+urac+race_display(2,player.race,0)+' '+uplc+player.name2+config.textcol1+
                            ' quit '+sex3[player.sex]+' job as '+ulcyan+'Royal Guard'+config.textcol1+'!',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '');

                       {load king record}
                       load_king(fload,king);

                       {init guard record}
                       if king.guard[j]=player.name2 then begin
                        king.guard[j]:=emptystr;
                        king.guardpay[j]:=0;
                       end;

                       {update king record}
                       load_king(fsave,king);

                       {mail the king}
                       post(MailSend,
                       king.name,
                       king.ai,
                       false,
                       mailrequest_nothing,
                       '',
                       ulred+'Resignation'+config.textcol1,
                       mkstring(11,underscore),
                       uplc+player.name2+config.textcol1+' resigned from the Royal Guard.',
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

                       if (is_online(king.name,online_player)) and
                          (king.name<>'') then begin
                        online_send_to_player(king.name,online_player,broadcast_IQuitAsGuard);
                       end;

                       ch:='R';

                      end;
                  'V':begin {view Royal Guard}
                       view_royal_guard;
                      end;
                 end; {case .end.}

                until ch='R';

               end
               else begin

                {set online location}
                onliner.location:=onloc_guardoffice;
                onliner.doing   :=location_desc(onliner.location);
                add_onliner(OUpdateLocation,onliner);

                repeat
                 {the Royal Guard Office}

                 {apply for guard duty}
                 crlf;
                 crlf;
                 menu('(A)pply for Royal Guard duty');
                 menu('(V)iew guard');
                 menu('(R)eturn');
                 crlf;
                 sd(config.textcolor,'Guard Office ('+config.textcol2+'?'+config.textcol1+' for menu) :');

                 ch:=upcase(getchar);

                 case ch of

                  'A':begin {apply for Guard Duty}

                       {any vacancies?}
                       load_king(fload,king);

                       if king.name='' then begin
                        d(12,'Sorry, the Kingdom is without a King!');
                        d(12,'We desperately need a leader, perhaps you could...');
                        pause;
                       end
                       else begin

                        if (is_online(king.name,online_player)) and
                           (king.ai='C') then begin
                         {if NPC king is online he must not be bothered}

                         crlf;
                         sd(config.textcolor,'Please come back later! ');
                         sd(config.textcolor,kingstring(king.sexy));
                         sd(global_kingcol,king.name);
                         d(config.textcolor,' is busy right now.');
                         crlf;
                        end
                        else begin

                         k:=0;
                         for i:=1 to global_kingguards do begin
                          if king.guard[i]='' then begin
                           k:=i;
                           break;
                          end;
                         end; {for i:= .end.}

                         if k>0 then begin
                          crlf;

                          d(config.textcolor,'You are lucky, there are vacancies for brave soldiers');
                          d(config.textcolor,'right now. You need to fill out this application and');
                          d(config.textcolor,'then await The Royal Office decision. The '+kingstring(king.sexy)
                                             +' also has to approve');
                          d(config.textcolor,'your application.');
                          crlf;
                          d(config.textcolor,'How much do you demand for Daily Salary?');
                          sd(14,':');
                          j:=get_number(0,50000000);

                          if confirm('Send this application','Y')=true then begin
                           d(15,'Done.');
                           d(15,'The Royal Office will put this request before the '+kingstring(king.sexy)+'.');
                           crlf;


                           if king.ai='H' then begin
                            post(MailSend,
                            king.name,
                            king.ai,
                            false,
                            mailrequest_IWantGuard,
                            player.name2,
                            long2str(j), {first message line has the salary offer}
                            long2str(player.sex), {secon message line has player sex}
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
                            '',
                            '');

                            {news-paper}
                            Newsy(true,
                            'Applicant',
                            ' '+uplc+player.name2+config.textcol1+', the '+urac+race_display(2,player.race,0)+','+
                            ' applied for a job at the '+ulcyan+'Royal Guard'+config.textcol1+'.',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                       '');


                            if (is_online(king.name,online_player)) and
                               (king.name<>'') then begin
                             online_send_to_player(king.name,online_player,broadcast_IWantToBeGuard);
                            end;

                           end
                           else begin
                            {The King is computer Controlled}

                            {The King must decide if the offer is reasonable}
                            y:=player.level*1100;

                            if j>y then begin

                             sd(config.textcolor,kingstring(king.sexy)+' ');
                             sd(global_kingcol,king.name);
                             d(config.textcolor,' has declined your offer.');
                             crlf;
                             pause;
                            end
                            else begin
                             {update king record}
                             king.guard[k]   :=player.name2;{guard}
                             king.guardpay[k]:=j;          {salary}
                             king.guardai[k] :=player.ai;  {control/AI}
                             king.guardsex[k]:=player.sex; {sex}

                             load_king(fsave,king);

                             sd(config.textcolor,kingstring(king.sexy)+' ');
                             sd(global_kingcol,king.name);
                             d(config.textcolor,' has ACCEPTED your offer.');

                             crlf;
                             d(15,'To Protect and Serve is our motto!');
                             d(15,'May the Royal Family never come to any harm.');
                             crlf;

                             {news-paper}
                             Newsy(true,
                             'Royal Employment'+config.textcol1,
                             ' '+uplc+player.name2+config.textcol1+' became a '+ulcyan+'Royal Guard'+config.textcol1+'!',
                             '',
                             '',
                             '',
                             '',
                             '',
                             '',
                             '',
                             '');

                             online_send_to_all(uplc+player.name2+config.textcol1+' became a Royal Guard!',player.name2,'');

                             pause;

                            end;

                           end;
                          end
                          else begin
                           d(12,'You changed your mind.');
                          end;

                         end
                         else begin
                          {no free places for guard duty at the moment.
                          but perhaps if the player ca be hired for a lesser
                          salary than one of the other guards. *FIX THIS*}
                          d(12,'The Clerk at the desk informs you that the Royals are in');
                          d(12,'no need of Guards at the present moment.');
                          pause;
                         end;
                        end;
                       end;
                      end;
                  'V':begin {view Royal Guard}
                       view_royal_guard;
                      end;
                 end; {case .end.}
                until ch='R';
               end;

              end; {body-guard .end.}

          'I':begin {infiltrate the castle}
               crlf;
               go:=true;

               if config.MinLevelKing=0 then begin
                d(10,'Sorry! Nobody can can have a go at the Crown right now!');
                d(12,'(your beloved sysop has decided this)');
                go:=false;
                pause;
               end
               else if player.level<config.MinLevelKing then begin
                d(15,'NO WAY! You must be at least a level '+commastr(config.MinLevelKing)+' character!');
                go:=false;
                pause;
               end
               else if (player.dark>player.chiv) and (config.SoulNeededKing=1) then begin
                d(15,'Only players with a clear conscience may attempt this!');
                d(15,'Your acts of evil disqualify you!');
                go:=false;
                pause;
               end
               else if (player.chiv>player.dark) and (config.SoulNeededKing=2) then begin
                d(15,'Only players with an evil mind may attempt this!');
                d(15,'Your soul needs to be darkened, I can tell...');
                go:=false;
                pause;
               end
               else if player.team<>'' then begin
                crlf;
                d(15,'Quit your team first! If you''re going up against the Royals');
                d(15,'you must alone, not representing any other interest than yourself.');
                go:=false;
                pause;
               end
               else begin

                {is the player a royal guard?}
                load_king(fload,king);

                for i:=1 to global_kingguards do begin
                 if king.guard[i]=player.name2 then begin
                  d(12,'Quit your Royal Guard job first!');
                  pause;
                  go:=false;
                  break;
                 end;
                end; {for i:= .end.}

               end;

               if go then begin
                if s='' then begin

                 {become king by default}
                 if player.sex=1 then s:='KING'
                                 else s:='QUEEN';

                 {set user flags}
                 player.king:=true;
                 user_save(player);

                 d(config.textcolor,'The Castle seems to be in disarray!');
                 d(config.textcolor,'No King or Queen is to be found anywhere. People are just');
                 d(config.textcolor,'running around in a disorganized manner.');

                 if confirm('Proclaim yourself '+s,'N')=false then begin
                  player.king:=false;
                  user_save(player);
                 end
                 else begin
                  {delete previous orders}
                  if f_exists(global_kingf) then begin
                   delete_file(global_kingf);
                  end;

                  {load empty king record}
                  load_king(fload,king);

                  {set new king values}
                  king.name:=player.name2;
                  king.ai  :='H';
                  king.sexy:=player.sex;

                  {save updated king record}
                  load_king(fsave,king);

                  crlf;
                  crlf;
                  d(14,'Congratulations, The Castle is Yours!');
                  d(config.textcolor,'The InterRegnum is over, long live the '+s);
                  crlf;

                  {put the event in the news}
                  newsy(true,uwhite+'NEW '+s+'! --- NEW '+s+'! --- NEW '+s+'! --- NEW '+s+'!'+config.textcol1,
                  ' '+ukingc+player.name2+config.textcol1+' usurped the thone today!',
                  ' May the new rulers reign be long and prosperous!',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  {inform other nodes}
                  online_send_to_all(uplc+player.name2+config.textcol1+' is the NEW '+s+'!',player.name2,'');

                  case player.sex of
                   1: s:='KING';
                   2: s:='QUEEN';
                  end;

                  {put the news in the Monarch News-file}
                  Generic_News(RoyalNews,
                  true,
                  config.textcol1+' The '+race_display(2,player.race,0)+' '+ukingc+player.name2+config.textcol1
                                 +' was elected '+s+'.',
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
                 end;

                end
                else if anybody_on_location(onloc_castle,player.name2)=true then begin
                 d(15,'The Castle is under attack!');
                 d(config.textcolor,'Security is tight right now, You must come back at a later moment.');
                 crlf;
                 pause;
                end
                else if is_online(s,online_player)=true then begin
                 {king online, challenge called off}
                 if male then d(15,'The King is online minding his business.')
                         else d(15,'The Queen is online minding her business.');
                 d(12,'Sorry, try again later!');
                end
                else begin
                 if confirm('Infiltrate the Castle','N')=false then begin
                  d(15,'Weakling!');
                 end
                 else begin

                  {go for the crown!}
                  d(14,'You want the Crown...');

                  {check again that the king hasn't arrived or}
                  if (is_online(pl0.name2,online_player)=false) and
                     (anybody_on_location(onloc_castle,player.name2)=false) then begin

                   {update online file so nobody can attack the castle
                    at the same time}
                   onliner.location:=onloc_castle; {in the Royal Castle}
                   onliner.doing   :=location_desc(onliner.location);
                   add_onliner(OUpdateLocation,onliner);

                   {place king online}
                   if add_shadow(SAdd,pl0,player.name2,'fighting to keep the throne',0)=false then begin
                    d(global_plycol,pl0.name2+config.textcol1+' has entered the Realm! Try again later.');
                    pause;
                   end
                   else begin

                    {worsen kings attitude to player}
                    Update_Relation(Relation_Worsen,2,pl0,player,true,false);

                    {the challenge}
                    challenge_king(pl0,player,false);

                    {remove king from being online}
                    add_shadow(SRemove,pl0,'','going to sleep...',0);

                   end;

                  end {EOF CHALLENGE}
                  else begin
                   d(12,'Sorry, try again later. The Royals are back!');
                   d(12,'It''s too dangerous right now.');
                   crlf;
                  end;

                 end;
                end;

               end; {sista}
              end; {infiltrate castle .end.}
         end; {case .end.}
        end;
       end; {KINGS CASTLE *END*}
   'J':begin {Journey to the Gods .start.}
        if global_ubeta then begin
         crlf;
         crlf;
         d(config.textcolor,'You meet a glum old man carrying a glow-worm.');
         crlf;
         pause;
        end;

       end; {Journey to the Gods .end.}
   'B':begin {Bounty Hunting}
        muffis;
        if global_registered then begin
         muffis;
         if global_registered then begin
          bounty_hunters;
         end
         else begin
          crlf;
          only_in_registered_version;
          crlf;
         end;
        end
        else begin
         crlf;
         only_in_registered_version;
         crlf;
        end;
       end;
   'O':begin {Online Challenge}

        crlf;
        d(config.textcolor,'Who would you like to challenge?');
        sd(config.textcolor,':');

        {get user-input}
        s:=get_string(20);

        found:=false;
        great:=false;

        for i:=1 to fs(FsOnline) do begin

         load_onliner(fload,only,i);

         if (findsub(s,only.name)) and
            (only.name<>player.name2) and
            (only.name<>'') then begin

          if confirm(uplc+only.name+config.textcol1,'n')=true then begin
           found:=true;

           if only.com<>' ' then begin
            crlf;
            sd(global_plycol,only.name);
            d(config.textcolor,' is busy and can''t accept the challenge right now.');
           end
           else if only.location in [onloc_mainstreet,
                                      onloc_theinn,
                                      onloc_darkalley,
                                      onloc_church,
                                      onloc_weaponshop,
                                      onloc_master,
                                      onloc_madmage,
                                      onloc_armorshop,
                                      onloc_bank,
                                      onloc_reportroom,
                                      onloc_healer,
                                      onloc_marketplace,
                                      onloc_foodstore,
                                      onloc_plymarket,
                                      onloc_recruit,
                                      onloc_dormitory] then begin

            onliner.doing:='challenging '+uplc+only.name+config.textcol1;
            onliner.com:=' ';

            if config.semaphore<>'' then begin
             onliner.comfile:=config.semaphore+crypt(8)+'.TMP';
            end
            else begin
             onliner.comfile:=crypt(8)+'.TMP';
            end;

            onliner.bname:=only.name;
            add_onliner(OUpdateAll,onliner);

            crlf;
            sd(config.textcolor,'You send out a messenger looking for ');
            sd(global_plycol,only.name);
            sd(config.textcolor,'.');
            great:=true;
            break;

           end
           else begin
            crlf;
            sd(global_plycol,only.name);
            d(config.textcolor,' is busy and can''t accept the challenge right now.');
           end;
          end;
         end;

        end; {for i:= .end.}

        {found a player to poll}
        if great=true then begin

         {poll only player}
         only.bname  :=onliner.name;
         only.com    :=intercom_challenge;
         only.comfile:=onliner.comfile;
         load_onliner(fsave,only,i);

         cc:=0;
         abort:=false;

         sd(config.textcolor,'(press ');
         sd(config.hotkeycolor,'A');
         sd(config.textcolor,' to abort)');
         repeat
          inc(cc);
          delay2(global_online_poll_delay);
          node_check;

          if config.spincursor=true then begin
           spin_cursor(2,config.textcolor);
          end
          else begin
           sd(config.textcolor,'.');
          end;

          if cc>global_online_maxwaits then begin
           abort:=true;
          end
          else begin
           {check if user has pressed A}
           if ukeypressed then begin
            ch:=upcase(getchar);
            if ch='A' then begin
             crlf;
             d(12,'abort.');
             abort:=true;
            end;
           end;

           my_timeslice;
          end;

         until (onliner.com in [intercom_accept,intercom_decline]) or (abort);

         if abort=false then begin
          crlf;
          if onliner.com=intercom_accept then begin
           d(15,'Your opponent has accepted! (FIGHT!)');

           onliner.doing:='fighting '+uplc+only.name+config.textcol1;
           add_onliner(OUpdateLocation,Onliner);

           global_multi:=false;
           online_duel(true);

          end
          else if onliner.com=intercom_decline then begin
           d(15,'Your opponent has declined! (what a CHICKEN!)');
          end
          else begin
           sd(global_plycol,only.name);
           d(config.textcolor,' didn''t answer your challenge!');
          end;
         end;

        end
        else if found=false then begin
         d(15,'Couldn''t locate that character.');
        end;

        onliner.bname:='';
        onliner.com:=intercom_empty;
        add_onliner(OUpdateAll,onliner);
        global_multi:=true;

       end;
   'T':begin
       { crlf;
        crlf;
        d(14,'Hey! Wait a minute!');
        d(12,'Entering the Castle can bring instant');
        d(12,'death to any small time player...');

        sd(config.textcolor,'Are you sure about doing this ');
        if confirm('','n')=true then begin
         the_castle;
        end;  }
       end;
   'R':begin {Return to MainStreet}
        crlf;
        exit;
       end;
   '?':begin {Menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;

   'G':begin {GangWars}

        if player.team<>'' then begin
         cho:='?';

         repeat

          if onliner.location<>onloc_gangprep then begin
           onliner.location:=onloc_gangprep;
           onliner.doing   :=location_desc(onliner.location);
           add_onliner(OUpdateLocation,onliner);
          end;

          if cho='?' then begin
           clearscreen;
           crlf;
           d(5,'-*- Team Bashing -*-');
           crlf;
           d(config.textcolor,'You and your men equip yourselves with your sharpened weapons');
           d(config.textcolor,'and start walking the streets, checking the known gang hangouts.');
           crlf;
           menu('(A)ttack!');
           menu('(C)ombat Ready teams (list)');
           menu('(R)eturn');
          end;
          crlf;

          sd(config.textcolor,'Gangwars ('+config.textcol2+'?'+config.textcol1+' for menu) :');

          {get user input}
          cho:=upcase(getchar);

          {evaluate user input}
          case cho of
           'C':begin {list of teams, ready to fight}
                sort_teams(false,false,true,false);
               end;
           'A':begin {attack team}

                allow:=true;

                {if one-man-teams are not allowed then we must check if the
                 player is alone or not}
                if config.onemanshow=false then begin
                 allow:=false;

                 for i:=1 to fs(FsPlayer) do begin
                  load_character(pl0,1,i);
                  if (pl0.name2<>player.name2) and
                     (pl0.team=player.team) and
                     (player_active(pl0,false)=true) then begin
                   allow:=true;
                   break;
                  end;
                 end; {for i:= .end.}

                 if allow=false then begin
                  for i:=1 to fs(FsNpc) do begin

                   load_character(pl0,2,i);

                   if (pl0.name2<>player.name2) and
                      (pl0.team=player.team) and
                      (player_active(pl0,false)=true) then begin
                    allow:=true;
                    break;
                   end;

                  end; {for i:= .end.}

                 end;
                end;

                if allow then begin

                 s:=attack_team;
                 if s<>'' then begin
                  gang_wars(s,false);
                 end;

                end
                else begin
                 crlf;
                 d(12,'You must have at least 2 teammembers before attacking');
                 d(12,'another team.');
                 crlf;
                 pause;
                end;
               end;
          end;
         until cho='R';
        end
        else begin
         crlf;
         d(12,'You don''t belong to a team!');
        end;
        cho:=' ';
       end; {Gangwars .end.}

   'F':begin {Flee town control}

        if (player.team<>'') and (player.cturf=false) then begin
         crlf;
         d(config.textcolor,'Your team doesn''t control the town.');
        end
        else if player.team='' then begin
         crlf;
         d(5,'You don''t belong to a team!');
        end
         else begin
         crlf;
         if confirm('Are you SURE that you wanna leave town control','n')=true then begin
          crlf;
          d(config.textcolor,'You publicly announce your teams withdrawal from town control.');
          d(config.textcolor,'The big question now is : Who''s gonna take over!?');
          crlf;
          d(config.textcolor,'(By the way, i hope that your teammates know about this!)');
          crlf;

          team_record(player.team);
          player.cturf:=false;
          for i:=1 to fs(FsPlayer) do begin
           load_character(pl0,1,i);
           if pl0.team=player.team then begin
            pl0.cturf:=false;
            user_save(pl0);
           end;
          end;

          for i:=1 to fs(FsNpc) do begin
           load_character(pl0,2,i);
           if pl0.team=player.team then begin
            pl0.cturf:=false;
            user_save(pl0);
           end;
          end; {for i:= .end.}

          {news-paper}
          newsy(true,
          'Team withdrawal from Town Control!'+config.textcol1,
          ' '+uplc+player.name2+config.textcol1+' decided to remove '+sex3[player.sex]+' team from Town Control.',
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
   'D':begin {dormitory}
        dormitory;
       end;
   'C':begin {Claim Town Control}
        if player.cturf=true then begin
         crlf;
         d(12,'Your team already control the town!');
        end
        else if player.team='' then begin
         crlf;
         d(12,'You are not a member of a team!');
        end
        else if player.tfights<1 then begin
         crlf;
         d(12,'Sorry, but you have no team-fights left.');
        end
        else begin
         crlf;
         crlf;
         d(11,'The Town is mine!');
         d(12,mkstring(17,underscore));

         d(config.textcolor,'This can be quite bloody business.');
         d(config.textcolor,'You can end up with a lot of stiffs here.');
         crlf;
         if confirm('Really go to GANGWAR','n')=true then begin
          dec(player.tfights);
          gang_wars('vet inte „nnu!',true);
          player.gnollp:=0;
         end
         else begin
          crlf;
          d(config.textcolor,'Well, You can take''m out later.');
         end;
        end;
       end;
   'R':begin {return to mainstreet}
        exit;
       end;

  end; {case .end.}

 until Never; {MAIN-LOOP *end*}

end; {Challenges *end*}

end. {Unit Challeng .end.}
