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



unit Post_To; {Usurper - send a letter}

interface

uses
  Init;

procedure Send_a_Letter(outside: boolean); {outside=true indicates that
                                          message is sent from commandline
                                          usurper /DO_SENDMAIL or
                                          from the intro game menu}

procedure Create_Letter(var new_letter: mailrec; const receiver: s100; {name of receiver}
  const Sender: s100; {name of sender}
  const q1: s100; {message text follows...}
  const q2: s100; const q3: s100; const q4: s100; const q5: s100; const q6: s100; const q7: s100; const q8: s100; const q9: s100; const q10: s100);


implementation

uses
  InitGods, Jakob, Cms,
  Mail, Online, File_Io;

procedure Create_Letter;
const maxlin   = 13;   {max lines in message}
  maxquote     = 10;   {max quote lines}
  len          = 70;   {max length of text lines}
  prefix       = '->'; {quote prefix} {note! also defined in mail.pas}
  quotetextcol = 7;  {quote text color} {note! also defined in mail.pas}
var
  ch:          char;

  i, j, y, Count: integer;

  line:        byte;

  memlocation: word;

  mtext:       array [1..maxlin] of s100; {message text array}
  qtext:       array [1..maxquote] of s100; {quote text array}

  multi_mem, abort_message: boolean;

  s, e, f, a2: s70;

  t:           string;

begin

 {lets turn OFF multi-node checking, so the message writer wont be
  disturbed by multiline broadcasts and messages}
  multi_mem := global_multi;
  if global_multi then
  begin
    global_multi := False;

    memlocation := onliner.location;
    if onliner.location <> onloc_postingmail then
    begin
      onliner.location := onloc_postingmail;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;
  end;

  {init message text string array}
  for i := 1 to maxlin do
  begin
    mtext[i] := emptystr;
  end;

  {transfering param quote strings to array}
  if q1 <> '' then qtext[1] := q1
  else qtext[1] := emptystr;

  if q2 <> '' then qtext[2] := q2
  else qtext[2] := emptystr;

  if q3 <> '' then qtext[3] := q3
  else qtext[3] := emptystr;

  if q4 <> '' then qtext[4] := q4
  else qtext[4] := emptystr;

  if q5 <> '' then qtext[5] := q5
  else qtext[5] := emptystr;

  if q6 <> '' then qtext[6] := q6
  else qtext[6] := emptystr;

  if q7 <> '' then qtext[7] := q7
  else qtext[7] := emptystr;

  if q8 <> '' then qtext[8] := q8
  else qtext[8] := emptystr;

  if q9 <> '' then qtext[9] := q9
  else qtext[9] := emptystr;

  if q10 <> '' then qtext[10] := q10
  else qtext[10] := emptystr;

  {remove double quotes}
  for i := 1 to maxquote do
  begin
    Count := 0;
    f := prefix;
    y := 0;
    repeat
      Inc(y);
      j := pos(prefix, qtext[i]);
      if j <> 0 then
      begin
        Inc(Count);
        if Count > 1 then break;
      end;
    until (j = 0) or (y > 10);
    if Count > 1 then
    begin
      qtext[i] := '';
    end;
  end; {for i:= .end.}

  {online player writes letter to RECEIVER}
  crlf;
  d(10, 'Enter your message  (max ' + commastr(maxlin) + ' lines, BLANK line to end) ');
  d(config.textcolor, '   I' + mkstring(68, underscore) + 'I');

  line := 1;
  for i := 1 to maxquote do
  begin
    if qtext[i] <> '' then
    begin
      e := commastr(line);
      if length(e) = 1 then e := '0' + e;
      sd(config.textcolor, '[' + e + '] ');

      f := prefix;
      repeat
        j := pos(prefix, qtext[i]);
        if j <> 0 then
        begin
          f := f + prefix;
          Delete(qtext[i], j, 2);
        end;
      until j = 0;

      e := f + mtext[line] + qtext[i];
      if length(e) > len then
      begin
        {quote line becomes too long and has to be moved down}
        j := length(e) - len;
        a2 := copy(e, 71, j); {string that shall be moved downward}
        e := copy(e, 1, 70);  {the 70 char string is kept}

        mtext[line + 1] := a2;
      end;

      mtext[line] := e;
      d(quotetextcol, mtext[line]);

      Inc(line);

      if line > maxquote then
      begin
        break;
      end;

    end;
  end; {for i:= .end.}

  a2 := '';

  abort_message := False;
  repeat
    e := commastr(line);
    if length(e) = 1 then e := '0' + e;
    sd(config.textcolor, '[' + e + ']:');

    t := mtext[line];
    get_stringw(t, len);
    mtext[line] := t;

    if (mtext[line] = '') or (line = maxlin) then
    begin
      repeat
        crlf;
        if line = maxlin then
        begin
          d(12, '[Message is full]');
        end;
        menu2('(S)ave  ');
        menu2('(C)ontinue  ');
        menu2('(D)isplay  ');
        menu2('(A)bort :');

        {get user-input}
        ch := upcase(getchar);

      until ch in ['S', 'C', 'D', 'A'];

      {evaluate user-input}
      case ch of
        'S': begin {save message}
          d(15, 'Save');
          break;
        end;
        'C': begin {continue message}

          d(15, 'Continue');
          if line >= 1 then
          begin
            Dec(line);
          end;

        end;
        'D': begin {display message}

          d(15, 'Display');
          crlf;
          for i := 1 to maxlin do
          begin
            if mtext[i] <> '' then
            begin
              d(config.textcolor, mtext[i]);
            end;
          end; {for i:= .end.}
          pause;
          if line >= 1 then
          begin
            Dec(line);
          end;

        end;
        'A': begin {abort message}
          d(15, 'Abort');
          abort_message := True;
          break;
        end;

      end; {case .end.}

    end;

    if line > 1 then
    begin
      j := length(mtext[line]);
      if (j = len) and (mtext[line][j] <> ' ') and (line < maxlin) then
      begin
        {do we have to bring with us the last word from the preceeding line?}
        {the word may not be too long (60 chars). we can't bring a whole line!}
        e := '';
        Count := 0;

        {count word length in mtext[line]}
        i := j;
        repeat
          if mtext[line][i] <> ' ' then
          begin
            Inc(Count);
          end else
          begin
            break;
          end;
          Dec(i);
        until i = 0;

        if Count <= 60 then
        begin
          Count := 0;
          repeat
            Inc(Count);
            if mtext[line][j] <> ' ' then
            begin
              e := mtext[line][j] + e;
            end else
            begin
              break;
            end;
            Dec(j);
          until j = 0;

          {delete word that is being transfered down to the next line}
          {and remove the same string from present line}

          for j := 1 to length(e) do
          begin
            sswrite(chr(8));
            sswrite(' ');
            sswrite(#8);
          end; {for j:= .end.}

          j := length(mtext[line]) - length(e);
          Delete(mtext[line], j, length(e) + 1);
          mtext[line + 1] := e;
        end;

      end;
    end;

    crlf;
    Inc(line);
  until line > maxlin;

  new_letter.mess[1] := '';

  if line > 1 then
  begin
    crlf;
    if abort_message = False then
    begin

      if receiver = global_destination then
      begin
        s := 'ROYAL PROCLAMATION *PUBLIC MESSAGE*';
      end else
      begin
        s := 'Message from ' + Sender;
      end;

      new_letter.mess[2] := ulgreen + mkstring(length(s), underscore) + config.textcol1;

      if receiver = global_destination then
      begin
        s := uwhite + 'ROYAL PROCLAMATION *PUBLIC MESSAGE*' + config.textcol1;
      end else
      begin
        s := ulblue + 'Message' + config.textcol1 + ' from ' + uplc + Sender + config.textcol1;
      end;

      new_letter.mess[1] := s;

      for i := 1 to maxlin do
      begin
        new_letter.mess[2 + i] := mtext[i];
      end; {for i:= .end.}

      if receiver = global_destination then
      begin
        crlf;
        d(config.textcolor, 'Message is being transmitted to your subjects..');
      end else
      begin
        crlf;
        s := ' Transmitting Mail ';
        d(9, cool_string(length(s), '=', '-', 9, 9));
        d(13, s);
        d(9, cool_string(length(s), '=', '-', 9, 9));
        sd(config.textcolor, 'Message has been sent to ');
        sd(global_plycol, receiver);
        d(config.textcolor, '.');
        crlf;
      end;

    end else
    begin
      new_letter.mess[1] := '';
      d(12, 'Message Aborted.');
      crlf;
    end;
  end else
  begin
    d(12, 'Message Aborted.');
    crlf;
  end;

 {lets turn ON multi-node checking, so the message writer may receive
  inter-node info again}
  global_multi := multi_mem;

  if global_multi then
  begin
    if onliner.location <> memlocation then
    begin
      onliner.location := memlocation;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;
  end;

end; {CREATE_LETTER **END**}

procedure Send_a_Letter; {player sends a letter to other player}
var
  destai:   char;

  found:    byte;
  i:        word;

  s:        string;
  alias, destination: s30;

  e:        string[7];

  destgod,  {is destination of letter a god/immortal?}
  no_more:  boolean;

  {records}
  a_letter: mailrec;
  god0:     godrec;
  pl0:      ^UserRec;

begin

  {init}
  destgod := False;
  no_more := False;
  found := 0;

  {this routine is used by "Inn.pas" and "PrisonC.pas"}
  {"castle.pas" uses a similar routine to mail *ALL SUBJECTS*}

  {init pointer vars}
  new(pl0);

  crlf;
  crlf;
  d(config.textcolor, 'To whom do you wish to send a message ?');
  sd(config.textcolor, ':');

  if outside then
  begin
    {local operation using command line option /DO_SENDMAIL}
    readln(s);
  end else
  begin
    s := get_string(25);
  end;

  for i := 1 to fs(FsPlayer) do
  begin

    load_character(pl0^, 1, i);

    if (findsub(s, pl0^.name2)) and
      (pl0^.name2 <> player.name2) and
      (pl0^.name2 <> global_delname2) and
      (pl0^.deleted = False) then
    begin

      sd(global_plycol, pl0^.name2);
      if pl0^.king then
      begin
        if pl0^.sex = 1 then e := 'King'
        else e := 'Queen';
        sd(14, ' (The ' + e + ')');
      end;

      if confirm('', 'N') = True then
      begin
        found := 1;
        break;
      end
      else
      begin
        if confirm('Continue Search', 'y') = False then
        begin
          no_more := True;
          break;
        end;
      end;

    end;

    if (found <> 0) or (no_more = True) then
    begin
      break;
    end;

  end; {for i:= .end.}

  if (found = 0) and (no_more = False) then
  begin
    {search among the immortals}
    for i := 1 to fs(FsGod) do
    begin

      {load god}
      load_god(fload, god0, i);

      if (findsub(s, god0.Name)) and
        (god0.deleted = False) and
        (god0.Name <> player.name2) then
      begin
        if confirm(ugodc + god0.Name + ulcyan + '  <Immortal>' + config.textcol1, 'N') = True then
        begin
          found := 2;
          destgod := True;
          break;
        end;
      end;

    end; {for i:= .end.}
  end;

  if (found > 0) and (no_more = False) then
  begin

    {ask for alias if this is created from the outside (dos/??)}
    if outside then
    begin
      crlf;
      d(config.textcolor, 'What ' + uyellow + 'NAME' + config.textcol1 + ' or ' + uyellow + 'ALIAS' + config.textcol1 + ' do you wish to use?');
      sd(config.textcolor, ':');
      readln(alias);
    end;

    if outside = False then
    begin
      if global_godactive then alias := god.Name
      else alias := player.name2;
    end else
    begin
      if alias = '' then alias := 'GOD';
    end;

    case found of
      1: begin {destination is a mortal player}
        destination := pl0^.name2;
        destai := pl0^.ai;
      end;
      2: begin {destination is a immortal player}
        destination := god0.Name;
        destai := god0.ai;
      end;
    end; {case .end.}

    {let user write his letter}
    a_letter.mess[1] := '';

 { debug check
  d(15,'ALIAS:'+alias);
  pause;
 }

    {write the letter}
    create_letter(a_letter,
      destination,
      alias,
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

    if a_letter.mess[1] <> '' then
    begin

      {post letter}
      post(MailSend,
        destination,
        destai,
        destgod,
        mailrequest_nothing,
        alias,
        a_letter.mess[1],
        a_letter.mess[2],
        a_letter.mess[3],
        a_letter.mess[4],
        a_letter.mess[5],
        a_letter.mess[6],
        a_letter.mess[7],
        a_letter.mess[8],
        a_letter.mess[9],
        a_letter.mess[10],
        a_letter.mess[11],
        a_letter.mess[12],
        a_letter.mess[13],
        a_letter.mess[14],
        a_letter.mess[15]);

      if outside = False then
      begin

        {online mess to reciever, only if he is online (of course)}
        if (is_online(destination, online_god)) and (destination <> player.name2) then
        begin
          online_send_to_player(destination, online_god, uplc + player.name2 + config.textcol1 + ' posted a letter to you.');
        end;

      end;
    end;
  end;

  {dispose pointer vars}
  dispose(pl0);

end; {send_a_letter *end*}

end. {Unit Post_To .end.}
