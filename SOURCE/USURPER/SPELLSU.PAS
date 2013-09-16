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


Unit SpellsU; {Usurper - Spell Unit, not all of them though :)}
              {"Get the future started!"}

Interface

Uses Init;

Procedure Spell_Description(class:classes ; spell:integer);
Procedure List_of_Spells(var happy:userrec; all:boolean);
Procedure Spell_List(var happy:userrec);
Procedure Reset_Spells (var pl1,pl2,pl3,pl4 : userrec);
Function Level_Needed(class:classes ; spell:byte) : integer;
Function Spell_Cost  (class:classes ; spell:byte) : integer;
Function Spell_Name  (class:classes ; spell:byte) : s70;
Function Spell_Utter (class:classes ; spell:byte) : s70;
Function Spell_Multi (class:classes ; spell:byte) : boolean;
Function Spell_User (const ply:userrec):boolean; {is ply a spell user?}

{Monster Spell}
Function Spell_Name_Monster (nr:integer) : s70;
Function Spell_Cost_Monster (nr:integer) : integer;
Function Spell_Multi_Monster(nr:integer) : boolean;


Implementation

Uses Jakob, Various2;


Function Spell_User (const ply:userrec):boolean; {is ply a spell user?}
var result : boolean;
begin

 if ply.class in [Cleric,Magician,Sage] then result:=true
                                        else result:=false;
 {return result}
 spell_user:=result;

end; {spell_user .end.}

Function Spell_Multi(class : classes ; spell : byte) : boolean;
var x : boolean;
begin

 {is SPELL a multi target one? If set to TRUE the spell will
  be used against a group of monsters, instead of just one.
  Provided that the spell is a attack spell.}

 x:=false;
 case spell of
  1:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
  2:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
  3:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
  4:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
  5:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=true; {wow! multi target spell!}
     end;
    end;
  6:begin
     case class of
      Cleric   : x:=true; {wow! multi target spell!}
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
  7:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
  8:begin
     case class of
      Cleric   : x:=false; 
      Magician : x:=true; {wow! multi target spell!}
      Sage     : x:=false;
     end;
    end;
  9:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
 10:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
 11:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;
 12:begin
     case class of
      Cleric   : x:=false;
      Magician : x:=false;
      Sage     : x:=false;
     end;
    end;

 end; {case .end.}

 {return result}
 spell_multi:=x;

end; {spell_multi *end*}

Function Level_Needed(class:classes ; spell:byte) : integer;
var x : integer;
begin

 {returns player level needed to aquire selected spell}
 x:=0;
 case spell of
  1:begin
     case class of
      Cleric   : x:=1;
      Magician : x:=1;
      Sage     : x:=1;
     end;
    end;
  2:begin
     case class of
      Cleric   : x:=5;
      Magician : x:=5;
      Sage     : x:=5;
     end;
    end;
  3:begin
     case class of
      Cleric   : x:=10;
      Magician : x:=10;
      Sage     : x:=10;
     end;
    end;
  4:begin
     case class of
      Cleric   : x:=15;
      Magician : x:=15;
      Sage     : x:=15;
     end;
    end;
  5:begin
     case class of
      Cleric   : x:=20;
      Magician : x:=20;
      Sage     : x:=20;
     end;
    end;
  6:begin
     case class of
      Cleric   : x:=25;
      Magician : x:=25;
      Sage     : x:=25;
     end;
    end;
  7:begin
     case class of
      Cleric   : x:=30;
      Magician : x:=30;
      Sage     : x:=30;
     end;
    end;
  8:begin
     case class of
      Cleric   : x:=40;
      Magician : x:=40;
      Sage     : x:=40;
     end;
    end;
  9:begin
     case class of
      Cleric   : x:=50;
      Magician : x:=50;
      Sage     : x:=50;
     end;
    end;
 10:begin
     case class of
      Cleric   : x:=60;
      Magician : x:=60;
      Sage     : x:=60;
     end;
    end;
 11:begin
     case class of
      Cleric   : x:=70;
      Magician : x:=70;
      Sage     : x:=70;
     end;
    end;
 12:begin
     case class of
      Cleric   : x:=80;
      Magician : x:=80;
      Sage     : x:=80;
     end;
    end;

 end; {case .end.}

 {return result}
 level_needed:=x;

end; {Level_Needed .end.}

Function Spell_Cost  (class:classes ; spell:byte) : integer;
var x : integer;
begin

 {Returns Spell cost, in mana}

 x:=0;
 case spell of
  1:begin
     case class of
      Cleric   : x:=10;
      Magician : x:=10;
      Sage     : x:=10;
     end;
    end;
  2:begin
     case class of
      Cleric   : x:=20;
      Magician : x:=20;
      Sage     : x:=20;
     end;
    end;
  3:begin
     case class of
      Cleric   : x:=30;
      Magician : x:=30;
      Sage     : x:=30;
     end;
    end;
  4:begin
     case class of
      Cleric   : x:=40;
      Magician : x:=40;
      Sage     : x:=40;
     end;
    end;
  5:begin
     case class of
      Cleric   : x:=50;
      Magician : x:=50;
      Sage     : x:=50;
     end;
    end;
  6:begin
     case class of
      Cleric   : x:=60;
      Magician : x:=60;
      Sage     : x:=60;
     end;
    end;
  7:begin
     case class of
      Cleric   : x:=70;
      Magician : x:=70;
      Sage     : x:=70;
     end;
    end;
  8:begin
     case class of
      Cleric   : x:=80;
      Magician : x:=80;
      Sage     : x:=80;
     end;
    end;
  9:begin
     case class of
      Cleric   : x:=90;
      Magician : x:=90;
      Sage     : x:=90;
     end;
    end;
 10:begin
     case class of
      Cleric   : x:=100;
      Magician : x:=100;
      Sage     : x:=100;
     end;
    end;
 11:begin
     case class of
      Cleric   : x:=110;
      Magician : x:=110;
      Sage     : x:=110;
     end;
    end;
 12:begin
     case class of
      Cleric   : x:=120;
      Magician : x:=120;
      Sage     : x:=120;
     end;
    end;
 end; {case .end.}

 {return result}
 spell_cost:=x;

end; {spell_cost .end.}

Function Spell_Name  (class:classes ; spell:byte) : s70;
var s : s30;
begin {returns NAME of spell for selected magic user}

 {The names of the Spells}
 s:='I love Jakob!';

 case spell of
  1:begin
     case class of
      Cleric   : s:='Cure Light';
      Magician : s:='Magic Missile';
      Sage     : s:='Fog of War';
     end;
    end;
  2:begin
     case class of
      Cleric   : s:='Armor';
      Magician : s:='Shield';
      Sage     : s:='Poison';
     end;
    end;
  3:begin
     case class of
      Cleric   : s:='Baptize Monster';
      Magician : s:='Sleep';
      Sage     : s:='Freeze';
     end;
    end;
  4:begin
     case class of
      Cleric   : s:='Cure Critical';
      Magician : s:='Web';
      Sage     : s:='Duplicate';
     end;
    end;
  5:begin
     case class of
      Cleric   : s:='Disease';
      Magician : s:='Power Hat';
      Sage     : s:='Roast';
     end;
    end;
  6:begin
     case class of
      Cleric   : s:='Holy Explosion';
      Magician : s:='Fireball';
      Sage     : s:='Hit Self';
     end;
    end;
  7:begin
     case class of
      Cleric   : s:='Invisibility';
      Magician : s:='Fear';
      Sage     : s:='Escape';
     end;
    end;
  8:begin
     case class of
      Cleric   : s:='Angel';
      Magician : s:='Lightning Bolt';
      Sage     : s:='Giant';
     end;
    end;
  9:begin
     case class of
      Cleric   : s:='Call Lightning';
      Magician : s:='Prismatic Cage';
      Sage     : s:='Steal';
     end;
    end;
 10:begin
     case class of
      Cleric   : s:='Heal';
      Magician : s:='Pillar of Fire';
      Sage     : s:='Energy Drain';
     end;
    end;
 11:begin
     case class of
      Cleric   : s:='Divination';
      Magician : s:='Power word KILL';
      Sage     : s:='Summon Demon';
     end;
    end;
 12:begin
     case class of
      Cleric   : s:='Gods Finger';
      Magician : s:='Summon Demon';
      Sage     : s:='Death Kiss';
     end;
    end;

 end; {case .end.}

 {return result}
 spell_name:=s;

end; {SPELL_NAME **** END ****}

Function Spell_Utter;
var s : s30;
begin

 {Phrases uttered by SpellCasters}
 s:='I love Jake!';

 case spell of
  1:begin
     case class of
      Cleric   : s:='Abrazak';
      Magician : s:='Zazzaknah';
      Sage     : s:='Umannaghra';
     end;
    end;
  2:begin
     case class of
      Cleric   : s:='Razzxixx';
      Magician : s:='Mokkoshu';
      Sage     : s:='Gonngexha';
     end;
    end;
  3:begin
     case class of
      Cleric   : s:='Ushmanikixz';
      Magician : s:='Sabdrak';
      Sage     : s:='Artizafisch';
     end;
    end;
  4:begin
     case class of
      Cleric   : s:='Garghamangan';
      Magician : s:='Sekaramata';
      Sage     : s:='Ishusabbhes';
     end;
    end;
  5:begin
     case class of
      Cleric   : s:='Meshushattagut';
      Magician : s:='Viloshmazza';
      Sage     : s:='Sheshnaxe';
     end;
    end;
  6:begin
     case class of
      Cleric   : s:='Kazarbah';
      Magician : s:='Zimmokoth';
      Sage     : s:='Xoxxammeuh';
     end;
    end;
  7:begin
     case class of
      Cleric   : s:='Xamientivah';
      Magician : s:='Urpashke';
      Sage     : s:='Reprusu';
     end;
    end;
  8:begin
     case class of
      Cleric   : s:='Bokajinnah';
      Magician : s:='Egribegah';
      Sage     : s:='Setuminahx';
     end;
    end;
  9:begin
     case class of
      Cleric   : s:='Tenibma';
      Magician : s:='Ynoskattarb';
      Sage     : s:='Algesmoxhu';
     end;
    end;
 10:begin
     case class of
      Cleric   : s:='Sondocesah';
      Magician : s:='Aivannaxievh';
      Sage     : s:='Noitarudamin';
     end;
    end;
 11:begin
     case class of
      Cleric   : s:='Swiillixtavh';
      Magician : s:='Gnisuremvenodh';
      Sage     : s:='Attigribinnizsch';
     end;
    end;
 12:begin
     case class of
      Cleric   : s:='Umbarakahstahx';
      Magician : s:='Mattravidduzzievh';
      Sage     : s:='Edujnomed';
     end;
    end;

 end; {case .end.}

 {return result}
 spell_utter:=s;

end; {SPELL_UTTER **** END ****}

Procedure Spell_Description(class:classes; spell:integer);
const m = '  ';
      m1= ' ';
      wh= '*multi target*';
var
    c : byte;
    t : byte;
   whc: byte;
begin

 {Displays text description of selected spell}

 c  :=11; {spell name color}
 t  :=4 ; {description color}
 whc:=10; {'affects whole group' color}

 crlf;

 case spell of
  1:begin {Level I Spells}
     case class of
      Cleric   :begin {Cure Light}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'This spell is good for small wounds only.');
                 d(t,m+'Effect : caster regains 4-7 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Magician :begin {Magic Missile}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'This spell sends a steel arrow towards its target.');
                 d(t,m+'Because of the strong magic involved, few armor can');
                 d(t,m+'resist it.');
                 d(t,m+'Damage : 4-7 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Sage     :begin {Fog of War}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'When casted, a bank of mist lowers over the battle.');
                 d(t,m+'You, the caster, is the only one able to see clear');
                 d(t,m+'through it.');
                 d(t,m+'Protection : +3');
                 d(t,m+'Duration : Whole fight.');
                end;
     end;
    end;
  2:begin {Level II Spells}
     case class of
      Cleric   :begin {Armor}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'An invisible Armor is placed on the caster.');
                 d(t,m+'The armor is resistance to magic and repulses');
                 d(t,m+'a portion of the attack.');
                 d(t,m+'Protection : +5');
                 d(t,m+'Duration : Whole fight.');
                end;
      Magician :begin {Shield}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'The Shield spell is a first class choice for a Magician');
                 d(t,m+'fighting a close battle. An invisible shield appears');
                 d(t,m+'before the caster, blocking a portion of any attack.');
                 d(t,m+'Protection : +4');
                 d(t,m+'Duration : Whole fight.');
                end;
      Sage     :begin {Poison}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Inserts poison into the opponents veins.');
                 d(t,m+'The poison is equivalent to the gnolls natural skill.');
                 d(t,m+'Damage : enemys lvl + 1');
                 d(t,m+'Duration : Whole fight.');
                end;
     end;
    end;
  3:begin {Level III Spells}
     case class of
      Cleric   :begin {Baptize Monster}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Works best on evil monsters, but other players');
                 d(t,m+'can be caught by this spell to. The baptizing');
                 d(t,m+'spell is a mind-controlling process, where the');
                 d(t,m+'opponent comes to a halt for a few turns.');
                 d(t,m+'Damage : enemy freezes');
                 d(t,m+'Duration : random.');
                end;
      Magician :begin {Sleep}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'The body goes to sleep, but the mind does not.');
                 d(t,m+'Effective against any type of monster.');
                 d(t,m+'Damage : enemy freezes');
                 d(t,m+'Duration : random.');
                end;
      Sage     :begin {Freeze}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'The Freeze spell turns the opponent into an');
                 d(t,m+'iced-block, preventing any action from his part');
                 d(t,m+'for one turn.');
                 d(t,m+'Damage : enemy freezes');
                 d(t,m+'Duration : 1 turn.');
                end;
     end;
    end;
  4:begin {Level IV Spells}
     case class of
      Cleric   :begin {Cure Critical}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Heals medium wounds inflicted to its caster.');
                 d(t,m+'Since the spell derives from God, the caster');
                 d(t,m+'also receives a blessing. Thus relieving his');
                 d(t,m+'soul.');
                 d(t,m+'Effect : caster regains 20-24 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Magician :begin {Web}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'This spell causes a magic web to lower over');
                 d(t,m+'its target, making it impossible for it to');
                 d(t,m+'move. Originally being a spell developed by');
                 d(t,m+'a great Sage, this is a bad plagiarism and');
                 d(t,m+'therefore it oftens dissolves after just one');
                 d(t,m+'combat round.');
                 d(t,m+'Damage : enemy freezes');
                 d(t,m+'Duration : 1 turn.');
                end;
      Sage     :begin {Duplicate}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'A very powerful spell, which causes a hologram');
                 d(t,m+'of yourself to arrive. The hologram attacks with');
                 d(t,m+'the same strength as yourself. Thus making this');
                 d(t,m+'spell more powerful the higher levels you reach.');
                 d(t,m+'(note that it costs mana+25 hps to cast this spell)');
                 d(t,m+'Effect : casters regular attack.');
                 d(t,m+'Duration : whole fight.');
                end;
     end;
    end;
  5:begin {Level V Spells}
     case class of
      Cleric   :begin {Disease}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Inflicts a random disease on the target.');
                 d(t,m+'This spell provides a nice way of slowly');
                 d(t,m+'draining an enemys power. Depending on the');
                 d(t,m+'targets resistance to diseases, the spell');
                 d(t,m+'may fail.');
                 d(t,m+'Effect : random disease.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Magician :begin {Power Hat}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'One of few spells possessed by the magicians which');
                 d(t,m+'regenerates hitpoints. This one does it well');
                 d(t,m+'though, causing not only a quick refill of power,');
                 d(t,m+'but also a protection for the rest of the battle.');
                 d(t,m+'Effect : caster regains 60-80 hps.');
                 d(t,m+'Duration : 1 turn (+ 10-13 protection every turn).');
                end;
      Sage     :begin {Roast}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Sends a bolt of fire towards the target.');
                 d(t,m+'Regardless of armor, this stuff penetrates');
                 d(t,m+'everything until it comes down to the bare skin.');
                 d(t,m+'You will certainly get used to the smell of');
                 d(t,m+'burning flesh when using this spell.');
                 d(t,m+'Damage : 50-65 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
     end;
    end;
  6:begin {Level VI Spells}
     case class of
      Cleric   :begin {Holy Explosion}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'A ball of holy energy which will burst into a');
                 d(t,m+'barrage of darts, causing damage and panic');
                 d(t,m+'among your foes.');
                 d(t,m+'Damage : 20-30 hps.');
                 d(t,m+'Duration : 1 turn.');
                 d(whc,m+wh);
                end;
      Magician :begin {Fireball}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'From the Nature of Fire this spell was among the');
                 d(t,m+'first to be sought out and improved.');
                 d(t,m+'The target is swallowed up by this ball of fire.');
                 d(t,m+'Even if it quickly burns out, the impact is great.');
                 d(t,m+'Damage : 60-70 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Sage     :begin {Hit Self}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Mind Bogy spell that goes straight to the targets');
                 d(t,m+'brain (if there is none) and shortcircuits some');
                 d(t,m+'vital nerves. For a brief moment the target loses');
                 d(t,m+'control and tries to commit suicide.');
                 d(t,m+'Damage : 70-80 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
     end;
    end;
  7:begin {Level VII Spells}
     case class of
      Cleric   :begin {Invisibility}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Makes the caster almost invisible to his foes,');
                 d(t,m+'thus making him harder to hit.');
                 d(t,m+'The only problem is that his team members');
                 d(t,m+'sometimes thinks their Cleric partner has ran');
                 d(t,m+'out on them.');
                 d(t,m+'Protection : +15-25.');
                 d(t,m+'Duration : Whole fight.');
                end;
      Magician :begin {Fear}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Incredible powerful spell (when it works).');
                 d(t,m+'It fills your enemy with such a great fear');
                 d(t,m+'that he freezes and does nothing for the rest');
                 d(t,m+'of the fight.');
                 d(t,m+'Effect : enemy freezes.');
                 d(t,m+'Duration : Whole fight.');
                end;
      Sage     :begin {Escape}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'This spell makes your opponent want to run');
                 d(t,m+'away instead of fighting. However, the genius who');
                 d(t,m+'developed the spell saw to it that it was just');
                 d(t,m+'powerful enough to force the targets mind and');
                 d(t,m+'the spell into conflict with each other, thus');
                 d(t,m+'rendering the effect to a stand still.');
                 d(t,m+'Effect : enemy freezes.');
                 d(t,m+'Duration : Whole fight.');
                end;
     end;
    end;
  8:begin {Level VIII Spells}
     case class of
      Cleric   :begin {Angel}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'This spell calls out for one the Lords angels,');
                 d(t,m+'which will come to your rescue. The angel');
                 d(t,m+'that will arrive is not of top class, but');
                 d(t,m+'even so, it can make a great difference when');
                 d(t,m+'it comes to dealing with the evil powers.');
                 d(t,m+'Don''t be evil yourself when you cast this spell!');
                 d(t,m+'Damage : 100 hps.');
                 d(t,m+'Duration : Whole fight.');
                end;
      Magician :begin {Lightning Bolt}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'This spell was stolen from the Clerics guild');
                 d(t,m+'several centuries ago. Still, it makes a great');
                 d(t,m+'impact on any foe, since its not preceded by');
                 d(t,m+'thunder or some other silly warning. It comes');
                 d(t,m+'down on its target silently, causing');
                 d(t,m+'respectable damage and agony.');
                 d(t,m+'Damage : 60-70 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Sage     :begin {GIANT}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Metamorphosis spell. Turns its caster into a');
                 d(t,m+'Giant, armed with a club. Well, this is what');
                 d(t,m+'your opponent(s) will see. Behind the magic');
                 d(t,m+'disguise, this spell just adds to its casters');
                 d(t,m+'attack capabilities. The Giant suit is just for');
                 d(t,m+'showing off, but those magican trash must be');
                 d(t,m+'taught the lesson on who''s the Master Spell Class.');
                 d(t,m+'Effect : +25 damage.');
                 d(t,m+'Duration : whole fight.');
                end;
     end;
    end;
  9:begin {Level IX Spells}
     case class of
      Cleric   :begin {Call Lightning}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Sends a lightning bolt right through the target.');
                 d(t,m+'Much greater effect than the similar spell possessed');
                 d(t,m+'by the magician guild.');
                 d(t,m+'Damage : 80-89 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Magician :begin {Prismatic Cage}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Lowers a magic cage over its caster, thus');
                 d(t,m+'increasing his protection. The only drawback');
                 d(t,m+'is that that possible team members might have to');
                 d(t,m+'wait before they can leave together with the');
                 d(t,m+'spellcaster, since the cage cannot be removed.');
                 d(t,m+'Protection : +20.');
                 d(t,m+'Duration : whole fight.');
                end;
      Sage     :begin {Steal}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Not being any attack or defence spell, this might');
                 d(t,m+'prove a more lucrative way of cursing your foes.');
                 d(t,m+'Rob them blind!');
                 d(t,m+'Effect : gets random amount of enemys '+config.moneytype+'.');
                 d(t,m+'Duration : 1 turn.');
                end;
     end;
    end;
 10:begin {Level X Spells}
     case class of
      Cleric   :begin {Heal}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'The most powerful healing spell.');
                 d(t,m+'Especially useful when fighthing alone.');
                 d(t,m+'Effect : caster regains 200 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Magician :begin {Pillar of Fire}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Magicians love fire. This spell is a good');
                 d(t,m+'example. Makes the target burning from the');
                 d(t,m+'vicious fire, which sticks like glue to the');
                 d(t,m+'skin. Penetrates all known armor');
                 d(t,m+'Damage : 110-112 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
      Sage     :begin {Energy Drain}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'As like many of the sages spells this to is a');
                 d(t,m+'mind boggling one. Using the classical perpetual');
                 d(t,m+'damnation technique, the victim is forced');
                 d(t,m+'gather his psi-energy into the heart, where it');
                 d(t,m+'is zapped.');
                 d(t,m+'The originator of the spell, Old Shaman Jadar,');
                 d(t,m+'drained himself, in what was to become');
                 d(t,m+'his last experiment (you have been warned).');
                 d(t,m+'Damage : 130-141 hps.');
                 d(t,m+'Duration : 1 turn.');
                end;
     end;
    end;
 11:begin {Level XI Spells}
     case class of
      Cleric   :begin {Divination}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Divine intervention, here we go again...');
                 d(t,m+'Causes its caster to become a mini God, a good');
                 d(t,m+'one. You are forgiven some of your older sins,');
                 d(t,m+'and your soul is not so dark anymore.');
                 d(t,m+'You become extremely hard to hit.');
                 d(t,m+'Protection : +110-141 protection, increased goodness');
                 d(t,m+'Duration : random.');
                end;
      Magician :begin {Power word KILL}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Drives the spirit from the flesh and attempts to');
                 d(t,m+'shut down the body and the mind.');
                 d(t,m+'Works extremely well when dealing with animlas.');
                 d(t,m+'Damage : 220-265 hps');
                 d(t,m+'Duration : 1 turn.');
                end;
      Sage     :begin {Summon Demon}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Calls upon a Demon from the higher regions of hell.');
                 d(t,m+'Usually, what you will get is a normal Servant-Demon.');
                 d(t,m+'Nothing fancy, but they are often keen to get the job');
                 d(t,m+'done, letting them return to their sweet hell.');
                 d(t,m+'Damage : 100-120 hps');
                 d(t,m+'Duration : whole fight.');
                end;
     end;
    end;
 12:begin {Level XII Spells}
     case class of
      Cleric   :begin {Gods Finger}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'If not actually Gods real finger, this spell');
                 d(t,m+'sends an energy blast right through the targets');
                 d(t,m+'body. It''s not a clean way of dealing with your');
                 d(t,m+'enemies. It often sends the victims bodies hurling');
                 d(t,m+'through the air, while blood and guts are all over');
                 d(t,m+'the place. Not for the quiet priesthood, but for');
                 d(t,m+'someone in great stress and dealing with evil.');
                 d(t,m+'Put in the spell-book for emergency cases ONLY.');
                 d(t,m+'Damage : 220-250 hps');
                 d(t,m+'Duration : 1 turn.');
                end;
      Magician :begin {Summon Demon}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'Calls upon a Demon from the mid-sections of hell.');
                 d(t,m+'The demons stay all battle long, and are great');
                 d(t,m+'with their claws. A better companion is hard to');
                 d(t,m+'find.');
                 d(t,m+'Damage : 200-300 hps');
                 d(t,m+'Duration : whole fight.');
                end;
      Sage :    begin {Death Kiss}
                 d(c,m1+spell_name(class,spell));
                 d(t,m+'The Force of Death is strong in this case.');
                 d(t,m+'This spell will summon a undead spirit which');
                 d(t,m+'will enter the targets body and try to bring');
                 d(t,m+'him back to the grave.');
                 d(t,m+'You''re dealing with some heavy stuff here, so be');
                 d(t,m+'cautious.');
                 d(t,m+'Damage : 240-290 hps');
                 d(t,m+'Duration : 1 turn.');
                end;
     end;
    end;
 end; {case .end.}

end; {SPELL_DESCRIPTION **** END ****}

Procedure List_of_Spells(var happy : userrec;all:boolean);
const shadcol = 7;

var

    c,
    i,
    j,
    justval : byte;

    x   : longint;

    done,
    afford_it : boolean;

    s : s70;


begin {displays a list of available spells}

 sd(15,'?');
 crlf;
 crlf;
 done:=false;

 for i:=1 to global_maxspells do begin

  if happy.mana>=spell_cost(happy.class,i) then afford_it:=true
                                           else afford_it:=false;

  {spell}
  case i of
   1 : s:='A';
   2 : s:='B';
   3 : s:='C';
   4 : s:='D';
   5 : s:='E';
   6 : s:='F';
   7 : s:='G';
   8 : s:='H';
   9 : s:='I';
   10: s:='J';
   11: s:='K';
   12: s:='L';
  end; {case .end.}

  if happy.spell[i,1] then c:=11
                      else c:=shadcol;

  if (all) or (happy.spell[i,1]) then begin

   if afford_it then sd(c,'('+s+') ')
                else sd(shadcol,'('+s+') ');

   if happy.spell[i,1] then begin
    justval:=18;
    c:=5;
   end
   else begin
    c:=shadcol;
    justval:=18;
   end;

   sd(c,ljust(spell_name(happy.class,i),justval));

   {level needed or LEARNED}
   if happy.spell[i,1] then begin
    sd(14,ljust('Learned',justval));
   end
   else begin
    if done then begin
     sd(shadcol,ljust('(xx)',justval));
    end
    else begin
     j:=level_needed(happy.class,i);
     x:=How_Many_XP_Left(j,happy.exp);

     s:='('+commastr(x)+' xp left';
     if x=0 then s:=s+'! Visit your Level Master!)'
            else s:=s+')';

     sd(shadcol,s);
     done:=true;
    end;
   end;

   {MANA cost}
   if happy.spell[i,1] then begin
    sd(15,commastr(spell_cost(happy.class,i))+' mana');
    if spell_multi(happy.class,i)=true then begin
     sd(11,'  *multi target*');
    end;
   end
   else begin
    {}
   end;

   crlf;
  end; {if ALL end}

 end; {for i:= .end.}
 crlf;

end;  {list_of_spells .end.}

Procedure Reset_Spells (var pl1,pl2,pl3,pl4 : userrec);
var i : byte;
begin

 {resets the spell for the pl1..pl4 players. used by team routines}

 for i:=1 to global_maxspells do begin
  player.spell[i,2]:=false;
  pl1.spell[i,2]:=false;
  pl2.spell[i,2]:=false;
  pl3.spell[i,2]:=false;
  pl4.spell[i,2]:=false;
 end; {for i:= .end.}

end; {reset_spells .end.}

Procedure Spell_List(var happy : userrec);
var ch : char;
     i : byte;
begin

 repeat
  sd(config.textcolor,'(');
  sd(10,classnames[happy.class]);
  sd(config.textcolor,' Spells, A..L, ?=list, Enter) :');
  ch:=upcase(getchar);

  case ch of
   'A'..'L':begin
             sd(15,ch);
             case ch of
              'A': i:=1;
              'B': i:=2;
              'C': i:=3;
              'D': i:=4;
              'E': i:=5;
              'F': i:=6;
              'G': i:=7;
              'H': i:=8;
              'I': i:=9;
              'J': i:=10;
              'K': i:=11;
              'L': i:=12;
             end;
             spell_description(happy.class,i);
             crlf;
            end;
   '?':begin
        list_of_spells(happy,true);
       end;

  end; {case .end.}

 until ch=ReturnKey;

end; {SPELL_LIST .end.}


{*** Monster Spell relating functions ***}

Function Spell_Name_Monster;
var s : s30;
begin

 case nr of
  1: s:='Cause Damage';
  2: s:='Snakes';
  3: s:='Cyclone';
  4: s:='Summon Undead';
  5: s:='Vice of Death';
  6: s:='Drain Life';
 end; {case .end.}

 {return result}
 spell_name_monster:=s;

end; {spell_name_monster *end*}

Function Spell_Cost_Monster;
var x : integer;
begin

 x:=0;
 case nr of
  1: x:=10;
  2: x:=20;
  3: x:=25;
  4: x:=30;
  5: x:=35;
  6: x:=40;
 end;

 {return result}
 spell_cost_monster:=x;

end; {spell_cost_monster .end.}

Function Spell_Multi_Monster;
var x : boolean;
begin

 x:=false;
 case nr of
  1: x:=false;
  2: x:=false;
  3: x:=true;
  4: x:=false;
  5: x:=false;
  6: x:=false;
 end;

 spell_multi_monster:=x;

end;

end. {Unit SpellsU .end.}
