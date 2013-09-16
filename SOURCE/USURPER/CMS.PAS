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


Unit CMS; {Usurper - Constants (not all of them are here!)}
          {many are located in 'init.pas'}
Interface

const

 {used when the royals are mass-communicating to all subjects}
 global_destination = '*ALL SUBJECTS*';

 {'ear information', onlinerec.ear= reads one of these values}
 global_ear_all     =1;
 global_ear_personal=2;
 global_ear_quiet   =3;

 {player vs monster battle, type of situation. used when calling fight routine}
 pl_vs_monster     =1; {player vs dungeon monsters}
 pl_vs_doorguards  =2; {player vs door guards}
 pl_vs_supreme     =3; {player vs supreme being}
 pl_vs_demon       =4; {player vs demon}
 pl_vs_alchemist   =5; {player vs alchemist opponent}
 pl_vs_prisonguards=6; {player vs prison guards (attempting to free a friend}


 {Relations Constants, used in relations situations}
 {if you decide to edit/add these then you must update the
  following : relation.pas, relatio2.pas

  not complete .pas list, *jakob*}

 global_RelationMarried     = 10;
 global_RelationLove        = 20;
 global_RelationPassion     = 30;
 global_RelationFriendship  = 40;
 global_RelationTrust       = 50;
 global_RelationRespect     = 60;

 global_RelationNone        = 1; {returned by social_relation}
 global_RelationNormal      = 70; {default relation value}

 global_RelationSuspicious  = 80;
 global_RelationAnger       = 90;
 global_RelationEnemy       = 100;
 global_RelationHate        = 110;
 {RELATION CONSTANTS *END*}

const {mail requests constants, used to create special "request" or
       "event" mail}
 mailrequest_Nothing   = 0; {used when posting regular mail}
 mailrequest_BeMyGuard = 1; {King would like to hire receiver as guard}
 mailrequest_IWantGuard= 2; {Player applies for guard duty to the king}
 mailrequest_DrinkOffer= 3; {Player is offered a drink by sender}

 {immortal}
 mailrequest_ImmortalOffer=40; {immortal wants to recruit receiver}

 mailrequest_RoyalAngel  =50; {king has sent a healing angel (court mage)}
 mailrequest_RoyalAvenger=51; {king has sent a dark avenger (court mage)}

 mailrequest_QuestOffer  =60; {king has offered player a Quest (quest.id)}
 mailrequest_Birthday    =61; {player celebrates birthday}

 {relation}
 mailrequest_HoldHands=70; {sender wants to hold hands with receiver. (y/n)}
 mailrequest_Roses    =71; {sender sends bouquet of roses to receiver. (y/n)}
 mailrequest_Poison   =72; {sender sends poison to receiver (y/n)}
 mailrequest_Dinner   =73; {sender wants to have dinner with receiver (y/n)}
 mailrequest_Scorpions=74; {sender sends scorpions to receiver, open box?}
 mailrequest_Chocolate=75; {sender sends a box of chocolates to receiver, open box?}
 mailrequest_Kiss     =76; {sender wants to kiss receiver (y/n)}

 {home}
 mailrequest_HaveSex         =77; {sender wants to have (in marriage) sex with receiver}
 mailrequest_HaveDiscreteSex =78; {sender wants to have (out of marriage) sex with receiver}

 {children}
 mailrequest_ScanForBabies     =79; {receiver must scan for new babies to name}
 mailrequest_ChildRaisingExp   =80; {receiver gets experience points for raising his child}
 mailrequest_ChildPoisonedExp  =81; {receiver loses experience points for grieving over poisoned child}
 mailrequest_ChildFightExp     =82; {receiver gets experience points for won kid fight}
 mailrequest_SilentExp         =83; {receiver gets experience points, without being notified}
 mailrequest_ChildCursedExp    =84; {receiver loses experience points for grieving over cursed child}
 mailrequest_ChildDepressedExp =85; {receiver loses experience points for depressed child (divorce)}

 {Gym}
 mailrequest_GymMembership =89; {receiver must say YES or NO to senders application for gym card}

 {team}
 mailrequest_jointeam = 90; {sender wants to join receivers gang}

 {*NO MAILREQUEST OVER 128* SINCE YOU ARE USING A BYTE VALUE!}

const {broadcast message constants, sent to other nodes, online}

 {note: the solution below with string constants is not a good one!
        I'm lazy and haven't bothered to change this yet}

 broadcast_MortalEnteredGame = 'enter†ll'; {player entered game}
 broadcast_GodEnteredGame    = 'enter„ll'; {god entered game}

 broadcast_kingenter    = 'king†ll';  {king entered game}
 broadcast_queenenter   = 'queen†ll'; {queen entered}
 broadcast_exitalive    = 'bye†ll'; {exit alive}
 broadcast_exitdead     = 'bye†ll-'; {exit dead}
 broadcast_senttoprison = 'ÏÏpris-'; {sent to prison}
 broadcast_sentmoney    = '@@@@@@+'; {sent money}
 broadcast_changeteampw = '@@@@@@-'; {team password has changed}
 broadcast_removeturf   = '@@@@@@='; {player must remove his town control flags}
 broadcast_addgym       = '„”†„”1'; {player must add his gym_owner flag}
 broadcast_removegymcard= '„”„”„2'; {player has been tossed out from the Gym}
 broadcast_newgymcard   = '„”„”„3'; {player has been invited to the Gym}
 broadcast_removegym    = '„”„”„4'; {player is no longer owner to Gym}

 {king/royal guard broadcasts}
 broadcast_kingwantsyou   = '™a'; {king has sent message/request to player to become guard}
 broadcast_refusedguard   = '™b'; {player refused to become royal guard}
 broadcast_noroomforguard = '™c'; {player tried to become royal guard, but there was no room}
 broadcast_IbecameGuard   = '™d'; {player became royal guard!}
 broadcast_YouAreSacked   = '™e'; {player was sacked from Guard Job, by the king}
 broadcast_IQuitasGuard   = '™f'; {player quits his job as royal guard}
 broadcast_IWanttobeGuard = '™g'; {player has applied for guard duty}
 broadcast_YoubecameGuard = '™h'; {player became royal guard!}
 broadcast_NoRoomForYou   = '™i'; {player failed application because guard force was full}

 {royal magic}
 broadcast_RoyalAngel     = '™j'; {player receives a Angel from the king}
 broadcast_RoyalAngelLand = '™k'; {receit of the above, to the sender}
 broadcast_RoyalAvenger   = '™l'; {player receives a Dark Avenger from the king}
 broadcast_RoyalAvengerLand = '™m'; {receit of the above, to the sender}

 {prison}
 broadcast_CellDoorOpens  = '™n'; {imprisoned player sees the cell door swing open! rescued!}
 {royal referendum}
 broadcast_ResetKingVote  = '™o'; {king has been removed. reset "vote for king" day counter}
 {king relieves subject from taxes}
 broadcast_TaxRelieved    = '™p';
 {king reinstates subject to taxes}
 broadcast_TaxReinstate   = '™q';

 {team}
 broadcast_JoinTeam = '™r'; {receiver allowed to join team}

 {gods receive messages}
 broadcast_GodDesecrated = '™™™1'; {player has desecrated gods altar}
 broadcast_GodSacrificed = '™™™2'; {player has sacrificed at gods altar}

 {relations}
 broadcast_HoldingHands = '™™b'; {sender has dated (hands) receiver! cool!}
 broadcast_BouquetRoses = '™™c'; {sender has dated receiver! cool!}
 broadcast_Poison       = '™™d'; {sender has sent poison to receiver!}
 broadcast_Dinner       = '™™e'; {sender has dated (dinner) receiver! cool!}
 broadcast_Kiss         = '™™f'; {sender has dated (kissed) receiver}

 broadcast_HaveSex         = '™™g'; {sender had (in marriage) sex with receiver!}
 broadcast_HaveDiscreteSex = '™™h'; {sender had (out of marriage) sex with receiver!}
 {children related}
 broadcast_ChildPartyExp   = '™™i'; {receivers child has earned XP from party going}

const {player (offline) location constants}
 offloc_dormitory = 0;  {dormitory}

 offloc_innroom1  = 1; {inn, floor 1}
 offloc_innroom2  = 2; {inn, floor 2}
 offloc_innroom3  = 3; {inn, floor 3}
 offloc_innroom4  = 4; {inn, floor 4}

 offloc_beggarwall= 10; {beggars wall}

 offloc_castle    = 30; {castle}
 offloc_prison    = 40; {prison}

 offloc_home      = 50; {home}

const {player (online) location constants, onlinerec.location=onloc_church}

{When adding new location constants :
  update 'online.pas' =>online_desc (func)
  also update 'give_me_exits_from'}

 onloc_nowhere    = 0; {}
 onloc_mainstreet = 1;
 onloc_theinn     = 2;
 onloc_darkalley  = 3; {outside the shady shops}
 onloc_church     = 4;
 onloc_weaponshop = 5;
 onloc_master     = 6;
 onloc_magicshop  = 7;
 onloc_dungeons   = 8;
 onloc_deathmaze  = 9;
 onloc_madmage    = 17; {groggos shop, reached from shady shops}
 onloc_armorshop  = 18;
 onloc_bank       = 19;
 onloc_reportroom = 20;
 onloc_healer     = 21;
 onloc_marketplace= 22;
 onloc_foodstore  = 23;
 onloc_plymarket  = 24;
 onloc_recruit    = 25; {hall of recruitment, recruite.pas}
 onloc_dormitory  = 26;
 onloc_anchorroad = 27;
 onloc_orbs       = 28;
 onloc_orbs_mixing= 29; {mixing own drink at orbs bar}
 onloc_orbs_browse= 30; {browsing drink file at orbs bar}

 onloc_bobsbeer   = 31; {Bobs Beer Hut}
 onloc_alchemist  = 32;
 onloc_steroids   = 33;
 onloc_drugs      = 34;
 onloc_darkness   = 35;
 onloc_whores     = 36;
 onloc_darkeralley= 37;
 onloc_gigolos    = 38;
 onloc_outsideinn = 39;
 onloc_onaraid    = 40;
 onloc_teamcorner = 41;
 onloc_mystic     = 42;
 onloc_robbingbank= 43;
 onloc_bountyroom = 44;
 onloc_readingnews= 45;
 onloc_checkplys  = 46;
 onloc_temple     = 47; {altar of the gods}
 onloc_bobthieves = 48;
 onloc_bobdrink   = 49; {beer drinking competiton}
 onloc_umanrest   = 50;
 onloc_umantame   = 51;
 onloc_umanwrest  = 52;
 onloc_innfight   = 53;
 onloc_dormfight  = 54; {fight in the dormitory}
 onloc_entering   = 55; {entering game}
 onloc_gangprep   = 56; {attacking/viewing other teams}
 onloc_readingmail= 57; {reading mail, scanning news}
 onloc_postingmail= 58; {posting mail/writing letter}
 onloc_combmaster = 59; {visiting Liu Zei, close combat master, at the market place}
 onloc_dormfists  = 60; {fistfight at the Dormitory}
 onloc_gymfists   = 61; {fistfight at the Gym}
 onloc_temples    = 62; {temple of the gods, temple.pas. 't' from the challenge menu}
 onloc_The_Gym    = 63; {the gym}
 onloc_MultiChat  = 64; {Multi Node Chat at the Inn - IMPORTANT! when this
                         location is entered then usurper will scan for IPC
                         files at every "wait for key" state, see ddplus.pas}

 onloc_outsideGym = 65; {outside the gym}
 onloc_gossipmonger = 66; {gossip monger [Lydia], at lovers.pas}
 onloc_lovehistory  = 67; {love history room, at lovers.pas}
 onloc_beggarswall  = 68; {beggars wall, reached from the marketplace}

 onloc_castle     = 70; {royal castle}
 onloc_royalmail  = 71; {reading royal mail (in the castle), scanning news}
 onloc_courtmage  = 72; {visiting court magician}
 onloc_warchamber = 73; {visiting war chamber}
 onloc_questmaster= 74; {royal quest master}
 onloc_questhall  = 75; {player visiting quest hall}
 onloc_QuestAttemp= 76; {player attempts a [monster] quest}
 onloc_royOrphanag= 77; {royal orphanage}

 onloc_guardoffice= 80; {players applying for guard jobs or quitting}
 onloc_outcastle  = 81; {players outside the Castle, deciding what to do}

 onloc_prison     = 90; {king visiting prison}
 onloc_prisoner   = 91; {prisoners in their cells}
 onloc_prisonerop = 92; {prisoner, but the cell door is open}
 onloc_prisonerex = 93; {prisoner, execution}
 onloc_prisonwalk = 94; {outside the prison}
 onloc_prisonbreak= 95; {outside the prison, attempting to liberate a prisoner}
 onloc_chestloot  = 96; {stealing chest items}

 {relations locations}
 onloc_lovestreet = 200; {love street}
 onloc_home       = 201; {managing family affairs}
 onloc_nursery    = 202; {in the childrens room}
 onloc_kidnapper  = 203; {home and maintaining kidnapped children}
 onloc_giftshop   = 204; {visiting gift-shop}

 onloc_icecaves   = 300;

 {god - immortal areas}
 onloc_heaven = 400;
 onloc_heaven_boss = 401; {visiting boss god}

 onloc_closed = 30000; {used by fakeplayers when deciding where to go.
                        see 'online.pas' and procedure 'give_me_exits_from'}

 {Child location constants
  see relatio2.pas => child_location_string}
 ChildLocation_Home     = 0; {home with parents, default}
 ChildLocation_Orphanage= 1; {royal orphanage}
 ChildLocation_Kidnapped= 2; {kidnapped}
 {Child health constants .. see relatio2.pas => child_health_string}
 ChildHealth_Normal    = 0; {normal health, default}
 ChildHealth_Poisoned  = 1; {poisoned}
 ChildHealth_Cursed    = 2; {cursed, curses can only be ordained by Gods}
 ChildHealth_Depressed = 3; {depressed after a divorce}

 {Graphic files (ANS/ASC) located in the DATA\USUTEXT.DAT file}
 {displayed with "show_usurper_data(name,pauseboolean)" }
 Picture_Crown       = 'CROWN'; {royal crown}
 Picture_Death_Head  = 'DEATH_HEAD'; {grinning skull}
 Picture_Ice_Caves   = 'ICE_CAVES'; {ice caves, entrance pic}
 Picture_Old_Man     = 'OLD_MAN'; {old man}
 Picture_Heart       = 'HEART'; {romantic heart}
 Picture_Small_Heart = 'SMALL_HEART'; {small romantic heart}
 Picture_Final_Doors = 'FINAL_DOORS'; {final doors to supreme being (last monster)}
 Picture_Supreme     = 'SUPREME_BEING'; {the final monster}
 Picture_Game_Finis  = 'GAME_COMPLETED'; {player completed the game}

 {constants used by online node<->node internode routines}
 intercom_empty     = ' '; {clean, dummy var}
 intercom_accept    = '+'; {say yes}
 intercom_decline   = '-'; {say no}
 intercom_sendstuff = '!'; {propose to trade with other player}
 intercom_challenge = '"'; {challenge player, online fight}
 intercom_release   = '#'; {release prisoner (who is online) in jail}
 intercom_execute   = 'Ï'; {execute prisoner (who is online) in jail}

Implementation

begin {put init code here}

end. {Unit CMS .end.}
