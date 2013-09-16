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

Unit Suicid; {Usurper - Suicide}

Interface

Procedure Suicide;

Implementation

Uses Init, CMS, Jakob, news,
     GenNews, various, various2,
     online, mail, file_io;

Procedure Suicide;
var
    s,
    s1 : s70;

begin

 clearscreen;
 crlf;
 d(12,' *** Suicide, The easy way out ***');
 crlf;

 s1:=' '+uplc+player.name2+config.textcol1+' is dead! '+sex2[player.sex]+' hanged '+sex4[player.sex]+' in the woods!';

 if confirm('ARE YOU SURE that you want to kill yourself','n')=true then begin
  crlf;
  s:=' A suicide note was found;';

  {news-paper}
  newsy(false,
  'Tragic!',
  s1,
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

  s:=emptystr;
  if confirm('Leave a Suicide Note','y')=true then begin
   crlf;
   s:=emptystr;
   d(config.textcolor,'Enter Your Last Message [1 line]');
   sd(config.textcolor,':');
   s:=get_string(70);
   if s<>'' then begin
    s:=' '+utalkc+s+config.textcol1;

    newsy(false,
    ' A suicide note was found;',
    s,
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

  newsy(true,
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
  crlf;
  d(config.textcolor,'You go out in the woods and find a big oak...');
  d(config.textcolor,'You string up the rope around a large branch and then climb the tree.');
  d(config.textcolor,'You recall your memories and comrades you now will abandon...');
  d(config.textcolor,'You let yourself fall....ARGHHHhhhh....!!');
  crlf;
  show_usurper_data(picture_death_head,false);
  d(config.textcolor,'Another brave adventurer has ended his quest for fame and glory...');
  crlf;
  pause;

  crlf;

  if player.king then begin
   if player.sex=1 then s:='King'
                   else s:='Queen';

   {inform royal guards that they have been sacked}
   sack_royal_guards;

   {delete king order file}
   if f_exists(global_kingf) then begin
    delete_file(global_kingf);
   end;

   {news-paper}
   newsy(true,
   'The '+s,
   ' '+s+uyellow+' '+player.name2+config.textcol1+' is gone!',
   ' The land is in disarray! Who can bring order to our Town?',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {kings-news}
   Generic_News(RoyalNews,
   true,
   ' '+config.textcol1+s+' '+ukingc+player.name2+config.textcol1+' committed suicide.',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {delete king order file}
   if f_exists(global_kingf) then begin
    delete_file(global_kingf);
   end;
  end;

  {inform other players online}
  online_send_to_all(uplc+player.name2+config.textcol1+' committed '+ulred+'SUICIDE!',player.name2,'');

  {this is also the lines in "supreme being" routine}
  add_shadow(SRemoveFakess,player,'','going to sleep',0); {remove online players}
  add_shadow(SRemoveShadows,player,'','going to sleep',0); {remove online players}
  add_onliner(ORemoveMe,onliner);

  {Inform God}
  if player.god<>'' then begin

   {we send both online and mail message to player god}
   if is_online(player.god,online_god)=true then begin
    online_send_to_player(player.god,online_god,uplc+player.name2+config.textcol1H+' committed Suicide!');
   end;

   {mail god}
   s:='Suicide!';
   post(MailSend,
   player.god,
   'H',
   true,
   mailrequest_nothing,
   '',
   ulred+s+config.textcol1,
   mkstring(length(s),underscore),
   uplc+player.name2+config.textcol1+' committed suicide!',
   'Your powers are diminishing! Find new disciples soon!',
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

  end; {inform god .end.}

  {deactivate player}
  deactivate_player(player);

  {save user}
  player.king:=false;
  user_save(player);
  player.name2:='';

  {exit program}
  normal_exit;

 end;
 crlf;
 d(config.textcolor,'Phew! You had us all worried with that suicide talk!');

end; {Suicide *end*}

end. {Unit Suicid .end.}
