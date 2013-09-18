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


unit ArmShop; {Usurper - Armor Shop}

interface

procedure Armor_Shop;

implementation

uses
  Init, Cms, Jakob,
  News, Invent,
  Hagglec, Various, Various2,
  Online, File_Io;

const backpack = 'back-pack';

var
  s:       s70;
  bought:  integer;
  objekt:  ^orec;
  Reese:   ^s70;
  refresh: boolean;
  counter: integer;
  needs:   integer;
  ok:      boolean;

  head_need, body_need, arms_need, legs_need, feet_need, face_need, shield_need, hands_need, abody_need: boolean;


procedure Note_It(const spook: s70); {put Armor Buy in the News}
begin

  newsy(True,
    'Armor',
    ' ' + uplc + player.name2 + config.textcol1 + ' bought a ' + uitemc + spook + config.textcol1 + '.',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end;

function Purchase_Now(tupp: objtype; i: word): boolean;
const loud_affect = True;
var deal: boolean;
begin

  sd(global_talkcol, 'I have a nice ');
  sd(global_itemcol, objekt^.Name);
  sd(global_talkcol, ' here');
  sd(config.textcolor, ', ');
  sd(global_plycol, reese^);
  d(config.textcolor, ' says.');
  sd(config.textcolor, 'You can get it for ');
  sd(14, commastr(objekt^.Value));
  d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + '.');
  crlf;

  if confirm('Buy it ', 'Y') = True then
  begin
    Inc(bought);
    decplayermoney(player, objekt^.Value);
    case tupp of
      Head: begin
        player.head := i;
        objekt_affect(1, player.head, head, player, loud_affect);
      end;
      Body: begin
        player.body := i;
        objekt_affect(1, player.body, body, player, loud_affect);
      end;
      Arms: begin
        player.arms := i;
        objekt_affect(1, player.arms, arms, player, loud_affect);
      end;
      Hands: begin
        player.hands := i;
        objekt_affect(1, player.hands, hands, player, loud_affect);
      end;
      Legs: begin
        player.legs := i;
        objekt_affect(1, player.legs, legs, player, loud_affect);
      end;
      Feet: begin
        player.feet := i;
        objekt_affect(1, player.feet, feet, player, loud_affect);
      end;
      Face: begin
        player.face := i;
        objekt_affect(1, player.face, face, player, loud_affect);
      end;
      Abody: begin
        player.abody := i;
        objekt_affect(1, player.abody, abody, player, loud_affect);
      end;
      Shield: begin
        player.shield := i;
        objekt_affect(1, player.shield, shield, player, loud_affect);
      end;

    end; {case .end.}

    deal := True;
  end else
  begin
    deal := False;
  end;

  {return result}
  if deal then purchase_now := True
  else purchase_now := False;

end; {purchase_now *end*}

procedure Purchase_Help(tupp: objtype; xx: longint);
var
  i:       word;
  bestobj: orec;
  bestnr:  word;

begin

  bestobj.Name := 'knuk';

  for i := 1 to fsob(tupp) do
  begin

    load_objekt(objekt^, tupp, i);

    if (objekt^.shop) and
      (objekt^.str_need <= player.strength) and
      (objekt^.cursed = False) and
      (objekt^.Value <= xx) then
    begin

      ok := True;

      if class_restricted(player.classid, objekt^, 0) = True then ok := False;
      if (player.dark > 0) and (objekt^.good) then ok := False;
      if (player.chiv > 0) and (objekt^.evil) then ok := False;
      if player.gold < objekt^.Value then ok := False;

      if ok then
      begin

        bestobj := objekt^;
        bestnr := i;

        if objekt^.Value > (xx - (xx div 2)) then
        begin
          if purchase_now(tupp, i) then
          begin
            break;
          end else
          begin
            ok := False;
          end;
        end else
        begin
          ok := False;
        end;

      end;
    end;
  end;

  if not (ok) and (bestobj.Name <> 'knuk') then
  begin
    {take the best the players money can get}
    objekt^ := bestobj;
    purchase_now(tupp, bestnr);
  end;

end; {purchase_help *end*}

procedure Meny;
var justval: byte;
begin

  clearscreen;
  crlf;
  s := 'Armorshop, run by ' + Reese^ + ' the elf';
  d(5, s);
  d(5, mkstring(length(s), underscore));
  crlf;

  d(config.textcolor, 'As you enter the store you notice a strange but appealing smell.');
  d(config.textcolor, 'You recall that some merchants use magic elixirs to make their selling easier...');
  sd(global_plycol, Reese^);
  d(config.textcolor, ' suddenly appears out of nowhere, with a smile on his face.');
  d(config.textcolor, 'He is known as a respectable citizen, although evil tounges speaks of');
  d(config.textcolor, 'meetings with dark and mysterious creatures from the deep dungeons.');
  sd(config.textcolor, 'You are interrupted in your thougts as ');
  sd(global_plycol, Reese^);
  d(config.textcolor, ' kindly asks');
  d(config.textcolor, 'what you want :');

  sd(config.textcolor, '(You have ');
  sd(14, commastr(player.gold));
  d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + ')');

  crlf;
  justval := 12;

  if config.classic then
  begin
    menu('(R)eturn to street');
    menu('(B)uy');
    menu('(S)ell');
    menu('(L)ist items');
  end else
  begin
  {1 : s:='Allow Hand Equipment';
   2 : s:='Allow Head Equipment';
   3 : s:='Allow Body Equipment';
   4 : s:='Allow Arm Equipment';
   5 : s:='Allow Left Finger Equipment';
   6 : s:='Allow Right Finger Equipment';
   7 : s:='Allow Leg Equipment';
   8 : s:='Allow Feet Equipment';
   9 : s:='Allow Waist Equipment';
   10: s:='Allow 1 Neck Equipment';
   11: s:='Allow 2 Neck Equipment';
   12: s:='Allow Face Equipment';
   13: s:='Allow Shield';
   14: s:='Allow Around Body Equipment';
   15: s:='Allow Secondary Weapon';
   }

    menu2(ljust('(B)uy', justval));
    justval := 16;
    if config.allowitem[2] then menu2(ljust('(H)ead Items', justval));
    if config.allowitem[3] then menu3(ljust('B(o)dy Items', justval), 3);
    if config.allowitem[4] then menu2(ljust('(A)rm Items', justval));
    crlf;

    justval := 12;
    menu2(ljust('(S)ell', justval));
    justval := 16;
    if config.allowitem[1] then menu3(ljust('Ha(n)d Items', justval), 4);
    if config.allowitem[7] then menu2(ljust('(L)eg Items', justval));
    if config.allowitem[8] then menu2(ljust('(F)eet Items', justval));
    crlf;

    justval := 12;
    menu2(ljust('(R)eturn', justval));
    justval := 16;
    if config.allowitem[12] then menu3(ljust('Fac(e) Items', justval), 5);
    if config.allowitem[14] then menu2(ljust('(C)loaks', justval));
    if config.allowitem[13] then menu3(ljust('Sh(i)elds', justval), 4);
    crlf;
    crlf;
    menu('(1) ask ' + uplc + reese^ + config.textcol1 + ' to help you with your equipment!');
  end;

end; {meny *end*}

procedure Display_Menu(force, short: boolean);
var s: s70;
begin

  if short = True then
  begin
    if player.expert = False then
    begin
      if (refresh) and (player.auto_meny) then
      begin
        refresh := False;
        meny;
      end;
      crlf;
      sd(config.textcolor, 'Armor Shop (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin
      crlf;
      if config.classic then
      begin
        sd(config.textcolor, 'Armors (L,B,S,R,?) :');
      end else
      begin
        s := 'Armors (B,S';

        if config.allowitem[2] then s := s + ',H';
        if config.allowitem[3] then s := s + ',O';
        if config.allowitem[4] then s := s + ',A';
        if config.allowitem[1] then s := s + ',N';
        if config.allowitem[7] then s := s + ',L';
        if config.allowitem[8] then s := s + ',F';
        if config.allowitem[12] then s := s + ',E';
        if config.allowitem[14] then s := s + ',C';
        if config.allowitem[13] then s := s + ',I';

        s := s + ',R,?) :';

        sd(config.textcolor, s);
      end;
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Armor_Shop;
var
  komihag, cho, ch: char;

  cc, j:       integer;

  x, i, xx:    longint;

  leave_place: boolean;

  zz:          word;

  inarm:       ^armrec;
  soktyp:      objtype;

  restrict:    boolean;
  normcol, shadcol, col: byte;
  aarmor:      armrec;

begin

  new(objekt);
  new(reese);
  new(inarm);

  {set default armor type when entering proc, NEW mode}
  if config.allowitem[1] then soktyp := Arms
  else if config.allowitem[2] then soktyp := Head
  else if config.allowitem[3] then soktyp := Body
  else if config.allowitem[4] then soktyp := Arms
  else if config.allowitem[7] then soktyp := Legs
  else if config.allowitem[8] then soktyp := Feet

  else if config.allowitem[12] then soktyp := Face
  else if config.allowitem[13] then soktyp := Shield
  else if config.allowitem[14] then soktyp := Abody
  else soktyp := Head;

  {fetch Reeses name from .CFG, #16}
  reese^ := cfg_string(16);
  if reese^ = '' then reese^ := 'Reese';

  komihag := ' ';
  leave_place := False;

  crlf;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_armorshop then
    begin
      refresh := True;
      onliner.location := onloc_armorshop;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    if player.armhag < 1 then
    begin
      crlf;
      d(15, 'The strong desk-clerks throw you out!');
      d(15, 'You realize that you went a little bit too far in');
      d(15, 'your attempts to get a good deal.');
      cho := 'R';

      Bad_News('A');

    end else if komihag = ' ' then
    begin
      display_menu(True, True);
      cho := upcase(getchar);
    end else
    begin
      cho := komihag;
      komihag := ' ';
    end;

    if cho = '?' then
    begin
      if player.expert = True then display_menu(True, False)
      else display_menu(False, False);
    end;

    if (cho = 'H') and (config.allowitem[2] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'O') and (config.allowitem[3] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'A') and (config.allowitem[4] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'N') and (config.allowitem[1] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'L') and (config.allowitem[7] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'F') and (config.allowitem[8] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'E') and (config.allowitem[12] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'C') and (config.allowitem[14] = False) and (config.classic = False) then cho := ' ';
    if (cho = 'I') and (config.allowitem[13] = False) and (config.classic = False) then cho := ' ';

    if (cho in ['H', 'O', 'A', 'N', 'L', 'F', 'E', 'C', 'I']) and (config.classic = False) then
    begin
      case cho of
        'H': soktyp := Head;
        'O': soktyp := Body;
        'A': soktyp := Arms;
        'N': soktyp := Hands;
        'L': soktyp := Legs;
        'F': soktyp := Feet;
        'E': soktyp := Face;
        'C': soktyp := Abody;
        'I': soktyp := Shield;
      end; {case .end.}

      crlf;
      j := 0;
      cc := 3;

      sd(5, ljust('#', 4));
      sd(5, ljust('Item', 16));
      d(5, rjust('Cost', 15));
      crlf;

      for i := 1 to fsob(soktyp) do
      begin
        load_objekt(objekt^, soktyp, i);
        if (objekt^.shop = True) then
        begin
          Inc(j, 1);

          Inc(cc, 1);

          restrict := False;
          if class_restricted(player.classid, objekt^, 0) = True then
          begin
            restrict := True;
          end;

          normcol := 3;
          shadcol := 8;

          if restrict then col := shadcol
          else col := normcol;

          {#}
          sd(col, ljust(commastr(j), 4));

          {name}
          s := objekt^.Name;
          while length(s) < 27 do
          begin
            s := s + '.';
          end;
          normcol := 15;
          if restrict then col := shadcol
          else col := normcol;
          sd(col, s);

          {price}
          normcol := 14;
          if restrict then col := shadcol
          else col := normcol;
          s := commastr(objekt^.Value);
          sd(col, s);

          {restrictions}
          if class_restricted(player.classid, objekt^, 0) = True then
          begin
            d(7, ' *Class Restricted*');
          end else
          begin
            crlf;
          end;

          {menu}
          if cc > global_screenlines - 2 then
          begin
            cc := 1;
            crlf;
            menu2('[C]ontinue  ');
            menu2('(A)bort  ');
            menu2('(B)uy item :');

            repeat
              ch := upcase(getchar);
            until ch in ['C', 'A', 'B', ReturnKey];

            if ch = ReturnKey then ch := 'C';

            case ch of
              'C': begin
                sd(config.textcolor, ' More');
              end;
              'A': begin
                sd(config.textcolor, ' Abort');
                break;
              end;
              'B': begin
                sd(config.textcolor, ' Buy item');
                cho := 'B';
                break;
              end;

            end; {case .end.}

            crlf;
          end;

        end;
      end;

      crlf;
    end;

    case cho of
      '1': begin {be REESE om hj„lp med ink”pen}
        if config.classic then
        begin

        end else
        begin
          {NEW GameMode}
          crlf;
          sd(global_talkcol, 'Hey! I need some help over here!');
          sd(config.textcolor, ', you shout to ');
          sd(global_plycol, reese^);
          d(config.textcolor, '.');

          sd(global_talkcol, 'Ok. Let''s see how much ' + config.moneytype + ' you got');
          sd(config.textcolor, ', ');
          sd(global_plycol, reese^);
          d(config.textcolor, ' says.');

          pause;
          crlf;
          if player.gold = 0 then
          begin
            sd(config.textcolor, 'You show ');
            sd(global_plycol, reese^);
            d(config.textcolor, ' your empty purse.');

            sd(global_talkcol, 'Is this supposed to be funny?');
            sd(config.textcolor, ', ');
            sd(global_plycol, reese^);
            d(config.textcolor, ' says with a strange voice.');
          end else if player.gold < 50 then
          begin
            d(config.textcolor, 'You show ' + reese^ + ' your ' + config.moneytype + ' ' + config.moneytype3 + '.');
            sd(global_talkcol, 'You won''t get anything for that!');
            sd(config.textcolor, ', ');
            sd(global_plycol, reese^);
            d(config.textcolor, ' says in a mocking tone.');
          end else
          begin
            needs := 0;

            head_need := False;
            body_need := False;
            arms_need := False;
            legs_need := False;
            feet_need := False;
            face_need := False;
            shield_need := False;
            hands_need := False;
            abody_need := False;

          {1 : s:='Allow Hand Equipment';
           2 : s:='Allow Head Equipment';
           3 : s:='Allow Body Equipment';
           4 : s:='Allow Arm Equipment';
           5 : s:='Allow Left Finger Equipment';
           6 : s:='Allow Right Finger Equipment';
           7 : s:='Allow Leg Equipment';
           8 : s:='Allow Feet Equipment';
           9 : s:='Allow Waist Equipment';
           10: s:='Allow 1 Neck Equipment';
           11: s:='Allow 2 Neck Equipment';
           12: s:='Allow Face Equipment';
           13: s:='Allow Shield';
           14: s:='Allow Around Body Equipment';
           15: s:='Allow Secondary Weapon';
          }

            if (player.head = 0) and (config.allowitem[2]) then
            begin
              Inc(needs);
              head_need := True;
            end;
            if (player.body = 0) and (config.allowitem[3]) then
            begin
              Inc(needs);
              body_need := True;
            end;
            if (player.arms = 0) and (config.allowitem[4]) then
            begin
              Inc(needs);
              arms_need := True;
            end;
            if (player.legs = 0) and (config.allowitem[7]) then
            begin
              Inc(needs);
              legs_need := True;
            end;
            if (player.feet = 0) and (config.allowitem[8]) then
            begin
              Inc(needs);
              feet_need := True;
            end;
            if (player.face = 0) and (config.allowitem[12]) then
            begin
              Inc(needs);
              face_need := True;
            end;
            if (player.shield = 0) and (config.allowitem[13]) then
            begin
              Inc(needs);
              shield_need := True;
            end;
            if (player.hands = 0) and (config.allowitem[1]) then
            begin
              Inc(needs);
              hands_need := True;
            end;
            if (player.abody = 0) and (config.allowitem[14]) then
            begin
              Inc(needs);
              abody_need := True;
            end;

            crlf;
            if needs = 0 then
            begin
              sd(global_talkcol, 'You are already fully equipped!');
              sd(config.textcolor, ', ');
              sd(global_plycol, reese^);
              d(config.textcolor, ' says.');
            end else
            begin

              xx := player.gold div needs;
              if xx < 300 then
              begin {bort prioritera vissa equipment saker}
              end;

              bought := 0;
              {b”rja plocka ihop grejor}
              if abody_need then purchase_help(abody, xx);
              if hands_need then purchase_help(hands, xx);
              if shield_need then purchase_help(shield, xx);
              if face_need then purchase_help(face, xx);
              if feet_need then purchase_help(feet, xx);
              if legs_need then purchase_help(legs, xx);
              if arms_need then purchase_help(arms, xx);
              if body_need then purchase_help(body, xx);
              if head_need then purchase_help(head, xx);

              if bought > 0 then
              begin
                crlf;
                sd(global_talkcol, 'A pleasure doing business with you!');
                sd(config.textcolor, ', ');
                sd(global_plycol, reese^);
                d(config.textcolor, ' smiles.');
              end else
              begin
                crlf;
                sd(global_talkcol, 'Too bad we couldn''t find anything suitable.');
                sd(config.textcolor, ', ');
                sd(global_plycol, reese^);
                d(config.textcolor, ' says.');
              end;

            end;
          end;

        end;
      end;
      'L': begin
        if config.classic then
        begin
          crlf;
          d(5, 'Ancient Armors                 Price');
          cc := 1;

          for i := 1 to fs(FsArmorClassic) do
          begin
            load_armor(i, aarmor);

            {#}
            sd(3, ljust(commastr(i), 4));

            {name}
            s := aarmor.Name + config.textcol1;
            repeat
              s := s + '.';
            until length(s) > 22;
            sd(global_itemcol, s);

            {price}
            s := uyellow + commastr(aarmor.Value);
            repeat
              s := '.' + s;
            until length(s) >= 15;

            sd(config.textcolor, rjust(s, 15));

            crlf;
            Inc(cc);
            if cc > global_screenlines - 2 then
            begin
              cc := 0;
              if confirm('Continue', 'Y') = False then
              begin
                break;
              end;
            end;
          end;
        end;

      end;
      'S': begin
        if config.classic then
        begin
          crlf;
          if player.armor = 0 then
          begin
            d(global_talkcol, 'You don''t have anything to sell!');
          end else
          begin
            load_armor(player.armor, inarm^);
            xx := inarm^.Value div 2;
            sd(global_plycol, reese^);
            d(config.textcolor, ' declares that he will pay you ');
            sd(14, commastr(xx));
            sd(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + ' for your ');
            d(global_itemcol, inarm^.Name);

            if confirm('Will you sell it ', 'N') = True then
            begin
              sd(config.textcolor, 'You give ');
              sd(global_plycol, reese^);
              d(config.textcolor, ' your armor, and receive the ' + config.moneytype + '.');

              incplayermoney(player, xx);
              player.armor := 0;
              player.apow := 0;
            end;
          end;
        end else
        begin
          crlf;
          crlf;
          if confirm('Sell ALL armor in your inventory', 'N') = True then
          begin
            counter := 0;
            for i := 1 to global_maxitem do
            begin
              if player.item[i] > 0 then
              begin
                load_objekt(objekt^, player.itemtype[i], player.item[i]);
                if objekt^.ttype in [Head, Body, Arms, Hands, Legs, Feet,
                  Face, Shield, Abody] then
                begin
                  if objekt^.Value > 1 then
                  begin
                    xx := objekt^.Value div 2;
                  end else
                  begin
                    xx := objekt^.Value;
                  end;
                  {time to sell}
                  if xx <= 0 then
                  begin
                    sd(global_itemcol, objekt^.Name);
                    sd(global_talkcol, ' is worthless!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, reese^);
                    sd(config.textcolor, ' says.');
                  end else if objekt^.cursed = True then
                  begin
                    sd(global_itemcol, objekt^.Name);
                    d(global_talkcol, ' is cursed!');
                    sd(global_talkcol, 'I don''t buy cursed items!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, reese^);
                    sd(config.textcolor, ' says.');
                  end else
                  begin
                    sd(global_plycol, reese^);
                    sd(config.textcolor, ' bought the ');
                    sd(global_itemcol, objekt^.Name);
                    sd(config.textcolor, ' for ');
                    sd(14, commastr(xx));
                    d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + '.');

                    incplayermoney(player, xx);
                    player.item[i] := 0;
                    Inc(counter);
                  end;

                end;
              end;
            end;
            if counter = 0 then
            begin
              sd(global_plycol, reese^);
              d(config.textcolor, ' looks at your empty ' + backpack);
              d(global_talkcol, ' You have nothing to sell!');
            end;

          end else
          begin
            repeat
              crlf;
              i := item_select(player);
              if i > 0 then
              begin
                load_objekt(objekt^, player.itemtype[i], player.item[i]);
                if objekt^.ttype in [Head, Body, Arms, Hands, Legs, Feet,
                  Face, Shield, Abody] then
                begin
                  if objekt^.Value > 1 then
                  begin
                    xx := objekt^.Value div 2;
                  end else
                  begin
                    xx := objekt^.Value;
                  end;

                  if xx <= 0 then
                  begin
                    sd(global_talkcol, 'That item is worthless!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, reese^);
                    d(config.textcolor, ' says.');
                  end else if objekt^.cursed = True then
                  begin
                    sd(global_talkcol, 'I don''t buy cursed items!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, reese^);
                    d(config.textcolor, ' says.');
                  end else
                  begin
                    sd(global_plycol, reese^);
                    sd(config.textcolor, ' declares that he will give you ');
                    sd(14, commastr(xx));

                    sd(config.textcolor, ' ' + many_money(xx));

                    sd(config.textcolor, ' for your ');
                    d(global_itemcol, objekt^.Name + '.');

                    menu2('(A)gree  ');
                    menu2('(N)o Deal');
                    sd(config.textcolor, ':');
                    repeat
                      ch := upcase(getchar);
                    until ch in ['A', 'N'];

                    crlf;
                    case ch of
                      'N': begin
                        sd(global_talkcol, 'NO!? What the heck are you up to?, ');
                        sd(global_plycol, reese^);
                        d(config.textcolor, ' asks.');
                      end;
                      'A': begin
                        d(14, 'Deal!');
                        player.item[i] := 0;
                        incplayermoney(player, xx);
                      end;
                    end;
                  end;
                end else
                begin
                  sd(global_talkcol, 'I don''t buy that kind of items');
                  sd(config.textcolor, ', ');
                  sd(global_plycol, reese^);
                  d(config.textcolor, ' says.');
                  crlf;
                  pause;
                end;
              end;
            until i = 0;
          end;
        end;
      end;

      'B': begin {buy .start.}
        if config.classic then
        begin
          crlf;
          if player.armor <> 0 then
          begin
            d(global_talkcol, 'Get rid of your old armor first!.');
            pause;
          end else
          begin
            d(global_talkcol, 'Which one?');
            sd(config.textcolor, ':');

            x := fs(FsArmorClassic);
            zz := get_number(0, 65000);
            if (zz > 0) and (zz <= x) then
            begin
              load_armor(zz, aarmor);

              sd(config.textcolor, 'So you want a ');
              d(global_itemcol, aarmor.Name);

              crlf;
              sd(config.textcolor, 'It will cost you ');
              sd(14, commastr(aarmor.Value));
              d(config.textcolor, ' in ' + config.moneytype + '.');

              sd(config.textcolor, 'Pay ? ');
              menu2('(Y)es, ');
              menu2('[N]o, ');
              menu('(H)aggle');
              sd(config.textcolor, ':');
              repeat
                ch := upcase(getchar);
              until ch in ['Y', 'N', 'H', ReturnKey];

              if ch = ReturnKey then
              begin
                ch := 'N';
              end;

              case ch of

                'H': begin
                  x := haggle('A', aarmor.Value, reese^);

                  if x < aarmor.Value then
                  begin
                    if player.gold < x then
                    begin
                      sd(global_talkcol, 'No ' + config.moneytype + ', no armor!');
                      sd(config.textcolor, ', ');
                      sd(global_plycol, reese^);
                      d(config.textcolor, ' yells.');
                      pause;
                    end else
                    begin
                      sd(global_plycol, reese^);
                      d(config.textcolor, ' gives you the armor.');
                      d(config.textcolor, 'You give him the ' + config.moneytype + '.');
                      decplayermoney(player, x);
                      player.armor := zz;
                      player.apow := aarmor.pow;

                      note_it(aarmor.Name);

                      pause;
                    end;
                  end;
                end;
                'N': begin
                  d(15, 'No');
                end;
                'Y': begin
                  d(15, 'Yes');
                  crlf;
                  if player.gold < aarmor.Value then
                  begin
                    sd(global_talkcol, 'No ' + config.moneytype + ', no armor!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, reese^);
                    d(config.textcolor, ' yells.');
                    pause;
                  end else
                  begin
                    sd(global_talkcol, 'Deal!');
                    sd(config.textcolor, ', says ');
                    sd(global_plycol, reese^);
                    d(config.textcolor, ' and gives you the armor.');

                    d(config.textcolor, 'You hand over the ' + config.moneytype + '.');

                    decplayermoney(player, aarmor.Value);
                    player.armor := zz;
                    player.apow := aarmor.pow;

                    note_it(aarmor.Name);

                    pause;
                  end;
                end;
              end;
              ch := ' ';

            end;
          end;
        end else
        begin
          crlf;
          d(3, 'Enter Item # to buy');
          sd(config.textcolor, ':');

          s := get_string(10);

          if s = '?' then
          begin
            d(15, 'List of armors :');
            case soktyp of {komih†g}
              Head: komihag := 'H';
              Body: komihag := 'O';
              Arms: komihag := 'A';
              Hands: komihag := 'N';
              Legs: komihag := 'L';
              Feet: komihag := 'F';
              Face: komihag := 'E';
              Abody: komihag := 'C';
              Shield: komihag := 'I';
            end;
          end;

          x := str_to_nr(s);
          j := 0;

          if (x > 0) and (x <= fsob(soktyp)) then
          begin
            for i := 1 to fsob(soktyp) do
            begin
              load_objekt(objekt^, soktyp, i);
              if objekt^.shop = True then
              begin
                Inc(j, 1);
              end;
              if j = x then
              begin

                if (objekt^.good) and (player.chiv < 1) and (player.dark > 0) then
                begin
                  d(12, 'This item is charmed for good characters.');
                  d(12, 'You can buy it, but you not use it!');
                end else if (objekt^.evil = True) and (player.chiv > 0) and (player.dark < 1) then
                begin
                  d(12, 'This item is enchanted and can be used by evil characters only.');
                  d(12, 'You can buy it, but not use it!');
                end;

                if objekt^.str_need > player.strength then
                begin
                  d(12, 'This item is too heavy for you to use!');
                end;

                sd(config.textcolor, 'Buy the ');
                sd(global_itemcol, objekt^.Name);
                sd(config.textcolor, ' for ');
                sd(14, commastr(objekt^.Value));
                sd(config.textcolor, ' ' + config.moneytype);
                sd(config.textcolor, ' (Y/[N] or (H)aggle) ?');
                repeat
                  cho := upcase(getchar);
                until cho in ['Y', 'N', 'H', ReturnKey];

                crlf;



                if cho = 'H' then
                begin
                  x := haggle('A', objekt^.Value, reese^);
                  if x < objekt^.Value then
                  begin
                    if player.gold < x then
                    begin
                      You_Cant_Afford_It;
                    end else
                    begin
                      if inventory_empty(player) = 0 then
                      begin
                        d(config.textcolor, 'Your inventory is full!');
                        if confirm('Drop something ', 'Y') = True then
                        begin
                          drop_item(player);
                        end;
                      end;

                      if inventory_empty(player) > 0 then
                      begin
                        j := inventory_empty(player);
                        d(14, 'Done!');
                        decplayermoney(player, x);
                        player.item[j] := i;
                        player.itemtype[j] := objekt^.ttype;

                        note_it(objekt^.Name);

                        crlf;
                        sd(config.textcolor, 'Start to use the ');
                        sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                        sd(config.textcolor, ' immediately');
                        if confirm('', 'Y') = True then
                        begin
                          use_item(j);
                        end else
                        begin
                          sd(config.textcolor, 'You put the ');
                          sd(global_itemcol, objekt^.Name);
                          d(config.textcolor, ' in your ' + backpack);
                        end;
                      end;
                    end;
                  end;
                end;

                if cho = 'Y' then
                begin
                  if player.gold < objekt^.Value then
                  begin
                    You_Cant_Afford_It;
                  end else
                  begin
                    if inventory_empty(player) = 0 then
                    begin
                      d(config.textcolor, 'Your inventory is full!');
                      if confirm('Drop something ', 'Y') = True then
                      begin
                        drop_item(player);
                      end;
                    end;

                    if inventory_empty(player) > 0 then
                    begin
                      j := inventory_empty(player);
                      d(14, 'Done!');
                      sd(config.textcolor, 'You give ');
                      sd(global_plycol, reese^ + ' ');
                      sd(14, commastr(objekt^.Value));
                      d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3);
                      decplayermoney(player, objekt^.Value);
                      player.item[j] := i;
                      player.itemtype[j] := objekt^.ttype;

                      note_it(objekt^.Name);

                      crlf;
                      sd(config.textcolor, 'Start to use the ');
                      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                      sd(config.textcolor, ' immediately');
                      if confirm('', 'Y') = True then
                      begin
                        use_item(j);
                      end else
                      begin
                        sd(config.textcolor, 'You put the ');
                        sd(global_itemcol, objekt^.Name);
                        d(config.textcolor, ' in your ' + backpack);
                      end;
                    end;
                  end;
                end;
                break;
              end;
            end;
          end;
        end;
      end; {buy .end.}

      'R': begin
        crlf;
        leave_place := True;
      end;

    end; {case .end.}

  until leave_place = True;

  {dispose pointer variables}
  dispose(objekt);
  dispose(reese);
  dispose(inarm);

end; {Armor_Shop *end*}

end. {Unit Armshop .end.}
