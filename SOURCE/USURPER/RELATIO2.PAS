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



unit Relatio2; {Usurper - relation routines 2/2 ..
                          .. see also relation.pas }

interface

uses
  Init;

{children}
function Child_Marks(const child: ChildRec): s70;
function Child_Adopted(const child: ChildRec): boolean;
function Give_Me_Newborn_Childname(const child: ChildRec): s70;
function Child_Location_String(const child: childrec): s70;
function Child_Health_String(const child: childrec): s70;
procedure Child_View(const child: childrec);

{top-list}
function RelationConstant_to_TopList(const inrel: longint): s70;
function RelationConstant_to_TopList2(const inrel: longint): s70;
function RelationConstant_to_String(const inrel: longint): s70;

{relations}
procedure Relation_Change_News(const pl1, pl2: userrec; const newrelval: word);
procedure Relation_CheckPlyRec(var relation: relationrec);
procedure Relations_Editor; {for debugging purposes only!}
procedure Validate_All_Relations(const step_through: boolean); {deletes all relations that cannot be

{npc - maint}
procedure Npc_Set_Out_To_Marry;


implementation

uses
  CMS, Jakob, Various,
  Various3, News,
  Mail, File_Io, GenNews,
  Children, File_Io2, Relation;

function Child_Adopted(const child: ChildRec): boolean;
var Result: boolean;
begin                   {is Child adopted?}

  Result := False;

  {blaha}
  if (child.mother <> '') and (child.mother <> child.orgmother) and
    (child.father <> '') and (child.father <> child.orgfather) then
  begin
    Result := True;
  end;

  {return result}
  child_Adopted := Result;

end; {child_adopted .end.}

function Child_Soul_String(const child: childrec): s20;
var Result: s20;
begin

  {init}
  Result := '';
  case child.soul of -500.. -250: Result := 'evil'; -249.. -100: Result := 'naughty'; -99..0: Result := 'bad kid';
    1..100: Result := 'normal';
    101..250: Result := 'well-behaved';
    251..500: Result := 'angel-heart';
  end; {case .end.}

  {return result}
  child_soul_string := Result;

end; {child_soul_string .end.}

function Child_Location_String(const child: childrec): s70;
         {
         returns child location.  similar func => child_health_string
         }
var
  Result: s70;
begin

  Result := '';

  case child.location of
    ChildLocation_Home: Result := uwhite + 'home'; {home with parents, default}
    ChildLocation_Orphanage: Result := uyellow + 'Royal Orphanage'; {royal orphanage}
    ChildLocation_Kidnapped: Result := ulred + 'Kidnapped'; {kidnapped}
  end; {case .end.}

  {return result}
  child_location_string := Result;

end; {child_location_string .end.}

function Child_Health_String(const child: childrec): s70;
         {
         returns child health.  similar func => child_location_string
         }
var
  Result: s70;
begin

  Result := '';

  case child.health of
    ChildHealth_Normal: Result := 'normal'; {normal health, default}
    ChildHealth_Poisoned: Result := ulred + 'poisoned!'; {poisoned}
    ChildHealth_Cursed: Result := ulred + 'cursed!'; {cursed, curses can only be ordained by Gods}
    ChildHealth_Depressed: Result := ulred + '*depressed*'; {depressed after a divorce}
  end; {case .end.}

  {return result}
  child_health_string := Result;

end; {child_health_string .end.}

procedure Child_View(const child: childrec);
const

  c1      = 2;
  c2      = 10;
  unknown = '*UNKNOWN*';
var
  s:     s70;

  lngth: integer;

begin {used in relation.pas <examine child>, also good for debugging}

  clearscreen;

  {build string}
  s := child.Name + ' (born ' + fix_date(child.birth) + ')';
  lngth := length(s);

  {name}
  d(global_kidcol, child.Name + config.textcol1 + ' (born ' + uyellow + fix_date(child.birth) + config.textcol1 + ')');

  d(1, cool_string(lngth, '=', '-', 10, 2));

  {age}
  sd(c1, 'Age: ');
  sd(c2, commastr(child.age));
  if child.age > 1 then d(c1, ' years')
  else d(c1, ' year');

  {sex}
  sd(c1, 'Sex: ');
  case child.sex of
    1: d(c2, 'male');
    2: d(c2, 'female');
  end;

  crlf;
  {location}
  sd(c1, 'Location: ');
  d(c2, child_location_string(child));


  {health}
  sd(c1, 'Health: ');
  d(c2, child_health_string(child));

  {soul}
  sd(c1, 'Soul: ');
  d(c2, child_soul_string(child));

  {marks, bastard..royal..etc etc}
  if child_marks(child) <> '' then
  begin
    d(c1, child_marks(child));
  end;

  if child.deleted then
  begin
    d(12, '****MARKED FOR DELETION****');
  end;

  crlf;
  {current mother}
  sd(c1, 'Mother: ');
  if child.mother = '' then d(12, unknown)
  else d(global_plycol, child.mother);

  {current father}
  sd(c1, 'Father: ');
  if child.father = '' then d(12, unknown)
  else d(global_plycol, child.father);

  crlf;

  if child.mother <> child.orgmother then
  begin
    {original mother}
    sd(c1, 'Biological Mother: ');
    if child.orgmother = '' then d(12, unknown)
    else d(global_plycol, child.orgmother);
  end;

  if child.father <> child.orgfather then
  begin
    {original father}
    sd(c1, 'Biological Father: ');
    if child.orgfather = '' then d(12, unknown)
    else d(global_plycol, child.orgfather);
  end;

  {  motherid : s15; {current mother ID - to match userrec ID}
  {  fatherid : s15; {current father ID - to match userrec ID}

  {  orgmotherid : s15; {original mother ID - to match userrec ID}
  {  orgfatherid : s15; {original father ID - to match userrec ID}

  {  motherai : char; {current mother ai}
  {  fatherai : char; {current father ai}

  {  orgmotherai : char; {original mother ai}
  {  orgfatherai : char; {original father ai}

  {  motherrace : races; {current mother race}
  {  fatherrace : races; {current father race}

  {  orgmotherrace : races; {original mother race}
  {  orgfatherrace : races; {original father race}


  {mother access}
  if child.motherAccess = False then
  begin
    d(12, child.mother + ' is DENIED access to ' + child.Name);
  end;

  {father access}
  if child.fatherAccess = False then
  begin
    d(12, child.father + ' is DENIED access to ' + child.Name);
  end;

  {kidnapper}
  if child.kidnapper <> '' then
  begin
    d(12, child.Name + ' has been kidnapped!');
    d(12, 'Ransom demanded: ' + commastr(child.ransom_demanded));
  end;

  if child.royal = 0 then d(c1, 'child is not of royal blood')
  else d(c1, 'CHILD IS ROYAL');

end; {child_view .end.}

function Child_Marks(const child: ChildRec): s70;
const
  royal_sign     = '<r>'; {the mark of a royal child}
  adopted_sign   = '<a>'; {the mark of a adopted child}
  bastard_sign   = '<b>'; {the mark of a bastard}
  orphanage_sign = '<o>'; {the mark of a child being at the Royal Orphanage}
  kidnapped_sign = '<k>'; {the mark of a child being kidnapped}

var Result: s70;
  {returns bastard,orphanage,adopted,}
  procedure add_red;
  begin
    if Result = '' then Result := ulred;
  end; {add_red .end.}

begin
  Result := '';

  {royal}
  if child.royal > 0 then
  begin
    add_red;
    Result := Result + royal_sign;
  end;

  {bastard}
  if child.bastard = True then
  begin
    add_red;
    Result := Result + bastard_sign;
  end;

  {adopted}
  if child_adopted(child) then
  begin
    add_red;
    Result := Result + adopted_sign;
  end;

  {kidnapped/orphanage}
  case child.location of
    childlocation_kidnapped: begin
      add_red;
      Result := Result + kidnapped_sign;
    end;
    childlocation_orphanage: begin
      add_red;
      Result := Result + orphanage_sign;
    end;
  end; {case .end.}


  {return result}
  child_marks := Result;

end; {child_marks .end.}

function RelationConstant_to_TopList2(const inrel: longint): s70;
var Result: s70;
begin

  Result := '';
  case inrel of
    global_RelationMarried: Result := 'marriages **should never be use**';
    global_RelationLove: Result := 'loved by';
    global_RelationPassion: Result := 'cared by';
    global_RelationFriendship: Result := 'friends';
    global_RelationTrust: Result := 'trusted by';
    global_RelationRespect: Result := 'respected by';

    global_RelationNone: Result := '*none*'; {returned by social_relation}
    global_RelationNormal: Result := 'normal'; {default relation value}

    global_RelationSuspicious: Result := 'suspected by';
    global_RelationAnger: Result := 'foes';
    global_RelationEnemy: Result := 'enemies';
    global_RelationHate: Result := 'hated by';

  end; {case .end.}

  {return result}
  RelationConstant_to_TopList2 := Result;

end; {RelationConstant_to_TopList2 .end.}

function RelationConstant_to_TopList(const inrel: longint): s70;
var Result: s70;
begin

  Result := '';
  case inrel of
    global_RelationMarried: Result := ', most married players **this should not be called**';
    global_RelationLove: Result := ', most loved players                 loved by';
    global_RelationPassion: Result := ', most cared for players             cared by';
    global_RelationFriendship: Result := 'players with most friends         friends';
    global_RelationTrust: Result := ', most trusted players            trusted by';
    global_RelationRespect: Result := ', most respected players          respected by';

    global_RelationNone: Result := '*none*'; {returned by social_relation}
    global_RelationNormal: Result := 'normal'; {default relation value}

    global_RelationSuspicious: Result := ', most suspicious';
    global_RelationAnger: Result := ', most anger';
    global_RelationEnemy: Result := ', players with most enemies       enemies';
    global_RelationHate: Result := ', most hated players              hated by';

  end; {case .end.}

  {return result}
  RelationConstant_to_TopList := Result;

end; {RelationConstant_to_TopList .end.}

function RelationConstant_to_String(const inrel: longint): s70;
var Result: s70;
begin

  Result := '';
  case inrel of
    global_RelationMarried: Result := 'married';
    global_RelationLove: Result := 'love';
    global_RelationPassion: Result := 'passion';
    global_RelationFriendship: Result := 'friendship';
    global_RelationTrust: Result := 'trust';
    global_RelationRespect: Result := 'respect';

    global_RelationNone: Result := '*none*'; {returned by social_relation}
    global_RelationNormal: Result := 'normal'; {default relation value}

    global_RelationSuspicious: Result := 'suspicious';
    global_RelationAnger: Result := 'anger';
    global_RelationEnemy: Result := 'enemy';
    global_RelationHate: Result := 'hate';

  end; {case .end.}

  {return result}
  relationConstant_to_String := Result;

end; {relationConstant_to_String .end.}

function Give_Me_Newborn_Childname(const child: ChildRec): s70;
var
  s:        s70;

  cnr:      byte;

  go_ahead: boolean;

  tempfilename: s90;

begin {called from name_babies. fetches a childname based on childs gender}

  { childmalef  = datadir+'CHILDMAL.DAT'; children, male names *used by npcs*}
  { childfemalef= datadir+'CHILDFEM.DAT';children, female names *used by npcs*}

  {init}
  s := '';
  cnr := 1;
  go_ahead := True;

  case child.sex of
    1: begin {get male name}
      tempfilename := global_childmalef;
      cnr := 1;
    end;
    2: begin {get female name}
      tempfilename := global_childfemalef;
      cnr := 2;
    end;
  end; {case .end.}

  {if the childname datafiles does not exist, then we create them}
  if f_exists(tempfilename) = False then
  begin
    if create_childrenfile(cnr) = False then go_ahead := False;
  end;

  if go_ahead = True then
  begin
    s := get_random_line_from_textfile(tempfilename);
  end;

  {return result}
  give_me_newborn_childname := s;

end; {give_me_mewborn_childname *end*}

function Correct_Relation_Recnr(correct_who: byte; var relation: relationrec): boolean;
var
  ReturnFileId: byte;
  x:      word;

  InAi:   char;
  InId:   s30;

  Result: boolean;

begin

  {init}
  Result := False;

  case correct_who of
    1: begin
      inid := relation.idtag1;
      inai := relation.ai1;
    end;
    2: begin
      inid := relation.idtag2;
      inai := relation.ai2;
    end;
  end; {case .end.}


{ if global_utest then begin
  d(config.textcolor,'Auto-Correcting '+uplc+inName+config.textcol1+' relation recnr...');
 end;

 {locate player}
  x := look_for_id(InId, InAi, ReturnFileId);
  if x < 1 then
  begin
    {lets try the other playerfile}
    case inai of
      'H': inai := 'C';
      'C': inai := 'H';
    end;
    x := look_for_id(InId, InAi, ReturnFileId);
  end;

  if x > 0 then
  begin

    if global_utest then
    begin
  { d(14,'Found Match in Userfile! Id tags in relation record and userfile matches!');
   d(14,'IdTags : '+InId+' / '+InId);
  }
    end;

    {set new idtag}
    case correct_who of
      1: begin
        Relation.recnr1 := x;
        Relation.filetype1 := ReturnFileId;
      end;
      2: begin
        Relation.recnr2 := x;
        Relation.filetype2 := ReturnFileId;
      end;
    end; {case .end.}

    if global_utest then
    begin
      d(15, 'Saving record pos#' + commastr(relation.recnr) + ' with new relation.recnr value :' + commastr(x));
    end;

    {save relation}
    load_relation(fsave, relation, relation.recnr);

    {set result}
    Result := True;

  end;

  {return result}
  correct_relation_recnr := Result;

end; {correct_relation_recnr .end.}

procedure Relation_CheckPlyRec(var relation: relationrec);
var
  i:   byte;

  relation_filtyp: byte;
  relation_recnr: word;
  relation_idtag: s30;

  loadres, result_person1, result_person2: boolean;

  ply: userrec;

  procedure ubeta_text;
  begin

{ if global_utest then begin
  d(14,'***MATCH***');
  d(14,'Id tags in relation record and userfile match!');
  d(14,'IdTags : '+ply.id+' / '+relation_idtag);
  d(14,'***MATCH***');
 end;
 }
  end;

begin {persons recnr in RELATION to #record nr in userfile
      if auto_correct=yes then we locate proper values, if no correct
      values are found then we return false }

 {if either one (or both) of the characters are not found then the relation
  record is marked for deletion}
  result_person1 := False;
  result_person2 := False;

  {scan relation1 and then relation2}
  for i := 1 to 2 do
  begin

    case i of
      1: begin
        relation_recnr := relation.recnr1;
        relation_idtag := relation.idtag1;
        relation_filtyp := relation.filetype1;
      end;
      2: begin
        relation_recnr := relation.recnr2;
        relation_idtag := relation.idtag2;
        relation_filtyp := relation.filetype2;
      end;
    end; {case .end.}

    loadres := Load_Character(ply, relation_filtyp, relation_recnr);

    if loadres then
    begin
      {match idtags}
      if ply.id = relation_idtag then
      begin

        {remove marked for deletion flag}
        case i of
          1: result_person1 := True;
          2: result_person2 := True;
        end; {case .end.}

        ubeta_text;

      end else loadres := False;
    end;

    if not loadres then
    begin

      if global_utest then
      begin
        d(12, 'Alert! RECNR ' + commastr(relation.recnr) + ' not matching. Attempting to auto-correct...');
      end;

      if correct_relation_recnr(i, relation) = True then
      begin
        {remove marked for deletion flag}
        case i of
          1: result_person1 := True;
          2: result_person2 := True;
        end; {case .end.}

        ubeta_text;

      end;

    end;

  end; {for i:= .end.}

  {delete record?}
  if (result_person1 = False) or (result_person2 = False) then
  begin
    if global_utest then
    begin
      d(12, 'Deleting Record! (#' + commastr(relation.recnr) + ') ' + relation.name1 + ' and ' + relation.name2);
    end;
    relation.deleted := True;
    load_relation(fsave, relation, relation.recnr);
  end;

end; {Relation_CheckPlyRec *end*}

procedure validate_all_relations; {deletes all relations that cannot be
                                   verified (players not found)}
var
  i:        word;

  override: boolean;

  relation: RelationRec;

begin {called by relation.pas => Relation_Maintenance
                 file_io.pas =>pack_relations}

  for i := 1 to fs(FsRelation) do
  begin

    {load relation}
    load_relation(fload, relation, i);
    if relation.deleted = False then
    begin
      relation_checkplyrec(relation);
    end;

    if (step_through) and (override) then
    begin
      if confirm('Continue', 'Y') = False then break;
      if confirm('Skip continue question', 'N') = True then override := False;
    end;

  end; {for i:= .end.}

end; {validate_all_relations *end*}




procedure Relations_Editor; {for debugging purposes only!}
var

  ply, ply2: userrec;

  done, dimmy, really_done: boolean;

  x:         byte;

  ch:        char;

  s:         s90;

begin

  really_done := False;
  repeat
    crlf;
    crlf;
    d(11, 'Relations Editor');
    d(2, 'Who are you looking for?');
    if select_character(ply, False) = True then
    begin

      done := False;
      repeat
        crlf;
        d(global_plycol, ply.name2);
        menu('(V)iew relations');
        menu('(E)dit relations');
        menu('(S)et out to marry');
        menu('(M)aintain relations');
        menu('(1) maintain spouse');
        menu('(C)reate new relations');
        menu('(F)amily');
        menu('(G)et child name!');
        menu('(Q)uit');
        sd(2, ':');

        {get user-input}
        ch := upcase(getchar);

        case ch of
          'Q': begin {quit editor}
            done := True;
            really_done := True;
          end;
          'G': begin
            crlf;
            menu('(M)ale name');
            menu('(F)emale name');
            sd(2, ':');

            {get user-input}
            ch := upcase(getchar);
            crlf;

            case ch of
              'M': begin
                s := get_random_line_from_textfile(global_childmalef);
                d(11, s);
                crlf;
                pause;
              end;
              'F': begin
                s := get_random_line_from_textfile(global_childfemalef);
                d(11, s);
                crlf;
                pause;
              end;
            end; {case .end.}

          end;

          'E': begin {edit relations}
            crlf;
            d(5, 'Select 1st person');
            if Select_Character(ply, False) = True then
            begin
              d(5, 'Select 2nd person');
              if Select_Character(ply2, False) = True then
              begin
                {display char1 and char2s current relation}
                View_One_Relation(ply.name2, ply2.name2, True);

                d(15, 'Edit');
                pause;
              end;
            end;

          {edit gawain to love mia, and then let mia marry gawain
           }
          end; {edit relations .end.}

          'V': begin {view relations}
            crlf;
            d(15, 'Hang on...');
            {display persons relations}
            personal_relations(ply, False);

          end;

          'S': begin {set out to marry}
            crlf;
            sd(15, 'Hang on... setting out to marry');
            {npc_set_out_to_marry(ply);}
            crlf;
          end;
          'M': begin {maintain relations}
            crlf;
            sd(15, 'Hang on... maintaining relations');
            npc_change_relations(ply);
            crlf;
          end;
          '1': begin {maintain spouse}
            crlf;
            sd(15, 'Hang on... maintaining spouse');
            {npc_spouse_maint(ply);}
            crlf;
          end;
          'F': begin {family}
            crlf;
            sd(15, 'Hang on... fetching ' + uplc + ply.name2 + adds(ply.name2) + config.textcol1 + ' family...');

            {spouse}
            s := is_player_married(ply.name2, ply.id);
            crlf;
            if s <> '' then
            begin
              d(global_plycol, ply.name2 + config.textcol1 + ' is married to ' + uplc + s + config.textcol1 + '.');
            end else
            begin
              d(global_plycol, ply.name2 + config.textcol1 + ' isn''t married.');
            end;

            {children}
            Display_Own_Children(ply, True, True, True);

            crlf;
            pause;

          end;

          'C': begin {create new relations}

            crlf;
            d(15, 'How many new relations should we create?');
            sd(2, ':');
            x := get_number(0, 255);

            if x > 0 then
            begin
              if confirm('Only create new relations with opposite sex', 'N') = True then dimmy := True
              else dimmy := False;
              crlf;
              sd(15, 'Hang on..');
              create_new_relations(ply, x, dimmy);
              crlf;
              pause;
            end;
          end;

        end; {case .end.}

      until done;

    end else
    begin
      if confirm('Exit Relations Editor', 'N') = True then really_done := True;
    end;

  until really_done;

end; {relations_editor *end*}

procedure Relation_Change_News(const pl1, pl2: userrec; const newrelval: word);
var header: s30;
begin

  {exit if configuration has been set to NOT DISPLAY RELATION CHANGES}
  if (config.RelationChangesNews = 0) or (global_maintrunning = True) then exit;

  case random(3) of
    0: header := 'Relations';
    1: header := 'Feelings';
    2: header := 'Emotions';
  end;

  {news-paper}
  Newsy(True,
    header,
    ' ' + Relation_String(False, pl1.name2, pl2.name2, newrelval),
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end; {relation_change_news *end*}

procedure Npc_Set_Out_To_Marry; {called from npcmaint.pas}
var
  i, ii:    word;
  x:        longint;
  s:        s70;
  child:    childrec;
  marry, spouse: userrec;
  relation: relationrec;

begin {called from npcmaint.pas. player marries the first girl/boy he can find}
  {scan relations for a LOVE-LOVE relation}
  for i := 1 to fs(FsRelation) do
  begin
    if i mod 100 = 0 then sd(12, '.');
    load_relation(fload, relation, i);
    if relation.deleted = True then continue;
    if ((relation.relation1 = global_RelationLove) and
      (relation.relation2 = global_RelationLove)) and
      (relation.BannedMarry = False) and
      (relation.ai1 = 'C') and (relation.ai2 = 'C') then
    begin
      if is_player_married(relation.name1, relation.idtag1) <> '' then continue;
      if is_player_married(relation.name2, relation.idtag2) <> '' then continue;

      if load_character(marry, relation.filetype2, relation.recnr1) = False then continue;
      if load_character(spouse, relation.filetype2, relation.recnr2) = False then continue;
      if (marry.age >= config.minimumagetomarry) and (spouse.age >= config.minimumagetomarry) then
      begin

        {we both love each other, lets marry!}
        relation.relation1 := global_RelationLove;
        relation.relation2 := global_RelationLove;

        {the npcs don't have to pay for their marriages!
         ^---perhaps you wanna change this later.}

        {news-paper text}
        case random(3) of
          0: s := ' The church was crowded with relatives and friends.';
          1: s := ' Not many came to honor the newly wed...';
          2: s := ' The mayor held a party for the newly wed!';
        end; {case .end.}

        {news-paper}
        newsy(True,
          'Wedding!',
          ' ' + uplc + marry.name2 + config.textcol1 + ', the ' + race_display(2, marry.race, 0) + ', and ' + uplc + spouse.name2 + config.textcol1 + ', the ' + race_display(2, spouse.race, 0) + ', were married!',
          s,
          '',
          '',
          '',
          '',
          '',
          '',
          '');

        {marriage-log, see duplicate code in lovers.pas}
        Generic_News(MarriageDivorceNews,
          False,
          ugreen + '[' + fix_date(todays_date) + '] ' + uplc + marry.name2 + ugreen + ' and ' + uplc + spouse.name2 + ugreen + ' were ' + uyellow + 'Married' + ugreen + '.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');


        {mail other player}
        s := 'Marriage!';
        post(MailSend,
          spouse.name2,
          spouse.ai,
          False,
          mailrequest_nothing,
          '',
          uyellow + s + config.textcol1,
          mkstring(length(s), underscore),
          uplc + marry.name2 + config.textcol1 + ' and You were married!',
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

        {set new relation}
        relation.relation1 := global_RelationMarried;
        relation.relation2 := global_RelationMarried;
        relation.marrieddays := 0;
        Inc(relation.marriedtimes);

        {update relation}
        load_relation(fsave, relation, relation.recnr);

        {update player married flags}
        spouse.married := True;
        marry.married := True;

        {update statistics}
        Inc(spouse.marriedtimes);
        Inc(marry.marriedtimes);


        {make children from previous marriage happy when their parents
         reunite. NOTE! This routine is copied in lovers.pas => marry_routine
         so..if you plan to make any changes here you must update that
          routine as well}

        for ii := 1 to fs(FsChildren) do
        begin

          {load child}
          if load_child(fload, child, ii) = True then
          begin

            if (child.deleted = False) and
              (my_child(marry, child) = True) and
              (my_child(spouse, child) = True) then
            begin

              {give xp for happy child}
              x := child.age * 850;

              {give parents xp}
              incplayerexp(marry, x);
              incplayerexp(spouse, x);

              {update child}
              child.motheraccess := True;
              child.fatheraccess := True;
              child.health := ChildHealth_Normal;
              load_child(fsave, child, child.recnr);

              {inform spouse of happy event and xp!}
              post(MailSend,
                spouse.name2,
                spouse.ai,
                False,
                mailrequest_nothing,
                '',
                uyellow + 'Happy Child!' + config.textcol1,
                'You receive ' + uwhite + commastr(x) + config.textcol1 + ' experience points for making your',
                sex7[child.sex] + ' ' + ukidc + child.Name + config.textcol1 + ' extremely happy by marrying',
                uplc + marry.name2 + config.textcol1 + ' the ' + classnames[marry.classid] + '.',
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

        end; {for ii:= .end.}

        {save updated player flags}
        user_save(spouse);
        user_save(marry);

        {debug}
        if True then
        begin
          {d(15,'NPC marriage between '+relation.name1+' and '+relation.name2+'!');}
        end;

      end;
    end;

  end; {for i:= .end.}

end; {npc_set_out_to_marry *end*}

end.
