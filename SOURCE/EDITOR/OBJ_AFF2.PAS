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

Unit Obj_Aff2;

Interface
Uses Init;

Procedure Objekt_Affect ( use ,
                          obj : word;
                          otyp : objtype;
                          var player0 : Userrec );

Implementation

Procedure Objekt_Affect;

var
    oobjekt : objektrec;

begin


 { => ** GL™M INTE ATT ŽNDRA I MOTSVARANDE OBJ AFFECT NU! ** <= }

 case use of
  1:begin
     { Objektet har B™RJAT ANVŽNDAS av player0 }
     if oobjekt.ttype in [food,drink] then begin
      player0.hps:=player0.hps+oobjekt.hps;
      if player0.hps>player0.maxhps then begin
       player0.hps:=player0.maxhps;
      end;
     end
     else begin
      player0.maxhps:=player0.maxhps+oobjekt.hps;
     end;

     player0.stamina:=player0.stamina+oobjekt.stamina;
     player0.agility:=player0.agility+oobjekt.agility;
     player0.charisma:=player0.charisma+oobjekt.charisma;
     player0.dex:=player0.dex+oobjekt.dex;
     player0.wisdom:=player0.wisdom+oobjekt.wisdom;
     player0.maxmana:=player0.maxmana+oobjekt.mana;
     player0.arm:=player0.arm+oobjekt.armor;
     player0.weap:=player0.weap+oobjekt.attack;
     player0.strength:=player0.strength+oobjekt.strength;
     player0.defence:=player0.defence+oobjekt.defence;

     case oobjekt.cure of
      All      : begin
                  player0.blind:=false;
                  player0.plague:=false;
                  player0.smallpox:=false;
                  player0.measles:=false;
                  player0.leprosy:=false;
                 end;
      Blindness:begin
                 player0.blind:=false;
                end;
         Plague:begin
                 player0.plague:=false;
                end;
       Smallpox:begin
                 player0.smallpox:=false;
                end;
        Measles:begin
                 player0.measles:=false;
                end;
        Leprosy:begin
                 player0.leprosy:=false;
                end;
     end;
    end;
  2:begin
     { Objektet har SLUTAT ANVŽNDAS av player0 }
     player0.maxhps:=player0.maxhps-oobjekt.hps;
     player0.stamina:=player0.stamina-oobjekt.stamina;
     player0.agility:=player0.agility-oobjekt.agility;
     player0.charisma:=player0.charisma-oobjekt.charisma;
     player0.dex:=player0.dex-oobjekt.dex;
     player0.wisdom:=player0.wisdom-oobjekt.wisdom;
     player0.maxmana:=player0.maxmana-oobjekt.mana;
     player0.arm:=player0.arm-oobjekt.armor;
     player0.weap:=player0.weap-oobjekt.attack;
     player0.strength:=player0.strength-oobjekt.strength;
     player0.defence:=player0.defence-oobjekt.defence;
    end;
 end;

end;
end.
