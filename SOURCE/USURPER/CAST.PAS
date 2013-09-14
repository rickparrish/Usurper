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
Unit Cast; {Usurper - Cast a Spell *this code should be rewritten*}

Interface

Uses Init;

Procedure Cast_Spell( fastgame : boolean;
                      mode  : integer;  {1=casting, >1 checking active spells}
                                        {mode is also targeted monster #}
                      place : byte;     {place=1 = Dungeons
                                               2 = Player vs Player}

                      var temp1 : UserRec;
                      var temp2 : UserRec;
                      imp : boolean;
                      var mon : byte); {pointing to online comfile}
                                       {only important if online duel is going on}

Implementation

Uses Jakob, Spellsu, Various,
     Various2, File_Io;

Procedure Put_Out(imp : boolean; m1,m2,m3 : s70);
var
    i : byte;

    bye : boolean;

    me : array[1..3] of s70;

    commy : comrec;

begin

 if imp=true then i:=2
             else i:=1;


 me[1]:=m1;
 me[2]:=m2;
 me[3]:=m3;

 if f_exists(onliner.comfile) then begin
  loadsave_com(Fload,Commy,i,'');

  commy.mess[1]:=me[1];
  commy.mess[2]:=me[2];

  LoadSave_Com(FSave,Commy,i,'');

 end;


end; {put_out *end*}

Procedure Cast_Spell;

const no_effect = -1; {magic_res is set to this value if no
                       affect on monster}
      yo1 = 'you';
      yo2 = 'your';

label
 spell_check;

var
    cho : char;

    def,
    newmon,
    the_choice : byte;

    online, use, cost : boolean;

    magic_res : array[1..global_maxmon] of integer;

    x, yy,
    cr, i, ii : integer;

    rad : longint;

    foe,
    att,
    cm1,
    cm2,
    spell_menu : s70;

    mon2,
    damage : longint;


Procedure Do_the_Damage;
var i : integer;
begin

 if (fastgame=false) or (foe=yo1) then begin
  if (magic_res[mon]<>no_effect) or (place=2) then begin
   if (spell_multi(temp1.class,ii)=false) or (place=2) then begin
    case random(2) of
     0:begin
        sd(global_moncol,foe);
        d(config.textcolor,cm1);
       end;
     1:begin
        sd(global_moncol,foe);
        d(config.textcolor,cm1);
       end;
    end;
   end;
  end;
 end;

 case place of
  1:begin
     if spell_multi(temp1.class,ii)=false then begin
      if magic_res[mon]<>no_effect then begin
       dec(monster[mon]^.hps,damage);
      end;
     end
     else begin
      for i:=1 to global_maxmon do begin
       if (monster_active(i)=true) and (magic_res[i]<>no_effect) then begin
        dec(monster[i]^.hps,damage);
        case random(2) of
         0:begin
            sd(global_moncol,monster[i]^.name);
            d(config.textcolor,cm1);
           end;
         1:begin
            sd(global_moncol,monster[i]^.name);
            d(config.textcolor,cm2);
           end;
        end;

        if monster[i]^.hps<1 then begin
         sd(global_moncol,monster[i]^.name);
         d(12,' is DEAD!');
        end;

       end;
      end;
     end;
    end;
  2:begin
     dec(temp2.hps,damage);
    end;

 end; {case .end.}

end; {Do_the_Damage *end*}

               
               
begin {Cast_Spell *begin*}

 {Computer Controlled Player (temp1) casts a spell against player2 (temp2)
 temp1 versus temp2}

 {is this a ONLINE fight?}

 spell_menu:='Cast spell (A..L, '+config.textcol2+'?'+config.textcol1+'=list, Enter=abort) :';

 if place=2 then mon:=1;

 online:=false;
 if onliner.comfile<>'' then begin
  if f_exists(onliner.comfile)=true then begin
   online:=true;
  end;
 end;

 {oops! bad programming! a GOTO - almost BASIC again :( sorry for this!}
 if mode>1 then goto spell_check;

 att:=temp1.name2;
 if (temp1.name2=player.name2) and (global_maintrunning=false) then att:=yo2;
 foe:=temp2.name2;
 if (temp2.name2=player.name2) and (global_maintrunning=false) then foe:=yo1;

 cho:=ReturnKey;

 {is caster an online player?}

 if (temp1.name2=player.name2) and (global_maintrunning=false) then begin
  temp1.casted:=false;

  {dungeon}
  if place=1 then begin
   mon:=1;
   cr:=0;
   {have to check if there are more targets in dungeon}
   for ii:=1 to global_maxmon do begin
    if monster_active(ii) then begin
     inc(cr);
     x:=ii;
    end;
   end; {for ii:= .end.}

   {more than 1 monsters active, user must pick target}
   if cr>1 then begin
    mon:=target_monster; { target is a function}
    foe:=monster[mon]^.name;
   end
   else begin
    foe:=monster[x]^.name; {changed 1995-03-20}
   end;

  end;

  sd(config.textcolor,spell_menu);
  repeat

   cho:=upcase(getchar);

   use:=false;
   cost:=false;
   the_choice:=0;

   case cho of
    '?':begin
         crlf;
         list_of_spells(temp1,false);
         crlf;
         sd(config.textcolor,spell_menu);
        end;
    'A': the_choice:=1;
    'B': the_choice:=2;
    'C': the_choice:=3;
    'D': the_choice:=4;
    'E': the_choice:=5;
    'F': the_choice:=6;
    'G': the_choice:=7;
    'H': the_choice:=8;
    'I': the_choice:=9;
    'J': the_choice:=10;
    'K': the_choice:=11;
    'L': the_choice:=12;
   end; {case .end.}


   if the_choice>0 then begin
    if player.spell[the_choice,2]=true then use:=true;
    if (player.spell[the_choice,1]=true) and
       (player.mana<spell_cost(player.class,the_choice)) then begin
        cost:=true;
    end;

    if use=true then begin
     d(config.textcolor,'Spell already active!');
     sd(config.textcolor,spell_menu);
    end
    else if (cost=true) and (use=false) then begin
     crlf;
     d(12,'Not enough mana!');
     sd(config.textcolor,spell_menu);
    end
    else begin
     if player.spell[the_choice,1]=true then begin
      sd(14,spell_name(player.class,the_choice));
      break;
     end;
    end;
   end;

  until cho=ReturnKey;

  temp2.castin:=cho;
  crlf;

 end
 else begin

  {if computer player meets monsters, target must be selected now!}
  if place=1 then begin
   for i:=1 to global_maxmon do begin
    if monster_active(i)=true then begin
     mon:=i;
     foe:=monster[mon]^.name;
     break;
    end;
   end; {for i:= .end.}
  end;

  {caster is a computer player, checking possibilities to cast spell.}
  for i := 12 downto 1 do
   if (temp1.spell[i,1]=true) and (temp1.spell[i,2]=false) and
    (temp1.mana>=spell_cost(temp1.class,i)) and (random(2)=0) then begin
   cho:=chr(ord('A')+i-1);
   break;
  end;
end;
 if cho<>ReturnKey then begin
  temp1.casted:=true;
 end;

 {checking monsters magic resistance, setting their chances to avoid
  the spell attack}
 for i:=1 to global_maxmon do begin
  magic_res[i]:=no_effect;
 end;

 if place=1 then begin
  for i:=1 to global_maxmon do begin
   magic_res[i]:=no_effect;
   if monster_active(i)=true then begin
    case monster[i]^.magicres of
     1..10  : magic_res[i]:=20;
     11..20 : magic_res[i]:=18;
     21..30 : magic_res[i]:=16;
     31..40 : magic_res[i]:=14;
     41..50 : magic_res[i]:=12;
     51..60 : magic_res[i]:=10;
     61..70 : magic_res[i]:=8;
     71..80 : magic_res[i]:=6;
     81..90 : magic_res[i]:=4;
     91..100: magic_res[i]:=2;
    end;
   end;
  end; {for i:= .end.}
 end;

 if cho=ReturnKey then begin
  exit;
 end;

 case cho of
  'A': ii:=1;
  'B': ii:=2;
  'C': ii:=3;
  'D': ii:=4;
  'E': ii:=5;
  'F': ii:=6;
  'G': ii:=7;
  'H': ii:=8;
  'I': ii:=9;
  'J': ii:=10;
  'K': ii:=11;
  'L': ii:=12;
  
 end; {case .end.}
 if (fastgame=false) and (att<>yo2) then begin
  sd(global_plycol,temp1.name2);
  sd(config.textcolor,' utters ');
  d(global_talkcol,spell_utter(temp1.class,ii));
 end
 else if fastgame=false then begin
  d(global_talkcol,spell_utter(temp1.class,ii));
 end;

 dec(temp1.mana,spell_cost(temp1.class,ii));

 {the spell can be a multi target spell!}
 if place=1 then begin
  for i:=1 to global_maxmon do begin
   if monster_active(i)=true then begin
    if magic_res[i]<>no_effect then begin
     if random(magic_res[i])=0 then begin
      magic_res[i]:=no_effect;
      sd(13,'The spell doesn''t affect ');
      sd(global_moncol,monster[i]^.name);
      d(13,'!');
     end;
    end;
   end;
  end;
 end
 else begin   {online battles & player vs player NEVER gives magic_res>0 !
               fix!}
  if magic_res[mon]<>no_effect then begin
   if random(magic_res[mon])=0 then begin
    magic_res[mon]:=no_effect;
    d(13,'The spell doesn''t affect '+uplc+foe+config.textcol1+'!');
    if online then begin
     put_out(imp,'The spell doesn''t affect '+uplc+foe+config.textcol1+'!',
             '',
             '');
    end;
    exit;
   end;
  end;
 end;


 {Spell # II has been casted!}
 case ii of

  1:begin {***** LEVEL 1 SPELLS *****}
     case temp1.class of
      Cleric:begin

              inc(temp1.hps,4);
              inc(temp1.hps,random(3));

              if temp1.hps>temp1.maxhps then temp1.hps:=temp1.maxhps;

              if (att=player.name2) and (fastgame=false) then begin
               d(config.textcolor,'You regain some hitpoints!');
              end;

              if online then begin
               put_out(imp,uplc+foe+config.textcol1+' is surrounded by a magical aura!',
                           uplc+foe+config.textcol1+' cast a HEAL spell!',
                           '');
              end;
             end;

      Magician:begin
                damage:=4+random(3);

                cm1:=' staggers under the impact from '+uplc+att+'s'+config.textcol1+' missiles!';
                cm2:=' is hit by several magic arrows!';

                do_the_damage;

                if online then begin
                 put_out(imp,'You stagger under the impact from '+uplc+foe+config.textcol1+' missiles!',
                             'You lose '+uwhite+commastr(damage)+config.textcol1+' hitpoints.',
                             '');
                end;

               end;

     Sage:begin
           if (fastgame=false) or (foe=yo1) then begin
            if (place=2) or (magic_res[mon]<>no_effect) then begin
             d(config.textcolor,uplc+foe+config.textcol1+' seems to be blinded!');
             temp1.spell[ii,2]:=true;
            end;
           end;

           if online then begin
            if magic_res[mon]<>no_effect then begin
             put_out(imp,'You can''t see!',
             '',
             '');
             temp1.spell[ii,2]:=true;
            end
            else begin
             put_out(imp,'A BLIND Spell failed against You!','','');
            end;
           end;

          end;

    end;
    end;

  2:begin {***** LEVEL 2 SPELLS *****}
     case temp1.class of
      Cleric:begin
              temp1.spell[2,2]:=true;
              if (att=player.name2) and (fastgame=false) then begin
               d(4,'You feel protected!');
               temp1.spell[ii,2]:=true;
              end;
              if online then begin
               put_out(imp,uplc+foe+config.textcol1+' has been blessed!','','');
              end;
             end;

      Magician:begin
                temp1.spell[2,2]:=true;
                if (att=player.name2) and (fastgame=false) then begin
                 d(4,'You feel an aura of steel around you!');
                 temp1.spell[ii,2]:=true;
                end;
                if online then begin
                 put_out(imp,uplc+foe+config.textcol1+' is surrounded by a steel aura!','','');
                end;
               end;

     Sage:begin
           if (fastgame=false) or (foe=yo1) then begin
            if (place=2) or (magic_res[mon]<>no_effect) then begin
             d(4,uplc+foe+ured+' seems to be poisoned!');
            end;
           end;

           case place of
            1: monster[mon]^.poisoned:=true;
            2: temp2.gnollp:=1;
           end;

           if online then begin
            if magic_res[mon]<>no_effect then begin
             put_out(imp,'You have been poisoned!','','');
            end
            else begin
             put_out(imp,'A POISON spell failed against You!','','');
            end;
           end;

          end;
     end;
     end;

  3:begin {***** LEVEL 3 SPELLS *****}
     case temp1.class of
      Cleric:begin
              if (fastgame=false) or (foe=yo1) then begin
               if (place=2) or (magic_res[mon]<>no_effect) then begin
                d(config.textcolor,foe+' suddenly freezes!');
                temp1.spell[ii,2]:=true;
               end;
              end;

              if online then begin
               if magic_res[mon]<>no_effect then begin
                put_out(imp,'You have been frozen by '+foe+'s magic!','','');
               end
               else begin
                put_out(imp,uplc+foe+config.textcol1+' tried to FREEZE you with magic!','','');
               end;
              end;

             end;

      Magician:begin
                if (fastgame=false) or (foe=yo1) then begin
                 if (place=2) or (magic_res[mon]<>no_effect) then begin
                  d(config.textcolor,uplc+foe+config.textcol1+' suddenly goes to sleep!');
                  temp1.spell[ii,2]:=true;
                 end;
                end;
                if online then begin
                 if magic_res[mon]<>no_effect then begin
                  put_out(imp,'You feel very sleepy...!','','');
                 end
                 else begin
                  put_out(imp,'A SLEEP spell failed against you!','','');
                 end;
                end;
               end;

     Sage:begin
           if (fastgame=false) or (foe=yo1) then begin
            if (place=2) or (magic_res[mon]<>no_effect) then begin
             d(config.textcolor,uplc+foe+config.textcol1+' suddenly freezes!');
             temp1.spell[ii,2]:=true;
            end;
           end;

           if online then begin
            if magic_res[mon]<>no_effect then begin
             put_out(imp,'You can''t move!','','');
            end
            else begin
             put_out(imp,'A FREEZE spell failed against you!','','');
            end;
           end;
          end;
     end;
     end;

  4:begin {***** LEVEL 4 SPELLS *****}
     case temp1.class of
      Cleric:begin
              if (att=player.name2) and (fastgame=false) then begin
               d(4,'You feel stronger!');
              end;

              inc(temp1.hps,20);
              inc(temp1.hps,random(5));
              if temp1.hps>temp1.maxhps then begin
               temp1.hps:=temp1.maxhps;
              end;

              if temp1.dark>0 then begin
               dec(temp1.dark,15);
               if temp1.dark<0 then temp1.dark:=0;
              end
              else begin
               inc(temp1.chiv,15);
              end;

              if online then begin
               put_out(imp,uplc+foe+config.textcol1+' cast a HEAL spell!!','','');
              end;
             end;

      Magician:begin
                if (fastgame=false) or (foe=yo1) then begin
                 if (place=2) or (magic_res[mon]<>no_effect) then begin
                  d(config.textcolor,'A Magic Web suddenly surrounds '+uplc+foe+config.textcol1+'!');
                  temp1.spell[ii,2]:=true;
                 end;
                end;

                if online then begin
                 if magic_res[mon]<>no_effect then begin
                  put_out(imp,'You are caught in a Magic Web!','','');
                 end
                 else begin
                  put_out(imp,uplc+foe+config.textcol1+' tried to catch you in a Magic Web!','','');
                 end;
                end;
               end;

     Sage:begin

           if (fastgame=false) or (foe=yo1) then begin
            sd(config.textcolor,'A '+uplc+'duplicate'+config.textcol1+' of ');
            sd(global_plycol,att);
            d(config.textcolor,' suddenly arrives!');
           end;

           dec(temp1.hps,25);
           temp1.spell[ii,2]:=true;

           if online then begin
            put_out(imp,'A '+uplc+'duplicate'+config.textcol1+' of '+uplc+foe+config.textcol1+' suddenly arrives!','','');
           end;
          end;
     end;
     end;

  5:begin {***** LEVEL 5 SPELLS *****}
     case temp1.class of
      Cleric:begin
         if place=1 then begin
          if monster[mon]^.disease=true then begin
           for i:=1 to global_maxmon do begin
            foe:='';
            if (monster_active(i)=true) and (monster[i]^.disease=false) then begin
             monster[i]^.disease:=true;
             foe:=monster[i]^.name;
             break;
            end;
           end; {for i:= .end.}
          end
          else begin
           monster[mon]^.disease:=true;
          end;
         end;
         if place=2 then begin
          def:=0;
          if temp2.disres>10 then inc(def);
          if temp2.disres>30 then inc(def);
          if temp2.disres>60 then inc(def);
          if temp2.disres>100 then inc(def);
          if temp2.disres>150 then inc(def);
          if temp2.disres>240 then inc(def);

          if random(def)=0 then begin
           rad:=random(5);
           if rad=0 then temp2.blind:=true;
           if rad=1 then temp2.plague:=true;
           if rad=2 then temp2.smallpox:=true;
           if rad=3 then temp2.measles:=true;
           if rad=4 then temp2.leprosy:=true;
           def:=0;
          end
          else begin
           def:=99;
          end;

         end;
         if (fastgame=false) or (foe=yo1) then begin
          if def=0 then begin
           d(config.textcolor,'A disease struck '+uplc+foe+config.textcol1+'!');
          end
          else begin
           d(config.textcolor,uplc+foe+config.textcol1+' resisted the Disease spell!');
          end;
         end;

         if online then begin
          if def=0 then begin
           put_out(imp,'You are struck by a disease!','','');
          end
          else begin
           put_out(imp,'You resisted a Disease spell!','','');
          end;
         end;

        end;

      Magician:begin
                inc(temp1.hps,60);
                inc(temp1.hps,random(20));

                if temp1.hps>temp1.maxhps then begin
                 temp1.hps:=temp1.maxhps;
                end;
                if (att=player.name2) and (fastgame=false) then begin
                 d(config.textcolor,'You regain some hitpoints!');
                end;
                temp1.spell[ii,2]:=true;

                if online then begin
                 put_out(imp,uplc+foe+config.textcol1+' cast a HEAL spell!','','');
                end;

               end;

     Sage:begin
           damage:=50+random(15);

           cm1:=' screams under a beam of incoming fire!';
           cm2:=' is struck by hellfire!';

           do_the_damage;

           if online then begin
            put_out(imp,'You are struck by a beam of hellfire!',
                        'You lose '+uwhite+commastr(damage)+config.textcol1+' hitpoints.',
                        '');
           end;
          end;
     end;
     end;

  6:begin {***** LEVEL 6 SPELLS *****}
     case temp1.class of
      Cleric:begin

              damage:=20+random(11);

              cm1:=' screams in pain as the detonation goes off!';
              cm2:=' is hurt by the barrage of magic darts!';

              do_the_damage;

              if online then begin
               put_out(imp,'A magic bomb goes off right in your face!',
                           'You lose '+commastr(damage)+' hitpoints.',
                           '');
              end;
        end;

      Magician:begin

                damage:=60+random(11);

                cm1:=' is hit by a Fireball!';
                cm2:=' is engulfed by a Fireball!';

                do_the_damage;

                if online then begin
                 put_out(imp,'You scream in horror as you are caught in a Fireball!',
                             'You lose '+commastr(damage)+' hitpoints.',
                             '');
                end;
               end;

     Sage:begin

           damage:=70+random(11);

           cm1:=' starts to hurt himself!';
           cm2:=' is filled with agony, and tries to commit suicide!';

           do_the_damage;

           if online then begin
            put_out(imp,'Some strange force makes you hit yourself!!',
                        'You lose '+commastr(damage)+' hitpoints.',
                        '');
           end;
          end;
     end;
     end;

  7:begin {***** LEVEL 7 SPELLS *****}
     case temp1.class of
      Cleric:begin

              if (fastgame=false) or (foe=yo1) then begin
               d(config.textcolor,uplc+att+config.textcol1+' disappears out of sight!');
              end;
              temp1.spell[ii,2]:=true;

              if online then begin
               put_out(imp,uplc+foe+config.textcol1+' suddenly disappears out of sight!',
               '','');
              end;

             end;

      Magician:begin
                if (fastgame=false) or (foe=yo1) then begin
                 if (place=2) or (magic_res[mon]<>no_effect) then begin
                  d(config.textcolor,uplc+foe+config.textcol1+' screams in fear from '+uplc+att+config.textcol1+' presence!');
                  temp1.spell[ii,2]:=true;
                 end;
                end;

                if online then begin
                 if magic_res[mon]<>no_effect then begin
                  put_out(imp,uplc+foe+config.textcol1+' suddenly scare the living daylights out of you!','','');
                 end
                 else begin
                  put_out(imp,uplc+foe+config.textcol1+' tried a FEAR spell against you, but failed!','','');
                 end;
                end;
               end;

     Sage:begin
           if (fastgame=false) or (foe=yo1) then begin
            if (place=2) or (magic_res[mon]<>no_effect) then begin
             d(config.textcolor,uplc+foe+config.textcol1+' kindly asks '+uplc+att+config.textcol1+' to stop the fight!');
             temp1.spell[ii,2]:=true;
            end;
           end;

           if online then begin
            if magic_res[mon]<>no_effect then begin
             put_out(imp,uplc+foe+config.textcol1+' is trying to force you to surrender! Mind Struggle!','','');
            end
            else begin
             put_out(imp,uplc+foe+config.textcol1+' tried a MIND BOGGLE SPELL against you, but failed!','','');
            end;
           end;
          end;
     end;
     end;


  8:begin {***** LEVEL 8 SPELLS *****}
     case temp1.class of
      Cleric:begin
              if (fastgame=false) or (foe=yo1) then begin
               d(config.textcolor,'An Angel suddenly arrives!');
              end;
              temp1.spell[ii,2]:=true;

              if online then begin
               put_out(imp,'An Angel suddenly arrives! It is huge with golden wings.','','');
              end;

             end;

      Magician:begin
                damage:=60+random(10);

                cm1:=' is hit by a Lightning Bolt!';
                cm2:=' is struck by Lightning!';

                do_the_damage;

                if online then begin
                 put_out(imp,'You are struck by a Lightning Bolt!',
                             'You lose '+commastr(damage)+' hitpoints.','');
                end;
               end;

     Sage:begin
           if (fastgame=false) or (foe=yo1) then begin
            d(config.textcolor,uplc+att+config.textcol1+' suddenly transforms into a GIANT!');
           end;
           temp1.spell[ii,2]:=true;

           if online then begin
            put_out(imp,uplc+foe+config.textcol1+' suddenly transforms into a GIANT!','','');
           end;

          end;
     end;
     end;

  9:begin  {***** LEVEL 9 SPELLS *****}
     case temp1.class of
      Cleric:begin

              damage:=80+random(10);

              cm1:=' is hit by a Lightning Bolt!';
              cm2:=' is struck by Lightning!';

              do_the_damage;

              if online then begin
               put_out(imp,'Lightning strikes you from above!',
                           'You lose '+commastr(damage)+' hitpoints.','');
              end;

             end;

      Magician:begin
                if (fastgame=false) or (foe=yo1) then begin
                 if (place=2) or (magic_res[mon]<>no_effect) then begin
                  d(config.textcolor,'A Magic Cage suddenly lowers over '+uplc+foe+config.textcol1+'!');
                  temp1.spell[ii,2]:=true;
                 end;
                end;

                if online then begin
                 if magic_res[mon]<>no_effect then begin
                  put_out(imp,'A Magic Cage suddenly lowerws over You! Trapped!','','');
                 end
                 else begin
                  put_out(imp,'A Magic Cage failed to imprison you!','','');
                 end;
                end;
               end;

     Sage:begin
           if place=1 then rad:=random(10000);
           if place=2 then begin
            rad:=temp2.level*9504;
            if temp2.gold<rad then rad:=temp2.gold;
            decplayermoney(temp2,rad);
           end;

           if (fastgame=false) or (foe=yo1) then begin
            d(config.textcolor,uplc+att+config.textcol1+' manages to steal '+uyellow+commastr(rad)+config.textcol1
              +' '+many_money(rad)+' from '+uplc+foe+config.textcol1+'!');
           end;


           IncPlayerMoney(temp1,rad);

           if online then begin
            put_out(imp,uplc+foe+' managed to steal '+uyellow+commastr(rad)+config.textcol1+' '+many_money(rad)
            +' from you!','','');
           end;

          end;
     end;
     end;

 10:begin  {***** LEVEL 10 SPELLS *****}
     case temp1.class of
      Cleric:begin
              inc(temp1.hps,200);
              if temp1.hps>temp1.maxhps then temp1.hps:=temp1.maxhps;
              if (att=player.name2) and (fastgame=false) then begin
               d(4,'You regain some hitpoints!');
              end;
              if online then begin
               put_out(imp,uplc+foe+config.textcol1+' seems to grow bigger....or is it just your imagination?','','');
              end;
             end;

      Magician:begin
                damage:=100+random(12);

                cm1:=' is severely burned in a Wall of fire!';
                cm2:=' is engulfed in flames!';

                do_the_damage;

                if online then begin
                 put_out(imp,'You are severely burned in a Wall of Fire!',
                             'You lose '+uwhite+commastr(damage)+config.textcol1+' hitpoints.','');
                end;

               end;

     Sage:begin
           damage:=130+random(11);

           cm1:=' energy is drained!';
           cm2:=' vitality is drained!';

           do_the_damage;

           if online then begin
            put_out(imp,uplc+foe+config.textcol1+' is draining your energy!',
                            'You lose '+uwhite+commastr(damage)+config.textcol1+' hitpoints.','');
           end;

          end;
     end;
     end;

 11:begin  {***** LEVEL 11 SPELLS *****}
     case temp1.class of
      Cleric:begin
              if (att=player.name2) and (fastgame=false) then begin
               d(config.textcolor,'You feel protected!');
              end;
              temp1.spell[ii,2]:=true;
             end;

      Magician:begin
                damage:=220+random(45);

                cm1:=' suffers from the KISS OF DEATH!';
                cm2:=' is touched by the LIPS OF DEATH!';

                do_the_damage;

                if online then begin
                 put_out(imp,uplc+foe+config.textcol1+' makes you suffer from the LIPS OF DEATH!',
                                 'You lose '+uwhite+commastr(damage)+config.textcol1+' hitpoints.','');
                end;

               end;

     Sage:begin
           if (fastgame=false) or (foe=yo1) then begin
            d(config.textcolor,'A '+umonc+'Demon'+config.textcol1+' suddenly appears!');
           end;
           temp1.spell[ii,2]:=true;
           if online then begin
            put_out(imp,'A '+umonc+'Demon'+config.textcol1+' suddenly appears!','','');
           end;
          end;
     end;
     end;

 12:begin  {***** LEVEL 12 SPELLS *****}
     case temp1.class of
      Cleric:begin
              damage:=220+random(31);

              cm1:=' is hit by a Divine Lightning Bolt!';
              cm2:=' is hit by a Holy Lightning Bolt!';

              do_the_damage;

              if online then begin
               put_out(imp,'A Divine Lightning bolt hits you! (OUCH!)',
                           'You lose '+commastr(damage)+' hitpoints.','');
              end;

             end;

      Magician:begin
                if (fastgame=false) or (foe=yo1) then begin
                 d(config.textcolor,'A Demon suddenly appears!');
                end;
                temp1.spell[ii,2]:=true;
                if online then begin
                 put_out(imp,'A Demon suddenly appears!','','');
                end;
               end;

     Sage:begin
           damage:=240+random(50);

           cm1:=' staggers under the Force of Death!';
           cm2:=' is struggling with the Force of Death!';

           do_the_damage;

           if online then begin
            put_out(imp,'You struggle against the Force of Death!',
                        'You lose '+commastr(damage)+' hitpoints.','');
           end;

        end;
     end;
     end;

 end; {case .end.}

 exit;


 {
 *****************************************
    checking / executing duration spells
 *****************************************
 }

 {a label. called by GOTO statement earlier}
 Spell_Check:

 {deduct for Player spells}

 att:=temp1.name2;
 foe:=temp2.name2;

 if temp2.name2=player.name2 then begin
  foe:=yo1;
 end;

 mon2:=mode-9999;

 {1}
 if (temp1.class=Sage) and (temp1.spell[1,1]=true) and (temp1.spell[1,2]=true) then begin
  inc(temp1.absorb,3);
 end;

 {2}
 if (temp1.class=Cleric) and (temp1.spell[2,1]=true) and (temp1.spell[2,2]=true) then begin
  inc(temp1.absorb,5);
 end;

 if (temp1.class=Magician) and (temp1.spell[2,1]=true) and (temp1.spell[2,2]=true) then begin
  inc(temp1.absorb,4);
 end;


 {3}
 if (temp1.class=Cleric) and (temp1.spell[3,1]=true) and (temp1.spell[3,2]=true) then begin
  if random(2)=0 then begin
   temp1.spell[3,2]:=false;
  end;

  if place=2 then begin
   temp2.punch:=0;
  end
  else begin
   monster[mon2]^.punch:=0;
  end;
 end;

 if (temp1.class=Magician) and (temp1.spell[3,1]=true) and (temp1.spell[3,2]=true) then begin
  if random(2)=0 then begin
   temp1.spell[3,2]:=false;
  end;

  if place=2 then begin
   temp2.punch:=0;
  end
  else begin
   monster[mon2]^.punch:=0;
  end;
 end;

 if (temp1.class=Sage) and (temp1.spell[3,1]=true) and (temp1.spell[3,2]=true) then begin
  temp1.spell[3,2]:=false;
  if place=2 then begin
   temp2.punch:=0;
  end
  else begin
   monster[mon2]^.punch:=0;
  end;
 end;

 {4}
 if (temp1.class=Magician) and (temp1.spell[4,1]=true) and (temp1.spell[4,2]=true) then begin
  temp1.spell[4,2]:=false;
  if place=2 then begin
   temp2.punch:=0;
  end
  else begin
   monster[mon2]^.punch:=0;
  end;
 end;

 if (temp1.class=Sage) and (temp1.spell[4,1]=true) and (temp1.spell[4,2]=true) then begin
  if place=2 then begin
   if fastgame=false then begin
    d(config.textcolor,att+' '+uplc+'Duplicate'+config.textcol1+' hits '+foe+'!');
   end;
   dec(temp2.hps,temp1.punch);
  end
  else begin

   {player versus monster}
   {is monster active?}
   newmon:=0;
   if monster_active(mon2)=true then begin
    newmon:=mon2;
   end
   else begin
    for i:=1 to global_maxmon do begin
     if monster_active(i) then begin
      newmon:=i;
      break;
     end;
    end; {for i:= .end.}
   end;

   if newmon>0 then begin

    if fastgame=false then begin
     d(config.textcolor,att+' '+uplc+'Duplicate'+config.textcol1+' hits '+umonc+monster[newmon]^.name+config.textcol1+'!');
    end;
    dec(monster[newmon]^.hps,player.punch);
   end;

  end;

 end;

 {5}
 if (temp1.class=Magician) and (temp1.spell[5,1]=true) and (temp1.spell[5,2]=true) then begin
  inc(temp1.absorb,(random(10)+3));
 end;

 {6}

 {7}
 if (temp1.class=Cleric) and (temp1.spell[7,1]=true) and (temp1.spell[7,2]=true) then begin
  inc(temp1.absorb,(random(15)+11));
 end;

 if (temp1.class=Magician) and (temp1.spell[7,1]=true) and (temp1.spell[7,2]=true) then begin
  {fear spell}
  if place=2 then temp2.punch:=0
             else monster[mon2]^.punch:=0;
 end;

 if (temp1.class=Sage) and (temp1.spell[7,1]=true) and (temp1.spell[7,2]=true) then begin
  if place=2 then begin
   temp2.punch:=0;
  end
  else begin
   monster[mon2]^.punch:=0;
  end;
 end;

 {8}
 if (temp1.class=Cleric) and (temp1.spell[8,1]=true) and (temp1.spell[8,2]=true) then begin
  if place=2 then begin
   if fastgame=false then begin
    d(config.textcolor,'The Angel hits '+uplc+foe+config.textcol1+' hard!');
   end;
   dec(temp2.hps,100);
  end
  else begin
   {player versus monster}
   {is monster active?}
   newmon:=0;
   if monster_active(mon2)=true then begin
    newmon:=mon2;
   end
   else begin
    for i:=1 to global_maxmon do begin
     if monster_active(i) then begin
      newmon:=i;
      break;
     end;
    end; {for i:= .end.}
   end;

   if newmon>0 then begin

    if fastgame=false then begin
     d(global_plycol,'The Angel'+config.textcol1+' hits '+umonc+monster[newmon]^.name+config.textcol1+' hard!');
    end;
    dec(monster[newmon]^.hps,100);
   end;

  end;
 end;

 if (temp1.class=Sage) and (temp1.spell[8,1]=true) and (temp1.spell[8,2]=true) then begin
  if fastgame=false then begin
   d(config.textcolor,uplc+att+'s'+config.textcol1+' Transformation protects '+sex[temp1.sex]+'!');
  end;
  if place = 2 then dec(temp2.hps,10);
  inc(temp1.absorb,50);
 end;

 {9}
 if (temp1.class=Magician) and (temp1.spell[9,1]=true) and (temp1.spell[9,2]=true) then begin
  temp1.spell[9,2]:=false;
  inc(temp1.absorb,20);
 end;

 {10}

 {11}
 if (temp1.class=Cleric) and (temp1.spell[11,1]=true) and (temp1.spell[11,2]=true) then begin
  if place=2 then begin
   if random(3)=0 then begin
    if temp1.chiv<30000 then begin
     inc(temp1.chiv,50);
    end;
    if temp1.dark>0 then begin
     dec(temp1.dark,50);
    end;
    temp1.spell[11,2]:=false;
   end;
   if temp1.dark<0 then begin
    temp1.dark:=0;
   end;
   dec(temp2.punch,110);
   if temp2.punch<0 then temp2.punch:=0;

  end
  else begin
   player.spell[11,2]:=false;
   inc(player.chiv,50);
   dec(player.dark,50);
   if player.dark<0 then player.dark:=0;
   dec(monster[mon2]^.punch,110);
   if monster[mon2]^.punch<0 then monster[mon2]^.punch:=0;
  end;
 end;

 if (temp1.class=Sage) and
    (temp1.spell[11,1]=true) and
    (temp1.spell[11,2]=true) then begin
  if place=2 then begin
   if fastgame=false then begin
    d(global_moncol,'The Demon'+config.textcol1+' claws '+uplc+foe+config.textcol1+' extremely Hard!');
   end;
   dec(temp2.hps,(100+random(21)));
  end
  else begin

   {demon versus monster}

   {is monster active?}
   newmon:=0;
   if monster_active(mon2)=true then begin
    newmon:=mon2;
   end
   else begin
    for i:=1 to global_maxmon do begin
     if monster_active(i) then begin
      newmon:=i;
      break;
     end;
    end; {for i:= .end.}
   end;

  { debug info. discard it if you feel like it. jake was here testing
    the demon spell
   if newmon>0 then begin
    d(15,'Monster # to be clawed:'+commastr(newmon));
    d(15,'Monster to be clawed:'+monster[newmon]^.name);
   end;
  }

   if newmon>0 then begin
    if fastgame=false then begin
     d(global_moncol,'The Demon'+config.textcol1+' claws '+umonc+monster[newmon]^.name+config.textcol1+' extremely hard!');
    end;
    dec(monster[newmon]^.hps,(100+random(21)));
   end;

  end;

 end;

 {12}
 if (temp1.class=Magician) and (temp1.spell[12,1]=true) and (temp1.spell[12,2]=true) then begin

  if place=2 then begin
   if fastgame=false then begin
    d(global_moncol,'The Demon'+config.textcol1+' claws '+uplc+foe+config.textcol1+' extremely Hard!');
   end;
   dec(temp2.hps,(200+random(101)));
  end
  else begin

   {is monster active?}
   newmon:=0;
   if monster_active(mon2)=true then begin
    newmon:=mon;
   end
   else begin
    for i:=1 to global_maxmon do begin
     if monster_active(i) then begin
      newmon:=i;
      break;
     end;
    end; {for i:= .end.}
   end;

   if newmon>0 then begin
    if fastgame=false then begin
     d(global_moncol,'The Demon'+config.textcol1+' claws '+umonc+monster[newmon]^.name+config.textcol1+' extremely Hard!');
    end;
    dec(monster[newmon]^.hps,(200+random(101)));
   end;

  end;
 end;

end; {Cast_Spell *end*}

end. {Unit Cast .end.}
