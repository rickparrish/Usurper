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


Unit DMaze; {Usurper - good deeds}

Interface

Procedure Death_Maze;

Implementation

Uses Init, Cms, Jakob,
     File_Io, Statusc, Various,
     Online;

var refresh : boolean;

Procedure Meny;
const local_place = 'The Starting Point';
begin
 clearscreen;
 crlf;
 d(5,'-*- Death Maze -*-');
 d(6,local_place);
 d(config.textcolor,'This is the world you never want to visit.');
 d(config.textcolor,'Unspeakable horrors are lurking in the shadows.');
 crlf;
 menu('(N)orth');
 menu('(S)tatus');
 menu('(R)eturn to dungeons');
end;

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['G',
                       'C',
                       'B',
                       'R',
                       chr(13),
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   crlf;
   sd(config.textcolor,'Death Maze (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin

   crlf;
   sd(config.textcolor,'Death Maze (N,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;
end; {display_menu *end*}

Procedure Death_Maze;
const never : boolean = false;
      mazef=global_datadir+'MAZE.DAT'; {maze file}
type MonsterState  = (MonsterPassive,MonsterActive);
type MazeRec = Record
      monster_name  : s30;
      monster_desc  : s70;
      monster_maxhps: longint;
      monster_hps   : longint;
      monster_state : MonsterState; {passive,aggressive}
     end;
var
   cho : char;

   mazedata : MazeRec;
   mazefile : file of MazeRec;

procedure init_mazedata(var mazy:mazerec);
begin
 mazy.monster_name:='Evil Gorilla';
 mazy.monster_desc:='The gorilla is huge and equipped with a club.';
 mazy.monster_maxhps:=700;
 mazy.monster_hps:=700;
 mazy.monster_state:=MonsterPassive; {see MonsterState}
end;
procedure load_mazedata(var mazy:mazerec);
begin
 assign(mazefile,mazef);
 reset(mazefile);
 read(mazefile,mazy);
 close(mazefile);
end;
procedure save_mazedata(var mazy:mazerec);
begin
 assign(mazefile,mazef);
 rewrite(mazefile);
 write(mazefile,mazy);
 close(mazefile);
end;

begin

 if f_exists(mazef)=false then begin
  assign(mazefile,mazef);
  rewrite(mazefile);
  init_mazedata(mazedata);
  write(mazefile,mazedata);
  close(mazefile);
 end;

 repeat

  {update player location, if necessary}
  if onliner.location<>onloc_deathmaze then begin
   refresh:=true;
   onliner.location :=onloc_deathmaze;
   onliner.doing    :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  {monster status}
  load_mazedata(mazedata);
  crlf;
  if mazedata.monster_hps>0 then begin
   d(15,'The '+umonc+mazedata.monster_name+uwhite+' is here.');
  end;
  if mazedata.monster_hps<1 then begin
   d(12,'The '+mazedata.monster_name+' is laying in a pool of blood!');
  end
  else if mazedata.monster_hps<mazedata.monster_maxhps then begin
   d(15,'The '+umonc+mazedata.monster_name+uwhite+' is bleeding! Kill it!');
  end
  else begin
   d(15,'The '+umonc+mazedata.monster_name+uwhite+' is in excellent condition.');
  end;

  if (mazedata.monster_state=MonsterActive) and
     (mazedata.monster_hps>0) then begin
   d(15,'The '+umonc+mazedata.monster_name+uwhite+' is aggressive, watch out!');
  end;

  {who is here}
  who_is_here;


  {display menu}
  display_menu(true,true);

  {get user-input}
  cho:=upcase(getchar);

  {evaluate user-input}
  case cho of
   '?':begin {menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'R':begin {return}
        break;
       end;
   'A':begin {attack}
        crlf;
        d(15,'TCHACK!');
        d(15,'You swing at the '+umonc+mazedata.monster_name+uwhite+'!');


        load_mazedata(mazedata);

        if mazedata.monster_hps<1 then begin
         d(15,'There is nothing to attack!');
        end
        else begin

         if random(2)=0 then begin
          d(15,'HIT!');
          {inform other nodes}
          send_to_location(uplc+player.name2+config.textcol1+' hit the '+umonc+mazedata.monster_name+config.textcol1
                           +'!',player.name2);
         end
         else begin
          d(12,'MISS!');
          {inform other nodes}
          send_to_location(uplc+player.name2+config.textcol1+' missed the '+umonc+mazedata.monster_name+config.textcol1
                           +'!',player.name2);
         end;

         dec(mazedata.monster_hps,13);
         mazedata.monster_state:=MonsterActive;
         save_mazedata(mazedata);

         if mazedata.monster_hps<1 then begin
          d(14,'You killed the '+umonc+mazedata.monster_name+uyellow+'!');
          send_to_location(uplc+player.name2+config.textcol1+' killed the '+umonc+mazedata.monster_name+config.textcol1
                           +'!',player.name2);
         end;

        end;

       end;
  end;
 until never; {never leave this loop}

 crlf;
end;
end.
