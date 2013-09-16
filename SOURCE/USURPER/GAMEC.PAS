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


Unit Gamec; {Usurper - Main Street}

Interface

Procedure Game;

Implementation

Uses DDplus, Cms, Init,
     Jakob, Statusc, LevMast,
     Dungeonc, Darkc, Goodc,
     News, SortPl, Shady,
     Suicid, Magic, Challeng,
     Market, Innc, Healerc,
     Weapshop, Rating, Bank,
     Armshop, Prisonc, Lovers,
     Home, Various, Various2,
     Various3, Mail, Online,
     Relation, Relatio2, Children,
     File_Io, SysUtils;

var
    refresh : boolean;
    town_name : s70; {name of town, fetched from .CFG}

Procedure Meny;
const offset = 18;
begin
 d(5,'Main street of '+ulcyan+town_name+config.textcol1);
 crlf;

 menu2(ljust('(S)tatus',offset));
 menu2(ljust('(G)ood Deeds',offset));
 sd(config.textcolor,'(');
 sd(5,'Ctrl+W');
 d(config.textcolor,') Who is Online?');

 menu2(ljust('(D)ungeons',offset));
 menu2(ljust('(E)vil Deeds',offset));
 sd(config.textcolor,'(');
 sd(5,'Ctrl+T');
 d(config.textcolor,') Send message to online player');

 menu2(ljust('(B)ank',offset));
 menu2(ljust('(V)isit Master',offset));
 menu('(1) Send stuff to online player');

 menu2(ljust('(I)nn',offset));
 menu2(ljust('(M)agic Shop',offset));
 menu('(2) Healing Hut');


 menu2(ljust('(C)hallenges',offset));
 menu('(N)ews of Today/Yesterday');

 menu2(ljust('(A)rmor Shop',offset));
 menu('(L)ist of Characters');

 menu2(ljust('(W)eapon Store',offset));
 menu('(T)he Marketplace');

 menu2(ljust('(Q)uit Game',offset));
 menu('(X)tra Shops');

 menu2(ljust('(H)ome',offset));
 menu('(R)elations, Love & Hate');

 menu('(F)ame');

 menu('(*) Suicide');

end; {meny *end*}

Procedure Main_Menu(force, short : boolean);
begin

 if short then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    clearscreen;
    meny;
   end;
   crlf;
   sd(config.textcolor,'Main Street ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin
   crlf;
   sd(config.textcolor,'Main (S,G,F,D,E,B,V,I,M,C,N,A,L,W,T,Q,X,H,R,!,*,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   clearscreen;
   meny;
  end;
 end;

end; {main_menu *end*}

Function Gimme_Relation_Constant:word;
var
    ch : char;
    result:word;
begin {debug purposes only. remove when sharp version is released.}

 {init}
 result:=global_relationNormal;

 menu('(1) Married');
 menu('(2) Love');
 menu('(3) Passion');
 menu('(4) Friendship');
 menu('(5) Trust');
 menu('(6) Respect');
 menu('(7) None');
 menu('(8) Suspicious');
 menu('(9) Anger');
 menu('(0) Enemy');
 menu('(A) Hate');
 sd(config.textcolor,':');

 {get user-input}
 repeat
  ch:=upcase(getchar);
 until ch in ['0'..'9','A'];

 case ch of
  '1': result:=global_RelationMarried;
  '2': result:=global_RelationLove;
  '3': result:=global_RelationPassion;
  '4': result:=global_RelationFriendship;
  '5': result:=global_RelationTrust;
  '6': result:=global_RelationRespect;
  '7': result:=global_RelationNormal;
  '8': result:=global_RelationSuspicious;
  '9': result:=global_RelationAnger;
  '0': result:=global_RelationEnemy;
  'A': result:=global_RelationHate;
 end; {case .end.}

 {return result}
 gimme_relation_constant:=result;

end; {gimme_relation_constant *end*}

Procedure Game;
const never : boolean = false;
      beggar_cost = 500; {cost to take a seat at the Beggars Wall}
var
    ch, cho : char;


    i, x : word;
    y : integer;

    done, {done is debug variable remove when sharp version is released}
    found,
    teamdngs,
    log_mortal_entrance : boolean;

    s : s100;
    s2: string[6];

    temp,
    temp2 : userrec; {jakob, remove when sharp version is released}
    child: childrec; {jakob, remove when sharp version is released}
    relation:relationrec; {jakob, remove when sharp version is released}

    bardsong : bardtype; {bardtype is defined in file_io.pas}

    king : kingrec; {oh boy! the King!}

begin

 {Save User}
 user_save(player);

 {Setup Online Record}
 if local then onliner.node:=global_onlocal
          else onliner.node:=global_cnode;

 onliner.name    :=player.name2;
 onliner.realname:=player.name1;
 onliner.location:=onloc_entering;
 onliner.doing   :=location_desc(onliner.location);
 onliner.arrived :=give_me_time;
 onliner.usertype:=online_player;
 onliner.shadow  :=false;
 onliner.dead    :=false;
 onliner.sex     :=player.sex;
 onliner.race    :=player.race;
 onliner.class   :=player.class;
 for i:=1 to global_maxnod do begin
  onliner.chatline[i]:=emptystr;
  onliner.chatsend[i]:=emptystr;
  onliner.info[i]    :=emptystr;
  onliner.infosend[i]:=emptystr;
 end;
 onliner.recnr:=0;
 onliner.ear  :=player.ear;
 onliner.bname:=emptystr;
 onliner.com  :=' ';
 onliner.comfile:=emptystr;

 {Add User to the Online user-file}
 if add_onliner(OAdd,onliner)=false then begin
  d(12,'Your character has been activated by another node.');
  d(12,'You must wait a while before you may enter.');
  crlf;

  player.name2:='';
  player.name1:='';

  pause;
  normal_exit;
 end;

 {Send a BroadCast to other nodes of player entry, THE KING has entered}
 if player.king then begin
  if player.sex=1 then online_send_to_all(broadcast_kingenter,onliner.name,'')
                  else online_send_to_all(broadcast_queenenter,onliner.name,'');

 end
 else begin
  online_send_to_all(broadcast_MortalEnteredGame,onliner.name,'');
 end;

 {name of town}
 town_name:=cfg_string(9);
 if town_name='' then town_name:='Valhalla';

 {allow multi node procs to be executed}
 global_multi:=true;

 {reading line 47 from .cfg = allow teams in the dungeons?}
 teamdngs:=true;
 s:=cfg_string(47);
 if UpperCase(s)='NO' then begin
  teamdngs:=false;
 end;

 {update status bar with player alias}
 {this is also used in godworld.pas}
 display_bar_status(true);

 {setup item to be found in the dungeons flags}
 setup_dungeonitems;

 {get "log player entrances in news" from .cfg}
 log_mortal_entrance:=true;
 s:=cfg_string(87);
 if UpperCase(s)='NO' then log_mortal_entrance:=false;

 if (player.king) and (log_mortal_entrance) then begin
  if player.sex=1 then s:='King'
                  else s:='Queen';

  case random(5) of
   0:begin
      newsy(true,
      config.textcol1+'The '+s,
      ' '+s+ukingc+' '+player.name2+config.textcol1+' is back at the Castle.',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');
     end;
   1:begin
      newsy(true,
      config.textcol1+'The '+s,
      ' '+s+ukingc+' '+player.name2+config.textcol1+' has arrived to Town.',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');
      end;
   2:begin
      newsy(true,
      config.textcol1+'The '+s,
      ' '+s+ukingc+' '+player.name2+config.textcol1+' has returned from a Mission.',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');
     end;
   3:begin
      newsy(true,
      config.textcol1+'The '+s,
      ' '+s+ukingc+' '+player.name2+config.textcol1+' loves '+sex3[player.sex]+' people!',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');
     end;
   4:begin
      newsy(true,
      config.textcol1+'The '+s,
      ' '+s+ukingc+' '+player.name2+config.textcol1+' takes care of '+sex3[player.sex]+' subjects!',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');
     end;

  end; {case .end.}

 end
 else begin {log regular player entrance}

  {log player entrance}
  x:=random(7);

  {prison news}
  if player.location=offloc_prison then begin
   x:=0;
  end
  else if x=0 then begin
   x:=1;
  end;

  if log_mortal_entrance then begin
   case x of
    0:begin
       newsy(true,
       config.textcol1+'Prison life',
       ' '+uplc+player.name2+config.textcol1+' is walking '+sex3[player.sex]+' small prison-cell.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    1:begin
       newsy(true,
       config.textcol1+'Player Active',
       ' '+uplc+player.name2+config.textcol1+' awoke from a restless sleep.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    2:begin

       if player.chiv>player.dark then begin
        s:='nice';
       end
       else begin
        s:='mean';
       end;

       newsy(true,
       'Entrance',
       ' '+uplc+player.name2+config.textcol1+' the '+s+' '+race_display(2,player.race,0)+' is back in Town.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    3:begin
       newsy(true,
       config.textcol1+'Terrorizer',
       ' '+uplc+player.name2+config.textcol1+' has returned to break a few bones.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    4:begin
       newsy(true,
       config.textcol1+'Regulator',
       ' '+uplc+player.name2+config.textcol1+' has arrived to settle a few disputes.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    5:begin
       newsy(true,
       config.textcol1+race_display(1,player.race,0)+' Hero',
       ' '+uplc+player.name2+config.textcol1+' returned from a Mission.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    6:begin
       newsy(true,
       config.textcol1+race_display(1,player.race,0),
       ' '+uplc+player.name2+config.textcol1+' arrived.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;

   end; {case .end.}

  end;
 end;

 {update online location}
 onliner.location:=onloc_readingmail;
 onliner.doing   :=location_desc(onliner.location);
 add_onliner(OUpdateLocation,onliner);

 {lets read our mail}
 crlf;
 case random(4) of
  0: sd(12,'Since your last visit ...');
  1: sd(12,'Opening the mail-bag ...');
  2: sd(12,'Your appearance has been noted ...');
  3: sd(12,'Gazing into your past ...');
  4: sd(12,'Your being observed ...');
 end; {case .end.}

 read_my_mail(player);

 {vote for king popularity}
 King_Popularity(player);

 {pause}
 pause;

 {inform player of pregnancy}
 if player.pregnancy>0 then begin
  crlf;
  d(15,'YOU ARE PREGNANT!');
  pause;
 end;

 {greet his majesty}
 if player.king then begin
  case player.sex of
   1: d(14,'Greetings your Majesty!');
   2: d(14,'Greeting your Highness!');
  end;
  d(config.textcolor,'Your wish is my command.');
  pause;
 end;

 {SORRY no bard songs in 0.18..not enough time =( }
 {display bard songs}
{ if (player.class=bard) and (config.bard_songs_allowed=true) then begin

  if global_utest=true then begin
   d(config.textcolor,'Welcome oh Bard '+uplc+player.name2+config.textcol1+'. These are the songs you know:');
  end;

  if player.level>1 then begin
  end;

  x:=0;
  y:=1;
  repeat
   if player.level>x then begin

    {init song record}
{    init_bard_song_data(bardsong);

    {fetch song}
{    if load_bardsong(bardsong,y)=true then begin
     {jakob}
{    end;
   end
   else break;

   inc(x,10);
   inc(y);

  until x>100;

 end; {bard song status -*-End-*-}


 {*status*}
 status(player);

 {display faith}
 if player.god<>'' then begin
  crlf;
  crlf;
  d(15,'*************************************************');
  d(15,'You believe in '+ugodc+player.god+config.textcol1);
  d(15,'*************************************************');
 end;


 {*Street Talk file*}
 crlf;
 crlf;
 crlf;

 if global_ansi then display_file(global_truthfile1)
                else display_file(global_truthfile2);

 crlf;
 if confirm('Say something','n')=true then begin
  d(config.textcolor,'Enter a line'+mkstring(64,'.')+'>');
  sd(11,':');
  s:=get_string(75);
  if s<>'' then begin
   if confirm('Write this','Y')=true then begin
    crlf;
    s:=' '+utalkc+s;
    Write_to_Truth_file(player.name2,s);
   end;
  end;
 end;

 {Update Online Status}
 onliner.doing:='entering game';
 add_onliner(OUpdateLocation,onliner);

 {unfinished quests?}
 x:=Claimed_Quests(player.name2);
 if x>0 then begin
  crlf;

  if x=1 then s2:='QUEST'
         else s2:='QUESTS';
  s:='YOU HAVE 99 '+commastr(x)+' UNFINISHED '+s2+'!';
  d(2,cool_string(length(s),'=','-',15,12));
  d(15,'YOU HAVE '+ucyan+commastr(x)+uwhite+' UNFINISHED '+s2+'!');
  d(2,cool_string(length(s),'=','-',15,12));

  pause;
 end;

 {report other players online}
 who_is_on(false,false);

 {main game loop .start.}
 repeat

  {update online location, only if necessary}
  if onliner.location<>onloc_mainstreet then begin
   refresh:=true;
   onliner.location:=onloc_mainstreet;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {should player "auto travel" to some place}
  case global_auto_probe of
   NoWhere:begin
            {display menu}
            main_menu(true,true);
            {get user-input}
            cho:=upcase(getchar);
            if cho='-' then cho:=' ';
           end;
   Slottet,
   Dormy:begin
          cho:='C';
         end;
   Prison:begin
           cho:='-';
          end;
   Inn:begin
             cho:='I';
            end;
   UmanCave:begin
             cho:='D';
            end;
   MainStreet:begin
               global_auto_probe:=NoWhere;
               cho:=' ';
              end;
   AtHome:begin
             cho:='H';
            end;

  end; {case .end.}


  {evaluate user-input}
  case cho of
   '!':begin {who is online}
        who_is_on(false,true);
       end;
   '1':begin {send items,money to another online player}
        crlf;
        send_stuff_online(true);
       end;
   '?':begin {display menu}
        if player.expert=true then main_menu(true,false)
                              else main_menu(false,false);
       end;
   '2':begin {healing hut}

        load_king(fload,king);

        if (king.shop_healing=false) and (player.king=false) then begin
         crlf;
         d(12,'The Healing Hut is closed! (The '+UpperCase(kingstring(king.sexy))+'s order!)');
        end
        else begin
         healer;
        end;

       end;
   'F':begin {rating and score room}
        crlf;
        crlf;
        d(config.textcolor,'You enter '+ucyan+'Hall of Fame'+config.textcol1+'.');
        crlf;
        ratings_and_scores(' ');
        crlf;
       end;

   'X':begin {shady shops}
        crlf;
        crlf;
        d(config.textcolor,'You enter the part of Town where the law seldom enters.');
        shady_shops;
       end;
   '-':begin {autowalk to prison}
        {player is just passing here on his way to prison}
        the_prison;
       end;
   '"':begin {debug, jakob}

        if global_utest then begin
         ch:='?';
         repeat

          crlf;
          if ch='?' then begin
           crlf;
           d(14,'Golden Opportunities');
           d(14,cool_string(20,'=','-',14,15));
           crlf;
           menu('(S)ysop editor');
           menu('(C)hild view');
           menu('(G)ive birth');
           menu('(N)pc set relations');
           menu('(M)arry NPC (set out to marry)');
           menu('(V)iew relations');
           menu('(E)dit relation');
           menu('(1) Check my spouse');
           menu('(D)uplicate check relations');
           menu('(A) Validate a relation records player index / userfile');
           menu('(B) Validate all relations (you can break out)');
           menu('(K)ing load');
           menu('(R)eturn');
           crlf;
          end;

          sd(config.textcolor,'Debug room ('+config.textcol2+'?'+config.textcol1+' for menu):');

          ch:=upcase(getchar);

          case ch of
           'K':begin {king load}
                load_king(fload,king);
                d(11,'The Kings name is: '+king.name);
                pause;
               end;
           'B':begin
                crlf;
                crlf;
                validate_all_relations(false);
               end;
           'A':begin
                crlf;
                crlf;
                d(13,'Validate (and correct) Relation Index for userrec player positions.');
                sd(2,'Relation# (0-'+commastr(fs(FsRelation))+'):');
                x:=get_number(0,fs(FsRelation));
                if x>0 then begin

                 load_relation(fload,relation,x);

                 if not relation.deleted then begin
                  if confirm(uplc+relation.name1+' and '+relation.name2+config.textcol1,'N')=true then begin
                   relation_checkplyrec(relation);
                  end;
                 end;

               end;

               end;

           'C':begin {child view}
                if Select_A_Child(player,
                                  child,
                                  AnyChild,
                                  ExcludeNone,
                                  true)=true then begin
                 clearscreen;
                 child_view(child);
                end;

               end;
           'D':begin {check for duplicate relations}
                crlf;
                crlf;
                d(2,'whos gonna get checked?');
                if select_character(temp,false)=true then begin
                 kill_duplicate_relations(temp,1);
                end;
               end;

           '1':begin {check_my_spouse}
                {check i player is married and to whom}
                crlf;
                crlf;
                d(2,'who do you wanna check for spouse');
                if select_character(temp,false)=true then begin
                 load_my_spouse(temp,temp2);
                 if (temp2.name2<>'') and (temp2.name1<>'') then begin
                  d(15,temp.name2+' is married to '+temp2.name2);
                 end
                 else begin
                  d(12,temp.name2+' isn''t married!');
                 end;
                end;

               end;
           'G':begin {give birth to pregnant player}

                crlf;
                crlf;
                d(2,'select pregnant character');
                if select_character(temp,false)=true then begin
                 if temp.pregnancy=0 then begin
                  d(12,temp.name2+' is not pregnant!');
                 end
                 else begin
                  d(15,'Processing '+temp.name2+'...');
                  give_birth(temp);
                 end;
                end;

               end;

           'E':begin {edit relation}
                crlf;
                crlf;
                d(2,'edit whos relations?');
                if select_character(temp,false)=true then begin
                 d(2,'other person?');
                 if select_character(temp2,false)=true then begin

                  {load current relation}
                  social_relation(temp,temp2,relation);

                  {correct relation}
                  correct_relation(temp.name2,relation);

                  done:=false;
                  repeat
                   crlf;
                   d(14,'Relations Editor');
                   d(14,cool_string(16,'=','-',14,15));
                   {display relations between the characters}
                   d(config.textcolor,relation_string(true,relation.name1,relation.name2,relation.relation1));
                   d(config.textcolor,relation_string(true,relation.name2,relation.name1,relation.relation2));

                   menu('(1) change '+uplc+temp.name2+'s'+config.textcol1+' attitude to '+uplc+temp2.name2+config.textcol1);
                   menu('(2) change '+uplc+temp2.name2+'s'+config.textcol1+' attitude to '+uplc+temp.name2+config.textcol1);
                   menu('(D)one');
                   sd(config.textcolor,':');

                   repeat
                    ch:=upcase(getchar);
                    until ch in ['1','2','D'];
                   crlf;

                   case ch of
                    'D': done:=true;
                    '1':begin {change temps attitude to temp2}
                         {get new relation value}
                         relation.relation1:=gimme_relation_constant;
                        end;
                    '2':begin {change temp2s attitude to temp}
                         {get new relation value}
                         relation.relation2:=gimme_relation_constant;
                        end;
                   end; {case .end.}

                  until done;

                  {save relation}
                  load_relation(fsave,relation,relation.recnr);

                 end;
                end;
                ch:=' ';
               end;

           'V':begin {view relations}
                crlf;
                crlf;
                d(2,'Who set relations marry?');
                if select_character(temp,false)=true then begin
                 personal_relations(temp,true);
                 crlf;
                 pause;
                end;

               end;

           'N':begin {npc sets relations}
                crlf;
                crlf;
                d(2,'Who should "set relations"?');
                if select_character(temp,false)=true then begin
                 d(15,'Processing...'+temp.name2);
                 Npc_Change_Relations(temp);
                 d(15,'Finished processing.');
                 pause;
                end;

               end;

           'M':begin {npc marry}
                crlf;
                crlf;
                d(2,'Who should marry?');
                if select_character(temp,false)=true then begin
                 if temp.married=true then begin
                  crlf;
                  d(12,temp.name2+' is already married stupid!');
                  pause;
                 end
                 else begin
                  d(15,'Processing...'+temp.name2);
                  {Npc_Set_Out_To_Marry(temp);}
                  d(15,'Finished processing.');
                  pause;
                 end;
                end;

               end;
          end; {case .end.}

         until ch='R';
        end;
       end;
   'T':begin {the marketplace}

        {check for registration}
        muffis;

        if global_registered=true then begin

         crlf;
         crlf;
         d(config.textcolor,'You enter the '+ucyan+'Market-Place'+config.textcol1+'.');

         marketplace;
        end
        else begin
         crlf;
         only_in_registered_version;
        end;
       end;
   'G':begin {good deeds}
        if (player.dark>=200000) then begin
         crlf;
         d(config.textcolor,'Your soul is already lost my friend.');
        end
        else begin
         good_deeds;
        end;
       end;
   'C':begin {challenges}
        challenges;
       end;
   'S':begin {status}
        status(player);
        crlf;
       end;
   'N':begin {news-paper}

        {update player location & doing}
        onliner.location:=onloc_readingnews;
        onliner.doing   :=location_desc(onliner.location);
        add_onliner(OUpdateLocation,onliner);

        {various.pas}
        read_news_paper;

       end;
   'I':begin {The Inn}

        crlf;
        crlf;
        d(config.textcolor,'You enter '+ucyan+'The Inn'+config.textcol1+'.');
        d(config.textcolor,'The '+ucyan+'Inn-Keeper'+config.textcol1+' glares at You and your purse.');
        crlf;
        the_inn;
       end;
   'M':begin {The Magic Shoppe}
        load_king(fload,king);

        if (king.shop_magic=false) and (player.king=false) then begin
         crlf;
         d(12,'The Magic Shop is closed! (The '+UpperCase(kingstring(king.sexy))+'s order!)');
        end
        else begin
         magic_shop;
        end;
       end;
   'V':begin {The Level Masters}
        level_masters;
       end;
   'E':begin {Dark Deeds}
        crlf;
        dark_deeds;
       end;
   'D':begin {Dungeons}
        case random(3) of
         0: onliner.doing:='exploring the '+ulgray+'Dungeons'+config.textcol1;
         1: onliner.doing:='in the '+ulgray+'Dungeons'+config.textcol1;
         2: onliner.doing:='wandering around in the '+ulgray+'Dungeons'+config.textcol1;
        end;

        {update player doing}
        onliner.location:=onloc_dungeons;
        add_onliner(OUpdateLocation,onliner);

        dungeons(teamdngs);

        crlf;
        crlf;
        d(5,'You leave the dungeons.');

        global_dungeonlevel:=3;

       end;
   'A':begin {The Armor Shoppe}
        load_king(fload,king);

        if (king.shop_armor=false) and (player.king=false) then begin
         crlf;
         d(12,'The Armor Shop is closed! (The '+UpperCase(kingstring(king.sexy))+'s order!)');
        end
        else if player.armhag<1 then begin
         crlf;
         d(15,'You have been shut out from the Armor Store!');
         d(15,'You are on their UNWANTED list of persons.');
         d(15,'Figure it!');
         pause;
        end
        else begin
         armor_shop;
        end;

       end;
   'W':begin {The Weapon Store}
        load_king(fload,king);

        if (king.shop_weapon=false) and (player.king=false) then begin
         crlf;
         d(12,'The Weapon Shop is closed! (The '+UpperCase(kingstring(king.sexy))+'s order!)');
        end
        else if player.weaphag<1 then begin
         crlf;
         d(15,'You have been shut out from the Weapon Store!');
         d(15,'You are on their UNWANTED list of persons.');
         d(15,'Figure it!');
         pause;
        end
        else begin
         weapon_shop;
        end;
       end;
   'B':begin {The Bank}
        crlf;
        crlf;
        d(config.textcolor,'You enter the Bank');
        the_bank;
       end;
   'R':begin {love corner}
        love_corner;
       end;
   'H':begin {home}
        home_sweet_home;
       end;
   'L':begin {List Players}

        crlf;
        sd(15,'Sorting..');

        {update player doing}
        onliner.location:=onloc_checkplys;
        onliner.doing   :=location_desc(onliner.location);
        add_onliner(OUpdateLocation,onliner);

        {update user first}
        user_save(player);

        {sort & display player list}
        sort_players(false);

       end;
   '*':begin {Suicide}

        onliner.doing:='considering to comit suicide';
        add_onliner(OUpdateLocation,onliner);

        suicide;

        onliner.doing:='wandering the streets';
        add_onliner(OUpdateLocation,onliner);

       end;
   'Q':begin {Quit Game}
        onliner.doing:='considering to get some sleep';
        add_onliner(OUpdateLocation,onliner);

        crlf;
        crlf;
        if confirm('QUIT game','n')=true then begin
         clearscreen;
         crlf;
         d(config.textcolor,'How do you wanna spend the night ?');
         d(config.textcolor,'Go and get some sleep at the Dormitory.');
         d(config.textcolor,'Or try to earn a few bucks at the Beggars Wall.');
         d(config.textcolor,'(you can get wasted on both places)');
         crlf;
         if confirm('Go to the Dormitory','Y')=false then begin
          crlf;
          d(config.textcolor,'Everything costs. A place at the Beggars Wall among');
          d(config.textcolor,'the other poor bastards doesn''t come for free.');
          d(config.textcolor,'It will cost you '+uyellow+commastr(beggar_cost)+config.textcol1+' '+many_money(beggar_cost)
            +' for a good seat.');

          if confirm('Pay','n')=true then begin

           if player.gold>=beggar_cost then begin

            {pay up}
            DecPlayerMoney(player,beggar_cost);

            {set new offline location}
            player.location:=offloc_beggarwall;

            crlf;
            d(config.textcolor,'You take your seat among the other beggars.');
            d(config.textcolor,'You pray that people will have mercy upon you.');
            d(config.textcolor,'(at least so you can get those '+uyellow+commastr(beggar_cost)+config.textcol1+' back)');
            crlf;
            pause;

            {news-paper}
            Newsy(true,'Beggar',
            ' '+uplc+player.name2+config.textcol1+' dozed off at the Beggars Wall.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');


            {exit game}
            normal_exit;

           end
           else begin
            crlf;
            d(12,'But you can''t afford it!');
            crlf;
            pause;
           end;
          end;
         end;

         clearscreen;
         crlf;
         d(config.textcolor,'You enter the Dormitory to get a good nights sleep.');
         d(config.textcolor,'There are a few beds left and you manage to get one.');
         crlf;
         d(config.textcolor,'You close your eyes and pray that no evil shall visit');
         d(config.textcolor,'you tonight.');
         crlf;
         pause;
         normal_exit;

        end
        else begin

         {player decided to stay in game}
         crlf;
         d(config.textcolor,'You decide to stay.');
         crlf;
         onliner.location:=onloc_nowhere; {we set this value so main loop will update location}

        end;

       end;

  end; {case .end.}

 until never; {main game loop}

end; {Game *end*}

end. {Unit GameC .end.}
