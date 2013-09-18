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



unit DispText; {Usurper - Displays text of the Level Masters}

interface

uses
  Init;

procedure Display_UText(const Name: s70);

implementation

uses
  Jakob, SysUtils;

procedure Display_UText;
const nr = 10;
var s: s70;
begin

  s := UpperCase(Name);

  if s = 'RACEHELP' then
  begin

    d(5, 'Race Selection  -  Helptext');
    d(5, '=-=-=-=-=-=-=-=-=-=-=-=-=-=');
    crlf;
    d(nr, 'Human    : ' + config.textcol1 + 'Good overall choice. You should know, as I assume that you are one.');
    d(nr, 'Hobbit   : ' + config.textcol1 + 'Small and dexterous. Strong resistance to magic attacks.');
    d(nr, 'Elf      : ' + config.textcol1 + 'As human, but weaker physique.');
    d(nr, 'Half-Elf : ' + config.textcol1 + 'As elf, but stronger. Can turn bad on occasions.');
    d(nr, 'Dwarf    : ' + config.textcol1 + 'Small, strong warrior. Can do almost anything with an axe.');
    d(nr, 'Troll    : ' + config.textcol1 + 'Big, strong warrior. Good starting abilities. Should be played bad.');
    d(nr, 'Orc      : ' + config.textcol1 + 'A little weaker than the troll, but can also be played good.');
    d(nr, 'Gnome    : ' + config.textcol1 + 'Half orc, half troll. Strong resistance to drugs.');
    d(nr, 'Gnoll    : ' + config.textcol1 + 'Weak physique and brains, but carries poison in its bite.');
    d(nr, 'Mutant   : ' + config.textcol1 + 'Well, nobody really knows. But they are immune to evil Gods...');
    crlf;
    d(config.textcolor, ulblue + 'Remember!');
    d(config.textcolor, 'One race may seem preferable to another at a quick glance, but');
    d(config.textcolor, 'you may wish to experiment with different types, as the starting abilities');
    d(config.textcolor, 'are very different. Races interact differently to each other, so if you');
    d(config.textcolor, 'start as troll for example, you may get discounts in the weaponstore, which');
    d(config.textcolor, 'is run by a troll.');
  end else if s = 'CLASSHELP' then
  begin
    d(5, 'Class Selection  -  HelpText');
    d(5, '=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
    crlf;
    d(5, 'The Alchemist');
    d(config.textcolor, 'This character depends greatly on his ability to use poisons. His');
    d(config.textcolor, 'skills enable him to apply powerful poison');
    d(config.textcolor, 'to his weapons. Without that aid, the alchemist');
    d(config.textcolor, 'leaves much to be desired as far as natural fighting skills is');
    d(config.textcolor, 'concerned. Being a creature of science, this class');
    d(config.textcolor, 'cannot use any magical powers or wands. The alchemist may,');
    d(config.textcolor, 'however, resist the effects of a spell or magical device.');
    d(config.textcolor, 'Alchemists receive an extra bonus in Wisdom per experience');
    d(config.textcolor, 'level.');
    d(config.textcolor, 'Alchemists have their own Order, in which they can excell in');
    d(config.textcolor, 'their profession and also get more powerful.');
    crlf;
    d(5, 'The Assassin');
    d(config.textcolor, 'A Ninja-style fighter, the assassin has extra fighting ability');
    d(config.textcolor, 'making him tough to defeat. With the use of');
    d(config.textcolor, 'backstabs, the assassin will usually have enough firepower to');
    d(config.textcolor, 'defeat any fighting class. Assassins receive an extra bonus in');
    d(config.textcolor, 'Agility per experience level.');
    pause;
    crlf;
    d(5, 'The Barbarian');
    d(config.textcolor, 'The strongest combat-class fighter in the game, but the most');
    d(config.textcolor, 'susceptible to the effects of magic. As the Barbarian grows in');
    d(config.textcolor, 'experience, his hitting power augments. There will be a point');
    d(config.textcolor, 'where a Barbarians essence can match the power of any man-made');
    d(config.textcolor, 'weapon. Barbarians receive an extra bonus in Stamina per');
    d(config.textcolor, 'experience level.');
    crlf;
    d(5, 'The Bard');
    d(config.textcolor, 'The Bard-class enjoys every aspect of the game: backstabbing');
    d(config.textcolor, 'magic, stealing, and fighting. However, the bard does not');
    d(config.textcolor, 'specialize in any of his abilities, thus his experience can be');
    d(config.textcolor, 'either rewarding or frustrating. An entertainer by trade, Bards');
    d(config.textcolor, 'receive an extra bonus in Charisma per experience level.');
    crlf;
    d(5, 'The Cleric');
    d(config.textcolor, 'A Cleric has good combat and magic abilities. His ability to');
    d(config.textcolor, 'Heal is stronger than his ability to Blast. Clerics get to use');
    d(config.textcolor, 'poisons cheaply, but not too effectively. Clerics receive an');
    d(config.textcolor, 'extra bonus in Charisma per experience level.');
    pause;
    crlf;
    d(5, 'The Jester');
    d(config.textcolor, 'Jesters are annoying pests. They lack serious hand-to-hand');
    d(config.textcolor, 'combat power, but their acrobatic-like abilities gives them an edge');
    d(config.textcolor, 'in dodging attacks. Jesters also possess some magic,');
    d(config.textcolor, 'backstabbing, and thieving abilities. Jesters receive an extra');
    d(config.textcolor, 'bonus in Charisma per experience level.');
    crlf;
    crlf;
    d(5, 'The Magician');
    d(config.textcolor, 'The Magician is the opposite of the Fighter; powerful magic');
    d(config.textcolor, 'opposed to combat abilities. Magicians can consistently cast');
    d(config.textcolor, 'spells effectively and yield better results. Magicians receive');
    d(config.textcolor, 'an extra bonus in Wisdom per experience level.');
    crlf;
    d(5, 'The Paladin');
    d(config.textcolor, 'Paldins are characters with strong beliefs and virtues.');
    d(config.textcolor, 'They believe in good and should be played that way for best');
    d(config.textcolor, 'results. Paladins are strong and skilled in combat. They');
    d(config.textcolor, 'also possess a special attack : the soulstrike. Paladins');
    d(config.textcolor, 'receive an extra bonus in Stamina per experience level.');
    pause;
    crlf;
    d(5, 'The Ranger');
    d(config.textcolor, 'Rangers are great survivors, because they must depend on their');
    d(config.textcolor, 'ability to live off the land. Like Bards, they have many special');
    d(config.textcolor, 'abilities, though they do not excel at any particular one. Their');
    d(config.textcolor, 'fighting and healing powers are among their best abilities.');
    d(config.textcolor, 'Rangers receive an extra bonus in Wisdom per experience level.');
    crlf;
    d(5, 'The Sage');
    d(config.textcolor, 'The weakest combat-class is the Sage. His hand-to-hand abilities');
    d(config.textcolor, 'leave much to be desired, but as the Sage grows in experience,');
    d(config.textcolor, 'his spell casting abilities can dominate any class, mortal or');
    d(config.textcolor, 'divine. Sages receive an extra bonus in Wisdom per');
    d(config.textcolor, 'experience level.');
    crlf;
    d(5, 'The Warrior');
    d(config.textcolor, 'Warriors are excellent killers. Their extraordinary combat');
    d(config.textcolor, 'ability makes them difficult opponents. Though their class has');
    d(config.textcolor, 'no extra abilities, there are no extra penalties levied against');
    d(config.textcolor, 'them either. Fighters receive an extra bonus in Stamina per');
    d(config.textcolor, 'experience level.');
    pause;
  end else if s = 'LEVEL_MASTER_#1' then
  begin
    crlf;
    d(config.textcolor, 'Akrappas house resides just outside town. They call him the Wisest');
    d(config.textcolor, 'of them all. Well, undisputably the most popular of them all.');
    d(config.textcolor, 'You notice the heap of books which are stored all over the big');
    d(config.textcolor, 'living room. The legends of Akrappa are so many, and yet so few');
    d(config.textcolor, 'compared to the other Great Masters. Anyhow, the impression when');
    d(config.textcolor, 'meeting the old man takes your breath away. Charisma of a');
    d(config.textcolor, 'hundred Heros and still an old and gentle man, who seems to');
    d(config.textcolor, 'care mostly for his gout.');
  end else if s = 'LEVEL_MASTER_#2' then
  begin
    crlf;
    d(config.textcolor, 'Singuman is the youngest of the known Masters. He acquired his title');
    d(config.textcolor, 'at only 35 years old, making a wood burst in to flames in only 30 seconds.');
    d(config.textcolor, 'Singuman also wrestled Xzinn on the mountain of Moon. His love for');
    d(config.textcolor, 'Ishana is well known but it is uncertain whether it goes both ways.');
    d(config.textcolor, 'By no means envious by nature, Singuman strives for Akrappas position');
    d(config.textcolor, 'as Head of Masters. Some say he''s already superior to');
    d(config.textcolor, 'Akrappa, some say Singuman lacks the important bit of caring for');
    d(config.textcolor, 'the poor. Always dressed in an Elven Chainmail and a red mantle');
    d(config.textcolor, 'Singuman is easily recognized.');
  end else if s = 'LEVEL_MASTER_#3' then
  begin
    crlf;
    d(config.textcolor, 'Elven and human blood pours through Ishanas veins. Taught for house-');
    d(config.textcolor, 'holding, she saw her father be brutally slain by Uruk-Hai.');
    d(config.textcolor, 'Rescued from slavery by Ahriman, Ishana learned a lot from the wise');
    d(config.textcolor, 'man. At the age of 25 she started her own practice of elementary');
    d(config.textcolor, 'magic. Ishana possesses wisdom unmatched by few, and disputed by');
    d(config.textcolor, 'even less. Extremely skilled with a longbow and sword. Slayed');
    d(config.textcolor, 'Ogmof the Fat in the battle of Shares in 3014. While never married,');
    d(config.textcolor, 'rumours speak of her magic being connected with her virginity.');
  end else if s = 'LEVEL_MASTER_#4' then
  begin
    crlf;
    d(config.textcolor, 'Hot-tempered to say the least, Dzarrgo is a ruler by nature. The big');
    d(config.textcolor, 'question about him is whether he is totally evil or has some good in him.');
    d(config.textcolor, 'The answer may simply be that Dzarrgo serves only himself. He has been');
    d(config.textcolor, 'allied with many great Warlords who have strived for power. They say');
    d(config.textcolor, 'that he is secretly building his own empire somewhere on the great');
    d(config.textcolor, 'plains of Okhsor. Eyes of stone and a weapon skill which outmatches');
    d(config.textcolor, 'the best warriors in the county. Dzarrgo is also expertly trained in');
    d(config.textcolor, 'Black Magic.');
  end else if s = 'LEVEL_MASTER_#5' then
  begin
    crlf;
    d(config.textcolor, 'Agni is a Master unmarked of time. He has never been seated in the');
    d(config.textcolor, 'Great Council, a fact which has rendered him suspect in many''s view.');
    d(config.textcolor, 'In feud with Gregorius after a disputed chess game, which Agni claims');
    d(config.textcolor, 'to have won, but Gregorius refuses to accept, accusing Agni of cheating.');
    d(config.textcolor, 'Always elegant in both manners and clothing, Agni gets the rightful');
    d(config.textcolor, 'respect he deserves, whether feared or praised.');
  end else if s = 'LEVEL_MASTER_#6' then
  begin
    crlf;
    d(config.textcolor, 'As a pupil of Sagan the Great, Apollonia makes no distinction between');
    d(config.textcolor, 'those who seek her aid. May it be evil, good or neutral; Apollonia is thought');
    d(config.textcolor, 'to assist all creatures. This seemingly rather naive attitude is an');
    d(config.textcolor, 'approach linked back to the first Ages, when purity ruled the world.');
    d(config.textcolor, 'Dressed in a glittering Silvergown and wearing a blue mantle, Apollonia');
    d(config.textcolor, 'is the last remnant from those days.');
  end else if s = 'LEVEL_MASTER_#7' then
  begin
    crlf;
    d(config.textcolor, 'The Witchmasters ramschackle lies in the shabby Eastern parts');
    d(config.textcolor, 'of Town. As probably one of the most feared men in the county, this');
    d(config.textcolor, 'tells us a bit of the ignorance of the townpeople. Almost never seen');
    d(config.textcolor, 'the rumours of Sachmez evil doings have reached absurd proportions.');
    d(config.textcolor, 'Still, when facing the Sorceror, You can''t get rid of the nasty');
    d(config.textcolor, 'feeling of being scrutinized by a superior mind, who wishes to control You.');
  end else if s = 'LEVEL_MASTER_#8' then
  begin
    crlf;
    d(config.textcolor, 'Umilak is always on the move and you never really can tell where');
    d(config.textcolor, 'he is. When he is in town you can normally find him at the old Crypt,');
    d(config.textcolor, 'just south of the Church. Musty air confronts You as you enter the gloomy');
    d(config.textcolor, 'regions of the old Crypt. You find Umilak sitting behind his desk,');
    d(config.textcolor, 'solving some riddle and equations perhaps? His dark glowing eyes suddenly');
    d(config.textcolor, 'focus on You as you make yourself noticed with a discrete cough.');
  end else if s = 'LEVEL_MASTER_#9' then
  begin
    crlf;
    d(config.textcolor, 'After an hour on a small trail leading into the forest, You');
    d(config.textcolor, 'can spot Asangas little cabin well hidden in a grove.');
    d(config.textcolor, 'This humble man could well be taken for a forester, but behind');
    d(config.textcolor, 'the simple appearance a mighty spiritual power dwells.');
    d(config.textcolor, 'It is hard to tell whether Asangas powers are dark or white, but');
    d(config.textcolor, 'does it matter? He is dressed in a spotted Goatskin and wields a staff.');
  end else if s = 'LEVEL_MASTER_#10' then
  begin
    crlf;
    d(config.textcolor, 'Gregorius great mansion resides two miles outside of town');
    d(config.textcolor, 'After the short journey You let yourself in to this eccentric mans house.');
    d(config.textcolor, 'He lives by himself in this enormous building, all made in marble.');
    d(config.textcolor, 'Religious symbols are imprinted everywhere, some you can interpret,');
    d(config.textcolor, 'some not. After a short while the Patriarch arrives, looking very busy');
    d(config.textcolor, 'You try to make your request as short and precise as possible.');
  end;

end;

end. {Unit DispText .end.}
