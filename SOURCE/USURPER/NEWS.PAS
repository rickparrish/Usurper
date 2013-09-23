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



unit News; {Usurper  - News Paper Unit

           writing to the News file? this
            is the procedure to use!

           see GENNEWS.PAS for a generic news routine..meant to replace
           this one

            For Royal comings and goings, which are logged
            in the royal log, see kingnews.pas}

interface

uses
  Init;

procedure Newsy(space: boolean; {place a trailing [empty] line at the end?}
  const l1: s100; {line with news text: l1-l10}
  const l2: s100; const l3: s100; const l4: s100; const l5: s100; const l6: s100; const l7: s100;
  const l8: s100; const l9: s100; const l10: s100);

implementation

uses
  AnsiColr, Jakob, File_Io;

procedure Newsy;
var
  newsfile:   Text;
  s1, s2, s3: s100;

begin

  {Writes to ANSI and ASCII file newsfiles}
  {Usurpers own ansicodes are converted to standard ansicodes before}
  {written to file.}
  {Ascii news strings are stripped from ansicodes before written to file}

  if (global_nwfileans <> '') and (not f_exists(global_nwfileans)) then
  begin
    if open_txtfile(tappend, newsfile, global_nwfileans) = True then
    begin
      s1 := '-*Usurper*- Happenings of ' + fix_date(todays_date);
      s2 := ulgray + '-*Usurper*-' + ulgreen + ' Happenings of ' + fix_date(todays_date) + ugreen;

      s3 := ulgray;

      write_to_text(newsfile, AGreenonBlack);
      writeln_to_text(newsfile, mkstring(length(s1), underscore));
      writeln_to_text(newsfile, uconv(s2));
      writeln_to_text(newsfile, mkstring(length(s1), underscore));
      writeln_to_text(newsfile, ' ');
      close_text(newsfile);
    end else
    begin
      unable_to_access(global_nwfileans, access_error);
    end;
  end;

  if (global_nwfileasc <> '') and (not f_exists(global_nwfileasc)) then
  begin
    if open_txtfile(tappend, newsfile, global_nwfileasc) = True then
    begin
      s1 := 'Usurper. Happenings of ' + fix_date(todays_date);
      writeln_to_text(newsfile, s1);
      writeln_to_text(newsfile, mkstring(length(s1), underscore));
      writeln_to_text(newsfile, ' ');
      close_text(newsfile);
    end else
    begin
      unable_to_access(global_nwfileasc, access_error);
    end;
  end;

  if global_nwfileans <> '' then
  begin
    {**** Let's write ANSI news *****}
    if open_txtfile(tappend, newsfile, global_nwfileans) then
    begin

      if l1 <> '' then
        writeln_to_text(newsfile, uconv(l1));
      if l2 <> '' then
        writeln_to_text(newsfile, uconv(l2));
      if l3 <> '' then
        writeln_to_text(newsfile, uconv(l3));
      if l4 <> '' then
        writeln_to_text(newsfile, uconv(l4));
      if l5 <> '' then
        writeln_to_text(newsfile, uconv(l5));
      if l6 <> '' then
        writeln_to_text(newsfile, uconv(l6));
      if l7 <> '' then
        writeln_to_text(newsfile, uconv(l7));
      if l8 <> '' then
        writeln_to_text(newsfile, uconv(l8));
      if l9 <> '' then
        writeln_to_text(newsfile, uconv(l9));
      if l10 <> '' then
        writeln_to_text(newsfile, uconv(l10));

      if space then
        writeln_to_text(newsfile, ' ');

      close_text(newsfile);

    end else
    begin
      unable_to_access(global_nwfileans, access_error);
    end;
  end;

  if global_nwfileasc <> '' then
  begin
    {**** Let's write ASCII news *****}
    if open_txtfile(tappend, newsfile, global_nwfileasc) then
    begin
      if l1 <> '' then
        writeln_to_text(newsfile, strip(l1));
      if l2 <> '' then
        writeln_to_text(newsfile, strip(l2));
      if l3 <> '' then
        writeln_to_text(newsfile, strip(l3));
      if l4 <> '' then
        writeln_to_text(newsfile, strip(l4));
      if l5 <> '' then
        writeln_to_text(newsfile, strip(l5));
      if l6 <> '' then
        writeln_to_text(newsfile, strip(l6));
      if l7 <> '' then
        writeln_to_text(newsfile, strip(l7));
      if l8 <> '' then
        writeln_to_text(newsfile, strip(l8));
      if l9 <> '' then
        writeln_to_text(newsfile, strip(l9));
      if l10 <> '' then
        writeln_to_text(newsfile, strip(l10));

      if space then
        writeln_to_text(newsfile, ' ');

      close_text(newsfile);

    end else
    begin
      unable_to_access(global_nwfileasc, access_error);
    end;
  end;

end; {newsy *end*}

end. {Unit News .end.}
