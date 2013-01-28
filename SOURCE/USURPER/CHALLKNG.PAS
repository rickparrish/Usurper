{$IFDEF WIN32}
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


Unit ChallKng; {Challenge the King (or Queen)}

Interface    {This routine can be called by a player or NPC}
             {see challeng.pas, npmaint.pas}
Uses Init;

Procedure Challenge_King(var pl0 : userrec;
                         var challenger : userrec;
                         const Silent : boolean);

{
 pl0 is the king.
 Challenger is the challenger
 Silent=true .... text display and interaction
       =false ... for silent auto intrusion, used by npcs (see npcmaint.pas)
 }

Implementation

Uses Cms, Jakob, Plcomp,
     Compwar, News, Various,
     Various2, Various3, PlvsMon,
     Mail, GenNews, Online,
     Relation, File_Io;

Procedure Challenge_King;
var
    s, s1 : s100;

    king : kingrec;

    i,j,k,size : word;

    ok,
    challenger_begged,
    moat_battle : boolean;

    pl : array [1..4] of ^Userrec;

    MoatGuard: MoatRec;

procedure New_Ruler(fight:boolean);
begin

 {challenger has usurped the Throne!}

 {inform royal guards that they have been sacked}
 sack_royal_guards;

 {the king is dead! long live the King!}
 if f_exists(global_kingf) then begin
  delete_file(global_kingf);
 end;

 {save the king}
 user_save(pl0);

 {load empty king record}
 load_king(fload,king);

 {init king record}
 new_king(king);

 {update king record , *searchword:kingstruct*}
 king.name:=challenger.name2;
 king.ai  :=challenger.ai;
 king.sexy:=challenger.sex;

 s:= KingString(challenger.sex);
 s1:=KingString(pl0.sex);

 {save king}
 load_king(fsave,king);

 if not silent then begin
  crlf;
  crlf;
  d(14,'Congratulations, The Castle is Yours!');
  d(config.textcolor,'The '+s1+' is dead, long live the '+s+'!');

  crlf;
 end;

 if fight then begin
  {put the event in the news}
  newsy(true,uwhite+'NEW '+s+'! --- NEW '+s+'! --- NEW '+s+'! --- NEW '+s+'!'+config.textcol1,
  ' '+uplc+challenger.name2+config.textcol1+' usurped the thone!',
  ' '+config.textcol1+s1+' '+ukingc+pl0.name2+config.textcol1+' was defeated after a duel in the Castle!',
  ' The Royal Forces have sworn allegiance to '+ukingc+challenger.name2+config.textcol1+'.',
  ' May the Kingdom prosper under the new Reign!'+config.textcol1,
  '',
  '',
  '',
  '',
  '');
 end
 else begin
  {put the event in the news}
  newsy(true,uwhite+'NEW '+s+'! --- NEW '+s+'! --- NEW '+s+'! --- NEW '+s+'!'+config.textcol1,
  ' '+uplc+challenger.name2+config.textcol1+' usurped the thone!',
  ' '+config.textcol1+s1+' '+ukingc+pl0.name2+config.textcol1+' was unable to defend the Castle!',
  ' The Royal Forces have sworn allegiance to '+ukingc+challenger.name2+config.textcol1+'.',
  ' May the Kingdom prosper under the new reign!'+config.textcol1,
  '',
  '',
  '',
  '',
  '');
 end;

 s:=KingString(pl0.sex);

 {put the news in the Monarch News-file}
 if fight then begin
  Generic_News(RoyalNews,
  true,
  ' '+config.textcol1+s+' '+ukingc+pl0.name2+config.textcol1+' was dethroned after a bloody battle.',
  config.textcol1+' The '+race_display(2,challenger.race,0)+' '+uplc+challenger.name2+config.textcol1+' usurped the Throne.',
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
  Generic_News(RoyalNews,
  true,
  ' '+config.textcol1+s+' '+ukingc+pl0.name2+config.textcol1+' was dethroned without bloodshed.',
  config.textcol1+' The '+race_display(2,challenger.race,0)+' '+uplc+challenger.name2+config.textcol1+' usurped the Throne.',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
 end;

 if not silent then begin
  {inform other nodes}
  online_send_to_all(uplc+challenger.name2+config.textcol1+' is the NEW '+s+'!',challenger.name2,'');
 end;

 {mail defeated king}
 if fight then begin
  s:='Infiltration';
  post(MailSend,
  pl0.name2,
  pl0.ai,
  false,
  mailrequest_nothing,
  '',
  ulred+s+config.textcol1,
  mkstring(length(s),underscore),
  uplc+challenger.name2+config.textcol1+' attacked you in your Chambers!',
  ulred+'You were defeated!'+config.textcol1,
  uplc+challenger.name2+config.textcol1+' usurped the Throne!',
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
  s:='Infiltration';
  post(MailSend,
  pl0.name2,
  pl0.ai,
  false,
  mailrequest_nothing,
  '',
  ulred+s+config.textcol1,
  mkstring(length(s),underscore),
  uplc+challenger.name2+config.textcol1+' attacked you in your Chambers!',
  ulred+'You were '+ulred+'DEAD'+config.textcol1+' and unable to defend yourself!',
  uplc+challenger.name2+config.textcol1+' usurped the Throne!',
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

 {general procedure}
 king_is_gone;

 {depose former king}
 pl0.king:=false;
 user_save(pl0);

 {set new king}
 challenger.king:=true;
 user_save(challenger);

 if not silent then begin
  {pause}
  pause;
 end;

end; {new_ruler *end*}

var monsters_killed : boolean;
    rounds : word;
begin {CHALLENGE KING *START*}

 {load king record}
 load_king(fload,king);

 {check that there are not more moat creatures than the system can handle}
 if king.moatnr>global_maxmon then begin
  king.moatnr:=global_maxmon;
  load_king(fsave,king);
 end;

 {**********************}
 {*** SWIM THE MOAT! ***}
 {**********************}

 if not silent then begin
  d(15,'You must swim across the moat to enter the secret passage.');
  crlf;
 end;

 moat_battle:=false;
 if king.moatnr>0 then begin
  if Find_MoatID(king.MoatID) then begin
   load_MoatID(MoatGuard,King.MoatID);
   if MoatGuard.ID=King.MoatID then begin
    moat_battle:=true;
   end;
  end;
 end;

 if moat_battle=false then begin
  if not silent then begin
   d(15,'Phew! You weren''t attacked in the water. Lax security around here!');
   crlf;
   pause;
  end;
 end
 else if king.moatnr>0 then begin

  if silent then begin

   {npc fights the moat creatures!

   CHEAT routine!  the npc/offline player never fights the monsters}
   if random(3)=0 then begin
    {npc killed moat monsters!}
    monsters_killed:=true;
    global_killed:=false;
    j:=0;
   end
   else begin
    {R.I.P.}
    monsters_killed:=false;
    global_killed:=true;
    j:=king.moatnr;
   end;

  end
  else if not silent then begin
   sd(config.textcolor,'You encounter ');
   sd(15,commastr(king.moatnr)+' ');

   sd(11,MoatGuard.Name);
   if king.moatnr>1 then sd(11,'s');

   sd(config.textcolor,' in the moat!');
   d(12,'  FIGHT!');

   {reset monsters}
   reset_monsters;

   for i:=1 to King.MoatNr do begin
    create_monster(i,  {#}
    MoatGuard.name,    {name}
    MoatGuard.hps,     {hps}
    MoatGuard.battack, {strength}
    challenger.level,  {defence}
    'Grrrr..',      {phrase}
    false,          {grabweap}
    false,          {grabarm}
    '',             {weapon-string}
    '',             {armor-string}
    false,          {poisoned-should be false}
    false,          {disease -should be false}
    MoatGuard.battack,  {punch}
    0,              {armpow}
    0);             {weappow}
   end; {for i:= .end.}

   {setting some variables before the fight}
   global_begged:=false;
   global_nobeg:=true;

   {init temp vars}
   for i:=1 to 4 do begin
    new(pl[i]);
    pl[i]^.name2:='';
   end;

   pause;

   {fight against moat creatures}
   player_vs_monsters(pl_vs_doorguards,pl[1]^,pl[2]^,pl[3]^,pl[4]^);

   {dispose temp vars}
   for i:=1 to 4 do begin
    dispose(pl[i]);
   end;

   {how many moat creatures survived}
   j:=0;
   for i:=1 to global_maxmon do begin
    if monster_active(i) then inc(j);
   end;

  end; {interactive moat-fight *end*}

  if j<king.moatnr then begin
   king.moatnr:=j;
   {update king record}
   load_king(fsave,king);
  end;

  if global_killed then begin

   {mail the king}
   s:='The Moat';
   post(MailSend,
   king.name,
   king.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+challenger.name2+config.textcol1+' swam across the Moat!',
   uplc+challenger.name2+config.textcol1+' was killed by your '+ulcyan+MoatGuard.Name+'s'+config.textcol1+'.',
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

   {decide on news text}
   case random(4) of
    0: s:=' Some '+ulcyan+MoatGuard.Name+'s'+config.textcol1+' killed '+uplc+challenger.name2+config.textcol1+'.';
    1: s:=' Some '+ulcyan+MoatGuard.Name+'s'+config.textcol1+' catched up with '+uplc+challenger.name2+config.textcol1
                  +' and killed '+sex[challenger.sex]+'.';
    2: s:=' Some '+ulcyan+MoatGuard.Name+'s'+config.textcol1+' had '+uplc+challenger.name2+config.textcol1+' for lunch.';
    3: s:=' Some '+ulcyan+MoatGuard.Name+'s'+config.textcol1+' trashed '+uplc+challenger.name2+config.textcol1+'!';
   end;

   {news-paper}
   Newsy(true,
   'Fatal Swim',
   ' '+uplc+challenger.name2+config.textcol1+' swam across the Moat.',
   s,
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   if not silent then begin
    crlf;
    d(12,'Idiot! You couldn''t even make it across the Moat!');

    {challenger.allowed:=false;}
    Reduce_Player_Resurrections(challenger,true);
    pause;
    normal_exit;
   end;

  end
  else begin

   {challenger made it across the moat!}

   {mail the king}
   s:='The Moat';
   post(MailSend,
   king.name,
   king.ai,
   false,
   mailrequest_nothing,
   '',
   ulred+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+challenger.name2+config.textcol1+' swam across the Moat!',
   uplc+challenger.name2+config.textcol1+' killed your '+ulcyan+MoatGuard.Name+'s '+config.textcol1+'!',
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
   'Swimmer',
   ' '+uplc+challenger.name2+config.textcol1+' swam across the Moat.',
   ' Some '+ulcyan+MoatGuard.Name+'s'+config.textcol1+' attacked '+uplc+challenger.name2+config.textcol1+'!',
   ' '+uplc+challenger.name2+config.textcol1+' massacred the '+ulcyan+MoatGuard.Name+'s'+config.textcol1+'.',
   '',
   '',
   '',
   '',
   '',
   '');


   if not silent then begin
    crlf;
    d(14,'Good Work! You have safely made it to the Secret Passage!');
    pause;
   end;

  end;

 end; {moat fight .end.}


 {************************}
 {*** FIGHT THE GUARDS ***}
 {************************}


 {lets bail out of npc challenger lost}
 if (silent=true) and (challenger.hps<1) then begin
  exit;
 end;


 if not silent then begin
  crlf;
  d(config.textcolor,'Suddenly you hear soldiers approaching...');
 end;

 {load king}
 load_king(fload,king);

 {init temp vars}
 new(pl[1]);
 pl[1]^.name2:='';

 for i:=1 to global_kingguards do begin

  if king.guard[i]<>'' then begin
   {lets see if guard is in the player/npc list}
   ok:=false;

   for j:=1 to 2 do begin
    case j of
     1: size:=fs(FsPlayer);
     2: size:=fs(FsNpc);
    end;

    for k:=1 to size do begin

     if ok then break;

     load_character(pl[1]^,j,k);

     if (player_active(pl[1]^,false)=true) and
        (pl[1]^.name2=king.guard[i]) and
        (king.guard[i]<>'') then begin

      ok:=true;

     end;
    end; {for k:= .end.}

   end; {for j:= .end.}

   if ok then begin

    if pl[1]^.location=Offloc_Prison then begin
     {guard is in prison and therefore unable to defend the king}

     {mail king of failure of guard to show up}
     post(MailSend,
     king.name,
     king.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+'FAILED DUTY'+config.textcol1,
     mkstring(11,underscore),
     'The royal guard '+uplc+king.guard[i]+config.textcol1+' was '+ulred+'IN PRISON'+config.textcol1
      +' when the Castle was attacked!',
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

     {mail the guard about his failure to show up}
     s:='Castle Infiltrated!';
     post(MailSend,
     pl[1]^.name2,
     pl[1]^.ai,
     false,
     mailrequest_nothing,
     '',
     uwhite+s+config.textcol1,
     mkstring(length(s),underscore),
     uplc+challenger.name2+config.textcol1+' infiltrated the Castle!',
     'You were '+ulred+'IN PRISON'+config.textcol1+' at the time and unable to defend the Royals!',
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
    else if pl[1]^.hps<1 then begin
     {guard is dead and therefore unable to defend the king}

     {mail king of failure of guard to show up}
     post(MailSend,
     king.name,
     king.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+'FAILED DUTY'+config.textcol1,
     mkstring(11,underscore),
     'The Royal Guard '+uplc+king.guard[i]+config.textcol1+' was '+ulred+'DEAD'+config.textcol1+' and unable to defend'
        +' the Castle!',
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

     {mail the guard about his failure to show up}
     s:='Castle Attacked!';
     post(MailSend,
     pl[1]^.name2,
     pl[1]^.ai,
     false,
     mailrequest_nothing,
     '',
     uwhite+s+config.textcol1,
     mkstring(length(s),underscore),
     uplc+challenger.name2+config.textcol1+' infiltrated the Castle!',
     'You were '+ulred+'DEAD'+config.textcol1+' and unable to defend the Castle!',
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
    else if is_online(king.guard[i],online_player) then begin
     {guard is online and therefore unable to defend the king}

     if not silent then begin
      {mail online player of failure to protect the king}
      online_send_to_player(king.guard[i],online_player,ulred+' You were needed at the Castle!'+config.textcol1);
     end;

     {mail king of failure of guard to show up}
     post(MailSend,
     king.name,
     king.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+'FAILED DUTY'+config.textcol1,
     mkstring(11,underscore),
     uplc+king.guard[i]+config.textcol1+' wasn''t on '+sex3[king.guardsex[i]]+' post when the Castle was attacked!',
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

     if not silent then begin
      {placing guard online and fighting intruder}
      add_shadow(SAdd,pl[1]^,challenger.name2,'fighting '+uplc+challenger.name2+config.textcol1,0);
     end;

     {fight, two kinds: (1) player-computer (2) computer-computer}
     if silent then begin

      rounds:=0;
      repeat
       inc(rounds);
       computer_computer(true,true,challenger,pl[1]^);
      until (challenger.hps<1) or (pl[1]^.hps<1) or (rounds>9999);

      {update "killedby" variable in relations data file}
      if challenger.hps<1 then begin
       killed_by_stats(pl[1]^,challenger);
      end;
      if pl[1]^.hps<1 then begin
       killed_by_stats(challenger,pl[1]^);
      end;

      challenger_begged:=false;

     end
     else begin

      {challenger computer}

      crlf;
      sd(config.textcolor,'You are up against the Royal Guard ');
      sd(global_plycol,pl[1]^.name2);
      d(config.textcolor,'!');
      pause;

      repeat
       challenger_begged:=player_computer(challenger,pl[1]^,false,2);
      until (challenger_begged) or (challenger.hps<1) or (pl[1]^.hps<1);

      {update "killedby" variable in relations data file}
      if challenger.hps<1 then begin
       killed_by_stats(pl[1]^,challenger);
      end;
      if pl[1]^.hps<1 then begin
       killed_by_stats(challenger,pl[1]^);
      end;

     end;

     {evaluate fight}
     if challenger_begged then begin
      {challenger begged for mercy}

      {guard automatically sends challenger to prison}
      challenger.location:=offloc_prison;
      challenger.daysinprison:=1;

      user_save(challenger);

      if not silent then begin
       {prison text}
       crlf;
       d(config.textcolor,'You are thrown in a damp prison dungeon...');
       d(config.textcolor,'Your only company will be the rats and cockroaches.');
       d(config.textcolor,'Your fate is in the hands of the Royal Family.');
       crlf;
      end;

      {news-paper}
      newsy(true,
      'Castle Fight!',
      ' '+uplc+challenger.name2+config.textcol1+' fought the Royal Guard '+uplc+pl[1]^.name2+config.textcol1+'!',
      ' '+ulred+challenger.name2+config.textcol1+' begged for mercy and was imprisoned.',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      {mail the king}
      s:='Infiltration';
      post(MailSend,
      pl0.name2,
      pl0.ai,
      false,
      mailrequest_nothing,
      '',
      ulred+s+config.textcol1,
      mkstring(length(s),underscore),
      uplc+challenger.name2+config.textcol1+' engaged in combat with the Royal Guard '+uplc+pl[1]^.name2+config.textcol1+'!',
      uplc+challenger.name2+config.textcol1+' begged for mercy! '+uplc+challenger.name2+'s'+config.textcol1
       +' life was spared.',
      uplc+challenger.name2+config.textcol1+' was sent to prison. Sentence pending.',
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

      {mail the guard}
      s:='Defending the '+kingstring(king.sexy);
      post(MailSend,
      pl[1]^.name2,
      pl[1]^.ai,
      false,
      mailrequest_nothing,
      '',
      uwhite+s+config.textcol1,
      mkstring(length(s),underscore),
      uplc+challenger.name2+config.textcol1+' infiltrated the Castle!',
      'You engaged '+uplc+challenger.name2+config.textcol1+'!',
      uplc+challenger.name2+config.textcol1+' begged for mercy!',
      'You spared '+sex3[challenger.sex]+' life.',
      uplc+challenger.name2+config.textcol1+' was sent to prison.',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      if not silent then begin
       {bye}
       pause;
       normal_exit;
      end;

     end
     else begin

      {evaluate fight! who won?}

      if (pl[1]^.hps<1) and (challenger.hps<1) then begin
       {both died}

       {news-paper}
       newsy(true,
       'Castle Infiltrated!',
       ' '+uplc+challenger.name2+config.textcol1+' fought the royal guard '+uplc+pl[1]^.name2+config.textcol1+'!',
       ' '+ulred+pl[1]^.name2+config.textcol1+' was killed!',
       ' '+ulred+challenger.name2+config.textcol1+' died of '+sex3[challenger.sex]+' wounds.',
       ' The intruder failed to infiltrate the Castle!',
       ' Long Live the '+kingstring(pl0.sex)+'!',
       '',
       '',
       '',
       '');

       {mail the king}
       s:='Infiltration Attempt';
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       ulred+s+config.textcol1,
       mkstring(length(s),underscore),
       uplc+challenger.name2+config.textcol1+' infiltrated the Castle!',
       'The royal guard '+uplc+pl[1]^.name2+config.textcol1+' fought the intruder!',
       'Both '+ulred+challenger.name2+config.textcol1+' and '+ulred+pl[1]^.name2+' were killed!',
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

       {mail the guard}
       s:='Defending the '+kingstring(king.sexy);
       post(MailSend,
       pl[1]^.name2,
       pl[1]^.ai,
       false,
       mailrequest_nothing,
       '',
       uwhite+s+config.textcol1,
       mkstring(length(s),underscore),
       uplc+challenger.name2+config.textcol1+' infiltrated the Castle!',
       'You engaged '+uplc+challenger.name2+config.textcol1+'!',
       'You killed '+uplc+challenger.name2+config.textcol1+'!',
       ulred+'Unfortunately you died from your wounds only moments later...'+config.textcol1,
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

       {save guard}
       user_save(pl[1]^);

       if not silent then begin
        {exit preparations}
        d(12,'You failed!');
        Reduce_Player_Resurrections(challenger,true);
        {challenger.allowed:=false;}
        pause;
        normal_exit;
       end;

      end
      else if challenger.hps<1 then begin

       {challenger died}

       {news-paper}
       newsy(true,
       'Infiltration Attempt!',
       ' '+uplc+challenger.name2+config.textcol1+' fought the Royal Guard '+uplc+pl[1]^.name2+config.textcol1+'!',
       ' '+ulred+challenger.name2+config.textcol1+' was defeated!',
       ' The intruder failed to infiltrate the Castle!',
       ' Long Live the '+kingstring(pl0.sex)+'!',
       '',
       '',
       '',
       '',
       '');

       {mail the king}
       s:='Infiltration Attempt';
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       ulred+s+config.textcol1,
       mkstring(length(s),underscore),
       uplc+challenger.name2+config.textcol1+' tried to get to your Bedroom!',
       'The Royal guard '+uplc+pl[1]^.name2+config.textcol1+' fought the intruder!',
       ulred+challenger.name2+config.textcol1+' was killed!',
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

       {mail the guard}
       s:='Defending the '+kingstring(king.sexy);
       post(MailSend,
       pl[1]^.name2,
       pl[1]^.ai,
       false,
       mailrequest_nothing,
       '',
       uwhite+s+config.textcol1,
       mkstring(length(s),underscore),
       uplc+challenger.name2+config.textcol1+' tried to enter the Castle!',
       'You engaged '+uplc+challenger.name2+config.textcol1+'!',
       'You killed '+uplc+challenger.name2+config.textcol1+'!',
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

       {save guard}
       user_save(pl[1]^);

       if not silent then begin

        {exit preparations}
        d(12,'You failed!');
        Reduce_Player_Resurrections(challenger,true);
        {challenger.allowed:=false;}
        pause;
        normal_exit;
       end;


      end
      else begin

       {guard died}

       case random(5) of
        0: s:='killed';
        1: s:='eliminated';
        2: s:='crushed';
        3: s:='massacred';
        4: s:='mauled';
       end;

       {news-paper}
       newsy(true,
       'Royal Guard Slain!',
       ' '+uplc+challenger.name2+config.textcol1+' fought the Royal guard '+uplc+pl[1]^.name2+config.textcol1+'!',
       ' '+ulred+pl[1]^.name2+config.textcol1+' was '+s+' by '+uplc+challenger.name2+'!'+config.textcol1,
       '',
       '',
       '',
       '',
       '',
       '',
       '');


       {mail the king}
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       ulred+'Guard Slain'+config.textcol1,
       mkstring(11,underscore),
       uplc+challenger.name2+config.textcol1+' tried to get to your Bedroom!',
       'The Royal guard '+uplc+pl[1]^.name2+config.textcol1+' fought the intruder!',
       uplc+challenger.name2+config.textcol1+' '+s+' '+ulred+pl[1]^.name2+config.textcol1+'!',
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

       {mail the guard}
       s:='Defending the '+kingstring(king.sexy);
       case random(5) of
        0: s1:='killed';
        1: s1:='eliminated';
        2: s1:='crushed';
        3: s1:='massacred';
        4: s1:='mauled';
       end;

       post(MailSend,
       pl[1]^.name2,
       pl[1]^.ai,
       false,
       mailrequest_nothing,
       '',
       uwhite+s+config.textcol1,
       mkstring(length(s),underscore),
       uplc+challenger.name2+config.textcol1+' tried to enter the Castle!',
       'You engaged '+uplc+challenger.name2+config.textcol1+'!',
       'You were '+s1+' by '+uplc+challenger.name2+config.textcol1+'!',
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

       {save guard}
       user_save(pl[1]^);

       {save challenger}
       user_save(challenger);

       if not silent then begin
        {victory}
        crlf;
        d(12,'You Disposed of the Guard!');
        pause;
        crlf;
       end;

      end;

     end;

     if not silent then begin
      {remove guard}
      add_shadow(SRemove,pl[1]^,'','',0);
     end;

    end;
   end;

  end;
 end; {for i:= .end.

 {*GUARD FIGHT* .end.}


 {dispose temp vars}
 dispose(pl[1]);


 {lets bail out of npc challenger lost}
 if (silent=true) and (challenger.hps<1) then begin
  exit;
 end;


 {***********************}
 {*** FIGHT THE KING! ***}
 {***********************}

 {set kings hitpoints}
 if Config.ResurrectTheKing=true then begin
  pl0.hps:=pl0.maxhps;
 end;

 if not silent then begin
  crlf;
  crlf;
  sd(config.textcolor,'You enter the Royal Bedroom...');
  make_delay_dots(2,7,300);
  crlf;
 end;

 if not silent then begin
  if pl0.hps>0 then begin
   sd(global_kingcol,pl0.name2);
   d(config.textcolor,' jumps out of '+sex3[king.sexy]+' bed and stares at you;');
   case random(4) of
    0: d(global_talkcol,'  - You will never get out of this room alive!');
    1: d(global_talkcol,'  - Surrender now and I will spare thee!');
    2: d(global_talkcol,'  - How dare you bare hands on the Royal Family!');
    3: d(global_talkcol,'  - Your head will be on the City Walls this evening!');
   end;
   crlf;
   pause;
   crlf;
   d(15,'You are up against the '+upcasestr(kingstring(king.sexy))+'!');
   pause;
  end
  else begin
   {king is already dead}
   d(15,'The bedroom is empty!');
   sd(global_kingcol,king.name);
   d(config.textcolor,' is '+ulred+'DEAD'+config.textcol1+'!');
   d(config.textcolor,'The Castle is in your hands!');
   crlf;
  end;
 end;

 {challenger gets the castle by default!}
 if pl0.hps<1 then begin
  new_ruler(false);
 end
 else begin


  if silent then begin
   rounds:=0;
   repeat
    inc(rounds);
    computer_computer(true,true,challenger,pl0);
   until (challenger.hps<1) or (pl0.hps<1) or (rounds>9999);

   {update "killedby" variable in relations data file}
   if challenger.hps<1 then begin
    killed_by_stats(pl0,challenger);
   end;
   if pl0.hps<1 then begin
    killed_by_stats(challenger,pl0);
   end;

   challenger_begged:=false;
  end
  else begin

   {fight}
   repeat
    challenger_begged:=player_computer(challenger,pl0,false,2);
   until (challenger_begged) or (challenger.hps<1) or (pl0.hps<1);

   {update "killedby" variable in relations data file}
   if challenger.hps<1 then begin
    killed_by_stats(pl0,challenger);
   end;
   if pl0.hps<1 then begin
    killed_by_stats(challenger,pl0);
   end;

  end;

  if challenger_begged then begin

   {challenger begged for mercy}

   {king automatically sends challenger to prison}
   challenger.location:=offloc_prison;
   challenger.daysinprison:=1;
   user_save(challenger);

   {news-paper}
   newsy(true,
   'Raise the Standard of Revolt!',
   ' '+uplc+challenger.name2+config.textcol1+' fought '+upcasestr(kingstring(king.sexy))+' '+ukingc+pl0.name2
    +config.textcol1+'!',
   ' '+ulred+challenger.name2+config.textcol1+' lost the fight, begged for mercy and was sent to Prison.',
   '',
   '',
   '',
   '',
   '',
   '',
   '');


   {mail the king}
   s:='Infiltration';
   post(MailSend,
   pl0.name2,
   pl0.ai,
   false,
   mailrequest_nothing,
   '',
   ulred+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+challenger.name2+config.textcol1+' attacked you in your Chambers!',
   uplc+challenger.name2+config.textcol1+' begged for mercy! You spared '+sex3[challenger.sex]+' life.',
   uplc+challenger.name2+config.textcol1+' was sent to prison, awaiting your sentence.',
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

   if not silent then begin
    crlf;
    sd(config.textcolor,'You throw yourself before ');
    sd(global_kingcol,pl0.name2+'s');
    d(config.textcolor,' feet.');
    d(config.textcolor,'Your life is spared.');
    pause;

    sd(config.textcolor,'You are chained and led off to the ');
    sd(10,'Royal Prison');
    d(config.textcolor,'.');
    crlf;
    pause;

    crlf;
    d(config.textcolor,'You are thrown in a damp prison dungeon...');
    d(config.textcolor,'Your only company will be the rats and cockroaches.');
    d(config.textcolor,'Your fate is in the hands of the Royal Family.');
    crlf;
    pause;

    normal_exit; {exit program}
   end;

  end {challenger begged for mercy *END*}
  else begin

   {evaluate fight! who won?}

   if (pl0.hps<1) and (challenger.hps<1) then begin
    {both died}

    s:=kingstring(pl0.sex);

    {news-paper}
    newsy(true,
    'Raise the Standard of Revolt!',
    ' '+uplc+challenger.name2+config.textcol1+' fought '+s+' '+ukingc+pl0.name2+config.textcol1+'!',
    ' '+ulred+pl0.name2+config.textcol1+' was killed!',
    ' '+ulred+challenger.name2+config.textcol1+' died of '+sex3[challenger.sex]+' wounds.',
    ' The intruder failed to usurp the Throne!',
    '',
    '',
    '',
    '',
    '');

    {mail the king}
    s:='Infiltration';
    post(MailSend,
    pl0.name2,
    pl0.ai,
    false,
    mailrequest_nothing,
    '',
    ulred+s+config.textcol1,
    mkstring(length(s),underscore),
    uplc+challenger.name2+config.textcol1+' attacked you in your Chambers!',
    uplc+challenger.name2+config.textcol1+' defeated you!',
    'However, '+uplc+challenger.name2+config.textcol1+' died from '+sex3[challenger.sex]+' wounds and',
    'was unable to take the Castle.',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

    {save the king}
    user_save(pl0);

    if not silent then begin
     {exit preparations}
     d(12,'You failed!');
     {challenger.allowed:=false;}
     Reduce_Player_Resurrections(challenger,true);
     pause;
     normal_exit;
    end;

   end
   else if challenger.hps<1 then begin
    {challenger died}

    s:=KingString(pl0.sex);

    {news-paper}
    newsy(true,
    'Raise the Standard of Revolt!',
    ' '+uplc+challenger.name2+config.textcol1+' fought '+s+' '+ukingc+pl0.name2+config.textcol1+'!',
    ' '+ulred+challenger.name2+config.textcol1+' was killed!',
    ' The intruder failed to usurp the throne. Hail the '+s+'!',
    '',
    '',
    '',
    '',
    '',
    '');

    {mail the king}
    s:='Infiltration';
    post(MailSend,
    pl0.name2,
    pl0.ai,
    false,
    mailrequest_nothing,
    '',
    ulred+s+config.textcol1,
    mkstring(length(s),underscore),
    uplc+challenger.name2+config.textcol1+' attacked you in your Chambers!',
    'You defeated '+uplc+challenger.name2+config.textcol1+'!',
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

    {save the king}
    user_save(pl0);

    if not silent then begin
     {exit preparations}
     d(12,'You failed!');
     d(12,'Your '+config.moneytype+' has been confiscated!');
     {challenger.allowed:=false;}
     Reduce_Player_Resurrections(challenger,true);
     challenger.gold:=0;
     pause;
     normal_exit;
    end;

   end
   else begin

    {challenger defeated the King!}
    new_ruler(true);

   end;

  end; {evaluate fight *END*}
 end;


end; {Challenge_King *end*}

end. {Unit ChallKng .end.}
