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
Unit PrisonC1; {Usurper - Kings Castle, Prison from the Kings view}

Interface

Procedure Royal_Prison;

Implementation

Uses Init, Cms, Jakob,
     Statusc, Various, News,
     Relation, Mail, Online,
     Various3, File_Io;

Procedure Royal_Prison;
const cap = 'Ronald'; {captain of the guard *same as in prisonf.pas}

var cho : char;
    cc, days: byte;
    s,s2,s4 : s70;

    daystr : string[4];
    i,j,x : word;
    size : word;
    counter,counter2 : word;
    pl0 : userrec;
    found, nomore, shadow:boolean;

   king : kingrec; {king orders, open establishments, taxes. etc .etc}
   onguy : onlinerec;

   leave_prison,
   abort : boolean;

begin

 crlf;
 crlf;
 d(config.textcolor,'You walk the long and winding stairs down to the prison');
 sd(config.textcolor,'dungeons.');

 leave_prison:=false;
 cho:='?';
 repeat

  if cho='?' then begin
   crlf;
   crlf;
   menu('(P)risoners');
   menu('(F)ree prisoner');
   menu('(I)mprison subject');
   menu('(E)xecute');
   menu('(S)tatus');
   menu('(R)eturn');
  end;

  crlf;
  sd(config.textcolor,'Prison ('+config.textcol2+'?'+config.textcol1+' for menu) :');

  {get user-input}
  cho:=upcase(getchar);

  case cho of
   'S':begin {player status}
        status(player);
       end;
   'R':begin {return}
        leave_prison:=true;
       end;
   'E':begin {execute prisoner .start.}
        load_king(fload,king);
        if king.executeleft<1 then begin
         crlf;
         d(12,'You have no executions left today.');
        end
        else begin
         crlf;
         sd(config.textcolor,'You send for ');
         sd(global_plycol,cap);
         d(config.textcolor,', Captain of the Guard.');
         crlf;
         d(global_talkcol,'Who should we take care of sire?');
         sd(config.textcolor,':');
         s:=get_string(20);
         s:=upcasestr(s);
         found:=false;
         nomore:=false;

         {search among the humans and NPCs}
         for i:=1 to 2 do begin
          case i of
           1: size:=fs(FsPlayer);
           2: size:=fs(FsNpc);
          end;

          if (found) or (nomore) then break;
          for j:=1 to size do begin

           {load character}
           load_character(pl0,i,j);

           if (findsub(s,pl0.name2)) and
              (pl0.name2<>player.name2) and
              (pl0.king=false) and
              (pl0.location=offloc_prison) and
              (pl0.deleted=false) then begin

            if confirm(uplc+pl0.name2+config.textcol1,'N')=true then begin
             found:=true;
             break;
            end
            else begin
             if confirm('Continue search ','Y')=false then begin
              nomore:=true;
              break;
             end;
            end;
           end;
          end; {for j:= .end.}
         end; {for i:= .end.}

         shadow:=false;
         if (found) and (is_online(pl0.name2,online_player)) then begin
          {execute ONLINE prisoner}
          crlf;
          sd(global_plycol,pl0.name2);
          d(config.textcolor,' is wandering around in '+sex3[pl0.sex]+' cell.');
          sd(config.textcolor,'Let''s fetch '+sex[pl0.sex]+'...');

          {semaphore file stuff}
          onliner.bname:=pl0.name2;
          if config.semaphore<>'' then begin
           onliner.comfile:=config.semaphore+crypt(8)+'.TMP';
          end
          else begin
           onliner.comfile:=crypt(8)+'.TMP';
          end;

          {add shadow playher}
          add_onliner(OUpdateAll,onliner);

          x:=0;
          for i:=1 to fs(FsOnline) do begin
           load_onliner(fload,onguy,i);
           if onguy.name=pl0.name2 then begin
            x:=i;
            break;
           end;
          end; {for i:= .end.}

          {poll onguy player}
          onguy.bname  :=onliner.name;
          onguy.com    :=intercom_execute;
          onguy.comfile:=onliner.comfile;
          load_onliner(fsave,onguy,x);

          cc:=0;
          repeat
           inc(cc);
           delay2(global_online_poll_delay);
           node_check;
           sd(config.textcolor,'.');
          until (onliner.com in [intercom_accept,intercom_decline]) or (cc>global_online_maxwaits);
          crlf;

          if onliner.com<>intercom_accept then begin
           {refuses to leave his cell, or doesn't answer}
           sd(global_plycol,pl0.name2);
           d(config.textcolor,' refuses to leave '+sex3[pl0.sex]+' cell!');
           sd(config.textcolor,'You reinforce the Guard, and ');
           sd(global_plycol,pl0.name2);
           d(config.textcolor,' is soon under control.');
          end;

         end
         else if found then begin
          {pl0 is not online, we put him as shadow}
          {add shadow}
          if add_shadow(SAdd,pl0,player.name2,'being executed',0)=true then begin
           shadow:=true;
          end
          else begin
           found:=false;
          end;
         end;

         if found then begin {execute offline prisoner}

          {prisoner is brought up}
          crlf;
          sd(global_plycol,pl0.name2);
          d(config.textcolor,' is brought up from '+sex3[pl0.sex]+' cell.');
          crlf;

          if player.sex=1 then s:='King'
                          else s:='Queen';

          {why death?}
          d(5,'You are hereby sentenced to death for your unspeakable');
          d(5,'crimes! The execution is to be carried out immediately.');
          sd(config.textcolor,'(This is my will, ');
          sd(global_plycol,s+' '+player.name2);
          d(config.textcolor,')');
          crlf;

          if confirm('Sign this order','Y')=true then begin
           {execute}
           crlf;
           sd(13,'Schwoooooop.........');
           delay2(global_online_poll_delay);
           d(13,'....!');

           sd(global_plycol,pl0.name2+'s');
           d(config.textcolor,' cut off head rolls down in the basket.');

           d(config.textcolor,'Thats that! Nice and clean. Now let''s continue with our business.');

           {worsen pl0:s attitude to player}
           Update_Relation(Relation_Worsen,2,pl0,player,false,false);

           {news}
           newsy(true,
           config.textcol1+'Execution',
           ' '+ulred+pl0.name2+config.textcol1+', the '+race_display(2,pl0.race,0)+', was sentenced to death and'
              +' beheaded!',
           ' '+s+ukingc+' '+player.name2+config.textcol1+' signed the order.',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {mail text}
           case random(5) of
            0: s2:='(there is no justice)';
            1: s2:='(you must get rid of that dictator)';
            2: s2:='('+player.name2+' hates your guts)';
            3: s2:='(life is not fair)';
            4: s2:='(it is my destiny)';
           end; {case }

           {mail to imprisoned subject}
           post(MailSend,
           pl0.name2,
           pl0.ai,
           false,
           mailrequest_nothing,
           '',
           ulred+'Executed!'+config.textcol1,
           mkstring(9,underscore),
           s+ukingc+' '+player.name2+config.textcol1+' had you executed after a short trial.',
           s2,
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

           {tell other nodes}
           online_send_to_all(uplc+pl0.name2+config.textcol1+' was executed in prison!',player.name2,'');

           {update prisoner}
           pl0.location:=offloc_dormitory;
           {pl0.allowed:=false;}
           Reduce_Player_Resurrections(pl0,false);
           pl0.hps:=0;
           user_save(pl0);

           {update kingrec}
           dec(king.executeleft);
           load_king(fsave,king);

          end;

          if shadow then begin
           {remove shadow}
           add_shadow(SRemove,pl0,'','',0);
          end;

          {remove semaphore comfile}
          if f_exists(onliner.comfile) then begin
           delete_file(onliner.comfile);
          end;

         end; {found}

        end;

       end; {execute prisoner .end.}

   'F':begin {free prisoner .start.}

        crlf;
        sd(config.textcolor,'You send for ');
        sd(global_plycol,cap);
        d(config.textcolor,', Captain of the Guard.');
        crlf;
        d(global_talkcol,'Who should be released sire?');
        sd(config.textcolor,':');
        s:=get_string(20);
        s:=upcasestr(s);
        found:=false;
        nomore:=false;

        {searching among the humans and NPCs}
        for i:=1 to 2 do begin

         case i of
          1: size:=fs(FsPlayer);
          2: size:=fs(FsNpc);
         end;

         for j:=1 to size do begin
          {load character}
          load_character(pl0,i,j);

          if (findsub(s,pl0.name2)) and
             (pl0.name2<>player.name2) and
             (pl0.name2<>global_delname2) and
             (pl0.king=false) and
             (pl0.location=offloc_prison) and
             (pl0.deleted=false) then begin

           if confirm(uplc+pl0.name2+config.textcol1,'N')=true then begin
            found:=true;
           end
           else begin
            if confirm('Continue search','Y')=false then begin
             nomore:=true;
            end;
           end;
          end;

          if (found) or (nomore) then break;
         end; {for j:= .end.}
         if (found) or (nomore) then break;
        end; {for i:= .end.}

        if (found) and
           (is_online(pl0.name2,online_player)=true) then begin

         {release ONLINE prisoner}
         crlf;
         sd(global_plycol,pl0.name2);
         d(config.textcolor,' is wandering around in '+sex3[pl0.sex]+' cell.');
         sd(config.textcolor,'Let''s fetch '+sex[pl0.sex]+'...');

         {semaphore file stuff}
         onliner.bname:=pl0.name2;
         if config.semaphore<>'' then begin
          onliner.comfile:=config.semaphore+crypt(8)+'.TMP';
         end
         else begin
          onliner.comfile:=crypt(8)+'.TMP';
         end;

         {update self}
         add_onliner(OUpdateAll,onliner);

         sd(config.textcolor,'(press ');
         sd(config.hotkeycolor,'A');
         sd(config.textcolor,' to abort)');

         online_release(pl0.name2);

         cc:=0;
         abort:=false;
         repeat

          inc(cc);
          delay2(global_online_poll_delay);
          node_check;
          sd(config.textcolor,'.');

          if cc>global_online_maxwaits then begin
           abort:=true;
          end
          else begin
           {check if user has pressed A}
           if ukeypressed then begin
            cho:=upcase(getchar);
            if cho='A' then begin
             crlf;
             d(12,'abort.');
             abort:=true;
            end;
           end;
          end;
         until (onliner.com in [intercom_accept,intercom_decline]) or
               (abort);

         crlf;

         if onliner.com=intercom_accept then begin
          {accept}
          sd(global_plycol,pl0.name2);
          d(config.textcolor,' thanks you for your kindness and walks out of '+sex3[pl0.sex]+' cell!');

          if player.sex=1 then s:='King'
                          else s:='Queen';
          {news-paper}
          newsy(true,
          config.textcol1+'Freedom',
          ' '+s+ukingc+' '+player.name2+config.textcol1+' released '+uplc+pl0.name2+config.textcol1+' from prison!',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
         end
         else if onliner.com=intercom_decline then begin
          {decline}
          sd(global_plycol,pl0.name2);
          d(config.textcolor,' refuses to leave '+sex3[pl0.sex]+' cell!');
         end
         else begin
          {no answer}
          sd(global_plycol,pl0.name2);
          d(config.textcolor,' doesn''t seem to care what you offer '+sex[pl0.sex]+'!');
         end;

         {remove semaphore comfile}
         if f_exists(onliner.comfile) then begin
          delete_file(onliner.comfile);
         end;

        end
        else if found then begin {prisoner is offline}

         {add shadow}
         if add_shadow(SAdd,pl0,player.name2,'being released from prison',0)=false then begin
          {unable to add pl0}
          d(global_plycol,pl0.name2+config.textcol1+' is awake! try again!');
          pause;
         end
         else begin

          {humiliate before relase?}
          crlf;
          sd(global_plycol,pl0.name2);
          d(config.textcolor,' is brought up from '+sex3[pl0.sex]+' cell.');
          crlf;

          sd(config.textcolor,'Be cruel to ');
          sd(global_plycol,pl0.name2);
          sd(config.textcolor,' before release');
          if confirm('','Y')=true then begin

           repeat
            crlf;
            menu('(F)orce '+sex[pl0.sex]+' to kiss the royal feet.');
            menu('(D)rag '+sex[pl0.sex]+' through the mud.');
            menu('(B)eat '+sex[pl0.sex]+' up.');
            sd(config.textcolor,':');
            {get user-input}
            cho:=upcase(getchar);
           until cho in ['F','D','B'];

          end
          else begin
           cho:='N';
          end;
          crlf;

          {evaluate user-input}
          case cho of
           'F': x:=1; {kiss feet}
           'D': x:=2; {drag through mud}
           'B': x:=3; {beat up}
           'N': x:=4; {nice release}
          end; {case .end.}


          case x of
           1:begin {forced to kiss feet}
              sd(global_plycol,pl0.name2);
              d(config.textcolor,' crawls out of '+sex3[pl0.sex]+' cell,');
              d(config.textcolor,sex2[pl0.sex]+' kisses your feet and disappears out to freedom.');
              crlf;
             end;
           2:begin {dragged through the mud}
              sd(global_plycol,pl0.name2);
              d(config.textcolor,' is dragged through the mud by your loyal henchmen.');
              d(config.textcolor,'You take no notice of '+pl0.name2+'s screaming. In fact, you find');
              d(config.textcolor,'it amusing. Finally, '+pl0.name2+' is kicked out on the street.');
              crlf;
             end;
           3:begin {beat up}
              sd(global_plycol,pl0.name2);
              sd(config.textcolor,' is given a proper beating by ');
              sd(global_plycol,cap);
              d(config.textcolor,' (a sadist).');

              sd(config.textcolor,'After a while, when ');
              sd(global_plycol,pl0.name2);
              d(config.textcolor,' is unconscious, You give order to');
              d(config.textcolor,'throw '+sex[pl0.sex]+' in the gutter.');
              crlf;
             end;
           4:begin {nice release}
              sd(global_plycol,pl0.name2);
              d(config.textcolor,' crawls out from '+sex3[pl0.sex]+' cell,');
              d(config.textcolor,sex2[pl0.sex]+' thanks you and leaves for the Beer Hut.');
              crlf;
             end;

          end; {case .end.}

          {release}
          pl0.location:=offloc_dormitory;

          if player.sex=1 then s:='King'
                          else s:='Queen';

          {news text}
          s2:='';
          case x of
           1: s2:=' '+uplc+pl0.name2+config.textcol1+' was forced to kiss the royal feet.';
           2: s2:=' '+uplc+pl0.name2+config.textcol1+' was dragged through the mud before released.';
           3: s2:=' '+uplc+pl0.name2+config.textcol1+' was beat up by the guards before released.';
           4: s2:=''; {nice release}
          end; {case .end.}

          {news}
          newsy(true,
          config.textcol1+'Pardon',
          ' '+s+ukingc+' '+player.name2+config.textcol1+' released '+uplc+pl0.name2+config.textcol1+' from prison!',
          ''+s2,
          '',
          '',
          '',
          '',
          '',
          '',
          '');

          {mail text}
          s2:='';
          case x of
           1: s2:='You had to kiss the royal feet before you were set free!';
           2: s2:='You were dragged through the mud before you were released!';
           3: s2:='You were beat up by the guards before they kicked you out!';
           4: s2:=''; {nice release}
          end; {case .end.}

          {improve pl0:s attitude to player}
          Update_Relation(Relation_Better,1,pl0,player,false,false);

          {tell other nodes}
          online_send_to_all(uplc+pl0.name2+config.textcol1+' was relesed from prison!',player.name2,'');

          {mail to imprisoned subject}
          post(MailSend,
          pl0.name2,
          pl0.ai,
          false,
          mailrequest_nothing,
          '',
          umailheadc+'Released!'+config.textcol1,
          mkstring(9,underscore),
          s+ukingc+' '+player.name2+config.textcol1+' released you from prison!',
          s2,
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

          {update prisoner}
          user_save(pl0);

          {remove shadow}
          add_shadow(SRemove,pl0,'','',0);
         end;

        end; {found}

       end; {release prisoner .end.}

   'I':begin {imprison subject}

        {load the king}
        load_king(fload,king);

        if king.prisonsleft<1 then begin
         crlf;
         crlf;
         d(12,'You have run out of prison sentences.');
         crlf;
        end
        else if Config.AllowKingtoImprison=0 then begin
         crlf;
         crlf;
         d(12,'The Super-God (SYSOP) has ruled that you may not imprison any person!');
         crlf;
         pause;
        end
        else begin
         crlf;
         sd(config.textcolor,'You send for ');
         sd(global_plycol,cap);
         d(config.textcolor,', Captain of the Guard.');
         crlf;
         d(global_talkcol,'Who shall we bring in sire?');
         sd(config.textcolor,':');

         s:=get_string(20);
         s:=upcasestr(s);
         found:=false;
         nomore:=false;

         {search among the humans and NPCs}
         for i:=1 to 2 do begin

          case i of
           1: size:=fs(FsPlayer);
           2: size:=fs(FsNpc);
          end;

          if (found) or (nomore) then break;
          for j:=1 to size do begin
           load_character(pl0,i,j);

           if (findsub(s,pl0.name2)) and
              (pl0.name2<>player.name2) and
              (pl0.hps>0) and
              (pl0.king=false) and
              (pl0.deleted=false) and
              (is_online(pl0.name2,online_player)=false) then begin

            sd(global_plycol,pl0.name2);
            if confirm(' ','n')=true then begin
             if pl0.location=offloc_prison then begin
              d(global_plycol,pl0.name2+config.textcol1+' is already in prison!');
              pause;
              crlf;
             end
             else begin
              found:=true;
              break;
             end;
            end
            else begin
             if confirm('Continue search ','Y')=false then begin
              nomore:=true;
              break;
             end;
            end;
           end;
          end; {for j:= .end.}
         end; {for i:= .end.}

         {imprison}
         if (found) and (is_online(pl0.name2,online_player)=false) then begin

          {add shadow}
          if add_shadow(SAdd,pl0,player.name2,'being arrested',0)=false then begin
           {unable to add pl0}
           d(global_plycol,pl0.name2+config.textcol1+' is awake! try again!');
           pause;
          end
          else begin

           repeat
            crlf;
            crlf;
            sd(global_plycol,pl0.name2);
            d(config.textcolor,' is brought before you in chains.');
            crlf;

            d(5,'And the charges ?');

            menu('(H)igh treason');
            menu('(P)ublic nuisance');
            menu('(D)isrespect to the Crown');
            menu('(C)riminal activities');
            menu('(N)o charges necessary');
            menu('(A)bort');
            sd(config.textcolor,':');

            {get user-input}
            cho:=upcase(getchar);
           until cho in ['H','P','D','C','N','A'];

           case cho of
            'A':begin
                 crlf;
                 d(config.textcolor,'You release '+uplc+pl0.name2+config.textcol1+'.');
                 {remove shadow}
                 add_shadow(SRemove,pl0,'','',0);
                 crlf;
                end;
            'H':begin {high treason}
                 {s2 = public news,
                  s4 = private mail to arrested subject
                       }
                 s2:=uplc+pl0.name2+config.textcol1+' was arrested for High Treason!';
                 s4:='You were arrested for High Treason.';
                end;
            'P':begin {puclic nuisance}
                 s2:=uplc+pl0.name2+config.textcol1+' was arrested for '+sex3[pl0.sex]+' indecent behaviour.';
                 s4:='You were arrested for being a public nuisance.';
                end;
            'D':begin {disrespect to the Crown}
                 s2:=uplc+pl0.name2+config.textcol1+' was arrested for mocking the Royal Family.';
                 s4:='You were arrested for mocking the Royal Family.';
                end;
            'C':begin {criminal activities}
                 s2:=uplc+pl0.name2+config.textcol1+' was arrested for alleged criminal activities.';
                 s4:='You were arrested for alleged criminal activities.';
                end;
            'N':begin {no charges necessary}
                 s2:='no official explanation has been given to the arrest.';
                 s4:='No explanation why you were arrested was given.';
                end;

           end; {case cho of .end.}


           if cho<>'A' then begin

            crlf;
            sd(global_plycol,pl0.name2);
            d(config.textcolor,' looks at you with a surprised look on '+sex3[pl0.sex]+' face!');
            sd(global_talkcol,' I''m innocent!');
            crlf;
            pause;

            {sentence, how many days}
            days:=1;
            if config.AllowKingtoImprison>1 then begin
             crlf;
             crlf;
             if confirm('Should '+uplc+pl0.name2+config.textcol1+' stay in Prison for more than'
                        +' 1 day','N')=true then begin

              crlf;
              d(config.textcolor,'How many days? (1-'+commastr(config.allowkingtoimprison)+')');
              sd(config.textcolor,':');
              days:=get_number(1,config.allowkingtoimprison);

              {let offline player comment on the sentence}
              case random(7) of
               0: d(global_plycol,pl0.name2+config.textcol1+' hates you!');
               1: d(global_plycol,pl0.name2+config.textcol1+' hates your guts!');
               2: d(global_plycol,pl0.name2+config.textcol1+' swears to kill you!');
               3: d(global_plycol,pl0.name2+config.textcol1+' thinks you are ugly!');
               4: d(global_plycol,pl0.name2+config.textcol1+' begs you to forgive '+sex[pl0.sex]+'!');
               5: d(global_plycol,pl0.name2+config.textcol1+' would love to see you in a hot place!');
               6: d(global_plycol,pl0.name2+config.textcol1+' begs you to release '+sex[pl0.sex]+'!');
              end; {case .end.}

             end;
            end;

            crlf;
            sd(global_plycol,'');
            sd(global_plycol,pl0.name2);
            d(config.textcolor,' is sent down to '+sex3[pl0.sex]+' cell.');
            crlf;

            if player.sex=1 then s:='King'
                            else s:='Queen';

            if days>1 then daystr:='days'
                      else daystr:='day';

            {worsen pl0:s attitude to player}
            Update_Relation(Relation_Worsen,2,pl0,player,false,false);

            {news}
            newsy(true,
            config.textcol1+'Prisoner',
            ' '+s+ukingc+' '+player.name2+config.textcol1+' imprisoned '+ulred+pl0.name2+config.textcol1+'!',
            ' '+s2,
            ' '+uplc+pl0.name2+config.textcol1+' will stay in prison for '+uwhite+commastr(days)+config.textcol1+' '
               +daystr+'.',
            '',
            '',
            '',
            '',
            '',
            '');

            {tell other nodes}
            online_send_to_all(uplc+pl0.name2+config.textcol1+' has been imprisoned!',player.name2,'');

            {mail to imprisoned subject}
            post(MailSend,
            pl0.name2,
            pl0.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+'Arrested!'+config.textcol1,
            mkstring(9,underscore),
            s+ukingc+' '+player.name2+config.textcol1+' had you imprisoned!',
            s4,
            'You were sentenced to '+uwhite+commastr(days)+config.textcol1+' '+daystr+' in prison.',
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

            {update king record}
            dec(king.prisonsleft);
            load_king(fsave,king);

            {prison location}
            pl0.location:=offloc_prison;
            pl0.DaysinPrison:=days;

            {save subject}
            user_save(pl0);

            {remove shadow}
            add_shadow(SRemove,pl0,'','',0);
           end;
          end;


         end
         else begin
          crlf;
          sd(global_plycol,cap);
          d(config.textcolor,' looks at you, and then marches off for his inspection rounds.');
         end;
        end;

       end; {imprison subject .end.}
   'P':begin {list of prisoners}

        crlf;
        crlf;
        d(5,'Prisoners');
        d(5,'^^^^^^^^^');

        counter:=0;
        counter2:=2;
        abort:=false;
        for i:=1 to 2 do begin

         case i of
          1: size:=fs(FsPlayer);
          2: size:=fs(FsNpc);
         end; {case .end.}

         for j:=1 to size do begin

          load_character(pl0,i,j);

          if (pl0.name2<>player.name2) and
             (pl0.location=offloc_prison) and
             (pl0.deleted=false) and
             (pl0.name1<>global_delname1) and
             (pl0.name2<>global_delname2) then begin

           inc(counter);
           sd(global_plycol,pl0.name2);
           sd(config.textcolor,' the '+race_display(2,pl0.race,0));
           if is_online(pl0.name2,online_player) then begin
            sd(14,' (awake).');
           end
           else if pl0.hps<1 then begin
            sd(config.textcolor,' ('+ulred+'dead'+config.textcol1+').');
           end
           else begin
            sd(config.textcolor,' (sleeping).');
           end;

           {days left in prison}
           x:=pl0.daysinprison;
           if x=0 then x:=1;
           if x=1 then daystr:='day'
                  else daystr:='days';

           d(config.textcolor,' ('+uwhite+commastr(x)+config.textcol1+' '+daystr+' left)');

           {pause listing?}
           inc(counter2);
           if counter2>global_screenlines-2 then begin
            counter2:=0;
            if confirm('Continue search','Y')=false then begin
             abort:=true;
            end;
           end;

          end;
          if abort then break;
         end; {for j:= .end.}
         if abort then break;
        end; {for i:= .end.}

        if counter=0 then begin
         d(6,'The Cells are empty! (how boring!)');
        end
        else begin
         crlf;
         sd(config.textcolor,'There is a total of ');
         sd(15,commastr(counter));
         d(config.textcolor,' prisoners.');
        end;

       end;

  end; {case .end.}

 until leave_prison=true;

 cho:=' ';

end; {Royal_Prison *end*}

end. {Unit PrisonC1 .end.}
