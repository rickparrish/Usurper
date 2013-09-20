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


unit Cms; {Usurper Editor - The Excellent DoorGame}

interface

{CM commands used by Usurper Editor, all button commands}

 {the HC commands are here as well (help & hints)
  edit init.pas for hc comments (hint text lines)

  see EDHELP.TXT for the raw help text
  run makehelp.bat to create updated .HLP file}

const

  {used by listbox}
  cmConfig        = 100;   {only 100-255 is available in Turbo Vision}
  cmPEditor       = 102;
  cmResetGame     = 103;
  cmResetData     = 104;
  cmNpcEditor     = 105;
  cmItemEditor    = 106;
  cmMonEditor     = 107;
  cmDoorEditor    = 108;
  cmMoreEditors   = 109;
  cmAbout         = 110;
  cmMain          = 111;

  cmReset         = 140;
  cmDocFiles      = 141;

  {text files, that can be viewed from the editor}
  cmWhatsNew      = 142;
  cmSysopDoc      = 143;
  cmUsurperDoc    = 144;
  cmReadMe        = 145;
  cmFutureDoc     = 146;
  cmSupportDoc    = 147;

  {Config Editor}
  CatchNum        = 150; {edit # config option}
  CmNewConf       = 151; {create new config}
  CmCGoto         = 152; {goto # config option}
  CmCSearch       = 153; {search for keyword}
  CmCToggle       = 154; {toggle yes/no option}

  {Player/NPC Editor}
  CmPMore         = 159; {page 2 i player/npc editorn}
  CmPDelete       = 160; {page 2 i player/npc editor-delete/revive character}
  CmPNext         = 162; {goto NEXT player in file}
  CmPPrev         = 163; {goto PREVIOUS player in file}
  CmPCreat        = 164; {create new character}
  CmPSearch       = 165; {search for character}
  CmPCreate       = 166; {create new npc/player}
  CmPEquip        = 167; {equipment dialog}
  CmPELhand       = 168; {          change left hand}
  CmPERhand       = 169; {          right hand}
  CmPEHead        = 170;
  CmPEBody        = 171;
  CmPEArms        = 172;
  CmPELFing       = 173;
  CmPERFing       = 174;
  CmPELegs        = 175;
  CmPEFeet        = 176;
  CmPEWaist       = 177;
  CmPELNeck       = 178;
  CmPERNeck       = 179;
  CmPEFace        = 180;
  CmPEShield      = 181;
  CmPEHands       = 182;
  CmPEAbody       = 183;

  cmEqCatchMe     = 184; {user selects item in listbox}
  cmEqNone        = 185; {item shall be removed from (for example): right hand}
  cmEqRemoveAll   = 186; {remove all PLAYER items}
  cmEqSearch      = 187;
  cmEqAutoEquip   = 188; {equip player/npc}
  cmEqInventory   = 189; {user/check inventory}
  cmInv01         = 190;
  cmInv02         = 191;
  cmInv03         = 192;
  cmInv04         = 193;
  cmInv05         = 194;
  cmInv06         = 195;
  cmInv07         = 196;
  cmInv08         = 197;
  cmInv09         = 198;
  cmInv10         = 199;
  cmInv11         = 200;
  cmInv12         = 201;
  cmInv13         = 202;
  cmInv14         = 203;
  cmInv15         = 204;
  cmInvCatchMe    = 205;
  cmInvRemoveAll  = 206;
  cmItemInfo      = 207;
  cmRemoveCurrent = 208;
  cmSWeap         = 209;
  cmShield        = 210;
  cmSHead         = 211;
  cmSBody         = 212;
  cmSArms         = 213;
  cmSHands        = 214;
  cmSFing         = 215;
  cmSLegs         = 216;
  cmSFeet         = 217;
  cmSWaist        = 218;
  cmSNeck         = 219;
  cmSFace         = 220;
  cmSFood         = 221;
  cmSDrink        = 222;
  cmSAbody        = 223;

  cmPWeapOld      = 224; {equipment dialog for classic mode}
  cmPArmOld       = 225; {same as above}

  CmMWeapSel      = 226; {monster editor, choose weapon}
  CmMArmSel       = 227; {monster editor, choose armor}
  CmMGoto         = 228; {monster editor, goto # monster}
  CmMGlobal       = 229; {monster editor, global monster commands}
  CmMGrmvSpells   = 230; {monster editor, global command: remove all spells}

  CmRestrict      = 260; {item editor, class restrictions}
  CmIType         = 261; {item editor, selects ITEM TYPE}
  CmIOptions      = 262; {item editor, file operations}
  CmImport        = 263; {used by above}
  CmExport        = 264; {used by above}

  CmPhrases       = 265; {go to phrases dialog box, from player editor page2/2}

  {options menu}
  CmOptions       = 300;
  CmOptionsToggle = 301;
  CmODosShell     = 302;

  {more editors menu}
  CmLevelEditor   = 400; {level editor}
  CmDrinkEditor   = 401;
  CmDrinkViewIng  = 402; {view drink ingredients}
  CmMoatEditor    = 403; {moat creatures editor}
  CmGodEditor     = 404; {god editor}
  CmChildEditor   = 405; {child editor}

  CmViewFile      = 900; {view a textfile}

  CmNothing       = 1000;


  {*** Help Context Constants ***}{edhelp.txt}
      {remember that changing the # must be followed by similar change
       to edhelp.txt, then run makehelp.bat to update helpfile}

  hcMainHelp = 1;
  hcAdios = 2;
  hcConfig = 3;
  hcAbout = 4;
  hcPlayerEditor = 5;
  {6 is empty!}
  {7 is empty!}
  hcDoorGuardEditor = 8;
  hcItemEditor = 9;
  hcMonsterEditor = 10;
  hcResetGame = 11;
  hcResetData = 12;

  hcLevelfile = 13;     {don't change the order of the following range}
  hcDoorGuardfile = 14; {without changing RESET_DATAFILES proc}
  hcItemfile = 15;
  hcMonsterfile = 16;
  hcArmorfile = 17;
  hcWeaponfile = 18;
  hcNpcFile = 19;
  hcTeamNamefile = 20;
  hcMoatFile = 21;
  {range caution .end.}

  hcLevEdExpNeed = 22; {level editor, xp needed}
  hcDocFiles = 23; {docfiles}
  hcMoreEditors = 24; {more.. from main menu}

  {files to view}
  hcViewFile = 50;
  hcWhatsNew = 51; {whats.new file}
  hcSysopDoc = 52;
  hcUsurperDoc = 53;
  hcReadMe = 54;
  hcFutureDoc = 55;
  hcSupportDoc = 56;

  {options menu}
  hcOptions = 60;
  hcOptionsToggle = 61;
  hcODosShell = 62;

  {more editors menu}
  HcLevelEditor = 71;
  HcGodEditor = 72;
  HcChildEditor = 73;

  {doorguard related}
  hcDGname = 100;
  hcDGcost = 101;
  hcDGmany = 102;
  hcDGmany2 = 103;
  hcDGdesc = 104;
  hcDGcreate = 105;
  hcDGHitpoints = 106;
  hcDGBaseArmor = 107;
  hcDGBaseAttack = 108;
  hcDGSearch = 109; {search for guard}

  {drink editor related}
  HcDrinkEditor = 600; {drink editor}
  hcDrinkName = 601; {drink name}
  hcDrinkDate = 602; {date when drink was created}
  hcDrinkCreator = 603; {name of user who created the drink}
  hcDrinkComment = 604; {comment to drink}
  hcDrinkOrdered = 605; {drink has been ordered # number of times}
  hcDrinkLastHad = 606; {drink was last had by this person}
  hcDrinkLastOrdered = 607; {drink was last ordered this date}
  hcDrinkSecret = 608; {secret recipe}
  hcDrinkSecret2 = 609; {#}
  hcDrinkDeleted = 610; {deleted}
  hcDrinkDeleted2 = 611; {#}
  hcDrinkSearch = 612; {search for drink}
  hcDrinkViewIng = 613; {view drink ingredients}

  {moat editor related}
  hcMoatEditor = 630; {moat editor}
  hcMoatName = 631; {moat creature name}
  hcMoatCost = 632; {name of user who created the drink}
  hcMoatHps = 633; {hitpoints}
  hcMoatBaseArmor = 634; {drink has been ordered # number of times}
  hcMoatBaseAttack = 635; {drink was last had by this person}
  hcMoatDesc = 636; {description}
  hcMoatDeleted = 637; {deleted}
  hcMoatDeleted2 = 638; {#}
  hcMoatSearch = 639; {search for drink}
  hcMoatCreate = 640; {create a new moat creature}

  {PLAYER/NPC Editor Page [2/2]}
  {phrases editor box}
  hcPeditPhrases = 650;
  hcPeditBattleCry = 651;
  hcPeditPhrase1 = 652;
  hcPeditPhrase2 = 653;
  hcPeditPhrase3 = 654;
  hcPeditPhrase4 = 655;
  hcPeditPhrase5 = 656;
  hcPeditPhrase6 = 657;

  {MONSTER EDITOR related}
  hcMeditSearch = 300;
  hcMeditGoto = 301;
  hcMeditMonster = 302;
  hcMeditHitpoints = 303;
  hcMeditPhrase = 304;
  hcMeditMagicRes = 305;
  hcMeditMagicLev = 306;
  hcMeditStrength = 307;
  hcMeditDefence = 308;
  hcMeditIQ = 309;
  hcMeditEvil = 310;
  hcMeditWeapon = 311;
  hcMeditArmor = 312;
  hcMeditGrabWeapon = 313; {ranged start}
  hcMeditGrabWeap2 = 314;
  hcMeditGrabArmor = 315;
  hcMeditGrabArm2 = 316;   {ranged end}
  hcMeditGlobal = 317;     {global monster commands}
  hcMeditGRmvSpells = 318; {global monster command: remove all spells}
  hcMeditSpells1 = 350;    {ranged start}
  hcMeditSpells2 = 351;
  hcMeditSpells3 = 352;
  hcMeditSpells4 = 353;
  hcMeditSpells5 = 354;
  hcMeditSpells6 = 355; {ranged end}

  {ITEM EDITOR related}
  hcItemName = 400;
  hcItemValue = 401;
  hcItemAttack = 402;
  hcItemArmor = 403;
  hcItemDesc1 = 404;
  hcItemDesc2 = 405;
  hcItemStore = 406;
  hcItemFound = 407;
  hcItemAtlevel1 = 408;
  hcItemAtLevel2 = 409;
  hcItemHps = 410;
  hcItemStamina = 411;
  hcItemAgility = 412;
  hcItemCharisma = 413;
  hcItemDexterity = 414;
  hcItemWisdom = 415;
  hcItemMana = 416;
  hcItemStrength = 417;
  hcItemDefence = 418;
  hcItemStrNeed = 419;

  hcItemGood1 = 421;
  hcItemGood2 = 422;

  hcItemEvil1 = 423;
  hcItemEvil2 = 424;

  hcItemCursed1 = 425;
  hcItemCursed2 = 426;

  hcItemRestrict = 427;

  hcItemSearch = 430;
  hcItemCreate = 431;
  hcItemType = 432;
  hcItemOptions = 433;
  hcItemImport = 434;
  hcItemExport = 435;
  hcItemRemove = 436;
  hcItemInfo = 437;

  hcItemCure1 = 441;
  hcItemCure2 = 442;
  hcItemCure3 = 443;
  hcItemCure4 = 444;
  hcItemCure5 = 445;
  hcItemCure6 = 446;
  hcItemCure7 = 447;

  {CONFIG RELATED}
  hcConfigNew = 480;
  hcConfigGoto = 481;
  hcConfigSearch = 482;
  hcConfigToggle = 483;

  {PLAYER/NPC EDITOR related}
  hcPeditDelete = 500;
  hcPeditRevive = 501;
  hcPeditEquip = 502;
  hcPeditMore = 503;
  hcPeditSearch = 504;
  hcPeditCreate = 505;
  hcPeditName = 506;
  hcPeditAlias = 507;
  hcPeditMoney = 508;
  hcPeditBank = 509;
  hcPeditExperience = 510;
  hcPeditHealings = 511;
  hcPeditDngFights = 512;
  hcPeditPlyFights = 513;
  hcPeditTeamFights = 514;
  hcPeditTeam = 515;
  hcPeditPassWord = 516;
  {517 is free!!}
  hcPeditMental = 518;
  hcPeditDrugAddict = 519;
  hcPeditThefts = 520;
  hcPeditBrawls = 521;
  hcPeditTrainings = 522;
  hcPeditControl1 = 524;
  hcPeditControl2 = 525;
  hcPeditGender1 = 526;
  hcPeditGender2 = 527;
  hcPeditKing1 = 528;
  hcPeditKing2 = 529;
  hcPeditAllowed1 = 530;
  hcPeditAllowed2 = 531;
  hcPeditLevel = 533;
  hcPeditHps = 534;
  hcPeditMaxhps = 535;
  hcPeditAge = 536;
  hcPeditChivalry = 537;
  hcPeditDarkness = 538;
  hcPeditStrength = 539;
  hcPeditDefence = 540;
  hcPeditGoodDeeds = 541;
  hcPeditEvilDeeds = 542;
  hcPeditMana = 543;
  hcPeditMaxMana = 544;
  hcPeditStamina = 545;
  hcPeditAgility = 546;
  hcPeditCharisma = 547;
  hcPeditDexterity = 548;
  hcPeditWisdom = 549;

  hcPeditRace1 = 561;
  hcPeditRace2 = 562;
  hcPeditRace3 = 563;
  hcPeditRace4 = 564;
  hcPeditRace5 = 565;
  hcPeditRace6 = 566;
  hcPeditRace7 = 567;
  hcPeditRace8 = 568;
  hcPeditRace9 = 569;
  hcPeditRace10 = 570;

  hcPeditClass1 = 581;
  hcPeditClass2 = 582;
  hcPeditClass3 = 583;
  hcPeditClass4 = 584;
  hcPeditClass5 = 585;
  hcPeditClass6 = 586;
  hcPeditClass7 = 587;
  hcPeditClass8 = 588;
  hcPeditClass9 = 589;
  hcPeditClass10 = 590;
  hcPeditClass11 = 591;

  {PLAYER/NPC EDITOR Page [2/2]}
  {magican spells}
  hcPeditSpells1 = 206; {ranged start}
  hcPeditSpells2 = 207;
  hcPeditSpells3 = 208;
  hcPeditSpells4 = 209;
  hcPeditSpells5 = 210;
  hcPeditSpells6 = 211;
  hcPeditSpells7 = 212;
  hcPeditSpells8 = 213;
  hcPeditSpells9 = 214;
  hcPeditSpells10 = 215;
  hcPeditSpells11 = 216;
  hcPeditSpells12 = 217; {ranged end}
  {cleric spell help}
  hcPeditSpells20 = 230; {ranged start}
  hcPeditSpells21 = 231;
  hcPeditSpells22 = 232;
  hcPeditSpells23 = 233;
  hcPeditSpells24 = 234;
  hcPeditSpells25 = 235;
  hcPeditSpells26 = 236;
  hcPeditSpells27 = 237;
  hcPeditSpells28 = 238;
  hcPeditSpells29 = 239;
  hcPeditSpells30 = 240;
  hcPeditSpells31 = 241; {ranged end}

  {sage spell help}
  hcPeditSpells35 = 250; {ranged start}
  hcPeditSpells36 = 251;
  hcPeditSpells37 = 252;
  hcPeditSpells38 = 253;
  hcPeditSpells39 = 254;
  hcPeditSpells40 = 255;
  hcPeditSpells41 = 256;
  hcPeditSpells42 = 257;
  hcPeditSpells43 = 258;
  hcPeditSpells44 = 259;
  hcPeditSpells45 = 260;
  hcPeditSpells46 = 261; {ranged end}

  hcPeditDesc = 270;
  hcPeditNeverDel = 271;
  hcPeditDis1 = 272;
  hcPeditDis2 = 273;
  hcPeditDis3 = 274;
  hcPeditDis4 = 275;
  hcPeditDis5 = 276;

  hcPeditMaxTime = 277;

  hcPeditMove1 = 281;
  hcPeditMove2 = 282;
  hcPeditMove3 = 283;
  hcPeditMove4 = 284;
  hcPeditMove5 = 285;
  hcPeditMove6 = 286;
  hcPeditMove7 = 287;
  hcPeditMove8 = 288;
  hcPeditMove9 = 289;
  hcPeditMove10 = 290;
  hcPeditMove11 = 291;
  hcPeditMove12 = 292;
  hcPeditMove13 = 293;
  hcPeditMove14 = 294;

  hcPeditMKills = 295;
  hcPeditMDefeats = 296;
  hcPeditPKills = 297;
  hcPeditPDefeats = 298;

  {Equipment Dialog (NEW)}
  hcEquipLeftHand = 800;
  hcEquipRightHand = 801;
  hcEquipHead = 802;
  hcEquipBody = 803;
  hcEquipArms = 804;
  hcEquipFinger1 = 805;
  hcEquipFinger2 = 806;
  hcEquipLegs = 807;
  hcEquipFeet = 808;
  hcEquipWaist = 809;
  hcEquipNeck1 = 810;
  hcEquipNeck2 = 811;
  hcEquipFace = 812;
  hcEquipShield = 813;
  hcEquipHands = 814;
  hcEquipABody = 815;
  hcEquipWeapon = 816;
  hcEquipFingers = 817;
  hcEquipNecks = 818;
  hcEquipFood = 819;
  hcEquipDrink = 820;

  hcAutoEquip = 850;
  hcRemoveAll = 851;

  {Equipment Dialog (Classic)}
  hcClassicWeapon = 870;
  hcClassicArmor = 871;
  hcClassicNone = 872;

  {Inventory}
  hcInventory = 900;
  hcInventoryItem = 901;
  hcInventoryRemove = 902;

  {GENERAL BUTTONS - used on various locations in the program}
  hcGenOk = 4000;
  hcGenCancel = 4001;
  hcGenPrevious = 4002;
  hcGenNext = 4003;
  hcGenNumeric = 4004;
  hcGenFileName = 4005;
  hcGenString = 4006;
  hcGenGoto = 4007;
  hcGenSearch = 4008;
  hcGenYes = 4009;
  hcGenNo = 4010;

  HcNada = 5001; {empty string}

 {*** Help Context Constants  END ***}

implementation

end. {Unit Cms .end.}
