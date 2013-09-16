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


Unit SortPl; {Usurper - Sort Players/Npcs to file/screen}

Interface

Procedure Sort_Players (bye : boolean);

Implementation

Uses Init, Cms, Jakob,
     Various, Various3, Online,
     AnsiColr, File_Io;

const header='###  Name                  Level  Race      Class      Experience  Status';
var

    counter,
    gap, j, k : integer;

    exp_array  : array [1..global_maxplayers] of ^longint; {experience}
    pos_array : array [1..global_maxplayers] of longint; {file position}

    i, x, y, xx, yy : longint;

    s : ^s70;

    cust0 : UserRec;

    ansifile, ascifile : text;
    ansiname, asciname : s70;
    ansiscore, asciscore : boolean;

    {worknumbers sets the number of records the game will sort.
     if the user file contains more than global_maxplayers constant
     allows, then this will prevent the program from bugging out (by
     limiting the sort items to global_maxplayers}
    worknumbers : word;


Procedure Write_Ansi; {writes player score file (ansi) }
var first : boolean;
    bigcounter : word;
begin

 if open_txtfile(trewrite,ansifile,ansiname) then begin

  {this line goes to local screen only}
  wrl(10,'    '+ansiname);

  writeln_to_text(ansifile,AMagentaOnBlack+header);
  writeln_to_text(ansifile,ALtGrayonBlack+mkstring(length(header),underscore));

  write_to_text(ansifile,ConvertToAnsi(Config.TextColor));

  bigcounter:=0;
  for i:=1 to WorkNumbers do begin

   if pos_array[i]>0 then begin

    {load characted}
    if load_character(cust0,1,pos_array[i]) then begin

     if player_active(cust0,false)=true then begin

      {write color for playernames}
      write_to_text(ansifile,ALtGreenOnBlack);

      {#}
      inc(bigcounter);

      {#}
      s^:=commastr(bigcounter)+'.';
      case length(s^) of
       2: s^:='  '+s^;
       3: s^:=' '+s^;
      end;

      {king,dead or alive color}
      if cust0.king then begin
       write_to_text(ansifile,ALtCyanOnBlack+s^+' '+ALtCyanOnBlack);
      end
      else if cust0.hps<1 then begin
       write_to_text(ansifile,ALtCyanOnBlack+s^+' '+ALtRedOnBlack);
      end
      else begin
       write_to_text(ansifile,ALtCyanOnBlack+s^+' '+ALtGreenOnBlack);
      end;

      {name}
      x:=length(cust0.name2);
      if x>20 then x:=20;

      cust0.name1:=cust0.name2;
      cust0.name2:=cust0.name2+mkstring(25,'.');
      first:=false;
      for j:=1 to 20 do begin
       if (j>x) and (first=false) then begin
        first:=true;
        write_to_text(ansifile,ConvertToAnsi(Config.TextColor));
       end;
       write_to_text(ansifile,cust0.name2[j]);
      end; {for j:= .end.}

      if not first then begin
       write_to_text(ansifile,ConvertToAnsi(Config.TextColor));
      end;

      {level}
      str(cust0.level:7,s^);
      for j:=1 to length(s^) do begin
       if s^[j]=' ' then s^[j]:='.';
      end;
      write_to_text(ansifile,s^);

      {race}
      s^:=race_display(1,cust0.race,0)+mkstring(22,' ');
      write_to_text(ansifile,'  '+copy(s^,1,10));

      {class}
      s^:=classnames[cust0.class]+mkstring(22,' ');
      write_to_text(ansifile,copy(s^,1,10));

      {experience}
      s^:=commastr(cust0.exp);
      x:=length(s^);
      if x<11 then begin
       x:=11-x;
       s^:=mkstring(x,' ')+s^;
      end;

      write_to_text(ansifile,ALtGrayonBlack+s^+ConvertToAnsi(Config.TextColor));

      if cust0.location=offloc_prison then begin
       write_to_text(ansifile,AltGrayonBlack+'  Prison'+ConvertToAnsi(Config.TextColor));
      end
      else if cust0.location=offloc_castle then begin
       write_to_text(ansifile,AYellowonBlack+'  Castle'+ConvertToAnsi(Config.TextColor));
      end
      else if cust0.hps>0 then begin
       write_to_text(ansifile,'  Alive');
      end
      else if cust0.hps<=0 then begin
       write_to_text(ansifile,ALtRedonBlack+'  Dead'+ConvertToAnsi(Config.TextColor));
      end;

      if (cust0.ai='C') and (config.marknpcs) then begin
       write_to_text(ansifile,global_npcmark);
      end;

      if (config.writemarriedflag=true) and
         (cust0.married=true) then begin
       write_to_text(ansifile,ALtGrayOnBlack);
       write_to_text(ansifile,'<M>');
       write_to_text(ansifile,ConvertToAnsi(Config.TextColor));
      end;

      if cust0.king=true then begin
       write_to_text(ansifile,ALtGrayOnBlack);
       if cust0.sex=1 then write_to_text(ansifile,'<K>')
                      else write_to_text(ansifile,'<Q>');
       write_to_text(ansifile,ConvertToAnsi(Config.TextColor));
      end;
      writeln_to_text(ansifile,' ');
     end;
    end;
   end;

  end; {for i:= .end.}

  writeln_to_text(ansifile,' ');
  if config.marknpcs then begin
   writeln_to_text(ansifile,'('+global_npcmark+' indicates computer player)');
  end;
  writeln_to_text(ansifile,'(<M>arried, <K>ing, <Q>ueen)');
  close_text(ansifile);
 end
 else begin
  {Unable to Create File}
  unable_to_create(ansiname,access_error);
 end;

end; {Write_Ansi *end*}

Procedure Sort_Players;
var dummy : word;
    col : byte;
    bigcounter : word;
    ch : char;
    pause_check : boolean;
begin

 worknumbers:=fs(FsPlayer);
 if worknumbers>global_maxplayers then worknumbers:=global_maxplayers;

 {init pointer vars}
 for i:=1 to worknumbers do begin
  new(exp_array[i]);
  exp_array[i]^:=0;
 end; {for i:= .end.}
 new(s);

 for i:=1 to global_maxplayers do begin
  pos_array[i]:=0;
 end; {for i:= .end.}

 dummy:=0;
 for i:=1 to worknumbers do begin

  if load_character(cust0,1,i)=true then begin

   if config.spincursor=true then begin
    inc(dummy);
    if dummy>20 then begin
     dummy:=0;
     spin_cursor(2,config.textcolor); {spinit}
    end;
   end;

   if player_active(cust0,false)=true then begin

    exp_array[i]^:=cust0.exp; {experience}
    pos_array[i]:=cust0.recnr; {file position/ record #}

   end;
  end;

 end; {for i:= .end.}

 gap:=1;
 while gap < worknumbers do
  gap:=gap*3 +1;

 while gap>0 do begin
  for i:=(gap+1) to worknumbers do begin
   xx:=exp_array[i]^;
   yy:=pos_array[i];
   j:=i-gap;
   while (j>0) do begin
    k:=j+gap;
    if exp_array[j]^>=xx then begin
     exp_array[k]^:=xx;
     pos_array[k]:=yy;
     j:=0;
    end
    else begin
     exp_array[k]^:=exp_array[j]^;
     pos_array[k]:=pos_array[j];
     j:=j-gap;
    end;
   end;
  end; {for i:= .end.}
  gap:=(gap - 1) div 3;
 end;
 {SortRoutine *END*}


 {Display list of sorted characters to the Screen}
 if bye=false then begin
  clearscreen;
  d(5,'Characters of Usurper');
  d(5,header);

  x:=0;
  y:=0;
  counter:=2;
  bigcounter:=0;
  pause_check:=true;

  for i:=1 to worknumbers do begin

   if pos_array[i]>0 then begin
    if load_character(cust0,1,pos_array[i]) then begin

     if player_active(cust0,false)=true then begin

      {counters}
      if pause_check=true then inc(counter);
      inc(bigcounter);

      {#}
      s^:=commastr(bigcounter)+'.';
      case length(s^) of
       2: s^:='  '+s^;
       3: s^:=' '+s^;
      end;
      sd(11,s^+' ');

      {name}
      x:=length(cust0.name2);
      if x>20 then x:=20;

      cust0.name1:=cust0.name2; {since we screw up cust0.name2 and we need
                                 to remember cust0.name2 we put it in .name1
                                 we never save the records here so there is
                                 nothing to worry about.}
      cust0.name2:=cust0.name2+mkstring(25,'.');

      for j:=1 to 20 do begin
       if j<=x then begin
        if cust0.king then begin
         col:=global_kingcol;
        end
        else if cust0.hps<1 then begin
         col:=12;
        end
        else begin
         col:=global_plycol;
        end;

       end
       else begin
        col:=2;
       end;
       sd(col,cust0.name2[j]);
      end; {for j:= .end.}

      {level}
      str(cust0.level:7,s^);
      for j:=1 to length(s^) do begin
       if s^[j]=' ' then s^[j]:='.';
      end;
      sd(config.textcolor,s^);

      {race}
      s^:=race_display(1,cust0.race,0)+mkstring(21,' ');
      sd(config.textcolor,'  '+copy(s^,1,10));

      {class}
      s^:=classnames[cust0.class]+mkstring(21,' ');
      sd(config.textcolor,copy(s^,1,10));

      {experience}
      s^:=commastr(cust0.exp);
      x:=length(s^);

      if x<11 then begin
       x:=11-x;
       s^:=mkstring(x,' ')+s^;
      end;
      sd(7,s^);

      {location/status}
      if is_online(cust0.name1,online_player)=true then begin
       sd(14,'  Online');
      end
      else if cust0.location=offloc_prison then begin
       sd(11,'  Prison');
      end
      else if cust0.location=offloc_castle then begin
       sd(14,'  Castle');
      end
      else if (cust0.hps=-9000) or (cust0.hps=-8000) then begin
       sd(12,'  Drugged');
      end
      else if cust0.hps>0 then begin
       sd(config.textcolor,'  Alive');
      end
      else begin
       sd(12,'  Dead');
      end;

      {mark npc character}
      if (cust0.ai='C') and (config.marknpcs) then begin
       sd(config.textcolor,global_npcmark);
      end;

      {married flag}
      if (config.WriteMarriedFlag=true) and
         (cust0.married=true) then begin
       sd(7,'<M>');
      end;

      {king}
      if cust0.king=true then begin
       if cust0.sex=1 then sd(7,'<K>')
                      else sd(7,'<Q>');
      end;
      crlf;
     end;

     {pause}
     if (counter>global_screenlines-2) and (pause_check=true) then begin
      counter:=0;
      ch:=confirm2('More','Y');
      if ch='N' then begin
       y:=1;
       break;
      end
      else if ch='=' then begin
       pause_check:=false;
      end;
     end;
    end;
   end;
  end; {for i:= .end.}

  if y=0 then begin
   crlf;
   if config.marknpcs then begin
    d(config.textcolor,'('+global_npcmark+' indicates computer player)');
   end;
   d(config.textcolor,'(<M>arried, <K>ing, <Q>ueen)');
   d(config.textcolor,'');
   pause;
   d(config.textcolor,'');
  end; {for i:= .end.}
 end
 else begin

  {should we write score lists?}

  ansiscore:=false;
  asciscore:=false;
  {checking if sysop has defined score lists}

  ansiname:=cfg_string(70);
  asciname:=cfg_string(71);

  if ansiname<>'' then ansiscore:=true;
  if asciname<>'' then asciscore:=true;

  {writes player score file (ascii) }
  if asciscore=true then begin

   dummy:=0;
   if open_txtfile(trewrite,ascifile,asciname) then begin

    {to local screen only}
    wrl(10,'    '+asciname);

    {start writing}
    writeln_to_text(ascifile,'Characters of Usurper');
    writeln_to_text(ascifile,' ');
    writeln_to_text(ascifile,header);
    writeln_to_text(ascifile,mkstring(length(header),underscore));

    bigcounter:=0;
    for i:=1 to worknumbers do begin

     if pos_array[i]>0 then begin
      {load character}
      if load_character(cust0,1,pos_array[i]) then begin

       if player_active(cust0,false)=true then begin

        inc(bigcounter);

        {#}
        s^:=commastr(bigcounter)+'.';
        case length(s^) of
         2: s^:='  '+s^;
         3: s^:=' '+s^;
        end; {case .end.}
        write_to_text(ascifile,s^+' ');

        {name}
        cust0.name1:=cust0.name2;
        cust0.name2:=cust0.name2+mkstring(21,'.');
        write_to_text(ascifile,copy(cust0.name2,1,20));

        {level}
        str(cust0.level:7,s^);
        for j:=1 to length(s^) do begin
         if s^[j]=' ' then s^[j]:='.';
        end;
        write_to_text(ascifile,s^);

        {race}
        s^:=race_display(1,cust0.race,0)+mkstring(21,' ');
        write_to_text(ascifile,'  '+copy(s^,1,10));

        {class}
        s^:=classnames[cust0.class]+mkstring(21,' ');
        write_to_text(ascifile,copy(s^,1,10));

        {experience}
        s^:=commastr(cust0.exp);
        x:=length(s^);
        if x<11 then begin
         x:=11-x;
         s^:=mkstring(x,' ')+s^;
        end;
        write_to_text(ascifile,s^);

        {location/status}
        if cust0.location=offloc_castle then begin
         write_to_text(ascifile,'  Castle');
        end
        else if cust0.location=offloc_prison then begin
         write_to_text(ascifile,'  Prison');
        end
        else if cust0.hps>0 then begin
         write_to_text(ascifile,'  Alive');
        end
        else if cust0.hps<=0 then begin
         write_to_text(ascifile,'  Dead');
        end;
        if (cust0.ai='C') and (config.marknpcs) then begin
         write_to_text(ascifile,global_npcmark);
        end;

        {married flag}
        if (config.writemarriedflag=true) and
           (cust0.married=true) then begin
         write_to_text(ascifile,'<M>');
        end;

        {king/queen}
        if cust0.king=true then begin
         if cust0.sex=1 then write_to_text(ascifile,'<K>')
                        else write_to_text(ascifile,'<Q>');
        end;

        writeln_to_text(ascifile,' ');
       end;
      end;
     end;
    end; {for i:= .end.}

    writeln_to_text(ascifile,' ');
    if config.marknpcs then begin
     writeln_to_text(ascifile,'('+global_npcmark+' indicates computer player)');
    end;
    writeln_to_text(ascifile,'(<M>arried, <K>ing, <Q>ueen)');

    close_text(ascifile);
   end
   else begin
    {Unable to Create File}
    unable_to_create(asciname,access_error);
   end;
  end;

  {should we write an ansi score file?}
  if ansiscore=true then begin
   write_ansi;
  end;

 end;

 {dispose pointer variables}
 for i:=1 to worknumbers do begin
  dispose(exp_array[i]);
 end;
 dispose(s);

end; {sort_players *end*}

end. {UNIT *end*}
