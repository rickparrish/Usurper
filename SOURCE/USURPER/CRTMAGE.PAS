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
Unit CrtMage; {Usurper - Court Mage, only the Monarch can enter here}

Interface

Procedure Court_Magician; {Court Magicians Chambers}

Implementation

Uses Init, Cms, Jakob,
     Statusc, Various, Mail,
     File_io, Online;

const

 {court mage}
 court_mage = 'Gourgaz';

var
    refresh : boolean;

Procedure Meny;
const offset = 22;
begin
 clearscreen;
 crlf;
 d(5,'-*- Court Magician -*-');
 crlf;
 d(2,'You are in the small tower north of the bridge.');
 sd(2,'Your host and employee is ');
 sd(global_plycol,court_mage);
 d(2,', the enchanter with a dubious record.');
 d(2,'This grumpy old goat is only pleased and will only serve when');
 d(2,'given proper respect and reward for his work.');
 crlf;

 menu2(ljust('(A)ngel of Healing',offset));
 crlf;

 menu('(D)ark Avenger');
 menu('(S)tatus');
 menu('(R)eturn to Great Hall');

end;

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   crlf;
   sd(2,'Court Mage (');
   sd(config.hotkeycolor,'?');
   sd(2,' for menu) :');
  end
  else begin

   crlf;
   sd(2,'Court Mage (A,D,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end;

Procedure Court_Magician;
var ch : char;
    s : s100;
    x : longint;

    pl0 : ^UserRec;
    found, abort : boolean;

    i,j,size : word;

begin


 {init pointer vars}
 new(pl0);

 crlf;
 crlf;
 sd(2,'You enter the Chambers of the Court Magican ');
 sd(global_plycol,court_mage);
 crlf;
 pause;

 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_courtmage then begin
   refresh:=true;
   onliner.location:=onloc_courtmage;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  {display menu}
  display_menu(true,true);

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user input}
  case ch of
   '?':begin {menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'D':begin {dark avenger}
        crlf;
        crlf;
        d(15,'Dark Avenger.');
        d(10,'The Dark Avenger can find and deplete the powers of a character.');
        d(10,'Usually the encounter with the Avenger will also give the character');
        d(10,'a disease or something else that will haunt for a period of time.');
        d(10,'Should the character be on-line the encounter will take place');
        d(10,'immediately, otherwise the Avenger will wait for the player');
        d(10,'to appear (forever if it''s necessary).');
        d(10,'The Avenger will report back to you upon return from its mission.');
        crlf;

        if confirm('Send Avenger','N')=true then begin
         if player.darknr<1 then begin
          d(12,'Sorry, you have no evil deeds left.');
         end
         else begin
          crlf;
          d(2,'Who should the Avenger seek out?');
          sd(2,':');
          s:=get_string(20);

          found:=false;
          abort:=false;

          for i:=1 to 2 do begin

           size:=1;
           case i of
            1: size:=fs(fsplayer);
            2: size:=fs(fsnpc);
           end;

           for j:=1 to size do begin

            load_character(pl0^,i,j);

            if (findsub(s,pl0^.name2)) and
               (pl0^.name2<>player.name2) and
               (pl0^.deleted=false) and
               (pl0^.name2<>global_delname2) then begin

             if confirm(uplc+pl0^.name2+config.textcol1,'N')=true then begin
              found:=true;
              abort:=true;
             end
             else begin
              if confirm('Continue search','Y')=false then begin
               abort:=true;
              end;
             end;

            end;
            if abort then break;
           end; {for j:= .end.}
           if abort then break;
          end; {for i:= .end.}


          if found then begin

           {sent text}
           d(14,'The Avenger has been sent out to destroy '+uplc+pl0^.name2
                +uyellow+'...');

           {decrease evil deeds}
           dec(player.darknr);

           {decrease player soul}
           x:=player.level*25;
           d(15,'Your soul darkened after this cruel deed! ('+commastr(x)+' points)');
           give_darkness(player,x);

           {send avenger}
           if is_online(pl0^.name2,online_player) then begin
            online_send_to_player(pl0^.name2,online_player,broadcast_RoyalAvenger);
           end
           else begin

            {mail an avenger :)}
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_RoyalAvenger,
            player.name2,
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

         end;

        end;

       end;
   'A':begin {angel of healing}

        crlf;
        crlf;
        d(15,'Angel of Healing.');
        d(10,'The Angel can find and restore the powers of a character.');
        d(10,'Usually the encounter with the Angel will also give the character');
        d(10,'a portion of experience.');
        d(10,'Should the character be on-line the healing process will take');
        d(10,'place immediately, otherwise the Angel will wait for the player');
        d(10,'to appear.');
        d(10,'The Angel will report back to you upon return from its mission.');
        crlf;

        if confirm('Send Angel','N')=true then begin
         if player.chivnr<1 then begin
          d(12,'Sorry, you have no good deeds left.');
         end
         else begin
          crlf;
          d(2,'Who should the Angel seek out?');
          sd(2,':');
          s:=get_string(20);

          found:=false;
          abort:=false;

          for i:=1 to 2 do begin

           size:=1;
           case i of
            1: size:=fs(fsplayer);
            2: size:=fs(fsnpc);
           end;

           for j:=1 to size do begin

            load_character(pl0^,i,j);

            if (findsub(s,pl0^.name2)) and
               (pl0^.name2<>player.name2) and
               (pl0^.deleted=false) and
               (pl0^.name2<>global_delname2) then begin

             if confirm(uplc+pl0^.name2+config.textcol1,'N')=true then begin
              found:=true;
              abort:=true;
             end
             else begin
              if confirm('Continue search','Y')=false then begin
               abort:=true;
              end;
             end;

            end;
            if abort then break;
           end; {for j:= .end.}
           if abort then break;
          end; {for i:= .end.}


          if found then begin

           {sent text}
           d(14,'The Angel has been sent out to heal '+uplc+pl0^.name2
                +uyellow+'...');

           {decrease good deeds}
           dec(player.chivnr);

           {increase player soul}
           x:=player.level*25;
           d(15,'Your soul lightened after this deserving act! ('+commastr(x)+' points)');
           give_chivalry(player,x);

           {send angel}
           if is_online(pl0^.name2,online_player) then begin
            online_send_to_player(pl0^.name2,online_player,broadcast_RoyalAngel);
           end
           else begin

            {mail an angel :)}
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_RoyalAngel,
            player.name2,
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

         end;

        end;

       end;
  end; {case .end.}

 until ch='R';

 crlf;
 crlf;
 d(config.textcolor,'You take the winding Staircase down to the Great Hall..');
 crlf;

 {dispose pointer vars}
 dispose(pl0);

end; {Court_Magician *end*}

end. {Unit CrtMage .end.}
