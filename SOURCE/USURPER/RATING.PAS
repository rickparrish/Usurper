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



unit Rating; {Usurper - all ranking lists are created and viewed here.
                        well, ALMOST all lists are created here}

interface

procedure Child_Producers; {rankings of top child producers}
procedure Feeling_List(const feeling: word); {rankings of most "feeled" players}
procedure King_VoteResults;
procedure Ratings_and_Scores(scoretype: char);

implementation

uses
  Init, Cms, Jakob,
  Statusc, Online, Sortpl,
  Various, Various2, AnsiColr,
  Relatio2, File_Io;

{max number of users/records the routines in this unit will handle}
const maxsorts = global_maxplayers * 2;

var
  dummy: byte;

  k, y:  word;

  gap, Count, counter: integer;

  i, x, xx, j, yy: longint;

  zz, refresh, npcinc: boolean;

  nice:  array [1..maxsorts] of longint;
  nice2: array [1..maxsorts] of longint;
  nice3: array [1..maxsorts] of boolean;

procedure King_VoteResults; {displays the players votes}
const voptions = 4; {vote options}
var

  gap:     integer;

  i, j, k, x, y, total, size: longint;

  goodbye: boolean;

  results, {vote results are stored here}
  slask:   array [1..voptions] of longint; {temporary workspace}

  s:       s40;

  pl0:     ^UserRec; {temporary user record}
  king:    KingRec; {the king}

begin

  {is there a king?}
  goodbye := False;
  if f_exists(global_kingf) = False then
  begin
    goodbye := True;
  end;

  {load king data}
  load_king(fload, king);

  if king.Name = '' then
  begin
    goodbye := True;
  end;

  if goodbye then
  begin
    d(12, 'The Realm has no ruler!');
    exit;
  end;

  {display header}
  s := 'The Royal Family, popularity poll';
  d(5, s);
  d(config.textcolor, cool_string(length(s), '=', '-', 10, 2));

  {init}
  new(pl0);
  for i := 1 to voptions do
  begin
    results[i] := 0;
    slask[i] := i;
  end;

  {collect results}
  for i := 1 to 2 do
  begin

    case i of
      1: size := fs(FsPlayer);
      2: size := fs(FsNpc);
    end; {case .end.}

    for j := 1 to size do
    begin

      if load_character(pl0^, i, j) = True then
      begin

        if (pl0^.king = False) and
          (pl0^.deleted = False) and
          (pl0^.KingLastVote > 0) then
        begin
          {record vote}
          Inc(results[pl0^.KingLastVote]);
        end;
      end;

    end; {for j:= .end.}
  end; {for i:= .end.}

  {sorting}
  gap := voptions;
  while gap > 0 do
  begin
    for i := (gap + 1) to voptions do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if results[j] >= results[k] then
        begin
          j := 0;
        end else
        begin
          x := results[j];
          y := slask[j];
          results[j] := results[k];
          slask[j] := slask[k];
          results[k] := x;
          slask[k] := y;
          j := j - gap;
        end;
      end; {while .end.}
    end; {for i:= .end.}
    gap := gap div 2;
  end; {while .end.}

  {total number of votes}
  total := 0;
  for i := 1 to voptions do
  begin
    total := total + results[i];
  end;

  {display results}
  for i := 1 to voptions do
  begin

    {% of votes}
    sd(11, percent_string(results[i], total) + '%');
    sd(2, ' ');

    {vote option}
    case slask[i] of
      1: sd(config.textcolor, 'think the ' + kingstring(king.sexy) + ' is doing a fine job');
      2: sd(config.textcolor, 'rate ' + sex[king.sexy] + ' as the best Monarch we''ve ever had');
      3: sd(config.textcolor, 'feel that the ' + kingstring(king.sexy) + ' is a poor excuse for a Monarch');
      4: sd(config.textcolor, 'vote for REVOLUTION NOW!');
    end; {case .end.}

    {nr of votes}
    if results[i] = 1 then s := ' vote'
    else s := ' votes';

    d(14, ' ... ' + uwhite + '(' + commastr(results[i]) + s + ')');

  end; {for i:= .end.}

  {dispose temporary variables}
  dispose(pl0);

end; {king_voteresults *end*}

procedure Class_Popularity(filescore: boolean);
var cla:   array [1..global_maxclasses] of word;
  npc:     boolean;
  ids:     word;
  justval: byte;
  kick:    Classes;

  rr:      ^real;
  ply0:    ^UserRec;

begin

  {init pointer variables}
  new(rr);
  new(ply0);

  crlf;
  crlf;

  if config.marknpcs then
  begin
    if confirm('Include NPCs in list', 'Y') then npc := True
    else npc := False;
  end else
  begin
    npc := True;
  end;

  for i := 1 to global_maxclasses do
  begin
    cla[i] := 0;
    nice2[i] := i;
  end;

  ids := 0;

  for i := 1 to fs(FsPlayer) do
  begin

    if load_character(ply0^, 1, i) = True then
    begin

      if (ply0^.deleted = False) and
        (ply0^.name1 <> global_delname1) and
        (ply0^.name2 <> global_delname2) then
      begin

        Inc(ids);
        case ply0^.class of
          Alchemist: Inc(cla[1]);
          Assassin: Inc(cla[2]);
          Barbarian: Inc(cla[3]);
          Bard: Inc(cla[4]);
          Cleric: Inc(cla[5]);
          Jester: Inc(cla[6]);
          Magician: Inc(cla[7]);
          Paladin: Inc(cla[8]);
          Ranger: Inc(cla[9]);
          Sage: Inc(cla[10]);
          Warrior: Inc(cla[11]);
        end; {case .end.}
      end;
    end;
  end; {for i:= .end.}

  if npc then
  begin
    for i := 1 to fs(FsNPC) do
    begin

      if load_character(ply0^, 2, i) = True then
      begin
        if (ply0^.deleted = False) and
          (ply0^.name1 <> global_delname1) and
          (ply0^.name2 <> global_delname2) then
        begin
          Inc(ids);
          case ply0^.class of
            Alchemist: Inc(cla[1]);
            Assassin: Inc(cla[2]);
            Barbarian: Inc(cla[3]);
            Bard: Inc(cla[4]);
            Cleric: Inc(cla[5]);
            Jester: Inc(cla[6]);
            Magician: Inc(cla[7]);
            Paladin: Inc(cla[8]);
            Ranger: Inc(cla[9]);
            Sage: Inc(cla[10]);
            Warrior: Inc(cla[11]);
          end; {case .end.}
        end;
      end;
    end; {for i:= .end.}
  end;

  {sort classes}
  gap := global_maxclasses;
  while gap > 0 do
  begin
    for i := (gap + 1) to global_maxclasses do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if cla[j] >= cla[k] then
        begin
          j := 0;
        end else
        begin
          xx := cla[j];
          yy := nice2[j];
          cla[j] := cla[k];
          nice2[j] := nice2[k];
          cla[k] := xx;
          nice2[k] := yy;
          j := j - gap;
        end;
      end;
    end; {for i:= .end.}
    gap := gap div 2;
  end; {while .end.}

  if filescore = False then
  begin
    clearscreen;
    crlf;
    d(5, '           **** Most Popular Professions ****');
    crlf;
    crlf;
    d(7, 'Rank    Profession   Players   (%)');

    for i := 1 to global_maxclasses do
    begin
      justval := 8;
      sd(15, ljust(commastr(i) + '.', justval));
      justval := 13;

      case nice2[i] of
        1: kick := Alchemist;
        2: kick := Assassin;
        3: kick := Barbarian;
        4: kick := Bard;
        5: kick := Cleric;
        6: kick := Jester;
        7: kick := Magician;
        8: kick := Paladin;
        9: kick := Ranger;
        10: kick := Sage;
        11: kick := Warrior;
      end; {case .end.}

      sd(10, ljust(upcasestr(classnames[kick]), justval));
      justval := 10;
      sd(14, ljust(commastr(cla[i]), justval));

      xx := ids;
      rr^ := cla[i];
      if xx > 0 then
      begin
        rr^ := rr^ / xx;
        xx := round(rr^ * 100);
      end else
      begin
        xx := 0;
      end;
      d(15, commastr(xx));
    end;
  end;

  {dispose}
  dispose(rr);
  dispose(ply0);

end; {class_popularity *end*}

procedure Feeling_List; {produces top list with players with the most
                         feelings FEELING against him.. FEELING is a
                         global_relationXXX constant  (see cms.pas)}
const maxsortsF = 300;
var

  line_counter: byte;

  found1, found2: boolean;

  relation:    RelationRec;

  s:           s100;
  targetid1, targetid2: s15;

  hatecounter: array [1..maxsortsF] of word; {used by sorting routine}
  idtag:       array [1..maxsortsF] of s15; {used by sorting routine}
  filex:       array [1..maxsortsF] of word; {used by sorting routine}

  zz:          s15;
  xx, yy:      longint;

begin

  {init}
  counter := 0;
  for i := 1 to maxsortsF do
  begin
    hatecounter[i] := 0;
    idtag[i] := '';
    filex[i] := 0;
  end; {for i:= .end.}

  for i := 1 to fs(FsRelation) do
  begin

    {load relation}
    load_relation(fload, relation, i);

    if relation.deleted = False then
    begin

      if (relation.relation1 = Feeling) or
        (relation.relation2 = Feeling) then
      begin

        {set idtag}
        targetid1 := '';
        targetid2 := '';
        found1 := False;
        found2 := False;

        if relation.relation1 = feeling then targetid1 := relation.idtag2;
        if relation.relation2 = feeling then targetid2 := relation.idtag1;

        {increase already existing}
        if counter > 1 then
        begin
          for j := 1 to counter do
          begin

            if (idtag[j] = targetid1) and (targetid1 <> '') then
            begin
              Inc(hatecounter[j]);
              found1 := True;
            end;

            if (idtag[j] = targetid2) and (targetid2 <> '') then
            begin
              Inc(hatecounter[j]);
              found2 := True;
            end;

            if (found1) and (found2) then break;

          end; {for j:= .end.}
        end;

        if (not found1) and (targetid1 <> '') and (counter < maxsortsF) then
        begin
          Inc(counter);
          idtag[counter] := targetid1;
          filex[counter] := i;
          hatecounter[counter] := 1;
        end;

        if (not found2) and (targetid2 <> '') and (counter < maxsortsF) then
        begin
          Inc(counter);
          idtag[counter] := targetid2;
          filex[counter] := i;
          hatecounter[counter] := 1;
        end;

      end;
    end;

    if counter >= maxsortsF then break;

  end; {for i:= .end.}

  {sort the array we collected}
  if counter > 1 then
  begin
    {Sort routine}
    gap := counter div 2;
    while gap > 0 do
    begin
      for i := (gap + 1) to counter do
      begin
        j := i - gap;
        while (j > 0) do
        begin
          k := j + gap;
          if hatecounter[j] >= hatecounter[k] then
          begin
            j := 0;
          end else
          begin

            xx := hatecounter[j];
            yy := filex[j];
            zz := idtag[j];

            hatecounter[j] := hatecounter[k];
            filex[j] := filex[k];
            idtag[j] := idtag[k];

            hatecounter[k] := xx;
            filex[k] := yy;
            idtag[k] := zz;

            j := j - gap;
          end;
        end;
      end;
      gap := gap div 2;
    end;
    {Sorting *end*}

  end;

  {header}
  s := RelationConstant_to_String(feeling);
 {
 +RelationConstant_to_TopList(global_RelationHate);
 }

  d(11, s);
  d(config.textcolor, cool_string(length(s), '=', '-', 10, 2));


  {lets display the sorted array of characters}
  counter := 0;
  line_counter := 2;
  for i := 1 to maxsortsF do
  begin

    if filex[i] > 0 then
    begin

      {determine who we are looking for in this relation}

      {load relation}
      load_relation(fload, relation, filex[i]);

      {#}
      Inc(counter);
      s := ulgray + commastr(counter) + '. ';

      {name}
      if idtag[i] = relation.idtag1 then
      begin
        s := s + uplc + relation.name1 + config.textcol1;
      end else if idtag[i] = relation.idtag2 then
      begin
        s := s + uplc + relation.name2 + config.textcol1;
      end;

      {numbers of relations}
      s := ' ' + s + ' is ' + RelationConstant_to_TopList2(feeling);

      sd(config.textcolor, s);

      {feelings total}
      if (hatecounter[i] > 1) or (hatecounter[i] = 0) then s := ' players'
      else s := ' player';

      d(15, ' ' + commastr(hatecounter[i]) + config.textcol1 + s);

      Inc(line_counter);
    end;

    if line_counter > global_screenlines - 2 then
    begin
      line_counter := 0;
      if confirm('Continue', 'Y') = False then
      begin
        break;
      end;
    end;

  end; {for i:= .end.}

end; {feeling_list *end*}

procedure Child_Producers; {rankings of top child producers}
var
  offset, line_counter: byte;
  i, j, k:  longint;
  counter:  word;
  ply:      ^UserRec;

  npc:      boolean;

  plyfile:  array[1..maxsorts] of byte; {used by sorting routine}
  filex:    array [1..maxsorts] of word; {used by sorting routine}
  children: array [1..maxsorts] of word; {used by sorting routine}

  s:        string;
  gap:      integer;
  zz:       byte;
  xx, yy:   longint;

begin

  {init pointer vars}
  new(ply);

  {init standard vars}
  for i := 1 to maxsorts do
  begin
    children[i] := 0;
    filex[i] := 0;
    plyfile[i] := 0;
  end; {for i:= .end.}

  crlf;
  crlf;

  if config.marknpcs = True then
  begin
    if confirm('Include NPCs in list', 'Y') then npc := True
    else npc := False;
  end else
  begin
    npc := True;
  end;

  s := 'Child Makers';

  d(5, s);
  sd(5, mkstring(length(s), underscore));
  d(8, mkstring(43, ' ') + '(children)');

  {let's load all characters with children in a temporary sort array}
  counter := 0;
  for i := 1 to fs(fsplayer) do
  begin

    if load_character(ply^, 1, i) = True then
    begin

      if (ply^.name2 <> global_delname2) and
        (ply^.deleted = False) and
        (ply^.kids > 0) then
      begin

        {#}
        Inc(counter);

        plyfile[counter] := 1;
        filex[counter] := i;
        children[counter] := ply^.kids;

      end;

      {emergency break out}
      if counter = maxsorts then
      begin
        break;
      end;

    end;

  end; {for i:= .end.}

  {should we load the npcs as well?}
  if npc = True then
  begin
    for i := 1 to fs(FsNpc) do
    begin

      if load_character(ply^, 2, i) = True then
      begin

        if (ply^.name2 <> global_delname2) and
          (ply^.deleted = False) and
          (ply^.kids > 0) then
        begin

          {#}
          Inc(counter);

          plyfile[counter] := 2;
          filex[counter] := i;
          children[counter] := ply^.kids;

        end;

        {emergency break out}
        if counter = maxsorts then
        begin
          break;
        end;

      end;

    end; {for i:= .end.}
  end;

  {lets sort the array we collected}
  if counter > 1 then
  begin
    {Sort routine}
    gap := counter div 2;
    while gap > 0 do
    begin
      for i := (gap + 1) to counter do
      begin
        j := i - gap;
        while (j > 0) do
        begin
          k := j + gap;
          if children[j] >= children[k] then
          begin
            j := 0;
          end else
          begin

            xx := children[j];
            yy := filex[j];
            zz := plyfile[j];

            children[j] := children[k];
            filex[j] := filex[k];
            plyfile[j] := plyfile[k];

            children[k] := xx;
            filex[k] := yy;
            plyfile[k] := zz;

            j := j - gap;
          end;
        end;
      end;
      gap := gap div 2;
    end;
    {Sorting *end*}

  end;

  {lets display the sorted array of characters}
  counter := 0;
  line_counter := 2;
  for i := 1 to maxsorts do
  begin

    if filex[i] > 0 then
    begin

      {load right character}
      if load_character(ply^, plyfile[i], filex[i]) = True then
      begin

        {#}
        Inc(counter);
        s := ulgray + commastr(counter) + '. ';

        {name}
        s := s + uplc + ply^.name2 + config.textcol1 + ' the level ';

        {level}
        s := s + commastr(ply^.level) + ' ';

        {race}
        s := s + config.textcol1 + classnames[ply^.class] + config.textcol1;

        {display produced string}
        if ply^.sex = 1 then s := s + ' is father to '
        else s := s + ' is mother to ';

        offset := 80;
        if length(s) < offset then
        begin
          xx := offset - length(s);
          s := s + mkstring(xx, '.');
        end else if length(s) > offset then
        begin
          s := copy(s, 1, offset);
        end;

        sd(config.textcolor, s);

        {children}
        d(15, commastr(ply^.kids));

        Inc(line_counter);
      end;
    end;

    if line_counter > global_screenlines - 2 then
    begin
      line_counter := 0;
      if confirm('Continue', 'Y') = False then
      begin
        break;
      end;
    end;

  end; {for i:= .end.}

  {dispose pointer vars}
  dispose(ply);

end; {child_producers *end*}

procedure Race_Popularity(filescore: boolean);
var rac:   array [1..global_maxraces] of word;
  npc:     boolean;
  ids:     word;
  justval: byte;
  rr:      ^real;
  Ply0:    ^UserRec;
begin

  {init}
  new(rr);
  new(ply0);

  crlf;
  crlf;

  if config.marknpcs then
  begin
    if confirm('Include NPCs in list', 'Y') then npc := True
    else npc := False;
  end else
  begin
    npc := True;
  end;


  for i := 1 to global_maxraces do
  begin
    rac[i] := 0;
    nice2[i] := i;
  end;

  ids := 0;

  for i := 1 to fs(FsPlayer) do
  begin

    if load_character(ply0^, 1, i) = True then
    begin
      if (ply0^.deleted = False) and
        (ply0^.name1 <> global_delname1) and
        (ply0^.name2 <> global_delname2) then
      begin
        Inc(ids);
        case ply0^.race of
          Human: Inc(rac[1]);
          Hobbit: Inc(rac[2]);
          Elf: Inc(rac[3]);
          HalfElf: Inc(rac[4]);
          Dwarf: Inc(rac[5]);
          Troll: Inc(rac[6]);
          Orc: Inc(rac[7]);
          Gnome: Inc(rac[8]);
          Gnoll: Inc(rac[9]);
          Mutant: Inc(rac[10]);
        end;
      end;
    end;
  end;

  if npc then
  begin
    for i := 1 to fs(FsNPC) do
    begin

      if load_character(ply0^, 2, i) = True then
      begin
        if (ply0^.deleted = False) and
          (ply0^.name1 <> global_delname1) and
          (ply0^.name2 <> global_delname2) then
        begin
          Inc(ids);
          case ply0^.race of
            Human: Inc(rac[1]);
            Hobbit: Inc(rac[2]);
            Elf: Inc(rac[3]);
            HalfElf: Inc(rac[4]);
            Dwarf: Inc(rac[5]);
            Troll: Inc(rac[6]);
            Orc: Inc(rac[7]);
            Gnome: Inc(rac[8]);
            Gnoll: Inc(rac[9]);
            Mutant: Inc(rac[10]);
          end;
        end;
      end;
    end; {for i:= .end.}
  end;

  {sort races}
  gap := global_maxraces;
  while gap > 0 do
  begin
    for i := (gap + 1) to global_maxraces do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if rac[j] >= rac[k] then
        begin
          j := 0;
        end else
        begin
          xx := rac[j];
          yy := nice2[j];

          rac[j] := rac[k];
          nice2[j] := nice2[k];

          rac[k] := xx;
          nice2[k] := yy;
          j := j - gap;
        end;
      end;
    end;
    gap := gap div 2;
  end;

  if filescore = False then
  begin
    clearscreen;
    crlf;
    d(5, '           **** Most Popular Races ****');
    crlf;
    crlf;
    d(7, 'Rank    Race         Players   (%)');

    for i := 1 to global_maxraces do
    begin
      justval := 8;
      sd(15, ljust(commastr(i) + '.', justval));
      justval := 13;
      sd(10, ljust(upcasestr(race_display(3, Human, nice2[i])), justval));
      justval := 10;
      sd(14, ljust(commastr(rac[i]), justval));

      xx := ids;
      rr^ := rac[i];
      if xx > 0 then
      begin
        rr^ := rr^ / xx;
        xx := round(rr^ * 100);
      end else
      begin
        xx := 0;
      end;
      d(15, commastr(xx));
    end;
  end;

  {dispose}
  dispose(rr);
  dispose(ply0);

end; {race_popularity *end*}

procedure Equipment_Masters(filescore: boolean);
var
  o, counter: word;

  ansifile, ascifile: Text;

  loading_ok: boolean;

  temp2, eansi, easci: ^s70;

  Ply0: ^UserRec;

begin

  {instructed to write score files but if no files are defined we exit}
  if (filescore = True) and (cfg_string(78) = '') then
  begin
    if cfg_string(79) = '' then
    begin
      exit;
    end;
  end;

  {init}
  new(temp2);
  new(ply0);
  new(eansi); eansi^ := '';
  new(easci); easci^ := '';
  o := 0;

  {get score files paths/names}
  eansi^ := cfg_string(78);
  easci^ := cfg_string(79);

  for i := 1 to fs(FsPlayer) do
  begin
    if o >= maxsorts then break;
    if load_character(ply0^, 1, i) = True then
    begin
      Inc(o);
      nice[o] := ply0^.armpow + ply0^.weappow;
      if nice[o] < 0 then nice[o] := 0;
      nice2[o] := i;
      nice3[o] := True;
    end;
  end;

  if (o < maxsorts) and (npcinc = True) then
  begin
    for i := 1 to fs(FsNPC) do
    begin
      if o >= maxsorts then break;
      if load_character(ply0^, 2, i) = True then
      begin
        Inc(o);
        nice[o] := ply0^.armpow + ply0^.weappow;
        if nice[o] < 0 then nice[o] := 0;
        nice2[o] := i;
        nice3[o] := False;
      end;
    end;
  end;

  gap := o div 2;
  while gap > 0 do
  begin
    for i := (gap + 1) to o do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if nice[j] >= nice[k] then
        begin
          j := 0;
        end else
        begin
          xx := nice[j];
          yy := nice2[j];
          zz := nice3[j];
          nice[j] := nice[k];
          nice2[j] := nice2[k];
          nice3[j] := nice3[k];
          nice[k] := xx;
          nice2[k] := yy;
          nice3[k] := zz;
          j := j - gap;
        end;
      end;
    end;
    gap := gap div 2;
  end;
  counter := 0;
  if (filescore = True) and (eansi^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ansifile, eansi^) then
    begin
      wrl(10, '    ' + eansi^);

      write_to_text(ansifile, AMagentaOnBlack);
      writeln_to_text(ansifile, ' *******************************');
      writeln_to_text(ansifile, '*** Equipment Masters Top 400 ***');
      writeln_to_text(ansifile, ' *******************************');
      writeln_to_text(ansifile, ' ');
      writeln_to_text(ansifile, aYellowOnBlack + 'Rank  Name              Equipment Rating   Level' + ConvertToAnsi(config.textcolor));
      for i := 1 to o do
      begin

        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        temp2^ := ply0^.name2;
        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ansifile, ljust(temp2^, 6));

          temp2^ := ply0^.name2 + mkstring(20, '.');
          write_to_text(ansifile, copy(temp2^, 1, 21));

          temp2^ := commastr((ply0^.armpow + ply0^.weappow));

          x := length(temp2^);
          if x < 13 then
          begin
            x := 13 - x;
            temp2^ := mkstring(x, '.') + temp2^;
          end;
          write_to_text(ansifile, temp2^ + '   ');

          temp2^ := commastr(ply0^.level);
          x := length(temp2^);
          write_to_text(ansifile, ACyanonBlack);
          case x of
            1: writeln_to_text(ansifile, '    ' + temp2^);
            2: writeln_to_text(ansifile, '   ' + temp2^);
            3: writeln_to_text(ansifile, '  ' + temp2^);
          end; {case .end.}
          write_to_text(ansifile, ConvertToAnsi(config.textcolor));
        end;
      end;
      close_text(ansifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(eansi^, access_error);
    end;
  end;

  if (filescore = True) and (easci^ <> '') then
  begin

    dummy := 0;
    counter := 0;
    if open_txtfile(trewrite, ascifile, easci^) then
    begin

      wrl(10, '    ' + easci^);
      writeln_to_text(ascifile, ' *******************************');
      writeln_to_text(ascifile, '*** Equipment Masters Top 400 ***');
      writeln_to_text(ascifile, ' *******************************');
      writeln_to_text(ascifile, ' ');
      writeln_to_text(ascifile, 'Rank  Name              Equipment Rating   Level');

      for i := 1 to o do
      begin

        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        temp2^ := ply0^.name2;
        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ascifile, ljust(temp2^, 6));

          temp2^ := ply0^.name2 + mkstring(20, '.');
          write_to_text(ascifile, copy(temp2^, 1, 21));

          temp2^ := commastr((ply0^.armpow + ply0^.weappow));

          x := length(temp2^);
          if x < 13 then
          begin
            x := 13 - x;
            temp2^ := mkstring(x, '.') + temp2^;
          end;
          write_to_text(ascifile, temp2^ + '   ');

          temp2^ := commastr(ply0^.level);
          x := length(temp2^);
          case x of
            1: writeln_to_text(ascifile, '    ' + temp2^);
            2: writeln_to_text(ascifile, '   ' + temp2^);
            3: writeln_to_text(ascifile, '  ' + temp2^);
          end;
        end;
      end;
      close_text(ascifile);
    end else
    begin
      {unable to create file}
      unable_to_create(easci^, access_error);
    end;

  end;

  if filescore = False then
  begin
    clearscreen;
    crlf;
    d(5, ' *******************************');
    d(5, '*** Equipment Masters Top 400 ***');
    d(5, ' *******************************');
    crlf;
    d(5, 'Rank  Name              Equipment Rating   Level');

    Count := 6;
    counter := 0;
    for i := 1 to o do
    begin
      loading_ok := False;
      if nice3[i] then
      begin
        if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
      end else
      begin
        if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
      end;

      temp2^ := ply0^.name2;
      if (loading_ok = True) and
        (ply0^.deleted = False) and
        (ply0^.name2 <> global_delname2) then
      begin
        counter := counter + 1;
        temp2^ := commastr(counter) + '.';
        sd(config.textcolor, ljust(temp2^, 6));

        temp2^ := ply0^.name2 + mkstring(20, '.');
        sd(config.textcolor, copy(temp2^, 1, 21));

        temp2^ := commastr((ply0^.armpow + ply0^.weappow));

        x := length(temp2^);
        if x < 13 then
        begin
          x := 13 - x;
          temp2^ := mkstring(x, '.') + temp2^;
        end;
        sd(config.textcolor, temp2^ + '   ');

        temp2^ := commastr(ply0^.level);
        x := length(temp2^);
        case x of
          1: sd(3, '    ' + temp2^);
          2: sd(3, '   ' + temp2^);
          3: sd(3, '  ' + temp2^);
        end;
        crlf;
        Inc(Count);

        if Count > global_screenlines - 2 then
        begin
          Count := 0;
          if confirm('More', 'y') = False then break;
        end;
      end;
    end;
    crlf;
    pause;
    d(config.textcolor, '');
  end;

  {dispose}
  dispose(temp2);
  dispose(eansi);
  dispose(easci);
  dispose(ply0);

end; {equipment_masters *end*}

procedure Armor_Masters(filescore: boolean);
const head1 = ' ***************************';
  head2     = '*** Armor Masters Top 400 ***';
  head3     = ' ***************************';
  head4     = 'Rank  Name                     ArmorPower  Level';

var o:        word;
  ansifile, ascifile: Text;
  offset:     integer;

  loading_ok: boolean;

  s, temp2, aansi, aasci: ^s70;

  ply0:       ^UserRec;

begin

  {instructed to write score files but if no files are defined we exit}
  if (filescore = True) and (cfg_string(76) = '') then
  begin
    if cfg_string(77) = '' then
    begin
      exit;
    end;
  end;


  {init}
  new(temp2);
  new(s);
  new(ply0);

  new(aansi); aansi^ := '';
  new(aasci); aasci^ := '';

  {get file paths/names}
  aansi^ := cfg_string(76);
  aasci^ := cfg_string(77);

  o := 0;

  for i := 1 to fs(FsPlayer) do
  begin
    if o >= maxsorts then break;

    if load_character(ply0^, 1, i) = True then
    begin
      Inc(o);
      if config.classic then
      begin
        nice[o] := ply0^.apow * 11;
      end else
      begin
        nice[o] := ply0^.armpow;
      end;
      if nice[o] < 0 then nice[o] := 0;
      nice2[o] := i;
      nice3[o] := True;
    end;
  end;

  if (o < maxsorts) and (npcinc = True) then
  begin
    for i := 1 to fs(FsNPC) do
    begin
      if o >= maxsorts then break;
      if load_character(ply0^, 2, i) = True then
      begin
        Inc(o);
        if config.classic then
        begin
          nice[o] := ply0^.apow * 11;
        end else
        begin
          nice[o] := ply0^.armpow;
        end;
        if nice[o] < 0 then nice[o] := 0;
        nice2[o] := i;
        nice3[o] := False;
      end;
    end;
  end;

  gap := o div 2;
  while gap > 0 do
  begin
    for i := (gap + 1) to o do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if nice[j] >= nice[k] then
        begin
          j := 0;
        end else
        begin
          xx := nice[j];
          yy := nice2[j];
          zz := nice3[j];
          nice[j] := nice[k];
          nice2[j] := nice2[k];
          nice3[j] := nice3[k];
          nice[k] := xx;
          nice2[k] := yy;
          nice3[k] := zz;
          j := j - gap;
        end;
      end;
    end;
    gap := gap div 2;
  end;

  if (filescore = True) and (aansi^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ansifile, aansi^) then
    begin
      wrl(10, '    ' + aansi^);

      write_to_text(ansifile, AMagentaOnBlack);
      writeln_to_text(ansifile, head1);
      writeln_to_text(ansifile, head2);
      writeln_to_text(ansifile, head3);
      writeln_to_text(ansifile, ' ');
      writeln_to_text(ansifile, AYellowonBlack + head4 + ConvertToAnsi(config.textcolor));

      counter := 0;
      for i := 1 to o do
      begin
        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        temp2^ := ply0^.name2;
        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ansifile, ljust(temp2^, 6));

          temp2^ := ply0^.name2 + mkstring(20, '.');
          write_to_text(ansifile, copy(temp2^, 1, 21));

          if config.classic then
          begin
            temp2^ := commastr(ply0^.apow * 11);
          end else
          begin
            temp2^ := commastr(ply0^.armpow);
          end;

          x := length(temp2^);
          if x < 13 then
          begin
            x := 13 - x;
            temp2^ := mkstring(x, '.') + temp2^;
          end;
          write_to_text(ansifile, temp2^ + '   ');

          temp2^ := commastr(ply0^.level);
          x := length(temp2^);
          write_to_text(ansifile, ACyanonBlack);
          case x of
            1: writeln_to_text(ansifile, '    ' + temp2^);
            2: writeln_to_text(ansifile, '   ' + temp2^);
            3: writeln_to_text(ansifile, '  ' + temp2^);
          end;
          write_to_text(ansifile, ConvertToAnsi(config.textcolor));
        end;
      end;
      close_text(ansifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(aansi^, access_error);
    end;
  end;

  if (filescore = True) and (aasci^ <> '') then
  begin

    dummy := 0;

    if open_txtfile(trewrite, ascifile, aasci^) then
    begin
      wrl(10, '    ' + aasci^);
      writeln_to_text(ascifile, head1);
      writeln_to_text(ascifile, head2);
      writeln_to_text(ascifile, head3);
      writeln_to_text(ascifile, ' ');
      writeln_to_text(ascifile, head4);

      counter := 0;
      Count := 0;

      for i := 1 to o do
      begin

        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ascifile, ljust(temp2^, 6));

          temp2^ := ply0^.name2 + mkstring(20, '.');
          write_to_text(ascifile, copy(temp2^, 1, 21));

          if config.classic then
          begin
            temp2^ := commastr(ply0^.apow * 11);
          end else
          begin
            temp2^ := commastr(ply0^.armpow);
          end;

          x := length(temp2^);
          if x < 13 then
          begin
            x := 13 - x;
            temp2^ := mkstring(x, '.') + temp2^;
          end;
          write_to_text(ascifile, temp2^ + '   ');

          temp2^ := commastr(ply0^.level);
          x := length(temp2^);
          case x of
            1: writeln_to_text(ascifile, '    ' + temp2^);
            2: writeln_to_text(ascifile, '   ' + temp2^);
            3: writeln_to_text(ascifile, '  ' + temp2^);
          end;
        end;
      end;
      close_text(ascifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(aasci^, access_error);
    end;
  end;

  if filescore = False then
  begin

    clearscreen;
    crlf;
    d(5, head1);
    d(5, head2);
    d(5, head3);
    crlf;
    d(5, head4);

    counter := 0;
    Count := 6;

    for i := 1 to o do
    begin

      loading_ok := False;
      if nice3[i] then
      begin
        if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
      end else
      begin
        if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
      end;

      if (loading_ok = True) and
        (ply0^.deleted = False) and
        (ply0^.name2 <> global_delname2) then
      begin
        counter := counter + 1;
        {#}
        temp2^ := commastr(counter) + '.';
        sd(config.textcolor, ljust(temp2^, 6));

        {name}
        offset := 20;

        s^ := ply0^.name2;
        if length(s^) > offset then
        begin
          sd(global_plycol, copy(s^, 1, offset));
        end else if length(s^) < offset then
        begin
          x := offset - length(s^);
          sd(global_plycol, ply0^.name2);
          sd(config.textcolor, mkstring(x, '.'));
        end else
        begin
          sd(global_plycol, s^);
        end;

        {armor power}
        if config.classic then
        begin
          temp2^ := commastr(ply0^.apow * 11);
        end else
        begin
          temp2^ := commastr(ply0^.armpow);
        end;

        x := length(temp2^);
        if x < 13 then
        begin
          x := 13 - x;
          temp2^ := mkstring(x, '.') + temp2^;
        end;
        sd(config.textcolor, temp2^ + '   ');

        {level}
        temp2^ := commastr(ply0^.level);
        x := length(temp2^);
        case x of
          1: sd(3, '    ' + temp2^);
          2: sd(3, '   ' + temp2^);
          3: sd(3, '  ' + temp2^);
        end;
        crlf;
      end;
      Inc(Count);

      if Count > global_screenlines - 2 then
      begin
        Count := 0;
        if confirm('More', 'y') = False then break;
      end;
    end;
    crlf;
    pause;
    d(config.textcolor, '');
  end;

  {dispose}
  dispose(temp2);
  dispose(s);
  dispose(ply0);
  dispose(aansi);
  dispose(aasci);

end; {armor_masters *end*}

procedure Weapon_Masters(filescore: boolean);
const head1 = ' ****************************';
  head2     = '*** Weapon Masters Top 400 ***';
  head3     = ' ****************************';
  head4     = 'Rank  Name                     WeaponPower   Level';

var
  o:          word;
  offset:     integer;

  loading_ok: boolean;

  ansifile, ascifile: Text;

  s, temp2, slask: ^s70;

  wansi, wasci: ^s70; {scorefiles path/name}

  ply0:       ^UserRec;

begin

  {instructed to write score files but if no files are defined we exit}
  if (filescore = True) and (cfg_string(74) = '') then
  begin
    if cfg_string(75) = '' then
    begin
      exit;
    end;
  end;

  {init}
  o := 0;
  new(temp2);
  new(slask);
  new(s);
  new(ply0);
  new(wansi); wansi^ := '';
  new(wasci); wasci^ := '';

  {get file paths/names}
  wansi^ := cfg_string(74);
  wasci^ := cfg_string(75);

  for i := 1 to fs(FsPlayer) do
  begin
    if o >= maxsorts then break;
    if load_character(ply0^, 1, i) = True then
    begin
      Inc(o);
      if config.classic then
      begin
        nice[o] := ply0^.wpow * 11;
      end else
      begin
        nice[o] := ply0^.weappow;
      end;

      if nice[o] < 0 then nice[o] := 0;
      nice2[o] := i;
      nice3[o] := True;
    end;
  end;

  if (o < maxsorts) and (npcinc = True) then
  begin
    for i := 1 to fs(FsNPC) do
    begin
      if o >= maxsorts then break;
      if load_character(ply0^, 2, i) = True then
      begin
        Inc(o);
        if config.classic then
        begin
          nice[o] := ply0^.wpow * 11;
        end else
        begin
          nice[o] := ply0^.weappow;
        end;
        if nice[o] < 0 then nice[o] := 0;
        nice2[o] := i;
        nice3[o] := False;
      end;
    end;
  end;

  gap := o div 2;
  while gap > 0 do
  begin
    for i := (gap + 1) to o do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if nice[j] >= nice[k] then
        begin
          j := 0;
        end else
        begin
          xx := nice[j];
          yy := nice2[j];
          zz := nice3[j];
          nice[j] := nice[k];
          nice2[j] := nice2[k];
          nice3[j] := nice3[k];
          nice[k] := xx;
          nice2[k] := yy;
          nice3[k] := zz;
          j := j - gap;
        end;
      end;
    end;
    gap := gap div 2;
  end;
  counter := 0;
  if (filescore = True) and (wansi^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ansifile, wansi^) then
    begin
      wrl(10, '    ' + wansi^);
      write_to_text(ansifile, AMagentaOnBlack);
      writeln_to_text(ansifile, head1);
      writeln_to_text(ansifile, head2);
      writeln_to_text(ansifile, head3);
      writeln_to_text(ansifile, ' ');
      writeln_to_text(ansifile, AYellowOnBlack + head4 + ConvertToAnsi(config.textcolor));

      for i := 1 to o do
      begin
        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ansifile, ljust(temp2^, 6));

          temp2^ := ply0^.name2 + mkstring(20, '.');
          write_to_text(ansifile, copy(temp2^, 1, 23));

          if config.classic then
          begin
            temp2^ := commastr(ply0^.wpow * 11);
          end else
          begin
            temp2^ := commastr(ply0^.weappow);
          end;

          x := length(temp2^);
          if x < 13 then
          begin
            x := 13 - x;
            slask^ := temp2^;
            temp2^ := mkstring(x, '.');
          end;
          write_to_text(ansifile, temp2^);

          write_to_text(ansifile, ALtGrayonBlack + slask^ + '   ' + ConvertToAnsi(config.textcolor));

          temp2^ := commastr(ply0^.level);
          x := length(temp2^);
          write_to_text(ansifile, ACyanonBlack);
          case x of
            1: writeln_to_text(ansifile, '    ' + temp2^);
            2: writeln_to_text(ansifile, '   ' + temp2^);
            3: writeln_to_text(ansifile, '  ' + temp2^);
          end;
          write_to_text(ansifile, ConvertToAnsi(config.textcolor));

        end;
      end;
      close_text(ansifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(wansi^, access_error);
    end;
  end;

  if (filescore = True) and (wasci^ <> '') then
  begin
    dummy := 0;
    counter := 0;
    if open_txtfile(trewrite, ascifile, wasci^) then
    begin
      wrl(10, '    ' + wasci^);
      writeln_to_text(ascifile, head1);
      writeln_to_text(ascifile, head2);
      writeln_to_text(ascifile, head3);
      writeln_to_text(ascifile, ' ');
      writeln_to_text(ascifile, head4);

      for i := 1 to o do
      begin
        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ascifile, ljust(temp2^, 6));

          temp2^ := ply0^.name2 + mkstring(20, '.');
          write_to_text(ascifile, copy(temp2^, 1, 23));

          if config.classic then
          begin
            temp2^ := commastr(ply0^.wpow * 11);
          end else
          begin
            temp2^ := commastr(ply0^.weappow);
          end;

          x := length(temp2^);
          if x < 13 then
          begin
            x := 13 - x;
            temp2^ := mkstring(x, '.') + temp2^;
          end;
          write_to_text(ascifile, temp2^ + '   ');

          temp2^ := commastr(ply0^.level);
          x := length(temp2^);
          case x of
            1: writeln_to_text(ascifile, '    ' + temp2^);
            2: writeln_to_text(ascifile, '   ' + temp2^);
            3: writeln_to_text(ascifile, '  ' + temp2^);
          end;
        end;
      end;
      close_text(ascifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(wasci^, access_error);
    end;
  end;

  if filescore = False then
  begin

    clearscreen;
    crlf;
    d(5, head1);
    d(5, head2);
    d(5, head3);
    crlf;
    d(5, head4);

    counter := 0;
    Count := 6;

    for i := 1 to o do
    begin
      loading_ok := False;
      if nice3[i] then
      begin
        if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
      end else
      begin
        if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
      end;

      if (loading_ok = True) and
        (ply0^.deleted = False) and
        (ply0^.name2 <> global_delname2) then
      begin
        counter := counter + 1;
        {#}
        temp2^ := commastr(counter) + '.';
        sd(config.textcolor, ljust(temp2^, 6));

        {name}
        offset := 23;

        s^ := ply0^.name2;
        if length(s^) > offset then
        begin
          sd(global_plycol, copy(s^, 1, offset));
        end else if length(s^) < offset then
        begin
          x := offset - length(s^);
          sd(global_plycol, ply0^.name2);
          sd(config.textcolor, mkstring(x, '.'));
        end else
        begin
          sd(global_plycol, s^);
        end;

        if config.classic then
        begin
          temp2^ := commastr(ply0^.wpow * 11);
        end else
        begin
          temp2^ := commastr(ply0^.weappow);
        end;

        x := length(temp2^);
        if x < 13 then
        begin
          x := 13 - x;
          temp2^ := mkstring(x, '.') + temp2^;
        end;
        sd(config.textcolor, temp2^ + '   ');

        temp2^ := commastr(ply0^.level);
        x := length(temp2^);
        case x of
          1: sd(3, '    ' + temp2^);
          2: sd(3, '   ' + temp2^);
          3: sd(3, '  ' + temp2^);
        end;

        crlf;

      end;
      Inc(Count);

      if Count > global_screenlines - 2 then
      begin
        Count := 0;
        if confirm('More', 'y') = False then break;
      end;
    end;
    crlf;
    pause;
    d(config.textcolor, '');
  end;

  {dispose}
  dispose(temp2);
  dispose(slask);
  dispose(s);
  dispose(ply0);
  dispose(wansi);
  dispose(wasci);

end; {weapon_masters *end*}

procedure Monster_Killers(filescore: boolean);
const head1 = ' **********************************';
  head2     = '*** Monster Killers Hall of Fame ***';
  head3     = ' **********************************';
  head4     = 'Rank  Name                        Kills : Defeats    Percentage  Level';

var
  o:          word;
  offset:     integer;

  ansifile, ascifile: Text;

  loading_ok: boolean;

  s, temp, temp2, mkillansi, mkillasci: ^s70;

  ply0:       ^UserRec;

  rr:         ^real;

begin

  {instructed to write score files but if no files are defined we exit}
  if (filescore = True) and (cfg_string(82) = '') then
  begin
    if cfg_string(83) = '' then
    begin
      exit;
    end;
  end;

  {init}
  o := 0;
  new(rr);
  new(temp);
  new(temp2);
  new(s);
  new(ply0);

  new(mkillansi); mkillansi^ := '';
  new(mkillasci); mkillasci^ := '';

  {get file paths/names}
  mkillansi^ := cfg_string(82);
  mkillasci^ := cfg_string(83);

  {Sorting}
  for i := 1 to fs(FsPlayer) do
  begin
    if o >= maxsorts then break;
    if load_character(ply0^, 1, i) = True then
    begin
      Inc(o);
      nice[o] := ply0^.m_kills - ply0^.m_defeats; {killer rating}
      {if nice[i]<0 then nice[i]:=0;}
      nice2[o] := i; {points to player record}
      nice3[o] := True; {true=user, false=npc}
    end;
  end; {for i:= .end.}

  if npcinc then
  begin
    for i := 1 to fs(FsNPC) do
    begin
      if o >= maxsorts then break;


      if load_character(ply0^, 2, i) = True then
      begin
        Inc(o);
        nice[o] := ply0^.m_kills - ply0^.m_defeats;
        {if nice[o]<0 then nice[o]:=0;}
        nice2[o] := i;
        nice3[o] := False;
      end;
    end; {for i:= .end.}
  end;

  {Sort routine}
  gap := o div 2;
  while gap > 0 do
  begin
    for i := (gap + 1) to o do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if nice[j] >= nice[k] then
        begin
          j := 0;
        end else
        begin
          xx := nice[j];
          yy := nice2[j];
          zz := nice3[j];

          nice[j] := nice[k];
          nice2[j] := nice2[k];
          nice3[j] := nice3[k];

          nice[k] := xx;
          nice2[k] := yy;
          nice3[k] := zz;

          j := j - gap;
        end;
      end;
    end;
    gap := gap div 2;
  end;
  {Sorting *END*}


  {Writing Ansi-File}
  if (filescore = True) and (mkillansi^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ansifile, mkillansi^) then
    begin
      wrl(10, '    ' + mkillansi^);

      write_to_text(ansifile, AMagentaOnBlack);
      writeln_to_text(ansifile, head1);
      writeln_to_text(ansifile, head2);
      writeln_to_text(ansifile, head3);
      writeln_to_text(ansifile, ' ');
      writeln_to_text(ansifile, AYEllowOnBlack + head4 + ConvertToAnsi(config.textcolor));

      counter := 0;
      for i := 1 to o do
      begin
        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          {#}
          temp2^ := commastr(counter) + '.';
          write_to_text(ansifile, ljust(temp2^, 6));

          {name}
          ply0^.name2 := ply0^.name2 + mkstring(20, '.');
          write_to_text(ansifile, copy(ply0^.name2, 1, 20));

          {kills}
          s^ := commastr(ply0^.m_kills);
          x := length(s^);
          if x < 13 then
          begin
            x := 13 - x;
            write_to_text(ansifile, mkstring(x, '.'));
          end;

          {defeats}
          temp2^ := commastr(ply0^.m_defeats);
          x := length(temp2^);
          if x < 7 then
          begin
            x := 7 - x;
            temp2^ := temp2^ + mkstring(x, ' ');
          end;
          temp^ := s^ + ' : ' + temp2^;

          xx := ply0^.m_kills + ply0^.m_defeats;
          rr^ := ply0^.m_kills;
          if xx > 0 then
          begin
            rr^ := rr^ / xx;
            xx := round(rr^ * 100);
          end else
          begin
            xx := 0;
          end;

          {Percent (%)}
          s^ := '  ' + commastr(xx) + '%';
          x := length(s^);
          if x < 8 then
          begin
            x := 8 - x;
            s^ := mkstring(x, ' ') + s^;
          end;
          temp^ := temp^ + s^;

          write_to_text(ansifile, ALtGrayonBlack + temp^ + ACyanonBlack);

          {Level}
          writeln_to_text(ansifile, '        ' + commastr(ply0^.level) + ConvertToAnsi(config.textcolor));

        end;
      end;
      close_text(ansifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(mkillansi^, access_error);
    end;
  end;

  {Writing Ascii-File}
  if (filescore = True) and (mkillasci^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ascifile, mkillasci^) then
    begin
      wrl(10, '    ' + mkillasci^);
      writeln_to_text(ascifile, head1);
      writeln_to_text(ascifile, head2);
      writeln_to_text(ascifile, head3);
      writeln_to_text(ascifile, ' ');
      writeln_to_text(ascifile, head4);

      counter := 0;

      for i := 1 to o do
      begin
        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ascifile, ljust(temp2^, 6));

          ply0^.name2 := ply0^.name2 + mkstring(20, '.');
          write_to_text(ascifile, copy(ply0^.name2, 1, 20));

          s^ := commastr(ply0^.m_kills);
          x := length(s^);
          if x < 13 then
          begin
            x := 13 - x;
            s^ := mkstring(x, '.') + s^;
          end;

          temp2^ := commastr(ply0^.m_defeats);
          x := length(temp2^);
          if x < 7 then
          begin
            x := 7 - x;
            temp2^ := temp2^ + mkstring(x, ' ');
          end;
          temp^ := s^ + ' : ' + temp2^;

          xx := ply0^.m_kills + ply0^.m_defeats;
          rr^ := ply0^.m_kills;
          if xx > 0 then
          begin
            rr^ := rr^ / xx;
            xx := round(rr^ * 100);
          end else
          begin
            xx := 0;
          end;

          s^ := '  ' + commastr(xx) + '%';
          x := length(s^);
          if x < 8 then
          begin
            x := 8 - x;
            s^ := mkstring(x, ' ') + s^;
          end;
          temp^ := temp^ + s^;

          write_to_text(ascifile, temp^);
          writeln_to_text(ascifile, '        ' + commastr(ply0^.level));
        end;
      end;
      close_text(ascifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(mkillasci^, access_error);
    end;
  end;

  {Writing to Screen}
  if filescore = False then
  begin

    clearscreen;
    crlf;
    d(5, head1);
    d(5, head2);
    d(5, head3);
    crlf;
    d(5, head4);

    counter := 0;
    Count := 6;

    for i := 1 to o do
    begin

      {is character properly loaded?}
      loading_ok := False;
      if nice3[i] then
      begin
        if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
      end else
      begin
        if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
      end;

      if (loading_ok = True) and
        (ply0^.deleted = False) and
        (ply0^.name2 <> global_delname2) then
      begin
        counter := counter + 1;
        {#}
        temp2^ := commastr(counter) + '.';
        sd(config.textcolor, ljust(temp2^, 6));

        {name}
        offset := 20;

        s^ := ply0^.name2;
        if length(s^) > offset then
        begin
          sd(global_plycol, copy(s^, 1, offset));
        end else if length(s^) < offset then
        begin
          x := offset - length(s^);
          sd(global_plycol, ply0^.name2);
          sd(config.textcolor, mkstring(x, '.'));
        end else
        begin
          sd(global_plycol, s^);
        end;

        {Monster Kills}
        s^ := commastr(ply0^.m_kills);
        x := length(s^);
        if x < 13 then
        begin
          x := 13 - x;
          s^ := mkstring(x, '.') + s^;
        end;

        {Monster Defeats}
        temp2^ := commastr(ply0^.m_defeats);
        x := length(temp2^);
        if x < 7 then
        begin
          x := 7 - x;
          temp2^ := temp2^ + mkstring(x, ' ');
        end;
        temp^ := s^ + ' : ' + temp2^;

        {Monster %}
        xx := ply0^.m_kills + ply0^.m_defeats;
        rr^ := ply0^.m_kills;
        if xx > 0 then
        begin
          rr^ := rr^ / xx;
          xx := round(rr^ * 100);
        end else
        begin
          xx := 0;
        end;

        s^ := '  ' + commastr(xx) + '%';
        x := length(s^);
        if x < 8 then
        begin
          x := 8 - x;
          s^ := mkstring(x, ' ') + s^;
        end;
        temp^ := temp^ + s^;

        {level}
        sd(config.textcolor, temp^);
        d(3, '        ' + commastr(ply0^.level));

      end;
      Inc(Count);

      if Count > global_screenlines - 2 then
      begin
        Count := 0;
        if confirm('More', 'y') = False then break;
      end;
    end;
    crlf;
    pause;
    d(config.textcolor, '');
  end;

  {dispose}
  dispose(temp);
  dispose(temp2);
  dispose(ply0);
  dispose(s);
  dispose(rr);
  dispose(mkillansi);
  dispose(mkillasci);

end; {monster_killers *end*}

procedure Player_Killers(filescore: boolean);
const head1 = ' *********************************';
  head2     = '*** Player Killers Hall of Fame ***';
  head3     = ' *********************************';
  head4     = 'Rank  Name                        Kills : Defeats    Percentage  Level';

var
  o:          word;
  offset:     integer;

  ansifile, ascifile: Text;

  loading_ok: boolean;

  s, temp, temp2, pkillansi, pkillasci: ^s70;

  rr:         ^real;

  ply0:       ^UserRec;
begin

  {instructed to write score files but if no files are defined we exit}
  if (filescore = True) and (cfg_string(80) = '') then
  begin
    if cfg_string(81) = '' then
    begin
      exit;
    end;
  end;

  {init}
  o := 0;
  new(temp2);
  new(temp);
  new(s);
  new(rr);
  new(ply0);

  new(pkillansi); pkillansi^ := '';
  new(pkillasci); pkillasci^ := '';

  {get file paths/names}
  pkillansi^ := cfg_string(80);
  pkillasci^ := cfg_string(81);

  for i := 1 to fs(FsPlayer) do
  begin
    if o >= maxsorts then break;
    if load_character(ply0^, 1, i) = True then
    begin
      Inc(o);
      nice[o] := ply0^.p_kills - ply0^.p_defeats;
      if nice[o] < 0 then nice[o] := 0;
      nice2[o] := i;
      nice3[o] := True;
    end;
  end; {for i:= .end.}

  if (o < maxsorts) and (npcinc = True) then
  begin
    for i := 1 to fs(FsNPC) do
    begin
      if o >= maxsorts then break;
      if load_character(ply0^, 2, i) = True then
      begin
        Inc(o);
        nice[o] := ply0^.p_kills - ply0^.p_defeats;
        if nice[o] < 0 then nice[o] := 0;
        nice2[o] := i;
        nice3[o] := False;
      end;
    end; {for i:= .end.}
  end;

  gap := o div 2;
  while gap > 0 do
  begin
    for i := (gap + 1) to o do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;

        if nice[j] >= nice[k] then
        begin
          j := 0;
        end else
        begin
          xx := nice[j];
          yy := nice2[j];
          zz := nice3[j];
          nice[j] := nice[k];
          nice2[j] := nice2[k];
          nice3[j] := nice3[k];
          nice[k] := xx;
          nice2[k] := yy;
          nice3[k] := zz;
          j := j - gap;
        end;
      end;
    end; {for i:= .end.}
    gap := gap div 2;
  end;

  if (filescore = True) and (pkillansi^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ansifile, pkillansi^) then
    begin
      wrl(10, '    ' + pkillansi^);

      write_to_text(ansifile, AMagentaonBlack);
      writeln_to_text(ansifile, head1);
      writeln_to_text(ansifile, head2);
      writeln_to_text(ansifile, head3);
      writeln_to_text(ansifile, ' ');
      writeln_to_text(ansifile, AYellowOnBlack + head4 + ConvertToAnsi(config.textcolor));
      counter := 0;
      for i := 1 to o do
      begin

        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ansifile, ljust(temp2^, 6));

          ply0^.name2 := ply0^.name2 + mkstring(20, '.');
          write_to_text(ansifile, copy(ply0^.name2, 1, 20));

          s^ := commastr(ply0^.p_kills);
          x := length(s^);
          if x < 13 then
          begin
            x := 13 - x;
            write_to_text(ansifile, mkstring(x, '.'));
          end;

          temp2^ := commastr(ply0^.p_defeats);
          x := length(temp2^);
          if x < 7 then
          begin
            x := 7 - x;
            temp2^ := temp2^ + mkstring(x, ' ');
          end;
          temp^ := s^ + ' : ' + temp2^;

          xx := ply0^.p_kills + ply0^.p_defeats;
          rr^ := ply0^.p_kills;
          if xx > 0 then
          begin
            rr^ := rr^ / xx;
            xx := round(rr^ * 100);
          end else
          begin
            xx := 0;
          end;

          s^ := '  ' + commastr(xx) + '%';
          x := length(s^);
          if x < 8 then
          begin
            x := 8 - x;
            s^ := mkstring(x, ' ') + s^;
          end;
          temp^ := temp^ + s^;

          write_to_text(ansifile, ALtGrayonBlack + temp^ + ACyanonBlack);

          writeln_to_text(ansifile, '        ' + commastr(ply0^.level) + ConvertToAnsi(config.textcolor));

        end;
      end;
      close_text(ansifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(pkillansi^, access_error);
    end;
  end;

  if (filescore = True) and (pkillasci^ <> '') then
  begin
    dummy := 0;

    if open_txtfile(trewrite, ascifile, pkillasci^) then
    begin
      wrl(10, '    ' + pkillasci^);
      writeln_to_text(ascifile, head1);
      writeln_to_text(ascifile, head2);
      writeln_to_text(ascifile, head3);
      writeln_to_text(ascifile, ' ');
      writeln_to_text(ascifile, head4);
      counter := 0;
      for i := 1 to o do
      begin

        loading_ok := False;
        if nice3[i] then
        begin
          if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
        end else
        begin
          if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
        end;

        if (loading_ok = True) and
          (ply0^.deleted = False) and
          (ply0^.name2 <> global_delname2) then
        begin
          counter := counter + 1;
          temp2^ := commastr(counter) + '.';
          write_to_text(ascifile, ljust(temp2^, 6));

          ply0^.name2 := ply0^.name2 + mkstring(20, '.');
          write_to_text(ascifile, copy(ply0^.name2, 1, 20));

          s^ := commastr(ply0^.p_kills);
          x := length(s^);
          if x < 13 then
          begin
            x := 13 - x;
            s^ := mkstring(x, '.') + s^;
          end;

          temp2^ := commastr(ply0^.p_defeats);
          x := length(temp2^);
          if x < 7 then
          begin
            x := 7 - x;
            temp2^ := temp2^ + mkstring(x, ' ');
          end;
          temp^ := s^ + ' : ' + temp2^;

          xx := ply0^.p_kills + ply0^.p_defeats;
          rr^ := ply0^.p_kills;
          if xx > 0 then
          begin
            rr^ := rr^ / xx;
            xx := round(rr^ * 100);
          end else
          begin
            xx := 0;
          end;

          s^ := '  ' + commastr(xx) + '%';
          x := length(s^);
          if x < 8 then
          begin
            x := 8 - x;
            s^ := mkstring(x, ' ') + s^;
          end;
          temp^ := temp^ + s^;

          write_to_text(ascifile, temp^);
          writeln_to_text(ascifile, '        ' + commastr(ply0^.level));

        end;
      end;
      close_text(ascifile);
    end else
    begin
      {Unable to Write File}
      unable_to_create(pkillasci^, access_error);
    end;
  end;

  if filescore = False then
  begin

    clearscreen;
    crlf;
    d(5, head1);
    d(5, head2);
    d(5, head3);
    crlf;
    d(5, head4);

    Count := 6;
    counter := 0;
    for i := 1 to o do
    begin

      loading_ok := False;
      if nice3[i] then
      begin
        if load_character(ply0^, 1, nice2[i]) = True then loading_ok := True;
      end else
      begin
        if load_character(ply0^, 2, nice2[i]) = True then loading_ok := True;
      end;

      if (loading_ok = True) and
        (ply0^.deleted = False) and
        (ply0^.name2 <> global_delname2) then
      begin
        counter := counter + 1;
        {#}
        temp2^ := commastr(counter) + '.';
        sd(config.textcolor, ljust(temp2^, 6));

        {name}
        offset := 20;

        s^ := ply0^.name2;
        if length(s^) > offset then
        begin
          sd(global_plycol, copy(s^, 1, offset));
        end else if length(s^) < offset then
        begin
          x := offset - length(s^);
          sd(global_plycol, ply0^.name2);
          sd(config.textcolor, mkstring(x, '.'));
        end else
        begin
          sd(global_plycol, s^);
        end;

        {Player kills}
        s^ := commastr(ply0^.p_kills);
        x := length(s^);
        if x < 13 then
        begin
          x := 13 - x;
          s^ := mkstring(x, '.') + s^;
        end;

        {player defeats}
        temp2^ := commastr(ply0^.p_defeats);
        x := length(temp2^);
        if x < 7 then
        begin
          x := 7 - x;
          temp2^ := temp2^ + mkstring(x, ' ');
        end;
        temp^ := s^ + ' : ' + temp2^;

        {%}
        xx := ply0^.p_kills + ply0^.p_defeats;
        rr^ := ply0^.p_kills;
        if xx > 0 then
        begin
          rr^ := rr^ / xx;
          xx := round(rr^ * 100);
        end else
        begin
          xx := 0;
        end;

        s^ := '  ' + commastr(xx) + '%';
        x := length(s^);
        if x < 8 then
        begin
          x := 8 - x;
          s^ := mkstring(x, ' ') + s^;
        end;
        temp^ := temp^ + s^;

        {level}
        sd(config.textcolor, temp^);
        d(3, '        ' + commastr(ply0^.level));

      end;
      Inc(Count);

      if Count > global_screenlines - 2 then
      begin
        Count := 0;
        if confirm('More', 'y') = False then break;
      end;
    end;
    crlf;
    pause;
    d(config.textcolor, '');
  end;

  {dispose}
  dispose(s);
  dispose(rr);
  dispose(temp);
  dispose(temp2);
  dispose(ply0);

  dispose(pkillansi);
  dispose(pkillasci);

end; {player_killers *end*}

procedure Meny; {score corner, menu}
const offset = 28;
begin

  clearscreen;
  crlf;
  d(5, 'Score Corner,');
  d(7, '  the place where you get the latest rankings and scores.');
  d(7, '  With a little luck even You might be on one of the lists.');
  crlf;
  menu2(ljust('(L)ist of Characters', offset));
  menu('(1) Most popular Race');

  menu2(ljust('(U)surper Heroes', offset));
  menu('(2) Most popular Profession');
  crlf;

  menu2(ljust('(P)layer  Killers Top 400', offset));
  menu('(C)hild Producers');

  menu2(ljust('(M)onster Killers Top 400', offset));
  menu('(Q)uest Masters');

  menu2(ljust('(A)rmor  Masters', offset));
  menu('(T)he Monarch and the People');

  menu('(W)eapon Masters');
  menu('(E)quipment Masters');
  crlf;
  menu('(H)elp on Ratings');
  menu('(S)tatus');
  menu('(R)eturn to Main Street');

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
      sd(config.textcolor, 'Score Corner (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');

    end else
    begin
      if player.ear = 1 then
      begin
        who_is_here;
      end;
      crlf;
      sd(config.textcolor, 'Scores (R,1,2,C,U,P,Q,M,H,S,T,A,W,E,L,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Ratings_and_Scores; {MAIN PROC **START**}
var
  s:     s70;
  ch:    char;
  allow: boolean;

begin

  {init}
  for i := 1 to maxsorts do
  begin
    nice[i] := 0;
    nice2[i] := 0;
  end; {for i:= .end.}

  if scoretype <> ' ' then
  begin

    {fetching .cfg options}
    s := cfg_string(84);

    allow := True;
    if upcasestr(s) = 'NO' then
    begin
      allow := False;
    end;

    s := cfg_string(93);
    npcinc := True;
    if upcasestr(s) = 'NO' then
    begin
      npcinc := False;
    end;

    if (allow = True) or (scoretype = 'C') then
    begin

      if config.classic = False then
      begin
        weapon_masters(True);
      end;

      if config.classic = False then
      begin
        armor_masters(True);
      end;

      if config.classic = False then
      begin
        equipment_masters(True);
      end;

      player_killers(True);
      monster_killers(True);

    end;

    exit;
  end;

  {save user so his info will be correctly shown in the rating lists}
  user_save(player);

  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_reportroom then
    begin
      refresh := True;
      onliner.location := onloc_reportroom;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      '?': begin {Menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'H': begin {Help Text}
        crlf;
        crlf;
        d(15, 'Help-Text on Scores and Rankings');
        d(15, mkstring(32, underscore));
        crlf;
        d(15, 'PLAYER KILLERS TOP 400 :');
        d(15, ' Who has killed most players.');
        crlf;
        d(15, 'MONSTER KILLERS TOP 400 :');
        d(15, ' Who has killed most monsters.');
        crlf;
        d(15, 'ARMOR MASTERS TOP 400 :');
        d(15, ' Who has the best armor.');
        crlf;
        d(15, 'WEAPON MASTERS TOP 400 :');
        d(15, ' Who has the best weapons.');
        crlf;
        d(15, 'EQUIPMENT MASTERS TOP 400 :');
        d(15, ' Who has the best equipment.');
        crlf;
        d(15, 'QUEST MASTERS TOP 400 :');
        d(15, ' Who has completed most quests.');
        crlf;
        d(15, 'THE MONARCH AND THE PEOPLE :');
        d(15, ' What do the players think of their ruler?');
        crlf;
        pause;
      end;
      'S': begin {Player Status}
        status(player);
        crlf;
      end;
      'U': begin {Heros, who completed Usurper}
        crlf;
        crlf;

        if f_exists(global_famefile) then
        begin
          display_file(global_famefile);
        end else
        begin
          d(config.textcolor, 'There are no heroes.');
        end;

        crlf;
        pause;
      end;
      'P': begin {Player Killers}
        crlf;
        crlf;
        if config.marknpcs then
        begin
          if confirm('Include NPCs in list', 'Y') then npcinc := True
          else npcinc := False;
        end else
        begin
          npcinc := True;
        end;
        player_killers(False);
      end;
      'M': begin {Monster Killers}
        crlf;
        crlf;
        if config.marknpcs then
        begin
          if confirm('Include NPCs in list', 'Y') then npcinc := True
          else npcinc := False;
        end else
        begin
          npcinc := True;
        end;
        monster_killers(False);
      end;
      'T': begin {the Monarch and the People}
        crlf;
        crlf;
        king_voteresults;
      end;
      'A': begin {Armor Masters}
        crlf;
        crlf;
        if config.marknpcs then
        begin
          if confirm('Include NPCs in list', 'Y') then npcinc := True
          else npcinc := False;
        end else
        begin
          npcinc := True;
        end;
        armor_masters(False);
      end;
      'W': begin {Weapon Masters}
        crlf;
        crlf;
        if config.marknpcs then
        begin
          if confirm('Include NPCs in list', 'Y') then npcinc := True
          else npcinc := False;
        end else
        begin
          npcinc := True;
        end;
        weapon_masters(False);
      end;
      'E': begin {Equipment Masters}
        if config.classic = False then
        begin
          crlf;
          crlf;
          if config.marknpcs then
          begin
            if confirm('Include NPCs in list', 'Y') then npcinc := True
            else npcinc := False;
          end else
          begin
            npcinc := True;
          end;
          equipment_masters(False);
        end else
        begin
          crlf;
          d(15, 'Not available in Classic mode.');
        end;
      end;
      '1': begin {Most Popular Races}
        race_popularity(False);
      end;
      '2': begin {Most Popular Classes}
        class_popularity(False);
      end;
      'C': begin {Child Producers}
        child_producers;
      end;
      'Q': begin {Quest Rankings}
        Quest_Rankings;
      end;
      'L': begin {List of Players}
        sort_players(False);
      end;

    end; {case .end.}

  until ch = 'R';

end; {rating_and_scores *end*}

end. {Unit Rating .end.}
