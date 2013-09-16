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



Unit Mail; {Usurper - Mail and Message Unit
            This unit handles all mail to/from users.

            Special "event mail" is defined by using the mailrequest_??
            constants (see CMS.PAS)}

            {for the message editor see 'Post_To.pas'}
Interface

Uses Init;

type MailAction = (MailRead,MailSend); {Type of Mail action}

Function Old_Mail(const mail:mailrec):boolean; {is mail record old}
Procedure Read_My_Mail(var ply : userrec); {read user mail}

Procedure Post(action : MailAction;  {MailRead or MailSend}
               const receiver : s30; {recipent of message}
               plai   : char;        {receivers AI, "C"omputer or "H"uman}
               destgod: boolean;     {is receiver a god?}
               special: byte;        {see mailrequest_XX constants}
               const sender : s100;  {senders name}
               const line1  : s100;  {message text follows...}
               const line2  : s100;
               const line3  : s100;
               const line4  : s100;
               const line5  : s100;
               const line6  : s100;
               const line7  : s100;
               const line8  : s100;
               const line9  : s100;
               const line10 : s100;
               const line11 : s100;
               const line12 : s100;
               const line13 : s100;
               const line14 : s100;
               const line15 : s100);

Implementation

Uses Jakob, Cms, Post_to,
     Orb, Gym, Various,
     Various2, Various3,
     News, Relation, Online,
     Children, InitGods, VarGods,
     File_Io, SysUtils;

Procedure Read_My_Mail(var ply : userrec);
begin {read ply:s mail}
 post(MailRead,
 ply.name2,
 ply.ai,
 false,
 mailrequest_nothing,
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
 crlf;

end; {read_my_mail *end*}

Function Old_Mail(const mail:mailrec):boolean; {is this mail record old?}
var
    result : boolean;

    tempdat1,
    tempdat2 : UDate;

begin

 {set dates}
 tempdat1:=fix_date(todays_date);
 tempdat2:=fix_date(mail.date);

 {if the days passed between creation of mail and current date are more
  than defined in .cfg then we consider this mail record to be old}
 if days_between(tempdat1,tempdat2)>config.maxmail then begin
  result:=true;
 end
 else begin
  result:=false;
 end;

 {return result}
 old_mail:=result;

end; {Old_Mail *end*}

Procedure Save_Mail(var postme:mailrec);
const max_records = 65500; {max records allowed in mail database}
var
    size,
    empty_mailslot : word;

    saved : boolean;

begin

 {lock mail file and find space to save new mail record}
 {find deleted mail(record) in mailfile.}

 {init vars}
 saved:=false;
 empty_mailslot:=1;

 {lock mailfile}
 if Lock_MailFile(FLock) then begin

  {set filesize}
  size:=global_mailfilesize;

   empty_mailslot:=size+1;

   {save mail}
   if empty_mailslot>max_records then begin
    {database is full - should never happen, but just in case..}
    crlf;
    d(12,'ALERT! Mail database is full ('+global_mafile+').');
    d(12,'Unable to save mail.');
    d(12,'The Sysop should be informed.');
   end
   else begin

    {save mail}
    load_Mailfile(fsave,postme,empty_mailslot);

   end;

  {unlock mailfile}
  Lock_MailFile(FUnlock);

 end
 else begin

  {we were unable to get a lock on the mailfile}
  unable_to_lockfile(global_mafile);

 end;

end; {Save_mail *end*}

Procedure Post;
var

   King   : ^KingRec; {used when processing requests from the King}
   Quest  : ^QuestRec; {used when processing quests proposals}
   Amount : ^AmountRec; {used when processing drink requests}
   Ply0   : ^UserRec; {used when processing Relation requests}

   Letter,
   A_Mail  : ^mailrec; {used when replying to letters etc etc}

   i,
   j,
   x,
   y : longint;

   l,
   k,
   col : byte;

   count : integer;

   s : s70;
   anonym : s30;

   ai,
   cho : char;

   qtext : array [1..10] of ^s100;
   worm  : array [1..global_maxmaillines] of ^s100;

   found,
   quote,
   readerisgod,
   forced_quest,
   killed,
   accept_quest : boolean;

procedure disposal;
var i : byte;
begin {dispose pointer vars}

 dispose(King);
 dispose(Quest);
 dispose(Amount);
 dispose(Ply0);
 dispose(Letter);
 dispose(A_Mail);

 for i:=1 to 10 do begin
  dispose(qtext[i]);
 end;

 for i:=1 to global_maxmaillines do begin
  dispose(worm[i]);
 end;

end; {disposal *end*}

procedure join_team; {mailrequest_jointeam}
var

    ok,
    team_full : boolean;

    id : s15;
    team : s25;
    applicant : s30;

    filenr : word;

begin

 {line1 -letterhead}
 {line2 -underscore}
 {line3 contains name of applicant}
 {line4 contains id of applicant}
 {line5 contains filex of applicant, position in userfile}
 {line6 contains name of team applicant wants to join}

 applicant:=letter^.mess[3];
 id:=letter^.mess[4];
 filenr:=str_to_nr(letter^.mess[5]);
 team:=letter^.mess[6];

 if (player.team='') or (player.team<>team) then begin
  {player is no longer WITH the team sender applied for}
  exit;
 end;

 {load applicant}
 load_character(ply0^,1,filenr);

 ok:=false;
 if (ply0^.name2=applicant) and
    (ply0^.id=id) and
    (ply0^.team='') and
    (player_active(ply0^,false)=true) then begin
  ok:=true;
 end;

 if not ok then begin
  {applicant not found in userfile}
  exit;
 end;

 {confirm application}
 crlf;
 s:='Team Membership Application';
 d(7,s);
 d(5,mkstring(length(s),underscore));
 d(global_plycol,ply0^.name2+config.textcol1+', the '+race_display(2,ply0^.race,0)+', would like become a member of '
               +'your gang.');

 {display player profile}
 player_profile(player,ply0^);

 crlf;
 if confirm('Accept '+uplc+ply0^.name2+config.textcol1+' as member','Y')=true then begin

  {application accepted}
  d(config.textcolor,'Informing '+uplc+ply0^.name2+config.textcol1+'...');

  {is the team full?}
  i:=team_members(player.team);

  if i>=global_maxteammembers then team_full:=true
                              else team_full:=false;

  if team_full then begin
   {application denied}
   d(12,'Sorry, but the team is full!');
   d(global_plycol,ply0^.name2+config.textcol1+' is not accepted as a member.');
   if is_online(ply0^.name2,online_player)=true then begin
    online_send_to_player(ply0^.name2,online_player,uplc+player.name2+config.textcol1+' declined your application for team'
                                           +' membership!');
   end;

   {mail ply0}
   post(MailSend,
   ply0^.name2,
   ply0^.ai,
   false,
   mailrequest_nothing,
   '',
   ulred+'Membership Denied'+config.textcol1,
   mkstring(17,underscore),
   uplc+player.name2+config.textcol1+' was not able to accept your application for membership in',
   'the '+utec+player.team+config.textcol1+' crew. Their theam is full!',
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

   {application granted}
   if is_online(ply0^.name2,online_player)=true then begin
    online_send_to_player(ply0^.name2,online_player,BroadCast_JoinTeam+player.team);
    online_send_to_player(ply0^.name2,online_player,uplc+player.name2+config.textcol1+' accepted your application for '
                                           +'membership in the '+utec+player.team+config.textcol1+' crew!');
   end;

   {inform owners teammates}
   Team_Report_All(player.team,  {team to send message to}
                   player.name2, {player name to exclude}
                   'Team Membership', {news-header}
                   mailrequest_nothing, {mailrequest_constant}
                   uplc+player.name2+config.textcol1+' accepted '+uplc+ply0^.name2
                       +config.textcol1+' as a new member in your crew.',
                   '',
                   '',
                   '');

   {update ply0^s flags}
   transfer_teamstatus(player,ply0^);

   {save user}
   user_save(ply0^);

   {mail ply0}
   post(MailSend,
   ply0^.name2,
   ply0^.ai,
   false,
   mailrequest_nothing,
   '',
   uyellow+'Accepted'+config.textcol1,
   mkstring(8,underscore),
   uplc+player.name2+config.textcol1+' accepted your application for membership in',
   'the '+utec+player.team+config.textcol1+' crew!',
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
   newsy(true,
   'New Gang Member!',
   ' '+uplc+ply0^.name2+config.textcol1+' was accepted member in the '+utec+player.team+config.textcol1+' crew.',
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
 else begin

  {application denied}
  d(config.textcolor,'Sorry, '+uplc+ply0^.name2+config.textcol1+'...');

  if is_online(ply0^.name2,online_player)=true then begin
   online_send_to_player(ply0^.name2,online_player,uplc+player.name2+config.textcol1+' declined your application for team'
                                           +' membership!');
  end;

  {inform owners teammates}
  Team_Report_All(player.team,  {team to send message to}
                  player.name2, {player name to exclude}
                  'Team Membership', {news-header}
                  mailrequest_nothing, {mailrequest_constant}
                  uplc+player.name2+ulred+' REFUSED '+uplc+ply0^.name2
                      +config.textcol1+' to join your crew.',
                  '',
                  '',
                  '');

  {mail ply0}
  post(MailSend,
  ply0^.name2,
  ply0^.ai,
  false,
  mailrequest_nothing,
  '',
  ulred+'Membership Denied'+config.textcol1,
  mkstring(17,underscore),
  uplc+player.name2+config.textcol1+' didn''t accept your application for membership in',
  'the '+utec+player.team+config.textcol1+' crew.',
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
  newsy(true,
  'Membership Denied',
  ' '+uplc+ply0^.name2+config.textcol1+' was '+ulred+'denied'+config.textcol1+' membership to the '+utec+player.team
     +config.textcol1+' crew.',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
 end;

end; {join_team *end*}

procedure gym_membership;{mailrequest_gymmembership}
var i : word;
  ReturnFileId : byte;
begin
 {sender applies for membership at the Gym}

 {we exit right away if receiver/player is no longer owner of The Gym}
 if (player.gym_owner=0) or (player.team='') then begin
  exit;
 end;

 {locate/load sender}
 i:=Look_for_ID(letter^.mess[1],'H',ReturnFileId);

 {load applicant}
 load_character(ply0^,ReturnFileId,i);

 {unable to locate applicant/deleted/deactivated}
 if (ply0^.name2<>letter^.sender) or
    (ply0^.id<>letter^.mess[1]) or
    (player_active(ply0^,false)=false) or
    (ply0^.name1=global_delname1) or
    (ply0^.name2=global_delname2) then begin
  exit;
 end;

 {we exit if sender already has become a member of the Gym}
 if ply0^.gym_card>0 then begin
  exit;
 end;

 {we exit if they are members of the same team}
 if ply0^.team=player.team then begin
  exit;
 end;

 {confirm application}
 crlf;
 s:='Gym membership Application';
 d(7,s);
 d(5,mkstring(length(s),underscore));
 d(global_plycol,ply0^.name2+config.textcol1+', the '+race_display(2,ply0^.race,0)+', would love to get access to '
                 +gymcol+'The Gym'+config.textcol1+'.');


 {display player profile}
 player_profile(player,ply0^);

 crlf;
 if confirm('Accept '+uplc+ply0^.name2+config.textcol1+' as member','Y')=true then begin

  {application accepted}
  d(config.textcolor,'Informing '+uplc+ply0^.name2+config.textcol1+'...');

  {update ply0}
  ply0^.gym_card:=1;
  user_save(ply0^);

  if is_online(ply0^.name2,online_player)=true then begin
   online_send_to_player(ply0^.name2,online_player,uplc+player.name2+config.textcol1+' accepted your application for '+gymcol
       +'Gym'+config.textcol1+' membership!');
  end;

  {inform owners teammates}
  Team_Report_All(player.team,  {team to send message to}
                  player.name2, {player name to exclude}
                  'The Gym',    {news-header}
                  mailrequest_nothing, {mailrequest_constant}
                  uplc+player.name2+config.textcol1+' gave '+uplc+ply0^.name2
                      +config.textcol1+' access to '+gymcol+'The Gym'+config.textcol1+'.',
                  '',
                  '',
                  '');

  {mail ply0}
  post(MailSend,
  ply0^.name2,
  ply0^.ai,
  false,
  mailrequest_nothing,
  '',
  uyellow+'Gym Membership'+config.textcol1,
  mkstring(14,underscore),
  uplc+player.name2+config.textcol1+' accepted your application for membership in '+gymcol+'The Gym'+config.textcol1+'!',
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

  {news-paper}
  newsy(true,
  'New Gym member',
  ' '+uplc+ply0^.name2+config.textcol1+' was accepted membership to '+gymcol+'The Gym'+config.textcol1+'!',
  ' '+uplc+player.name2+config.textcol1+' in the '+utec+player.team+config.textcol1+' crew accepted '+uplc+ply0^.name2
     +config.textcol1+'.',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
 end
 else begin

  {application denied}
  d(config.textcolor,'Sorry, '+uplc+ply0^.name2+config.textcol1+'...');

  if is_online(ply0^.name2,online_player)=true then begin
   online_send_to_player(ply0^.name2,online_player,uplc+player.name2+config.textcol1+' declined your application for '+gymcol
       +'Gym'+config.textcol1+' membership!');
  end;

  {inform owners teammates}
  Team_Report_All(player.team,  {team to send message to}
                  player.name2, {player name to exclude}
                  'The Gym',    {news-header}
                  mailrequest_nothing, {mailrequest_constant}
                  uplc+player.name2+config.textcol1+' denied '+uplc+ply0^.name2
                      +config.textcol1+' access to '+gymcol+'The Gym'+config.textcol1+'.',
                  '',
                  '',
                  '');

  {mail ply0}
  post(MailSend,
  ply0^.name2,
  ply0^.ai,
  false,
  mailrequest_nothing,
  '',
  ulred+'Membership Denied'+config.textcol1,
  mkstring(17,underscore),
  uplc+player.name2+config.textcol1+' doesn''t think you qualify for the '+gymcol+'The Gym'+config.textcol1+'!',
  'The malevolent '+uplc+player.name2+config.textcol1+' tore your application to pieces.',
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
  newsy(true,
  'Turned Down',
  ' '+uplc+ply0^.name2+config.textcol1+' is denied membership to '+gymcol+'The Gym'+config.textcol1+'.',
  ' '+uplc+player.name2+config.textcol1+' in the '+utec+player.team+config.textcol1+' crew says NO!',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

 end;

end; {gym_membership *end*}

procedure Fighting_children; {mailrequest_childfightExp}
var
   childname,
   otherchildname : s30;

   childsex  : byte;
   xp        : longint;
begin

 {line1: child.name
  line2: otherchild.name
  line3: child.sex
  line4: exp earned
 }
 childname:=letter^.mess[1];
 otherchildname:=letter^.mess[2];
 childsex :=str_to_nr(letter^.mess[3]);
 xp       :=str_to_nr(letter^.mess[4]);

 s:='Parental Reward';
 d(5,s);
 d(10,cool_string(length(s),'=','-',10,10));
 d(config.textcolor,'You receive '+uwhite+commastr(xp)+config.textcol1+' experience points for the victory');
 d(config.textcolor,'of your '+sex7[childsex]+ukidc+' '+childname+config.textcol1+' over '+ukidc+otherchildname
                    +config.textcol1+'.');

 {give player experience}
 incplayerexp(player,xp);

end; {fighting_children *end*}

procedure Silent_Experience; {mailrequest_SilentExp}
var
   i : word;
   xp : longint;
begin

 {line 1:experience reward}
 xp:=str_to_nr(letter^.mess[1]);

 {the rest of the lines can contain any message.}
 for i:=2 to global_maxmaillines do begin
  if letter^.mess[i]<>'' then begin
   d(config.textcolor,letter^.mess[i]);
  end;
 end; {for i:= .end.}

 {DEBUG LINE s:='Silent Experience Reward!';}

 {give player experience}
 incplayerexp(player,xp);

end; {silent_experience *end*}

procedure immortal_offer(var ply : userrec);
var god0, god1 : godrec;
    go_ahead : boolean;

    request : char;

    ss1,ss2,ss3 : s100;

begin

 {SENDER, an immortal, has sent a request to receiver to become a believer}
 {request can be of type: Threat, Normal or Gift}

 {init}
 go_ahead:=true;
 request:='N';
 if letter^.mess[1]='*threat*' then request:='T';
 if letter^.mess[1]='*normal*' then request:='N';
 if letter^.mess[1]='*gift*' then request:='G';

 {let us first check if the Immortal still is active}
 if load_god_by_name(letter^.sender,god0)=false then begin
  {letter^.readflag=true;}
  go_ahead:=false;
 end;

 {check if ply perhaps already worships immortal sender}
 if go_ahead then begin
  if ply.god=letter^.sender then begin
   go_ahead:=false;
  end;
 end;

 if go_ahead then begin
  {present the offer}
  d(5,'Worship Request');
  d(5,mkstring(15,underscore));
  d(config.textcolor,'The immortal '+ugodc+god0.name+config.textcol1+' wants You to join '+sex3[god0.sex]+' ranks!');

  if request='T' then begin
   d(global_godcol,god0.name+config.textcol1+' sends a warning;');
   d(12,' DON''T TURN THIS OFFER DOWN! You will be sorry if you do...');
  end;

  crlf;
  sd(config.textcolor,'Currently you are; ');
  if ply.god<>'' then begin
   d(7,'a believer in '+ugodc+ply.god);
  end
  else begin
   d(7,'a Pagan');
  end;

  if confirm('Become a believer in '+ugodc+god0.name+config.textcol1,'N')=true then begin
   {ply ACCEPTED to become a believer in immortal (god0) }

   crlf;

   case request of
    'T':begin
         d(12,'You decide to become a follower of '+ugodc+god0.name+config.textcol1+'!');
         d(12,'You send word of your decision.');
         d(12,'...threats seem to work on you....');
        end;
    'N':begin
         d(12,'You decide to become a follower of '+ugodc+god0.name+config.textcol1+'!');
         d(12,'You send word of your decision.');
        end;
    'G':begin
         d(12,'You accept the gifts (bribes) offered by '+ugodc+god0.name+config.textcol1+'!');
         d(12,'You are now a follower of the immmortal '+ugodc+god0.name+config.textcol1+'!');
         d(12,'You send word of your decision.');
        end;
   end; {case .end.}


   {inform god, the new one}
   case request of
    'T': ss1:=uplc+ply.name2+config.textcol1+' has found faith in you! (Your threats seem to have worked';
    'N': ss1:=uplc+ply.name2+config.textcol1+' accepted your offer and has found faith in you!';
    'G': ss1:=uplc+ply.name2+config.textcol1+' accepted your gifts (bribes) and is now one of your followers!';
   end; {case .end.}

   if ply.god<>'' then begin
    ss2:='I don''t think that '+ugodc+player.god+config.textcol1+' will appreciate this decision.';
   end
   else begin
    ss2:='';
   end;

   s:='New Acolyte!';
   post(MailSend,
   god0.name,
   god0.ai,
   true,
   mailrequest_nothing,
   '',
   ulred+s+config.textcol1,
   mkstring(length(s),underscore),
   ss1,
   ss2,
   '',
   uwhite+'Your powers increase!'+config.textcol1,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {inform former god, if any}
   if ply.god<>'' then begin

    if load_god_by_name(ply.god,god1)=true then begin

     s:='Traitor!';
     case request of
      'T': ss1:=uplc+ply.name2+config.textcol1+' was forced / intimidated by '+ugodc+god0.name+config.textcol1
                +' to switch loyalties!';
      'N': ss1:=uplc+ply.name2+config.textcol1+' has left your flock for mighty immortal '+ugodc+god0.name
           +config.textcol1+'!';
      'G': ss1:=uplc+ply.name2+config.textcol1+' received several gifts from the immortal '+ugodc+god0.name+config.textcol1
            +' to make '+sex[ply.sex]+' switch sides!';
     end; {case .end.}

     post(MailSend,
     god1.name,
     god1.ai,
     true,
     mailrequest_nothing,
     '',
     ulred+s+config.textcol1,
     mkstring(length(s),underscore),
     ss1,
     uwhite+'Your powers are diminishing!'+config.textcol1,
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
   s:='';
   case request of
    'T': s:=' '+uplc+ply.name2+config.textcol1+' was threatened to join the following of '+ugodc+god0.name
           +config.textcol1+'!';
    'N': s:=' '+uplc+ply.name2+config.textcol1+' accepted an invitation from the god '+ugodc+god0.name+config.textcol1+'!';
    'G': s:=' '+uplc+ply.name2+config.textcol1+' took several gifts (bribes) and joined '+ugodc+god0.name
         +config.textcol1+'!';
   end; {case .end.}

   if ply.god<>'' then begin

    Newsy(true,
    'Lost Faith',
    ' '+uplc+ply.name2+config.textcol1+' lost faith in '+ugodc+ply.god+config.textcol1+'!',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

   end;

   Newsy(true,
   'Faith',
   ' '+uplc+ply.name2+config.textcol1+' found faith in '+ugodc+god0.name+config.textcol1+'!',
   s,
   '',
   '',
   '',
   '',
   '',
   '',
   '');


   {update god, former god and ply}
   inc(god0.believers);

   {experience, change this and you must change in godworld.pas as well}
   incgodexp(god0,150);

   load_god(fsave,god0,god0.recnr);

   if ply.god<>'' then begin
    if load_god_by_name(ply.god,god1)=true then begin
     if god1.believers>0 then dec(god1.believers);
     load_god(fsave,god1,god1.recnr);
    end;
   end;

   ply.god:=god0.name;
   user_save(ply);

  end {accept .end.}
  else begin

   crlf;

   case request of
    'T':begin
         d(12,'You don''t take threats! Even when they come from the Gods!');
         d(12,'You send word of your decision.');
        end;
    'N':begin
         d(12,'You reject the offer from '+ugodc+god0.name+config.textcol1+'!');
         d(12,'You send word of your decision.');
        end;
    'G':begin
         d(12,'You reject the offer and gifts from '+ugodc+god0.name+config.textcol1+'!');
         d(12,'You send word of your decision.');
        end;
   end; {case .end.}

   {ply TURNED DOWN offer to become a believer in immortal (god0) }

   {inform god, of bad news}
   s:='Ungrateful Mortal';
   post(MailSend,
   god0.name,
   god0.ai,
   true,
   mailrequest_nothing,
   '',
   uyellow+s+config.textcol1,
   mkstring(length(s),underscore),
   'The puny '+lowercase(racenames[ply.race])+' '+uplc+ply.name2+config.textcol1+' rejected your offer',
   'to become a worshipper of you.',
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

   {inform current god, if any}
   if player.god<>'' then begin

    if load_god_by_name(player.god,god1)=true then begin

     case request of
      'T':begin
           s:='Loyalty!';
           ss1:=uplc+player.name2+config.textcol1+' was threatened by the immortal '+ugodc+god0.name+config.textcol1+'!';
           ss2:=uplc+player.name2+config.textcol1+' stayed loyal to you despite the threats!';
           ss3:=uplc+player.name2+config.textcol1+' has faith in you!';
          end;
      'G':begin
           s:='Loyalty!';
           ss1:=uplc+player.name2+config.textcol1+' was tempted by the mighty immortal '+ugodc+god0.name+config.textcol1+'!';
           ss2:=uplc+player.name2+config.textcol1+' received several gifts from '+ugodc+god0.name+config.textcol1
            +' to switch sides!';
           ss3:=uplc+player.name2+config.textcol1+' continues to have faith in you!';
          end;
      'N':begin
           s:='Loyalty!';
           ss1:='An attempt was made to shift '+uplc+player.name2+'s'+config.textcol1+' loyalties to the immortal '+ugodc
            +god0.name+config.textcol1+'!';
           ss2:=uplc+player.name2+config.textcol1+' stayed loyal to you!';
           ss3:='';
          end;
     end; {case .end.}


     {mail god}
     post(MailSend,
     god1.name,
     god1.ai,
     true,
     mailrequest_nothing,
     '',
     uyellow+s+config.textcol1,
     mkstring(length(s),underscore),
     ss1,
     ss2,
     ss3,
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
   s:='';
   case request of
    'T': s:=' '+uplc+player.name2+config.textcol1+' stood up against the immortal '+ugodc+god0.name+'s'+config.textcol1
          +' untolarable threat!';
    'N': s:=' '+uplc+player.name2+config.textcol1+' resisted an attempt to accept a new God.';
    'G': s:=' '+uplc+player.name2+config.textcol1+' rejected several bribes (gifts) offered.';
   end; {case .end.}

   ss1:='';
   if player.god<>'' then begin
    ss1:=' '+uplc+player.name2+config.textcol1+' stayed loyal to '+ugodc+player.god+config.textcol1+'!';
   end;

   Newsy(true,
   'Heaven is denied',
   ' '+uplc+player.name2+config.textcol1+' rejected the immortal '+ugodc+god0.name+'s'+config.textcol1+' offer!',
   s,
   ss1,
   '',
   '',
   '',
   '',
   '',
   '');


  end;

 end;

end;

procedure drink_offer;
var
    ADrink : ^DrinkRec; {used when processing drink requests}

begin

 {SENDER has sent a free drink to PLAYER}
 found:=false;

 {init}
 new(ADrink);

 {let us first check whether the drink is valid}

 {extract drink #}
 x:=str_to_nr(letter^.mess[1]);

 if (x>0) and (x<=fs(fsdrink)) then begin

  found:=true;
  load_drink(fload,adrink^,x);

  {lets compare drink data with the ones sent along in the message}
  if adrink^.name<>letter^.mess[2] then found:=false;
  if adrink^.date<>letter^.mess[3] then found:=false;
  if letter^.mess[4]='Y' then s:='*Unknown*'
  else s:=letter^.sender;

 end;

 {did we pass all tests?}
 if found then begin
  crlf;

  {pre-drink-text, important! this text must be the same as
   when you send poison to a player. to be able to fool him
   the texts must be identical.}

  d(5,'Cocktail Party');
  d(5,mkstring(14,underscore));
  d(global_plycol,S+config.textcol1+' has sent you a free drink!');
  d(config.textcolor,'The cocktail is the famous '+udrinkc+adrink^.name+config.textcol1+'.');

  if confirm('Drink it','Y')=true then begin

   {any drink attempts left?}
   if player.drinksleft<1 then begin

    {keep mail, since player was unable to have the drink}
    letter^.readflag:=false;

    d(12,'You have a terrible hangover! You can''t accept this drink.');
    d(12,'You can have more drinks tomorrow.');
    crlf;
    pause;
   end
   else begin

    {send reply to sender}
    if is_online(letter^.sender,online_player) then begin
     online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1
      +' accepted your drink!');
    end
    else begin
     {regular mail}
     post(MailSend,
     letter^.sender,
     'H',
     false,
     mailrequest_nothing,
     '',
     uwhite+'Free Drink'+config.textcol1,
     mkstring(10,underscore),
     uplc+player.name2+config.textcol1+' accepted your drink!',
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

    dec(player.drinksleft);

    {enjoy the free drink!}
    Drink_a_drink(Player,MailDrink,ADrink^,Amount^,x);

   end;

  end
  else begin
   {drink offer declined!}

   {send reply to sender}
   if is_online(letter^.sender,online_player) then begin
    online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1
    +' didn''t accept your drink!');
   end
   else begin
    {regular mail}
    post(MailSend,
    letter^.sender,
    'H',
    false,
    mailrequest_nothing,
    '',
    ulred+'No Drinks'+config.textcol1,
    mkstring(9,underscore),
    uplc+player.name2+config.textcol1+' didn''t accept your drink!',
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

 {dispose temporary variables}
 dispose(ADrink);

end; {drink_offer *end*}

procedure raising_children(mailconstant:word);
                           {mailrequest_childraisingExp,
                            mailrequest_childpoisonedExp,
                            mailrequest_childcursedExp,
                            mailrequest_childdepressedExp}
var
   childname : s30;
   childsex  : byte;
   xp        : longint;
begin

 {line1: child.name
  line2: child.sex
  line3: exp earned
 }
 childname:=letter^.mess[1];
 childsex :=str_to_nr(letter^.mess[2]);
 xp       :=str_to_nr(letter^.mess[3]);

 if mailconstant=mailrequest_childraisingExp then begin
  s:='Raising Your Children';
  d(5,s);
  d(2,cool_string(length(s),'=','-',10,2));
  d(config.textcolor,'You receive '+uwhite+commastr(xp)+config.textcol1+' experience points for');
  d(config.textcolor,'raising your '+sex7[childsex]+'; '+ukidc+childname+config.textcol1+'.');

  incplayerexp(player,xp);
 end
 else if mailconstant=mailrequest_childCursedExp then begin
  d(12,'Grieving your Children');
  d(14,'-=-=-=-=-=-=-=-=-=-=-=');
  d(config.textcolor,'You lose '+uwhite+commastr(xp)+config.textcol1+' experience points for going through the');
  d(config.textcolor,'hardship of seeing your '+sex7[childsex]+'; '+ukidc+childname+config.textcol1
    +' being cursed.');

  decplayerexp(player,xp);
 end
 else if mailconstant=mailrequest_childDepressedExp then begin
  d(12,'Grieving your Children');
  d(14,'-=-=-=-=-=-=-=-=-=-=-=');
  d(config.textcolor,'You lose '+uwhite+commastr(xp)+config.textcol1+' experience points for going through the');
  d(config.textcolor,'hardship of seeing your '+sex7[childsex]+'; '+ukidc+childname+config.textcol1
    +' being depressed.');

  decplayerexp(player,xp);
 end

 else if mailconstant=mailrequest_childpoisonedExp then begin
  d(12,'Grieving over your Children');
  d(14,'-=-=-=-=-=-=-=-=-=-=-=-=-=-');
  d(config.textcolor,'You lose '+uwhite+commastr(xp)+config.textcol1+' experience points for going through the');
  d(config.textcolor,'hardship of seeing your '+sex7[childsex]+'; '+ukidc+childname+config.textcol1
    +' being ill.');

  decplayerexp(player,xp);
 end;

end; {raising_children *end*}

procedure birthday; {mailrequest_birthday}
var
    i : integer;
    ch : char;
    done : boolean;
    tries: byte;
    relation : ^RelationRec;

begin

 {maint.pas sends this birthday-mail}

 {Maintenance has decided that player has become a year older (birthday)}
 {1.messageline carries the age which the player has reached}

 {init temporary variables}
 new(relation);

 {extract AGE player reached}
 s:=letter^.mess[1];
 x:=str_to_nr(s);

 crlf;
 d(14,'Birthday Party!');
 d(config.textcolor,'You celebrated your '+uwhite+commastr(player.age)+config.textcol1+' birthday!');
 d(config.textcolor,'The Town council has gracefully decided you worthy a present.');

 done:=false;
 repeat

  crlf;
  d(config.textcolor,'Choose a gift:');
  menu('(E)xperience');
  menu('(L)ove');
  menu('(A)dopt a child');
  menu('(S)kip');
  sd(config.textcolor,':');

  {get user-input}
  ch:=upcase(getchar);

  
  {evaluate user-input}
  case ch of
   'S':begin
        d(15,'I''m sick of gifts!');
        done:=true;
       end;
   'E':begin {experience}
        d(15,'Experience');
        x:=player.level*1322;
        incplayerexp(player,x);
        crlf;
        d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');
        pause;
        done:=true;
       end;
   'L':begin {love}

        d(15,'Love!');
        crlf;
        sd(config.textcolor,'A powerful '+ulred+'Magic Arrow'+config.textcol1+' sets out for a random target...');

        {locate random target}
        found:=false;
        tries:=0;
        repeat

         i:=random(2)+1;
         case i of
          1:   j:=random(fs(fsplayer))+1;
          else j:=random(fs(fsnpc))+1;
         end;

         {load random character}
         load_character(ply0^,i,j);

         {tries}
         inc(tries);

         if (player_active(ply0^,false)=true) and
            (ply0^.name2<>player.name2) and
            (ply0^.id<>player.id) and
            (ply0^.sex<>player.sex) then begin

          {load relation}
          Social_Relation(player,ply0^,relation^);

          if relation^.relation1<>global_relationMarried then begin

           {correct relation}
           correct_relation(player.name2,relation^);

           {update relations between players to LOVE}
           relation^.relation1:=global_relationLove;
           relation^.relation2:=global_relationLove;

           {save relation}
           load_relation(fsave,relation^,relation^.recnr);

           found:=true;
          end;

         end;

        until (found) or (tries>15);

        if found then begin
         d(14,'HIT!');
         crlf;
         d(global_plycol,ply0^.name2+config.textcol1+' is madly in love with you!');
         d(config.textcolor,'The secret love potion worked!');

         {news-paper}
         newsy(true,
         'Love Arrow!',
         ' '+uplc+ply0^.name2+config.textcol1+' was hit by a '+ulred+'Magic Arrow'+config.textcol1+'!',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '');

         {mail player who got hit}
         post(MailSend,
         ply0^.name2,
         ply0^.ai,
         false,
         mailrequest_nothing,
         '',
         ulred+'Magic Arrow'+config.textcol1,
         mkstring(11,underscore),
         'You were hit by a '+ulred+'Magic Arrow'+config.textcol1+'!',
         'It was some kind of love poison...you feel strongly for '+uplc+player.name2+config.textcol1+'!',
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


         pause;

        end
        else begin
         d(12,'Missed!');
        end;

        done:=true;

       end;
   'A':begin
        d(15,'Adoption');
        crlf;
        d(12,'Sorry, there are no kids available for adoption right now!');
        pause;
        done:=false;
       end;

  end; {case .end.}

 until done=true;

 {dispose temporary variables}
 dispose(relation);

end; {birthday **END**}

procedure surprise_box; {mailrequest_chocolate/scorpions}
begin
 {SENDER has sent a box with [chocolate,scorpions] to PLAYER *relation event*}

 {let us first check whether the SENDER still is valid}
 ai:='A';
 x:=look_for_person('',letter^.sender,ai);

 if x>0 then begin

  {load sender}
  case ai of
   'H': load_character(ply0^,1,x);
   'C': load_character(ply0^,2,x);
  end; {case .end.}

  {Relation Header}
  crlf;
  love_header(' Gift ');

  case letter^.special of
   MailRequest_Chocolate:begin
    {a gift to you!}
    d(global_plycol,letter^.sender+config.textcol1+' has sent you a present.');
    d(config.textcolor,'It''s a box with a surprise inside!');
   end;
   MailRequest_Scorpions:begin
    {a gift to you!}
    d(global_plycol,letter^.sender+config.textcol1+' has sent you a present.');
    d(config.textcolor,'It''s a box with a surprise inside!');
   end;
  end; {case .end.}

  {display current relation}
  view_one_relation(player.name2,letter^.sender,true);

  crlf;
  if confirm('Open the Box','Y')=true then begin

   case letter^.special of
    mailrequest_chocolate:begin
     {earn experience}
     x:=player.level*185;
     y:=ply0^.level*95;
     x:=x+y;
     x:=x div 2;
     if x<100 then x:=100;
    end;
    mailrequest_scorpions:begin
     {earn experience}
     x:=player.level*95;
     y:=ply0^.level*185;
     x:=x+y;
     x:=x div 2;
     if x<100 then x:=100;
    end;
   end; {case .end.}

   case letter^.special of
    MailRequest_chocolate:begin
     {open box of chocolates}
     sd(config.textcolor,'You put your hand in the box...and out comes.');
     make_delay_dots(config.textcolor,4,800);
     d(15,'a box of Chocolates'+config.textcol1+'!');
    end;
    MailRequest_scorpions:begin
     {open box with scorpions}
     sd(config.textcolor,'You put your hand in the box...and out comes.');
     make_delay_dots(config.textcolor,4,800);
     d(12,'SCORPIONS!'+uwhite+'!!!');

     {death head}
     show_usurper_data(picture_DEATH_HEAD,false);

     {set player flags}
     player.hps:=0;
     killed:=true;
     {player.allowed:=false;}
     Reduce_Player_Resurrections(player,true);

     {news-paper}
     newsy(true,
     'Deadly Gift',
     ' '+uplc+player.name2+config.textcol1+' put '+sex3[player.sex]+' hand in a box with '+umonc+'Scorpions'
        +config.textcol1+'!',
     ' '+uplc+player.name2+config.textcol1+' was badly bitten...it proved '+ulred+'fatal'+config.textcol1+'.',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     {send to all nodes}
     online_send_to_all(uplc+player.name2+config.textcol1+' has been bitten by '+umonc+'scorpions'
                        +config.textcol1+'!',player.name2,'');

     {mail sender}
     post(MailSend,
     ply0^.name2,
     ply0^.ai,
     false,
     mailrequest_nothing,
     '',
     ulcyan+'Scorpions at Work'+config.textcol1,
     mkstring(17,underscore),
     uplc+player.name2+config.textcol1+' put '+sex3[player.sex]+' hand in the box filled with '+umonc+'scorpions'
         +config.textcol1+'!',
     uplc+player.name2+config.textcol1+' '+ulred+'died'+config.textcol1+' immediately from the poison.',
     'Your gift was a success!',
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

     {mail bitten player}
     post(MailSend,
     player.name2,
     player.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+'Your Death'+config.textcol1,
     mkstring(10,underscore),
     'Fool! You put your hand in a box filled with '+umonc+'Scorpions'+config.textcol1+'!',
     'Remember that it''s pay-back time to '+uplc+ply0^.name2+config.textcol1+', who sent you the package!',
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

     {death text}
     crlf;
     show_usurper_data(picture_death_head,false);
     d(12,'You have been bitten several times...it''s too late...!');
     d(7,'Darkness...');
     pause;

     {exit program}
     {normal_exit;}

    end;
   end; {case .end.}

   if letter^.special=MailRequest_Chocolate then begin

    {improve relation with sender?}
    crlf;
    if confirm('Do you like '+uplc+letter^.sender+config.textcol1+' better now','Y')=true then begin
     {improve pl0:s attitude to player}
     d(15,'Nice feeling!');
     Update_Relation(Relation_Better,1,player,ply0^,false,false);
    end
    else begin
     d(global_plycol,ply0^.name2+config.textcol1+' is still a blockhead.');
    end;

    {inc players exp}
    IncPlayerExp(player,x);
    {IncPlayerExp(ply0,x);}

    {inform jealous husband/wife}
    Jealousy(2,player,ply0^);

    {news-paper}
    newsy(true,
    'Sweet Gift',
    ' '+uplc+ply0^.name2+config.textcol1+' gobbled a '+uwhite+'Box of Chocolates'+config.textcol1+' coming',
    ' from '+uplc+ply0^.name2+config.textcol1+'.',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

    if is_online(letter^.sender,online_player)=true then begin
     online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' accepted the '+uwhite+'Chocolate'
     +config.textcol1+'!');
    end
    else begin

     {mail evil player who sent the horrible gift}
     post(MailSend,
     ply0^.name2,
     ply0^.ai,
     false,
     mailrequest_nothing,
     '',
     uwhite+'Gift Accepted'+config.textcol1,
     mkstring(13,underscore),
     uplc+player.name2+config.textcol1+' accepted your '+uwhite+'Box of Chocolates'+config.textcol1+'!',
     uplc+player.name2+config.textcol1+' gobbled the whole box.',
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

     {update ply0}
     {User_Save(ply0);}

    end;
   end;
  end
  else begin
   {I wont open this surprise box!}
   {mail sender}
   if is_online(letter^.sender,online_player)=true then begin
    online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' refused to open your gift!');
   end
   else begin
    post(MailSend,
    letter^.sender,
    'H',
    false,
    mailrequest_nothing,
    '',
    ulred+'Gift returned'+config.textcol1,
    mkstring(13,underscore),
    uplc+player.name2+config.textcol1+' never opened the '+uwhite+'Box of Chocolates'+config.textcol1+' you sent '
        +sex[ply0^.sex]+'.',
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

end; {surprise_box **END**}

procedure have_sex; {mailrequest_havesex}
begin
 {SENDER wants to have sex with PLAYER *relation event*}

 {let us first check whether the SENDER still is valid}
 ai:='A';
 x:=look_for_person('',letter^.sender,ai);

 if x>0 then begin

  {load sender}
  case ai of
   'H': load_character(ply0^,1,x);
   'C': load_character(ply0^,2,x);
  end; {case .end.}

  {Relation Header}
  crlf;
  love_header(' Invitation ');

  case letter^.special of
   MailRequest_HaveSex:begin
    {have sex with me please!}
    d(global_plycol,letter^.sender+config.textcol1+' would like to '+uyellow+'Sleep'+config.textcol1+' with you.');
   end;
   MailRequest_HaveDiscreteSex:begin
    {have sex with me please!}
    d(global_plycol,letter^.sender+config.textcol1+' would like to '+uyellow+'Sleep'+config.textcol1+' with you.');
   end;
  end; {case .end.}

  {display current relation}
  view_one_relation(player.name2,letter^.sender,true);

  crlf;
  if confirm('Agree to have Sex','Y')=true then begin

   case letter^.special of
    mailrequest_HaveSex:begin
     {earn experience}
     x:=sex_experience(player,ply0^);
    end;
    mailrequest_HaveDiscreteSex:begin
     {earn experience}
     x:=sex_experience(player,ply0^);
    end;

   end; {case .end.}

   case letter^.special of
    MailRequest_HaveSex:begin
     {news-paper}
     newsy(true,
     'In Bed',
     ' '+uplc+player.name2+config.textcol1+' and '+uplc+ply0^.name2+config.textcol1+' spent the night together.',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
    MailRequest_HaveDiscreteSex:begin
     {news-paper}
     newsy(true,
     'In Bed (secret)',
     ' '+uplc+player.name2+config.textcol1+' and '+uplc+ply0^.name2+config.textcol1+' spent the night together.',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
   end; {case .end.}

   case letter^.special of
    MailRequest_HaveSex:begin
     {have (in marriage) sex}
     sex_act_routine(player,ply0^,true);
     d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');
    end;
    MailRequest_HaveDiscreteSex:begin
     {have (out of marriage) sex}
     sex_act_routine(player,ply0^,true);
     d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');
    end;
   end; {case .end.}

   if letter^.special=MailRequest_HaveDiscreteSex then begin
    {improve relation with sender?}
    crlf;
    if confirm('Do you like '+uplc+letter^.sender+config.textcol1+' better now','Y')=true then begin
     {improve pl0:s attitude to player}
     d(15,'Nice feeling!');
     Update_Relation(Relation_Better,1,player,ply0^,false,false);
    end
    else begin
     d(global_plycol,ply0^.name2+config.textcol1+' is still a loser.');
    end;
   end;

   {inc players exp}
   IncPlayerExp(player,x);
   IncPlayerExp(ply0^,x);

   if letter^.special=MailRequest_HaveDiscreteSex then begin
    {inform jealous husband/wife}
    Jealousy(2,player,ply0^);
   end;

   if is_online(letter^.sender,online_player)=true then begin

    case letter^.special of
     mailrequest_HaveSex:begin
      online_send_to_player(letter^.sender,online_player,Broadcast_HaveSex+long2str(x));
     end;
     mailrequest_HaveDiscreteSex:begin
      online_send_to_player(letter^.sender,online_player,Broadcast_HaveDiscreteSex+long2str(x));
     end;
    end; {case .end.}

   end
   else begin

    case letter^.special of
     mailrequest_HaveSex:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      uyellow+'Spending the Night'+config.textcol1,
      mkstring(18,underscore),
      uplc+player.name2+config.textcol1+' accepted your invitation.',
      'You had a wonderful time in bed with '+uplc+player.name2+config.textcol1+'.',
      'You received '+uwhite+commastr(x)+config.textcol1+' experience points.',
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
     Mailrequest_HaveDiscreteSex:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      uyellow+'Spending the Night'+config.textcol1,
      mkstring(18,underscore),
      uplc+player.name2+config.textcol1+' accepted your invitation.',
      'You had a wonderful time in bed with '+uplc+player.name2+config.textcol1+'.',
      'You received '+uwhite+commastr(x)+config.textcol1+' experience points.',
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

    end; {case .end.}

    {update ply0}
    User_Save(ply0^);

   end;
  end
  else begin
   {I wont sleep with you buster!}
   {mail poor letter^.sender}
   if is_online(letter^.sender,online_player)=true then begin
    online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' refuses to sleep with you!');
   end
   else begin
    post(MailSend,
    letter^.sender,
    'H',
    false,
    mailrequest_nothing,
    '',
    ulred+'Crushed Dreams'+config.textcol1,
    mkstring(14,underscore),
    uplc+player.name2+config.textcol1+' declined to sleep with you!',
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

end; {have_sex **END**}

procedure dating; {mailrequest_holdhands/dinner/kiss}
var agree_text : s30;
begin
 {SENDER wants to date (hold hands/dinner/kiss) with PLAYER *relation event*}

 {let us first check whether the SENDER still is valid}
 ai:='A';
 x:=look_for_person('',letter^.sender,ai);

 if x>0 then begin

  {load sender}
  case ai of
   'H': load_character(ply0^,1,x);
   'C': load_character(ply0^,2,x);
  end; {case .end.}

  {Relation Header}
  crlf;
  love_header(' Invitation ');

  case letter^.special of
   MailRequest_HoldHands:begin
    {go out with me please!}
    d(global_plycol,letter^.sender+config.textcol1+' would like to go out with you.');
    agree_text:='Agree to date';
   end;
   MailRequest_Dinner:begin
    {go out with me please!}
    d(global_plycol,letter^.sender+config.textcol1+' would like to take you out for dinner.');
    agree_text:='Agree to date';
   end;
   MailRequest_Kiss:begin
    {kiss me!}
    d(global_plycol,letter^.sender+config.textcol1+' would like to kiss you!');
    agree_text:='Agree to be kissed';
   end;

  end; {case .end.}

  {display current relation}
  view_one_relation(player.name2,letter^.sender,true);

  crlf;
  if confirm(agree_text,'Y')=true then begin

   case letter^.special of
    mailrequest_holdhands:begin
     {earn experience}
     x:=player.level*185;
     y:=ply0^.level*95;
     x:=x+y;
     x:=x div 2;
     if x<100 then x:=100;
    end;
    mailrequest_dinner:begin
     {earn experience}
     x:=player.level*95;
     y:=ply0^.level*185;
     x:=x+y;
     x:=x div 2;
     if x<100 then x:=100;
    end;
    mailrequest_kiss:begin
     {earn experience}
     x:=player.level*55;
     y:=ply0^.level*138;
     x:=x+y;
     x:=x div 2;
     if x<100 then x:=100;
    end;
   end; {case .end.}

   case letter^.special of
    MailRequest_HoldHands:begin
     {walk together, hand in hand}
     d(config.textcolor,'You go out with '+uplc+letter^.sender+config.textcol1+' and have a great time!');
     d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');
    end;
    MailRequest_Dinner:begin
     {have dinner together}
     d(config.textcolor,'You go out and have dinner with '+uplc+letter^.sender+config.textcol1+'!');
     d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');
    end;
    MailRequest_Kiss:begin
     {kissing}
     d(config.textcolor,uplc+letter^.sender+config.textcol1+' kissed you on the lips!');
     d(config.textcolor,'Great feeling!');
     d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');
    end;

   end; {case .end.}

   {improve relation with sender?}
   crlf;
   if confirm('Do you like '+uplc+letter^.sender+config.textcol1+' better now','Y')=true then begin
    {improve pl0:s attitude to player}
    d(15,'Nice feeling!');
    Update_Relation(Relation_Better,1,player,ply0^,false,false);
   end
   else begin
    d(global_plycol,ply0^.name2+config.textcol1+' is still a blockhead.');
   end;

   {inc players exp}
   IncPlayerExp(player,x);
   IncPlayerExp(ply0^,x);

   {inform jealous husband/wife}
   Jealousy(2,player,ply0^);

   case letter^.special of
    MailRequest_HoldHands:begin
     {news-paper}
     newsy(true,
     'Dating',
     ' '+uplc+player.name2+config.textcol1+' and '+uplc+ply0^.name2+config.textcol1+' were seen together today.',
     ' They two of them were necking on a park bench.',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
    MailRequest_Dinner:begin
     {news-paper}
     newsy(true,
     'Date',
     ' '+uplc+player.name2+config.textcol1+' and '+uplc+ply0^.name2+config.textcol1+' had dinner.',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
    MailRequest_Kiss:begin
     {news-paper}
     newsy(true,
     'Romance',
     ' '+uplc+ply0^.name2+config.textcol1+' kissed '+uplc+player.name2+config.textcol1+'.',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
   end; {case .end.}

   if is_online(letter^.sender,online_player)=true then begin
    case letter^.special of
     mailrequest_holdhands:begin
      online_send_to_player(letter^.sender,online_player,Broadcast_HoldingHands+long2str(x));
     end;
     mailrequest_dinner:begin
      online_send_to_player(letter^.sender,online_player,Broadcast_Dinner+long2str(x));
     end;
     mailrequest_kiss:begin
      online_send_to_player(letter^.sender,online_player,Broadcast_Kiss+long2str(x));
     end;
    end; {case .end.}
   end
   else begin

    case letter^.special of
     mailrequest_holdhands:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulblue+'Holding Hands'+config.textcol1,
      mkstring(13,underscore),
      uplc+player.name2+config.textcol1+' accepted your invitation to go out.',
      'You had a wonderful time together.',
      'You received '+uwhite+commastr(x)+config.textcol1+' experience points.',
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
     mailrequest_dinner:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulblue+'Dinner'+config.textcol1,
      mkstring(13,underscore),
      uplc+player.name2+config.textcol1+' accepted your invitation to have dinner.',
      'You spent the evening together.',
      'You earned '+uwhite+commastr(x)+config.textcol1+' experience points.',
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
     mailrequest_kiss:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulblue+'Kissing'+config.textcol1,
      mkstring(7,underscore),
      uplc+player.name2+config.textcol1+' kissed you!',
      'You spent the evening together.',
      'You earned '+uwhite+commastr(x)+config.textcol1+' experience points.',
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

    end; {case .end.}

    {update ply0}
    User_Save(ply0^);

   end;
  end
  else begin
   {I wont walk with you buster!}
   {mail poor letter^.sender}
   if is_online(letter^.sender,online_player)=true then begin
    case letter^.special of
     mailrequest_holdhands:begin
      online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' refused to go out with you!');
     end;
     mailrequest_dinner:begin
     online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' refused to have dinner with you!');
     end;
     mailrequest_kiss:begin
      online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' refused to be kissed by you!');
     end;
    end; {case .end.}

   end
   else begin
    case letter^.special of
     mailrequest_holdhands:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Crushed Dreams'+config.textcol1,
      mkstring(14,underscore),
      uplc+player.name2+config.textcol1+' declined to go out with you!',
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
     mailrequest_dinner:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Crushed Dreams'+config.textcol1,
      mkstring(14,underscore),
      uplc+player.name2+config.textcol1+' declined to have dinner with you!',
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
     mailrequest_kiss:begin
      post(MailSend,
      letter^.sender,
      'H',
      false,
      mailrequest_nothing,
      '',
      ulred+'Crushed Dreams'+config.textcol1,
      mkstring(14,underscore),
      uplc+player.name2+config.textcol1+' refused to be kissed by you!',
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
    end; {case .end.}

   end;
  end;

 end;

end; {dating **END**}

var sender_type : OnlineTypes; {see init.pas, determines type of online player}
    dummy : byte; {counter for spinning cursor routine}

begin {MAIN PROC (POST) **START**}

 killed:=false;
 {init pointer vars}
 new(King);
 new(Quest);
 new(Amount);
 new(Ply0);
 new(Letter);
 new(A_Mail);

 for i:=1 to 10 do begin
  new(qtext[i]);
 end;

 for i:=1 to global_maxmaillines do begin
  new(worm[i]);
 end;

 {turn multinode checking off}
 global_multi:=false;

 worm[1]^:=line1;
 worm[2]^:=line2;
 worm[3]^:=line3;
 worm[4]^:=line4;
 worm[5]^:=line5;
 worm[6]^:=line6;
 worm[7]^:=line7;
 worm[8]^:=line8;
 worm[9]^:=line9;
 worm[10]^:=line10;
 worm[11]^:=line11;
 worm[12]^:=line12;
 worm[13]^:=line13;
 worm[14]^:=line14;
 worm[15]^:=line15;

 for i:=1 to global_maxmaillines do begin
  if worm[i]^='' then worm[i]^:=emptystr;
 end; {for i:= .end.}

 count:=0;

 {Read or Write Mail?}
 case action of
  MailSend:begin {SEND News to player .start.}

            if plai='H' then begin {mail is sent only if receiver is a human}
             letter^.receiver :=receiver;
             letter^.date     :=todays_date;
             letter^.readflag :=false;
             letter^.sender   :=sender;
             letter^.special  :=special;
             letter^.recgod   :=destgod;
             if global_godactive then letter^.sendgod:=true
                                 else letter^.sendgod:=false;

             for j:=1 to global_maxmaillines do begin
              letter^.mess[j]:=worm[j]^;
              if letter^.mess[j]='' then letter^.mess[j]:=emptystr;
             end; {for j:= .end.}

             {save mail}
             Save_Mail(letter^);

            end;
           end; {SEND News to player .end.}

  MailRead:begin {READ News to player .start.}

            {is reader a mortal or a god}
            if global_godactive then ReaderIsGod:=true
                                else ReaderIsGod:=false;

            {we scan the whole mail database, tedious!}
            dummy:=0;
            for i:=1 to fs(FsMail) do begin

             {load mail}
             load_mail(Fload,letter^,i);

             if config.spincursor=true then begin
              inc(dummy);
              if dummy>20 then begin
               dummy:=0;
               spin_cursor(2,12); {spinit}
              end;
             end;

             
                if (letter^.receiver=receiver) and
                (letter^.readflag=false) and
                (letter^.recgod=ReaderIsGod) then begin

              crlf;
              letter^.readflag:=true;

              if (letter^.sender<>'') and (letter^.special=mailrequest_nothing) then begin
               {** Letter from somebody **}
               for j:=1 to global_maxmaillines do begin
                if letter^.mess[j]<>'' then begin
                 if j=1 then s:=' ['+udgray+fix_date(letter^.date)+config.textcol1+']'
                        else s:='';

                 if (letter^.mess[j][1]='-') and (letter^.mess[j][2]='>') then begin
                  col:=7;
                 end
                 else begin
                  col:=2;
                 end;

                 if j>2 then begin
                  d(col,letter^.mess[j]+s);
                 end
                 else begin
                  d(config.textcolor,letter^.mess[j]+s);
                 end;

                 inc(count);
                 if count>15 then begin
                  pause;
                  count:=0;
                 end;
                end;
               end; {for j:= .end.}

               {letter menu}
               crlf;
               menu2('(R)eply  ');
               menu2('(D)elete  ');

               sd(config.textcolor,'(');
               menu2('[I])gnore :');

               repeat
                cho:=upcase(getchar);
                if cho=ReturnKey then cho:='I';
               until cho in ['R','D','I'];

               {evaluate user-input}
               case cho of
                'R':begin {reply}
                     quote:=false;
                     d(10,'Reply!');
                     sd(10,'Quote');
                     if confirm('','Y')=true then begin
                      quote:=true;
                     end;
                    end;
                'D':begin {delete}
                     d(10,'Delete');
                    end;
                'I':begin {ignore}
                     d(10,'Ignore');
                    end;
               end; {case .end.}

               crlf;

               case cho of
                'I':begin {ingore}
                     letter^.readflag:=false;
                    end;
                'R':begin {reply}
                     crlf;

                     for j:=3 to 12 do begin
                      qtext[j-2]^:=emptystr;
                      worm[j]^:=emptystr;
                      if (quote) and (letter^.mess[j]<>'') then begin
                       qtext[j-2]^:=letter^.mess[j];
                      end;
                     end; {for j:= .end.}

                     a_mail^.mess[1]:=emptystr;

                     create_letter(a_mail^,
                                   letter^.sender,
                                   player.name2,
                                   qtext[1]^,
                                   qtext[2]^,
                                   qtext[3]^,
                                   qtext[4]^,
                                   qtext[5]^,
                                   qtext[6]^,
                                   qtext[7]^,
                                   qtext[8]^,
                                   qtext[9]^,
                                   qtext[10]^);

                     if a_mail^.mess[1]<>'' then begin
                      a_mail^.receiver :=letter^.sender;
                      a_mail^.date     :=todays_date;
                      a_mail^.readflag :=false;
                      a_mail^.sender   :=letter^.receiver;
                      a_mail^.special  :=mailrequest_nothing;

                      a_mail^.recgod   :=letter^.sendgod;
                      if global_godactive then a_mail^.sendgod:=true
                                          else a_mail^.sendgod:=false;

                      Save_Mail(a_mail^);

                      {online mess to reciever, only if he is online (of course)}
                      if letter^.sendgod then sender_type:=online_god
                                         else sender_type:=online_player;

                      if is_online(letter^.sender,sender_type) then begin
                       online_send_to_player(letter^.sender,sender_type,uplc+receiver+config.textcol1
                               +' posted a letter to you.');
                       break;
                      end;

                      d(15,'OK.');
                     end;

                     count:=0;
                     for j:=1 to global_maxmaillines do begin
                      if letter^.mess[j]<>'' then begin

                       if copy(letter^.mess[j],1,2)='->' then begin
                        d(7,letter^.mess[j]);
                       end
                       else begin
                        d(config.textcolor,letter^.mess[j]);
                       end;

                       inc(count);
                       if count>15 then begin
                        pause;
                        count:=0;
                       end;
                      end;
                     end; {for j:= .end.}

                     crlf;
                     if confirm('Delete Letter ','Y')=false then begin
                      letter^.readflag:=false;
                     end
                     else begin
                      case random(2) of
                       0: d(config.textcolor,'You toss the letter out the window...');
                       1: d(config.textcolor,'You shred the letter.');
                      end;
                     end;
                    end; {read .end.}
               end; {case .end.}

              end {NORMAL LETTER FROM SOMEBODY **END**}

              {special LETTERS, mail/requests}
                      else if (letter^.special=MailRequest_IWantGuard) and
                      (player.king=true) then begin
               {PLAYER OFFERS KING TO BE HIS/HER PERSONAL GUARD}

               {daily salary demanded}
               x:=str_to_nr(letter^.mess[1]); {salary demanded}
               y:=str_to_nr(letter^.mess[2]); {player sex}

               if (y<1) or (y>2) then begin
                d(12,'Error in SEX value (programmer should be informed).');
               end;

               d(14,'Job Application');
               d(5,mkstring(15,underscore));

               sd(global_plycol,letter^.sender);
               d(config.textcolor,' would like to be in the Royal Guard force.');
               sd(global_plycol,letter^.sender);
               sd(config.textcolor,' would like to see a daily salary of ');
               sd(14,commastr(x));
               d(config.textcolor,' '+many_money(x)+'.');
               crlf;

               {these lines are also in ONLINERs.PAS}
               if confirm('Accept this','N')=true then begin
                {are there any free spots?}
                load_king(fload,king^);

                k:=0;
                for j:=1 to global_kingguards do begin
                 if king^.guard[j]='' then begin
                  k:=j;
                  break;
                 end;
                end; {for j:= .end.}

                if k=0 then begin
                 {no free spot}

                 {post refused player}
                 post(MailSend,
                 letter^.sender,
                 'H',
                 false,
                 mailrequest_nothing,
                 '',
                 ulred+'No Job'+config.textcol1,
                 mkstring(6,underscore),
                 uplc+player.name2+config.textcol1+' would like to see you in '+sex3[player.sex]+' Guard Force.',
                 'Unfortunately, there are no vacancies at the moment.',
                 'Try again later. /The Royal Office/',
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

                 if is_online(letter^.sender,online_player) then begin
                  online_send_to_player(letter^.sender,online_player,broadcast_NoRoomForYou);
                 end;

                 {text}
                 d(12,'Your guard force is full. Sack somebody before you and hire');
                 d(12,'new people!');
                 pause;

                end
                else begin
                 {free spot, hire!}
                 sd(global_plycol,letter^.sender);
                 d(config.textcolor,' has joined the Guard!');

                 {update king record}
                 king^.guard[k]   :=letter^.sender; {guard}
                 king^.guardpay[k]:=x;   {salary}
                 king^.guardai[k] :='H'; {control/AI}
                 king^.guardsex[k]:=y;  {sex}

                 load_king(fsave,king^);

                 {post the employee}
                 if player.sex=1 then s:='KING'
                                 else s:='QUEEN';
                 post(MailSend,
                 letter^.sender,
                 'H',
                 false,
                 mailrequest_nothing,
                 '',
                 uyellow+'Job'+config.textcol1,
                 mkstring(3,underscore),
                 s+' '+uplc+player.name2+config.textcol1+' accepted Your application.',
                 'You are now a member of the '+ulcyan+'Royal Guard'+config.textcol1+'.',
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


                 {news-paper and other pipes for information}

                 if is_online(letter^.sender,online_player) then begin
                  online_send_to_player(letter^.sender,online_player,broadcast_YouBecameGuard);
                 end;

                 {send to all nodes}
                 online_send_to_all(uplc+letter^.sender+config.textcol1+' became a Royal Guard!',player.name2,letter^.sender);

                 case random(2) of
                  0:begin
                     Newsy(true,
                     'Royal Employment',
                     ' '+uplc+letter^.sender+config.textcol1+' became a member of the '
                        +ulcyan+'Royal Guard'+config.textcol1+'!',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');
                    end;
                  1:begin
                     Newsy(true,
                     'Royal Employment',
                     ' '+uplc+letter^.sender+config.textcol1+' joined the '+ulcyan+'Royal Guard'+config.textcol1+'!',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');
                    end;
                 end; {case .end.}

                end;

               end
               else begin
                {the king wont have this new guard}

                if player.sex=1 then s:='KING'
                                else s:='QUEEN';

                {post a letter to the player}
                post(MailSend,
                letter^.sender,
                'H',
                false,
                mailrequest_nothing,
                '',
                ulred+'No Job'+config.textcol1,
                mkstring(6,underscore),
                uplc+player.name2+config.textcol1+' declined your offer to be Guard.',
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

              end
              
                      else if (letter^.special=MailRequest_RoyalAngel) then begin
               {KING HAS SENT A ANGEL TO HEAL PLAYER}

               {is the good doing king still king?}

               {load king record}
               load_king(fload,king^);

               {the king is still king :)}
               if letter^.sender=king^.name then begin
                healing_royal_angel; {this proc is also called from online.pas}

                {tell all nodes of this remarkable event}
                online_send_to_all(uwhite+'an '+uwhite+'Angel'+config.textcol1+' visited '+uplc+player.name2+config.textcol1
                                   +'!',player.name2,'');

                {we must send a reciept to the sender (the king or queen)}
                if is_online(letter^.sender,online_player) then begin
                 online_send_to_player(letter^.sender,online_player,broadcast_RoyalAngelLand);
                end
                else begin
                 {maail king of successful Angel mission}

                 s:='Angel Mission';
                 post(MailSend,
                 king^.name,
                 king^.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 uwhite+s+config.textcol1,
                 mkstring(length(s),underscore),
                 uplc+player.name2+config.textcol1+' was healed by the '+uwhite+'Angel'+config.textcol1+' sent out by you!',
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

                pause;
               end;

              end {royal angel *end*}
                      else if (letter^.special=MailRequest_RoyalAvenger) then begin
               {KING HAS SENT A DARK AVENGER TO HURT PLAYER}

               {is the evil doing king still king?}

               {load king record}
               load_king(fload,king^);

               {the king is still king :)}
               if letter^.sender=king^.name then begin

                {this proc is also called from online.pas}
                hurting_royal_avenger;
                
                {tell all nodes of this remarkable event}
                online_send_to_all(uwhite+'a '+ulred+'Dark Avenger'+config.textcol1+' hurt '+uplc+player.name2+config.textcol1
                                   +'!',player.name2,'');

                {we must send a reciept to the sender (the king or queen)}
                if is_online(letter^.sender,online_player) then begin
                 online_send_to_player(letter^.sender,online_player,broadcast_RoyalAvengerLand);
                end
                else begin
                 {mail king of successful Dark Avenger mission}

                 s:='Dark Avenger Mission';
                 post(MailSend,
                 king^.name,
                 king^.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 uwhite+s+config.textcol1,
                 mkstring(length(s),underscore),
                 uplc+player.name2+config.textcol1+' was hurt by the '+ulred+'Dark Avenger'+config.textcol1
                     +' sent out by you!',
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

                pause;
               end;

              end {royal Dark Avenger *end*}
                      else if (letter^.special=MailRequest_QuestOffer) then begin
               {KING HAS OFFERED A QUEST TO PLAYER}

               {is the king still king?}

               {load king record}
               load_king(fload,king^);

               {the king is still king :)}
               if letter^.sender=king^.name then begin

                {we must check if quest^.id still exists in the quest database}
                x:=0;
                for k:=1 to fs(fsquest) do begin
                 load_quest(fload,quest^,k);

                 if (quest^.id=letter^.mess[1]) and
                    (quest^.deleted=false) then begin

                  if quest^.forced then forced_quest:=true
                                  else forced_quest:=false;
                  x:=k;
                  break;
                 end;

                end; {for k:= .end.}

                {valid quest}
                if x>0 then begin

                 {present the Quest Offer to player}
                 d(config.textcolor,uquestc+'QUEST '+uyellow+'Proposal'+config.textcol1);
                 d(5,mkstring(14,underscore));
                 sd(config.textcolor,kingstring(king^.sexy)+' ');
                 sd(global_kingcol,king^.name);

                 accept_quest:=true;
                 if forced_quest then begin
                  d(config.textcolor,' has forced you to accept a Quest to be completed in '+uwhite
                    +commastr(quest^.daystocomple)
                      +config.textcol1+' days!');
                  pause;
                 end
                 else begin
                  d(config.textcolor,' offers YOU a Quest to be completed in '+uwhite+commastr(quest^.daystocomple)
                    +config.textcol1+' days.');
                  if confirm('Accept Quest','Y')=false then begin
                   accept_quest:=false;
                  end;
                 end;


                 if accept_quest then begin

                  if claimed_quests(player.name2)>=Config.MaxClaimedQuests then begin
                   crlf;
                   d(12,'Sorry, You may only be active on '+uwhite+commastr(Config.MaxClaimedQuests)+ulred
                        +' Quests at the same time.');

                   {player was unable to accept the quest}
                   quest^.offerto:=emptystr;
                   load_quest(fsave,quest^,x);

                   load_king(fload,king^);

                   if (king^.name<>'') and (king^.ai='H') then begin
                    if is_online(king^.name,online_player) then begin
                     online_send_to_player(king^.name,online_player,uplc+player.name2+config.textcol1
                          +' was unable to accept a '+uquestc+'Quest'+config.textcol1+'!');
                    end
                    else begin

                     {mail}
                     s:='Quest offer Declined';

                     post(MailSend,
                     king^.name,
                     king^.ai,
                     false,
                     mailrequest_nothing,
                     '',
                     uquestc+'QUEST'+umailheadc+' offer '+ulred+'Declined'+config.textcol1,
                     mkstring(length(s),underscore),
                     uplc+player.name2+config.textcol1+' was unable to accept your offer to complete a '+uquestc+'QUEST'
                         +config.textcol1+'!',
                     uplc+player.name2+config.textcol1+' is involved in too many missions right now.',
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
                   pause;
                  end
                  else begin

                   if grab_quest(player,x)=true then begin

                    if forced_quest then begin
                     {news-paper}
                     Newsy(true,
                     'Force Quest',
                     ' '+uplc+player.name2+config.textcol1+' was forced to accept a '+uquestc+'Quest'+config.textcol1+'!',
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
                     {news-paper}
                     Newsy(true,
                     'Quest Proposal',
                     ' '+uplc+player.name2+config.textcol1+' accepted a '+uquestc+'Quest'+config.textcol1+'.',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');
                    end;

                    {tell other nodes}
                    online_send_to_all(uplc+player.name2+config.textcol1+' accepted a '+uquestc+'Quest'+config.textcol1
                                       +'!',player.name2,'');

                    load_king(fload,king^);

                    if (king^.name<>'') and (king^.ai='H') then begin
                     if is_online(king^.name,online_player)=false then begin

                      {mail}
                      s:='QUEST Accepted';

                      post(MailSend,
                      king^.name,
                      king^.ai,
                      false,
                      mailrequest_nothing,
                      '',
                      uquestc+'QUEST'+umailheadc+' Accepted'+config.textcol1,
                      mkstring(length(s),underscore),
                      uplc+player.name2+config.textcol1+' accepted a '+uquestc+'QUEST'+config.textcol1+' proposed by You!',
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
                   end
                   else begin
                    {failed to claim quest, somebody has tampered with the
                     quest-file just before we were able to claim it.}
                    crlf;
                    d(12,'Unable to claim quest!');
                    pause;
                   end;
                  end;

                 end
                 else begin

                  {player didn't accept the quest}
                  quest^.offerto:=emptystr;
                  load_quest(fsave,quest^,x);

                  {news-paper}
                  Newsy(true,
                  'Cowardice',
                  ' '+uplc+player.name2+config.textcol1+' declined an invitation to join a '+uquestc+'QUEST'
                     +config.textcol1+'!',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  {tell other nodes}
                  online_send_to_all(uplc+player.name2+config.textcol1+' declined an '+uquestc+'QUEST'+config.textcol1
                                     +' offer!',player.name2,'');

                  load_king(fload,king^);

                  if (king^.name<>'') and (king^.ai='H') then begin
                   if is_online(king^.name,online_player)=false then begin

                    {mail}
                    s:='Quest offer Declined';

                    post(MailSend,
                    king^.name,
                    king^.ai,
                    false,
                    mailrequest_nothing,
                    '',
                    uquestc+'QUEST'+umailheadc+' offer '+ulred+'Declined'+config.textcol1,
                    mkstring(length(s),underscore),
                    uplc+player.name2+config.textcol1+' declined your offer to complete a '+uquestc+'QUEST'
                        +config.textcol1+'!',
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

                end;

               end;

              end {quest offer *end*}
                      else if (letter^.special=MailRequest_Poison) then begin
               {SENDER has sent "poison" to PLAYER *relation event*}

               {let us first check whether the SENDER still is valid}
               ai:='A';
               x:=look_for_person('',letter^.sender,ai);

               {did sender want to be anonymous?}
               if letter^.mess[1]='A' then begin
                anonym:='*Anonymous*';
               end
               else begin
                anonym:=letter^.sender;
               end;

               if x>0 then begin

                {load sender}
                case ai of
                 'H': load_character(ply0^,1,x);
                 'C': load_character(ply0^,2,x);
                end; {case .end.}


                {Disguise poison as a free drink}
                d(5,'Cocktail Party');
                d(5,mkstring(14,underscore));
                d(global_plycol,anonym+config.textcol1+' has sent you a free drink!');
                d(config.textcolor,'The cocktail is the famous '+udrinkc+random_drink+config.textcol1+'.');

                if confirm('Drink it','Y')=true then begin

                 {chance to detect the poison}
                 x:=random(2);

                 {accept drink}
                 d(config.textcolor,'You accept the drink!');

                 if x=0 then begin

                  {detected the poison!}
                  crlf;
                  d(15,'Wait a minute! You can smell the Arsenic right away..!');
                  d(15,'This is a lethal Drink!');
                  d(15,'They are trying to get rid of you!');

                  crlf;
                  d(config.textcolor,'You throw the drink down the sink...');

                  {news-paper}
                  newsy(true,
                  'Poisoning attempt',
                  ' Somebody tried to poison '+uplc+player.name2+config.textcol1+'!',
                  ' But it failed.',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  if is_online(letter^.sender,online_player)=true then begin
                   online_send_to_player(letter^.sender,online_player,'Your attempt to poison '+uplc+player.name2
                                         +config.textcol1+' failed!');
                  end
                  else begin

                   post(MailSend,
                   letter^.sender,
                   'H',
                   false,
                   mailrequest_nothing,
                   '',
                   ulred+'Poison failure'+config.textcol1,
                   mkstring(14,underscore),
                   uplc+player.name2+config.textcol1+' detected the poison the Drink you sent '+sex[player.sex]+'!',
                   ulred+'FAILURE!'+config.textcol1,
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

                  crlf;
                  pause;
                 end
                 else begin

                  {drinking poison!}
                  crlf;
                  sd(config.textcolor,'Glugg...');
                  Sleep(800);
                  sd(config.textcolor,'Glugg...');
                  Sleep(800);
                  sd(config.textcolor,'Glugg...');
                  Sleep(800);
                  d(12,'Glugg...!');
                  crlf;

                  d(12,'It was an odd flavor to this drink...');
                  show_usurper_data(picture_DEATH_HEAD,false);
                  d(12,'ARSENIC!!!!!');
                  d(12,'Arghhhh!............');
                  crlf;
                  d(config.textcolor,'Darkness...');

                  {set player flags}
                  player.hps:=0;
                  Reduce_Player_Resurrections(player,true);
                  killed:=true;
                  {player.allowed:=false;}

                  {how much xp should poisoner (ply0) receive}
                  x:=player.level*55;

                  {news-paper}
                  newsy(true,
                  'Poisoned!',
                  ' '+uplc+player.name2+config.textcol1+' was poisoned by a Drink.',
                  ' The cocktail was laced with '+ulred+'arsenic'+config.textcol1+'.',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  if is_online(letter^.sender,online_player)=true then begin
                   online_send_to_player(letter^.sender,online_player,Broadcast_Poison+long2str(x));
                  end
                  else begin

                   post(MailSend,
                   letter^.sender,
                   'H',
                   false,
                   mailrequest_nothing,
                   '',
                   ulblue+'Poison'+config.textcol1,
                   mkstring(6,underscore),
                   uplc+player.name2+config.textcol1+' accepted the fake Drink you sent '+sex[player.sex]+'!',
                   uplc+player.name2+config.textcol1+' drank the poison and died!',
                   'You received '+uwhite+commastr(x)+config.textcol1+' experience points.',
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

                   {update ply0}
                   IncPlayerExp(ply0^,x);
                   user_save(ply0^);

                  end;

                  {goodbye dead man!}
                  crlf;
                  pause;
                  {normal_exit;}

                 end;
                end
                else begin
                 {I don't want your darn drink!}
                 {mail poor letter^.sender}
                 if is_online(letter^.sender,online_player)=true then begin
                  online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1+' rejected drink!');
                 end
                 else begin
                  post(MailSend,
                  letter^.sender,
                  'H',
                  false,
                  mailrequest_nothing,
                  '',
                  ulred+'Drink Rejected'+config.textcol1,
                  mkstring(14,underscore),
                  uplc+player.name2+config.textcol1+' ignored the Drink you sent '+sex[player.sex]+'!',
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

              end

                      else if (letter^.special=MailRequest_Roses) then begin
               {SENDER has sent "bouquet of roses" to PLAYER *relation event*}

               {let us first check whether the SENDER still is valid}
               ai:='A';
               x:=look_for_person('',letter^.sender,ai);

               if x>0 then begin

                {load sender}
                case ai of
                 'H': load_character(ply0^,1,x);
                 'C': load_character(ply0^,2,x);
                end; {case .end.}

                {Red hearts}
                crlf;
                show_usurper_data(picture_SMALL_HEART,false);
                d(15,'-*-LOVE EVENT*-');
                sd(4,heartsign+heartsign+heartsign);
                sd(4,' Roses ');
                d(4,heartsign+heartsign+heartsign);
                crlf;

                {take these flowers please!}
                d(global_plycol,letter^.sender+config.textcol1+' has sent you Roses!');

                {display current relation}
                view_one_relation(player.name2,letter^.sender,true);

                crlf;
                if confirm('Accept the Flowers','Y')=true then begin

                 if confirm('Do you like '+uplc+letter^.sender+config.textcol1+' better now','Y')=true then begin
                  {improve players attitude to sender}
                  d(15,'Nice feeling!');
                  Update_Relation(Relation_Better,2,player,ply0^,false,false);
                 end
                 else begin
                  d(global_plycol,ply0^.name2+config.textcol1+' is still a blockhead.');
                 end;

                 {inform jealous husband/wife}
                 Jealousy(2,player,ply0^);

                 {earn experience}
                 x:=player.level*85;
                 y:=ply0^.level*85;
                 x:=x+y;
                 x:=x div 2;
                 if x<100 then x:=100;

                 {smell roses}
                 d(config.textcolor,'You accept the flowers from '+uplc+letter^.sender+config.textcol1+'!');
                 d(15,'They smell beautiful!');
                 d(config.textcolor,'You both earn '+uwhite+commastr(x)+config.textcol1+' experience points!');

                 {inc players exp}
                 IncPlayerExp(player,x);
                 IncPlayerExp(ply0^,x);

                 {news-paper}
                 newsy(true,
                 'Flowers',
                 ' '+uplc+player.name2+config.textcol1+' received flowers from a secret admirer.',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '');

                 if is_online(letter^.sender,online_player)=true then begin
                  online_send_to_player(letter^.sender,online_player,Broadcast_BouquetRoses+long2str(x));
                 end
                 else begin

                  post(MailSend,
                  letter^.sender,
                  'H',
                  false,
                  mailrequest_nothing,
                  '',
                  ulblue+'Flowers'+config.textcol1,
                  mkstring(7,underscore),
                  uplc+player.name2+config.textcol1+' accepted the Roses you sent '+sex[player.sex]+'!',
                  'It was a success!',
                  'You received '+uwhite+commastr(x)+config.textcol1+' experience points.',
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

                  {update ply0}
                  User_Save(ply0^);

                 end;
                end
                else begin
                 {I don't want your darn roses!}
                 {mail poor letter^.sender}
                 if is_online(letter^.sender,online_player)=true then begin
                  online_send_to_player(letter^.sender,online_player,uplc+player.name2+config.textcol1
                     +' trashed the flowers!');
                 end
                 else begin
                  post(MailSend,
                  letter^.sender,
                  'H',
                  false,
                  mailrequest_nothing,
                  '',
                  ulred+'Trashed Roses'+config.textcol1,
                  mkstring(13,underscore),
                  uplc+player.name2+config.textcol1+' ignored the Flowers you sent '+sex[player.sex]+'!',
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
                 {news-paper}
                 newsy(true,
                 'Flowers',
                 ' '+uplc+player.name2+config.textcol1+ulred+' rejected'+config.textcol1+' flowers from a secret admirer.',
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

              end

                      else if (letter^.special in [MailRequest_ChildRaisingExp,
                                           MailRequest_ChildPoisonedExp,
                                           MailRequest_ChildCursedExp,
                                           MailRequest_ChildDepressedExp]) then begin
               raising_children(letter^.special);
              end
                      else if (letter^.special=MailRequest_ChildFightExp) then begin
               fighting_children;
              end
                      else if (letter^.special=MailRequest_SilentExp) then begin
               silent_experience;
              end
                      else if (letter^.special=MailRequest_ScanForBabies) then begin
               name_babies(player,false);
              end
                      else if (letter^.special=MailRequest_JoinTeam) then begin
               Join_Team;
              end
                      else if (letter^.special=MailRequest_GymMembership) then begin
               Gym_Membership;
              end
                      else if (letter^.special=MailRequest_Birthday) then begin
               birthday;
              end
                      else if (letter^.special in [MailRequest_HoldHands,
                                           MailRequest_Dinner,
                                           MailRequest_Kiss]) then begin
               dating;
              end
                      else if (letter^.special in [MailRequest_Scorpions,
                                           MailRequest_Chocolate]) then begin
               surprise_box;
              end
                      else if (letter^.special in [MailRequest_HaveSex,
                                           MailRequest_HaveDiscreteSex]) then begin
               Have_Sex;
              end
                      else if (letter^.special=MailRequest_DrinkOffer) then begin

               drink_offer;

              end {drink offer *end*}

                      else if (letter^.special=mailrequest_ImmortalOffer) then begin

               immortal_offer(player);

              end {drink offer *end*}

                      else if (letter^.special=MailRequest_BeMyGuard) then begin
               {KING OFFERS PLAYER TO BE HIS/HER PERSONAL GUARD}

               {is the offering king still king?}

               {load king record}
               load_king(fload,king^);

               {the king is still king :)}
               if letter^.sender=king^.name then begin
                {extract salary offer the king proposed}
                x:=str_to_nr(letter^.mess[1]);

                {is player a Royal guard already?}
                found:=false;
                for k:=1 to global_kingguards do begin
                 if king^.guard[k]=player.name2 then begin
                  found:=true;
                  break;
                 end;
                end; {for k:= .end.}

                if found then begin
                 {player is already a guard}
                 d(14,'Royal Request');
                 d(5,mkstring(13,underscore));
                 sd(config.textcolor,kingstring(king^.sexy)+' ');
                 sd(global_kingcol,king^.name);
                 d(config.textcolor,' has offered YOU to become '+sex3[king^.sexy]+' personal Guard.');
                 crlf;
                 d(12,'You already are a ROYAL GUARD. Consequently you ignore');
                 d(12,'this letter^.');
                 pause;
                end
                else begin
                 {present the offer to player}
                 d(14,'Royal Request');
                 d(5,mkstring(13,underscore));
                 sd(config.textcolor,kingstring(king^.sexy)+' ');
                 sd(global_kingcol,king^.name);
                 d(config.textcolor,' offers YOU to become '+sex3[king^.sexy]+' personal Guard.');

                 sd(config.textcolor,'You will have a daily salary of ');
                 sd(14,commastr(x));
                 d(config.textcolor,' '+many_money(x)+'.');
                 crlf;

                 if confirm('Accept Offer','Y')=true then begin
                  {put the new guard in the King Record}
                  load_king(fload,king^);
                  {check for a free spot}
                  l:=0;
                  for k:=1 to global_kingguards do begin
                   if king^.guard[k]='' then begin
                    l:=k;
                    break;
                   end;
                  end; {for k:= .end.}

                  if l=0 then begin

                   d(12,'Too bad! There is No room for you any more.');
                   d(12,'The '+UpperCase(kingstring(king^.sexy))+' already has all the guards');
                   d(12,'necessary.');
                   pause;

                   {mail the king about this failed attempt to become guard}
                   post(MailSend,
                   king^.name,
                   'H',
                   false,
                   mailrequest_nothing,
                   '',
                   umailheadc+'Failed Job Application'+config.textcol1,
                   mkstring(22,underscore),
                   uplc+player.name2+config.textcol1+' accepted your offer to become Guard.',
                   'Unfortunately there was no room for '+uplc+player.name2+config.textcol1+' in your guard force.',
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

                   if is_online(king^.name,online_player) then begin
                    online_send_to_player(king^.name,online_player,broadcast_NoRoomForGuard);
                   end;


                  end
                  else begin
                   {There IS room for a new guard}
                   d(15,'To Protect and Serve is our motto!');
                   d(15,'May the Royal Family never come to any harm.');

                   king^.guard[l]   :=player.name2; {guard}
                   king^.guardpay[l]:=x; {salary}
                   king^.guardai[l] :=player.ai; {control/AI}
                   king^.guardsex[l]:=player.sex; {sex}

                   {save updated king record}
                   load_king(fsave,king^);

                   if is_online(king^.name,online_player) then begin
                    online_send_to_player(king^.name,online_player,broadcast_IBecameGuard);
                   end;

                   {post mess to king}
                   post(MailSend,
                   king^.name,
                   'H',
                   false,
                   mailrequest_nothing,
                   '',
                   umailheadc+'Accepted Offer'+config.textcol1,
                   mkstring(14,underscore),
                   uplc+player.name2+config.textcol1+' accepted your offer to become a '+ulcyan+'Royal Guard'
                       +config.textcol1+'.',
                   uplc+player.name2+''+config.textcol1+' has a salary of '+uyellow+commastr(x)+config.textcol1
                       +' '+many_money(x)+' / day.',
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

                   {send news to all + news paper}
                   online_send_to_all(player.name2+' became a Royal Guard!',player.name2,king^.name);

                   case random(9) of
                    0: s:='lovely';
                    1: s:='self-minded';
                    2: s:='good-hearted';
                    3: s:='promising';
                    4: s:='insane';
                    5: s:='charming';
                    6: s:='boastful';
                    7: s:='dark-hearted';
                    8: s:='terrible';
                   end;

                   case random(2) of
                    0:begin
                       Newsy(true,
                       'Royal Employment',
                       ' The '+s+' '+urac+race_display(2,player.race,0)+' '+uplc+player.name2+config.textcol1
                         +' became a member of the '
                              +ulcyan+'Royal Guard'+config.textcol1+'!',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '');
                      end;
                    1:begin
                       Newsy(true,
                       'Royal Employment',
                       ' The '+s+' '+urac+race_display(2,player.race,0)+' '+uplc+player.name2+config.textcol1+' joined the '
                              +ulcyan+'Royal Guard'+config.textcol1+'!',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '');
                      end;
                   end; {case .end.}

                  end; {if l<>0 .end.}


                 end
                 else begin

                  post(MailSend,
                  king^.name,
                  'H',
                  false,
                  mailrequest_nothing,
                  '',
                  umailheadc+'Insubordination'+config.textcol1,
                  mkstring(14,underscore),
                  uplc+player.name2+config.textcol1+' declined your offer to become a '+ulcyan+'Royal Guard'
                      +config.textcol1+'.',
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

                  if is_online(king^.name,online_player) then begin
                   online_send_to_player(king^.name,online_player,BroadCast_RefusedGuard);
                  end;

                 end;
                end;

               end; {the kings offer}


              end {be My Guard .end.}

              else begin

               {** Regular News about Events etc .. **}
               for j:=1 to global_maxmaillines do begin
                if letter^.mess[j]<>'' then begin
                 if j=1 then s:=' ['+udgray+fix_date(letter^.date)+config.textcol1+']'
                        else s:='';
                 d(config.textcolor,letter^.mess[j]+s);

                 inc(count);
                 if count>15 then begin
                  pause;
                  count:=0;
                 end;
                end;
               end; {for j:= .end.}

              end;

              {we only update the letter if the readflag has been set}
              if letter^.readflag=true then begin
               Load_Mail(FSave,letter^,i);
              end;

             end;
            end; {for i:= .end.}


               if killed then begin
               disposal;
               normal_exit;
              end;

end; {READ News to player .end.}
end; {case action of .end.}

 {dispose pointer vars}
 disposal;

 {turn on multinode checking}
 global_multi:=true;

end; {POST *end*}

end. {Unit Mail .end.}
