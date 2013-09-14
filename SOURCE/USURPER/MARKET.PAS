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
Unit Market; {Usurper - The Market Place}

Interface

Procedure MarketPlace;

Implementation

Uses Init, Cms, Jakob,
     Statusc, Mail, News,
     Invent, SwapEq, Plmarket,
     Various, Various2, Relation,
     Online, File_Io;

const food_master = 'Alabat'; {shop keeper, food & drinks}
var
    refresh : boolean;
    ok : boolean;

Function Set_Color(rank:byte) : byte;
begin

 if rank>16 then set_color:=14
            else set_color:=3;
end; {set_color *end*}

Procedure Meny2;
begin
 crlf;
 crlf;
 if player.sex=1 then begin
  sd(global_talkcol,'What can I do for you?');
  sd(config.textcolor,', ');
 end
 else begin
  sd(global_talkcol,'What can I do for you?');
  sd(config.textcolor,', ');
 end;
 d(config.textcolor,'the old shopkeeper cackles.');
 d(config.textcolor,'Behind his Scat-Bow glasses the skinny old gnome');
 d(config.textcolor,'gives a very peculiar impression.');

 crlf;
 menu('(L)ist items');
 menu('(B)uy');
 menu('(S)ell');
 menu('(R)eturn to market');

end; {meny2 *end*}

Procedure Display_Menu2(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['L',
                       'B',
                       'S',
                       'R',
                       chr(13),
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny2;
   end;
   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,food_master+'s (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin
   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,food_master+'s (L,B,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny2;
  end;
 end;

end; {display_menu2 *end*}

Procedure Market_Meny;
const offset = 22;
begin

 clearscreen;
 crlf;
 d(5,'-**- The Old Marketplace -**-');
 crlf;
 d(config.textcolor,'The marketplace is filled with people and creatures.');
 d(config.textcolor,'Selling, buying, arguing or just looking. Everybody');
 d(config.textcolor,'is doing something. What shall you do?');
 crlf;

 menu2(ljust('(B)eggars wall',offset));
 menu('(T)rain with master');

 menu2(ljust('(A)labats store',offset));
 menu('(P)layers Market');

 menu('(S)tatus');
 menu('(R)eturn');

end; {market_meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 {sethotkeys_on(NoKill,['B',
                       'T',
                       'A',
                       'S',
                       'P',
                       'R',
                       chr(13),
                       '?']);}

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    market_meny;
   end;
   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,'Market-Place (');
   sd(config.hotkeycolor,'?');
   sd(config.textcolor,' for menu) :');
  end
  else begin

   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,'Market (B,T,A,P,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   market_meny;
  end;
 end;

end; {display_menu *end*}

Procedure MarketPlace;
var
    master : s70; {training master}
    s      : s70;
    a      : s70;

    tr_def,
    ch,
    cho,
    tdk     : char;

    xx: longint;
    i : longint;

    j     : word;
    size  : word;
    sturm : word;

    counter : integer;

    cc : byte;
    bash_color : byte;

    found     : boolean;
    again     : boolean;
    teamkill  : boolean;
    abort     : boolean;
    break_time:boolean;

    soktyp : objtype;

    player0 : UserRec; {User record}
    objekt  : ^orec;   {Object/item record}
    king    : kingrec; {King record}

    pause_counter : byte;

begin

 {init pointer vars}
 new(objekt);

 tr_def:=' ';

 {fetching option set in .CFG, is player allowed to kill teammates?}
 teamkill:=false;
 s:=cfg_String(35);
 if upcasestr(s)='YES' then teamkill:=true;

 {fetching Training masters name from .CFG}
 master:=cfg_string(17);
 if master='' then master:='Liu Zei';

 crlf;
 crlf;

 {**MAIN-LOOP***}
 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_marketplace then begin
   refresh:=true;
   onliner.location:=onloc_marketplace;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {display menu}
  display_menu(true,true);

  {get usuer-input}
  cho:=upcase(getchar);

  {evaluate user-input}
  case cho of
   '?':begin {display menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'P':begin {Player Market, where players sell their stuff}
        load_king(fload,king);

        if config.classic then begin
         crlf;
         d(15,'This place is not available in Usurper Classic mode.');
        end
        else if (king.shop_plmarket=false) and (player.king=false) then begin
         crlf;
         d(12,'The Marketplace is closed! (The '+upcasestr(kingstring(king.sexy))+'s order!)');
        end
        else begin
         players_market;
        end;
       end;
   'A':begin {Alabats (food) store}

        load_king(fload,king);

        if config.classic then begin
         crlf;
         d(15,'This store is not available in Usurper Classic mode.');
        end
        else if (king.shop_alabat=false) and (player.king=false) then begin
         crlf;
         d(12,food_master+'s store is closed! (The '+upcasestr(kingstring(king.sexy))+'s order!)');
        end
        else begin

        crlf;
        repeat

         if onliner.location<>onloc_foodstore then begin
          refresh:=true;
          onliner.location:=onloc_foodstore;
          onliner.doing   :=location_desc(onliner.location);
          add_onliner(OUpdateLocation,onliner);
         end;

         display_menu2(true,true);
         ch:=upcase(getchar);

         case ch of
          '?':begin {display menu}
               if player.expert=true then display_menu2(true,false)
                                     else display_menu2(false,false);
              end;
          'S':begin {sell}
               crlf;
               crlf;
               d(15,'Sell some goods?');

               if confirm('Sell everything in your inventory ','N')=true then begin
                counter:=0;
                for i:=1 to global_maxitem do begin
                 if player.item[i]>0 then begin
                  load_objekt(objekt^,player.itemtype[i],player.item[i]);
                  if objekt^.ttype in [Food,Drink] then begin
                   if objekt^.value>1 then begin
                    xx:=objekt^.value div 2;
                   end
                   else begin
                    xx:=objekt^.value;
                   end;
                   {time to sell}
                   if xx<=0 then begin
                    sd(global_itemcol,objekt^.name);
                    sd(global_talkcol,' is worthless!');
                    sd(config.textcolor,', ');
                    sd(global_plycol,food_master);
                    d(config.textcolor,' says.');
                   end
                   else if objekt^.cursed=true then begin
                    sd(global_itemcol,objekt^.name);
                    sd(global_talkcol,' is cursed!');
                    sd(global_talkcol,'I don''t buy cursed items!');
                    sd(config.textcolor,', ');
                    sd(global_plycol,food_master);
                    d(config.textcolor,' says.');
                   end
                   else begin

                    sd(global_plycol,food_master);
                    sd(config.textcolor,' bought ');
                    sd(global_itemcol,objekt^.name);
                    sd(config.textcolor,' for ');
                    sd(14,commastr(xx));
                    d(config.textcolor,' '+config.moneytype+' '+config.moneytype3+'.');

                    incplayermoney(player,xx);
                    player.item[i]:=0;
                    inc(counter);
                   end;

                  end;
                 end;

                end; {for i:= .end.}

                if counter=0 then begin
                 d(global_talkcol,'You have nothing of interest.');
                end;

               end
               else begin

                {choose and sell}
                repeat
                 i:=item_select(player);
                 if i>0 then begin
                  load_objekt(objekt^,player.itemtype[i],player.item[i]);
                  if objekt^.ttype in [Food,Drink] then begin
                   if objekt^.value>1 then begin
                    xx:=objekt^.value div 2;
                   end
                   else begin
                    xx:=objekt^.value;
                   end;

                   if xx<=0 then begin
                    sd(global_talkcol,'That item is worthless!');
                    sd(config.textcolor,', ');
                    sd(global_plycol,food_master);
                    d(config.textcolor,' says.');
                   end
                   else if objekt^.cursed=true then begin
                    sd(global_talkcol,'I don''''t buy cursed items!');
                    sd(config.textcolor,', ');
                    sd(global_plycol,food_master);
                    d(config.textcolor,' says.');
                   end
                   else begin
                    sd(global_plycol,food_master);
                    sd(config.textcolor,' says that he will give you ');
                    sd(14,commastr(xx));
                    sd(config.textcolor,' '+many_money(xx)+' for your ');
                    sd(global_itemcol,objekt^.name);
                    d(config.textcolor,'.');

                    menu2('(A)gree  ');
                    menu2('(N)o Deal  ');
                    sd(config.textcolor,':');

                    {get user-input}
                    repeat
                     ch:=upcase(getchar);
                    until ch in ['A','N'];

                    crlf;
                    case ch of
                     'N':begin
                          sd(global_talkcol,'Bad for you!');
                          sd(config.textcolor,', ');
                          sd(global_plycol,food_master);
                          d(config.textcolor,' says.');
                         end;
                     'A':begin
                          sd(global_talkcol,'Great!');
                          sd(config.textcolor,', ');
                          sd(global_plycol,food_master);
                          d(config.textcolor,' smiles.');

                          player.item[i]:=0;
                          incplayermoney(player,xx);
                         end;

                    end; {case .end.}

                   end;
                  end
                  else begin
                   sd(global_talkcol,'I don''t buy that kind of items');
                   sd(config.textcolor,', ');
                   sd(global_plycol,food_master);
                   d(config.textcolor,' says.');
                   crlf;
                   pause;
                  end;
                 end;
                until i=0;
               end;
              end;
          'B':begin {buy items}

               crlf;
               crlf;
               d(config.textcolor,'Purchase what?');
               menu2('(F)ood  ');
               menu2('(D)rinks  ');
               menu2('(A)bort ');
               sd(config.textcolor,':');

               repeat
                ch:=upcase(getchar);
               until ch in ['F','D','A'];

               case ch of
                'A':begin
                     sd(15,'Abort');
                    end;
                'F':begin
                     sd(15,'Food');
                     soktyp:=Food;
                    end;
                'D':begin
                     sd(15,'Drinks');
                     soktyp:=Drink;
                    end;
               end; {case .end.}

               xx:=0;
               if ch<>'A' then begin
                crlf;
                d(3,'Enter Item # to buy');
                sd(config.textcolor,':');

                xx:=get_number(0,65000);
                j:=0;
               end;

               if xx>0 then begin
                sturm:=fsob(soktyp);

                if xx<sturm then begin
                 for i:=1 to fsob(soktyp) do begin
                  load_objekt(objekt^,soktyp,i);
                  if objekt^.shop=true then begin
                   inc(j);
                  end;
                  if j=xx then begin
                   sd(config.textcolor,'Buy the ');
                   sd(global_itemcol,objekt^.name);
                   sd(config.textcolor,' for ');
                   sd(14,commastr(objekt^.value));
                   sd(config.textcolor,' '+many_money(objekt^.value));
                   sd(config.textcolor,' (Y/[N]) ?');

                   {get user-input}
                   repeat
                    ch:=upcase(getchar);
                   until (ch='Y') or (ch='N') or (ch=ReturnKey);

                   crlf;
                   if ch='Y' then begin
                    if player.gold<objekt^.value then begin
                     d(global_talkcol,'You don''''t have the '+config.moneytype+'!');
                    end
                    else begin
                     if inventory_empty(player)=0 then begin
                      d(config.textcolor,'Your inventory is full!');
                     end
                     else begin
                      d(global_talkcol,'Done!');
                      decplayermoney(player,objekt^.value);
                      xx:=inventory_empty(player);
                      player.item[xx]:=i;
                      player.itemtype[xx]:=objekt^.ttype;
                     end;
                    end;
                   end;
                   break;
                  end;
                 end;
                end;
               end;
               ch:=' ';
              end;
          'L':begin
               j:=0;

               crlf;
               menu('(F)ood');
               menu('(D)rinks');
               sd(config.textcolor,':');

               repeat
                ch:=upcase(getchar);
               until ch in ['F','D'];

               case ch of
                'F':begin
                     soktyp:=Food;
                    end;
                'D':begin
                     soktyp:=Drink;
                    end;
               end; {case .end.}

               clearscreen;
               crlf;
               d(5,'#   Item                       Cost');
               crlf;

               cc:=1;
               for i:=1 to fsob(soktyp) do begin
                load_objekt(objekt^,soktyp,i);
                if objekt^.shop=true then begin
                 inc(j);
                 inc(cc);

                 {#}
                 sd(3,ljust(commastr(j),4));
                 {name}
                 sd(15,ljust(objekt^.name,18));
                 {cost}
                 d(14,rjust(commastr(objekt^.value),13));

                 if cc>global_screenlines-2 then begin
                  cc:=0;
                  crlf;
                  if confirm('Continue ','Y')=false then break;
                  crlf;
                 end;
                end;
               end;
               crlf;
              end;

         end; {case .end.}

        until ch='R';
       end;
       end;

   'T':begin {Training Master, close combat}
        clearscreen;
        crlf;
        d(5,'Small Hut');

        {update player doing}
        onliner.location:=onloc_combmaster;
        onliner.doing   :=location_desc(onliner.location);
        add_onliner(OUpdateLocation,onliner);

        crlf;

        d(config.textcolor,'You enter the little hut where the master lives.');
        d(config.textcolor,'Two young men with shaved heads and armed with sticks');
        d(config.textcolor,'watch you closely when you enter.');

        repeat
         crlf;
         crlf;
         d(config.textcolor,'The Master has arrived.');
         d(global_talkcol,' Would you like to train close-combat moves or increase your');
         d(global_talkcol,' immunity to diseases ?');
         menu('(F)ancy moves');
         menu('(I)mmunity against diseases');
         menu('(R)eturn');
         crlf;
         sd(config.textcolor,'Train :');

         {get user-input}
         ch:=upcase(getchar);

        until ch in ['F','I','R'];

        {evaluate user-input}
        case ch of
         'R':begin {return}
              d(15,'Nothing!');
              crlf;
              d(global_talkcol,'I don''t need your help old man!');
              d(config.textcolor,'You leave.');
             end;
         'I':begin
              d(15,'Immunity!');
              if player.trains<1 then begin
               d(15,'You have no training sessions left!');
              end
              else begin

               if player.disres>=240 then begin
                crlf;
                d(15,'You are already immune!');
                d(config.textcolor,'No need to train this more.');
                pause;
               end
               else begin
                repeat
                 crlf;
                 xx:=random(3)+1;
                 inc(player.disres,xx);
                 dec(player.trains);
                 d(config.textcolor,'Your immunity has increased!');
                 if player.race=Hobbit then begin
                  inc(player.disres);
                  d(14,'For being a Hobbit you receive +1!');
                 end;
                 sd(config.textcolor,'Your resistance is now : ');
                 d(10,immunity(player.disres));
                 sd(config.textcolor,'You have ');
                 sd(15,commastr(player.trains));
                 d(config.textcolor,' training sessions left.');

                 again:=false;
                 if player.trains>0 then begin
                  crlf;
                  if confirm('Increase immunity some more','N')=true then begin
                   if player.disres>=240 then begin
                    crlf;
                    d(15,'You are already immune!');
                    d(config.textcolor,'No need to train this more.');
                    pause;
                   end
                   else begin
                    again:=true;
                   end;
                  end;
                 end;
                until again=false;
               end;

              end;
             end;
         'F':begin
              d(15,'Moves!');
              if player.trains<1 then begin
               crlf;
               sd(global_talkcol,'You cannot learn more from your current level! ');
               sd(global_plycol,master);
               d(config.textcolor,' says.');
               crlf;
               pause;
              end
              else begin

               repeat
                s:='You have VERY MUCH to learn!';
                case player.trains of
                 1: s:='You can learn some from me.';
                 2: s:='You have potential to advance!';
                 3: s:='You can learn quite a lot now!';
                 4: s:='You can earn much from these lessons!';
                 5: s:='Your skills can be improved!';
                 6: s:='You should have come to me earlier!';
                end;
                crlf;

                sd(global_talkcol,s);
                sd(config.textcolor,', ');
                sd(global_plycol,master);
                d(config.textcolor,' says.');

                d(global_talkcol,'Which skill would you like to improve?');
                crlf;

                menu2('(T)ackle         ');

                bash_color:=set_color(player.skill[1]);
                d(bash_color,'- '+bash_rank(player.skill[1]));

                menu2('(D)rop-Kick      ');
                bash_color:=set_color(player.skill[2]);
                d(bash_color,'- '+bash_rank(player.skill[2]));

                menu2('(U)ppercut       ');
                bash_color:=set_color(player.skill[3]);
                d(bash_color,'- '+bash_rank(player.skill[3]));

                menu2('(B)ite           ');
                bash_color:=set_color(player.skill[4]);
                d(bash_color,'- '+bash_rank(player.skill[4]));

                menu2('(L)eg-Sweep      ');
                bash_color:=set_color(player.skill[5]);
                d(bash_color,'- '+bash_rank(player.skill[5]));

                menu2('(J)oint Break    ');
                bash_color:=set_color(player.skill[6]);
                d(bash_color,'- '+bash_rank(player.skill[6]));

                menu2('(K)nifehand      ');
                bash_color:=set_color(player.skill[7]);
                d(bash_color,'- '+bash_rank(player.skill[7]));

                menu2('(N)erve Punch    ');
                bash_color:=set_color(player.skill[8]);
                d(bash_color,'- '+bash_rank(player.skill[8]));

                menu2('(C)hokehold      ');
                bash_color:=set_color(player.skill[9]);
                d(bash_color,'- '+bash_rank(player.skill[9]));

                menu2('(H)eadbash       ');
                bash_color:=set_color(player.skill[10]);
                d(bash_color,'- '+bash_rank(player.skill[10]));

                menu2('(P)ull Hair      ');
                bash_color:=set_color(player.skill[11]);
                d(bash_color,'- '+bash_rank(player.skill[11]));

                menu3('K(i)ck           ',3);
                bash_color:=set_color(player.skill[12]);
                d(bash_color,'- '+bash_rank(player.skill[12]));

                menu2('(S)traight Punch ');
                bash_color:=set_color(player.skill[13]);
                d(bash_color,'- '+bash_rank(player.skill[13]));

                menu2('(R)am            ');
                bash_color:=set_color(player.skill[14]);
                d(bash_color,'- '+bash_rank(player.skill[14]));

                if tr_def<>' ' then begin
                 crlf;
                 sd(config.textcolor,'[');
                 sd(5,'A');
                 sd(config.textcolor,']bort, ');

                 sd(config.textcolor,'[');
                 sd(5,'Enter');
                 sd(config.textcolor,'] to train ');
                 case tr_def of
                  'T': d(14,'Tackle');
                  'D': d(14,'Drop-Kick');
                  'U': d(14,'Uppercut');
                  'B': d(14,'Bite');
                  'L': d(14,'Leg-Sweep');
                  'J': d(14,'Joint Break');
                  'K': d(14,'Knife Hand');
                  'N': d(14,'Nerve Punch');
                  'C': d(14,'Chokehold');
                  'H': d(14,'Headbash');
                  'P': d(14,'Pull Hair');
                  'I': d(14,'Kick');
                  'S': d(14,'Straight Punch');
                  'R': d(14,'Ram');
                 end;
                 sd(config.textcolor,':');
                end
                else begin
                 crlf;
                 sd(config.textcolor,'[');
                 sd(5,'A');
                 d(config.textcolor,']bort');
                 sd(config.textcolor,':');
                end;

                repeat
                 ch:=upcase(getchar);
                 if ch=chr(13) then begin
                  if tr_def=' ' then ch:=' ';
                 end;
                until ch in ['T','D','U','B','L','J','K','N','C','H',
                             'P','I','S','R','A',chr(13)];

                xx:=0;

                if ch=chr(13) then begin
                 ch:=tr_def;
                end;

                case ch of
                 'T': xx:=1;
                 'D': xx:=2;
                 'U': xx:=3;
                 'B': xx:=4;
                 'L': xx:=5;
                 'J': xx:=6;
                 'K': xx:=7;
                 'N': xx:=8;
                 'C': xx:=9;
                 'H': xx:=10;
                 'P': xx:=11;
                 'I': xx:=12;
                 'S': xx:=13;
                 'R': xx:=14;
                end;

                if xx>0 then begin
                 tr_def:=ch;
                 if player.skill[xx]>16 then begin
                  d(config.textcolor,'You cannot advance more in this skill.');
                  d(config.textcolor,'You are already an EXPERT!');
                  crlf;
                  pause;
                 end
                 else begin
                  crlf;
                  sd(config.textcolor,'Train ');
                  sd(global_bashcol,bash_name(xx));

                  if confirm('','y')=true then begin

                   d(config.textcolor,'Train this skill as much as you can or only once?');
                   menu('(F)ull training');
                   menu('(O)nly once');
                   sd(config.textcolor,':');

                   repeat
                    tdk:=upcase(getchar);
                   until tdk in ['F','O'];

                   case tdk of
                    'F':begin
                         crlf;
                         d(config.textcolor,'Let''s see how far you can advance!');
                         sd(global_plycol,master);
                         sd(config.textcolor,' guides you through the art of ');
                         sd(global_bashcol,bash_name(xx));
                         d(config.textcolor,'.');

                         d(10,'You have advanced in this skill!');
                         crlf;

                         counter:=0;
                         repeat
                          dec(player.trains);
                          inc(player.skill[xx]);
                          inc(counter);
                         until (player.trains<1) or (player.skill[xx]>16);

                         sd(config.textcolor,'You''ve used ');
                         sd(14,commastr(counter));
                         d(config.textcolor,' trainings.');

                         if player.skill[xx]>16 then begin
                          d(14,'Congratulations!');
                          d(config.textcolor,'You have completed your training!');
                         end
                         else begin
                          sd(config.textcolor,'Your skill is now ');
                          d(15,bash_rank(player.skill[xx]));
                         end;

                         case random(4) of
                          0: s:=uplc+player.name2+config.textcol1+' trained '+sex3[player.sex]+' combat skills!';
                          1: s:=uplc+player.name2+config.textcol1+' increased '+sex3[player.sex]+ ' combat skills!';
                          2: s:=uplc+player.name2+config.textcol1+' trained some close-combat skills!';
                          3: s:=uplc+player.name2+config.textcol1+' trained '+sex3[player.sex]+' skills!';
                         end;

                         {news-paper}
                         newsy(true,
                         'Combat Training',
                         ' '+s,
                         '',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '');

                         pause;
                        end;
                    'O':begin
                         crlf;
                         sd(global_plycol,master);
                         sd(config.textcolor,' guides you through the art of ');
                         sd(global_bashcol,bash_name(xx));
                         d(config.textcolor,'.');

                         d(config.textcolor,'You have advanced in this skill!');
                         crlf;

                         dec(player.trains);
                         inc(player.skill[xx]);

                         sd(config.textcolor,'You have ');
                         sd(15,commastr(player.trains));
                         d(config.textcolor,' training sessions left.');

                         case random(4) of
                          0: s:=uplc+player.name2+config.textcol1+' trained '+sex3[player.sex]+' combat skills!';
                          1: s:=uplc+player.name2+config.textcol1+' has increased '+sex3[player.sex]+ ' combat skills!';
                          2: s:=uplc+player.name2+config.textcol1+' has trained some close-combat skills!';
                          3: s:=uplc+player.name2+config.textcol1+' trained '+sex3[player.sex]+' skills!';
                         end;

                         newsy(true,
                         'Combat Training',
                         ' '+s,
                         '',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '',
                         '');

                         pause;
                        end;
                   end;
                  end;
                 end;
                end;
               until (ch='A') or (player.trains<1);

               if player.trains<1 then begin
                crlf;
                sd(global_talkcol,'You cannot learn more from your current level!');
                sd(config.textcolor,', ');
                sd(global_plycol,master);
                d(config.textcolor,' says.');
                crlf;
                d(config.textcolor,'You look at him, disappointed but determined to come back');
                d(config.textcolor,'and train more later on...');
                crlf;
                pause;
               end;
              end;
             end;
        end;

       end;
   'S':begin {Status}
        clearscreen;
        status(player);
        crlf;
       end;
   'B':begin {Beggars Wall}

        {update player doing}
        onliner.location:=onloc_beggarswall;
        onliner.doing   :=location_desc(onliner.location);

        add_onliner(OUpdateLocation,onliner);

        clearscreen;
        crlf;
        d(5,'Beggars Wall');
        d(5,mkstring(12,underscore));
        crlf;
        d(config.textcolor,'You approach the great wall where all the beggars');
        d(config.textcolor,'are gathered with their cups and loud shouting...');
        d(config.textcolor,'You look around to see who'+chr(39)+'s here :');
        crlf;
        xx:=0;
        pause_counter:=6;
        abort:=false;

        for i:=1 to 2 do begin

         case i of
          1: size:=fs(FsPlayer);
          2: size:=fs(FsNpc);
         end; {case .end.}

         for j:=1 to size do begin

          load_character(player0,i,j);

          if (player0.location=offloc_beggarwall) and
             (player0.name2<>player.name2) and
             (player0.name2<>global_delname2) and
             (player0.deleted=false) then begin

           inc(xx);
           if player0.hps<1 then begin
            d(12,player0.name2+' : (laying in a pool of blood, murdered!)');
           end
           else begin
            sd(global_plycol,player0.name2+' : ');
            case random(16) of
             0: s:='Give us a pound!';
             1: s:='Help me!';
             2: s:='Give me something!';
             3: s:='Help me out of my misery!';
             4: s:='Have a coin to spare, have ya?';
             5: s:='Hey there! Give us something!';
             6: s:='Help the poor!';
             7: s:='I''m weak and helpless! Give me something!';
             8: s:='I have a family to support! Share your wealth!';
             9: s:='Have mercy upon me!';
             10: s:='Oh God, aid me in my poverty!';
             11: s:='Give me a helping hand!';
             12: s:='Help an old man with poor sight!';
             13: s:='Spare us something!';
             14: s:='Dear Sire, save your soul and help me!';
             15: s:='I''m old and poor! Have mercy!';
            end; {case .end.}
            sd(global_talkcol,s);
            crlf;
           end;

           inc(pause_counter);
           if pause_counter>global_screenlines-2 then begin
            pause_counter:=0;
            if confirm('Continue','Y')=false then begin
             abort:=true;
            end;
           end;

          end;
          if abort then break;
         end; {for j:= .end.}
         if abort then break;
        end; {for i:= .end.}

        if (xx=0) and (abort=false) then begin
         crlf;
         d(config.textcolor,'They are all gone. Perhaps they ran away when');
         d(config.textcolor,'you arrived...');
        end
        else begin
         repeat
          crlf;
          menu2('(A)ttack!  ');
          menu2('(G)ive alms  ');
          menu2('(S)kip action :');
          cho:=upcase(getchar);
         until cho in ['A','G','S'];
         crlf;

         {evaluate user-input}
         if (cho='A') and (player.darknr<1) then begin
          crlf;
          d(12,'You have run out of dark deeds, my blood-thirsty friend!');
          pause;
         end
         else if (cho='A') and (player.darknr>0) then begin
          crlf;
          d(config.textcolor,'Who must die?');
          sd(config.textcolor,':');
          a:=get_string(20);

          abort:=false;
          found:=false;
          for i:=1 to 2 do begin

           case i of
            1: size:=fs(FsPlayer);
            2: size:=fs(FsNpc);
           end;

           for j:=1 to size do begin

            load_character(player0,i,j);

            if (findsub(a,player0.name2)) and
               (player0.hps>0) and
               (player0.deleted=false) and
               (player0.location=offloc_beggarwall) then begin

             if confirm(uplc+player0.name2+config.textcol1,'n')=true then begin

              if (player.team=player0.team) and (player.team<>'') and
                 (teamkill=false) then begin
               crlf;
               d(12,'You are not allowed to attack your own team-mates!');
               abort:=true;
              end
              else if Is_Player_Married(player.name2,player.id)=player0.name2 then begin

               cannot_attack_husband(player,player0);

               abort:=true;
              end
              else if is_online(player0.name2,online_player)=true then begin
               crlf;
               sd(global_plycol,player0.name2);
               d(config.textcolor,' is busy elsewhere!');
               abort:=true;
              end
              else begin
               {we found our target}

               {add shadow player}
               if add_shadow(SAdd,player0,player.name2,'attacked by '+uplc+player.name2+config.textcol1,0)=false then begin
                {unable to add player0}
                d(global_plycol,player0.name2+ulred+' has left this location!');
                pause;
                abort:=true;
               end
               else begin
                found:=true;
               end;

              end;

             end
             else begin
              if confirm('Continue search','Y')=false then begin
               abort:=true;
              end;
             end;
            end;

            if (abort) or (found) then break;

           end; {for j:= .end.}

           if (abort) or (found) then break;

          end; {for i:= .end.}


          if (found=true) and (abort=false) then begin

           {update player doing}
           onliner.doing:='attacking '+uplc+player0.name2+config.textcol1;
           add_onliner(OUpdateLocation,onliner);

           {'way to kill' menu}
           crlf;
           menu2('(S)trangle  ');
           menu2('(B)ash head  ');
           menu2('(W)ring neck');
           crlf;
           menu2('(C)ut throat  ');
           sd(config.textcolor,'S(');
           sd(5,'t');
           sd(config.textcolor,')ab :');

           {get user-input}
           repeat
            cho:=upcase(getchar);
           until cho in ['S','B','W','T','C'];
           crlf;

           {evaluate user-input}
           case cho of
            'B':begin {bash head}
                 crlf;
                 d(config.textcolor,'You scan the vicinty for a nice weapon.');
                 d(config.textcolor,'Finally you find a wooden club!');

                 sd(config.textcolor,'You return and approach ');
                 sd(global_plycol,player0.name2);
                 d(config.textcolor,' with a smile.');

                 d(config.textcolor,sex2[player0.sex]+' looks expectantly at you. You draw your weapon');
                 d(config.textcolor,'and manage to surprise '+sex[player0.sex]+', with a quick stroke over '
                   +sex3[player0.sex]+' head!');

                 sd(config.textcolor,'You laugh loudly as ');
                 sd(global_plycol,player0.name2);
                 d(config.textcolor,' screams in pain!');

                 d(config.textcolor,'Feeling your pulse raising you finish '+sex[player0.sex]+' off with');
                 sd(config.textcolor,'two more precise strokes. ');
                 sd(global_plycol,player0.name2+'s');
                 d(config.textcolor,' skull breaks and');
                 d(config.textcolor,'everything in it pours out...');
                 crlf;
                end;
            'S':begin {strangle}
                 crlf;
                 sd(config.textcolor,'You approach ');
                 sd(global_plycol,player0.name2);
                 d(config.textcolor,' and pretend to give');
                 d(config.textcolor,sex[player0.sex]+' some '+config.moneytype+'. But when '+sex2[player0.sex]+' reaches for '+
                    sex3[player0.sex]+' begging cup');

                 d(config.textcolor,'you charge and engage '+sex[player0.sex]+' in a wrestling match. You soon');
                 d(config.textcolor,'overcome '+sex[player0.sex]+' and place your strong hands around '+sex3[player0.sex]
                   +' throat.');
                 d(config.textcolor,'A couple of minutes later and you realize that you are holding a stiff.');
                 d(config.textcolor,'You feel happy to have gotten rid of this piece of garbage.');
                 sd(global_plycol,player0.name2+'s');
                 d(config.textcolor,' face is pale and distorted in a frightened deathmask.');
                 d(config.textcolor,'Your soul darkens...');
                 crlf;
                end;
            'W':begin {wring neck}
                 crlf;
                 sd(config.textcolor,'You approach ');
                 sd(global_plycol,player0.name2);
                 d(config.textcolor,' and pretend to give');
                 d(config.textcolor,sex[player0.sex]+' some '+config.moneytype+'. But when '+sex2[player0.sex]+' reach for '
                   +sex3[player0.sex]
                        +' begging cup');
                 d(config.textcolor,'you charge '+sex[player0.sex]+' and place '+sex3[player0.sex]+' head between'
                   +' your strong');
                 sd(config.textcolor,'hands. A quick bend and ');
                 sd(global_plycol,player0.name2+'s');
                 d(config.textcolor,' neck snaps!');
                 sd(config.textcolor,'Only a short gurgling sound makes way through ');
                 d(global_plycol,player0.name2+'s');
                 d(config.textcolor,'lips before '+sex2[player0.sex]+' is dead...');
                 d(config.textcolor,'Your soul darkens...');
                 crlf;
                end;
            'T':begin {stab}
                 crlf;
                 sd(config.textcolor,'You sneak up behind ');
                 sd(global_plycol,player0.name2);
                 d(config.textcolor,' and swiftly');
                 sd(config.textcolor,'drive your dagger deep into '+sex3[player0.sex]+' back. ');
                 d(global_plycol,player0.name2);
                 d(config.textcolor,'grasp for air and tries to scream, but you hold a');
                 d(config.textcolor,'firm grip over '+sex3[player0.sex]+' mouth until the deed is done...');
                 d(config.textcolor,'Your soul darkens...');
                 crlf;
                end;
            'C':begin {cut throat}
                 crlf;
                 sd(global_plycol,player0.name2);
                 d(config.textcolor,' looks afraid you approach '+sex[player0.sex]+'...');
                 d(config.textcolor,'But you manage to get behind '+sex[player0.sex]+' and then quickly slice');
                 d(config.textcolor,sex3[player0.sex]+' throat. You then let the body slowly glide down to the');
                 d(config.textcolor,'ground and cover it with some old rags.');
                 d(config.textcolor,'Your soul darkens...');
                 crlf;
                end;
           end; {case .end.}


           {decrease number of dark deeds left today}
           dec(player.darknr);

           case cho of
            'S': s:=uplc+player.name2+config.textcol1+' strangled the innocent '+race_display(2,player0.race,0)+' '+uplc
                 +player0.name2+
                 config.textcol1+'.';
            'B': s:=uplc+player.name2+config.textcol1+' beat the '+race_display(2,player0.race,0)+' '+uplc+player0.name2
                  +config.textcol1+
                 ' to death with a club!';
            'W': s:=uplc+player.name2+config.textcol1+' wringed the innocent '+race_display(2,player0.race,0)+' '+uplc
                   +player0.name2+
                 's'+config.textcol1+' neck.';
            'T': s:=uplc+player.name2+config.textcol1+' stabbed '+uplc+player0.name2+config.textcol1+', the '
                   +race_display(2,player0.race,0)+'!';
            'C': s:=uplc+player.name2+config.textcol1+' sliced '+player0.name2+'s throat!';
           end; {case .end.}

           a:=' It all happened when '+uplc+player0.name2+config.textcol1+' was begging for '+config.moneytype+'.';

           {news-paper}
           newsy(true,
           'Brutal Murder!',
           ' '+s,
           a,
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {darkness points are handed out to player}
           xx:=100+random(15);
           Give_Darkness(player,xx);

           {mail the victim}
           post(MailSend,
           player0.name2,
           player0.ai,
           false,
           mailrequest_nothing,
           '',
           ulred+'Murdered!'+config.textcol1,
           umailheadc+mkstring(9,underscore)+config.textcol1,
           uplc+player.name2+config.textcol1+' viciously murdered you when you sat begging!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {take items}
           {removed because of imbalance}
           {swap_objects(player,player0,false);}

           {set offline player to 0 hitpoints (DEAD)}
           player0.hps:=0;

           {save offline player}
           user_save(player0);

           {worsen player0:s attitude to player}
           Update_Relation(Relation_Worsen,1,player0,player,false,false);

           {remove offline player}
           add_shadow(SRemove,player0,player.name2,'',0);

           {pause}
           pause;

          end;

         end
         else if (cho='G') and (player.chivnr<1) then begin
          crlf;
          d(config.textcolor,'You have run out of good deeds.');
          pause;
         end
         else if (cho='G') and (player.chivnr>0) then begin

          {give alms}
          d(config.textcolor,'Who shall receive your gift?');
          sd(config.textcolor,':');
          a:=get_string(20);
          a:=upcasestr(a);

          break_time:=false;
          for i:=1 to 2 do begin

           case i of
            1: size:=fs(FsPlayer);
            2: size:=fs(FsNpc);
           end; {case .end.}

           for j:=1 to size do begin

            load_character(player0,i,j);

            if (findsub(a,player0.name2)) and
               (player0.deleted=false) and
               (player0.hps>0) and
               (player0.location=offloc_beggarwall) and

               (confirm(uplc+player0.name2+config.textcol1,'n')=true) then begin

             crlf;
             d(config.textcolor,'Amount to give (max '+commastr(player.gold)+')');
             sd(config.textcolor,':');

             {get input}
             xx:=get_number(0,player.gold);

             if (xx<=player.gold) and (xx>0) then begin


              if confirm('Give '+uyellow+commastr(xx)+config.textcol1,'Y') then begin

               crlf;
               d(config.textcolor,'You approach '+uplc+player0.name2+config.textcol1+' and hand '
                +sex[player0.sex]+' the money.');
               crlf;
               sd(global_plycol,player0.name2);
               d(config.textcolor,' bless you for your kindness and quickly');
               d(config.textcolor,'returns to '+sex3[player0.sex]+' place. You feel how your soul');
               d(config.textcolor,'is lightening...');
               crlf;
               dec(player.chivnr,1);

               decplayermoney(player,xx);
               incplayermoney(player0,xx);

               {chivalry}
               xx:=random(10)+5;
               Give_Chivalry(player,xx);

               if (xx>500) and (random(2)=0) then begin
                {improve player0s attitude to player}
                update_Relation(Relation_Better,1,player0,player,false,false);
                d(config.textcolor,'Your relation with '+uplc+player0.name2+config.textcol1+' improves!');
               end;

               {inform other player}
               post(MailSend,
               player0.name2,
               player0.ai,
               false,
               mailrequest_nothing,
               '',
               umailheadc+'Beggar Gift'+config.textcol1,
               umailheadc+mkstring(11,underscore)+config.textcol1,
               uplc+player.name2+config.textcol1+' gave you '+commastr(xx)+' '+many_money(xx)+' when you sat begging!',
               'You blessed '+sex[player.sex]+'.',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '');

               {news-paper}
               newsy(true,
               'Good Doer at Beggars Wall',
               ' '+uplc+player.name2+config.textcol1+' gave alms to '+uplc+player0.name2+config.textcol1+'!',
               ' May the gods bless the good-hearted '+uplc+player.name2+config.textcol1+'!',
               '',
               '',
               '',
               '',
               '',
               '',
               '');


               {update offline player}
               user_save(player0);

               pause;

               break_time:=true;
               break;
              end
              else begin
               crlf;
               d(15,'You changed your mind..');
               break_time:=true;
               pause;
              end;

             end
             else begin
              crlf;
              d(config.textcolor,'You must be taking drugs...');
              break_time:=true;
              break;
             end;
            end;

           end; {for j:= .end.}

           if break_time then break;

          end; {for i:= .end.}

         end
         else begin
          crlf;
         end;
        end;
       end;

  end; {case .end.}

 until cho='R';

 crlf;

 {dispose pointer variables}
 dispose(objekt);

end; {Marketplace *end*}

end. {Unit Market .end.}
