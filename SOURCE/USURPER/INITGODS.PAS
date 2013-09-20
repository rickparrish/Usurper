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



unit InitGods; {Usurper - God init/structure code}

interface

uses
  Init;

const global_supreme_creator = 'Manwe'; {the boss God}

type   {see vargods.pas => become_god}
  GodRec = record {God record}
    realname:  s30;  {real (user/bbs) name}
    Name:      s30;      {alias}
    id:        s15;      {unique ID tag, this id follows the player from the
                    user file!}
    recnr:     SmallWord;      {rec # in file}
    age:       SmallWord;      {age}
    sex:       byte;      {sex, 1=male, 2=female}
    ai:        char;      {ai: 'H'uman or 'C'omputer }
    level:     SmallWord;      {level}
    exp:       longint;   {experience, power}
    deedsleft: SmallWord; {deedsleft today, new ones given at maintenance}
    deleted:   boolean; {deleted}
    believers: SmallWord;    {believers, disciples, # of players who worship this god}
    darkness:  longint; {good points, follows from the player time}
    goodness:  longint; {dark points, follows from the player time}
  end; {godrec *end*}

var God: GodRec; {used by God in game}

implementation

begin

end. {Unit InitGods .end.}
