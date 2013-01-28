
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


Unit GenNews; {Usurper - news paper routines for Royals,
                marriages, births etc etc

               SEE ALSO related routines: news.pas

               when you have the time: incorporate NEWS.PAS into
               this generic routine. this routine can be used
               for all newsfiles that needs to be written.
              }
Interface

Uses Init;

type NewsType = (RoyalNews,MarriageDivorceNews,ChildBirthNews,HolyNews);

Procedure Generic_News(KindofNews : NewsType;
                       space  : boolean; {place a trailing [empty] line at the end?}
                       const l1  : s100;
                       const l2  : s100;
                       const l3  : s100;
                       const l4  : s100;
                       const l5  : s100;
                       const l6  : s100;
                       const l7  : s100;
                       const l8  : s100;
                       const l9  : s100;
                       const l10 : s100);


Implementation

Uses AnsiColr, Jakob, File_Io;

Procedure Generic_News; {** Generic News **}
var
    newsfile : text;

    i : integer;

    header,
    datestr : s90;

    AnsiFile, AsciFile : s100;

begin

 {Generic News Paper}

 {Writes to either both ANSI and ASCII file or only one of them}
 {Usurpers own ansicodes are converted to general ansicodes before}
 {written to file.}
 {Ascii news strings are stripped from ansicodes before written to file}

 {we put a date string first in the news-paper, kind of a a header}
 datestr:=fix_date(todays_date);
 header:='';

 {determine NewsType}
 case KindofNews of
  HolyNews:begin
            AnsiFile:=global_GodsANSI;
            AsciFile:=global_GodsASCI;
            header:='Usurper, Log of Gods';
           end;
  RoyalNews:begin
             AnsiFile:=global_MonarchsANSI;
             AsciFile:=global_MonarchsASCI;
             header:='Usurper, List of Monarchs ';
            end;
  MarriageDivorceNews:begin
                       AnsiFile:=global_MarrHistANSI;
                       AsciFile:=global_MarrHistASCI;
                       header:='Usurper,  Marriages and Divorces';
                      end;
  ChildBirthNews:begin
                  AnsiFile:=global_ChildBirthHistANSI;
                  AsciFile:=global_ChildBirthHistASCI;
                  header:='Usurper,  Child-Births & Deaths';
                 end;
 end; {case .end.}


 {does ansifile exist?}
 if (AnsiFile<>'') and (f_exists(AnsiFile)=false) then begin
  if open_txtfile(tappend,newsfile,AnsiFile)=true then begin

   {write header}
   write_to_text(newsfile,AGreenonBlack);
   writeln_to_text(newsfile,mkstring(length(header),underscore));
   writeln_to_text(newsfile,uconv(header));
   writeln_to_text(newsfile,mkstring(length(header),underscore));
   writeln_to_text(newsfile,' ');
   close_text(newsfile);

  end
  else begin
   unable_to_access(AnsiFile,access_error);
  end;
 end;

 {does AsciiFile exist?}
 if (AsciFile<>'') and (f_exists(AsciFile)=false) then begin

  if open_txtfile(tappend,newsfile,AsciFile)=true then begin

   {write header}
   writeln_to_text(newsfile,header);
   writeln_to_text(newsfile,mkstring(length(header),underscore));
   writeln_to_text(newsfile,' ');

   {close newsfile}
   close_text(newsfile);

  end
  else begin
   unable_to_access(AsciFile,access_error);
  end;
 end;



 {**** Let's write ANSI news *****}
 if (AnsiFile<>'') and (open_txtfile(tappend,newsfile,AnsiFile)) then begin

  if KindofNews in [RoyalNews,HolyNews] then begin
   writeln_to_text(newsfile,datestr);
  end;

  if l1<>'' then writeln_to_text(newsfile,uconv(l1));
  if l2<>'' then writeln_to_text(newsfile,uconv(l2));
  if l3<>'' then writeln_to_text(newsfile,uconv(l3));
  if l4<>'' then writeln_to_text(newsfile,uconv(l4));
  if l5<>'' then writeln_to_text(newsfile,uconv(l5));
  if l6<>'' then writeln_to_text(newsfile,uconv(l6));
  if l7<>'' then writeln_to_text(newsfile,uconv(l7));
  if l8<>'' then writeln_to_text(newsfile,uconv(l8));
  if l9<>'' then writeln_to_text(newsfile,uconv(l9));
  if l10<>'' then writeln_to_text(newsfile,uconv(l10));

  if space then writeln_to_text(newsfile,' ');
  close_text(newsfile);
 end
 else begin
  unable_to_access(AnsiFile,access_error);
 end;


 {**** Let's write ASCII news *****}
 if (AsciFile<>'') and (open_txtfile(tappend,newsfile,AsciFile)) then begin

  if KindofNews in [RoyalNews,HolyNews] then begin
   writeln_to_text(newsfile,datestr);
  end;

  if l1<>'' then writeln_to_text(newsfile,strip(l1));
  if l2<>'' then writeln_to_text(newsfile,strip(l2));
  if l3<>'' then writeln_to_text(newsfile,strip(l3));
  if l4<>'' then writeln_to_text(newsfile,strip(l4));
  if l5<>'' then writeln_to_text(newsfile,strip(l5));
  if l6<>'' then writeln_to_text(newsfile,strip(l6));
  if l7<>'' then writeln_to_text(newsfile,strip(l7));
  if l8<>'' then writeln_to_text(newsfile,strip(l8));
  if l9<>'' then writeln_to_text(newsfile,strip(l9));
  if l10<>'' then writeln_to_text(newsfile,strip(l10));

  if space then writeln_to_text(newsfile,' ');
  close_text(newsfile);
 end
 else begin
  unable_to_access(AsciFile,access_error);
 end;

end; {Generic_News *end*}


end. {Unit GenNews .end.}
