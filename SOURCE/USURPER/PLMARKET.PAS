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



unit PlMarket; {Usurper - players market}

interface

uses
  Init;

procedure Players_Market;
procedure Remove_PlayerMarketItems(const ply: UserRec);

implementation

uses
  Cms, Jakob, Mail,
  News, Statusc, Invent,
  Various, Various2, Online,
  File_Io;

const keeper = 'Ugly Joe';

var refresh:          boolean;
  tempdat1, tempdat2: Udate;

procedure Remove_PlayerMarketItems;
var i:   word;
  pitem: MarketItemRec;
begin {executed when a player is deactivated from the game}

      {we remove plys items from the market-place}
  for i := 1 to fs(fsmarket) do
  begin
    load_market(Fload, pitem, i);

    if (pitem.sold = False) and
      (pitem.seller = ply.name2) then
    begin
      {deactivate item}
      pitem.sold := True;
      load_market(fsave, pitem, i);
    end;
  end; {for i:= .end.}

end;   {remove_playermarketitems *end*}


procedure Meny;
begin
  clearscreen;
  crlf;
  sd(5, '-*- Players Market, run by ');
  sd(14, keeper);
  d(5, ' -*-');
  crlf;
  sd(11, keeper);
  d(config.textcolor, ' looks at you. He carries a large Stick in his belt.');
  d(config.textcolor, 'With his bulging muscles, he makes a formidable opponent.');
  d(config.textcolor, 'Many thieves bear in their memories dreadful experiences');
  d(config.textcolor, 'of being flogged..');

  crlf;
  menu('(C)heck bulletin board');
  menu('(B)uy item');
  menu('(A)dd item');
  menu('(S)tatus');
  menu('(R)eturn to Market');
end;

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['C',
                       'A',
                       'B',
                       'S',
                       'R',
                       chr(13),
                       '?']);}

  if short = True then
  begin
    if player.expert = False then
    begin
      if (refresh) and (player.auto_meny) then
      begin
        refresh := False;
        meny;
      end;
      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;

      sd(config.textcolor, 'Players Market (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');

    end else
    begin
      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'Players Market (A,C,B,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;
end;

function Empty_Slot: longint;
var q:    longint;
  kuvert: MarketItemrec;
  grepp:  boolean;
begin

  {find deleted post in playermarket file}

  grepp := False;
  empty_slot := 1;
  tempdat1 := fix_date(todays_date);

  for q := 1 to fs(FsMarket) do
  begin
    load_market(Fload, kuvert, q);

    {checking if mail is old and can be discarded}
    if kuvert.sold = False then
    begin
      tempdat2 := fix_date(kuvert.date);
      if days_between(tempdat1, tempdat2) > config.maxmarket then
      begin
        kuvert.sold := True;
      end;
    end;

    if kuvert.sold = True then
    begin
      empty_slot := q;
      grepp := True;
      break;
    end;
  end;

  if not grepp then
  begin
    empty_slot := fs(FsMarket) + 1;
  end;

end; {empty_slot *end*}

procedure Players_Market;
var
  dayson: integer;
  i:      longint;
  cho:    char;
  cc, cc2, mem: word;
  found:  boolean;
  PItem:  MarketItemrec;
  objekt: ^orec;
  pl0:    userrec;
  x, xx:  longint;
  s:      s70;

begin

  new(objekt);

  repeat

    if onliner.location <> onloc_plymarket then
    begin
      refresh := True;
      onliner.location := onloc_plymarket;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;


    {display menu}
    display_menu(True, True);

    {get user input}
    cho := upcase(getchar);

    case cho of
      '?': begin
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin
        status(player);
      end;
      'A': begin {add item}

        crlf;
        repeat
          cc := item_select(player);
          if cc > 0 then
          begin
            load_objekt(objekt^, player.itemtype[cc], player.item[cc]);
            crlf;

            sd(global_itemcol, objekt^.Name);

            if confirm(' ', 'Y') = True then
            begin
              if objekt^.cursed = True then
              begin
                sd(12, 'You can''t get rid of ');
                sd(global_itemcol, objekt^.Name);
                sd(12, ' !');
                d(12, ' It must be cursed!');
              end else
              begin
                sd(config.textcolor, 'Price ? (your ');
                sd(global_itemcol, objekt^.Name);
                sd(config.textcolor, ' is worth about ');

                sd(14, commastr(objekt^.Value));
                d(config.textcolor, ' ' + many_money(objekt^.Value) + ')');

                sd(config.textcolor, ':');

                {get requested price from user}
                x := get_number(0, 1000000000);

                if (x <= 1000000000) and (x > 0) then
                begin
                  if confirm('Add a comment', 'Y') = True then
                  begin
                    sd(config.textcolor, ':');
                    s := get_string(65);
                  end else
                  begin
                    s := emptystr;
                  end;

                  {setup item}
                  pitem.pekare := player.item[cc];
                  pitem.ityp := player.itemtype[cc];
                  pitem.seller := player.name2;
                  pitem.date := todays_date;
                  pitem.price := x;
                  pitem.target := emptystr;
                  pitem.team := False;
                  pitem.comment := s;
                  pitem.sold := False;

                  {save item}
                  load_market(Fsave, pitem, empty_slot);

                  player.item[cc] := 0;

                  crlf;
                  sd(15, 'OK. ');
                  sd(config.textcolor, 'Your ');
                  sd(global_itemcol, objekt^.Name);
                  d(config.textcolor, ' has been added to the board.');

                  crlf;
                  crlf;
                  sd(config.textcolor, 'Hopefully, someone will buy your ');
                  sd(global_itemcol, objekt^.Name);
                  d(config.textcolor, '.');

                  {news-paper}
                  newsy(True,
                    'Bargain',
                    ' ' + uplc + player.name2 + config.textcol1 + ' is selling ' + uitemc +
                    objekt^.Name + config.textcol1 + ' at the Market.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  pause;

                end else
                begin
                  d(15, 'Error!');
                end;
              end;
            end;
          end;
        until cc = 0;

      end;       {add item .end.}

      'B': begin {buy item}
        if inventory_empty(player) = 0 then
        begin
          d(config.textcolor, 'Your inventory is full!');
          d(config.textcolor, 'Get rid of something before you start buying!');
        end else
        begin
          crlf;
          d(3, 'Enter Item # to buy');
          sd(config.textcolor, ':');

          x := get_number(0, 65000);

          found := False;
          if (x > 0) and (x <= fs(FsMarket)) then
          begin
            cc2 := 0;
            xx := fs(FsMarket);
            for i := 1 to xx do
            begin
              load_market(Fload, pitem, i);

              tempdat1 := fix_date(todays_date);
              tempdat2 := fix_date(pitem.date);
              dayson := days_between(tempdat1, tempdat2);

              if (pitem.sold = False) and (dayson <= config.maxmarket) then
              begin
                Inc(cc2);
                if cc2 = x then
                begin
                  mem := i - 1;
                  found := True;
                  break;
                end;
              end;
            end;

            if found = True then
            begin
              load_objekt(objekt^, pitem.ityp, pitem.pekare);

              sd(global_itemcol, objekt^.Name);
              if confirm(' ', 'N') = True then
              begin
                if player.gold < pitem.price then
                begin
                  d(15, 'You don''t have enough ' + config.moneytype + '!');
                end else
                if allowed_to_use(pitem.ityp) = False then
                begin
                  d(15, 'This type of items are no longer permitted in the game.');
                  d(15, 'Your Sysop has disabled the use of them.');
                end else
                begin
                  decplayermoney(player, pitem.price);
                  cc := inventory_empty(player);
                  player.item[cc] := pitem.pekare;
                  player.itemtype[cc] := pitem.ityp;

                  if pitem.seller <> player.name2 then
                  begin
                    d(15, 'Deal!');
                    sd(config.textcolor, 'You send ');
                    sd(14, commastr(pitem.price));
                    sd(config.textcolor, ' ' + many_money(pitem.price) + ' to ');
                    sd(global_plycol, pitem.seller);
                    d(config.textcolor, '.');
                  end else
                  begin
                    d(15, 'Deal!');
                    sd(config.textcolor, 'You send ');
                    sd(14, commastr(pitem.price));
                    sd(config.textcolor, ' ' + many_money(pitem.price) + ' to ');
                    sd(global_plycol, 'YOURSELF');
                    d(config.textcolor, ' (idiot).');
                    incplayermoney(player, pitem.price);
                  end;

                  pitem.sold := True;

                  load_market(Fsave, pitem, mem + 1);

                  {news-paper}
                  newsy(True,
                    'Purchase',
                    ' ' + uplc + player.name2 + config.textcol1 + ' bought the ' + uitemc +
                    objekt^.Name + config.textcol1 + ' at the Market.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {find seller and send pengar + mess}
                  if pitem.seller <> player.name2 then
                  begin
                    for i := 1 to fs(FsPlayer) do
                    begin
                      load_character(pl0, 1, i);
                      if pl0.name2 = pitem.seller then
                      begin

                        post(MailSend,
                          pl0.name2,
                          pl0.ai,
                          False,
                          mailrequest_nothing,
                          '',
                          umailheadc + 'The Market' + config.textcol1,
                          mkstring(10, underscore),
                          uplc + player.name2 + config.textcol1 + ' purchased your ' + uitemc +
                          objekt^.Name + config.textcol1 + ' for ' + uyellow + commastr(pitem.price) + config.textcol1 +
                          ' ' + many_money(pitem.price) + '.',
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


                        {if receiver is online we send him a mess + the money online to}
                        {else if send the money offline}
                        if is_online(pl0.name2, online_player) then
                        begin
                          online_send_to_player(pl0.name2, online_player, broadcast_sentmoney + long2str(pitem.price));
                        end else
                        begin
                          IncBankMoney(pl0, pitem.price);
                          user_save(pl0);
                        end;

                        break;
                      end;
                    end; {for i:= .end.}
                  end;

                end;
              end;
            end;

          end;
        end;

      end;
      'C': begin {check bulletin board}
        crlf;
        d(global_talkcol, 'Well let''s see what''s for sale ..!');
        crlf;

        cc := 0;
        cc2 := 0;
        found := False;

        for i := 1 to fs(FsMarket) do
        begin
          found := True;

          load_market(Fload, pitem, i);
          load_objekt(objekt^, pitem.ityp, pitem.pekare);

          tempdat1 := fix_date(todays_date);
          tempdat2 := fix_date(pitem.date);
          dayson := days_between(tempdat1, tempdat2);

          if (pitem.sold = False) and (dayson <= config.maxmarket) then
          begin
            Inc(cc2);
            Inc(cc);
            if cc > 3 then
            begin
              cc := 1;
              if confirm('Continue List ', 'Y') = False then
              begin
                break;
              end;
            end;

            crlf;
            d(15, '[#' + commastr(cc2) + ']');
            sd(config.textcolor, 'Item          : ');
            d(global_itemcol, objekt^.Name);

            sd(config.textcolor, 'Price         : ');
            d(14, commastr(pitem.price));

            sd(config.textcolor, 'Seller        : ');
            d(global_plycol, pitem.seller);

            sd(config.textcolor, 'Comment       : ');
            d(global_talkcol, pitem.comment);

            sd(config.textcolor, 'Days on board : ');


            dayson := days_between(tempdat1, tempdat2);

            d(10, commastr(dayson));

            if pitem.team = True then
            begin
              d(5, 'This item can only be purchased by teammates to ');
              d(15, ' ' + pitem.seller);
            end;

            if pitem.target <> '' then
            begin
              d(5, 'This item has been marked as *PRIVATE*');
            end;
          end;

        end;

        if found = False then
        begin
          crlf;
          d(15, 'Nothing for sale!');
        end;

      end;
    end;
  until cho = 'R';

  dispose(objekt);
  crlf;

end; {Players_Market *end*}

end. {Unit PlMarket .end.}
