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



unit OnTrade; {Usurper - Online Trade between two players}

interface

procedure Online_Trade(utman: boolean);

implementation

uses
  Init, Jakob, Statusc,
  Invent, News, Various,
  Various2, File_Io;

var
  adios, imp, challenger: boolean;

  oppo:           s30;

  save_mess, outmessage: s70;

  nr1, nr2, maxm: longint;

  enemy:          userrec;
  commy:          comrec;


procedure Put_Other(incom: char);
var i:   byte;
  bye:   boolean;
  sleep: longint;
begin

  bye := False;
  sleep := 0;

  if imp = True then
    i := 1
  else i := 0;
  repeat

    Inc(sleep);
    loadsave_com(Fload, Commy, i, save_mess);

    {jakob}
    delay2(global_lockdelay);

    if commy.com = '=' then
    begin
      bye := True;
    end;

    if f_exists(onliner.comfile) = False then
    begin
      d(config.textcolor, 'The talks are over!');
      d(config.textcolor, 'The other part has left!');
      adios := True;
      bye := True;
    end;

    if sleep > global_online_maxwaits_bigloop then
    begin

      d(config.textcolor, 'The talks are over!');
      d(config.textcolor, 'You have not responded fast enough! (press ENTER)');
      adios := True;
      bye := True;

    end;

  until bye = True;

  loadsave_com(Fload, Commy, i, save_mess);
  commy.com := incom;
  commy.nr1 := nr1;
  commy.nr2 := nr2;
  loadsave_com(FSave, commy, i, save_mess);

end; {put_other *end*}

procedure Put_Own(incom: char);
var i: byte;
begin

  if imp = True then
    i := 0
  else i := 1;
  commy.com := incom;
  commy.nr1 := nr1;
  commy.nr2 := nr2;

  loadsave_com(FSave, Commy, i, save_mess);

end; {put_own *end*}


function Get_Com(k1, k2, k3, k4, k5, k6, k7, k8, k9, k11, k10, k12, k13, k14, k15, k16, k17, k18: char): char;
var i:   byte;
  sleep: longint;
begin
  sleep := 0;
  if imp = True then
    i := 0
  else i := 1;

  repeat

    Inc(sleep);

    {jakob}
    delay2(global_lockdelay);

    if f_exists(onliner.comfile) then
    begin
      loadsave_com(Fload, Commy, i, save_mess);
      if commy.com = '^' then
      begin
        commy.com := ' ';
      end;
    end else
    begin
      if sleep > global_online_maxwaits_bigloop then
      begin
        sd(global_plycol, oppo);
        d(config.textcolor, ' has dropped out of the negotiations!');
        sleep := global_online_maxwaits_bigloop;
        break;
      end;
    end;

  until (commy.com in [k1, k2, k3, k4, k5, k6, k7, k8, k9, k10,
      k11, k12, k13, k14, k15, k16, k17, k18]) or (sleep >= global_online_maxwaits_bigloop);


  if sleep >= global_online_maxwaits_bigloop then
  begin
    adios := True;
    sd(global_plycol, oppo);
    d(config.textcolor, ' has suddenly left you!');
  end else
  begin
    get_com := commy.com;
  end;

  outmessage := commy.mess[1];
  nr1 := commy.nr1;
  nr2 := commy.nr2;

end; {get_com *end*}


procedure Online_Trade;
const
  I_Accept_The_Trade = 'I accept the trade! (IT''S A DEAL!)';

var
  {news-paper vars}
  news_item, news_money, news_potion: boolean;

  {news paper string array}
  ns:       array[1..3] of s90;

  abort, ok, done, grepe, finito: boolean;

  waits:    word;

  i, fs1, fs2, zz, yy: longint;

  y, error: integer;

  ch, cho:  char;

  s:        s70;

  slask1:   byte;

  slask2:   objtype;

  objekt:   ^orec;
  ComFile:  file of ComRec;     {** Comm file for duels **}

  procedure Disposal;
  begin
    dispose(objekt);
  end;

begin

  {init pointer variables}
  new(objekt);

  {check to see if loser can play more today}
  User_save(player);

  {find player positions in userfile}
  fs1 := 0;
  fs2 := 0;

  for i := 1 to fs(FsPlayer) do
  begin
    load_character(enemy, 1, i);
    if enemy.name2 = onliner.Name then
    begin
      fs1 := i;
    end;
    if enemy.name2 = onliner.bname then
    begin
      fs2 := i;
    end;

    if (fs1 <> 0) and (fs2 <> 0) then
    begin
      break;
    end;
  end; {for i:= .end.}

       {init}
  error := 0;
  challenger := utman;
  imp := utman;
  adios := False;
  oppo := onliner.bname;

  news_item := False;
  news_money := False;
  news_potion := False;


  {file that keeps track of filelocking}
  if challenger then
  begin
    commy.com := '=';
    commy.mess[1] := emptystr;
    commy.mess[2] := emptystr;
    commy.nr1 := 0;
    commy.nr2 := 0;

    Assign(comfile, onliner.comfile);
  {$I-}rewrite(comfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_create(onliner.comfile, error);

  {$I-}Write(comfile, commy);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_write(onliner.comfile, error);

  {$I-}Write(comfile, commy);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_write(onliner.comfile, error);

  {$I-}Close(comfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_close(onliner.comfile, error);

  end else
  begin

    grepe := False;
    waits := 0;
    abort := False;
    repeat

      delay2(global_lockdelay);
      Inc(waits);
      {wait until 'attacker' has created a comfile}
      if not grepe then
      begin

        sd(config.textcolor, 'Preparing to negotiate...(press ');
        sd(config.hotkeycolor, 'A');
        sd(config.textcolor, ' to abort)');

        grepe := True;
      end else
      begin

        {check if user has pressed A to abort}
        if ukeypressed then
        begin
          ch := upcase(getchar);
          if ch = 'A' then
          begin
            crlf;
            d(12, 'abort.');
            abort := True;
          end;
        end;

        my_timeslice;
        sd(config.textcolor, '.');

      end;

      if waits > global_online_maxwaits then
        abort := True;

    until (f_exists(onliner.comfile)) or (abort);

    if abort then
    begin
      d(12, 'unable to establish connection..');
      disposal;
      exit;
    end;

    crlf;
  end;

  repeat
    crlf;

    if not challenger then
    begin

      load_character(enemy, 1, fs2);

      repeat

        crlf;
        d(config.textcolor, 'waiting for ' + uplc + oppo + 's' + config.textcol1 + ' move...');

        put_own('='); {setting up for "ready for input" mode}

        {get input from other node}
        cho := get_com('M', 'H', 'I', 'J', 'G', 'D', 'E', '1', '2', '3', '4', '^', '^',
          '^', '^', '^', '^', '^');

        if cho = 'J' then
        begin
          ok := False;

          inventory_sort(player);
          inventory_sort(enemy);

          load_objekt(objekt^, enemy.itemtype[nr1], enemy.item[nr1]);
          sd(global_plycol, oppo);
          sd(config.textcolor, ' offers you the ');
          d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
          sd(config.textcolor, ' in return for your ');
          load_objekt(objekt^, player.itemtype[nr2], player.item[nr2]);
          sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
          d(config.textcolor, '.');

          if confirm('Accept trade', 'Y') = True then
          begin
            {deal!}

            {give item to other player}
            slask1 := enemy.item[nr1];
            slask2 := enemy.itemtype[nr1];
            enemy.item[nr1] := 0;

            y := inventory_empty(enemy);

            enemy.item[y] := player.item[nr2];
            enemy.itemtype[y] := player.itemtype[nr2];

            {remove item from players inventory}
            player.item[nr2] := 0;

            {get item from other player}
            y := inventory_empty(player);
            player.item[y] := slask1;
            player.itemtype[y] := slask2;

            {remove item from enemys inventory}
            enemy.item[nr1] := 0;

            {save users}
            user_save(enemy);
            user_save(player);

            ch := 'E';
            save_mess := I_Accept_The_Trade;

            put_other(ch);
          end else
          begin
            {no deal}
            ch := 'E';
            save_mess := 'I don''t accept your offer!';
            put_other(ch);
          end;

        end else
        begin
          ok := True;
        end;

      until ok;

    end else
    begin {if challenger = false}

      load_character(enemy, 1, fs2);

      ch := '?';
      repeat

        {trading menu}
        if ch = '?' then
        begin
          d(11, 'Negotiating with ' + uplc + oppo);

          sd(config.textcolor, 'Send : ');
          menu2('(M)oney  ');
          menu2('(H)ealing Potions  ');
          menu2('(I)tems  ');
          menu('(O) Socials');
          sd(config.textcolor, '       ');
          menu2('(C)heck inventory  ');
          menu('(L)ook at ' + oppo + '  ');
          sd(config.textcolor, '       ');
          menu2('(E)xpress your feelings  ');
          menu2('(S)tatus  ');
          menu2('(D)o nothing  ');
          menu('(G)oodbye');
          sd(config.textcolor, ':');
        end;

        {get user-input}
        ch := upcase(getchar);
        save_mess := '';

        {this is necessary since 'J' is used in the 'I' routine below}
        if ch = 'J' then
          ch := '?';

        {evaluate user-input}
        case ch of
          'D': begin {do nothing}
            d(config.textcolor, 'You hang around...');
          end;
          'S': begin {status}
            status(player);
            ch := '?';
          end;
          'L': begin {look at the other guy}
            status(enemy);
            ch := '?';
          end;
          'C': begin {check inventory}
            inventory_display(player);
            ch := '?';
          end;
          'I': begin {send item}

            ch := '?';
            inventory_sort(player);

            repeat
              finito := False;
              d(config.textcolor, 'Item # to Send (' + config.textcol2 + '?' + config.textcol1 + '=list, Enter=abort)');
              sd(config.textcolor, ':');

              s := get_string(5);
              yy := 0;

              if s = '?' then
              begin
                inventory_display(player);
              end else
              if s = '' then
              begin
                finito := True;
              end else
              begin
                yy := str_to_nr(s);
                if (yy < 1) or (yy > global_maxitem) then
                begin
                  yy := 0;
                end;
              end;

              if yy > 0 then
              begin

                if player.item[yy] > 0 then
                begin
                  zz := player.item[yy];
                  load_objekt(objekt^, player.itemtype[yy], zz);
                  if inventory_empty(enemy) = 0 then
                  begin
                    crlf;
                    sd(global_plycol, oppo + 's');
                    d(config.textcolor, ' inventory is full!');
                    crlf;
                    pause;
                  end else
                  if objekt^.cursed = True then
                  begin
                    sd(12, 'Impossible! The ');
                    sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                    d(12, ' is cursed!');
                    crlf;
                    pause;
                  end else
                  begin

                    crlf;
                    sd(config.textcolor, 'Give ');
                    sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                    sd(config.textcolor, ' to ');
                    sd(global_plycol, oppo);

                    if confirm(' ', 'N') = True then
                    begin

                      if confirm('Would you like to request an item from ' + uplc + oppo +
                        config.textcol1 + ' at the same time', 'N') = True then
                      begin

                        ch := '?';
                        nr1 := yy; {item offered}
                        nr2 := 0;  {item requested}

                        inventory_sort(enemy);

                        repeat
                          finito := False;
                          d(config.textcolor, 'Item # to Request (' + config.textcol2 + '?' +
                            config.textcol1 + '=list, Enter=abort)');
                          sd(config.textcolor, ':');

                          s := get_string(5);
                          yy := 0;

                          if s = '?' then
                          begin
                            inventory_display(enemy);
                          end else
                          if s = '' then
                          begin
                            finito := True;
                          end else
                          begin
                            yy := str_to_nr(s);
                            if (yy < 1) or (yy > global_maxitem) then
                            begin
                              yy := 0;
                            end;
                          end;

                          if yy > 0 then
                          begin

                            if enemy.item[yy] > 0 then
                            begin

                              load_objekt(objekt^, enemy.itemtype[yy], enemy.item[yy]);
                              crlf;
                              sd(config.textcolor, 'Request ');
                              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                              sd(config.textcolor, ' from ');
                              sd(global_plycol, oppo);

                              if confirm(' ', 'N') = True then
                              begin
                                nr2 := yy;
                                finito := True;
                              end;

                            end;
                          end;

                        until finito;

                        if nr2 > 0 then
                        begin
                          {send request}
                          d(config.textcolor, 'You wait for ' + uplc + oppo + 's' + config.textcol1 + ' reply.');
                          ch := 'J';
                        end;

                      end else
                      begin

                        {give text}
                        sd(config.textcolor, 'You give ');
                        sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                        sd(config.textcolor, ' to ');
                        sd(global_plycol, oppo);
                        d(config.textcolor, '.');
                        crlf;

                        {give item to other player}
                        y := inventory_empty(enemy);
                        enemy.item[y] := player.item[yy]; {zz}
                        enemy.itemtype[y] := player.itemtype[yy];

                        {remove item from players inventory}
                        player.item[yy] := 0;

                        ch := 'I';

                        nr1 := y;
                        nr2 := 0;

                        user_save(enemy);

                        finito := True;
                      end;
                    end;

                  end;
                end;
              end;

            until finito;

          end;

          'H': begin {healing potions}
            ch := '?';

            if enemy.healing >= config.maxheals then
            begin
              crlf;
              d(12, enemy.name2 + ' can''t carry more potions.');
              pause;
            end else
            if player.healing > 0 then
            begin
              crlf;
              sd(config.textcolor, '  (' + oppo + ' has ');
              sd(5, commastr(enemy.healing));
              d(config.textcolor, ' potions)');
              crlf;

              sd(config.textcolor, 'You have ');
              sd(5, commastr(player.healing));
              d(config.textcolor, ' potions. Send how many?');
              sd(config.textcolor, ':');

              {get user input}
              zz := get_number(0, player.healing);

              if (zz <= player.healing) and (zz > 0) then
              begin
                maxm := global_maxinput - enemy.healing;
                if zz <= maxm then
                begin
                  sd(config.textcolor, 'You give the healing potions to ');
                  d(global_plycol, oppo);
                  nr1 := zz;
                  player.healing := player.healing - nr1;
                  ch := 'H';
                end else
                begin
                  d(15, 'Too many! Try again.');
                  pause;
                end;
              end;

            end else
            begin
              crlf;
              d(12, 'Fool! You have no potions!');
              pause;
            end;
          end;

          'O': begin {social interaction}
            ch := '?';
            repeat
              if ch = '?' then
              begin
                crlf;
                d(5, 'Do Social stuff');
                menu2('(B)ow   ');
                menu('(I)nsult');
                menu('(H)ug   ');
                menu('(K)iss  ');
                menu('(A)bort ');
                sd(config.textcolor, ':');
              end;
              ch := upcase(getchar);
            until ch in ['A', 'B', 'H', 'K', 'I'];

            crlf;
            {evaluate user-input}
            case ch of
              'A': begin
                ch := '?';
              end;
              'B': begin
                ch := '1'; {bow}
                sd(config.textcolor, 'You bow deeply before ');
                d(global_plycol, oppo);
              end;
              'H': begin
                ch := '2'; {hug}
                sd(config.textcolor, 'You hug ');
                d(global_plycol, oppo);
              end;
              'K': begin
                ch := '3'; {kiss}
                sd(config.textcolor, 'You step forward and give ');
                sd(global_plycol, oppo);
                d(config.textcolor, ' a kiss!');
              end;
              'I': begin
                ch := '4'; {insult}
                sd(config.textcolor, 'You call ');
                sd(global_plycol, oppo);
                d(config.textcolor, ' some dirty names!');
              end;

            end; {case .end.}

          end;
          'M': begin {money}

            ch := '?';

            if player.gold > 0 then
            begin
              crlf;
              sd(config.textcolor, '  (' + oppo + ' has ');
              sd(14, commastr(enemy.gold));
              d(config.textcolor, ' ' + many_money(enemy.gold) + ')');
              crlf;

              sd(config.textcolor, 'You have ');
              sd(14, commastr(player.gold));
              d(config.textcolor, ' ' + many_money(player.gold) + '. Send how much?');

              sd(config.textcolor, ':');

              {get user-input}
              zz := get_number(0, player.gold);



              if (zz <= player.gold) and (zz > 0) then
              begin

                maxm := global_maxinput - enemy.gold;

                if zz <= maxm then
                begin
                  sd(config.textcolor, 'You give the ' + config.moneytype + ' to ');
                  d(global_plycol, oppo);

                  nr1 := zz;

                  DecPlayerMoney(player, nr1);

                  ch := 'M';
                end else
                begin
                  d(12, 'Too much! Try again.');
                  pause;
                end;
              end;

            end else
            begin
              crlf;
              d(15, 'Idiot! You have no ' + config.moneytype + ' on hand!');
              pause;
            end;
          end;

          'E': begin {express yourself, say something}
            ch := '?';
            crlf;
            sd(config.textcolor, 'Say what : ');
            s := get_string(70);
            if s <> '' then
            begin
              ch := 'E';
              save_mess := s;
            end;
          end;

        end; {case .end.}
             {1=bow 2=hug 3=kiss}
      until ch in ['G', 'M', 'H', 'I', 'J', 'D', 'E', '1', '2', '3', '4'];

      {load the other player}
      load_character(enemy, 1, fs2);

      case ch of
        'G': begin {goodbye, end talks}
          d(15, 'You wave goodbye!   (press enter)');
          outmessage := '';
          adios := True;
        end;
      end; {case .end.}

           {save users}
      user_save(enemy);
      user_save(player); {pucko 0.13}

      put_other(ch);
    end;


    {EVALUATE ROUND}
    if challenger = False then
    begin
      load_character(player, 1, fs1);

      crlf;
      case cho of
        'G': begin {receiving goodbye}
          sd(global_plycol, oppo);
          d(config.textcolor, ' waves goodbye!');
          adios := True;
        end;
        '1': begin {receiving bow}
          sd(global_plycol, oppo);
          d(config.textcolor, ' bows deeply before you!');
        end;
        '2': begin {receiving hug}
          sd(global_plycol, oppo);
          d(config.textcolor, ' hugs you!');
        end;
        '3': begin {receiving kiss}
          sd(global_plycol, oppo);
          d(config.textcolor, ' kissed you!');
        end;
        '4': begin {receiving insults}
          sd(global_plycol, oppo);
          case random(5) of
            0: d(config.textcolor, ' thinks your mother is a cow!');
            1: d(config.textcolor, ' thinks you dresses like a pig!');
            2: d(config.textcolor, ' thinks you''re an idiot!');
            3: d(config.textcolor, ' thinks you''re a moron!');
            4: d(config.textcolor, ' thinks you look like a swamp monster!');
            5: d(config.textcolor, ' thinks you should get the hell out of here!');
          end;     {case end}
        end;
        'I': begin {receiving item}
          load_objekt(objekt^, player.itemtype[nr1], player.item[nr1]);
          sd(global_plycol, oppo);
          sd(config.textcolor, ' gave you the ');
          sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
          d(config.textcolor, '.');
          pause;

          news_item := True;
        end;
        'E': begin {receiving phrase}
          sd(global_plycol, oppo);
          d(config.textcolor, ' says :');
          d(global_talkcol, outmessage);

          {load player}
          if outmessage = I_Accept_The_Trade then
          begin

            load_character(player, 1, fs1);
            load_character(enemy, 1, fs2);

          end;

        end;
        'D': begin {receiving "the other guys doing nothing"}
          sd(global_plycol, oppo);
          d(config.textcolor, ' looks at you very intensively.');
          d(config.textcolor, 'Perhaps you should send some stuff...');
        end;
        'M': begin {receiving money}


          if incplayermoney(player, nr1) then
          begin
            sd(global_plycol, oppo);
            sd(config.textcolor, ' gave you ');
            sd(14, commastr(nr1));
            d(config.textcolor, ' ' + many_money(nr1) + '!');
            pause;
            news_money := True;
          end else
          begin
            d(12, 'You could not accept the money! It would be too much for');
            d(12, 'You to carry!');
            pause;

          end;

        end;
        'H': begin {receiving healing potions}
          sd(global_plycol, oppo);
          sd(config.textcolor, ' gave you ');
          sd(15, commastr(nr1));
          d(config.textcolor, ' healing potions!');
          player.healing := player.healing + nr1;
          news_potion := True;
          pause;
        end;

      end; {case .end.}

    end else
    begin {if challenger = true}
      case ch of
        'G': begin
          adios := True;
        end;
      end; {case .end.}
    end;

    {swap roles}
    if challenger then
    begin
      challenger := False;
    end else
    begin
      challenger := True;
    end;

  until (adios) or (f_exists(onliner.comfile) = False);

  {END OF TALKS!}

  {finish the temporary file}
  if utman then
  begin

    {read comfile until "O + OVER" has been found}
    done := False;

    repeat
      loadsave_com(Fload, Commy, 1, save_mess);
      if (commy.com = 'O') and (commy.mess[1] = 'OVER') then
      begin
        done := True;
      end;

      delay2(global_lockdelay);

    until done;

    {delete comfile}
    delete_file(onliner.comfile);

  end else
  begin {writing signoff sign, so that UTMAN can delete the comfile}

    if f_exists(onliner.comfile) then
    begin
      commy.com := 'O';
      commy.mess[1] := 'OVER';
      save_mess := 'OVER';
      loadsave_com(FSave, Commy, 1, save_mess);
    end;

  end;

  {news-paper}
  if (news_item = True) or (news_money = True) or (news_potion = True) then
  begin

    i := 0;
    ns[1] := '';
    ns[2] := '';
    ns[3] := '';

    if news_item then
    begin
      Inc(i);
      ns[i] := ' Some ' + ulblue + 'items' + config.textcol1 + ' were traded...';
    end;

    if news_money then
    begin
      Inc(i);
      ns[i] := ' Some ' + uyellow + config.moneytype + config.textcol1 + ' were traded...';
    end;

    if news_potion then
    begin
      Inc(i);
      ns[i] := ' Some ' + ulcyan + 'potions' + config.textcol1 + ' were traded...';
    end;

    {news-paper}
    Newsy(True,
      'Online Trading' + config.textcol1,
      ' ' + uplc + player.name2 + config.textcol1 + ' met with ' + uplc + enemy.name2 + config.textcol1 + ' to trade.',
      '' + ns[1],
      '' + ns[2],
      '' + ns[3],
      '',
      '',
      '',
      '',
      '');
  end;

  {remove pointer vars}
  disposal;
  crlf;

end; {Online_Trade *end*}

end. {Unit Ontrade .end.}
