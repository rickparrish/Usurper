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


unit HaggleC; {Usurper - Haggle routines}

interface

function Haggle(shop: char; origcost: longint; const keeper: string): longint;

implementation

uses
  Init, Jakob, News;

function Haggle;
var
  diff, offer, temp, cost: longint;

  accept: boolean;

  rr:     real;

begin

  {init}
  accept := False;
  cost := origcost;

  d(15, 'Haggle');
  crlf;

  if (config.classic) and (player.race = troll) and (shop = 'W') then
  begin
    d(global_talkcol, 'Hey! I''ve already given you a discount!');
    d(global_talkcol, 'Don''t expect any more! Get out!');
  end else
  begin
    if (shop = 'W') and (player.weaphag = 0) then
    begin
      d(global_talkcol, 'You are making me very angry ');
      sd(global_plycol, player.name2);
      d(config.textcolor, ' !');
      d(global_talkcol, 'Accept my offer or leave!');
      crlf;
      sd(global_plycol, keeper + 's');
      d(config.textcolor, ' face turns unhealthy red...');

      d(config.textcolor, 'What are you going to do? Insist once more or leave?');
      if confirm('Insist ', 'N') = True then
      begin
        d(15, 'You have been kicked out!');

        {news-paper}
        newsy(True,
          'Haggler kicked out',
          ' ' + uplc + player.name2 + config.textcol1 + ' was kicked out from the ' + ulcyan + 'Weaponshop' + config.textcol1 + '!',
          ' ',
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
        d(config.textcolor, 'End of discussion.');
        pause;
      end;
    end else if (shop = 'A') and (player.armhag = 0) then
    begin
      sd(global_talkcol, 'Damn you ');
      sd(global_plycol, player.name2);
      d(global_talkcol, '!');
      d(global_talkcol, ' Accept my offer or leave!');
      crlf;
      sd(global_plycol, keeper + 's');
      d(config.textcolor, ' seems to be quite upset with your behaviour.');
      d(config.textcolor, 'What are you going to do? Insist once more or leave?');

      if confirm('Insist ', 'N') = True then
      begin
        d(15, 'You have been kicked out!');

        {news-paper}
        newsy(True,
          'Haggler kicked out',
          ' ' + uplc + player.name2 + config.textcol1 + ' was kicked out from the ' + ulcyan + 'Armor Shop' + config.textcol1 + '!',
          ' ',
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
        d(config.textcolor, 'No deal.');
        pause;
      end;

    end else
    begin
      {main haggle routine b”rjar h„r}

      case shop of
        'W': Dec(player.weaphag);
        'A': Dec(player.armhag);
      end;

      d(global_talkcol, 'Alright, give me an offer');

      sd(config.textcolor, ':');
      offer := get_number(0, global_maxinput);

      if (offer > 0) and (offer < 2000000000) then
      begin
        offer := offer;
      end else
      begin
        offer := 0;
      end;

      if offer >= origcost then
      begin
        offer := 0;
      end;

      {chans att lyckas beror p† charisma och tur}
      {max 20 % kan prutas}
      if offer > 0 then
      begin
        rr := 0.20 * origcost;
        temp := origcost - round(rr);

        if offer < temp then
        begin
          accept := False;
        end else
        begin
          rr := origcost / offer;
          rr := rr - 1;
          temp := round(rr * 100);

          {kollar charisman}
          {d(15,commastr(temp)+'%');}
          case player.charisma of
            1..25: if temp <= 4 then accept := True;
            26..75: if temp <= 7 then accept := True;
            76..125: if temp <= 10 then accept := True;
            126..175: if temp <= 13 then accept := True;
            176..200: if temp <= 17 then accept := True;
            201..999: if temp <= 20 then accept := True;
          end;

        end;

    {rr:=(origcost*rr);
    dec(origcost,round(rr));}
      end else
      begin
        accept := False;
      end;

      if accept = False then
      begin
        case shop of
          'W': begin
            d(global_talkcol, 'Haha! You think you''re funny huh!?');
            d(global_talkcol, 'Get out of here before I get nasty!');
          end;
          'A': begin
            d(global_talkcol, 'Stop kidding around and get out, so I can');
            d(global_talkcol, 'do some serious business!');
          end;
        end;
      end else
      begin
        sd(global_talkcol, 'Alright ');
        sd(global_plycol, player.name2);
        d(global_talkcol, ' ! You''ve got a deal!');
        if confirm('Accept ', 'N') = True then
        begin
          cost := offer;
        end;
      end;

    end;
  end;

  {return result}
  haggle := cost;

end; {Haggle *end*}

end. {Unit HaggleC .end.}
