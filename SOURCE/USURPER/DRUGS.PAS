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


unit Drugs; {Usurper - Drugs - not to be used by children}

interface

procedure Drug_Store;

implementation

uses
  Init, Cms, Jakob,
  Various, Statusc, News,
  Various3, Online;

var
  owner:   s40;
  refresh: boolean;


procedure Meny;
var s: s90;
begin

  s := 'Beer-House, run by ' + owner + ' the Orc';

  crlf;
  d(5, 'Beer-House, run by ' + uplc + owner + umag);
  d(5, mkstring(length(s), underscore));
  crlf;
  d(config.textcolor, 'You enter the shabby hut with a close grip on your equipment.');
  d(config.textcolor, 'In these parts of town you must keep an eye on everything, and');
  d(config.textcolor, 'no one is to be trusted.');
  d(config.textcolor, 'Everybody knows that this place is the biggest drughole in town.');
  d(config.textcolor, 'But somehow it is left alone by the Kings men. You can only');
  d(config.textcolor, 'guess what bribes it must take to keep it open.');
  crlf;
  d(config.textcolor, 'You salute ' + uplc + owner + config.textcol1 + ' as you make your way to the bar.');
  crlf;
  menu('(L)ist drugs');
  menu('(B)uy');
  menu('(S)tatus');
  menu('(R)eturn to street');

end;

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'L',
                       'B',
                       'S',
                       chr(13),
                       '?']);}

  if short = True then
  begin
    if player.expert = False then
    begin
      if (refresh) and (player.auto_meny) then
      begin
        refresh := False;
        clearscreen;
        meny;
      end;
      crlf;
      sd(config.textcolor, 'Drugs (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin
      crlf;
      sd(config.textcolor, 'Drugs (R,L,B,S,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      clearscreen;
      meny;
    end;
  end;
end;

procedure Drug_Store;
const
  drugnr = 10;

var
  drug:      array[1..drugnr] of ^string;
  drugprice: array[1..drugnr] of ^longint;
  comment:   array[1..drugnr] of ^string;
  xx, i, x:  longint;
  cho:       char;
  s:         s70;
  justval:   integer;

begin

  {init drug variables}
  for i := 1 to drugnr do
  begin
    new(drug[i]);
    new(drugprice[i]);
    new(comment[i]);
  end;

  {get shop-keepers name from .cfg #180}
  owner := cfg_string(180);
  if owner = '' then
    owner := 'Ordlof';


  {set drug names & prices}
  drug[1]^ := 'Incense';
  drug[2]^ := 'Psilocybin';
  drug[3]^ := 'Oxytozin';
  drug[4]^ := 'Psylxion';
  drug[5]^ := 'Shang Ri La';
  drug[6]^ := 'Neopratin';
  drug[7]^ := 'Galacticum';
  drug[8]^ := 'Inferno';
  drug[9]^ := 'Sanguin Hope';
  drug[10]^ := 'Transactor';

  comment[1]^ := 'Quite harmless. Give you this cosy feeling.';
  comment[2]^ := 'Be happy, be happier, be happiest!';
  comment[3]^ := 'Ever wanted to be able to fly?';
  comment[4]^ := 'Used by Orc infantry to reduce stress.';
  comment[5]^ := 'Enter dreamland. Where everything is yours.';
  comment[6]^ := 'Gnome favourite. Walk the rainbow.';
  comment[7]^ := 'Float out in space. Heavy and dangerous.';
  comment[8]^ := 'Your adrenalin meter will skyrocket.';
  comment[9]^ := 'You will never know what hit you...';
  comment[10]^ := 'Heaviest stuff on the market. Be cautious.';

  drugprice[1]^ := 900;
  drugprice[2]^ := 3000;
  drugprice[3]^ := 13000;
  drugprice[4]^ := 27000;
  drugprice[5]^ := 50000;
  drugprice[6]^ := 70000;
  drugprice[7]^ := 120000;
  drugprice[8]^ := 175000;
  drugprice[9]^ := 200000;
  drugprice[10]^ := 500000;

  crlf;
  crlf;
  d(config.textcolor, 'You enter the ' + ulcyan + 'Drug' + config.textcol1 + ' shop.');

  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_drugs then
    begin
      refresh := True;
      onliner.location := onloc_drugs;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    display_menu(True, True);


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
      'B': begin
        crlf;
        d(3, 'Enter Item # to buy');
        sd(config.textcolor, ':');
        x := get_number(0, drugnr);

        if (x < 1) or (x > drugnr) then
          x := 0;

        if x = 0 then
        begin
          d(15, 'Wrong number birdbrain!');
          d(15, '(valid numbers are 1..' + commastr(drugnr) + ')');
        end else
        begin
          i := x;

          sd(config.textcolor, 'Buy some ');
          sd(5, drug[i]^);

          if confirm('', 'N') = True then
          begin
            if player.gold < drugprice[i]^ then
            begin
              d(config.textcolor, 'You don''t have the ' + config.moneytype + '!');
              pause;
              cho := '?';
            end else
            begin
              crlf;
              d(global_talkcol, 'Alright, let''s do business ' + uplc + owner + config.textcol1 + ' says.');
              crlf;
              d(config.textcolor, 'You hand the sloe-eyed orc the ' + config.moneytype + ' and receive a small packet.');
              d(config.textcolor, 'Inside the package you find a white pill.');
              d(config.textcolor, 'You take the stuff and enter one of the backdoors to');
              d(config.textcolor, 'the inner localities of the building.');
              crlf;

              decplayermoney(player, drugprice[i]^);

              pause;
              clearscreen;
              crlf;
              d(config.textcolor, 'Seated in one of the rooms, you take the pill and');
              d(config.textcolor, 'swallow it down together with a cool softdrink.');
              delay2(800);
              crlf;
              d(config.textcolor, 'Gulp..');
              delay2(800);
              d(config.textcolor, 'Slurp..');
              delay2(800);
              d(config.textcolor, 'Mmmm..');
              delay2(800);
              d(config.textcolor, 'Slurp..');
              delay2(800);
              d(config.textcolor, 'Slurp..');
              delay2(800);
              d(config.textcolor, '....Gulp!');
              delay2(800);

              case i of
                1: begin
                  crlf;
                  d(config.textcolor, 'You light the incense and feel the blend of nature.');
                  d(config.textcolor, 'Soon you start to feel very comfortable with everything.');
                  d(config.textcolor, 'Your problems fade away in a distant blur and nothing');
                  d(config.textcolor, 'really matters. It''s only you and your hallucinations...');
                end;
                2: begin
                  crlf;
                  d(config.textcolor, 'At first you feel nothing from the pill. But you know that');
                  d(config.textcolor, 'Psilocybin is a drug worth waiting for... And yes, sudden impressions');
                  d(config.textcolor, 'and experiences soon begin to fill your mind. They all have');
                  d(config.textcolor, 'one thing in common: all are filled with happiness and joy.');
                  d(config.textcolor, 'You start to notice a deep vibration from somewhere near...');
                  d(config.textcolor, 'It takes a while before you realize that it is your pulse beating.');
                  d(config.textcolor, 'You stretch out on the couch and let the drug take over...');
                end;
                3: begin
                  crlf;
                  d(config.textcolor, 'Ouuchh! You feel as you were being burned from inside.');
                  d(config.textcolor, 'You are almost knocked unconscious by the drug. But soon');
                  d(config.textcolor, 'you feel how your mind is filled with wisdom, and finally');
                  d(config.textcolor, 'how your soul disembarks from your body.');
                  d(config.textcolor, 'Your link to reality fades, and the last thing you can remember before');
                  d(config.textcolor, 'you enter the surreal is that you must come back here tomorrow...');
                end;
                4: begin
                  crlf;
                  d(config.textcolor, 'Psylxion is a combat drug. A real stress reducer.');
                  d(config.textcolor, 'The dose you took was a triple normal. After a couple of');
                  d(config.textcolor, 'minutes you feel how your tensions disappears. Your mind feels');
                  d(config.textcolor, 'amazingly sharp and crystal clear. You soon enter a state of');
                  d(config.textcolor, 'complete harmony with yourself. The strong dose takes you');
                  d(config.textcolor, 'beyond reality. Soon you surf the lightwaves...');
                end;
                5: begin
                  crlf;
                  d(config.textcolor, 'The intro-effect from this drug isn''t nice. After a short');
                  d(config.textcolor, 'moment you feel like you got hit by a giant hammer...');
                  d(config.textcolor, 'You wake up in a long dark tunnel. At the end you can see');
                  d(config.textcolor, 'a light shining with sharp intensity. At the same time you');
                  d(config.textcolor, 'feel the presence of something powerful behind you.');
                  d(config.textcolor, 'But you strive towards the light without looking back...');
                  d(config.textcolor, 'As you progress towards the light you feel wisdom and joy.');
                end;
                6: begin
                  crlf;
                  d(config.textcolor, 'The Neopratin drug soon takes over your body and soul.');
                  d(config.textcolor, 'The familiar spinner effect takes place, where you feel the');
                  d(config.textcolor, 'short discomfort of having your head turning at the speed of');
                  d(config.textcolor, 'light. Bright colours fill your mind and give you a feeling');
                  d(config.textcolor, 'of supernatural powers. With a giant step you enter the');
                  d(config.textcolor, 'galaxy of dreams...');
                end;
                7: begin
                  crlf;
                  d(config.textcolor, 'With a short prayer you await the effect of the drug.');
                  d(config.textcolor, 'After a while you hear this intense stomping sound.');
                  d(config.textcolor, 'During the short time it takes for you to realize that');
                  d(config.textcolor, 'the stomping sound is your own heart, bolts of light');
                  d(config.textcolor, 'cut right through your mind. The darkness that follows');
                  d(config.textcolor, 'soon changes to a new reality, the ocean of galaxies...');
                end;
                8: begin
                  crlf;
                  d(config.textcolor, '"Ko-nahm toh, ko-nahm toh, ko-nahm toh". The phrase');
                  d(config.textcolor, 'repeats itself inside your head. Quite funny drug effect.');
                  d(config.textcolor, 'A large amount of energy pours through your body. This would');
                  d(config.textcolor, 'be a perfect combat drug, a true illegal rush.');
                  d(config.textcolor, 'Unfortunately there is a coma stadium too...');
                  d(config.textcolor, 'Your increased brain capacity scans your accumulated wisdom');
                  d(config.textcolor, 'and reworks it. The last thing you must do before darkness...');
                end;
                9: begin
                  crlf;
                  d(config.textcolor, 'Before you know it a large black helmet is drawn over');
                  d(config.textcolor, 'your head. Your quest for joy and knowledge begins with a');
                  d(config.textcolor, 'trip to the other side of life. The combined journey is dark');
                  d(config.textcolor, 'and dangerous. But it''s a mustbe for the true adventurer of');
                  d(config.textcolor, 'life. Altered states can be confusing, but all in all it''s');
                  d(config.textcolor, 'just one hell of a trip...');
                end;
                10: begin
                  crlf;
                  d(config.textcolor, 'Warping into the unknown with Transactor.');
                  d(config.textcolor, 'You feel that the reality around you transforms into');
                  d(config.textcolor, 'atoms of light. Your body loses it''s contours before');
                  d(config.textcolor, 'you takeoff into the unknown realitys of your subconscious...');
                end;
              end; {case .end.}

              crlf;
              pause;
              xx := random(11);

              if (xx = 0) and (i > 0) then
              begin

                player.hps := -9000;
                {player.allowed:=false;}
                Reduce_Player_Resurrections(player, True);

                crlf;
                d(config.textcolor, 'Oh my god....something went wrong!');
                d(config.textcolor, 'Your body is in turmoil under the heavy drugs');
                d(config.textcolor, 'you just took. An overdose! You fade away....');
                crlf;
                show_usurper_data(picture_death_head, False);
                d(config.textcolor, 'Darkness...');

                {News-paper}
                newsy(True,
                  'Overdose!',
                  ' ' + uplc + player.name2 + config.textcol1 + ' took an overdose and died. One yunkie less to worry about.',
                  '',
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

                case i of
                  1: x := 100 + random(100);
                  2: x := 300 + random(300);
                  3: x := 700 + random(700);
                  4: x := 1000 + random(1000);
                  5: x := 2000 + random(2000);
                  6: x := 3000 + random(3000);
                  7: x := 4000 + random(4000);
                  8: x := 5000 + random(5000);
                  9: x := 6000 + random(6000);
                  10: x := 9000 + random(10000);
                end;

                {x:=x-random(player.addict);}

                if x <= 0 then
                  x := 50;

                Inc(player.exp, x);

                crlf;
                d(config.textcolor, 'Successful Trip!');
                d(config.textcolor, '******************');
                d(config.textcolor, 'You receive ' + uwhite + commastr(x) + config.textcol1 + ' experience points.');
                d(config.textcolor, '(Don''t turn into a dopey!)');
                crlf;

                case i of
                  1: x := 2 + random(2);
                  2: x := 4 + random(2);
                  3: x := 8 + random(3);
                  4: x := 10 + random(3);
                  5: x := 14 + random(4);
                  6: x := 15 + random(6);
                  7: x := 18 + random(6);
                  8: x := 19 + random(8);
                  9: x := 20 + random(8);
                  10: x := 20 + random(10);
                end;

                if player.race = Gnome then
                begin
                  x := x - 2;
                  if x <= 0 then
                    x := 0;
                end;

                player.addict := player.addict + x;
                if player.addict > 100 then
                  player.addict := 100;

                pause;
                case random(5) of
                  0: s := uplc + player.name2 + config.textcol1 + ' got high on some heavy drugs.';
                  1: s := uplc + player.name2 + config.textcol1 + ' shot himself full of drugs.';
                  2: s := uplc + player.name2 + config.textcol1 + ' escaped reality with the help of drugs.';
                  3: s := uplc + player.name2 + config.textcol1 + ' boosted his experience with a skytripper.';
                  4: s := uplc + player.name2 + config.textcol1 + ' made his way to dreamland with a dose of chemicals.';
                end;

                newsy(True,
                  'Drug Trip',
                  ' ' + s,
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                normal_exit;

              end;
            end;
          end else
          begin
            cho := 'A';
          end;
        end;
      end;
      'L': begin {list drugs}
        clearscreen;
        crlf;
        d(6, 'Drug               Cost     Comment');
        for i := 1 to drugnr do
        begin
          justval := 3;
          sd(10, ljust(commastr(i), justval));

          justval := 16;
          sd(5, ljust(drug[i]^, justval));
          justval := 9;
          sd(14, ljust(commastr(drugprice[i]^), justval));
          d(config.textcolor, comment[i]^);
        end;

      end;

    end; {case .end.}

  until cho = 'R';

  crlf;

  {dispose of pointer vars}
  for i := 1 to drugnr do
  begin
    dispose(drug[i]);
    dispose(drugprice[i]);
    dispose(comment[i]);
  end; {for i:= .end.}

end;   {Drug_store *end*}

end.   {Unit Drugs .end.}
