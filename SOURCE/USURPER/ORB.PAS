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



unit Orb;  {Usurper - Orbs Bar, "drinks are served here around the clock!"}

interface

uses
  Init;

const

  {Number of ingredients used. "snake spit", "bobs bomber" ... etc etc.}
  MaxIngredients = 17;

 {Ingredients to use when mixing own drinks
  notice that these names are also used in the editor project!
  so don't forget to change the names there when you edit these names.}
  ing: array [1..MaxIngredients] of string[15] = (
    'Bat Brain',
    'Honeydew',
    'Orange Juice',
    'Tabasco',
    'Ale',
    'Hedgehog Saliva',
    'Water',
    'Horse Blood',
    'Bobs Bomber',
    'Troll Rum',
    'Elf Water',
    'Kicking Squaw',
    'Milk',
    'Wine-vinegar',
    'Snake Spit',
    'Duck Dropping',
    'Chilipeppar');

type AmountRec = record
    amount: array [1..maxingredients] of smallint;
  end;

type DrinkTypes = (OwnDrink, FileDrink, MailDrink, NpcDrink);

                  {OwnDrink = player creates & drinks his own drink
                   FileDrink = player gets a drink from the database
                   MailDrink = player enjoys a free drink sent from another player
                   NpcDrink = player buys NPC player a drink}

procedure Drink_a_drink(var Drinker: UserRec; KindofDrink: DrinkTypes; const cocktail: drinkrec;
  var InAmount: amountRec; RecNr: word);
{drinks}
function Old_Drink(const adrink: drinkrec): boolean; {is drink record old}

procedure Orb_Center;

implementation

uses
  File_Io, Jakob, Cms,
  Various, Various2, Various3,
  Statusc, Mail, Relation,
  News, Online;

const
  drink_col      = 9;     {color used when displaying drink names}
  bartender: s40 = 'Sly'; {the bartender}


var refresh: boolean;
  TheAmount: AmountRec;

function Old_Drink(const adrink: drinkrec): boolean; {is drink record old}
var
  r: boolean;

  tempdat1, tempdat2: Udate;

begin

  {set date}
  tempdat1 := fix_date(todays_date);
  tempdat2 := fix_date(adrink.lastdat);

 { debugging info...
 d(15,'This drink is :'+commastr(days_between(tempdat1,tempdat2))+' days old');
 }

  if (days_between(tempdat1, tempdat2) > config.maxdrinkds) and
    (config.maxdrinkds > 0) then
  begin
    r := True; {this drink is old!}
  end else
  begin
    r := False; {this drink is NOT old}
  end;

  {return result}
  old_drink := r;

end; {old_drink *end*}

procedure Meny;
const offset = 20;
begin

  clearscreen;
  crlf;
  d(5, 'Welcome to Orbs Bar & Recreation Center!');
  crlf;
  d(config.textcolor, 'The sign on the doorpost is quite clear regarding the');
  d(config.textcolor, 'matter of risks involved with drinking the different');
  d(config.textcolor, 'liquids in this place.');
  d(config.textcolor, 'Orchids and herbs, all in different mixtures and blendings.');
  d(config.textcolor, 'You can choose between the regular drinks and your own');
  d(config.textcolor, '"on the spot made" recipes.');
  crlf;

  menu2(ljust('(O)rder a drink', offset));
  menu2(ljust('(H)ouse Specials', offset + 7));
  menu('(P)opular drinks');

  menu2(ljust('(S)tatus', offset));
  menu('(B)uy your friend (or enemy) a drink');
  menu('(R)eturn');

end; {meny *end*}

procedure Display_Menu(force, short: boolean);
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
      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'Orbs Bar (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin
      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'Orbs (O,H,P,B,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

function Empty_DrinkSlot: longint;
var q, i: longint;
  ADrink: DrinkRec;
  found:  boolean;
begin

  {find deleted record in drinkfile}

  found := False;
  empty_drinkslot := 1;

  for q := 1 to fs(FsDrink) do
  begin
    load_drink(Fload, adrink, q);

    {checking if drink is old and can be discarded}
    if adrink.deleted = False then
    begin

      if old_drink(adrink) then
      begin
        adrink.deleted := True;

        load_drink(fsave, adrink, q);

      end;

    end;

    {is drink deleted}
    if adrink.deleted = True then
    begin
      empty_drinkslot := q;
      found := True;
      break;
    end;

  end; {for q:= .end.}

       {no empty drink-slot found, we place the drink at the end of file}
  if not found then
  begin
  {have to check if file has more than the allowed # of drinks specified
   by Sysop}
    i := fs(FsDrink);
    if i >= config.maxdrinks then
    begin
      empty_drinkslot := 0; {sorry! no new drinks allowed}
    end else
    begin
      empty_drinkslot := fs(FsDrink) + 1;
    end;
  end;

end; {EMPTY DRINKSLOT *END*}

procedure Add_Drink;
{add own special made drink to list}

var
  drink:  DrinkRec;

  Name, comment: s70;

  i:      longint;

  secret: boolean;

begin
  crlf;
  sd(config.textcolor, 'You are so impressed by your cocktail that you ask ');
  sd(global_plycol, bartender);
  d(config.textcolor, ',');

  sd(config.textcolor, 'the Bartender');
  d(config.textcolor, ' to put up your new invention on the drink-list.');
  crlf;
  pause;

  {is the list full?}
  if empty_drinkslot = 0 then
  begin
    sd(global_plycol, bartender);
    sd(config.textcolor, ' looks at you;');
    d(global_talkcol, 'Sorry, but we have no room for more Drinks at the moment.');
    crlf;
    d(config.textcolor, 'Disappointed, you leave the counter. You were absolutely sure that this');
    d(config.textcolor, 'Cocktail of yours was bound to be a success...');
    pause;
    exit;
  end;

  {name drink}
  d(15, 'New Cocktail');
  d(config.textcolor, 'What name shall the Drink have? (max 30 chars)');
  sd(config.textcolor, ':');
  Name := get_string(30);

  if Name = '' then
  begin
    d(12, 'Aborted!');
    exit;
  end;

  {comment}
  comment := emptystr;
  if confirm('Add a Comment', 'Y') = True then
  begin
    sd(config.textcolor, ':');
    comment := get_string(70);
  end;

  {secret}
  if confirm('Keep the recipe a secret', 'N') = True then
  begin
    secret := True;
  end else
  begin
    secret := False;
  end;

  {setup drink record}
  drink.Name := Name; {the drink}
  drink.creator := player.name2; {creator}
  drink.date := todays_date; {8-string date, american style}
  drink.comment := comment;
  drink.ordered := 0;
  drink.lasthad := emptystr;
  drink.lastrac := Human; {last race that had the drink (see above lasthad)}
  drink.lastdat := todays_date;
  drink.deleted := False;
  drink.secret := secret;

  {ingredients}
  for i := 1 to maxingredients do
  begin
    drink.amount[i] := TheAmount.amount[i];
  end;

  if empty_drinkslot = 0 then
  begin
    d(12, 'Unable to save your drink!');
  end else
  begin

    d(15, 'Your Drink has been added to the Bartenders list!');

    {save new drink}
    load_drink(Fsave, drink, empty_drinkslot);

    {inform other nodes}
    online_send_to_all(uplc + player.name2 + config.textcol1 + ' invented a new COCKTAIL!', player.name2, '');

    {news-paper}
    Newsy(True,
      'New Cocktail',
      ' ' + uplc + player.name2 + config.textcol1 + ' invented a new Cocktail at Orbs Bar.',
      ' The drink is called ' + udrinkc + drink.Name + config.textcol1 + '.',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

  end;

end; {ADD_DRINK *END*}

procedure Drink_Top_List;
const max_sort = 50; {max drinks to read and sort in memory}
var

  ordered:    array [1..max_sort] of ^longint;
  Name:       array [1..max_sort] of ^s70;

  found:      boolean;

  Lines:      byte;

  i, counter: word;

  s:          s70;

  TempDrink:  DrinkRec;

  procedure Sort_Drinks;
  var
    k, gap: integer;
    j, xx:  longint;
    cr:     byte;
    i:      word;
  begin

    cr := 0;

    for i := 1 to fs(FsDrink) do
    begin

      load_drink(Fload, tempdrink, i);

      found := False;
      if (tempdrink.Name <> '') and
        (old_drink(tempdrink) = False) and
        (tempdrink.deleted = False) then
      begin

        {is this drink already in the list?}
        if cr > 0 then
        begin
          for j := 1 to cr do
          begin
            if Name[j]^ = tempdrink.Name then
            begin
              ordered[j]^ := ordered[j]^ + tempdrink.ordered;
              found := True;
              break;
            end;
          end;
        end;

        if (found = False) and (cr + 1 <= max_sort) then
        begin
          Inc(cr);
          ordered[cr]^ := tempdrink.ordered;
          Name[cr]^ := tempdrink.Name;
        end;
      end;

    end; {for i:= .end.}

    gap := max_sort div 2;
    while gap > 0 do
    begin
      for i := (gap + 1) to max_sort do
      begin
        j := i - gap;
        while (j > 0) do
        begin
          k := j + gap;
          if ordered[j]^ >= ordered[k]^ then
          begin
            j := 0;
          end else
          begin
            xx := ordered[j]^;
            s := Name[j]^;

            ordered[j]^ := ordered[k]^;
            Name[j]^ := Name[k]^;

            ordered[k]^ := xx;
            Name[k]^ := s;

            j := j - gap;
          end;
        end; {while .end.}
      end;   {for i:= .end.}
      gap := gap div 2;
    end; {while .end.}

  end; {sort_drinks *end*}

begin

  {top [ten] list of most popular drinks}

  {init}
  for i := 1 to max_sort do
  begin
    new(ordered[i]);
    ordered[i]^ := 0;

    new(Name[i]);
    Name[i]^ := emptystr;
  end; {for i:= .end.}

  found := False;

  {are there any drinks to display?}
  if f_exists(global_drinkfile) then
  begin
    for i := 1 to fs(fsdrink) do
    begin
      load_drink(fload, tempdrink, i);

      if (tempdrink.deleted = False) and (old_drink(tempdrink) = False) then
      begin
        found := True;
        break;
      end;

    end; {for i:= .end.}
  end;

  if found then
  begin
    crlf;
    crlf;

    {top list header}
    s := '  -*-Popular Cocktails-*-';
    d(11, s);
    sd(5, mkstring(length(s) + 9, underscore));
    d(7, '   (times ordered)');
    sort_drinks;
    {display sorted list}
    counter := 1;
    Lines := 2;
    for i := 1 to max_sort do
    begin
      if Name[i]^ <> '' then
      begin

        {#}
   { s:=commastr(counter);
    case length(s) of
     1: s:=s+'   ';
     2: s:=s+'  ';
     3: s:=s+' ';
    end;
    sd(7,s);

    {name}
        sd(drink_col, rjust(Name[i]^, 30));
        {times ordered}
        sd(11, '  ' + commastr(ordered[i]^));
        crlf;
        {inc counter}
        Inc(counter);
        {pause}
        Inc(Lines);
        if Lines > global_screenlines - 2 then
        begin
          Lines := 0;
          if confirm('Continue', 'Y') = False then
          begin
            break;
          end;
        end;

      end;
    end; {for i:= .end.}

  end;

  {dispose pointer variables}
  for i := 1 to max_sort do
  begin
    dispose(ordered[i]);
    dispose(Name[i]);
  end;

end; {drink_top_list *end*}

procedure Drink_a_drink(var Drinker: UserRec; KindofDrink: DrinkTypes; const cocktail: drinkrec;
  var InAmount: amountRec; RecNr: word);
{Custom-Made Drink, either from File or own mix}
var
  i:         word;
  s:         s70;

  killed:    boolean;

  stamina, agility, charisma, dexterity, wisdom, strength, defence, darkness, chivalry: integer;

  tempdrink: DrinkRec;

begin

 {this procedure is either called from 1.the routine where a player makes
  his own drink, or its called from the 2.ORDER CUSTOM DRINK (from file)
  it can also be called from 3.the mail.pas when a drink has been sent
  from another player. It can also be called from 4.'b'uying a drink to
  a Npc character. RecNr holds # in database where drink is stored}

  if KindOfDrink in [FileDrink, MailDrink, NpcDrink] then
  begin
    {convert record info with ingredients to in-game array}
    for i := 1 to maxingredients do
    begin
      InAmount.amount[i] := cocktail.amount[i];
    end; {for i:= .end.}
  end;

  {reset reward values}
  stamina := 0;
  agility := 0;
  charisma := 0;
  dexterity := 0;
  wisdom := 0;
  strength := 0;
  defence := 0;
  darkness := 0;
  chivalry := 0;

  {"Glugg" text!}
  crlf;
  sd(config.textcolor, 'Glugg...');
  delay2(800);
  sd(config.textcolor, 'Glugg...');
  delay2(800);
  sd(config.textcolor, 'Glugg...');
  delay2(800);
  d(config.textcolor, 'Glugg...!');
  pause;
  crlf;

  if KindOfDrink <> NpcDrink then
  begin
    for i := 1 to maxingredients do
    begin
      if InAmount.amount[i] > 0 then
      begin
        case InAmount.amount[i] of
          0..10: d(global_talkcol, 'Ahh..a little bit of ' + ing[i] + '!');
          11..25: d(global_talkcol, 'A slight touch of ' + ing[i] + '!');
          26..50: d(global_talkcol, 'That extra taste of ' + ing[i] + '!');
          51..75: d(global_talkcol, 'Quite some taste of ' + ing[i] + '!');
          76..90: d(global_talkcol, 'That delightful taste of ' + ing[i] + '!');
          91..100: d(global_talkcol, 'Holy Smokes!!! Thats alot of ' + ing[i] + '!');
        end; {case .end.}
      end;
    end;     {for i:= .end.}
  end;

  if KindOfDrink in [OwnDrink, FileDrink] then
  begin
    crlf;
    d(config.textcolor, 'You put the empty cup on the bardisk...');
    delay2(1000);
    sd(config.textcolor, 'You look at ');
    sd(global_plycol, bartender);
    d(config.textcolor, ', the Bartender...');
    delay2(1000);
    sd(global_plycol, bartender);
    d(config.textcolor, ' looks at you...');
    delay2(1000);
  end else
  if KindOfDrink = NpcDrink then
  begin
    crlf;
    d(global_plycol, drinker.name2 + config.textcol1 + ' puts the empty cup on the bardisk...');
    delay2(1000);
    sd(global_plycol, drinker.name2 + config.textcol1 + ' looks at ');
    sd(global_plycol, bartender);
    d(config.textcolor, ', the Bartender...');
    delay2(1000);
    sd(global_plycol, drinker.name2 + config.textcol1 + ' looks at ');
    d(config.textcolor, 'You...');
    delay2(1000);

    sd(global_plycol, bartender);
    d(config.textcolor, ' and You look at ' + uplc + drinker.name2 + config.textcol1 + '...');
    delay2(1000);
  end else
  if KindOfDrink = MailDrink then
  begin
    {MailDrink}
    crlf;
    d(config.textcolor, 'You put down the empty cup...');
    delay2(1000);
    d(config.textcolor, 'You look at the people around you...');
    delay2(1000);
    d(config.textcolor, 'the people look back at you...');
    delay2(1000);
  end;

  if KindofDrink = NpcDrink then
  begin
    crlf;
    d(global_plycol, drinker.name2 + config.textcol1 + ' tries to establish how ' + sex2[drinker.sex] + ' feels...');
  end else
  begin
    crlf;
    d(config.textcolor, 'You try to establish how you feel...');
  end;

  crlf;
  delay2(800);

 {stuff that are directkillers :
 1. troll drink Elf water
 2. elves drink Troll rum
 3. somebody drinks over 80% tabasco
 4. somebody drinks over 80% Chilipeppar
 5. somebody drinks over 70% Bat brain
 6. somebody drinks over 90% horse blood
 7. somebody drinks over 90% Bobs bomber
 8. somebody drinks over 80% snake spit
 }
  killed := False;

  if (InAmount.amount[10] > 0) and (drinker.class = Assassin) then
    killed := True;

  {Elf Water}
  if InAmount.amount[11] > 0 then
  begin
    if (drinker.class = Cleric) or
      (drinker.class = Jester) or
      (drinker.race = Troll) then
      killed := True;
  end;

  if InAmount.amount[4] >= 80 then
    killed := True;
  if InAmount.amount[17] >= 80 then
    killed := True;
  if InAmount.amount[1] >= 70 then
    killed := True;
  if InAmount.amount[8] >= 90 then
    killed := True;
  if InAmount.amount[9] >= 90 then
    killed := True;
  if InAmount.amount[15] >= 80 then
    killed := True;

  for i := 1 to maxingredients do
  begin
    if InAmount.amount[i] > 0 then
    begin
      case InAmount.amount[i] of
        0..10: begin
          stamina := stamina + random(2);
          charisma := charisma + random(2);
          defence := defence + random(2);
        end;
        11..25: begin
          agility := agility + random(2);
          dexterity := dexterity + random(2);
          wisdom := wisdom + random(2);
          strength := strength + random(2);
        end;
        26..50: begin
          stamina := stamina + random(2);
          darkness := darkness + random(150);
        end;
        51..75: begin
          stamina := stamina + random(2);
          wisdom := wisdom + random(2);
          strength := strength + random(2);
          defence := defence + random(2);
        end;
        76..90: begin
          agility := agility + random(2);
          charisma := charisma + random(2);
          dexterity := dexterity + random(2);
          wisdom := wisdom + random(2);
          defence := defence + random(2);
          darkness := darkness + random(2);
          chivalry := chivalry + random(2);
        end;
        91..100: begin
          stamina := stamina + random(2);
          charisma := charisma + random(3);
          wisdom := wisdom + random(3);
        end;

      end; {case .end.}
    end;
  end;     {for i:= .end.}


  if (KindOfDrink <> OwnDrink) and (recnr > 0) then
  begin
    {update statistics for this drink}
    load_drink(fload, tempdrink, recnr);

    Inc(tempdrink.ordered);
    tempdrink.lasthad := drinker.name2;
    tempdrink.lastrac := drinker.race;
    tempdrink.lastdat := todays_date;

    {save drink}
    load_drink(fsave, tempdrink, recnr);
  end;

  pause;
  if killed = True then
  begin

    {worsen pl0:s attitude to player}
    Update_Relation(Relation_Worsen, 2, drinker, player, False, False);

    if KindofDrink = NpcDrink then
    begin
      d(12, drinker.name2 + ' is not feeling very well!');
      d(12, drinker.name2 + ' is DEAD!');
    end else
    begin
      d(12, 'You are not feeling very well! Arrgghhhh...!!!');
    end;

    {the dead drinker may not enter again}

    {drinker.allowed:=false;}
    reduce_player_resurrections(drinker, False);

    drinker.hps := 0;

    {Bad Drink Experience}
    case KindofDrink of
      OwnDrink: begin
        {news-paper}
        newsy(True,
          'Cocktail Death!',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' suffered a horrible death after drinking',
          ' ' + sex3[drinker.sex] + ' own Special-Made drink...',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
      FileDrink: begin
        {news-paper}
        newsy(True,
          'Drinking Death',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' died after having the special Cocktail; ' +
          udrinkc + cocktail.Name + config.textcol1 + '.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
      MailDrink: begin
        {news-paper}
        newsy(True,
          'Free Drink proves Fatal',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' died after having the special Cocktail; ' +
          udrinkc + cocktail.Name + config.textcol1 + '.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
      NpcDrink: begin
        {news-paper}
        newsy(True,
          'Free Drink proves Fatal',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' died after having the special Cocktail; ' +
          udrinkc + cocktail.Name + config.textcol1 + '.',
          ' The deathbringer who served the drink was ' + uplc + player.name2 + config.textcol1 + '.',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;

    end; {case KindofaDrink .end.}

    crlf;

    if KindOfDrink in [OwnDrink, FileDrink] then
    begin
      d(config.textcolor, 'You slide down from the BarStool...');
    end else
    if KindofDrink = MailDrink then
    begin
      d(config.textcolor, 'You feel extremely intoxicated...');
    end else
    if KindOfDrink = NpcDrink then
    begin
      d(global_plycol, drinker.name2 + config.textcol1 + ' slides down from the BarStool...');
    end;

    show_usurper_data(picture_death_head, False);
    d(config.textcolor, 'Darkness...');
    pause;

    if KindofDrink <> NpcDrink then
    begin
      normal_exit;
    end;

  end else
  begin

    if KindofDrink = NpcDrink then
    begin
      sd(config.textcolor, 'Some of ');
      d(global_plycol, drinker.name2 + 's' + config.textcol1 + ' abilities raised!');
    end else
    begin
      d(14, 'AWESOME!');

      {stamina}
      if stamina > 0 then
      begin
        sd(config.textcolor, 'Your Stamina raised by ');
        d(14, commastr(stamina));
      end;

      {agility}
      if agility > 0 then
      begin
        sd(config.textcolor, 'Your Agility raised by ');
        d(14, commastr(agility));
      end;

      {charisma}
      if charisma > 0 then
      begin
        sd(config.textcolor, 'Your Charisma raised by ');
        d(14, commastr(charisma));
      end;

      {dexterity}
      if dexterity > 0 then
      begin
        sd(config.textcolor, 'Your Dexterity raised by ');
        d(14, commastr(dexterity));
      end;

      {wisdom}
      if wisdom > 0 then
      begin
        sd(config.textcolor, 'Your Wisdom raised by ');
        d(14, commastr(wisdom));
      end;

      {strength}
      if strength > 0 then
      begin
        sd(config.textcolor, 'Your Strength raised by ');
        d(14, commastr(strength));
      end;

      {defence}
      if defence > 0 then
      begin
        sd(config.textcolor, 'Your Defence raised by ');
        d(14, commastr(defence));
      end;

      {darkness}
      if darkness > 0 then
      begin
        sd(config.textcolor, 'Your Darkness raised by ');
        d(14, commastr(darkness));
      end;

      {chivalry}
      if chivalry > 0 then
      begin
        sd(config.textcolor, 'Your Chivalry raised by ');
        d(14, commastr(chivalry));
      end;

      {trainings}
      if random(10) = 0 then
      begin
        sd(config.textcolor, 'You also received an ');
        d(14, 'EXTRA COMBAT TRAINING');
        drinker.trains := drinker.trains + 1;
      end;
    end;

    drinker.stamina := drinker.stamina + stamina;
    drinker.agility := drinker.agility + agility;
    drinker.charisma := drinker.charisma + charisma;
    drinker.dex := drinker.dex + dexterity;
    drinker.wisdom := drinker.wisdom + wisdom;
    drinker.strength := drinker.strength + strength;
    drinker.defence := drinker.defence + defence;
    Give_Darkness(drinker, darkness);
    Give_Chivalry(drinker, chivalry);

    crlf;

    {comment to the news}
    case random(5) of
      0: s := 'This was great!';
      1: s := 'I must have another one!';
      2: s := 'This drink rocks!';
      3: s := 'My head is spinning!';
      4: s := 'I''ve had enough.';
    end; {case .end.}

         {Good Drink Experience}
    case KindofDrink of
      OwnDrink: begin
        {news-paper}
        newsy(True,
          'Cocktail Party',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' enjoyed ' + sex3[drinker.sex] + ' own Special-Made drink.',
          ' ' + utalkc + s + config.textcol1 + ': ' + uplc + drinker.name2 + config.textcol1 + ' says.',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
      FileDrink: begin
        {news-paper}
        newsy(True,
          'Special Cocktail',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' enjoyed a special Cocktail; ' + udrinkc +
          cocktail.Name + config.textcol1 + '.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
      MailDrink: begin
        {news-paper}
        newsy(True,
          'Free Drink',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' enjoyed a free drink; ' + udrinkc +
          cocktail.Name + config.textcol1 + '.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
      NpcDrink: begin
        {news-paper}
        newsy(True,
          'Drink Buddies',
          ' ' + uplc + drinker.name2 + config.textcol1 + ' enjoyed a free drink; ' + udrinkc +
          cocktail.Name + config.textcol1 + ' at Orbs.',
          ' The generous ' + race_display(2, player.race, 0) + ' ' + uplc + player.name2 +
          config.textcol1 + ' paid the bill.',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;

    end; {case kindofdrink .end.}

    if KindOfDrink = OwnDrink then
    begin
      {put this drink on the Customers Special List}
      if confirm('Would you like to put this drink on the Customers Special List', 'Y') = True then
      begin
        crlf;
        d(15, 'OK.');
        add_drink;
      end;
    end;

    pause;

  end;

end; {DRINK_A_DRINK *END*}

procedure Orb_Center; {*MAIN PROCEDURE*}
const

  owndrink_cost = 2800; {cost to make your own cocktail}

var
  ch:     char;
  drink:  array [1..9] of string[25];
  cost:   array [1..9] of word;

  sdrink, i, j: integer;
  xx, c, x: longint;
  s:      s70;

  Adrink: ^DrinkRec;
  pl0:    ^UserRec;

  function Mini_Menu(event: byte): longint;
 {event=1, user is browsing/ordering
  event=2, user is selecting a drink to send to other player
 }
    {returns -1 if listing was aborted, 0=no drink selected >0=# of drink}
  var
    ch2:       char;

    i, lookup: word;

    Result:    longint;

    v2, z8, c8, memory, realcounter: word;

    view:      boolean;

    tempdrink: drinkrec;

  begin

    {init vars}
    x := 0;
    Result := 0;

    {mini menu}
    crlf;

    case event of
      1: menu2('(O)rder  ');
      2: menu2('(S)elect  ');
    end;

    menu2('(V)iew  ');
    menu2('(A)bort  ');
    menu2('(L)ook for  ');
    menu2('[M]ore :');

    {get user-input}
    repeat

      lookup := 0;

      {get user-input}
      ch2 := upcase(getchar);

      case ch2 of
        'O': begin
          if event = 2 then
            ch2 := ' ';
        end;
        'S': begin
          if event = 1 then
            ch2 := ' ';
        end;
        'L': begin {look for drink}
          crlf;
          d(12, '*Search*');
          d(config.textcolor, 'Which drink are you looking for?');
          sd(config.textcolor, ':');
          s := get_string(20);

          lookup := 0;
          for i := 1 to fs(fsdrink) do
          begin

            if load_drink(fload, tempdrink, i) = True then
            begin

              if (findsub(s, tempdrink.Name)) and
                (tempdrink.deleted = False) then
              begin
                if confirm(udrinkc + tempdrink.Name + config.textcol1, 'N') = True then
                begin
                  lookup := i;
                  case event of
                    1: ch2 := 'O';
                    2: ch2 := 'S';
                  end;

                  break;
                end else
                begin
                  if confirm('Continue search', 'Y') = False then
                  begin
                    break;
                  end;
                end;
              end;
            end;
          end; {for i:= .end.}

        end;

      end; {case .end.}

    until ch2 in ['V', 'O', 'S', 'A', 'M', ReturnKey];

    {evaluate user-input}
    case ch2 of
      'A': begin {abort listing}
        Result := -1;
      end;
      'O', 'S': begin {Order or Select a drink}

        if (player.drinksleft < 1) and (ch2 = 'O') then
        begin
          crlf;
          d(12, 'You''ve had too much already!');
          pause;
        end else
        begin

          if lookup > 0 then
          begin
            memory := lookup;
            view := True;
          end else
          begin
            view := False;
            crlf;

            d(config.textcolor, '# to order');

            sd(config.textcolor, ':');

            {get user-input}
            v2 := get_number(0, fs(fsdrink));

            {evaluate user-input}
            if v2 > 0 then
            begin

              c8 := 0;
              realcounter := 0;
              for z8 := 1 to fs(fsdrink) do
              begin

                {load drink}
                load_drink(fload, tempdrink, z8);

                Inc(realcounter);

                if tempdrink.deleted = False then
                begin
                  Inc(c8);
                end;

                if (c8 = v2) and (tempdrink.deleted = False) then
                begin
                  memory := z8;
                  view := True;
                  break;
                end;

              end; {for z8:= .end.}
            end;
          end;

          if view = True then
          begin
            case ch2 of
              'O': sd(config.textcolor, 'Order the ');
              'S': sd(config.textcolor, 'Select the ');
            end; {case .end.}

            sd(drink_col, tempdrink.Name);

            if confirm('', 'Y') = True then
            begin
              if player.gold < owndrink_cost then
              begin
                d(12, 'You don''t have enough ' + config.moneytype + '!');
                crlf;
                view := False;
                pause;
              end else
              begin
                sd(config.textcolor, 'You pay ');
                sd(14, commastr(owndrink_cost));
                d(config.textcolor, ' ' + many_money(owndrink_cost) + ' for the drink.');
                crlf;
                decplayermoney(player, owndrink_cost);
                view := True;
              end;
            end else
            begin
              view := False;
            end;
          end else
          begin
            d(12, 'Incorrect Cocktail #');
          end;

          if (view = True) and (ch2 = 'S') then
          begin
            Result := realcounter;
          end else
          if (view) and (ch2 = 'O') then
          begin

            {bartender mixes the drink}
            sd(config.textcolor, 'Full of expectation, You watch ');
            sd(global_plycol, bartender);
            sd(config.textcolor, ' prepare your cocktail...');
            Make_Delay_Dots(2, 6, 250);
            crlf;
            d(15, 'Here goes..');

            {no more drinks}
            Dec(player.drinksleft);

            {call drink routine}
            drink_a_drink(Player, FileDrink, tempdrink, TheAmount, memory);

            {creator of drink is online, lets send him a message}
            if (tempdrink.creator <> player.name2) and
              (is_online(tempdrink.creator, online_player)) then
            begin

              online_send_to_player(tempdrink.creator, online_player, uplc + player.name2 +
                config.textcol1 + ' just ordered one of your' + ' drinks; ' + udrinkc + tempdrink.Name +
                config.textcol1 + '.');
            end else
            if tempdrink.creator <> player.name2 then
            begin

              {creator of drink is offline, lets send him a message}
              post(MailSend,
                tempdrink.creator,
                'H',
                False,
                mailrequest_nothing,
                '',
                udrinkc + 'Drinker' + config.textcol1,
                mkstring(7, underscore),
                uplc + player.name2 + config.textcol1 + ' enjoyed your drink; ' + udrinkc +
                tempdrink.Name + config.textcol1 + '.',
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

      end;       {Order or Select a drink .end.}

      'V': begin {view ingredients}
        view := False;
        crlf;

        d(config.textcolor, '# to view');
        sd(config.textcolor, ':');
        v2 := get_number(0, fs(fsdrink));

        if v2 > 0 then
        begin
          c8 := 0;
          for z8 := 1 to fs(fsdrink) do
          begin

            load_drink(fload, tempdrink, z8);

            if tempdrink.deleted = False then
            begin
              Inc(c8);
            end;

            if c8 = v2 then
            begin
              view := True;
              break;
            end;

          end; {for z8:= .end.}

          if view then
          begin
            sd(config.textcolor, 'View the ');
            sd(drink_col, tempdrink.Name);
            if confirm('', 'Y') = True then
            begin
              view := True;
            end else
            begin
              view := False;
            end;
          end else
          begin
            d(15, 'Incorrect Cocktail #');
          end;

        end;

        if view then
        begin
          if tempdrink.secret then
          begin
            {sorry, secret recipe}
            crlf;

            sd(global_plycol, bartender);
            d(config.textcolor, ', the bartender, screws up his eyes at you;');
            d(global_talkcol, 'Sorry but this cocktail has a secret recipe.');
            crlf;
            d(15, '(Damn!)');
            pause;
          end else
          begin

            {display recipe}
            crlf;
            sd(15, 'The ');
            sd(drink_col, tempdrink.Name);
            d(15, ' Cocktail contains');
            for i := 1 to maxingredients do
            begin
              if tempdrink.amount[i] > 0 then
              begin
                sd(3, ing[i]);
                d(config.textcolor, ' - ' + commastr(tempdrink.amount[i]) + '%');
              end;
            end; {for i:= .end.}

            pause;

          end;
        end;

        pause;

      end; {view ingredients .end.}
    end;   {case ch2 .end.}

           {return result}
    mini_menu := Result;

  end; {mini_menu}


  function browse_select_drinks(event: byte): longint;
 {event=1, user is browsing/ordering
  event=2, user is selecting a drink to send to other player
 }
  var i:         word;
    lasttimewasthemenu: boolean;
    menu_result: longint;

  begin

    {Update Online Location}
    if onliner.location <> onloc_orbs_browse then
    begin
      onliner.location := onloc_orbs_browse;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    crlf;
    crlf;
    d(11, 'Guest Favourite Cocktails');

    c := 0; {drink counter}
    x := 7; {pause counter}

    menu_result := 0;
    for i := 1 to fs(FsDrink) do
    begin

      {load drink}
      load_drink(fload, adrink^, i);

      if adrink^.deleted = False then
      begin

        lasttimewasthemenu := False;

        {increse counters}
        Inc(c);
        Inc(x, 7);

        {#}
        crlf;
        d(7, '[' + commastr(c) + ']');

        {cocktail}
        sd(config.textcolor, 'Cocktail : ');
        d(drink_col, adrink^.Name);

        {comment}
        sd(config.textcolor, 'Comment  : ');
        d(global_talkcol, adrink^.comment);

        {creator}
        sd(config.textcolor, 'Creator  : ');
        d(global_plycol, adrink^.creator);

        {ordered}
        sd(config.textcolor, 'Ordered  : ');
        sd(7, commastr(adrink^.ordered));
        if adrink^.ordered = 1 then
        begin
          sd(config.textcolor, ' time.');
        end else
        begin
          sd(config.textcolor, ' times.');
        end;

        {last had by customer "X"}
        if adrink^.ordered > 0 then
        begin
          sd(config.textcolor, ' (last had by ');
          sd(global_plycol, adrink^.lasthad);
          d(config.textcolor, ', the ' + race_display(2, adrink^.lastrac, 0) + ', ' + ulmag +
            fix_date(adrink^.lastdat) + config.textcol1 + ')');
        end else
        begin
          crlf;
        end;

      end;

      {should we pause the listing}
      if x > global_screenlines - 2 then
      begin

        menu_result := mini_menu(event);

        lasttimewasthemenu := True;

        if (menu_result = -1) or (menu_result > 0) then
        begin
          break;
        end;

      end; {mini menu/pause .end.}

    end;   {for i:= .end.}

    if (menu_result = 0) and (lasttimewasthemenu = False) then
    begin
      menu_result := mini_menu(event);
    end;

    if c = 0 then
    begin
      crlf;
      d(15, 'There are no cocktails on the list right now!');
      d(15, '(perhaps you could add one)');
      pause;
      crlf;
    end;

    crlf;

    {return result}
    browse_select_drinks := menu_result;

  end; {browse_select_drinks *end*}

var
  finito, found: boolean;
  size:          word;

begin {*MAIN PROCEDURE*}

      {Init Pointer Var}
  new(pl0);
  new(adrink);

  {fetch Bartenders name from .CFG, #165}
  bartender := cfg_string(165);
  if bartender = '' then
    bartender := 'Sly';

  {Name of Regular Drinks}
  drink[1] := 'Orb Soda';
  drink[2] := 'Troll Cola';
  drink[3] := 'Gildarion';
  drink[4] := 'Harlindar';
  drink[5] := 'Reliever';
  drink[6] := 'Grindstone';
  drink[7] := 'ByeBye Sue';
  drink[8] := 'Suranie';
  drink[9] := 'Dark Lord';

  {Cost to buy Regular Drinks}
  cost[1] := 500;
  cost[2] := 1500;
  cost[3] := 5000;
  cost[4] := 12500;
  cost[5] := 15000;
  cost[6] := 20000;
  cost[7] := 24000;
  cost[8] := 30000;
  cost[9] := 55000;

  repeat

    {Update Online Location}
    if onliner.location <> onloc_orbs then
    begin
      refresh := True;
      onliner.location := onloc_orbs;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    ch := upcase(getchar);

    if (ch = 'O') and (player.drinksleft < 1) then
    begin
      crlf;
      d(12, 'You have drunk too much already!');
      pause;
      ch := ' ';
    end;

    {evalauate user input}
    case ch of
      '?': begin {display menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        clearscreen;
        status(player);
      end;
      'B': begin {buy a "friend" a drink. house specials only}


        if player.drinksleft < 1 then
        begin
          crlf;
          crlf;
          d(12, 'You are exhausted. There is no strength left in you to send any drinks today.');
          d(12, 'Return tomorrow.');
          pause;
          crlf;
        end else
        begin

          crlf;
          crlf;
          d(config.textcolor, 'Who would you like to buy a drink?');
          sd(config.textcolor, ':');

          s := get_string(20);

          found := False;
          finito := False;

          {searching among the humans and NPCs}
          for i := 1 to 2 do
          begin
            case i of
              1: size := fs(FsPlayer);
              2: size := fs(FsNpc);
            end;

            if found then
              break;

            for j := 1 to size do
            begin

              if finito then
                break;

              {load character}
              load_character(pl0^, i, j);

              if (findsub(s, pl0^.name2)) and
                (pl0^.name1 <> global_delname1) and
                (pl0^.name2 <> global_delname2) and
                (pl0^.name2 <> player.name2) and
                (pl0^.hps > 0) and
                (pl0^.deleted = False) then
              begin

                if confirm(uplc + pl0^.name2 + config.textcol1 + ', the ' + classnames[pl0^.class], 'N') = True then
                begin
                  found := True;
                  break;
                end else
                begin
                  if confirm('Continue search', 'Y') = False then
                  begin
                    finito := True;
                    break;
                  end;
                end;

              end;
            end; {for j:= .end.}
          end;   {for i:= .end.}

          if not found and not finito then
          begin
            could_not_locate_character;
          end else
          if found then
          begin

            {we have a target!}
            crlf;

            d(15, 'Pick a nice drink to send to ' + uplc + pl0^.name2 + config.textcol1 + '.');
            pause;

            {let player pick a drink}
            x := browse_select_drinks(2);

            if x > 0 then
            begin

              {load drink}
              load_drink(Fload, adrink^, x);

              {create question}
              if pl0^.ai = 'H' then
              begin
                s := 'Send ' + udrinkc + adrink^.Name + config.textcol1 + ' to ' + uplc + pl0^.name2 + config.textcol1;
              end else
              begin
                s := 'Invite ' + uplc + pl0^.name2 + config.textcol1 + ' to drink ' + udrinkc +
                  adrink^.Name + config.textcol1 + '.';
              end;

              if confirm(s, 'Y') = True then
              begin

                if pl0^.ai <> 'H' then
                begin

                  if pl0^.drinksleft < 1 then
                  begin
                    crlf;
                    d(12, uplc + pl0^.name2 + ulred + ' is suffering from a hangover!');
                    pause;
                    crlf;
                  end else
                  begin

                    {how should the computer players respond?}

                    if is_online(pl0^.name2, online_player) then
                    begin
                      crlf;
                      d(global_plycol, pl0^.name2 + config.textcol1 + ' is busy right now.');
                    end else
                    begin

                      {add offline player}
                      if add_shadow(SAdd, pl0^, player.name2, 'having a drink', 0) = False then
                      begin
                        {unable to add pl0}
                        crlf;
                        d(global_plycol, pl0^.name2 + config.textcol1 + ' is busy right now.');
                      end else
                      begin

                        {pl0 was successfully added to the online list}
                        if random(1) = 0 then
                        begin
                          crlf;
                          d(global_plycol, pl0^.name2 + config.textcol1 +
                            ' has arrived, with a dry throat longing for a drink!');

                          {npc enjoys the free drink!}
                          Drink_a_drink(pl0^, NpcDrink, ADrink^, TheAmount, x);

                          Dec(pl0^.drinksleft);

                          {save npc}
                          user_save(pl0^);

                          if pl0^.allowed then
                          begin
                            d(global_plycol, pl0^.name2 + config.textcol1 + ' thank you and leaves.');
                          end else
                          begin
                            d(config.textcolor, 'The spirit of ' + uplc + pl0^.name2 + config.textcol1 + ' hates your guts!');
                          end;

                        end else
                        begin
                          crlf;
                          d(global_plycol, pl0^.name2 + config.textcol1 + ' doesn''t want your lousy drink!');
                        end;

                        {remove shadow player PL0}
                        add_shadow(SRemove, pl0^, '', '', 0);

                      end;

                    end;
                  end;

                end else
                begin

                  {send drink to human player}
                  {anonymous}
                  if confirm('Be Anonymous', 'N') = True then
                    s := 'Y'
                  else s := 'N';

                  d(14, 'Done!');
                  d(config.textcolor, 'The drink will be served as soon as ' + uplc + pl0^.name2 +
                    config.textcol1 + ' arrives.');

                  {mail the drink to the (human) player pl0}
                  post(MailSend,
                    pl0^.name2,
                    pl0^.ai,
                    False,
                    mailrequest_DrinkOffer,
                    player.name2,
                    commastr(x),  {drink #, so receiver can load the right drink}
                    adrink^.Name, {drink name, compared at load time}
                    adrink^.date, {drink date, compared at load time}
                    s,            {is sender anonymous? (Y/N)}
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

                  if s = 'Y' then
                    s := '*Unknown*'
                  else s := player.name2;

                  if is_online(pl0^.name2, online_player) then
                  begin
                    online_send_to_player(pl0^.name2, online_player, uplc + S + config.textcol1 +
                      ' has sent you a free drink!');
                  end;

                end;

              end else
              begin
                d(12, 'Aborted.');
              end;

            end else
            begin
              d(12, 'Aborted.');
            end;

          end;

        end;

      end;
      'P': begin {popular drinks}
        drink_top_list;
      end;
      'H': begin {customers special drink}

        browse_select_drinks(1);

      end;
      'O': begin {order a drink}
        crlf;

        {update player doing}
        onliner.doing := 'having a drink at Orbs';
        add_onliner(OUpdateLocation, onliner);

        repeat

          ch := '?';
          repeat

            if ch = '?' then
            begin
              crlf;
              d(5, 'Order a drink');
              d(11, '~~~~~~~~~~~~~');
              menu('(R)egular drink');
              menu('(C)reate own Cocktail');
              menu('(A)bort');
            end;

            crlf;
            sd(config.textcolor, 'Order (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
            ch := upcase(getchar);
          until ch in ['C', 'R', 'A'];


          if ch = 'C' then
          begin
            crlf;
            sd(config.textcolor, 'Pay ');
            sd(14, commastr(owndrink_cost));
            sd(config.textcolor, ' for making your own Cocktail');
            if confirm('', 'N') = False then
            begin
              ch := 'A';
            end else
            begin
              if player.gold < owndrink_cost then
              begin
                ch := 'A';
                d(config.textcolor, 'You don''t have the ' + config.moneytype + '!');
                crlf;
                pause;
              end else
              begin
                decplayermoney(player, owndrink_cost);
              end;
            end;
          end;

        until ch in ['R', 'C', 'A'];

        case ch of
          'A': begin
            crlf;
            d(12, 'Aborted');
            d(config.textcolor, 'You decide to order that drink later.');
          end;
          'C': begin
            {Update Online Location}
            if onliner.location <> onloc_orbs_mixing then
            begin
              onliner.location := onloc_orbs_mixing;
              onliner.doing := location_desc(onliner.location);
              add_onliner(OUpdateLocation, onliner);
            end;

            clearscreen;
            crlf;
            crlf;

            sd(5, 'Mixing Your Own ');
            sd(global_plycol, player.name2);
            d(5, ':s Special');

            crlf;
            d(config.textcolor, 'You can choose from ' + commastr(maxingredients) + ' different ingredients. Mix freely,');
            d(config.textcolor, 'but be careful... The wrong mixture can kill you instantly,');
            d(config.textcolor, 'while a good one can boost your abilities!');
            crlf; pause;

            sdrink := 0; {n„r denna n†r 100 „r den full och kan drickas}

            for i := 1 to maxingredients do
              TheAmount.amount[i] := 0;

            repeat

              crlf;
              sd(config.textcolor, 'Your drink is : ');
              sd(15, commastr(sdrink));
              d(config.textcolor, ' % Ready');
              menu('(+) Add Ingredient');
              menu('(D)rink your Home-Made Special!');
              menu('(A)bort');
              sd(config.textcolor, ':');

              repeat
                ch := getchar; ch := upcase(ch);
              until ch in ['+', 'D', 'A'];
              crlf;

              case ch of
                'A': begin
                  if confirm('Abort Process', 'N') = False then
                  begin
                    ch := ' ';
                  end;
                end;
                'D': begin
                  if sdrink < 100 then
                  begin
                    d(config.textcolor, 'Your drink is not ready yet! Add some more ingredients!');
                    ch := ' ';
                    pause;
                  end else
                  begin
                    drink_a_drink(Player, OwnDrink, adrink^, TheAmount, 0);
                  end;
                end;
                '+': begin
                  crlf;
                  for i := 1 to 9 do
                  begin
                    menu2('(' + commastr(i) + ') ' + ljust(ing[i] + ' - ' + commastr(TheAmount.amount[i]), 24));
                    if i < 9 then
                      menu('(' + chr(i + 64) + ') ' + ing[9 + i] + ' - ' + commastr(TheAmount.amount[9 + i]));
                  end;

                  crlf;
                  sd(config.textcolor, ':');
                  repeat
                    ch := getchar; ch := upcase(ch);
                  until ch in ['1', '2', '3', '4', '5', '6', '7', '8', '9',
                      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
                  case ch of
                    '1': i := 1;
                    '2': i := 2;
                    '3': i := 3;
                    '4': i := 4;
                    '5': i := 5;
                    '6': i := 6;
                    '7': i := 7;
                    '8': i := 8;
                    '9': i := 9;
                    'A': i := 10;
                    'B': i := 11;
                    'C': i := 12;
                    'D': i := 13;
                    'E': i := 14;
                    'F': i := 15;
                    'G': i := 16;
                    'H': i := 17;
                  end;
                  ch := ' ';

                  crlf;
                  sd(config.textcolor, 'How much ');
                  sd(3, ing[i]);
                  sd(config.textcolor, ' shall you use (max ');
                  sd(3, commastr(100 - sdrink));
                  d(config.textcolor, ')');

                  sd(config.textcolor, ':');
                  j := get_number(0, 100 - sdrink);
                  if (j > 0) and (j <= (100 - sdrink)) then
                  begin
                    sd(config.textcolor, 'You pour some ');
                    sd(3, ing[i]);
                    d(config.textcolor, ' in your cup!');
                    pause;
                    sdrink := sdrink + j;
                    TheAmount.amount[i] := TheAmount.amount[i] + j;
                  end;
                end;
              end;

            until ch in ['A', 'D'];

            case ch of
              'D': begin
                Dec(player.drinksleft);
              end;
            end;

          end;
          'R': begin
            repeat
              clearscreen;
              crlf; crlf;
              d(5, 'Standard Orb Drinks :');
              crlf;
              menu('(1) Orb Soda   - Known to be a stamina-raiser for some [' + commastr(cost[1]) +
                ' ' + config.moneytype + ']');
              menu('(2) Troll Cola - Famous outdoor drink, troll favourite [' + commastr(cost[2]) +
                ' ' + config.moneytype + ']');
              menu('(3) Gildarion  - Holy elf water (be a good boy)        [' + commastr(cost[3]) +
                ' ' + config.moneytype + ']');
              menu('(4) Harlindar  - Character builder                     [' + commastr(cost[4]) +
                ' ' + config.moneytype + ']');
              menu('(5) Reliever   - Hardworking dwarves love this one     [' + commastr(cost[5]) +
                ' ' + config.moneytype + ']');
              menu('(6) Grindstone - Buy it, drink it, think about it      [' + commastr(cost[6]) +
                ' ' + config.moneytype + ']');
              menu('(7) ByeBye Sue - Also called "THE KISS" by the fans    [' + commastr(cost[7]) +
                ' ' + config.moneytype + ']');
              menu('(8) Suranie    - Only recommended to strong males      [' + commastr(cost[8]) +
                ' ' + config.moneytype + ']');
              menu('(9) Dark Lord  - Interesting...                        [' + commastr(cost[9]) +
                ' ' + config.moneytype + ']');
              menu('(0) Abort');
              sd(config.textcolor, ':');
              repeat
                ch := getchar; ch := upcase(ch);
                if ch in ['1', '2', '3', '4', '5', '6', '7', '8', '9'] then
                begin

                  crlf;
                  case ch of
                    '1': i := 1;
                    '2': i := 2;
                    '3': i := 3;
                    '4': i := 4;
                    '5': i := 5;
                    '6': i := 6;
                    '7': i := 7;
                    '8': i := 8;
                    '9': i := 9;
                  end; {case .end.}

                  if cost[i] > player.gold then
                  begin
                    crlf;
                    sd(global_talkcol, 'Come back when you have enough ' + config.moneytype + '!');
                    d(config.textcolor, ', the bartender mutters.');
                    pause;
                    ch := ' ';
                    break;
                  end else
                  begin
                    sd(config.textcolor, 'The ');
                    sd(5, drink[i]);
                    sd(config.textcolor, ' costs ');
                    sd(14, commastr(cost[i]));
                    sd(config.textcolor, ' ' + many_money(cost[i]) + '.');
                    crlf;
                    if confirm('Buy one ', 'N') = True then
                    begin
                      d(config.textcolor, 'Done! Insha gives you the drink');
                      decplayermoney(player, cost[i]);
                      Dec(player.drinksleft);
                      pause;
                    end else
                    begin
                      ch := ' ';
                      break;
                    end;
                  end;
                end;
              until ch in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

              case ch of
                '1': begin
                  crlf;
                  d(config.textcolor, 'You sweep the drink down in one go...');
                  d(config.textcolor, 'Holy smokes! That was good!');
                  xx := player.level * 50;
                  player.exp := player.exp + xx;
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  if random(2) = 0 then
                  begin
                    if random(2) = 0 then
                    begin
                      player.stamina := player.stamina + 1;
                      d(config.textcolor, 'You feel fitter too!');
                    end else
                    begin
                      player.strength := player.strength + 1;
                      d(config.textcolor, 'You feel stronger too!');
                    end;
                  end;
                  pause;
                  ch := '0';
                end;
                '2': begin
                  crlf;
                  d(config.textcolor, 'Brrrrrr....! That was awesome!');
                  if player.race = Elf then
                    d(config.textcolor, 'But you don' + chr(39) + 't feel very well...');
                  if player.race = Troll then
                  begin
                    xx := player.level * 200;
                  end else
                  if player.race = Elf then
                  begin
                    xx := 0;
                  end else
                  begin
                    xx := player.level * 100;
                  end;
                  if (random(2) = 0) and (player.class <> Assassin) then
                  begin

                    if player.dark > player.chiv then
                    begin
                      d(config.textcolor, 'Your powers are increasing!');
                      d(config.textcolor, 'Your darkness is good!');
                      player.agility := player.agility + 1;
                      player.defence := player.defence + 1;
                    end;
                  end;
                  player.exp := player.exp + xx;
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  pause;
                  ch := '0';
                end;
                '3': begin
                  crlf;
                  xx := player.level * 150;
                  d(config.textcolor, 'You let the water pour down your throat...');
                  if (player.race = Troll) or (player.race = Orc) then
                  begin
                    d(config.textcolor, 'OUCH! That was disgusting!!!');
                    d(config.textcolor, 'Never drink that again!');
                    player.stamina := player.stamina - 1;
                    player.strength := player.strength - 1;
                    if player.stamina < 1 then
                      player.stamina := 1;
                    if player.strength < 1 then
                      player.strength := 1;
                    xx := 0;
                  end else
                  begin
                    d(config.textcolor, 'Ahh...that was really good!');
                    if player.chiv < player.dark then
                    begin
                      d(config.textcolor, 'But you feel a slight pain after awhile!');
                      xx := 100;
                    end else
                    begin
                      if player.race = Elf then
                        d(config.textcolor, 'This is THE drink for you!');
                      if random(2) = 0 then
                      begin
                        d(config.textcolor, 'Your powers are increasing!');
                        Inc(player.stamina, 2);
                        Inc(player.dex);
                      end else
                      begin
                        d(config.textcolor, 'You are getting more powerful, my friend!');
                        Inc(player.stamina);
                        Inc(player.defence);
                      end;
                    end;
                  end;

                  Inc(player.exp, xx);
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  pause;
                  ch := '0';
                end;
                '4': begin
                  crlf;
                  d(config.textcolor, 'You look at the yellow bubbling liquid before you...');
                  d(global_talkcol, 'Character Builder huh!?. Yiehhaaa...here goes...');
                  delay2(1000);
                  if random(2) = 0 then
                  begin
                    player.skin := random(10);
                    d(config.textcolor, 'Haha....your skin just turned ' + color[player.skin] + '!');

                    newsy(True,
                      'Laughs at the Orb!',
                      ' ' + uplc + player.name2 + 's' + config.textcol1 + ' skin changed color after a bad drink!',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');

                    if player.stamina > 1 then
                      player.stamina := player.stamina - 1;
                  end else
                  begin
                    if random(2) = 0 then
                    begin
                      d(config.textcolor, 'Whooopps! JACKPOT! That drink hit the right spot alright!');
                      if player.class in [Cleric, Magician, Sage] then
                      begin
                        player.maxmana := player.maxmana + 10;
                      end else
                      begin
                        player.wisdom := player.wisdom + 1;
                        player.agility := player.agility + 1;
                        player.strength := player.strength + 1;
                      end;
                    end;
                    xx := player.level * 200;
                    player.exp := player.exp + xx;
                    if xx > 0 then
                      d(config.textcolor, 'Your experience raised!');
                  end;
                  pause;
                  ch := '0';
                end;
                '5': begin
                  crlf;
                  d(config.textcolor, 'The Reliever drink stands before you.');
                  d(config.textcolor, 'It' + chr(39) + 's deep blue, with strange black grains');
                  d(config.textcolor, 'floating around in it.');
                  d(config.textcolor, 'You are also given the additional "lucky dog" herb');
                  xx := player.level * 250;

                  if confirm('Swallow the herb ', 'N') = True then
                  begin
                    d(config.textcolor, 'Gulp!....');
                    delay2(500);
                    if player.race = Dwarf then
                    begin
                      d(config.textcolor, 'Ahhhh...! You feel the fluid empower you with the');
                      d(config.textcolor, 'strength you need so badly.');
                      pause;
                      if random(2) = 0 then
                        player.stamina := player.stamina + 2;
                      xx := xx + random(1000);
                    end;
                  end else
                  begin
                    if player.race = Dwarf then
                    begin
                      d(config.textcolor, 'Somehow I feel that this was a bad move...');
                      delay2(1000);
                    end;
                    d(config.textcolor, 'You throw the "lucky dog" in the spittoon....');
                    delay2(1000);
                    d(config.textcolor, 'KLONK!');
                    delay2(1000);
                  end;
                  player.exp := player.exp + xx;
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  pause;
                  ch := '0';
                end;
                '6': begin
                  crlf;
                  d(config.textcolor, 'The Grindstone Drink is served in a enormous Troll-Jar.');
                  d(config.textcolor, 'Are you sure you wanna drink all of it ?');
                  menu('(Y)es, all of it!');
                  menu('(N)o only half');
                  menu('(J)ust a few zips...');
                  sd(config.textcolor, ':');
                  repeat
                    ch := getchar; ch := upcase(ch);
                  until (ch = 'Y') or (ch = 'N') or (ch = 'J');
                  case ch of
                    'Y': begin
                      for xx := 1 to 5 do
                      begin
                        sd(config.textcolor, 'Klunk....');
                        delay2(700);
                      end;
                      crlf;
                      if random(2) = 0 then
                      begin
                        d(config.textcolor, 'You are DRUNK!.....');
                        delay2(700);
                        d(config.textcolor, 'Goodnight! You fall heavily to the floor!');

                        if random(2) = 0 then
                        begin
                          if player.drinksleft > 0 then
                            Dec(player.drinksleft);
                        end;

                        newsy(True,
                          'Boozer at Orbs!',
                          ' ' + uplc + player.name2 + 's' + config.textcol1 + ' didn''t manage to control ' +
                          sex3[player.sex],
                          ' drinking! Had to be carried out from the bar...',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '');

                        crlf;
                        pause;
                        normal_exit;
                      end else
                      begin
                        d(config.textcolor, 'Ahhhh!!! That was GOOD!');
                        player.strength := player.strength + random(5);
                        player.dex := player.dex + random(3);
                      end;
                      pause;
                    end;
                    'N': begin
                      for xx := 1 to 3 do
                      begin
                        sd(config.textcolor, 'Klunk....');
                        delay2(700);
                      end;
                      crlf;
                      if random(2) = 0 then
                      begin
                        d(config.textcolor, 'Mmmmm...you are enriched with power!');
                        player.agility := player.agility + random(3);
                      end;
                      d(config.textcolor, 'Buurp!!');
                      pause;
                    end;
                    'J': begin
                      for xx := 1 to 3 do
                      begin
                        sd(config.textcolor, 'Zip....');
                        delay2(700);
                      end;
                      crlf;
                      if random(2) = 0 then
                      begin
                        d(config.textcolor, 'Mmmmm...you are enriched with power!');
                        player.charisma := player.charisma + random(10);
                      end;
                      d(config.textcolor, 'Hrmm....that tasted quite good...');
                      pause;
                    end;
                  end;

                  xx := player.level * 300;
                  player.exp := player.exp + xx;
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  pause;
                  ch := '0';
                end;
                '7': begin
                  crlf;
                  d(config.textcolor, 'This seems to be a quite ordinary drink...');
                  delay2(800);
                  d(config.textcolor, 'Cheers!');
                  crlf; pause;
                  if (player.race = Gnome) or (player.race = Gnoll) then
                  begin
                    if random(2) = 0 then
                    begin
                      d(config.textcolor, 'Ahh! That was just what YOU needed!');
                      d(config.textcolor, 'POWER DRINK!');
                      crlf;
                      pause;
                      player.stamina := player.stamina + 3;
                      player.agility := player.agility + 3;
                    end;
                  end;
                  if random(3) = 0 then
                  begin
                    d(config.textcolor, 'TURBO! You got your engine running on this one!');
                    crlf; pause;
                    player.strength := player.strength + 5;
                    player.defence := player.defence + 5;
                  end;
                  xx := player.level * 350;
                  player.exp := player.exp + xx;
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  pause;
                  ch := '0';
                end;
                '8': begin
                  crlf;
                  d(config.textcolor, drink[8] + '! Take a deep breath....');
                  delay2(900);
                  d(config.textcolor, 'Here goes! KLUNK!...');
                  delay2(900);
                  d(config.textcolor, 'KLUNK!....');
                  delay2(900);

                  if (player.level < 10) or (random(5) = 0) then
                  begin
                    d(config.textcolor, 'Sorry, you were knocked out by this one!');
                    d(config.textcolor, 'You should get more experience, and perhaps a few years older');
                    d(config.textcolor, 'before trying this one out!');

                    if random(2) = 0 then
                    begin
                      if player.drinksleft > 0 then
                        Dec(player.drinksleft);
                    end;
                    crlf;
                    pause;
                    normal_exit;
                  end;

                  xx := player.level * 400;

                  if random(2) = 0 then
                  begin
                    d(config.textcolor, 'Perfect! Just what you needed!');
                    xx := xx * 2;
                  end;

                  player.exp := player.exp + xx;
                  if xx > 0 then
                    d(config.textcolor, 'Your experience raised!');
                  pause;
                  ch := '0';
                end;
                '9': begin
                  crlf;
                  xx := player.level * 800;
                  d(config.textcolor, 'This is a GRIM DRINK! It comes in a huge orcskull, and');
                  d(config.textcolor, 'it' + chr(39) + 's steeming! (Dragon Afterburner so to speak...)');
                  crlf; pause;
                  d(config.textcolor, 'Everybody is looking your way right now! It is always');
                  d(config.textcolor, 'interesting to see how Dark Lord affects it' + chr(39) + ' consumer...');
                  crlf; pause;
                  d(config.textcolor, 'You must say something to the crowd before this one goes down!');
                  sd(config.textcolor, ':');
                  s := get_string(70);
                  if s = '' then
                    s := 'Hello there Mama!';
                  s := ' ' + s;

                  newsy(False,
                    'Brave Drinker!',
                    ' ' + uplc + player.name2 + 's' + config.textcol1 + ' last words before taking the DARK LORD drink :',
                    utalkc + s + config.textcol1,
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  if random(10) > 0 then
                  begin
                    newsy(True,
                      ' ' + uplc + player.name2 + config.textcol1 + ' was not prepared for this strong brew...',
                      ' (what a loser)',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');

                    d(config.textcolor, 'You take the hideous skull, and drink the whole brew in one go...');
                    delay2(1200);
                    d(config.textcolor, 'Your head is exloding! You fade away into the great unknown..');
                    if player.exp > 500 then
                      player.exp := player.exp - 500;

                    if random(3) = 0 then
                    begin
                      if player.drinksleft > 0 then
                        Dec(player.drinksleft);
                    end;

                    crlf;
                    pause;
                    normal_exit;
                  end;

                  newsy(True,
                    ' and ' + uplc + player.name2 + config.textcol1 + ' managed to take the Dark Lord!',
                    ' What a great deed! (WINNER!)',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  player.exp := player.exp + xx;
                  player.stamina := player.stamina + 2;
                  player.agility := player.agility + 2;
                  player.dex := player.dex + 2;
                  player.wisdom := player.wisdom + 2;
                  if player.class in [Cleric, Magician, Sage] then
                  begin
                    player.maxmana := player.maxmana + 20;
                  end;
                  d(config.textcolor, 'Your experience raised!');
                  d(config.textcolor, 'And so did many of your other abilities also!');
                  d(config.textcolor, 'Everybody in the Bar congratulate you on your effort!');
                  crlf;
                  d(14, 'YOU DID IT! CONGRATULATIONS!');
                  crlf;
                  pause;
                  ch := '0';
                end;
              end;
            until ch = '0';
          end;
        end; {case ch of .end.}
      end;

    end; {case ch of .end.}

  until ch = 'R';

  {dispose pointer vars}
  dispose(pl0);
  dispose(adrink);

  crlf;

end; {Orb_Center *end*}

end. {Unit Orb .end.}
