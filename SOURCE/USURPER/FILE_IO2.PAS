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



unit File_IO2; {Usurper - file i/o routines 2/2 ..
                          .. see also file_io.pas }

interface

uses
  Init;

function Create_Childrenfile(const nr: byte): boolean;


implementation

uses
  File_IO;

function Create_Childrenfile(const nr: byte): boolean;
const ctype: array [1..2] of string[6] = ('MALE', 'FEMALE');
var
  txt:          Text;

  tempfilename: s70;

  Result:       boolean;

  procedure Ox(const s: s100); {shorter to write ox('blaha') than writeln_....}
  begin
    writeln_to_text(txt, s);
  end;

begin {creates textfile with children data, names and stuff}

  {set correct filename, male or female}
  case nr of
    1: tempfilename := global_childmalef;
    2: tempfilename := global_childfemalef;
  end; {case .end.}

  if open_txtfile(trewrite, txt, tempfilename) = True then
  begin
    ox('; These are the names of the ' + ctype[nr] + ' children that will be');
    ox('; used by the NPC''s when they name their newborn children.');
    ox('; Feel free to add, edit or remove names from the list.');
    ox('; To recreate this file, delete the current one, and a new one');
    ox('; will be made.');
    ox(';');
    ox(';format: name');
    ox(';');
    case nr of
      1: begin {Write the MALE children names}
        ox('Sam'); {#1}
        ox('Sam Junior'); {#2}
        ox('Totte'); {#3}
        ox('Nick'); {#4}
        ox('Bull'); {#5}
        ox('Flicker'); {#6}
        ox('Negro'); {#7}
        ox('Wasp'); {#8}
        ox('Trent'); {#9}
        ox('Kid'); {#10}
        ox('Bruno'); {#11}
        ox('Butch'); {#12}
        ox('Butcher');{#13}
        ox('Abdul');{#14}
        ox('Wagner');{#15}
        ox('Nietzsche');{#16}
        ox('Bozo');{#17}
        ox('Bozer');{#18}
        ox('Miniman');{#19}
        ox('Boxer');{#20}
        ox('Prick');{#21}
        ox('Nippe');{#22}
        ox('Orbie');{#23}
        ox('Stew'); {#24}
        ox('Urban');{#25}
        ox('Ugly'); {#26}
        ox('Eric'); {#27}
        ox('Tom'); {#28}
        ox('Buckler');{#29}
        ox('Puke');{#30}
        ox('Nadim');{#31}
        ox('Murmur');{#32}
        ox('Prince');{#33}
        ox('Smurf');{#34}
        ox('Ditto');{#35}
        ox('Crash');{#36}
        ox('Flint');{#37}
        ox('Serious');{#38}
        ox('Molk');{#39}
        ox('Hero'); {#40}
        ox('Frank'); {#41}
        ox('Sharky');{#42}
        ox('Wolf');{#43}
        ox('Balthazaar');{#44}
        ox('Zovonomir');{#45}
        ox('Landmine');{#46}
        ox('Kurt');{#47}
        ox('Igor');{#48}
        ox('Zack');{#49}
        ox('Woody');{#50}
        ox('Franky');{#51}
        ox('Bill');  {#52}
        ox('Wacky'); {#53}
        ox('John'); {#54}
        ox('Stinky'); {#55}
        ox('Gwibbli'); {#56}
        ox('Quintus'); {#57}
        ox('Arf'); {#58}
        ox('Barf'); {#59}
        ox('Skunk'); {#60}
        ox('Blip'); {#61}
        ox('Blop'); {#62}
        ox('Benny'); {#63}
        ox('Targash'); {#64}
        ox('Slobbo'); {#65}
        ox('Paco'); {#66}
        ox('Butchy'); {#67}
        ox('Thor'); {#68}
        ox('Rugwash'); {#69}
        ox('Asghnak'); {#70}
        ox('Twinky'); {#71}
        ox('Pinky'); {#72}
        ox('Hellraiser'); {#73}
        ox('Slow'); {#74}
        ox('Dirtface'); {#75}
        ox('Dog'); {#76}
        ox('Digger'); {#77}
        ox('Mini'); {#78}
        ox('Alex'); {#79}
        ox('Jasper'); {#80}
        ox('Ola'); {#81}
        ox('Monster'); {#82}
        ox('Red-Neck'); {#83}
        ox('Ulf'); {#84}
        ox('Grogg'); {#85}
        ox('Grogg Junior'); {#86}
        ox('Grogg II'); {#87}
        ox('Grogg III'); {#88}
        ox('Grogg IV'); {#89}
        ox('Smear'); {#90}
        ox('Gollum'); {#91}
        ox('Gwindly'); {#92}
        ox('Sack of Shit'); {#93}
        ox('Zack the Second'); {#94}
        ox('Billy'); {#95}
        ox('Billy Bob'); {#96}
        ox('Bobby'); {#97}
        ox('Stig'); {#98}
        ox('Glob'); {#99}
        ox('Fredrick'); {#100}
        ox('Steiner'); {#101}
        ox('Julius'); {#102}
        ox('Twit'); {#103}
        ox('Disaster'); {#104}
        ox('Jonathan'); {#105}
        ox('Athelstan'); {#106}
        ox('William'); {#107}
        ox('Gilbert'); {#108}
        ox('Walter'); {#109}
        ox('Hugh'); {#110}
        ox('Richard'); {#111}
        ox('Ralph'); {#112}
        ox('Remigius'); {#113}
        ox('Alan'); {#114}
        ox('Quasimodo'); {#115}
        ox('Bartholomew'); {#116}
        ox('Waleran'); {#117}
        ox('Percy'); {#118}
        ox('Gruff'); {#119}
        ox('Francis'); {#120}
        ox('Peter'); {#121}
        ox('Torgny'); {#122}
        ox('Jonas'); {#123}
        ox('Stephan'); {#124}
        ox('Joakim'); {#125}
        ox('Tony'); {#126}
        ox('Little Tony'); {#127}
        ox('Dirty Tony'); {#128}
        ox('Tony Junior'); {#129}
        ox('Joe'); {#130}
        ox('Eddie'); {#131}
        ox('Fast Eddie'); {#132}
        ox('Rushgnak'); {#133}
        ox('Willy'); {#134}
        ox('Kenny'); {#135}
        ox('Fearless'); {#136}
        ox('Enfant Terrible'); {#137}
        ox('Horror'); {#138}
        ox('Blue'); {#139}
        ox('Kong'); {#140}
        ox('Little Jack'); {#141}
        ox('Jack'); {#142}
        ox('Jack Junior'); {#143}
        ox('Milius'); {#144}
        ox('Garth'); {#145}
        ox('Alfred'); {#146}
        ox('Robert'); {#147}
        ox('Paul'); {#148}
        ox('Biff'); {#149}
        ox('Paulie'); {#150}
        ox('Marc'); {#151}
        ox('Winnie'); {#152}
        ox('Timothy'); {#153}
        ox('Turambar'); {#154}
        ox('Melkor'); {#155}
        ox('Feanor'); {#156}
        ox('Amillo'); {#157}
        ox('Omar'); {#158}
        ox('Tuor'); {#159}
        ox('Otto'); {#160}
        ox('Friday'); {#161}
        ox('Shaggy'); {#162}
        ox('Tintin'); {#163}
        ox('Brain-Dead'); {#164}
        ox('F.U.B.A.R.'); {#165}
        ox('Smooth'); {#166}
        ox('Smeagol'); {#167}
        ox('Christopher'); {#168}
        ox('Nicholas'); {#169}
        ox('Albert'); {#170}
        ox('Loke'); {#171}
        ox('Albrecht'); {#172}
        ox('Crazy Joe'); {#173}
        ox('Morgoth'); {#174}
        ox('Lassiter'); {#175}
        ox('Kick'); {#176}
        ox('Bolt'); {#177}
        ox('Kicke'); {#178}
        ox('Snap'); {#179}
        ox('Big Bill'); {#180}
        ox('Lurch'); {#181}
        ox('Ricky'); {#182}
        ox('Rick'); {#183}
        ox('Demon Boy'); {#184}
        ox('Little Bloody Joe'); {#185}
        ox('Agarwaen'); {#186}
        ox('Urin'); {#187}
        ox('Bogg'); {#188}
        ox('Amillo'); {#189}
        ox('Jake'); {#190}
        ox('Svein'); {#191}
        ox('Johan'); {#192}
        ox('Amrod'); {#193}
        ox('Gary'); {#194}
        ox('Lennart'); {#195}
        ox('Thorstein'); {#196}
        ox('Axel'); {#197}
        ox('Thunder'); {#198}
        ox('Curufin'); {#199}
        ox('Jesus'); {#200}
        ox('Bogomir'); {#201}
        ox('Stone'); {#202}
        ox('Auredhir'); {#203}
        ox('Ausir'); {#204}
        ox('Balcmeg'); {#205}
        ox('Baragund'); {#206}
        ox('Barahir'); {#207}
        ox('Belawryn'); {#208}
        ox('Belcha'); {#209}
        ox('Beleg'); {#210}
        ox('Beorn'); {#211}
        ox('Beowulf'); {#212}
        ox('Thomas'); {#213}
        ox('Slayer'); {#214}
        ox('Ottor'); {#215}
        ox('Bear'); {#216}
        ox('Bodruit'); {#217}
        ox('Little Buddha'); {#218}
        ox('Beren'); {#219}
        ox('Bethos'); {#220}
        ox('Bior'); {#221}
        ox('Ior'); {#222}
        ox('Dhuilin'); {#223}
        ox('Brandir'); {#224}
        ox('Brodda'); {#225}
        ox('Bronweg'); {#226}
        ox('Carcharoth'); {#227}
        ox('Cranthor'); {#228}
        ox('Todd'); {#229}
        ox('Felix'); {#230}
        ox('Nimrod'); {#231}
        ox('Ted'); {#232}
        ox('Mysghnak'); {#233}
        ox('Gandalf Jr'); {#234}
        ox('Daimord'); {#235}
        ox('Dairon'); {#236}
        ox('Daeron'); {#237}
        ox('Damon'); {#238}
        ox('Grishnak'); {#239}
        ox('Damrod'); {#240}
        ox('Daniel'); {#241}
        ox('Danigwiel'); {#242}
        ox('D‚or'); {#243}
        ox('Duilin'); {#244}
        ox('Dhuilin'); {#245}
        ox('Dinithel'); {#246}
        ox('Dior'); {#247}
        ox('Bilbo'); {#248}
        ox('Pippin'); {#249}
        ox('D¡riel'); {#250}
        ox('Dorlas'); {#251}
        ox('Ecthelion'); {#252}
        ox('Edain'); {#253}
        ox('Egnor'); {#254}
        ox('Elbenil'); {#255}
        ox('Selwyn'); {#256}
        ox('Melvin'); {#257}
        ox('Charles'); {#258}
        ox('Calvin'); {#259}
        ox('Hobbes'); {#260}
        ox('Dilbert'); {#261}
        ox('Herbert'); {#262}
        ox('Eldairon'); {#263}
        ox('Elmir'); {#264}
        ox('Elgon'); {#265}
        ox('Rufus'); {#266}
        ox('Jakob Jr'); {#267}
        ox('Ered'); {#268}
        ox('Erambwed'); {#269}
        ox('Ermon'); {#270}
        ox('Nixon'); {#271}
        ox('Eruman'); {#272}
        ox('Fafnir'); {#273}
        ox('Fangluin'); {#274}
        ox('Fauri'); {#275}
        ox('F‰anor'); {#276}
        ox('Felagund'); {#277}
        ox('Finarfin'); {#278}
        ox('Finrod'); {#279}
        ox('Fionw‰'); {#280}
        ox('Finw‰'); {#281}
        ox('Flinding'); {#282}
        ox('Brutus'); {#283}
        ox('Captain Blue'); {#284}
        ox('Little Rascal'); {#285}
        ox('Ashgvak'); {#286}
        ox('Glorund'); {#287}
        ox('Frodo'); {#288}
        ox('Belrond'); {#289}
        ox('Fuithlug'); {#290}
        ox('Galdor'); {#291}
        ox('Galweg'); {#292}
        ox('Gamil'); {#293}
        ox('Zirak'); {#294}
        ox('Gilfanon'); {#295}
        ox('Gilim'); {#296}
        ox('Glim'); {#297}
        ox('Gimli'); {#298}
        ox('Glaurung'); {#299}
        ox('Glend'); {#300}
        ox('Lenny'); {#301}
        {ox('Glorfindel'); {#302}
        {ox('Gorgumoth'); {#303}
        {ox('Abel'); {#304}
        {ox('Kain'); {#305}
        {ox('Gorlim'); {#306}
        {ox('Gothmog'); {#307}
        {ox('Grithnir'); {#308}
        {ox('Gumlin'); {#309}
        {ox('Gumniow'); {#310}
        {ox('Grim'); {#311}
        {ox('Gwindor'); {#312}
        {ox('Hador'); {#313}
        {ox('Ulmo'); {#314}
        {ox('Hadar'); {#315}
        {ox('Helgor'); {#316}
        {ox('Hendor'); {#317}
        {ox('Hengest'); {#318}
        {ox('Heorrenda'); {#319}
        {ox('Bernie'); {#320}
        {ox('Huan'); {#321}
        {ox('Hunthor'); {#322}
        {ox('Hunter'); {#323}
        {ox('Killer'); {#324}
        {ox('Huor'); {#325}
        {ox('H£rin'); {#326}
        {ox('Ilfrin'); {#327}
        {ox('Indor'); {#328}
        {ox('Indorildo'); {#329}
        {ox('Ignatius'); {#330}
        {ox('Belsebub'); {#331}
        {ox('Achmed'); {#332}
        {ox('Attila'); {#333}
        {ox('Ben'); {#334}

        {ox('Ingil'); {#334}
        {forts„tt p† de f”rlorade sagornas bok 2, sid 472.. Ingil}

      end; {finished writing MALE children names}

      2: begin {write the FEMALE children names}
        ox('Mina'); {#1}
        ox('Tina'); {#2}
        ox('Ronda');{#3}
        ox('Spice');{#4}
        ox('Flo');  {#5}
        ox('Cynthia'); {#6}
        ox('Abid'); {#7}
        ox('Cybil');{#8}
        ox('Lena'); {#9}
        ox('Monica'); {#10}
        ox('Sarah'); {#11}
        ox('Kicki'); {#12}
        ox('Timid'); {#13}
        ox('Untah'); {#14}
        ox('Sedina'); {#15}
        ox('Fresh');  {#16}
        ox('Princess'); {#17}
        ox('Ludmila'); {#18}
        ox('Gorgeous'); {#19}
        ox('Anna'); {#20}
        ox('Phobia'); {#21}
        ox('Annabella'); {#22}
        ox('Strawn'); {#23}
        ox('Lolita'); {#24}
        ox('Flower'); {#25}
        ox('Nidema'); {#26}
        ox('Felina'); {#27}
        ox('Nadime'); {#28}
        ox('Gogo'); {#29}
        ox('Brynhilda'); {#30}
        ox('Lotta'); {#31}
        ox('Jeanette');{#32}
        ox('Hollie');{#33}
        ox('Karin'); {#34}
        ox('Karen'); {#35}
        ox('Marilyn');{#36}
        ox('Dalia');  {#37}
        ox('Stella'); {#38}
        ox('Crystal');{#39}
        ox('Lill'); {#40}
        ox('Lilly');{#41}
        ox('Ronya');{#42}
        ox('Saga'); {#43}
        ox('Eva'); {#44}
        ox('Tyra');{#45}
        ox('Nebula');{#46}
        ox('Ymnia');{#47}
        ox('Precious');{#48}
        ox('Angel');{#49}
        ox('Sylvia');{#50}
        ox('Angelica');{#51}
        ox('Faithful'); {#52}
        ox('Innocence');{#53}
        ox('Ylva'); {#54}
        ox('Tylva'); {#55}
        ox('Knyppla'); {#56}
        ox('Gewinla'); {#57}
        ox('Hilda'); {#58}
        ox('Hildur'); {#59}
        ox('Saida'); {#60}
        ox('Finesse'); {#61}
        ox('Pure'); {#62}
        ox('Kerry'); {#63}
        ox('Trine'); {#64}
        ox('Honey'); {#65}
        ox('Sweet'); {#66}
        ox('Tiny'); {#67}
        ox('Vespia'); {#68}
        ox('Agda'); {#69}
        ox('Felicia'); {#70}
        ox('Lina'); {#71}
        ox('Vanessa'); {#72}
        ox('Abigail'); {#73}
        ox('Amy'); {#74}
        ox('Stina'); {#75}
        ox('Aase'); {#76}
        ox('Slyna'); {#77}
        ox('Peggy'); {#78}
        ox('Olga'); {#79}
        ox('Mary'); {#80}
        ox('Astrid'); {#81}
        ox('Aliena'); {#82}
        ox('Gwynedd'); {#83}
        ox('Joliette'); {#84}
        ox('Julia'); {#85}
        ox('Cynthia II'); {#86}
        ox('Zynthia'); {#87}
        ox('Phantasia'); {#88}
        ox('Little Mama'); {#89}
        ox('Momo'); {#90}
        ox('Linda'); {#91}
        ox('Linda Fearless'); {#92}
        ox('Linda Truthful'); {#93}
        ox('Linda Loyal'); {#94}
        ox('Joyce'); {#95}
        ox('Little Maud'); {#96}
        ox('Maud'); {#97}
        ox('Paulia'); {#98}
        ox('Cassandra'); {#99}
        ox('Wynola'); {#100}
        ox('Tinuviel'); {#101}
        ox('Sandy'); {#102}
        ox('Airin'); {#103}
        ox('Faiglindra'); {#104}
        ox('Firilanda'); {#105}
        ox('Aredhel'); {#106}
        ox('Nienori'); {#107}
        ox('Iris'); {#108}
        ox('Happy'); {#109}
        ox('Tuva'); {#110}
        ox('Tove'); {#111}
        ox('Love'); {#112}
        ox('Wirilome'); {#113}
        ox('Elenwe'); {#114}
        ox('Ellen'); {#115}
        ox('Ellie'); {#116}
        ox('Nellie'); {#117}
        ox('Evranin'); {#118}
        ox('Faelivrin'); {#119}
        ox('Fluithuin'); {#120}
        ox('Gwedheling'); {#121}
        ox('Gwendeling'); {#122}
        ox('Gwendelin'); {#123}
        ox('Gunnila'); {#124}
        ox('Therese'); {#125}
        ox('Gwenethlin'); {#126}
        ox('Melian'); {#127}
        ox('Gwenniel'); {#128}
        ox('Hirilorn'); {#129}
        ox('Idril'); {#130}
        ox('Samantha'); {#131}
        ox('Lydia'); {#132}
        ox('Isfin'); {#133}
        ox('Clarissa'); {#134}
        ox('Vanya'); {#135}
        ox('Tanya'); {#136}
        ox('Mavwin'); {#137}
        ox('Morwen'); {#138}
        ox('Tiranne'); {#139}
        ox('Meleth'); {#140}
        ox('Melinir'); {#141}
        ox('Veanne'); {#142}
        ox('Yvonne'); {#143}
        ox('Sam'); {#144}
        ox('Naimi'); {#145}
        ox('Paradise'); {#146}
        ox('Fruit'); {#147}
        ox('Tasteful'); {#148}
        ox('Belinda'); {#149}
        ox('Pleasure'); {#150}
        ox('Nessa'); {#151}
        ox('Nielthi'); {#152}
        ox('Nienori'); {#153}
        ox('Nineveh'); {#154}
        ox('Monday'); {#155}
        ox('Tuesday'); {#156}
        ox('Wednesday'); {#157}
        ox('Niniel'); {#158}
        ox('Nina'); {#159}
        ox('Sunday'); {#160}
        ox('Faint'); {#161}
        ox('Saint'); {#162}
        ox('Lolly'); {#163}
        ox('Blossom'); {#164}
        ox('Rosie'); {#165}
        ox('Rose'); {#166}
        ox('Gwyneth'); {#167}
        ox('Slut'); {#168}
        ox('Eliza'); {#169}
        ox('Twiggy'); {#170}
        ox('Elizabeth'); {#171}
        ox('Elisabeth'); {#172}
        ox('Tindriel'); {#173}
        ox('Tinwelin'); {#174}
        ox('Tinwe'); {#175}
        ox('Big Girl'); {#176}
        ox('Lady Di'); {#177}
        ox('Margareth'); {#178}
        ox('Tynwfiel'); {#179}
        ox('Little Lady'); {#180}
        ox('Sheila'); {#181}
        ox('Vaire'); {#182}
        ox('Wendelin'); {#183}
        ox('Ungweliant'); {#184}
        ox('Chris'); {#185}
        ox('Erinti'); {#186}
        ox('Lotesse'); {#187}
        ox('April'); {#188}
        ox('June'); {#189}
        ox('May'); {#190}
        ox('Annica'); {#191}
        ox('Anne'); {#192}
        ox('Helga'); {#193}
        ox('Ilse'); {#194}
        ox('Ravenni'); {#195}
        ox('Lush'); {#196}
        ox('Measse'); {#197}
        ox('Nielikki'); {#198}
        ox('Nikki'); {#199}
        ox('Barbara'); {#200}
        ox('Mimmi'); {#201}
        ox('Minnie'); {#202}
        ox('Melessa'); {#203}
        ox('Nieliqui'); {#204}
        ox('Nienna'); {#205}
        ox('Nanna'); {#206}
        ox('Nanette'); {#207}
        ox('Larissa'); {#208}
        ox('Beth'); {#209}
        ox('Dorothy'); {#210}
        ox('Lucy'); {#211}
        ox('Yavanna'); {#212}
        ox('Luschka'); {#213}
        ox('Mia'); {#214}
        ox('Miranda'); {#215}
        ox('Josephine'); {#216}
        ox('Sparkle'); {#217}
        ox('Ursula'); {#218}
        ox('Bonnie'); {#219}
        ox('Jane'); {#220}
        ox('Darling'); {#221}
        ox('Spring'); {#222}
        ox('Autumn'); {#223}
        ox('Holly'); {#224}
        ox('Hollie'); {#225}
        ox('Robin'); {#226}
        ox('Rickie'); {#227}
        ox('Little Sarah'); {#228}
        ox('Cindy'); {#229}
        ox('Cindarella'); {#230}
        ox('Gloria'); {#241}
        ox('Carla'); {#242}
        ox('Karla'); {#243}
        ox('Evelyn'); {#244}
        ox('Helwig'); {#245}
        ox('Camilla'); {#246}
        ox('Pussy'); {#247}
        ox('Cat'); {#248}
        ox('Catherine'); {#249}
        ox('Rawynda'); {#250}
        ox('Birgitte'); {#251}
        ox('Birgitta'); {#252}
        ox('Marbles'); {#253}
        ox('Trinnie'); {#254}
        ox('Nany'); {#255}
        ox('Nanny'); {#256}
        ox('Bertha'); {#257}
        ox('Trixie'); {#258}
        ox('Rachel'); {#259}
        ox('Awful Annie'); {#260}
        ox('Harriet'); {#261}
        ox('Haggie'); {#262}
        ox('Maggie'); {#263}
        ox('Meg'); {#264}
        ox('Peggie'); {#265}
        ox('Peg'); {#266}
        ox('Phoebe'); {#267}
        ox('Xenophobia'); {#268}
        ox('Terry'); {#269}
        ox('Ophelia'); {#270}
        ox('Psycho Peg'); {#271}
        ox('Crazy Anne'); {#272}
        ox('Stupid Lena'); {#273}
        ox('Evil Evelyn'); {#274}
        ox('Baby Bonnie'); {#275}
        ox('Babyface Belinda'); {#276}
        ox('Skirtless Sheila'); {#277}
        ox('Kerstin'); {#278}
        ox('Claire'); {#279}
        ox('Cate'); {#280}
        ox('Sue'); {#281}
        ox('Sue Ellen'); {#282}
        ox('Sheena'); {#283}
        ox('Starlight'); {#284}
        ox('Cleopatra'); {#285}
        ox('Sigrid'); {#286}
        ox('Antonina'); {#287}
        ox('Antonia'); {#288}
        ox('Frigid'); {#289}
        ox('Ariadne'); {#290}
        ox('Scarlet'); {#291}
        ox('Blenda'); {#292}
        ox('Daphne'); {#293}
        ox('Roberta'); {#294}
        ox('Athena'); {#295}
        ox('Eudoxhia'); {#296}
        ox('Euphemia'); {#297}
        ox('Filippa'); {#298}
        ox('Sofia'); {#299}
        ox('Sophie'); {#300}
        ox('Lorietta'); {#301}

      end; {finished writing FEMALE children names}

    end; {case .end.}

    {close textfile}
    close_text(txt);
    Result := True;

  end else
  begin

    {unable to create file!}
    unable_to_create(tempfilename, 5);
    Result := False;

  end;

  {return result}
  create_childrenfile := Result;

end; {create_childrenfile *end*}


end. {Unit File_IO2 .END.}
