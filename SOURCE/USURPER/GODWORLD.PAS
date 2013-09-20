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



unit GodWorld; {Usurper - Where the Gods enter and dwell}

interface

{Uses Init}

procedure God_World;

implementation

uses
  DDplus, Init, Cms,
  InitGods, Jakob, Various,
  Various2, Various3, VarGods,
  StatusC, Relation, Mail,
  Post_To, Sortpl, Online,
  Children, News, GenNews,
  File_Io;

var
  refresh: boolean;

procedure Prison_Intervention;
var
  ch:     char;
  done:   boolean;

  mortal: userrec;

  king:   kingrec;

begin

  crlf;
  done := False;
  ch := '?';
  repeat

    if ch = '?' then
    begin
      crlf;
      crlf;
      d(11, 'You prepare to make use of your powers on the prisoners...');
      menu('(V)iew prisoners');
      menu('(H)elp prisoner to escape');
      menu('(R)eturn');
    end;

    crlf;
    sd(config.textcolor, 'Help Prisoners (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      'R': begin {return}
        crlf;
        crlf;
        done := True;
      end;
      'V': begin {view prisoners}
        crlf;
        crlf;
        d(config.textcolor, 'You examine the Royal Prison.');
        crlf;

        list_of_prisoners;

      end; {view prisoners *end*}

      'H': begin {help prisoner escape}

        if god.deedsleft > 0 then
        begin
          crlf;
          d(config.textcolor, 'Who should be set free?');
          if Select_Character(mortal, False) = True then
          begin
            if mortal.location = offloc_prison then
            begin

              if is_online(mortal.name2, online_player) then
              begin
                {rescue online prisoner}
                d(12, mortal.name2 + ' is busy.');
                pause;
              end else
              begin

                {rescue offline prisoner}

                {add shadow}
                if add_shadow(SAdd, mortal, god.Name, 'escaping from prison', 0) = False then
                begin
                  d(global_plycol, mortal.name2 + config.textcol1 + ' is busy! Try again later.');
                  pause;
                end else
                begin

                  {release}
                  mortal.location := offloc_dormitory;

                  crlf;
                  d(config.textcolor, 'By pure will-force you make the prison door open!');
                  d(global_plycol, mortal.name2 + config.textcol1 + ' escapes with your assistance!');
                  d(config.textcolor, 'The Royals will not be pleased when they discover this.');
                  d(config.textcolor, 'Your energy decreases by ' + ulcyan + '1');

                  {news}
                  newsy(True,
                    config.textcol1 + 'Prison Escape!',
                    ' ' + uplc + mortal.name2 + config.textcol1 + ' escaped from Prison!',
                    ' The mighty God ' + ugodc + god.Name + config.textcol1 + ' is suspected to be behind this.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {improve mortal:s attitude to god}
             {Update_Relation(Relation_Better,1,mortal,god,false,false);

             {tell other nodes}
                  online_send_to_all(uplc + mortal.name2 + config.textcol1 + ' escaped from Prison!', player.name2, '');

                  {load the king}
                  load_king(fload, king);

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Prisoner Escape' + config.textcol1,
                      mkstring(15, underscore),
                      uplc + mortal.name2 + config.textcol1 + ' escaped from Prison.',
                      ugodc + god.Name + config.textcol1 + ', the Immortal, made this happen.',
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


                  {mail imprisoned subject}
                  post(MailSend,
                    mortal.name2,
                    mortal.ai,
                    False,
                    mailrequest_nothing,
                    '',
                    umailheadc + 'Prison Escape!' + config.textcol1,
                    mkstring(14, underscore),
                    'The Immortal ' + ugodc + god.Name + config.textcol1 + ' helped you escape from Prison!',
                    'You should be grateful that your fate is of interest to the higher powers.',
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
                  user_save(mortal);

                  {remove shadow}
                  add_shadow(SRemove, mortal, '', '', 0);

                  {decrease deeds left}
                  if global_utest = False then
                  begin
                    Dec(god.deedsleft);
                  end;

                  {experience}
                  incgodexp(god, 10);
                  d(15, 'Your powers increase!');

                end;

              end;

            end else
            begin

              d(global_plycol, mortal.name2 + ulred + ' is not a prisoner!');
              pause;

            end;
          end;
        end else
        begin
          d(12, 'You are too tired! Come back tomorrow.');
        end;

      end; {help prisoner escape *end*}

    end; {case .end.}

  until done = True;

end; {prison_intervention .end.}

procedure Mortal_Intervention;
var
  ch:       char;
  done, go_ahead: boolean;

  x:        byte;
  s:        s90;

  ss1, ss2, ss3: s100;

  mortal:   userrec;

  god0:     godrec;

  pl0, pl1: ^UserRec;

  switch_sides: boolean;

begin

  {init}
  new(pl0);
  new(pl1);

  crlf;
  done := False;
  ch := '?';
  repeat

    if ch = '?' then
    begin
      crlf;
      crlf;
      d(11, 'You prepare to make use of your powers on the mortals.');
      crlf;
      menu('(G)et a believer');
      menu('(P)oison relation');
      menu('(H)and outs');
      menu('(I)nstill doubt');
      menu('(R)eturn');

    end;

    crlf;
    sd(config.textcolor, 'Influence Mortals (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');

    {get user-input}
    ch := upcase(getchar);

    if (ch = 'G') and (god.deedsleft < 1) then
    begin
      crlf;
      crlf;
      d(12, 'You are exhausted. return tomorrow.');
      pause;
      crlf;
      ch := '?';
    end;


    {evaluate user-input}
    case ch of
      'R': begin {return}
        crlf;
        crlf;
        done := True;
      end;
      'P': begin {punish mortal}

        if god.deedsleft < 1 then
        begin
          d(12, 'You are too tired! Come back tomorrow.');
        end else
        begin

          crlf;
          crlf;
          d(config.textcolor, 'hehe...');
          d(9, '-*Dirty Trick*-');
          d(config.textcolor, 'Name the two persons who''s relation you would like to ruin');

          d(11, 'first person you want to harm');
          if select_character(pl0^, False) = True then
          begin
            crlf;
            d(11, 'second person you want to harm');
            if select_character(pl1^, False) = True then
            begin
              if (pl0^.name2 = pl1^.name2) and (pl0^.id = pl1^.id) then
              begin
                d(12, 'And I thought Immortals were smart...');
              end else
              begin

                crlf;

                if confirm('Setup ' + uplc + pl0^.name2 + config.textcol1 + ' against ' + uplc + pl1^.name2 + config.textcol1, 'Y') = True then
                begin

                  {deeds left}
                  Dec(god.deedsleft);

                  d(config.textcolor, 'You focus your powers on poisoning the souls of the victims.');
                  make_delay_dots(config.textcolor, 4, 600);
                  crlf;

                  x := random(3);
                  {x:=0; {cheat! dev...test stuff}

                  if x = 0 then
                  begin

                    {*Poison Relation Succeeded*}
                    s := uplc + pl0^.name2 + config.textcol1 + ' and ' + uplc + pl1^.name2 + config.textcol1;
                    d(15, 'SUCCESS!');
                    case random(3) of
                      0: d(15, 'A note of discord crept into the relationship between ' + s + '!');
                      1: d(15, s + ' distrust each other!');
                      2: d(15, s + ' relationship is deteriorating!');
                    end; {case .end.}
                    crlf;

                    {immortal experience}
                    incgodexp(god, 20);
                    d(15, 'Your powers increase!');


                    {worsen pl0:s attitude to pl1}
                    Update_Relation(Relation_Worsen, 2, pl0^, pl1^, False, False);

                    {worsen pl1:s attitude to pl0}
                    Update_Relation(Relation_Worsen, 2, pl1^, pl0^, False, False);

                    {informing pl0}
                    post(MailSend,
                      pl0^.name2,
                      pl0^.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Bad Feeling' + config.textcol1,
                      mkstring(11, underscore),
                      uplc + pl1^.name2 + config.textcol1 + ' is trying to set you up!',
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

                    {informing pl1}
                    post(MailSend,
                      pl1^.name2,
                      pl1^.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Bad Feeling' + config.textcol1,
                      mkstring(11, underscore),
                      uplc + pl0^.name2 + config.textcol1 + ' is trying to hurt you and your family!',
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
                    newsy(True,
                      'Disagreement',
                      ' ' + uplc + pl0^.name2 + config.textcol1 + ' and ' + uplc + pl1^.name2 + config.textcol1 + ' had an argument.',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');

                  end else
                  begin

                    {*Poison Relation Attempt Failed*}
                    d(12, 'Dang! It failed! They saw through your plot!');
                    d(global_plycol, pl0^.name2 + config.textcol1 + ' is angry!');
                    d(global_plycol, pl1^.name2 + config.textcol1 + ' is upset!');
                    crlf;

                    {news}
             {newsy(true,
             config.textcol1+'Divine Intervention Failed!',
             ' The immortal '+ugodc+god.name+config.textcol1+' failed in an attempt to poison the relation',
             ' between '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1+'!',
             '',
             '',
             '',
             '',
             '',
             '',
               '');
              }

                    {if pl0 is a NPC and follower then drop faith}
                    if (pl0^.ai = 'C') and (pl0^.god = god.Name) then
                    begin

                      if add_shadow(SAdd, pl0^, god.Name, 'dreaming', 0) = True then
                      begin

                        {drop faith in Immortal}
                        d(12, uplc + pl0^.name2 + ulred + ' lost ' + sex3[pl0^.sex] + ' faith in you!');
                        pl0^.god := '';

                        {save pl0}
                        user_save(pl0^);

                        {remove shadow player PL0}
                        add_shadow(SRemove, pl0^, '', '', 0);

                        Dec(god.believers);

                      end;

                    end;

                    {if npc drop pl1 as the Immortals follower}
                    if (pl1^.ai = 'C') and (pl1^.god = god.Name) then
                    begin

                      if add_shadow(SAdd, pl1^, god.Name, 'dreaming', 0) = True then
                      begin

                        {drop faith in Immortal}
                        d(12, uplc + pl1^.name2 + ulred + ' lost ' + sex3[pl1^.sex] + ' faith in you!');
                        pl1^.god := '';

                        {save pl1}
                        user_save(pl1^);

                        {remove shadow player PL1}
                        add_shadow(SRemove, pl1^, '', '', 0);

                        Dec(god.believers);

                      end;

                    end;


                    {informing pl0, if online}
                    if is_online(pl0^.name2, online_player) = True then
                    begin
                      online_send_to_player(pl0^.name2, online_player, ugodc + god.Name + config.textcol1 + ' tried to poison your' + ' relation with ' + uplc + pl1^.name2 + config.textcol1 + '!');
                    end;

                    if pl0^.ai = 'H' then
                    begin
                      {informing pl0}
                      post(MailSend,
                        pl0^.name2,
                        pl0^.ai,
                        False,
                        mailrequest_nothing,
                        '',
                        ulred + 'Failed Attempt!' + config.textcol1,
                        mkstring(15, underscore),
                        ugodc + god.Name + config.textcol1 + ' tried to poison your relation with ' + uplc + pl1^.name2 + config.textcol1 + '!',
                        'But the weak immortal failed miserably.',
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

                    if pl1^.ai = 'H' then
                    begin
                      {informing pl1, if online}
                      if is_online(pl1^.name2, online_player) = True then
                      begin
                        online_send_to_player(pl1^.name2, online_player, ugodc + god.Name + config.textcol1 + ' tried to poison your' + ' relation with ' + uplc + pl0^.name2 + config.textcol1 + '!');
                      end;


                      {informing pl1}
                      post(MailSend,
                        pl1^.name2,
                        pl1^.ai,
                        False,
                        mailrequest_nothing,
                        '',
                        ulred + 'Failed Attempt!' + config.textcol1,
                        mkstring(15, underscore),
                        ugodc + god.Name + config.textcol1 + ' tried to poison your relation with ' + uplc + pl0^.name2 + config.textcol1 + '!',
                        'But the weak immortal failed miserably.',
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

                    {news-paper}
                    newsy(True,
                      'Troublemaker Exposed',
                      config.textcol1 + ' The immortal ' + ugodc + god.Name + config.textcol1 + ' was exposed trying to poison the relation',
                      ' between ' + uplc + pl0^.name2 + config.textcol1 + ' and ' + uplc + pl1^.name2 + config.textcol1 + '.',
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

      'G': begin {recruite}

        {threat or promise}
        {recruit a believer to a rivaling immo. consequences?}

        crlf;
        crlf;
        d(config.textcolor, 'Who would you like to recruit?');

        if Select_Character(mortal, False) = True then
        begin

          if mortal.god = god.Name then
          begin
            d(15, uplc + mortal.name2 + uwhite + ' already believes in you!');
            go_ahead := False;
          end else
          begin

            crlf;
            d(15, 'You concentrate your powers on ' + uplc + mortal.name2);
            pause;

            go_ahead := True;

            if (mortal.god <> '') and (Verify_Gods_Existance(mortal.god) = True) then
            begin
              go_ahead := False;


              if confirm(uplc + mortal.name2 + config.textcol1 + ' is already a believer in ' + ugodc + mortal.god + config.textcol1 + '! Continue', 'N') = True then
              begin
                d(config.textcolor, 'You are not afraid of ' + ugodc + mortal.god + config.textcol1 + '!');
                go_ahead := True;
              end else
              begin
                d(12, 'You dare not disturb the mighty ' + ugodc + mortal.god + ulred + '!');
                pause;
              end;

            end;

            {add mortal online}
            if go_ahead then
            begin
              if add_shadow(SAdd, mortal, god.Name, 'interacting with ' + ugodc + god.Name, 0) = False then
              begin
                d(global_plycol, mortal.name2 + config.textcol1 + ' is busy! Try again later.');
                go_ahead := False;
              end;

            end;



            if go_ahead then
            begin

              repeat
                crlf;
                crlf;
                d(14, 'How will you persuade ' + uplc + mortal.name2);
                menu('(T)hreat');
                menu('(G)ift ' + uwhite + '*not implemented*');
                menu('(J)ust ask');
                menu('(A)bort');
                crlf;
                sd(config.textcolor, 'Recruit Method (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');


                ch := upcase(getchar);
              until ch in ['T', 'J', 'A'];


              {hey i use N}
              if ch = 'J' then ch := 'N';

              case ch of

                'A': begin {abort}
                  crlf;
                  crlf;
                  d(13, 'You have better things to do.');
                end;
                'T', 'N': begin {threat & normal}
                  crlf;

                  if ch = 'T' then
                  begin
                    d(12, 'You send word to ' + uplc + mortal.name2 + ulred + ' that ' + sex3[mortal.sex] + ' situation will become unpleasant unless');
                    d(12, sex2[mortal.sex] + ' join your ranks.');
                  end else
                  begin
                    d(config.textcolor, 'You let ' + uplc + mortal.name2 + config.textcol1 + ' know that you wish ' + sex[mortal.sex] + ' to become a follower.');
                  end;

                  crlf;

                  {decrese deeds left}
                  if not global_utest then
                  begin
                    Dec(god.deedsleft);
                  end;

                  pause;

                  {is Mortal computer controlled?}
                  if mortal.ai = 'C' then
                  begin

                    {how should computer player react to this threat / normal offer?}

                    {if he already is a believer then compare God Powers}
                    if mortal.god <> '' then
                    begin

                      {load mortals current god}
                      if load_god_by_name(mortal.god, god0) = True then
                      begin

                        if god.believers > god0.believers then
                        begin
                          d(14, 'Success!');
                          d(global_plycol, mortal.name2 + config.textcol1 + ' has decided to follow you!');
                          d(14, 'Your powers grow!');
                          d(14, 'News of your actions spreads through the mortal and immortal world...');

                          switch_sides := True;
                        end else
                        begin
                          d(12, 'Failure!');

                          if ch = 'T' then
                          begin
                            d(global_plycol, mortal.name2 + config.textcol1 + ' listens to no threat!');
                          end else
                          begin
                            d(global_plycol, mortal.name2 + config.textcol1 + ' rejects your offer!');
                          end;

                          d(12, 'News of your actions spreads through the mortal and immortal world...');

                          switch_sides := False;
                        end;

                        crlf;
                        if switch_sides then
                        begin

                          {update mortal with new god}
                          mortal.god := god.Name;
                          user_save(mortal);

                          {update immortal with new stats}
                          {experience, change this and you must change in mail.pas as well}
                          incgodexp(god, 150);

                          Inc(god.believers);
                          load_god(fsave, god, god.recnr);

                          {inform other god of what happened}
                          if ch = 'T' then
                          begin
                            s := 'Treachery';

                            ss1 := 'One of your followers; ' + uplc + mortal.name2 + config.textcol1 + ' was threatened by ' + ugodc + god.Name + config.textcol1 + '!';
                            ss2 := uplc + mortal.name2 + config.textcol1 + ' has left your flock for the vicious ' + ugodc + god.Name + config.textcol1 + '!';
                            ss3 := '';
                          end else
                          begin
                            s := 'Convert';

                            ss1 := 'One of your followers; ' + uplc + mortal.name2 + config.textcol1 + ' has lost faith in you!';
                            ss2 := uplc + mortal.name2 + config.textcol1 + ' has left your flock for the insidious ' + ugodc + god.Name + config.textcol1 + '!';
                            ss3 := ugodc + god.Name + ' persuaded ' + uplc + mortal.name2 + config.textcol1 + ' to desert you!';
                          end;



                          post(MailSend,
                            god0.Name,
                            god0.ai,
                            True,
                            mailrequest_nothing,
                            '',
                            ulred + s + config.textcol1,
                            mkstring(length(s), underscore),
                            ss1,
                            ss2,
                            ss3,
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
                          Newsy(True,
                            'Lost Faith',
                            ' ' + uplc + mortal.name2 + config.textcol1 + ' lost faith in ' + ugodc + god0.Name + config.textcol1 + '!',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');


                          if ch = 'T' then
                          begin
                            {news-paper}
                            Newsy(True,
                              'Trickery in Heaven',
                              ' ' + uplc + mortal.name2 + config.textcol1 + ' found faith in ' + ugodc + god.Name + config.textcol1 + '!',
                              ' Evil tounges claim that ' + uplc + mortal.name2 + config.textcol1 + ' was forced into ' + ugodc + god.Name + 's' + config.textcol1 + ' flock.',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');
                          end else
                          begin
                            {news-paper}
                            Newsy(True,
                              'Fight For Souls',
                              ' ' + uplc + mortal.name2 + config.textcol1 + ' found faith in ' + ugodc + god.Name + config.textcol1 + '!',
                              ' Evil tounges claim that ' + ugodc + god0.Name + config.textcol1 + ' played an active part in this.',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');
                          end;

                        end else
                        begin

                          if ch = 'T' then
                          begin
                            {inform other god of attempt}
                            s := 'Evil Attempt';
                            post(MailSend,
                              god0.Name,
                              god0.ai,
                              True,
                              mailrequest_nothing,
                              '',
                              ulred + s + config.textcol1,
                              mkstring(length(s), underscore),
                              uplc + mortal.name2 + config.textcol1 + ' was threatened by ' + ugodc + god.Name + config.textcol1 + '!',
                              uplc + mortal.name2 + config.textcol1 + ' decided to stay with you!',
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
                            Newsy(True,
                              'Divine Intervention Failed',
                              ' The no-good immortal ' + ugodc + god.Name + config.textcol1 + ' tried to force ' + uplc + mortal.name2 + config.textcol1 + ' to',
                              '  give up ' + sex3[mortal.sex] + ' faith in ' + ugodc + god0.Name + config.textcol1 + '!',
                              ' The attempt failed!',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                          end else
                          begin
                            {inform other god of attempt}
                            s := 'Attempt to Steal one of Your followers';
                            post(MailSend,
                              god0.Name,
                              god0.ai,
                              True,
                              mailrequest_nothing,
                              '',
                              ulred + s + config.textcol1,
                              mkstring(length(s), underscore),
                              uplc + mortal.name2 + config.textcol1 + ' was approached by ' + ugodc + god.Name + config.textcol1 + '!',
                              uplc + mortal.name2 + config.textcol1 + ' decided to continue to have faith in you!',
                              config.textcol1 + 'The pathetic attempt to steal one of your followers failed!',
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
                            Newsy(True,
                              'Fight over Power in Heaven',
                              ' The insidious demi-god ' + ugodc + god.Name + config.textcol1 + ' tried to sway ' + uplc + mortal.name2 + config.textcol1 + ' to',
                              ' ' + sex3[god.sex] + ' flock!',
                              ' The attempt failed!',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                          end;

                        end;

                      end else
                      begin
                        {perhaps implement something better here}
                        d(12, '*unable to load immortal: ' + mortal.god + '*');
                        pause;
                        crlf;
                      end;

                    end else
                    begin

                      {computer is a pagan. random choice}
                      if random(3) = 0 then
                      begin

                        {success}
                        d(14, 'Success!');
                        d(14, 'Congratulations!');
                        d(global_plycol, mortal.name2 + config.textcol1 + ' has joined your flock.');
                        d(15, 'Your powers grow!');

                        {experience, change this and you must change in mail.pas as well}
                        incgodexp(god, 150);

                        {inc counter}
                        Inc(god.believers);

                        {save god}
                        load_god(fsave, god, god.recnr);


                        {set mortal flags}
                        mortal.god := god.Name;
                        user_save(mortal);

                        {news-paper}
                        if ch = 'T' then
                        begin
                          Newsy(True,
                            'Salvation',
                            ' ' + uplc + mortal.name2 + config.textcol1 + ' found faith in ' + ugodc + god.Name + config.textcol1 + '!',
                            ' Evil tongues claim that ' + uplc + mortal.name2 + config.textcol1 + ' was forced into ' + ugodc + god.Name + 's' + config.textcol1 + ' flock.',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');
                        end else
                        begin
                          Newsy(True,
                            'Salvation',
                            ' ' + uplc + mortal.name2 + config.textcol1 + ' found faith in ' + ugodc + god.Name + config.textcol1 + '!',
                            ' Evil tongues claim that ' + ugodc + god.Name + config.textcol1 + ' played an active part in this!',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');
                        end;

                        crlf;

                      end else
                      begin

                        if ch = 'T' then
                        begin
                          {failure}
                          crlf;
                          d(12, 'FAILURE!');
                          d(global_plycol, mortal.name2 + config.textcol1h + ' is not afraid of YOUR powers!');
                          d(config.textcolor, 'Your intimidation tactics don''t seem to work...');
                          d(12, 'News of your actions spreads through the mortal and immortal world...');


                          {news-paper}
                          newsy(True, +config.textcol1 + 'Pathetic Recruitment Attempt',
                            config.textcol1 + ' The immortal ' + ugodc + god.Name + config.textcol1 + ' attempted scare tactics to make ',
                            ' ' + uplc + mortal.name2 + config.textcol1 + ' join ' + sex3[god.sex] + ' ranks.',
                            ' The attempt failed miserably.',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');
                        end else
                        begin
                          {failure}
                          crlf;
                          d(12, 'FAILURE!');
                          d(global_plycol, mortal.name2 + config.textcol1h + ' has no interest in joining your flock!');
                          d(12, 'News of your actions spreads through the mortal and immortal world...');


                          {news-paper}
                          newsy(True, +config.textcol1 + 'Pathetic Recruitment Attempt',
                            config.textcol1 + ' The immortal ' + ugodc + god.Name + config.textcol1 + ' attempted to recruit ',
                            ' ' + uplc + mortal.name2 + config.textcol1 + '.',
                            ' The attempt failed miserably.',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');
                        end;

                        pause;
                        crlf;

                      end;

                    end;

                  end
                  else
                  begin

                    {mail 'H'uman mortal receiver}
                    if ch = 'T' then
                    begin
                      s := '*threat*';
                    end else
                    begin
                      s := '*normal*';
                    end;

                    post(MailSend,
                      mortal.name2,
                      mortal.ai,
                      False,
                      mailrequest_ImmortalOffer,
                      god.Name,
                      s,
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

                    d(15, 'Done!');
                    d(config.textcolor, 'You will be informed of ' + uplc + mortal.name2 + config.textcol1 + ' decision later.');
                    pause;

                  end;
                end; {threat & normal .end.}

              end; {case .end.}

              {remove shadow}
              add_shadow(SRemove, mortal, '', '', 0);

            end; {go_ahead .end.}

          end;

        end;

      end; {recruite *end*}

    end; {case .end.}

  until done;

  {dispose pointer vars}
  dispose(pl0);
  dispose(pl1);

end; {mortal_intervention .end.}

procedure Child_Intervention;
var
  ch:    char;
  done:  boolean;
  child: childrec;

begin

  crlf;
  done := False;
  ch := '?';
  repeat

    if ch = '?' then
    begin
      crlf;
      crlf;
      d(11, 'You prepare to make use of your powers...');
      menu('(V)iew commitments');
      menu('(C)urse children');
      menu('(P)rotect children');
      menu('(R)eturn');
    end;

    crlf;
    sd(config.textcolor, 'Child Intervention (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      'R': begin {return}
        crlf;
        crlf;
        done := True;
      end;
      'C': begin {curse children}
        crlf;
        crlf;
        d(12, 'Oh great Evil One, who is the mortal insect you wish to harm?');

        if select_a_child(player, child, anychild, excludenone, False) then
        begin

          if confirm('Harm ' + ukidc + child.Name + config.textcol1, 'N') = True then
          begin

            if add_child(SAddChild, child, god.Name, '*under influence*', 0) = False then
            begin
              d(12, child.Name + ' is unreachable right now. try again later!');
            end else
            begin

              {now, what should we do to the little rascal}
              d(15, '*nothing happened*');

              {remove shadow kid}
              add_child(SRemoveChild, child, '', '', 0);

            end;
          end;
        end;
      end; {curse children end}

    end; {case .end.}

  until done = True;

end; {child_intervention .end.}

procedure Meny;
const offset = 18;
begin

  {text}
  clearscreen;
  crlf;
  d(5, '-**- The Divine Heaven -**-');
  crlf;
  d(config.textcolorH, 'You are standing on the slope of Trazz...');
  d(config.textcolorH, 'Floating around you are the billion stars of the sky.');
  crlf;

  menu2(ljust('(I)mmortals', offset));
  menu2(ljust('(D)ivine intervention', offset + 7));
  menu('(V)isit ' + global_supreme_creator);

  menu2(ljust('(B)elievers', offset));
  menu2(ljust('(L)ist Mortals', offset + 7));
  menu('(*) suicide');
  {menu('(C)hange your divine appearance');}

  menu2(ljust('(M)essage', offset));
  menu2(ljust('(E)xamine mortal', offset + 7));
  menu('(1) Immortal News');

  menu2(ljust('(S)tatus', offset));
  menu2(ljust('(C)omment to the Mortals', offset + 7));
  menu('(N)ews');

  menu2(ljust('(Q)uit', offset));
  menu('(F)lock inspection');

end; {meny *end*}


procedure Display_Menu(force, short: boolean);
begin

  if short then
  begin
    if (refresh) and (player.auto_meny) then
    begin
      refresh := False;
      meny;
    end;

    crlf;
    sd(config.textcolorH, 'Heaven (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure God_World; {where the gods begin}
var
  i, j, size: word;

  x:          longint;

  ch:         char;

  s:          s90;

  god0:       godrec;

  firsttime, endgodworld, abort, done, found: boolean;

  player0:    UserRec;

begin

  {Setup fake player record}
  player.name1 := god.realname;
  player.name2 := god.Name;

  player.ai := 'H';
  player.ear := global_ear_all;
  player.maxhps := 32000;
  player.hps := player.maxhps;
  player.auto_meny := True;
  player.expert := False;

  {used by ddplus doordriver}
  global_godactive := True;

  {update status bar with player alias}
  {this is also used in gamec.pas}
  display_bar_status(True);

  {Setup Online Record}
  if local then onliner.node := global_onlocal
  else onliner.node := global_cnode;

  onliner.Name := player.name2;
  onliner.realname := player.name1;
  onliner.location := onloc_entering;
  onliner.doing := location_desc(onliner.location);
  onliner.arrived := give_me_time;
  onliner.usertype := online_god;
  onliner.shadow := False;
  onliner.dead := False;
  onliner.race := human;
  onliner.class := warrior;
  for i := 1 to global_maxnod do
  begin
    onliner.chatline[i] := emptystr;
    onliner.chatsend[i] := emptystr;
    onliner.info[i] := emptystr;
    onliner.infosend[i] := emptystr;
  end; {for i:= .end.}
  onliner.recnr := 0;
  onliner.ear := global_ear_all;
  onliner.bname := emptystr;
  onliner.com := ' ';
  onliner.comfile := emptystr;

  {Add User to the Online user-file}
  if add_onliner(OAdd, onliner) = False then
  begin
    d(12, 'Your character has been activated by another node.');
    d(12, 'You must wait a while before you may enter.');
    crlf;

    player.name2 := '';
    player.name1 := '';

    pause;
    normal_exit;
  end;

  {Send a BroadCast to other nodes about the player-god entry}
  online_send_to_all(broadcast_GodEnteredGame, onliner.Name, '');

  {allow multi node procs to be executed}
  global_multi := True;

  {enter god-world}
  crlf;
  case random(3) of
    0: d(12, 'Since your last visit ...');
    1: d(12, 'Flow of time ...');
    2: d(12, 'Verifying events ...');
  end; {case .end.}

  {read mail}
  post(MailRead,
    player.name2,
    player.ai,
    False,
    mailrequest_nothing,
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
    '',
    '',
    '');

  pause;

  {Let us BEGIN}
  clearscreen;
  crlf;
  d(config.textcolorH, 'Preparing your divine entry...');
  crlf;
  sd(config.textcolorH, 'Welcome oh great ' + ugodc + god.Name + config.textcol1h + '...');

  {check how many disciples the immortal has}
  x := how_many_believers(god);

  if x > god.believers then
  begin
    s := 'You have gained believers since your last visit!';
    crlf;
    crlf;
    d(14, mkstring(length(s), '*'));
    d(14, s);
    d(14, mkstring(length(s), '*'));
    pause;
  end else if x < god.believers then
  begin
    s := 'You have lost believers since your last visit!';
    crlf;
    crlf;
    d(12, mkstring(length(s), '*'));
    d(12, s);
    d(12, mkstring(length(s), '*'));

    pause;
  end else
  begin
    if x = 0 then
    begin
      s := 'You have no believers! Seek among the mortals to expand your flock.';
      crlf;
      crlf;
      d(12, mkstring(length(s), '*'));
      d(12, s);
      d(12, mkstring(length(s), '*'));
      pause;
    end else if x < 4 then
    begin
      s := 'You should recruit new disciples! Seek among the mortals to expand your flock.';
      crlf;
      crlf;
      d(12, mkstring(length(s), '*'));
      d(12, s);
      d(12, mkstring(length(s), '*'));
      pause;
    end else
    begin
      s := 'Your flock remains with you.';
      crlf;
      crlf;
      d(12, mkstring(length(s), '*'));
      d(12, s);
      d(12, mkstring(length(s), '*'));
      pause;
    end;

  end;

  god.believers := x;

 {case random(3) of
  0: god.doing:='playing with dolls';
  1: god.doing:='mastering the puppets';
  2: god.doing:='juggling with fate';
 end;}

  {save updated god account}
  load_god(fsave, god, god.recnr);

  endgodworld := False;

  {BIG LOOP *START*}
  repeat

    if onliner.location <> onloc_heaven then
    begin
      refresh := True;
      onliner.location := onloc_heaven;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      '?': begin {menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        god_status(god);
      end;
      'M': begin {send a message}
        send_a_letter(False);
      end;
      '1': begin {immortal news}
        d(11, 'Immortal News');
        crlf;
        if global_ansi then display_file(global_GodsANSI)
        else display_file(global_GodsASCI);
        crlf;
        pause;
      end;
      'F': begin {examine another immmortals flock (followers) }
        crlf;
        crlf;
        d(15, 'Who is the immortal you wish to inspect?');

        if select_a_god(god0, god.Name, False) = True then
        begin

          x := God_Believers(god0.Name, True);

        end;

      end;
      'C': begin {communicate to the mortal world, broad}
        crlf;
        crlf;
        if confirm('Make a statement to the Mortal World', 'n') = True then
        begin
          crlf;

          crlf;
          d(10, 'Enter your message');
          d(config.textcolor, 'I' + mkstring(70, underscore) + 'I');
          sd(config.textcolor, ':');
          s := get_string(70);

          if s <> '' then
          begin

            crlf;
            if confirm('Send this to the Mortal World', 'Y') = True then
            begin
              crlf;

              {news-paper}
              newsy(True,
                'Divine Remark',
                ' ' + ugodc + god.Name + config.textcol1 + ' made a statement to the Mortal World:',
                ' ' + utalkc + s,
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              d(11, 'Done! Hopefully the puny earthlings will understand your message.');
              crlf;

            end else
            begin
              d(12, 'They don''t deserve your words of wisdom!');
            end;
          end;

        end else
        begin
          crlf;
          d(10, 'You decide that the earthly creatures are not worthy of your wisdom.');
        end;

      end;
      'V': begin {visit the supreme creator}
        the_great_creators_place;
      end;
      'B': begin {believers, list of}

        crlf;
        crlf;
        sd(2, 'Concentrating....');

        {reset counter}
        god.believers := 0;
        firsttime := True;

        {searching among the players/npcs}
        for i := 1 to 2 do
        begin

          case i of
            1: size := fs(FsPlayer);
            2: size := fs(FsNpc);
          end; {case .end.}

          for j := 1 to fs(fsplayer) do
          begin

            if load_character(player, i, j) = True then
            begin

              if (player_active(player, False) = True) and
                (player.god = god.Name) then
              begin

                if firsttime then
                begin
                  firsttime := False;
                  crlf;
                  d(14, 'Your flock consists of the following creatures :');
                  crlf;
                end;

                {believers name}
                sd(global_plycol, player.name2);

                {believers race}
                sd(config.textcolor, ', the ');
                sd(config.textcolor, race_display(2, player.race, 0) + '.');

                crlf;

                {inc counter}
                Inc(god.believers);

              end;
            end;
          end; {for j:= .end.}
        end; {for i:= .end.}

        if god.believers = 0 then
        begin
          crlf;
          d(12, 'You have no followers. Your shadow on earth is diminishing...');
        end;

        crlf;
        pause;

      end;

      '*': begin {suicide}

        clearscreen;
        crlf;
        d(12, ' *** Suicide, the Easy way out ***');
        crlf;
        if confirm('ARE YOU SURE you want to kill yourself', 'n') = False then
        begin
          crlf;
          d(10, 'PHEW! That was close!');

          {put this "close encounter with death" experience in the news}
          {news-paper}
          newsy(True,
            config.textcol1 + 'Near Death in Heaven',
            ' ' + ugodc + god.Name + config.textcol1 + ' considered suicide, but decided not to do it!',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

        end else
        begin

          {bye text}
          d(12, 'You place yourself in ' + ugodc + global_supreme_creator + 's' + ulred + ' Fire Wagon.');
          d(12, 'Your spirit dissolves into the eternal rest...');

          {send info to all players}
          online_send_to_all(ugodc + god.Name + ugreen + ' HAS COMMITTED SUICIDE!', god.Name, '');

          {news-paper}
          newsy(True,
            config.textcol1 + 'Tragic in Heaven',
            ' ' + ugodc + god.Name + ulred + ' committed suicide!' + config.textcol1H,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

          {put the news in the Holy log-file}
          Generic_News(HolyNews,
            True,
            ' ' + ugodc + god.Name + ulred + ' committed suicide!' + config.textcol1H,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

          {inform & deactivate disciples}
          Inform_Disciples(god, 'God Dead!',
            ugodc + god.Name + ulred + ' committed Suicide!',
            '',
            '',
            '');

          {deactivate character}
          if global_utest = False then
          begin
            god.deleted := True;
            god.id := '';
            god.Name := global_delname2;
            god.realname := global_delname1;
            god.believers := 0;
          end else
          begin
            d(15, 'This is a TEST Version of Usurper.');
            d(15, 'This God has not deleted!');
            d(15, 'You have to delete him manually via the Editor.exe program.');
            pause;
          end;

          pause;

          {bye}
          normal_exit;

        end;

      end;

      'L': begin {list of mortals (players)}

        crlf;
        sd(15, 'Sorting..');

        {sort & display player list}
        sort_players(False);

      end;
      'I': begin {list of immortals}

        crlf;
        list_gods(True);

      end;
      'Q': begin {quit}

        crlf;
        crlf;
        if confirm('QUIT to the real world', 'N') = True then
        begin
          crlf;
          crlf;
          EndGodWorld := True;

        end;
      end;
      'N': begin {read news-paper}

        {update player location & doing}
        onliner.location := onloc_readingnews;
        onliner.doing := location_desc(onliner.location);
        add_onliner(OUpdateLocation, onliner);

        {read paper}
        read_news_paper;

      end;
      'E': begin {examine mortal}
        crlf;
        crlf;
        d(config.textcolor, 'So, who is the mortal you wish to know more about?');
        sd(config.textcolor, ':');
        s := get_string(20);
        s := upcasestr(s);

        abort := False;
        found := False;

        for i := 1 to 2 do
        begin

          size := 1;
          case i of
            1: size := fs(FsPlayer);
            2: size := fs(FsNpc);
          end;

          for j := 1 to size do
          begin
            load_character(player0, i, j);

            if (findsub(s, player0.name2)) and
              (player0.name2 <> player.name2) and
              (player0.deleted = False) and
              (player0.name2 <> global_delname2) then
            begin

              if confirm(uplc + player0.name2 + config.textcol1h, 'n') = True then
              begin

                crlf;
                sd(config.textcolorH, 'You close your eyes and concentrate on ' + uplc + player0.name2);
                Make_Delay_Dots(2, 6, 250);
                crlf;

                s := player0.name2;
                status(player0);
                found := True;

                {inform the subject who was spied upon}
                if is_online(player0.name2, online_player) = True then
                begin
                  online_send_to_player(player0.name2, online_player, ugodc + player.name2 + config.textcol1 + ' spied on you!');
                end else
                begin
                  post(MailSend,
                    player0.name2,
                    'H',
                    False,
                    mailrequest_nothing,
                    '',
                    umailheadc + 'Examined' + config.textcol1,
                    mkstring(7, underscore),
                    'The Gods are spying on you!',
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

                break;

              end else
              begin
                if confirm('Continue Search', 'y') = False then
                begin
                  abort := True;
                  break;
                end;
              end;
            end;

          end; {for j:= .end.}

          if (found) or (abort) then break;

        end; {for i:= .end.}

        if not found then
        begin
          d(12, 'Sorry, couldn''t find that character.');
          crlf;
          pause;
        end;

      end;

      'D': begin {divine_intervention *start*}
        crlf;
        done := False;
        ch := '?';
        repeat

          if ch = '?' then
          begin
            clearscreen;
            crlf;
            d(9, '**Use your Powers**');
            menu('(M)ortals');
            menu('(C)hildren');
            menu('(P)risoners');
            menu('(H)elp');
            menu('(R)eturn');
          end;

          crlf;
          sd(config.textcolor, 'Divine Intervention (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');

          {get user-input}
          ch := upcase(getchar);

          {evaluate user-input}
          case ch of

            'R': done := True; {return}

            'H': begin {help}
              crlf;
              crlf;
              d(11, 'Chose category of people to use your powers on.');
              crlf;
            end;
            'M': mortal_intervention;
            'C': child_intervention;
            'P': prison_intervention;
          end; {case .end.}

        until done;

      end; {divine_intervention *end*}

    end; {case .end.}

  until EndGodWorld;
  {BIG LOOP *END*}

  {save god before exit}
  load_god(fsave, god, god.recnr);

  {bye}
  normal_exit;

end; {god_world *end*}

end. {Unit GodWorld .end.}
