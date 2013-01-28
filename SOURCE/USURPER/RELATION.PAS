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



Unit Relation; {Usurper - relation routines 1/2
                          .. see also relatio2.pas}

Interface

Uses Init;



{relations}
Function Relation_String(useYou:boolean;const rname1,rname2:s30;relation:word) : s100;
Function Are_They_Married(const pl1,pl2:userrec):boolean;
Function Is_Player_Married(const plyname2:s30;const plyid:s15) : s30;
Function Sex_Experience(const pl1,pl2:userrec) : longint;
Function Social_Relation(const pl1,pl2:userrec;var Relation:RelationRec):Word;
Procedure Replace_All_Relations(const ply:userrec;const origfeeling,newfeeling:word);
Procedure Load_My_Spouse(const me:userrec;var spouse:userrec);
Procedure Sex_Act_Routine(var pl1,pl2:userrec;humans_involved:boolean);
Procedure Give_Birth(var pl1:userrec);
Procedure Love_Header(const header:s70);
Procedure Good_Looks(const ply:userrec);
Procedure List_Banned_Relations;
Procedure List_Married_Couples; {list of married couples}
Procedure Relation_Maintenance;
Procedure Attacked_Relation_Display(const Relation:RelationRec);
Procedure Display_Relation(const plyname:s30;var Relation:RelationRec;extended_info:boolean);
Procedure View_One_Relation(const name1,name2:s30;extended_info:boolean);
Procedure Personal_Relations(const ply:UserRec;spy_mode:boolean); {list of Plys personal relations}
Procedure Correct_Relation(const plyname:s30;var relation:relationrec);
Procedure Kill_Duplicate_Relations(const ply:userrec;howmany:byte); {debug!}
Procedure Remove_Relations(const ply:userrec); {remove plys relations}
Procedure Relation_Self_Mail(const pl1,pl2:userrec; newrel:word);
Procedure Relation_Change_Mail(const pl1,pl2:userrec; newrel:word);
Procedure Update_Relation(direction:RelationCommand;steps:byte;
                          const pl1,pl2:userrec;
                          overrideautohate,
                          overridemaxfeeling:boolean);

Procedure Killed_By_Stats(const pl1,pl2:userrec);
Procedure Summary_of_Player_Relations(const ply:userrec);
Procedure Jealousy(event : byte; const ply1,ply2 : userrec);

{npc/maintenance relation stuff}
Procedure Npc_Change_Relations(var ply:userrec);
Procedure Create_New_Relations(var ply:userrec;const goal_relations:byte;opposite_sex_only:boolean);



Procedure Inform_Parent(const child:childrec;
                              MailRequest:word;
                        const ply:userrec;
                        const line1,line2,line3,line4,line5,line6,
                              line7,line8,line9,line10,line11,line12,
                              line13,line14,line15:s90);

Procedure Inform_Parents_Online(const child:childrec;const mess:s100);
Procedure Inform_Parents(const child:childrec;
                               MailRequest:word;
                         const line1,line2,line3,line4,line5,line6,
                               line7,line8,line9,line10,line11,line12,
                               line13,line14,line15:s90);

Implementation


Uses CMS, Jakob, Relatio2,
     Various, Various2, Various3,
     News, Mail, Online,
     Children, GenNews, File_Io;



{*** RELATIONS ***}
Procedure Relation_Maintenance;
var i : word;
   relation : RelationRec;
begin

 {first we weed out the bad relationships}
 validate_all_relations(false);

 {runs every day. updates the relation records.}
 for i:=1 to fs(FsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  if relation.deleted=false then begin

   if (relation.relation1=global_RelationMarried) and
      (relation.relation2=global_RelationMarried) then begin

    {how many days have the current marriage lasted}
    inc(relation.marrieddays);

   end;

   {save relation}
   load_relation(fsave,relation,i);

  end;

 end; {for i:= .end.}

end; {relation_maintenance *end*}

Procedure List_Married_Couples; {list of married couples}
var
    i : word;
    s : s70;
    line_counter : byte;
    found,abort : boolean;
    Relation : ^RelationRec; {RelationRecord}
begin

 {init pointer variables}
 new(relation);

 crlf;
 crlf;
 sd(4,heartsign+heartsign+heartsign);
 sd(4,' Married ');
 d(4,heartsign+heartsign+heartsign);
 crlf;

 found:=false;
 abort:=false;
 line_counter:=3;
 if f_exists(global_relationf) then begin
  for i:=1 to fs(fsRelation) do begin

   {load relation}
   load_relation(fload,relation^,i);

   {married?}
   if (relation^.relation1=global_relationMarried) and
      (relation^.relation2=global_relationMarried) and
      (relation^.deleted=false) then begin
    found:=true;

    if relation^.marrieddays=1 then s:='day'
                               else s:='days';

    sd(global_plycol,relation^.name1);
    sd(config.textcolor,' and ');
    sd(global_plycol,relation^.name2);
    sd(config.textcolor,' have been married for ');
    sd(15,commastr(relation^.marrieddays));
    d(config.textcolor,' '+s+'.');

    {mixed races!}
    if relation^.race1<>relation^.race2 then begin
     s:='';
     d(config.textcolor,'('+race_display(2,relation^.race1,0)+' and '
       +race_display(2,relation^.race2,0)+' combination'+s+')');
    end;
    crlf;

    inc(line_counter,3);
    if line_counter>global_screenlines-2 then begin
     line_counter:=0;
     if confirm('Continue','Y')=false then begin
      abort:=true;
     end;
    end;

   end;

   if abort then break;

  end; {for i:= .end.}
 end;

 if (not found) and (not abort) then begin
  d(12,'Nobody is married.');
 end;

 {dispose pointer variables}
 dispose(relation);

end; {list_married_couples *end*}

Procedure List_Banned_Relations;
var

   i : word;

   counter : byte;

   abort,
   any_found : boolean;

   relation : RelationRec;

begin

 {display of banned relations, the Royals ban relations= people can't marry}

 crlf;
 crlf;
 d(5,'Banned Relationships');
 d(5,mkstring(20,underscore));

 counter:=2;
 abort:=false;
 any_found:=false;
 for i:=1 to fs(FsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  if (relation.deleted=false) and (relation.bannedmarry=true) then begin

   {display banned relation}
   d(global_plycol,relation.name1+config.textcol1+' and '+uplc+relation.name2
     +config.textcol1+' are not allowed to marry.');

   any_found:=true;

   {counter}
   inc(counter);

   {pause listing?}
   if counter>global_screenlines-2 then begin
    counter:=0;
    if confirm('Continue','Y')=false then begin
     abort:=true;
    end;
   end;

  end;

  if abort then break;

 end; {for i:= .end.}

 if (not any_found) and (abort=false) then begin
  d(12,'No relations are banned in your Realm.');
 end;
 pause;

end; {list_banned_relations *end*}


Procedure Inform_Parents_Online(const child:childrec;const mess:s100);
begin
 if (child.mother<>'') and (is_online(child.mother,online_player)=true) then begin
  online_send_to_player(child.mother,online_player,mess);
 end;

 if (child.father<>'') and (is_online(child.father,online_player)=true) then begin
  online_send_to_player(child.father,online_player,mess);
 end;

end; {inform_parents_online *end*}

Procedure Inform_Parents(const child:childrec;
                         MailRequest:word;
                         const line1,line2,line3,line4,line5,line6,
                         line7,line8,line9,line10,line11,line12,line13,
                         line14,line15:s90);

{mail parents to child with message}
begin

 if child.mother<>'' then begin
  post(MailSend,
  child.mother,
  child.motherai,
  false,
  mailrequest,
  '',
  line1,
  line2,
  line3,
  line4,
  line5,
  line6,
  line7,
  line8,
  line9,
  line10,
  line11,
  line12,
  line13,
  line14,
  line15);
 end;

 if child.father<>'' then begin
  post(MailSend,
  child.father,
  child.fatherai,
  false,
  mailrequest,
  '',
  line1,
  line2,
  line3,
  line4,
  line5,
  line6,
  line7,
  line8,
  line9,
  line10,
  line11,
  line12,
  line13,
  line14,
  line15);
 end;

end; {inform_parents *end*}

Procedure Inform_Parent(const child:childrec;
                        MailRequest:word;
                        const ply:userrec;
                        const line1,line2,line3,line4,line5,line6,
                              line7,line8,line9,line10,line11,line12,
                              line13,line14,line15:s90);

{mail parent to child (not Ply but the other)}
begin

 if (child.mother<>'') and (child.mother<>ply.name2) then begin
  post(MailSend,
  child.mother,
  child.motherai,
  false,
  mailrequest,
  '',
  line1,
  line2,
  line3,
  line4,
  line5,
  line6,
  line7,
  line8,
  line9,
  line10,
  line11,
  line12,
  line13,
  line14,
  line15);
 end;

 if (child.father<>'') and (child.father<>ply.name2) then begin
  post(MailSend,
  child.father,
  child.fatherai,
  false,
  mailrequest,
  '',
  line1,
  line2,
  line3,
  line4,
  line5,
  line6,
  line7,
  line8,
  line9,
  line10,
  line11,
  line12,
  line13,
  line14,
  line15);
 end;

end; {inform_parents *end*}



Procedure New_RelationRecord(var Relation:RelationRec);
begin

 {this procedure initializes a RelationRecord}

 With Relation do begin
  name1       :='';  {player 1}
  name2       :='';  {player 2}
  ai1         :='H'; {ai}
  ai2         :='H'; {ai}
  race1       :=Human; {race1}
  race2       :=Human; {race2}
  relation1   :=Global_RelationNormal; {pl1s relation to pl2 ,see:relation constants}
  relation2   :=Global_RelationNormal; {pl2s relation to pl1 ,see:relation constants}
  recnr1      :=0;
  recnr2      :=0;
  filetype1   :=1;
  filetype2   :=1;
  idtag1      :=crypt(15);
  idtag2      :=crypt(15);
  deleted     :=false; {deleted}
  recnr       :=1; {position in file, record #}
  bannedmarry :=false; {not allowed to marry? only the king can set this option}
  marriedtimes:=0; {this couple has been married # times}
  marrieddays :=0; {married for X days}
  kids        :=0; {kids produced in this relation}
  killedby1   :=0; {name2 has been killed this many times by name1}
  killedby2   :=0; {name1 has been killed this many times by name2}
 end;

end;

Procedure Setup_Relation(const pl1,pl2:userrec;var relation : RelationRec);
const max_relations = 65500; {max relations record allowed in database}
var
    found : boolean;
    i : longint;
    size  : word;


procedure prepare_relation; {just before saving new relation}
begin

 {init all variables}
 New_RelationRecord(relation);

 {set necessary options}
 relation.name1:=pl1.name2;
 relation.name2:=pl2.name2;

 relation.ai1:=pl1.ai;
 relation.ai2:=pl2.ai;

 relation.race1:=pl1.race;
 relation.race2:=pl2.race;

 relation.idtag1:=pl1.ID;
 relation.idtag2:=pl2.ID;

 relation.recnr1:=pl1.recnr;
 relation.recnr2:=pl2.recnr;

 {player1}
 case pl1.ai of
  'H': relation.filetype1:=1;
  'C': relation.filetype1:=2;
 end;

 {player2}
 case pl2.ai of
  'H': relation.filetype2:=1;
  'C': relation.filetype2:=2;
 end;

 relation.deleted:=false; {relation is not deleted}
 relation.relation1:=global_RelationNormal; {default start relation}
 relation.relation2:=global_RelationNormal; {default start relation}

end; {prepare_relation .end.}

begin {Setup_Relation **start**}

 {init vars}
 found:=false;

 {set filesize}
 size:=global_relationfilesize;

 {look for empty/deleted record}
 for i:=1 to size do begin

  load_relationfile(fload,relation,i);

  {is releation available}
  if relation.deleted then begin
   prepare_relation;
   relation.recnr:=i;
   load_relationfile(fsave,relation,i);
   found:=true;
   break;
  end;

 end; {for i:= .end.}

 if found=false then begin
  {we must append the new relation to the end of the relation file}

  i:=size+1;

  if i>max_relations then begin
   {database is full}
   crlf;
   d(12,'ALERT! Relation database is full ('+global_relationf+').');
   d(12,'The Sysop/Programmers should be informed.');
  end
  else begin
   {saving new relation}
   prepare_relation;
   relation.recnr:=i;
   load_relationfile(fsave,relation,i);
  end;

 end;

end;

Procedure Decrease_Relation(var relation:word);
begin

 {decrease relation (RELATION) one step}
 case relation of
  global_RelationMarried     : relation:=global_RelationMarried; {no change}
  global_RelationLove        : relation:=global_RelationPassion;
  global_RelationPassion     : relation:=global_RelationFriendship;
  global_RelationFriendship  : relation:=global_RelationTrust;
  global_RelationTrust       : relation:=global_RelationRespect;
  global_RelationRespect     : relation:=global_RelationNormal;

  global_RelationNormal      : relation:=global_RelationSuspicious;

  global_RelationSuspicious  : relation:=global_RelationAnger;
  global_RelationAnger       : relation:=global_RelationEnemy;
  global_RelationEnemy       : relation:=global_RelationHate;
  global_RelationHate        : relation:=global_RelationHate;

 end; {case .end.}

end;

Procedure Increase_Relation(var relation:word;overridemaxfeeling:boolean);
begin

 {increase relation (RELATION) one step}
 case relation of
  global_RelationMarried     : relation:=global_RelationMarried; {no change}
  global_RelationLove        : relation:=global_RelationLove; {no change}
  global_RelationPassion     :begin
   if overridemaxfeeling then relation:=global_RelationLove
                         else relation:=global_RelationPassion; {no change}
  end;
  global_RelationFriendship:begin
   if overridemaxfeeling then relation:=global_RelationPassion
                         else relation:=global_RelationFriendship;
  end;
  global_RelationTrust   : relation:=global_RelationFriendship;
  global_RelationRespect : relation:=global_RelationTrust;

  global_RelationNormal  : relation:=global_RelationRespect;

  global_RelationSuspicious  : relation:=global_RelationNormal;
  global_RelationAnger       : relation:=global_RelationSuspicious;
  global_RelationEnemy       : relation:=global_RelationAnger;
  global_RelationHate        : relation:=global_RelationEnemy;
 end; {case .end.}

end;

Procedure Summary_of_Player_Relations(const ply:userrec);
var
    love_nr,
    passion_nr,
    friends_nr,
    trust_nr,
    respect_nr,
    normal_nr,
    suspect_nr,
    anger_nr,
    enemy_nr,
    hate_nr : word;

    i : word;
    ok : boolean;
    relation : RelationRec;

begin {displays a summary of ply:s relations}

 {init counter variables}
 love_nr    :=0;
 passion_nr :=0;
 friends_nr :=0;
 trust_nr   :=0;
 respect_nr :=0;
 normal_nr  :=0;
 suspect_nr :=0;
 anger_nr   :=0;
 enemy_nr   :=0;
 hate_nr    :=0;

 for i:=1 to fs(FsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  if relation.deleted=false then begin
   ok:=false;
   if (relation.name1=ply.name2) and (relation.idtag1=ply.id) then begin
    ok:=true;
   end
   else if (relation.name2=ply.name2) and (relation.idtag2=ply.id) then begin
    ok:=true;
   end;

   if ok then begin
    {set the relation right, from ply:s point of view}
    Correct_Relation(ply.name2,relation);
    {store other characters view of ply}
    case relation.relation2 of
     global_RelationLove       : inc(love_nr);
     global_RelationPassion    : inc(passion_nr);
     global_RelationFriendship : inc(friends_nr);
     global_RelationTrust      : inc(trust_nr);
     global_RelationRespect    : inc(respect_nr);
     global_RelationNormal     : inc(normal_nr); {default relation value}
     global_RelationSuspicious : inc(suspect_nr);
     global_RelationAnger      : inc(anger_nr);
     global_RelationEnemy      : inc(enemy_nr);
     global_RelationHate       : inc(hate_nr);
    end; {case .end.}
   end;

  end;
 end; {for i:= .end.}

 {display summary}
 if love_nr>0 then begin
  if love_nr=1 then d(15,commastr(love_nr)+config.textcol1+' person loves you!')
               else d(15,commastr(love_nr)+config.textcol1+' people love you!');
 end;
 if passion_nr>0 then begin
  if passion_nr=1 then d(15,commastr(passion_nr)+config.textcol1+' person likes you very much.')
                  else d(15,commastr(passion_nr)+config.textcol1+' people like you very much.');
 end;
 if friends_nr>0 then begin
  if friends_nr=1 then d(config.textcolor,'You have '+uwhite+commastr(friends_nr)+config.textcol1+' friend.')
                  else d(config.textcolor,'You have '+uwhite+commastr(friends_nr)+config.textcol1+' friends.');
 end;
 if trust_nr>0 then begin
  if trust_nr=1 then d(15,commastr(trust_nr)+config.textcol1+' people trust you.')
                else d(15,commastr(trust_nr)+config.textcol1+' person trusts you.');
 end;
 if respect_nr>0 then begin
  if respect_nr=1 then d(15,commastr(respect_nr)+config.textcol1+' person respects you.')
                  else d(15,commastr(respect_nr)+config.textcol1+' people respect you.');
 end;
 if normal_nr>0 then begin
  {}
 end;
 if suspect_nr>0 then begin
  if suspect_nr=1 then d(15,commastr(suspect_nr)+config.textcol1+' person doesn''t trust you.')
                  else d(15,commastr(suspect_nr)+config.textcol1+' people don''t trust you.');
 end;
 if anger_nr>0 then begin
  if anger_nr=1 then d(15,commastr(anger_nr)+config.textcol1+' person is angry with you.')
                else d(15,commastr(anger_nr)+config.textcol1+' people are angry with you.');
 end;
 if enemy_nr>0 then begin
  if enemy_nr=1 then d(config.textcolor,'You have '+uwhite+commastr(enemy_nr)+config.textcol1+' real enemy.')
                else d(config.textcolor,'You have '+uwhite+commastr(enemy_nr)+config.textcol1+' real enemies.');
 end;
 if hate_nr>0 then begin
  if hate_nr=1 then d(15,commastr(hate_nr)+config.textcol1+' person HATES you!')
               else d(15,commastr(hate_nr)+config.textcol1+' people HATE you!');
 end;

end; {summary_of_player_relations *end*}

Procedure Killed_By_Stats(const pl1,pl2:userrec);
var relation : RelationRec;
begin

  {this proc is called when pl1 has killed pl2, we will update the
   statistics in the relations datafile, regarding "Pl2 killed by Pl1 X
   times"}

 {load players current relation}
 social_relation(pl1,pl2,relation);

 {set the relation right, from pl1:s point of view}
 Correct_Relation(pl1.name2,relation);

 {set new stats}
 if relation.killedby1<60000 then begin
  inc(relation.killedby1)
 end;

 {save updated record}
 load_relation(fsave,relation,relation.recnr);

end; {killed_by_stats *end*}

Procedure Update_Relation(direction:RelationCommand;
                          steps:byte;
                          const pl1,pl2:userrec;
                          overrideautohate,
                          overridemaxfeeling:boolean);
var
    i : byte;
    mem : byte;
    relation : RelationRec;

begin {pl1 trust for pl2 increases/decreases by STEPS}

 {let's calculate pl1:s new attitude will be when we decrease the
  current attitude by STEPS}

 {we exit if pl1 has his setting pl1.autohate to '0' }

 {
 d(15,'UPDATING RELATION (1/2) '+commastr(pl1.autohate)+'/'+commastr(pl2.autohate));
 evaluate}

 if (pl1.AutoHate=0) and (overrideautohate=false)  then begin
  if direction=Relation_Worsen then begin
   exit; {exit this procedure!}
  end;
 end;

 {
 d(15,'UPDATING RELATION (2/2) '+commastr(pl1.autohate)+'/'+commastr(pl2.autohate));
 evaluate}

 {load current relation}
 social_relation(pl1,pl2,relation);

 {set the relation right, from pl1:s point of view}
 Correct_Relation(pl1.name2,relation);

 {remember old relation}
 mem:=relation.relation1;

 {set new relation}
 for i:=1 to steps do begin
  case direction of
   Relation_Better: Increase_Relation(relation.relation1,overridemaxfeeling);
   Relation_Worsen: Decrease_Relation(relation.relation1);
  end; {case .end.}
 end; {for i:= .end.}

 {only update if relation changed}
 if relation.relation1<>mem then begin

  {save updated relation}
  load_relation(fsave,relation,relation.recnr);

  {inform pl1 of pl1:s changed attitude}
  Relation_Self_Mail(pl1,pl2,relation.relation1);

  {inform pl2 of pl1:s changed attitude}
  Relation_Change_Mail(pl1,pl2,relation.relation1);

  {put new relation in the news}
  Relation_Change_News(pl1,pl2,relation.relation1);

 end;

end; {Update_Relation **END**}


Procedure Relation_Self_Mail(const pl1,pl2:userrec; newrel:word);
var s,s2 : s90;
    name1 : s70;
begin

 {pl1 has changed his relations towards pl2, but pl1 was offline when
  it happened (autohate)

  this proc mails pl1 of the new relation status
  NEWREL contains the relation_constant}

 s:='Feelings';
 name1:=uplc+pl2.name2+config.textcol1;

 s2:='*error*';
 case NewRel of {see global_relation??? constants in CMS.PAS}
  global_RelationMarried     : s2:='You are married to '+name1+'!';
  global_RelationLove        : s2:='You are in love with '+name1+'!';
  global_RelationPassion     : s2:='You have a crush for '+name1+'!';
  global_RelationTrust       : s2:='You trust '+name1+'.';
  global_RelationFriendship  : s2:='You consider '+name1+' among your friends.';

  global_RelationRespect     : s2:='You hold '+name1+' in great respect.';

  global_RelationNormal      : s2:='You feel nothing special for '+name1+'.';

  global_RelationSuspicious  : s2:='You think '+name1+' is a shady character.';
  global_RelationAnger       : s2:='You are angry with '+name1+'!';
  global_RelationEnemy       : s2:=name1+' is your enemy!';
  global_RelationHate        : s2:='You '+ulred+'hate '+name1+'!';

 end; {case .end.}

 {inform other player about thee relation change}
 post(MailSend,
 pl1.name2,
 pl1.ai,
 false,
 mailrequest_nothing,
 '',
 BackUblue+ulmag+s+BackUBlack+config.textcol1,
 mkstring(length(s),underscore),
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
 '',
 '');

end;

Procedure Relation_Change_Mail(const pl1,pl2:userrec; newrel:word);
var s,s2 : s90;
    name1 : s70;
begin

 {pl1 has changed his relations toward pl2, this proc will notify
  pl2 via mail. NEWREL contains the relation_constant}

 s:='Feelings';
 name1:=uplc+pl1.name2+config.textcol1;

 s2:='*error*';
 case NewRel of {see global_relation??? constants in CMS.PAS}
  global_RelationMarried     : s2:=name1+' married you!';
  global_RelationLove        : s2:=name1+' loves you!';
  global_RelationPassion     : s2:=name1+' passion for you makes '+sex[pl1.sex]+' blind to everything else!';
  global_RelationTrust       : s2:=name1+' trusts you.';
  global_RelationFriendship  : s2:=name1+' considers you among '+sex3[pl1.sex]+' friends.';

  global_RelationRespect     : s2:=name1+' holds you in the greatest respect.';

  global_RelationNormal      : s2:=name1+' is indifferent to your person.';

  global_RelationSuspicious  : s2:=name1+' suspects you for not being honest.';
  global_RelationAnger       : s2:=name1+' is angry with you!';
  global_RelationEnemy       : s2:=name1+' counts you among '+sex3[pl1.sex]+' enemies.';
  global_RelationHate        : s2:=name1+' '+ulred+'hates'+config.textcol1+' you!';

 end; {case .end.}

 {inform other player about thee relation change}
 post(MailSend,
 pl2.name2,
 pl2.ai,
 false,
 mailrequest_nothing,
 '',
 BackUblue+ulmag+s+BackUBlack+config.textcol1,
 mkstring(length(s),underscore),
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
 '',
 '');

end;

Procedure Kill_Duplicate_Relations;
var
    i, j, size ,hits, mem  : word;

    ok : boolean;

    relation,
    relation2 : RelationRec;

begin {this is really a debug procedure. Good when testing new stuff
       It scans the entire relations database for duplicates}

 {init}
 hits:=0;

 {debug}
 if global_utest then d(15,'Scanning for duplicate relations.');

 for i:=1 to fs(fsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  {evaluate}
  if relation.deleted=false then begin

   ok:=true;
   if howmany>0 then begin
    if (relation.name1<>ply.name2) and
       (relation.name2<>ply.name2) then begin
     ok:=false;
    end;
   end;

   if ok then begin

    {debug}
    if global_utest then begin
     d(15,'Scanning '+relation.name1+' and '+relation.name2+'s relation.');
    end;

    for j:=1 to fs(fsRelation) do begin

     {load relation}
     load_relation(fload,relation2,j);

     {remember original location}
     mem:=i;

     if (relation2.deleted=false) and
        (j<>mem) then begin
      {compare relation with relation2}
      if (relation.name1=relation2.name1) or
         (relation.name1=relation2.name2) then begin

       if (relation.name2=relation2.name1) or
          (relation.name2=relation2.name2) then begin

        {correct relation}
        correct_relation(relation.name1,relation);
        correct_relation(relation.name1,relation2);

        if (relation.idtag1=relation2.idtag1) and
           (relation.idtag2=relation2.idtag2) then begin

         if global_utest then d(14,'Duplicate found!');
         inc(hits);

        end;
       end;
      end;
     end;
    end; {for j:= .end.}

   end;
  end;

 end; {for i:= .end.}

 {debug}
 if (hits>0) and (global_utest) then begin
  d(14,commastr(hits)+' duplicates found!');
 end;

end; {kill_duplicate_relations *end*}

Procedure Remove_Relations(const ply:userrec); {remove plys relations}
var
    i, size  : word;
    relation : RelationRec;

begin

 {remove ALL of ply:s relations}

 {lock relation file}
 if Lock_RelationFile(FLock)=false then begin
  unable_to_access(global_relationf,5);
 end
 else begin

  {set filesize}
  size:=global_relationfilesize;

  for i:=1 to size do begin

   {load relation}
   load_relationfile(fload,relation,i);

   if (relation.name1=ply.name2) or (relation.name2=ply.name2) then begin

    {set relation to be deleted}
    relation.deleted:=true;

    {save relation}
    load_relationfile(fsave,relation,i);

   end;

  end; {for i:= .end.}

  {unlock relation file}
  Lock_RelationFile(FUnlock);

 end;

end;

Procedure Correct_Relation(const plyname:s30;var relation:relationrec);
var
    TempRelation : word;
    TempKilledBy : word;
    TempRecNr    : word;
    TempName     : s30;
    TempIdTag    : s15;
    TempAi       : char;
    TempRace     : races;
    TempFileType : byte;

begin

 {sets relation right, from plys point of view}

 if relation.name1<>plyname then begin

  {swap name}
  TempName:=Relation.Name1;
  Relation.Name1:=Relation.Name2;
  Relation.Name2:=TempName;

  {swap ai}
  TempAi:=Relation.Ai1;
  Relation.Ai1:=Relation.Ai2;
  Relation.Ai2:=TempAi;

  {swap race}
  TempRace:=Relation.Race1;
  Relation.Race1:=Relation.Race2;
  Relation.Race2:=TempRace;

  {swap relation}
  TempRelation:=Relation.Relation1;
  Relation.Relation1:=Relation.Relation2;
  Relation.Relation2:=TempRelation;

  {swap id tags}
  TempIdTag:=Relation.IdTag1;
  Relation.IdTag1:=Relation.IdTag2;
  Relation.IdTag2:=TempIdTag;

  {swap filrec tags}
  TempRecNr:=Relation.RecNr1;
  Relation.RecNr1:=Relation.Recnr2;
  Relation.RecNr2:=TempRecNr;

  {swap filetypes}
  TempFileType:=Relation.FileType1;
  Relation.FileType1:=Relation.FileType2;
  Relation.FileType2:=TempFileType;

  {swap killed by stats}
  TempKilledBy:=Relation.Killedby1;
  Relation.KilledBy1:=Relation.Killedby2;
  Relation.KilledBy2:=TempKilledBy;

 end;

end; {correct_relation *end*}


Function Social_Relation(const pl1,pl2:userrec;var Relation:RelationRec):word;
var
    result : word;
    found : boolean;
    i, size : word;
begin

 {function return value}
 result:=global_RelationNone;

 {returns the relation between characters pl1 and pl2}
 {if no relation is found we try to create one!}

 {init incoming Relation Record}
 New_RelationRecord(Relation);

 {init vars}
 found:=false;

 {lock relation file}
 if Lock_RelationFile(FLock)=false then begin
  unable_to_access(global_relationf,5);
 end
 else begin

  {set filesize}
  size:=global_relationfilesize;

  for i:=1 to size do begin

   {load relation}
   load_relationfile(fload,relation,i);

   if (relation.deleted=false) and
      (relation.name1<>'') and
      (relation.name2<>'') and
      (relation.name1<>relation.name2) then begin

    if (pl1.name2=relation.name1) or (pl1.name2=relation.name2) then begin

     if (pl2.name2=relation.name1) or (pl2.name2=relation.name2) then begin
      {relation found!}
      found:=true;
      result:=relation.relation1;
      break;
     end;

    end;
   end;

  end; {for i:= .end.}

  {if no relation was found then we must setup a new one}
  if found=false then begin

   { debugging text
   d(15,'Establishing a new relation..');
   }

   {setup a new relation in the RELATION database}
   setup_relation(pl1,pl2,relation);

  end;

  {unlock relation file}
  Lock_RelationFile(FUnLock);

 end;

 {return result}
 social_relation:=result;

end; {social_relation *end*}

Procedure Good_Looks(const ply:userrec);

var
    s,
    name : s30;

    col : byte;

function age_string(age:longint) : s30;
var s : s30;
begin
 s:=commastr(age);
 if age>1 then s:=s+' years old'
          else s:=s+' year old';

 {return result}
 age_string:=s;
end; {age_string *end*}

begin {displays ply:s looks depending upon age,race etc etc}

 {init}
 name:=uplc+ply.name2+config.textcol1;
 col:=config.textcolor;
 crlf;
 sd(col,name);

 {king/queen?}
 if ply.king then begin
  sd(config.textcolor,', '+uyellow+'THE '+upcasestr(KingString(ply.sex))+'!'+config.textcol1+',');
 end;

 {power}
 case ply.level of
  0..10  : sd(col,' is a puny '+race_display(2,ply.race,0)+'.');
 11..20  : sd(col,' is a wimpish '+race_display(2,ply.race,0)+'.');
 21..30  : sd(col,' is a mediocre '+race_display(2,ply.race,0)+'.');
 31..40  : sd(col,' is a average '+race_display(2,ply.race,0)+'.');
 41..50  : sd(col,' is a strong '+race_display(2,ply.race,0)+'.');
 51..60  : sd(col,' is a experienced '+race_display(2,ply.race,0)+'.');
 61..70  : sd(col,' is a potent '+race_display(2,ply.race,0)+'.');
 71..80  : sd(col,' is a veteran '+race_display(2,ply.race,0)+'.');
 81..90  : sd(col,' is a overwhelming '+race_display(2,ply.race,0)+'.');
 100..255: sd(col,' is a super mighty '+race_display(2,ply.race,0)+'.');
 end; {case .end.}
 crlf;

 {age}
 sd(col,name);
 case ply.age of
  0..10  : sd(col,' is still a child ('+age_string(ply.age)+').');
  11..25 : sd(col,' is young and daring ('+age_string(ply.age)+').');
  26..40 : sd(col,' is in '+sex3[ply.sex]+' prime ('+age_string(ply.age)+').');
  41..60 : sd(col,' bears the marks of time ('+age_string(ply.age)+').');
  61..90 : sd(col,' is an old-timer ('+age_string(ply.age)+').');
  91..255: sd(col,' is a super-senior ('+age_string(ply.age)+').');
  else     sd(col,' is a super-super senior ('+age_string(ply.age)+').');
 end; {case .end.}
 crlf;

 {good/evil}
 if ply.chiv>=ply.dark then begin
  d(col,name+' is good-hearted.');
 end
 else begin
  d(col,name+' has an evil mind.');
 end;

 {steroid user?}
 if ply.mental<100 then begin
  d(col,name+ulred+' is mentally disturbed!');
 end;

 {drug user}
 if ply.addict>0 then begin
  d(col,name+ulred+' is a drug addict!');
 end;

 {married to anybody}
 s:=Is_Player_Married(ply.name2,ply.id);
 if s<>'' then begin
  d(col,name+' is married to '+uplc+s+config.textcol1+'.');
 end;

 crlf;

end; {good_looks **end**}

Function Sex_Experience(const pl1,pl2:userrec) : longint;
var result : longint;
begin
 {experience points earned for sexual interaction between pl1 and pl2}

 {init}
 result:=0;

 result:=pl1.level*110 + pl2.level*90;

 {return result}
 sex_experience:=result;

end; {sex_experience *end*}

Function Are_They_Married(const pl1,pl2:userrec):boolean;
var relation : RelationRec;
    result : boolean;
begin

 {load current relation}
 social_relation(pl1,pl2,relation);

 if (relation.relation1=Global_RelationMarried) and
    (relation.relation2=Global_RelationMarried) then begin
  result:=true;
 end
 else begin
  result:=false;
 end;

 {return result}
 are_they_married:=result;

end; {are_they_married *end*}

Procedure Replace_all_Relations(const ply:userrec;const origfeeling,newfeeling:word);
var
    i : word;
    relation : relationrec;
begin
 {replaces all of ply:s relations with other characters that is equal to
  "origfeeling" and sets the new newfeeling instead}

 {debug}
 if global_utest then begin
  d(15,'Entering "replace_all_relations!"');
 end;

 for i:=1 to fs(fsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  {evaluate}
  if relation.deleted=false then begin

   if (relation.name1=ply.name2) and
      (relation.name2=ply.name2) then begin

    correct_relation(ply.name2,relation);
    {matching idtag?}
    if relation.idtag1=ply.id then begin

     if relation.relation1=origfeeling then begin

      {debug}
      if global_utest then begin
       d(15,'Updating '+relation.name1+' feelings to '+relation.name2+' to '+commastr(newfeeling));
      end;

      {save relation}
      load_relation(fsave,relation,i);

     end;
    end;
   end;
  end;
 end; {for i:= .end.}

end; {replace_all_relations *end*}

Procedure Load_My_Spouse(const me:userrec;var spouse:userrec);
var
    ReturnFileId : byte;

    i,j : word;
    found : boolean;
    relation : RelationRec;

begin {load spouse married to "me". if not found then spouse
       will be empty (spouse.name2='') }
 {init}
 found:=false;
 spouse.name1:='';
 spouse.name2:='';

 for i:=1 to fs(fsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  {evaluate}
  if relation.deleted=false then begin

   if (relation.name1=me.name2) or
      (relation.name2=me.name2) then begin

    correct_relation(me.name2,relation);
    {matching idtag?}
    if relation.idtag1=me.id then begin

     if (relation.relation1=Global_RelationMarried) and
        (relation.relation2=Global_RelationMarried) then begin

      {alright, now we must find and load the spouse from one
       of the userfiles}

      j:=Look_for_ID(relation.idtag2,relation.ai2,ReturnFileId);

      if load_character(spouse,ReturnFileId,j)=true then begin
       if (spouse.name2=relation.name2) and
          (spouse.id=relation.idtag2) then begin
        found:=true;
       end;

      end;

     end;
    end;

   end;
  end;

  if found then begin
   break;
  end;

 end; {for i:= .end.}

end; {load_my_spouse *end*}

Function Is_Player_Married(const plyname2:s30;const plyid:s15) : s30;
var
    result : s30;
    found : boolean;
    i : word;
    relation : RelationRec;

begin {returns the name of spouse if player PLY is married}

 {init}
 result:='';
 found:=false;

 {check}
 if f_exists(global_relationf) then begin

  for i:=1 to fs(fsRelation) do begin

   {load relation}
   load_relation(fload,relation,i);

   {evaluate}
   if relation.deleted=false then begin

    if (relation.name1=plyname2) or
       (relation.name2=plyname2) then begin

     correct_relation(plyname2,relation);
     {matching idtag?}
     if relation.idtag1=plyid then begin

      if (relation.relation1=Global_RelationMarried) and
         (relation.relation2=Global_RelationMarried) then begin

       if relation.name1<>plyname2 then result:=relation.name1
                                   else result:=relation.name2;
       found:=true;
      end;
     end;

    end;
   end;

   if found then begin
    break;
   end;

  end; {for i:= .end.}
 end;

 {return result}
 is_player_married:=result;

end; {IS_PLAYER_MARRIED *END*}

Function Relation_String(useYou:boolean;const rname1,rname2:s30;relation:word) : s100;
var s : s100;
    name1,name2:s40;
begin

 {init}
 s:='';
 name1:=rname1;
 name2:=rname2;

 name1:=uplc+name1+config.textcol1;
 name2:=uplc+name2+config.textcol1;

 {setting relation/feeling/emotion}
 case relation of
  global_RelationNormal:begin {normal}

   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You feel '+urelationc+'nothing special'+config.textcol1+' for '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' '+urelationc+'ignores'+config.textcol1+' you.';
   end
   else begin
    s:=s+name1+' '+urelationc+'ignores'+config.textcol1+' '+name2+'.';
   end;

  end;
  global_RelationSuspicious:begin {suspicious}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You are not sure if '+name2+' is '+urelationc+'reliable'+config.textcol1+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' is '+urelationc+'suspicious'+config.textcol1+' of you.';
   end
   else begin
    s:=s+name1+' is '+urelationc+'suspicious'+config.textcol1+' of '+name2+'.';
   end;

  end;
  global_RelationEnemy:begin {enemy}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+name2+' is your '+urelationc+'enemy'+config.textcol1+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' is your '+urelationc+'enemy'+config.textcol1+'.';
   end
   else begin
    s:=s+name1+' is '+name2+'s '+urelationc+'enemy'+config.textcol1+'.';
   end;

  end;
  global_RelationAnger:begin {anger}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You are '+urelationc+'angry'+config.textcol1+' with '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' is '+urelationc+'angry'+config.textcol1+' with you.';
   end
   else begin
    s:=s+name1+' doesn''t like '+name2+config.textcol1+'.';
   end;

  end;

  global_RelationHate:begin {hate}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You '+ulred+'hate'+config.textcol1+' '+name2+'!';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' '+ulred+'hates'+config.textcol1+' you!';
   end
   else begin
    s:=s+name1+' '+ulred+'hates'+' '+name2+'!';
   end;

  end;

  {*nice feelings*}
  global_RelationMarried:begin {married}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You are '+uyellow+'married'+config.textcol1+' to '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' is '+uyellow+'married'+config.textcol1+' to you!';
   end
   else begin
    s:=s+name1+' is '+uyellow+'married'+config.textcol1+' to '+name2+'.';
   end;

  end;
  global_RelationLove:begin {love}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You are deeply '+urelationc+'IN LOVE'+config.textcol1+' with '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' is '+urelationc+'IN LOVE'+config.textcol1+' with you!';
   end
   else begin
    s:=s+name1+' is '+urelationc+'IN LOVE'+config.textcol1+' with '+name2+'.';
   end;

  end;

  global_RelationPassion:begin {passion}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'Your '+urelationc+'passion'+config.textcol1+' is '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+'s '+urelationc+'passion'+config.textcol1+' is you!';
   end
   else begin
    s:=s+name1+'s '+urelationc+'passion'+config.textcol1+' is '+name2+'.';
   end;

  end;

  global_RelationTrust:begin {trust}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You '+urelationc+'trust'+config.textcol1+' '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' '+urelationc+'trusts'+config.textcol1+' you.';
   end
   else begin
    s:=s+name1+' '+urelationc+'trusts'+config.textcol1+' '+name2+'.';
   end;

  end;

  global_RelationFriendship:begin {friendship}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+name2+' is your '+urelationc+'friend'+config.textcol1+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' sees you as a '+urelationc+'friend'+config.textcol1+'.';
   end
   else begin
    s:=s+name1+config.textcol1+' sees '+name2+' as a '+urelationc+'friend'+config.textcol1+'.';
   end;

  end;

  global_RelationRespect:begin {respect}
   if (rname1=player.name2) and (UseYou) then begin
    s:=s+'You '+urelationc+'respect'+config.textcol1+' '+name2+'.';
   end
   else if (rname2=player.name2) and (UseYou) then begin
    s:=s+name1+' '+urelationc+'respects'+config.textcol1+' you.';
   end
   else begin
    s:=s+name1+' '+urelationc+'respects'+config.textcol1+' '+name2+'.';
   end;

  end;


  else begin
   s:=s+'no relation at all';
  end;
 end;

 {return result}
 relation_string:=s;

end; {relation_string *end*}

Procedure Attacked_Relation_Display(const Relation:RelationRec);
var s,s2,s3 : s70;
begin

 if relation.killedby1>0 then begin
  if relation.killedby1>1 then s:='times'
                          else s:='time';

  if relation.name2=player.name2 then s2:='You have'
                                 else s2:=uplc+relation.name2+config.textcol1+' has';

  if relation.name1=player.name2 then s3:='you'
                                 else s3:=uplc+relation.name1+config.textcol1;

  d(config.textcolor,s2+' been defeated by '+s3+' '+uwhite+commastr(relation.killedby1)+config.textcol1+' '+s+'!');
 end;

 if relation.killedby2>0 then begin
  if relation.killedby2>2 then s:='times'
                          else s:='time';

  if relation.name1=player.name2 then s2:='You have'
                                 else s2:=uplc+relation.name1+config.textcol1+' has';

  if relation.name2=player.name2 then s3:='you'
                                 else s3:=uplc+relation.name2+config.textcol1;

  d(config.textcolor,s2+' been defeated by '+s3+' '+uwhite+commastr(relation.killedby2)+config.textcol1+' '+s+'!');
 end;

end;

Procedure Display_Relation(const plyname:s30;var Relation:RelationRec;extended_info:boolean);
var s,s2,s3 : s70;
    the_heart, the_skull : boolean;

begin {used internally by other relation routines, like personal_relations
       and view_one_relation}

 {set the relation right, from ply:s point of view}
 Correct_Relation(plyname,relation);

 {any graphic, love/hate}
 the_heart:=false;
 the_skull:=false;
 if (relation.relation1=global_RelationMarried) or
    (relation.relation1=global_RelationLove) then begin
  the_heart:=true;
 end
 else if (relation.relation2=global_RelationMarried) or
         (relation.relation2=global_RelationLove) then begin
  the_heart:=true;
 end
 else if (relation.relation1=global_RelationHate) or
         (relation.relation2=global_RelationHate) then begin
  the_skull:=true;
 end;

 if the_heart=true then begin
  show_usurper_data(picture_SMALL_HEART,false);
 end
 else if the_skull=true then begin
  show_usurper_data(picture_DEATH_HEAD,false);
 end;

 {relation}
 d(config.textcolor,relation_string(true,relation.name1,relation.name2,relation.relation1));

 {married before?}
 if relation.marriedtimes>1 then begin
  if relation.marriedtimes>2 then s:='times'
                             else s:='time';
  if relation.name1=player.name2 then begin
   s:='You and '+uplc+relation.name2+config.textcol1+' have been married '+uwhite+commastr(relation.marriedtimes-1)
      +config.textcol1+' '+s+' before.';
  end
  else begin
   s:=uplc+relation.name1+config.textcol1+' and '+uplc+relation.name2+config.textcol1+' have been married '
      +uwhite+commastr(relation.marriedtimes-1)+config.textcol1+' '+s+' times before.';
  end;
  d(config.textcolor,s);

 end;

 {children}
 if relation.kids>0 then begin
  if relation.kids=1 then s:=uwhite+commastr(relation.kids)+config.textcol1+' child.'
                     else s:=uwhite+commastr(relation.kids)+config.textcol1+' children.';
  if relation.name1=player.name2 then s2:='You'
                                 else s2:=uplc+relation.name1+config.textcol1;
  if relation.name2=player.name2 then s3:='You'
                                 else s3:=uplc+relation.name2+config.textcol1;

  d(config.textcolor,s2+' and '+s3+' have '+s);
 end;

 {relation}
 if (relation.relation1<>Global_RelationMarried) and
    (relation.relation2<>Global_RelationMarried) then begin
  d(config.textcolor,relation_string(true,relation.name2,relation.name1,relation.relation2));
 end;

 if extended_info=true then begin
  {let us display some info on attacking}
  attacked_relation_display(relation);
 end;

end; {display_relation *END*}

Procedure View_One_Relation(const name1,name2:s30;extended_info:boolean);
var i : word;
   ok : boolean;
   relation : RelationRec;

begin {like personal_relations, but this proc only views ONE relation,
       the one between name1 and name2}

 {sd(config.textcolor,'Relation between ');
 d(global_plycol,name1+config.textcol1+' and '+uplc+name2+config.textcol1+'.');
 }

 for i:=1 to fs(fsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  if (relation.deleted=false) and
     (relation.name1<>'') and
     (relation.name2<>'') and
     (relation.name1<>relation.name2) then begin

   ok:=false;
   if (relation.name1=name1) and (relation.name2=name2) then ok:=true;
   if (relation.name1=name2) and (relation.name2=name1) then ok:=true;

   if ok then begin

    crlf;

    Display_Relation(name1,relation,extended_info);

    break;

   end;
  end;

 end; {for i:= .end.}

 {no relations found}
 if ok=false then begin
  d(12,'No relation established.');
 end;

end; {View_One_Relation *END*}

Procedure Personal_Relations(const ply:UserRec;spy_mode:boolean);
var
   i,
   counter : word;

   counter2: byte;

   s : s70;

   relation : RelationRec;

begin

 {list of character PLY:s personal relations, to screen}

 clearscreen;
 crlf;
 s:='Personal Relations';
 if spy_mode then begin
  s:=s+ulred+' (spy mode)';
 end;

 d(5,s);
 d(5,mkstring(18,underscore));

 counter:=0;
 counter2:=4;

 for i:=1 to fs(fsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  if (relation.deleted=false) and
     (relation.name1<>'') and
     (relation.name2<>'') and
     (relation.name1<>relation.name2) then begin

   if (relation.name1=ply.name2) or (relation.name2=ply.name2) then begin

    crlf;
    Display_Relation(ply.name2,relation,true);

    inc(counter);
    inc(counter2,9);

    {should we pause the listing?}
    if counter2>global_screenlines-2 then begin
     counter2:=0;
     crlf;
     if confirm('Continue','Y')=false then begin
      break;
     end;
    end;

   end;
  end;

 end; {for i:= .end.}

 {no relations found}
 if counter=0 then begin
  d(12,'No interesting relations.');
 end;

end; {personal_relations **END**}

Procedure Jealousy; {ply1 and ply2 have met and done something (romantic)
                     togheter. This routine informs their spouses.}
var
    spouse1,
    spouse2 : s30;

    s : s70;

begin

 {does ply1 have a spouse?}
 spouse1:=is_player_married(ply1.name2,ply1.id);
 {does ply2 have a spouse?}
 spouse2:=is_player_married(ply2.name2,ply2.id);

 case event of
  1:begin {ply1 and ply2 had a baby, let's tell their spouses}

     if spouse1<>'' then begin

      {mail cheated spouse}
      post(MailSend,
      spouse1,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Unknown Baby!'+config.textcol1,
      mkstring(13,underscore),
      'Your '+sex5[ply1.sex]+' '+uplc+ply1.name2+config.textcol1+' and '+uplc+ply2.name2+config.textcol1,
      'have produced a baby!',
      uplc+ply1.name2+config.textcol1+' has been cheating on you!',
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

     if spouse2<>'' then begin

      {mail cheated spouse}
      post(MailSend,
      spouse2,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Unknown Baby!'+config.textcol1,
      mkstring(13,underscore),
      'Your '+sex5[ply2.sex]+' '+uplc+ply2.name2+config.textcol1+' and '+uplc+ply1.name2+config.textcol1,
      'have produced a baby!',
      uplc+ply2.name2+config.textcol1+' has been cheating on you!',
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



    end
    else begin {all other activities}

     if spouse1<>'' then begin

      if ply1.sex=1 then s:='He is cheating on you!'
                    else s:='She is cheating on you!';

      {mail cheated spouse}
      post(MailSend,
      spouse1,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Cheating!'+config.textcol1,
      mkstring(9,underscore),
      'Your '+sex5[ply1.sex]+' '+uplc+ply1.name2+config.textcol1+' is fooling around with a '+race_display(2,ply2.race,0)+'!',
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
      '');
     end;


     if spouse2<>'' then begin

      if ply1.sex=1 then s:='He is cheating on you!'
                    else s:='She is cheating on you!';

      {mail cheated spouse}
      post(MailSend,
      spouse2,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Cheating!'+config.textcol1,
      mkstring(9,underscore),
      'Your '+sex5[ply2.sex]+' '+uplc+ply2.name2+config.textcol1+' is fooling around with a '+race_display(2,ply1.race,0)+'!',
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
      '');

     end;
    end;

 end; {case .end.}

end; {Jealousy *end*}

Procedure Love_Header;
begin
 sd(4,mkstring(3,heartsign));
 sd(4,header);
 d(4,mkstring(3,heartsign));
 d(5,mkstring(6+length(header),underscore));
end;

Procedure Give_Birth; {see also : Procedure New_ChildRecord}
var
    bastard,
    go_ahead,
    father_exist : boolean;

    x : longint;

    Npc_Baby,
    ReturnFileId : byte; {1=plyerfile,2=npcfile}

    Relation : RelationRec; {father & mother relation}
    Pl2 : UserRec; {father}
    Child : ChildRec; {new born child}

    kids : string[4];

    s2,sr3,sr4 : s90;

    s,
    MotherExpString,
    MotherString1,

    FatherExpString : s90;

begin

 {checks if pl1 should give birth to a child. pregancy required.}
 {pl1 is the mother, pl2 is the father}

 {if one of the parents is a NPC, then the birth takes place
  immediately!}

 {init}
 go_ahead:=true;
 MotherExpString:='';
 MotherString1:='';
 FatherExpString:='';

 {is pregnant person really a woman?}
 if (pl1.pregnancy>0) and (pl1.sex<>2) then begin
  pl1.pregnancy:=0;
  go_ahead:=false;
 end;

 {is pl1 pregnant?}
 if pl1.pregnancy=0 then go_ahead:=false;

 if go_ahead then begin

  if pl1.pregnancy>=config.labordays then begin

   {locate the father}
   pl2:=pl1;
   pl2.name2:='';

   x:=look_for_id(pl1.FatherID,'H',ReturnFileId);

   if x>0 then begin
    load_character(pl2,ReturnFileId,x);
   end
   else begin
    if global_ubeta or global_utest then begin
     wrl(12,'Father not to '+pl1.name2+'s new-born not found! check relation.pas');
    end;
   end;


   bastard:=true;

   {was father found?}
   if pl1.FatherId=pl2.Id then begin
    father_exist:=true;
    {but are they married? otherwise this child will be a bastard}
    if are_they_married(pl1,pl2)=true then begin
     bastard:=false;
    end;
   end
   else begin

    if global_utest then begin
     d(21,'Potential Error: Father to '+child.name+'not found in player files.');
    end;

    father_exist:=false;
    bastard:=true;
   end;

   {create a kid and store it in the database}
   create_child(child,pl1,pl2,bastard);

   {if this is a baby produced by one (or two) NPCs then we will
    make and name the baby immediately!}
   npc_baby:=0;
   if pl1.ai='C' then begin
    npc_baby:=1;
   end
   else if (father_exist) and (pl2.ai='C') then begin
    npc_baby:=2;
   end;

   if npc_baby>0 then begin

    {debug!}
    if global_utest then begin
     d(15,'Creating NPC baby! ('+pl1.name2+' and '+pl2.name2+')');
    end;

    case npc_baby of
     1: name_babies(pl1,true);
     2: name_babies(pl2,true);
    end;
   end;

   {update player records. [kids produced] [relation kids] [experience]}

   {give experience, always the mother but only sometimes the father}
   x:=pl1.level*1500;
   IncPlayerExp(pl1,x);
   MotherExpString:='You received '+uwhite+commastr(x)+config.textcol1+' experience points for the delivery.';

   if father_exist then begin
    if random(3)=0 then begin
     x:=pl2.level*650;
     IncPlayerExp(pl2,x);
     FatherExpString:='You were present at the delivery and received '+uwhite+commastr(x)+config.textcol1
                       +' experience points.';
     MotherString1:=uplc+pl2.name2+config.textcol1+' was present at the delivery to support you.';
    end
    else begin
     {chicken father}
     FatherExpString:='You didn''t have the guts to be present at the delivery!';
     MotherString1:=uplc+pl2.name2+config.textcol1+' was too scared and didn''t show.';
    end;
   end;

   pl1.pregnancy:=0; {reset mothers pregnancy flag}
   inc(pl1.kids,1);  {history of kids}
   inc(pl2.kids,1);  {history of kids}

   user_save(pl1);

   if father_exist then begin
    user_save(pl2);

    {load couples relation}
    social_relation(pl1,pl2,relation);

    {update relation record. # children produced in relation}
    inc(relation.kids,1);

    {save relation}
    load_relation(fsave,relation,relation.recnr);

   end;

   {inform father}
   if pl2.kids=1 then kids:='kid'
                 else kids:='kids';

   if father_exist then begin
    s:='Childbirth!';
    post(MailSend,
    pl2.name2,
    pl2.ai,
    false,
    mailrequest_nothing,
    '',
    uyellow+s+config.textcol1,
    mkstring(length(s),underscore),
    uplc+pl1.name2+config.textcol1+' gave birth to your child today!',
    'You are responsible for '+uwhite+commastr(pl2.kids)+config.textcol1+' '+kids+' now.',
    FatherExpString,
    'Congratulations!',
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

   {inform mother}
   if pl1.kids=1 then kids:='kid'
                 else kids:='kids';

   s:='Childbirth!';
   post(MailSend,
   pl1.name2,
   pl1.ai,
   false,
   mailrequest_nothing,
   '',
   uyellow+s+config.textcol1,
   mkstring(length(s),underscore),
   'You gave birth to a child today!',
   'You are responsible for '+uwhite+commastr(pl1.kids)+config.textcol1+' '+kids+' now.',
   MotherExpString,
   MotherString1,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   if npc_baby=0 then begin
    {Instruct parents to scan for new babies, so they can be named.
     [MailRequest_ScanForBabies]}
    {mail mother}
    post(MailSend,
    pl1.name2,
    pl1.ai,
    false,
    mailrequest_ScanForBabies,
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

    {mail father}
    if father_exist then begin
     post(MailSend,
     pl2.name2,
     pl2.ai,
     false,
     mailrequest_ScanForBabies,
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
    end;
   end;

   {news-paper}
   if father_exist then begin
    s2:=uplc+pl2.name2+config.textcol1+' the '+race_display(2,pl2.race,0)+' is a proud father!';
   end
   else begin
    s2:='The poor '+sex6[child.sex]+' is fatherless!';
   end;

   {bastard text}
   if bastard=true then begin
    sr3:=' The newborn is an illegitimate child, a bastard!';
   end
   else begin
    sr3:='';
   end;

   {royal text}
   if child.royal>0 then begin
    sr4:=' The newborn has '+uyellow+'Royal'+config.textcol1+' blood floating in '
     +sex3[child.sex]+' veins!';
   end
   else begin
    sr4:='';
   end;

   {news-paper}
   newsy(true,'Childbirth!',
   ' '+uplc+pl1.name2+config.textcol1+' the '++race_display(2,pl1.race,0)+', delivered a baby '+sex6[child.sex]+'!',
   ' '+s2,
   ''+sr3,
   ''+sr4,
   '',
   '',
   '',
   '',
   '');

   if (bastard=true) and (pl2.deleted=false) and
      (pl2.name2<>global_delname2) and (pl1.id<>pl2.id) then begin
    jealousy(1,pl1,pl2);
   end;

  end;

 end;

end; {Give_Birth .end.}

Procedure Sex_Act_Routine; {sexual act described / and babies are produced}
var
    mother,
    father : s30;

    s : s90;

    go_ahead: boolean;

    max_kids : word;

    x : integer;

begin {humans_involved=false when npcs call this routine}

 if humans_involved=true then begin
  crlf;
  d(config.textcolor,'It''s time to make up for all those days of continence..');
  d(config.textcolor,'You take '+uplc+pl2.name2+'s'+config.textcol1+' hand and walk up to the bedroom.');
  pause;
  crlf;
  d(global_plycol,pl2.name2+config.textcol1+' takes off '+sex3[pl2.sex]+' clothes...');
  sd(global_plycol,pl2.name2+config.textcol1+' then helps you out of your rags...');
  Make_Delay_Dots(config.textcolor,10,600);
  crlf;

  show_usurper_data(picture_HEART,false);

  sd(config.textcolor,'You embrace and let your wildest fantasies of lust come true.');

  {Make_Delay_Dots(config.textcolor,10,600);}
  {players did not like the long waiiit. we settle with a pause instead}
  pause;

  crlf;
  d(config.textcolor,'After a few intense hours of magic you rest...');

  {comment from other player}
  case random(2) of
   0:begin
      d(global_plycol,pl2.name2+config.textcol1+' gives you a sheepish smile:');
      d(global_talkcol,' Was it good for you?');
     end;
   1:begin
      d(global_plycol,pl2.name2+config.textcol1+' looks at you with a stupid grin on '+sex3[pl2.sex]+' face:');
      d(global_talkcol,' Was it good for you to?');
     end;
  end; {case .end.}
 end;

 {produce babies?}
 go_ahead:=true;

 {homo}
 if pl1.sex=pl2.sex then go_ahead:=false;

 {already pregnant}
 if (pl1.pregnancy>0) or (pl2.pregnancy>0) then go_ahead:=false;

 {calculate maxkids}
 if (pl1.ai='C') and (pl2.ai='C') then begin
  max_kids:=config.MaxNPCChildren; {# of children allowed}
 end
 else begin
  max_kids:=config.MaxHumanChildren; {# of children allowed}
 end;

 {too young or too old, or too many kids already}
 if pl1.sex=2 then begin
  if (pl1.age<14) or (pl1.age>45) or (pl1.kids>=max_kids) then go_ahead:=false;
 end
 else if pl2.sex=2 then begin
  if (pl2.age<14) or (pl2.age>45) or (pl2.kids>=max_kids) then go_ahead:=false;
 end;

 {baby boom randomizer}
 x:=random(3);

 {cheat! jakob}
 if global_utest=true then begin
  x:=0;
 end;

 if (go_ahead) and (x=0) then begin

  {a baby has been produced!}

  {update player flags}
  if pl1.sex=2 then begin
   mother:=pl1.name2;
   father:=pl2.name2;
   pl1.pregnancy:=1;
   pl1.fatherID:=pl2.ID;
   user_save(pl1);
  end
  else if pl2.sex=2 then begin
   mother:=pl2.name2;
   father:=pl1.name2;
   pl2.pregnancy:=1;
   pl2.fatherID:=pl1.ID;
   user_save(pl2);
  end;

  {inform players}
  if (pl1.sex=1) or (humans_involved=false) then begin

   if humans_involved=true then begin
    {inform father}
    d(15,pl2.name2+' is pregnant!');
   end;

   {mail mother}
   s:='Babies!';
   post(MailSend,
   pl2.name2,
   pl2.ai,
   false,
   mailrequest_nothing,
   '',
   uyellow+s+config.textcol1,
   mkstring(length(s),underscore),
   'You are pregnant!',
   uplc+pl1.name2+config.textcol1+' is the father!',
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

  if (pl1.sex=2) or (humans_involved=false) then begin

   if humans_involved=true then begin
    {inform mother}
    d(15,'You are pregnant!');
   end;

   {mail father}
   s:='Babies!';
   post(MailSend,
   pl2.name2,
   pl2.ai,
   false,
   mailrequest_nothing,
   '',
   uyellow+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+pl1.name2+config.textcol1+' is pregnant.',
   'You are going to be father to this child!',
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

  {abortion, domestic dispute}

  {comment by mother to news-paper}
  case random(4) of
   0: s:=' '+uplc+father+config.textcol1+utalkc+' brought this to happen!'+config.textcol1+', '+uplc+mother+config.textcol1
            +' twitters.';
   1: s:=' '+uplc+father+config.textcol1+utalkc+' forced me!'+config.textcol1+', '+uplc+mother+config.textcol1+' cries.';
   2: s:=' '+utalkc+' I forgot to take the Pill!'+config.textcol1+', '+uplc+mother+config.textcol1+' laments.';
   3: s:=' '+uplc+father+config.textcol1+utalkc+' didn''t use a condom!'+config.textcol1+', '+uplc+mother+config.textcol1
            +' moans.';
  end; {case .end.}

  {news-paper}
  newsy(true,'Pregnancy',
  ' '+uplc+mother+config.textcol1+' is going to have a baby!',
  s,
  '',
  '',
  '',
  '',
  '',
  '',
  '');

 end;

 if humans_involved=true then begin
  pause;
 end;

end; {sex_act_text *END*}


Procedure Npc_Change_Relations;
var

   jj, i, x : word;

   j, max_sessions, sessions : byte;

   ok,
   married,
   go_ahead : boolean;

   s : s90;

   ply2 : UserRec; {spouse}
   child : ChildRec;
   relation : RelationRec;

begin {npc character PLY maintains/creates/nurses/establishes/destroys
       X of his/her relations}

 {sessions to handle}
 max_sessions:=random(15)+1;
 sessions:=0;
 married:=false;

 {is ply married? and in that case to whom?}
 if ply.married=true then begin
  married:=true;
  {perform spouse maintenance}
  {jakob .. add something here please. }
 end
 else begin

  {should player try to marry?}
  if global_utest then d(15,ply.name2+' entering npc_set_out_to_marry');
  npc_set_out_to_marry(ply);
  if global_utest then d(15,ply.name2+' exiting npc_set_out_to_marry');

 end;


 if global_utest then d(15,ply.name2+' STARTS to browse (all) relations');

 for i:=1 to fs(FsRelation) do begin

  {load relation}
  load_relation(fload,relation,i);

  if relation.deleted=false then begin

   {is this one of ply:s relations we just loaded?}
   go_ahead:=false;
   if (relation.name1=ply.name2) and (relation.idtag1=ply.id) then begin
    go_ahead:=true;
   end
   else if (relation.name2=ply.name2) and (relation.idtag2=ply.id) then begin
    go_ahead:=true;
   end;

   if go_ahead=true then begin

    {correct relation}
    correct_relation(ply.name2,relation);

    ok:=false;
    {is the other player in the userfiles?}
    x:=Look_for_ID(relation.idtag2,relation.ai2,j);

    if x>0 then begin

     if load_character(ply2,j,x)=true then begin

      if (ply2.name2=relation.name2) and
         (ply2.id=relation.idtag2) then begin
       ok:=true;
      end;

      if ok=true then begin

       {let us improve/worsen relation or even marry!}
       x:=random(16);
       if (x<6) and (married=true) then begin
        x:=7;
       end
       else if (x<6) and (ply.sex=ply2.sex) then begin
        x:=7;
       end;

       case x of
        0..5:begin {fall in love with ply2 suddenly!}

              if global_utest then begin
               d(15,ply.name2+' falls in love with '+ply2.name2);
              end;

              {update relation}
              relation.relation1:=global_RelationLove;

              {save relation}
              load_relation(fsave,relation,relation.recnr);

              {put new relation in the news
              jakob}
              Relation_Change_News(ply,ply2,relation.relation1);

              {mail of other player is human controlled}
              if ply2.ai='H' then begin
               post(MailSend,
               ply2.name2,
               ply2.ai,
               false,
               mailrequest_nothing,
               '',
               udrinkc+'Romance'+config.textcol1,
               cool_string(7,'=','-',12,4),
               uplc+ply.name2+config.textcol1+' has fallen in love with you!',
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
        6..10:begin {worsen ply:s attitude to other player}
               Update_Relation(Relation_Worsen,1,ply,ply2,false,false);
              end;
        11..15:begin
                {improve ply:s attitude to other player}
                {but if ply is married then we don't improve it to
                 "in love" level}
                if relation.relation1<=Global_RelationFriendShip then begin
                 Update_Relation(Relation_Better,1,ply,ply2,false,false);
                end;
               end;

       end; {case .end.}

       {set sessions #}
       inc(sessions);
       if sessions>max_sessions then begin
        break;
       end;

      end;
     end;
    end;
   end;
  end;

 end; {for i:= .end.}

 if global_utest then d(15,ply.name2+' ENDS browsing (all) relations');


 if married=true then begin
  {load spouse}
  load_my_spouse(ply,ply2);
 end;

 if (married=true) and (ply2.name2<>'') then begin

  {debug}
  if global_utest then begin
   d(15,ply.name2+' entering married routines...');
  end;

  {load current relation}
  social_relation(ply,ply2,relation);

  {somehow these flags might be out of sync...doesn't really matter
  but we set them here, just in case}
  ply.married:=true;
  ply2.married:=true;

  {first we remove all "in love" relations, since we are married!}
  replace_all_relations(ply,global_relationLove,global_relationFriendship);

  if random(20)=0 then begin

   {divorce! .. maybe change chances for divorce depending on children, money, status etc}

   {debug}
   if global_utest then begin
    d(15,ply.name2+' decided to divorce '+ply2.name2+'!');
   end;

   if relation.marrieddays<1 then begin
    s:=' Their marriage lasted only a couple of hours!';
   end
   else if relation.marrieddays<30 then begin
    s:=' Their marriage lasted only '+uwhite+commastr(relation.marrieddays)+config.textcol1+' days.';
   end
   else begin
    s:=' Their marriage lasted '+uwhite+commastr(relation.marrieddays)+config.textcol1+' days.';
   end;

   {update relation}
   relation.relation1:=global_RelationNormal;
   relation.relation2:=global_RelationHate;
   relation.marrieddays:=0;

   {set player married flags}
   ply.married:=false;
   ply2.married:=false;
   user_save(ply);
   user_save(ply2);

   {save relation}
   load_relation(fsave,relation,relation.recnr);

   {news-paper}
   Newsy(true,
   'Divorce!',
   ' '+uplc+ply.name2+config.textcol1+' divorced '+uplc+ply2.name2+config.textcol1+'!',
   s,
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {divorce-log, see duplicate code in lovers.pas}
   Generic_News(MarriageDivorceNews,
   false,
   ugreen+'['+fix_date(todays_date)+'] '+uplc+ply.name2+ugreen+' and '+uplc+ply2.name2+ugreen+' were '+ulred+'Divorced'
     +ugreen+'!',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {note that this code is duplicated here and in
   lovers.pas => divorce proc, home.pas
   the children will be placed with the spouse! important decision
   made by the author.. but I think this can prove interesting
   the children are going to be depressed automatically.
   however, if a spouse is dead or deleted then the children will
   of course stay with the player and not get depressed.}

   {NOTE! DANGER! if a child is already online it will not be properly
   updated! you could solve this by putting all the children online
   like you do to the spouse above. and refuse divorce if putting the kids
   online is not possible}

   for jj:=1 to fs(FsChildren) do begin

    {load child}
    if load_child(fload,child,jj)=true then begin

     {is this child produced by ply and ply2?}
     if (my_child(ply,child)=true) and
        (my_child(ply2,child)=true) then begin

      {refuse player access to this child}
      if ply.sex=1 then child.fatheraccess:=false;
      if ply.sex=2 then child.motheraccess:=false;

      {debug}
      if global_utest then begin
       d(12,ply.name2+' lost custody of '+sex3[ply.sex]+' '+sex7[child.sex]+' '+ukidc+child.name+ulred+'!');
      end;

      {set child to depressed}
      child.health:=ChildHealth_Depressed;

      {inform spouse of childs depression}
      s:='Depression';
      post(MailSend,
      ply2.name2,
      ply2.ai,
      false,
      mailrequest_nothing,
      '',
      ulred+s+config.textcol1,
      mkstring(length(s),underscore),
      ukidc+child.name+config.textcol1+', your '+sex7[child.sex]+', is suffering from a '+ulred+'depression'
           +config.textcol1+'!',
      'The divorce you are going through is not good for the children!!',
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

      {inform spouse of gained custody}
      s:='Divorce Consequences';
      post(MailSend,
      ply2.name2,
      ply2.ai,
      false,
      mailrequest_nothing,
      '',
      umailheadc+s+config.textcol1,
      mkstring(length(s),underscore),
      'You are now fully responsible for '+ukidc+child.name+config.textcol1+', your '+sex7[child.sex]+'!',
      uplc+ply.name2+config.textcol1+' has left you and the children!',
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
      Newsy(true,
      'Child depressed!',
      ' '+ukidc+child.name+config.textcol1+', the '+sex7[child.sex]+' of '+uplc+child.mother
         +config.textcol1+' and '+uplc+child.father+config.textcol1+' is',
      ' suffering from a '+ulred+'depression'+config.textcol1+' as a direct result of the',
      ' parents divorce.',
      '',
      '',
      '',
      '',
      '',
      '');

      {save updated child}
      load_child(fsave,child,child.recnr);

     end;
    end;

   end; {for i:= .end.}

   {debug}
   if global_utest then begin
    online_send_to_all(uplc+ply.name2+config.textcol1+' divored '+uplc+ply2.name2+config.textcol1
    +'!',ply.name2,'');
   end;

   {mail ex-wife/husband}
   s:='Divorce!';
   post(MailSend,
   ply2.name2,
   ply2.ai,
   false,
   mailrequest_nothing,
   '',
   uyellow+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+ply.name2+config.textcol1+' divorced you!',
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

  end
  else begin

   {player is married and decided to stay married.
   here we have sex and produce babies!}

   x:=random(3);

   if global_utest=true then begin
    x:=0; {cheat!}
   end;

   if x=0 then begin

    {debug}
    if global_utest then begin
     d(15,ply.name2+' and '+ply2.name2+' have sex!');
    end;

    {sexual act}
    sex_act_routine(ply,ply2,false);

   end;

  end;

 end; {I'm married routines end}

 if sessions<max_sessions then begin

  {ply didn't process enough number of relations. lets try and
   create some new relations}

  {debug}
  if global_utest then begin
   d(15,'Creating new relations for '+ply.name2+'.');
  end;

  sessions:=max_sessions-sessions;

  {debug}
  if global_utest then begin
   d(15,'Creating '+commastr(sessions)+' new sessions.');
  end;

  create_new_relations(ply,sessions,false);

 end;

end; {Npc_Change_Relations *end*}

Procedure Create_New_Relations;
const max_attempts = 44; {important setting!}
var
    i , jj : integer;

    relationValue : word;

    attempts : byte;
    created_relations : byte;

    ok : boolean;

    relation : relationRec;
    ply2 : userrec;

begin

 attempts:=0;
 created_relations:=0;
 repeat

  {1=load from playerfile, 2=load from npc file}
  repeat
   i:=random(2)+1;
  until i in [1,2];

  {pick random character from selected file}
  case i of
   1: jj:=random(fs(FsPlayer)+1);
   2: jj:=random(fs(FsNpc)+1);
  end; {case .end.}

  inc(attempts);

  {load random selected character}
  if load_character(ply2,i,jj)=true then begin

   if (ply2.deleted=false) and
      (ply2.name2<>global_delname2) and
      (ply2.name1<>global_delname1) and
      (ply2.name2<>ply.name2) and
      (ply2.id<>ply.id) then begin

    ok:=false;

    {does ply and ply2 already have a relation? (load their relation)}
    RelationValue:=Social_Relation(ply,ply2,relation);

    if relationValue=global_relationNone then ok:=true;

    {are they different sex?}
    if (ok=true) and (opposite_sex_only=true) then begin
     {sorry, these two are of the same sex...no relation created}
     if ply.sex=ply2.sex then ok:=false;
    end;

    if ok then begin

     {new relation established!}
     inc(created_relations);

     {set new relation...random!}
     case random(8) of
      0: i:=global_RelationFriendship;
      1: i:=global_RelationTrust;
      2: i:=global_RelationRespect;
      3: i:=global_RelationNormal; {default relation value}
      4: i:=global_RelationSuspicious;
      5: i:=global_RelationAnger;
      6: i:=global_RelationEnemy;
      7: i:=global_RelationHate;
     end; {case .end.}

     relation.relation1:=i;

     {debug}
     if global_utest then begin
      d(15,'New Relation Created between '+uplc+ply.name2+config.textcol1+' and '+uplc+ply2.name2+config.textcol1+'! ');
     end;

     {update relation, save to file}
     load_relation(fsave,relation,relation.recnr);

     {put new relation in the news}
     Relation_Change_News(ply,ply2,relation.relation1);

    end;

   end;
  end;

 until (attempts>max_attempts) or (created_relations>=goal_relations);

end; {create_new_relations *end*}

end. {Unit Relation .END.}
