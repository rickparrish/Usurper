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
Unit Lovers; {Usurper - love, hate and family stuff}

Interface

Procedure Love_Corner; {Lovers Corner}

Implementation

Uses Init, Jakob, Statusc, CMS,
     Various, Various2, News,
     Relation, Various3, Mail,
     Relatio2, Online,
     Children, Rating, GenNews,
     File_Io;

const local_place = 'Love Corner'; {name of this place}
var
    refresh : boolean;

Procedure Meny;
const offset = 23;
begin

 clearscreen;
 crlf;
 d(5,'-=*=- '+local_place+' -=*=-');
 crlf;
 d(config.textcolor,'Come and train your romantic skills. There is nothing');
 d(config.textcolor,'like a big family and a house.');
 d(config.textcolor,'You should also make up to the people you have hurt through the');
 d(config.textcolor,'years. You can poison other persons lives here as well.');
 crlf;

 menu2(ljust('(A)pproach somebody',offset));
 menu2(ljust('(C)hildren in the Realm',offset));

 sd(2,'  ');
 menu2('(L)ove history');

 crlf;

 menu2(ljust('(D)ivorce',offset));
 menu('(V)isit '+uplc+config.gossip_monger);

 {menu2(ljust('(H)ome',offset));}
 menu2(ljust('(M)arried Couples',offset));
 menu('(E)xamine child');


 menu2(ljust('(P)ersonal',offset));
 menu('(G)ift shop');

 menu2(ljust('(S)tatus',offset));
 menu('(R)eturn');

end; {meny *end*}

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   crlf;
   sd(config.textcolor,local_place+' ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin

   crlf;
   sd(config.textcolor,local_place+' (A,C,D,E,V,M,P,G,S,R,L,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure History_of_Love; {news history of divorces/marriages/childbirths}
var ch : char;
begin

 ch:='?';
 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_lovehistory then begin
   refresh:=true;
   onliner.location:=onloc_lovehistory;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;


  if ch='?' then begin
   clearscreen;
   crlf;
   d(5,'-*- History of Love -*-');
   crlf;
   d(config.textcolor,'See what''s happened during the years.');
   crlf;

   menu2('(M)arriages & Divorces   ');
   menu2('(T)op '+commastr(global_maxplayers)+', Child Producers  ');
   menu('(1) Current Marriages');

   menu2('(C)hild-births & Deaths  ');
   menu('(H)ated players, Top '+commastr(global_maxplayers));

   menu2('(R)eturn                 ');
   menu('(L)oved players, Top '+commastr(global_maxplayers));

   {menu('(R)eturn');}
   crlf;
  end;

  sd(config.textcolor,'History Room ('+config.textcol2+'?'+config.textcol1+' for menu) :');

  {get user-input}
  ch:=upcase(getchar);
  crlf;
  case ch of
   'M':begin {marriages, this file is also displayed in the LOVE HISTORY}
        crlf;
        if global_ansi then display_file(global_MarrHistANSI)
                       else display_file(global_MarrHistASCI);
        crlf;
       end;
   '1':begin {current marriages, this file is also displayed at lovers main menu}
        clearscreen;
        list_married_couples;
       end;
   'C':begin {child-births}
        crlf;
        if global_ansi then display_file(global_ChildBirthHistANSI)
                       else display_file(global_ChildBirthHistASCI);
        crlf;
       end;
   'L':begin {most loved players}
        feeling_list(global_RelationLove);
       end;

   'H':begin {most hated players}
        feeling_list(global_RelationHate);
       end;
   'T':begin {rankings of top child producers}
        Child_Producers;
        crlf;
       end;
  end; {case .end.}

 until ch='R';

end; {history of love *end*}

Procedure The_Witch; {gossip_mongers place}
var ch : char;

  abort,
  found,
  visit_done : boolean;

  ReturnFileId : byte;
  price : longint;

  s : s90;

  i,
  j,
  size : word;

  x:byte;

  pl0,
  pl1  : ^UserRec;

begin

 {[lydia] is a gossip-monger but she also handles abortions}

 {init}
 new(pl0);
 new(pl1);

 visit_done:=false;
 ch:='?';
 repeat

  {update online location, if necessary}
  if onliner.location<>onloc_gossipmonger then begin
   refresh:=true;
   onliner.location:=onloc_gossipmonger;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  if ch='?' then begin
   crlf;
   crlf;
   d(global_plycol,config.gossip_monger+config.textcol1+' can help you with various problems.');
   crlf;
   menu('(S)py on relations');
   menu('(P)oison relation');
   menu('(H)ave an abortion');
   menu('(R)eturn');
   crlf;
  end;

  sd(config.textcolor,'Gossip-monger ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  {get user-input}
  ch:=upcase(getchar);
  crlf;

  {evaluate user-input}
  case ch of
   'R':begin {return}
        visit_done:=true;
       end;
   'P':begin {poison relation}
        crlf;
        crlf;
        if player.darknr<1 then begin
         {no dark deeds left}
         no_dark_deeds;
         pause;
        end
        else begin
         d(9,'-*Dirty Trick*-');
         d(config.textcolor,'Name the two persons who''s relation you would like to ruin');
         d(config.textcolor,'(failed attempts will be reported to the people you are trying to hurt!)');

         d(11,'first person you want to harm');
         if select_character(pl0^,false)=true then begin
          crlf;
          d(11,'second person you want to harm');
          if select_character(pl1^,false)=true then begin
           if (pl0^.name2=pl1^.name2) and (pl0^.id=pl1^.id) then begin
            d(12,'Idiot!');
           end
           else begin
            crlf;
            if confirm('Setup '+uplc+pl0^.name2+config.textcol1+' against '+uplc+pl1^.name2
                       +config.textcol1,'Y')=true then begin

             price:=(pl0^.level*15000)+(pl1^.level*15000);

             if player.gold<price then begin
              d(12,'It will cost you '+commastr(price)+' '+many_money(price));
              you_cant_afford_it; {generic message}
              pause;
             end
             else begin
              d(15,'Ok.');

              {pay gold + 1 dark deed}
              decplayermoney(player,price);
              dec(player.darknr);

              sd(global_plycol,config.gossip_monger+config.textcol1+' promises to spread the most vicious slander..');
              make_delay_dots(config.textcolor,4,600);
              crlf;
              x:=random(3);
              {x:=0; {fusk!}
              if x=0 then begin
               {*POISON RELATION SUCCEDED*}
               s:=uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1;
               d(15,'SUCCESS!');
               case random(3) of
                0: d(15,'A note of discord crept into the '+s+' relationship!');
                1: d(15,s+' distrust each other!');
                2: d(15,s+' relationship is deteriorating!');
               end; {case .end.}
               crlf;

               {worsen pl0:s attitude to pl1}
               Update_Relation(Relation_Worsen,2,pl0^,pl1^,false,false);

               {worsen pl1:s attitude to pl0}
               Update_Relation(Relation_Worsen,2,pl1^,pl0^,false,false);

               {informing pl0}
               post(MailSend,
               pl0^.name2,
               pl0^.ai,
               false,
               mailrequest_nothing,
               '',
               ulred+'Bad Feeling'+config.textcol1,
               mkstring(11,underscore),
               uplc+pl1^.name2+config.textcol1+' is trying to set you up!',
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

               {informing pl1}
               post(MailSend,
               pl1^.name2,
               pl1^.ai,
               false,
               mailrequest_nothing,
               '',
               ulred+'Bad Feeling'+config.textcol1,
               mkstring(11,underscore),
               uplc+pl0^.name2+config.textcol1+' is trying to hurt you and your family!',
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

               {news-paper}
               newsy(true,
               'Disagreement',
               ' '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1+' had an argument.',
               '',
               '',
               '',
               '',
               '',
               '',
               '',
               '');

              end
              else begin
               {*POISON RELATION ATTEMPT FAILED*}
               d(12,'Dang! It failed! They saw through your petty little scheme!');
               d(global_plycol,pl0^.name2+config.textcol1+' is very upset!');
               d(global_plycol,pl1^.name2+config.textcol1+' is pissed off!');
               crlf;

               {worsen pl0:s attitude to player}
               Update_Relation(Relation_Worsen,1,pl0^,player,false,false);

               {worsen pl1:s attitude to player}
               Update_Relation(Relation_Worsen,1,pl1^,player,false,false);

               {informing pl0, if online}
               if is_online(pl0^.name2,online_player)=true then begin
                online_send_to_player(pl0^.name2,online_player,uplc+player.name2+config.textcol1+' tried to poison your'
                                      +' relation with '+uplc+pl1^.name2+config.textcol1+'!');
               end;

               {informing pl0}
               post(MailSend,
               pl0^.name2,
               pl0^.ai,
               false,
               mailrequest_nothing,
               '',
               ulred+'Intriguer!'+config.textcol1,
               mkstring(10,underscore),
               uplc+player.name2+config.textcol1+' tried to poison your relation with '+uplc+pl1^.name2+config.textcol1+'!',
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

               {informing pl1, if online}
               if is_online(pl1^.name2,online_player)=true then begin
                online_send_to_player(pl1^.name2,online_player,uplc+player.name2+config.textcol1+' tried to poison your'
                                      +' relation with '+uplc+pl0^.name2+config.textcol1+'!');
               end;

               {informing pl1}
               post(MailSend,
               pl1^.name2,
               pl1^.ai,
               false,
               mailrequest_nothing,
               '',
               ulred+'Intriguer!'+config.textcol1,
               mkstring(10,underscore),
               uplc+player.name2+config.textcol1+' tried to poison your relation with '+uplc+pl0^.name2+config.textcol1+'!',
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

               {news-paper}
               newsy(true,
               'Intriguer!',
               ' '+uplc+player.name2+config.textcol1+' was exposed trying to poison the relation',
               ' between '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1+'.',
               '',
               '',
               '',
               '',
               '',
               '',
               '');

              end;
             end;
            end;
           end;
          end;
         end;
        end;

       end;
   'H':begin {have an abortion}

        crlf;
        crlf;

        {a guy trying}
        if player.sex=1 then begin
         d(12,'Ha ha ha...very funny.');
         pause;
        end
        else begin

         if player.pregnancy>0 then begin
          price:=player.level*150000;
          if player.gold<price then begin
           d(12,'It will cost you '+commastr(price)+' '+many_money(price));
           you_cant_afford_it; {generic message}
           pause;
          end
          else if confirm('Pay '+uyellow+commastr(price)+config.textcol1
                          +' '+many_money(price)+' for an abortion','N')=true then begin

           d(15,'Ok.');
           sd(config.textcolor,'You place yourself on the table, while '+uplc+config.gossip_monger+config.textcol1+
             ' gets her tools...');
           make_delay_dots(config.textcolor,4,700);
           crlf;
           sd(config.textcolor,'A moment later '+uplc+config.gossip_monger+config.textcol1+' returns and goes to work...');

           {update player stats}
           player.pregnancy:=0;
           user_save(player);

           {inform father: player.fatherId}
           found:=false;

           i:=look_for_id(player.fatherid,'H',ReturnFileId);

           load_character(pl0^,ReturnFileId,i);

           if pl0^.id=player.fatherid then found:=true;

           if found then begin
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+'Spies!'+config.textcol1,
            mkstring(6,underscore),
            uplc+player.name2+config.textcol1+' spied on your personal relations.',
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
           end;

           {inform all nodes}
           online_send_to_all(uplc+player.name2+config.textcol1+' had an ABORTION!',player.name2,'');

           {news-paper}
           newsy(true,
           'Abortion',
           ' '+uplc+player.name2+config.textcol1+' hired '+uplc+config.gossip_monger+config.textcol1
              +', the midwife, to have an abortion.',
           ' The Realm was denied a new and longed-for citizen.',
           ' Shame on '+uplc+player.name2+config.textcol1+'!!',
           '',
           '',
           '',
           '',
           '',
           '');

           crlf;
           crlf;
           d(15,'The Abortion is completed!');
           d(global_plycol,config.gossip_monger+config.textcol1+' smiles at you.');
           d(config.textcolor,'You are exhausted, but also relieved that everything went well.');
           pause;
           crlf;

          end;
         end
         else begin
          d(12,'You silly woman! You are not pregnant!');
          pause;
         end;
        end;
       end; {have an abortion *end*}

   'S':begin {spy on relations}
        {cost for using Lydias information}
        price:=1500;

        crlf;
        crlf;
        d(global_plycol,config.gossip_monger+config.textcol1+' the gossip-monger knows everyting worth knowing');
        d(config.textcolor,'of people when it comes to love and relations. Even though the old witch');
        d(config.textcolor,'knows too much for her own good, nobody has ever dared to harm her...');
        d(global_plycol,config.gossip_monger+'s'+config.textcol1+' fondness of idle gossip has made her a wealthy woman.');
        d(config.textcolor,'You must pay her '+uyellow+commastr(price)+config.textcol1+' '+many_money(price)+' for any kind of'
                           +' information.');
        crlf;

        if confirm('Agreed','Y')=false then begin
         crlf;
         d(12,'Begone!');
        end
        else begin
         if player.gold<price then begin
          crlf;
          d(12,'You haven''t got enough '+config.moneytype+'!');
         end
         else begin
          crlf;
          d(config.textcolor,'Who''s relations would you like to examine?');
          sd(config.textcolor,':');

          {get string}
          s:=get_string(20);

          abort:=false;
          found:=false;
          for i:=1 to 2 do begin

           case i of
            1: size:=fs(FsPlayer);
            2: size:=fs(FsNpc);
           end; {case .end.}

           for j:=1 to size do begin

            load_character(pl0^,i,j);

            if (findsub(s,pl0^.name2)) and
               (pl0^.name2<>player.name2) and
               (pl0^.deleted=false) then begin

             if confirm(uplc+pl0^.name2+config.textcol1,'N')=true then begin
              {found person!}
              found:=true;
             end
             else begin
              if confirm('Continue search','Y')=false then begin
               abort:=true;
              end;
             end;

            end;

            if (found) or (abort) then break;

           end; {for j:= .end.}

           if (found) or (abort) then break;

          end; {for i:= .end.}

          if (found=false) and (abort=false) then begin
           Could_Not_Locate_Character; {generic message}
          end
          else if found=true then begin

           {display other persons relations}
           personal_relations(pl0^,true);
           crlf;

           {inform other pl0 that he has been spied upon}
           if random(2)=0 then begin
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+'Spies!'+config.textcol1,
            mkstring(6,underscore),
            uplc+player.name2+config.textcol1+' spied on your relations.',
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
           end;

          end;

         end;

        end;
       end; {spy on relations *end*}

  end; {case .end.}

 until visit_done;

 {dispose pointer vars}
 dispose(pl0);
 dispose(pl1);

end; {the_witch .end.}

Procedure Love_Corner; {MAIN *START*}
const
      roses_cost = 1500;        {gift shop item}

var

   ch,
   relation_sign : char;

   s : s100;
   s1,
   s2 : s70;

   done,
   save,
   found,
   abort,
   go_ahead,
   anonymous,
   really_done,
   location_done : boolean;

   i,
   j,
   size,
   new_relation : word;

   x,
   y,
   price,
   Poison_Cost,           {cost to send poison}
   WeddingCost : longint; {cost to marry}

   pl0      : ^UserRec;     {User Record}
   King     : ^KingRec;     {King Record}
   Relation : ^RelationRec; {Relation Record}

   NewRelVal : word;

procedure divorce; {get a divorce, remember that the kids will lose a parent}
var i, j : word;
   child : childrec;
begin

 crlf;
 crlf;

 if random(2)=0 then begin
  d(5,'Better get rid of the matrimonial bonds right away!');
 end
 else begin
  d(5,'Single Life! Here I come!');
 end;

 s:=is_player_married(player.name2,player.id);

 if s<>'' then begin
  found:=false;
  {load spouse}
  for i:=1 to 2 do begin

   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end;

   for j:=1 to size do begin
    load_character(pl0^,i,j);

    if pl0^.name2=s then begin
     found:=true;
     break;
    end;

   end; {for j:= .end.}

   if found then break;

  end; {for i:= .end.}

 end;

 if found=false then begin

  d(12,'You are not married bird-brain!');
  d(12,'Go and find yourself a '+sex5[player.sex]+' before it''s too late!');
  pause;
  crlf;

 end
 else begin

  {NOTE that this divorce routine is more or less duplicated in
    Home.pas, when a NPC spouse executes a divorce}


  {establish spouse online}
  if add_shadow(SAdd,pl0^,player.name2,'intimate with '+uplc+player.name2+config.textcol1,0)=false then begin
   {we were (for some reason) unable to add pl0 to the online file}
   crlf;
   d(12,'Sorry, you can''t divorce '+uplc+pl0^.name2+ulred+' right now!');
   pause;
  end
  else begin

   if add_couples_children_online(player,pl0^,'seeing parents')=false then begin

    {remove couples children}
    remove_couples_children_online(player,pl0^);

    crlf;
    d(12,'You were unable to gather the whole family!');
    d(12,'In order to get a divorce you must gather your spouse and children.');
    d(12,'(try again soon!)');
    crlf;
    pause;
   end
   else begin

    d(15,'The family is gathered!');

    {load relation}
    Social_Relation(player,pl0^,relation^);

    {correct relation}
    correct_relation(player.name2,relation^);

    d(config.textcolor,'You and '+uplc+pl0^.name2+config.textcol1+' have been married for '
      +uwhite+commastr(relation^.marrieddays)+config.textcol1+' days.');

    if confirm('Divorce '+uplc+pl0^.name2+config.textcol1,'N')=true then begin

     if confirm('You will lose custody of your children! Go ahead anyway','N')=true then begin
      d(15,'Ok.');
      d(global_plycol,pl0^.name2+config.textcol1+' is gone at last, and good riddance!');

      if relation^.marrieddays<1 then begin
       s:=' Their marriage lasted only a couple of hours!!';
      end
      else if relation^.marrieddays<30 then begin
       s:=' Their marriage lasted only '+uwhite+commastr(relation^.marrieddays)+config.textcol1+' days.';
      end
      else begin
       s:=' Their marriage lasted '+uwhite+commastr(relation^.marrieddays)+config.textcol1+' days.';
      end;

      {update relation}
      relation^.relation1:=global_RelationNormal;
      relation^.relation2:=global_RelationHate;
      relation^.marrieddays:=0;

      {set player married flags}
      player.married:=false;
      pl0^.married:=false;
      user_save(player);
      user_save(pl0^);

      {save relation}
      load_relation(fsave,relation^,relation^.recnr);

      {news-paper}
      Newsy(true,
      'Divorce!',
      ' '+uplc+player.name2+config.textcol1+' divorced '+uplc+pl0^.name2+config.textcol1+'!',
      s,
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      {divorce-log, see duplicate code in relation.pas}
      Generic_News(MarriageDivorceNews,
       false,
       ugreen+'['+fix_date(todays_date)+'] '+uplc+player.name2+ugreen+' and '+uplc+pl0^.name2+ugreen+' were '+ulred+'Divorced'
         +ugreen+'!',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

      {note that this code is duplicated in
        relation.pas => npc_change_relations and home.pas
      The children will be placed with the spouse! important decision
       made by the author.. but I think this can prove to be interesting}
      {the children are going to be depressed automatically}
      {however, if a spouse is dead or deleted then the children will
       of course stay with the player and not get depressed.}

      {NOTE! DANGER! if a child is already online it will not be properly
       updated! you could solve this by putting all the children online
       like you do to the spouse above. and refuse divorce if this is
       not possible}

      for i:=1 to fs(FsChildren) do begin

       {load child}
       if load_child(fload,child,i)=true then begin

        {is this child produced by player and spouse?}
        if (my_child(player,child)=true) and
           (my_child(pl0^,child)=true) then begin

         {refuse player access to this child}
         if player.sex=1 then child.fatheraccess:=false;
         if player.sex=2 then child.motheraccess:=false;

         d(12,'You have lost custody of your '+sex7[child.sex]+' '+ukidc+child.name+ulred+'!');

         {set child health to depressed}
         child.health:=ChildHealth_Depressed;

         {inform spouse of child depression}
         s:='Depression';
         post(MailSend,
         pl0^.name2,
         pl0^.ai,
         false,
         mailrequest_nothing,
         '',
         ulred+s+config.textcol1,
         mkstring(length(s),underscore),
         ukidc+child.name+config.textcol1+', your '+sex7[child.sex]+', is suffering from a '+ulred+'depression'+config.textcol1
             +'!',
         'The divorce you are going through is not good for the children!!',
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

         {inform spouse of gained custody}
         s:='Divorce Consequences';
         post(MailSend,
         pl0^.name2,
         pl0^.ai,
         false,
         mailrequest_nothing,
         '',
         umailheadc+s+config.textcol1,
         mkstring(length(s),underscore),
         'You are now fully responsible for '+ukidc+child.name+config.textcol1+', your '+sex7[child.sex]+'!',
         uplc+player.name2+config.textcol1+' has left you and the children!',
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
         Newsy(true,
         'Child depressed!',
         ' '+ukidc+child.name+config.textcol1+', the '+sex7[child.sex]+' of '+uplc+child.mother
           +config.textcol1+' and '+uplc+child.father+config.textcol1+' is',
         ' suffering from a '+ulred+'depression'+config.textcol1+' as a direct result of the',
         ' parents divorce.',
         '',
         '',
         '',
         '',
         '',
         '');

         {save updated child}
         load_child(fsave,child,child.recnr);

        end;
       end;

      end; {for i:= .end.}

      {inform other nodes}
      online_send_to_all(uplc+player.name2+config.textcol1+' divorced '+uplc+pl0^.name2+config.textcol1
        +'!',player.name2,'');

      {mail ex-wife/husband}
      s:='Divorce!';
      post(MailSend,
      pl0^.name2,
      pl0^.ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+s+config.textcol1,
      mkstring(length(s),underscore),
      uplc+player.name2+config.textcol1+' divorced you!',
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

     end
     else begin
      crlf;
      d(15,'Good choice! Don''t give up your marriage for no good reason.');
     end;
    end
    else begin
     crlf;
     d(15,'Good choice! Don''t give up your marriage for no good reason.');
    end;

    {remove couples children}
    remove_couples_children_online(player,pl0^)

   end;

   {remove pl0^ from online list}
   add_shadow(SRemove,pl0^,'','',0);

  end;

 end;

end; {divorce *end*}

procedure change_feelings_menu;
begin

 done:=false;

 repeat

  crlf;
  s:='You and '+pl0^.name2+'.';
  d(config.textcolor,'You and '+uplc+pl0^.name2+config.textcol1+'.');
  sd(config.textcolor,cool_string(length(s),'=','-',10,2));

  {load relation}
  Social_Relation(player,pl0^,relation^);
  {correct relation}
  correct_relation(player.name2,relation^);

  {display current relation}
  view_one_relation(player.name2,pl0^.name2,true);
  crlf;
  crlf;
  d(config.textcolor,'Declare Your Feelings for '+uplc+pl0^.name2+config.textcol1+' !!');

  d(9,'<R>espect <T>rust <F>riendship <P>assion <L>ove');
  d(6,'<N>eutral');
  d(12,'<S>uspicion <A>nger <E>nemy <H>ate');
  d(config.textcolor,'(D)one');
  crlf;
  sd(config.textcolor,'Pick a Feeling :');

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user-input}
  newrelval:=0;
  case ch of
   'D': done:=true;
   'L':begin
        d(12,'Love!');
        newrelval:=global_relationLove;{love}
       end;
   'P':begin
        d(12,'Passion!');
        newrelval:=global_relationPassion;{passion}
       end;
   'F':begin
        d(5,'Friends!');
        newrelval:=global_relationFriendship;{friendship}
       end;
   'T':begin
        d(5,'Trust relationship');
        newrelval:=global_relationTrust;{trust}
       end;
   'R':begin
        d(5,'Respect!');
        newrelval:=global_relationRespect;{respect}
       end;
   'N':begin
        d(5,'Neutral');
        newrelval:=global_relationNormal; {neutral}
       end;
   'S':begin
        d(12,'Suspicion!');
        newrelval:=global_relationSuspicious;{suspicious}
       end;
   'A':begin
        d(12,'Anger!');
        newrelval:=global_relationAnger;{anger}
       end;
   'E':begin
        d(12,'Enemy!');
        newrelval:=global_relationEnemy;{enemy}
       end;
   'H':begin
        d(12,'Hate!');
        newrelval:=global_relationHate;{hate}
       end;
  end; {case .end.}

  if (newrelval<>0) and
     (newrelval<>relation^.relation1) then begin

   crlf;
   crlf;
   if confirm('Are You sure','Y')=true then begin

    {some text..}
    d(15,'You declare your feelings to '+uplc+pl0^.name2+config.textcol1+'!');
    case random(6) of
     0: d(global_plycol,pl0^.name2+config.textcol1+' looks at you somewhat puzzled.');
     1: d(global_plycol,pl0^.name2+config.textcol1+' looks distraught.');
     2: d(global_plycol,pl0^.name2+config.textcol1+' smiles.');
     3: d(global_plycol,pl0^.name2+config.textcol1+' looks indifferent.');
     4: d(global_plycol,pl0^.name2+config.textcol1+' is silent.');
     5: d(global_plycol,pl0^.name2+config.textcol1+' smiles.');

    end; {case .end.}


    {display picture if this is a love/hate update}
    case newrelval of
     global_relationLove:begin
                          d(12,'LOVE! LOVE! LOVE! LOVE!');
                          show_usurper_data(picture_HEART,false);
                         end;
     global_relationhate:begin
                          d(12,'HATE! HATE! HATE! HATE!');
                          show_usurper_data(Picture_Death_Head,false);
                         end;
    end; {case .end.}


    {update relation with new value}
    relation^.relation1:=newrelval;
    load_relation(fsave,relation^,relation^.recnr);

    {inform other player of changed relation}
    Relation_Change_Mail(player,pl0^,relation^.relation1);

    {put new relation in the news}
    Relation_Change_News(player,pl0^,newrelval);

    pause;

    done:=true;

   end;

  end;

 until done;

end; {change_feelings_menu *end*}

procedure marry_routine; {Marriage!, when two become one}
var i : word;
  child : ^childrec;
begin

 {init}
 new(child);

 s1:=is_player_married(player.name2,player.id);
 s2:=is_player_married(pl0^.name2,pl0^.id);

 if global_registered=false then begin
  crlf;
  Only_In_Registered_Version;
  pause;
 end
 else if (pl0^.sex=player.sex) and (Config.AllowHomoRelations=false) then begin
  no_homo_relations;
  pause;
 end
 else if player.IntimacyActs<1 then begin
  {no acts of intimacy left}
  no_intimate_acts;
 end
 else if (player.name2=s2) and (pl0^.name2=s1) then begin
  crlf;
  d(12,'You two are already married! (dummy!)');
  pause;
 end
 else if s2<>'' then begin
  {the other player is married}
  crlf;
  d(global_plycol,pl0^.name2+config.textcol1+' is already married to '+uplc+s2+config.textcol1+'!');
  pause;
 end
 else if s1<>'' then begin

  {player is married}
  crlf;
  crlf;
  if player.sex=1 then s:='Buster'
                  else s:='Darling';

  d(12,'Hey '+s+'! You are already married!');
  sd(12,'Go look after your family instead of chasing ');
  case player.sex of
   1: d(12,'girls.');
   2: d(12,'guys.');
  end;

  pause;

 end
 else if Relation^.BannedMarry=true then begin
  {marriage between the two has beeen banned by the Royals}

  {load the king}
  load_king(fload,king^);

  s:=KingString(king^.sexy)+' '+ukingc+king^.name;

  crlf;
  d(config.textcolor,'The Royal House has decided that your relation with '+uplc+pl0^.name2);
  d(config.textcolor,'is '+ulred+'undesirable'+config.textcol1+'. You cannot marry in this Realm.');
  d(config.textcolor,'/'+s+config.textcol1+', your enlightened leader.');
  pause;
 end
 else if (player.age<config.MinimumAgetoMarry) or
         (pl0^.age<config.MinimumAgetoMarry) then begin

  {some of the players is too young for the sacred act}
  if player.age<config.MinimumAgetoMarry then begin
   d(12,'You are too young to marry! (required age is '+commastr(config.minimumagetomarry)+')');
  end
  else begin
   d(global_plycol,pl0^.name2+config.textcol1+' is too young to marry! (required age is '
     +commastr(config.minimumagetomarry)+')');
  end;

  pause;
 end
 else begin

  {Allowed to Marry!}
  done:=false;
  d(15,'MARRY');
  crlf;

  if relation^.MarriedTimes>0 then begin
   if relation^.marriedtimes>1 then s:='times'
                               else s:='time';
    d(15,'You and '+uplc+pl0^.name2+uwhite+' have been married '+uyellow+commastr(relation^.marriedtimes)+uwhite
        +' '+s+' before.');
  end;

  if confirm('Marry '+uplc+pl0^.name2+config.textcol1,'N')=true then begin

   {the wedding costs money}
   weddingcost:=player.level*150000;

   if player.gold<weddingcost then begin
    crlf;
    d(12,'Your wedding will cost '+uyellow+commastr(weddingcost)+ulred+'.');
    d(12,'You don''t have the '+config.moneytype+'!');
    pause;
   end
   else begin

    if confirm('Pay '+uyellow+commastr(weddingcost)+config.textcol1+' '+many_money(weddingcost)
       +' for the wedding','Y')=true then begin

     {relation needs to be "IN LOVE" from both sides before marriage}
     if (relation^.relation1=global_RelationLove) and
        (relation^.relation2=global_RelationLove) then begin
     {pay for the wedding}
     DecPlayerMoney(player,weddingcost);

      crlf;
      d(15,'MARRIAGE!');
      show_usurper_data(picture_HEART,true);
      d(5,'The Church');
      d(config.textcolor,'You stand before Bishop '+ulmag+config.bishop+config.textcol1+'.');
      d(config.textcolor,'You and '+uplc+pl0^.name2+config.textcol1+' take each others hands...');
      d(global_talkcol,'"What God has joined, man must not divide...!"');

      {d(config.talkcolor,'Do you '+uplc+pl0^.name2+config.textcol1+' take '+uplc+player.name2+config.textcol1
        +' as your lawfully ...');
      }

      {news-paper}
      case random(3) of
       0: s:=' The church was crowded with relatives and friends.';
       1: s:=' Not many came to honor the newly wed...';
       2: s:=' The mayor held a party for the newly wed!';
      end; {case .end.}

      {news-paper}
      newsy(true,
      'Wedding!',
      ' '+uplc+player.name2+config.textcol1+' the '+race_display(2,player.race,0)+' and '+uplc+pl0^.name2
         +config.textcol1+' the '+race_display(2,pl0^.race,0)+' were married!',
      s,
      '',
      '',
      '',
      '',
      '',
      '',
      '');


      {marriage-log, see duplicate code in relation.pas}
      Generic_News(MarriageDivorceNews,
       false,
       ugreen+'['+fix_date(todays_date)+'] '+uplc+player.name2+ugreen+' and '+uplc+pl0^.name2+ugreen+' were '+uyellow+'Married'
         +ugreen+'.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

      {mail other player}
      s:='Marriage!';
      post(MailSend,
      pl0^.name2,
      pl0^.ai,
      false,
      mailrequest_nothing,
      '',
      uyellow+s+config.textcol1,
      mkstring(length(s),underscore),
      uplc+player.name2+config.textcol1+' and you were married!',
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

      {inform other nodes}
      online_send_to_all(uplc+player.name2+config.textcol1+' and '+uplc+pl0^.name2+config.textcol1
                         +' were married!',player.name2,'');

      {set new relation}
      relation^.relation1:=global_RelationMarried;
      relation^.relation2:=global_RelationMarried;
      relation^.marrieddays:=0;
      inc(relation^.marriedtimes);

      {save relation}
      load_relation(fsave,relation^,relation^.recnr);

      {decrease initmate sessions}
      dec(player.IntimacyActs);

      {well, the two lovebirds who now marries could have children
       from a previous marriage. the parents will now get access to
       these children (remember that custody is rewarded one parent
       when a divorce occurs)}
      {Danger! this routine is not fool-proof, should one of the children
       already be online when this routine runs..then this child will
       not be updated correctly. this is not a big problem though, since
       a parent easily can share custody and thereby correct the problem
       NOTE! : this routine is copied in relation.pas =>npc_set_out_to_marry }

      for i:=1 to fs(FsChildren) do begin

       {load child}
       if load_child(fload,child^,i)=true then begin

        if (child^.deleted=false) and
           (my_child(player,child^)=true) and
           (my_child(pl0^,child^)=true) then begin

         if add_child(SAddChild,child^,player.name2,'joining parents',0)=true then begin

          x:=child^.age*850;

          d(15,'You share custody of your '+sex7[child^.sex]+' '+child^.name+'!');
          d(14,child^.name+' is happy when '+sex2[child^.sex]+' sees '+sex3[child^.sex]+' parents join again!');
          d(config.textcolor,'You and '+uplc+pl0^.name2+config.textcol1+' receive '+commastr(x)+' experience points for making'
            +' your children happy!');

          {give parents xp}
          incplayerexp(player,x);
          incplayerexp(pl0^,x);

          {update child}
          child^.motheraccess:=true;
          child^.fatheraccess:=true;
          child^.health:=ChildHealth_Normal;
          load_child(fsave,child^,child^.recnr);

          {inform spouse of happy event and xp!}
          post(MailSend,
          pl0^.name2,
          pl0^.ai,
          false,
          mailrequest_nothing,
          '',
          uyellow+'Happy Child!'+config.textcol1,
          'You receive '+uwhite+commastr(x)+config.textcol1+' experience points for making your',
          sex7[child^.sex]+' '+ukidc+child^.name+config.textcol1+' extremely happy by marrying',
          uplc+player.name2+config.textcol1+' the '+classnames[player.class]+'.',
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

          {remove shadow child}
          add_child(SRemoveChild,child^,'','',0);

         end;

        end;
       end;

      end; {for i:= .end.}

      {set player married flags}
      player.married:=true;
      pl0^.married:=true;
      {update statistics}
      inc(player.marriedtimes);
      inc(pl0^.marriedtimes);

      user_save(player);
      user_save(pl0^);

      {text}
      d(config.textcolor,'Marriage complete.');

      {display message depending on male-female, or homo relationship}
      if player.sex<>pl0^.sex then begin
       d(14,'Congratulations! (go home and make babies)');
      end
      else begin
       d(14,'Congratulations! (go home and adopt babies)');
      end;

      really_done:=true;
      pause;

     end
     else begin

      crlf;
      d(12,'You both need to be in love with each other to marry!');
      pause;

     end;

    end;
   end;
  end;
 end;

 {dispose temporary vars}
 dispose(child);


end; {marry_routine *end*}

var child : childrec;
 mysex : char;
begin

 {intro text}
 crlf;
 crlf;
 sd(config.textcolor,'You enter '+config.textcol2+local_place+config.textcol1+'.');
 crlf;

 {init pointer vars}
 new(pl0);
 new(king);
 new(relation);

 location_done:=false;
 repeat

  {update online location, if necessary}
  if (onliner.location<>onloc_lovestreet) or
     (onliner.doing<>location_desc(onliner.location)) then begin
   refresh:=true;
   onliner.location:=onloc_lovestreet;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,Onliner);
  end;

  {menu}
  display_menu(true,true);

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user input}
  case ch of
   '?':begin {menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'R':begin {return}
        location_done:=true;
       end;
   'L':begin {history of love}
        history_of_love;
       end;
   'C':begin {list of of all children in the realm}
        crlf;
        crlf;
        children_in_realm('','',true,true);
       end;
   'P':begin {personal, list of relations}
        personal_relations(player,false);
        crlf;
        pause;
        {summary of relations}
        summary_of_player_relations(player);
       end;
   'E':begin {examine child}
        crlf;
        crlf;
        d(11,'-*Examine Child*-');
        if select_a_child(player,child,anychild,excludenone,false) then begin
         child_view(child);
        end;

       end; {examine child .end.}
   'G':begin {gift_shop}
        crlf;
        crlf;
        d(config.textcolor,'You enter the small Gift Shop.');
        crlf;
        crlf;

        {update online location, if necessary}
        if onliner.location<>onloc_giftshop then begin
         refresh:=true;
         onliner.location:=onloc_giftshop;
         onliner.doing   :=location_desc(onliner.location);
         add_onliner(OUpdateLocation,onliner);
        end;

        done:=false;
        ch:='?';
        repeat

         if ch='?' then begin
          {gift shop menu}
          crlf;
          s:='Gift Shop';

          d(2,cool_string(length(s),'=','-',5,10));
          d(5,s);
          d(2,cool_string(length(s),'=','-',5,10));

          menu('(B)ouquet of roses');
          menu('(S)urprise Box');
          menu('(P)oison');
          menu('(H)elp');
          menu('(R)eturn');
          crlf;
         end;

         case player.sex of
          1: s:='Sir';
          2: s:='Madam';
         end; {case .end.}

         sd(config.textcolor,'Gift Shop ('+config.textcol2+'?'+config.textcol1+' for menu):');

         {get user-input}
         ch:=upcase(getchar);

         crlf;
         {evaluate user-input}
         case ch of
          'H':begin
               crlf;
               d(15,'Buy a gift to impress your friend or date.');
               d(15,'Send poison to your enemies.');
               pause;
               crlf;
               crlf;
              end;
          'S':begin {surprise box}
               crlf;

               {get receiver}
               d(config.textcolor,'Who shall receive the gift-box?');
               found:=select_character(pl0^,false);

               if found then begin

                d(15,'OK.');

                d(config.textcolor,'Select Gift');
                menu('(C)hocolate');
                menu('(S)corpions');
                menu('(A)bort');
                sd(config.textcolor,':');

                repeat
                 {get user-input}
                 ch:=upcase(getchar);
                until ch in ['C','S','A'];

                crlf;
                {evaluate user-input}
                case ch of
                 'A':begin {abort}
                      d(15,'Aborted!');
                     end;
                 'C':begin {chocolate}
                      {set price}
                      price:=pl0^.level*55000;

                      {}
                      d(config.textcolor,'Sending '+uyellow+'Chocolate'+config.textcol1+' to '+uplc+pl0^.name2
                                         +config.textcol1+' will cost '+uyellow+commastr(price)+config.textcol1+'.');

                      if player.gold<price then begin
                       you_cant_afford_it;
                       pause;
                      end
                      else if player.chivnr<1 then begin
                       no_good_deeds;
                       pause;
                      end
                      else begin
                       {sending chocolate!}
                       crlf;
                       d(config.textcolor,'Nice nice!');
                       d(config.textcolor,'Delivering '+uyellow+'Chocolate'+config.textcol1+' is a nice gesture.');
                       if confirm('Go ahead','Y')=false then begin
                        d(12,'Aborted.');
                       end
                       else begin

                        d(15,'You pay '+uyellow+commastr(price)+uwhite+' '+many_money(price)+'.');
                        {pay}
                        DecPlayerMoney(player,price);
                        Dec(player.darknr);

                        {if target is human then we mail the box, otherwise
                         npc opens it right away.}
                        case pl0^.ai of
                         'C':begin {npc player handles #box with chocolate#}

                              {first we must put pl0 online}
                              sd(13,'Teleporting '+uplc+pl0^.name2+ulmag+'...');

                              if add_shadow(SAdd,pl0^,player.name2,'receiving gift',0)=false then begin
                               {unable to add pl0}
                               crlf;
                               crlf;
                               d(global_plycol,pl0^.name2+config.textcol1+' is busy!');
                               pause;
                              end
                              else begin
                               crlf;
                               x:=random(3);
                               if x=0 then begin
                                {npc opens the box!}
                                 sd(global_plycol,pl0^.name2+config.textcol1+' puts '+sex3[pl0^.sex]+' hand in the box...and'
                                   +' out comes.');
                                make_delay_dots(config.textcolor,4,800);
                                d(14,'CHOCOLATE!'+uwhite+'!');

                                {should npc be grateful or not...}
                                case random(2) of
                                 0:begin {grateful}
                                    show_usurper_data(picture_SMALL_HEART,false);
                                    d(global_plycol,pl0^.name2+ulred+' is grateful.');

                                    {better pl0:s attitude towards player}
                                    Update_Relation(Relation_Better,1,pl0^,player,false,false);

                                    {news-paper}
                                    newsy(true,
                                    'Romantic Gift',
                                    ' '+uplc+pl0^.name2+config.textcol1+' received a box with '+uyellow+'Chocolate'
                                       +config.textcol1,
                                    ' from '+uplc+player.name2+config.textcol1+'.',
                                    ' '+uplc+pl0^.name2+config.textcol1+' ate the whole box.',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '');

                                   end;
                                 1:begin {ungrateful}
                                    show_usurper_data(picture_DEATH_HEAD,false);
                                    d(global_plycol,pl0^.name2+ulred+' is not satisfied!');

                                    {worsen pl0:s attitude towards player}
                                    Update_Relation(Relation_Worsen,1,pl0^,player,false,false);

                                    {news-paper}
                                    newsy(true,
                                    'Gift turned down',
                                    ' '+uplc+pl0^.name2+config.textcol1+' received a box with '+uyellow+'Chocolate'
                                       +config.textcol1,
                                    ' from '+uplc+player.name2+config.textcol1+'.',
                                    ' '+uplc+pl0^.name2+config.textcol1+' thrashed the gift!',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '',
                                    '');

                                   end;
                                end; {case .end.}

                                {update player soul}
                                d(15,'Your soul lightens!');
                                dec(player.chivnr);
                                Give_Chivalry(player,random(5)+2);

                               end
                               else begin
                                {npc didn't open the box!}
                                d(12,'Nope! '+uplc+pl0^.name2+ulred+' ignored the package!');
                                d(12,'('+sex2[pl0^.sex]+' probably suspects that your intentions are dubious!)');
                                pause;
                               end;

                               {remove shadow player pl0}
                               add_shadow(SRemove,pl0^,'','',0);

                               crlf;

                              end;
                             end;
                         'H':begin {human player}
                              d(15,'We will see if '+uplc+pl0^.name2+uwhite+' opens this package...');
                              sd(15,'Posting '+uyellow+'chocolate'+uwhite+'...');

                              {mail "chocolate" request}
                              post(MailSend,
                              pl0^.name2,
                              pl0^.ai,
                              false,
                              mailrequest_Chocolate,
                              player.name2,
                              '', {first message line holds nothing right now}
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
                              '',
                              '',
                              '');

                              d(14,'Done!');
                              crlf;
                             end;
                        end; {case .end.}

                       end;
                      end;

                     end;
                 'S':begin {scorpions}

                      {set price}
                      price:=pl0^.level*75000;

                      {}
                      d(config.textcolor,'Sending '+umonc+'scorpions'+config.textcol1+' to '+uplc+pl0^.name2
                                         +config.textcol1+' will cost '+uyellow+commastr(price)+config.textcol1+'.');

                      if player.gold<price then begin
                       you_cant_afford_it;
                       pause;
                      end
                      else if player.darknr<1 then begin
                       no_dark_deeds;
                       pause;
                      end
                      else begin
                       {sending scorpions!}
                       crlf;
                       d(config.textcolor,'Naughty naughty!');
                       d(config.textcolor,'Delivering '+umonc+'scorpions'+config.textcol1+' is not a very nice thing to do.');
                       if confirm('Go ahead','Y')=false then begin
                        d(12,'Aborted.');
                       end
                       else begin

                        d(15,'You pay '+uyellow+commastr(price)+uwhite+' '+many_money(price)+'.');
                        {pay}
                        DecPlayerMoney(player,price);
                        Dec(player.darknr);

                        {if target is human then we mail the box, otherwise
                         npc opens it right away.}
                        case pl0^.ai of
                         'C':begin {npc player handles #box with scorpions#}
                              {first we must put pl0 online}
                              sd(13,'Teleporting '+uplc+pl0^.name2+ulmag+'...');

                              if add_shadow(SAdd,pl0^,player.name2,'receiving gift',0)=false then begin
                               {unable to add pl0}
                               crlf;
                               crlf;
                               d(global_plycol,pl0^.name2+config.textcol1+' is busy!');
                               pause;
                              end
                              else begin
                               crlf;
                               x:=random(3);
                               if x=0 then begin
                                {npc opens the box!}
                                 sd(global_plycol,pl0^.name2+config.textcol1+' puts '+sex3[pl0^.sex]+' hand in the box...and'
                                   +' out comes.');
                                make_delay_dots(config.textcolor,4,800);
                                d(12,'SCORPIONS!'+uwhite+'!!!');

                                {death head}
                                show_usurper_data(picture_DEATH_HEAD,false);
                                d(12,pl0^.name2+ulred+' is dead.');
                                d(12,'Good work Evil One!');

                                {update pl0}
                                pl0^.hps:=0;
                                user_save(pl0^);

                                {worsen pl0:s attitude to player}
                                Update_Relation(Relation_Worsen,1,pl0^,player,false,false);

                                {news-paper}
                                newsy(true,
                                'Scorpions',
                                ' '+uplc+pl0^.name2+config.textcol1+' put '+sex3[pl0^.sex]+' hand in a box with '+umonc
                                   +'scorpions'+config.textcol1+'!',
                                ' '+uplc+pl0^.name2+config.textcol1+' died instantly!',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '');
                               end
                               else begin
                                {npc didn't open the box!}
                                d(12,'Damn! '+uplc+pl0^.name2+ulred+' ignored the package!');
                                d(12,'('+sex2[pl0^.sex]+' probably suspects that you are up to no good!)');
                                pause;
                               end;

                               {remove shadow player pl0}
                               add_shadow(SRemove,pl0^,'','',0);

                               crlf;

                              end;
                             end;
                         'H':begin {human player}
                              d(15,'We will see if '+uplc+pl0^.name2+uwhite+' opens this package...');
                              sd(15,'Posting '+umonc+'scorpions'+uwhite+'...');

                              {mail "scorpions" request}
                              post(MailSend,
                              pl0^.name2,
                              pl0^.ai,
                              false,
                              mailrequest_Scorpions,
                              player.name2,
                              '', {first message line holds nothing right now}
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
                              '',
                              '',
                              '');

                              d(14,'Done!');
                              crlf;
                             end;
                        end; {case .end.}

                       end;
                      end;

                     end;
                end; {case .end.}

               end;

              end; {SURPRISE-BOX **END**}
          'P':begin {poison}

               crlf;
               if player.darknr<1 then begin
                {no dark deeds left}
                no_dark_deeds;
                pause;
               end
               else begin

                {get receiver}
                d(config.textcolor,'Who do you wanna poison?');
                found:=select_character(pl0^,false);

                if found then begin

                 {decrease player dark deeds}
                 dec(player.darknr);

                 {cost to poison other player}
                 poison_cost:=pl0^.level*45000;

                 crlf;
                 if confirm('Send some '+ulred+'Poison'+config.textcol1+' to '+uplc+pl0^.name2
                                   +config.textcol1,'Y')=true then begin

                  if player.gold<poison_cost then begin
                   {can't afford it}
                   d(config.textcolor,'The poison for '+uplc+pl0^.name2+config.textcol1+' costs '+uyellow
                                      +commastr(poison_cost)+config.textcol1+'!');
                   d(12,'You can''t afford it!');
                  end
                  else if confirm('Pay '+uyellow+commastr(poison_cost)+config.textcol1+' for the Poison','Y')=true then begin


                   {attack teammate?}
                   go_ahead:=true;
                   if (player.team<>'') and (player.team=pl0^.team) then begin
                    d(12,'You and '+uplc+pl0^.name2+ulred+' are in the same team!');
                    if confirm('go ahead anyway','Y')=false then begin
                     go_ahead:=false;
                    end;
                   end;

                   {are they married?}
                   if go_ahead then begin
                    s:=is_player_married(player.name2,player.id);
                    if s=pl0^.name2 then begin

                     if confirm('poison your '+sex5[pl0^.sex],'N')=false then begin
                      go_ahead:=false;
                     end;

                    end;
                   end;


                   if (pl0^.ai='C') and (go_ahead=true) then begin

                    {send poison to np'C' player}
                    if add_shadow(SAdd,pl0^,player.name2,'talking to '+uplc+player.name2+config.textcol1,0)=false then begin
                     {we were (for some reason) unable to add pl0 to the online file}
                     crlf;
                     d(12,'Sorry, but '+uplc+pl0^.name2+ulred+' is busy right now!');
                     pause;
                    end
                    else begin

                     {npc pl0^ is online with us!}
                     crlf;
                     d(global_plycol,pl0^.name2+config.textcol1+' has arrived!');

                     {will pl0 drink it?}
                     x:=random(2);

                     if x=0 then begin
                      {npc drinks it!}

                      {will pl0 detect the poison?}
                      x:=random(2);

                      if x=0 then begin
                       {pl0 detected the poison}
                       crlf;
                       d(12,'Damn!');
                       d(global_plycol,pl0^.name2+config.textcol1+' sniffs at the drink and spots');
                       d(config.textcolor,'the arsenic!');
                       d(15,'You are going to get your butt kicked!');
                       pause;
                      end
                      else begin

                       {pl0 didn't detect the poison! glugg..glugg!}
                       d(global_plycol,pl0^.name2+config.textcol1+' takes the cup and...');
                       crlf;
                       sd(config.textcolor,'Glugg...');
                       delay2(800);
                       sd(config.textcolor,'Glugg...');
                       delay2(800);
                       sd(config.textcolor,'Glugg...');
                       delay2(800);
                       d(12,'Glugg...!');
                       crlf;

                       d(global_plycol,pl0^.name2+config.textcol1+' stares at you!');
                       d(12,'I''VE BEEN POISONED!');
                       d(12,'Arghhhh!............');
                       d(global_plycol,pl0^.name2+config.textcol1+' drops dead!');
                       crlf;

                       {set pl0 flags}
                       {pl0^.allowed:=false;}
                       Reduce_Player_Resurrections(pl0^,false);
                       pl0^.hps:=0;

                       {save pl0}
                       user_save(pl0^);

                       {news-paper}
                       Newsy(true,
                       'Poisoned!',
                       ' '+uplc+pl0^.name2+config.textcol1+' was poisoned by '+uplc+player.name2+config.textcol1+', the evil '
                          +race_display(2,player.race,0),
                       ' The drink '+uplc+pl0^.name2+config.textcol1+' had was laced with '+ulred+'arsenic'
                                    +config.textcol1+'.',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '',
                       '');

                       {how much xp should player receive}
                       x:=pl0^.level*55;
                       IncPlayerExp(player,x);

                       {evil deed text}
                       sd(config.textcolor,'You earned ');
                       sd(15,commastr(x));
                       sd(config.textcolor,' experience points!');
                       d(config.textcolor,' for this evil deed!');


                       {increase dark points}
                       x:=pl0^.level*9;
                       Pre_Darkness;
                       Give_Darkness(player,x);

                       {pause}
                       crlf;
                       pause;

                      end;

                      {worsen pl0:s attitude to player}
                      Update_Relation(Relation_Worsen,2,pl0^,player,false,false);

                     end
                     else begin
                      {npc refuses to drink!}
                      crlf;
                      d(global_plycol,pl0^.name2+config.textcol1+' takes the drink and throws it at you!');
                      d(config.textcolor,'It seems you aren''t so popular with '+uplc+pl0^.name2+config.textcol1+'!');
                      pause;
                     end;

                     {pay}
                     DecPlayerMoney(player,poison_cost);

                     {decrease dark deeds}
                     dec(player.Darknr);

                     {remove pl0^ from online list}
                     add_shadow(SRemove,pl0^,'','',0);

                    end;

                   end
                   else if (pl0^.ai='H') and (go_ahead=true) then begin

                    {HUMAN PLAYER AND POISON}
                    {pay}
                    DecPlayerMoney(player,poison_cost);

                    {decrease dark deeds}
                    dec(player.Darknr);

                    {does player wants to be anonymous?}
                    if confirm('Anonymous','N')=true then begin
                     anonymous:=true;
                    end
                    else begin
                     anonymous:=false;
                    end;

                    if anonymous then s:='A'
                                 else s:='P';


                    {send to 'H'uman player}
                    crlf;
                    sd(15,'Mailing Poison...(it will appear as a drink to '+uplc+pl0^.name2+uwhite+')');

                    {if is_online(pl0^.name2,false)=true then begin
                     online_send_to_player(pl0^.name2,false,uplc+player.name2+config.textcol1+' has sent you flower!');
                    end;}

                    {mailing "poison"}
                    post(MailSend,
                    pl0^.name2,
                    pl0^.ai,
                    false,
                    mailrequest_Poison,
                    player.name2,
                    s, {first message line holds 'A'nonymous or 'P'ublic}
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
                    '',
                    '',
                    '');

                    crlf;
                    crlf;
                    d(14,'DONE!');
                    crlf;

                    {increase dark points}
                    x:=pl0^.level*9;
                    Pre_Darkness;
                    Give_Darkness(player,x);
                    crlf;
                   end;

                  end;
                 end;
                end;

               end;

              end; {poison *end*}

          'B':begin {bouquet of roses}
               crlf;

               if player.gold<roses_cost then begin
                d(12,'Come back when you have '+uyellow+commastr(roses_cost)+ulred+' '+many_money(roses_cost)+'!');
                crlf;
               end
               else begin

                if confirm('Pay '+uyellow+commastr(roses_cost)+config.textcol1+' for a bouquet of Roses','Y')=true then begin

                 {get receiver}
                 d(config.textcolor,'Who''s the sweet-heart?');
                 found:=select_character(pl0^,false);

                 if found then begin

                  {is player married}
                  s:=is_player_married(player.name2,player.id);

                  {load relation}
                  Social_Relation(player,pl0^,relation^);

                  {correct relation}
                  correct_relation(player.name2,relation^);

                  if s=pl0^.name2 then begin
                   {no need to court this person if you are already married to him/her}
                   d(12,'You are already married! No need to court '+sex[pl0^.sex]+'!');
                  end
                  else if player.IntimacyActs<1 then begin
                   {any intimate acts left?}
                   no_intimate_acts;
                   pause;
                  end
                  else if confirm('Send '+ulcyan+'Bouquet'+config.textcol1+' to '+uplc+pl0^.name2
                                  +config.textcol1,'Y')=true then begin
                   {pay}
                   DecPlayerMoney(player,roses_cost);

                   {decrease intimate acts}
                   dec(player.IntimacyActs);

                   if pl0^.ai='C' then begin
                    {send to np'C' player}
                    if pl0^.sex=player.sex then begin

                     {reject}
                     crlf;
                     d(global_plycol,pl0^.name2+config.textcol1+' says that you can stuff the flowers!');
                     pause;

                     {worsen pl0:s attitude to player}
                     Update_Relation(Relation_Worsen,1,pl0^,player,false,false);

                     {news-paper}
                     newsy(true,
                     'Turned Down',
                     ' '+uplc+player.name2+config.textcol1+' sent flowers to '+uplc+pl0^.name2+config.textcol1
                      +'!',
                     ' '+uplc+pl0^.name2+ulred+' rejected'+config.textcol1+' the gift!',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');


                    end
                    else begin

                     if random(3)=0 then begin
                      {accept}
                      crlf;
                      d(global_plycol,pl0^.name2+config.textcol1+' accepts your flowers with a smile!');
                      d(15,'(I think it had effect!)');

                      {news-paper}
                      newsy(true,
                      'Romance?',
                      ' '+uplc+player.name2+config.textcol1+' sent flowers to '+uplc+pl0^.name2+config.textcol1
                       +'!',
                      ' '+uplc+pl0^.name2+uwhite+' accepted'+config.textcol1+' the flowers!',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');

                      {better pl0:s attitude to player}
                      Update_Relation(Relation_Better,1,pl0^,player,false,false);

                      pause;

                     end
                     else begin
                      {reject}
                      crlf;
                      d(global_plycol,pl0^.name2+config.textcol1+' says that you can stuff the flowers!');

                      {news-paper}
                      newsy(true,
                      'Turned Down',
                      ' '+uplc+player.name2+config.textcol1+' sent flowers to '+uplc+pl0^.name2+config.textcol1
                       +'!',
                      ' '+uplc+pl0^.name2+ulred+' rejected'+config.textcol1+' the gift!',
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

                   end
                   else begin

                    {send to 'H'uman player}

                    crlf;
                    sd(15,'Mailing flowers...');

                    if is_online(pl0^.name2,online_player)=true then begin
                     online_send_to_player(pl0^.name2,online_player,uplc+player.name2+config.textcol1+' has sent you flower!');
                    end;

                    {mailing a "bouquet of roses"}
                    post(MailSend,
                    pl0^.name2,
                    pl0^.ai,
                    false,
                    mailrequest_Roses,
                    player.name2,
                    '', {first message line holds nothing right now}
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
                    '',
                    '',
                    '');

                    d(14,'DONE!');
                    crlf;

                   end;

                  end;

                 end;

                end;

               end;

              end;
          'R':begin {return}
               done:=true;
              end;
         end; {case .end.}

        until done;

       end; {GIFT_SHOP *end*}

   'V':begin {visit [lydia] the gossip-monger}
        the_witch;
       end;
   'D':begin {divorce}
        divorce;
       end;
   'M':begin {married couples, also displayed at love history room}
        clearscreen;
        list_married_couples;
       end;
   'A':begin {approach somebody}


        crlf;
        repeat
         crlf;

         d(5,'What are you interested in');
          menu('(F)emales');
         menu('(M)ales');
         menu('(B)oth');
         menu('(R)eturn');
         sd(config.textcolor,':');
         mysex:=upcase(getchar);

         case mysex of
          'F': d(15,'Females');
          'M': d(15,'Males');
          'B',chr(13): d(15,'Both, of course');
          'R': d(15,'Return');
         end;

         crlf;
        until mysex in ['F','M','B','R',chr(13)];

        if mysex<>'R' then begin
        d(11,'*establish relation*');
        d(config.textcolor,'Meet with who?');
        sd(config.textcolor,':');
        s:=get_string(20);

        found:=false;
        abort:=false;

        for i:=1 to 2 do begin

         size:=1;
         case i of
          1: size:=fs(fsplayer);
          2: size:=fs(fsnpc);
         end;

         for j:=1 to size do begin

          {load player/npc}
          if load_character(pl0^,i,j)=true then begin

           if (findsub(s,pl0^.name2)) and
              (pl0^.name2<>player.name2) and
              (pl0^.deleted=false) and
              (pl0^.name2<>global_delname2) then begin

            go_ahead:=true;
            if (mysex='F') and (pl0^.sex<>2) then go_ahead:=false;
            if (mysex='M') and (pl0^.sex<>1) then go_ahead:=false;

            if go_ahead then begin
            if pl0^.sex=1 then begin
             s1:='(M)';
            end
            else begin
             s1:='(F)';
            end;

            if confirm(uplc+pl0^.name2+' '+uyellow+s1+config.textcol1,'N')=true then begin

             if is_online(pl0^.name2,online_player) then begin
              d(12,'Sorry, but '+uplc+pl0^.name2+ulred+' is not available right now.');
             end
             else if pl0^.location=offloc_prison then begin
              d(12,'Sorry, but '+uplc+pl0^.name2+ulred+' is in Prison right now.');
             end
             else begin
              found:=true;
              abort:=true;
             end;
            end
            else begin
             if confirm('Continue search','Y')=false then begin
              abort:=true;
             end;
            end;
            end;
           end;
          end;

          if abort then break;

         end; {for j:= .end.}

         if abort then break;

        end; {for i:= .end.}

        if (found=false) and (abort=false) then begin
         could_not_locate_character;
        end
        else if found then begin

         {add player pl0 to onliner list, so other nodes can't mess with him}

         {load current relation}
         social_relation(player,pl0^,relation^);

         if add_shadow(SAdd,pl0^,player.name2,'intimate with '+uplc+player.name2+config.textcol1,0)=false then begin
          {we were (for some reason) unable to add pl0 to the online file}
          crlf;
          d(12,'Sorry, but '+uplc+pl0^.name2+ulred+' is busy right now!');
          pause;
         end
         else if Relation^.Relation1=global_RelationMarried then begin

          {if they are already married}
          d(12,'You are married to '+uplc+pl0^.name2+ulred+'!');
          d(12,'Have you already forgotten that?');
          sd(12,'Go to your house and make your '+sex5[pl0^.sex]);

          d(12,' happy.');
          crlf;
          pause;
         end

         else begin

          {we have established pl0 online!}

          really_done:=false;
          repeat

           {set relation sign, heart or something more neutral}
           if relation^.relation1 in [global_RelationMarried..global_RelationFriendship] then begin
            relation_sign:=heartsign;
           end
           else begin
            relation_sign:='+';
           end;

           {top text}
           crlf;
           s:=mkstring(3,relation_sign)+player.name2+' and '+pl0^.name2+mkstring(3,relation_sign);
           d(4,mkstring(3,relation_sign)+uplc+player.name2+config.textcol1+' and '+uplc+pl0^.name2+ured
              +mkstring(3,relation_sign));
           d(5,mkstring(length(s),underscore));

           {lets be intimate}
           onliner.doing   :='intimate with '+uplc+pl0^.name2+config.textcol1;
           add_onliner(OUpdateLocation,onliner);

           {display relation}
           social_relation(player,pl0^,relation^);

           {display computer characteristics}
           good_looks(pl0^);

           {correct relation}
           correct_relation(player.name2,relation^);

           {display relations between the characters}
           d(config.textcolor,relation_string(true,relation^.name1,relation^.name2,relation^.relation1));
           d(config.textcolor,relation_string(true,relation^.name2,relation^.name1,relation^.relation2));

           {menu}
           crlf;
           menu('(C)hange attitude');
           menu('(I)ntimate');
           menu('(M)arry');
           menu('(R)eturn');
           crlf;
           sd(config.textcolor,'Choice :');

           {get user-input}
           ch:=upcase(getchar);

           {evaluate user-input}
           case ch of
            'R':begin {return}
                 d(10,'return');
                 really_done:=true;
                end;
            'I':begin {intimate}

                 crlf;
                 sd(15,'.....hang on....');
                 if (pl0^.sex=player.sex) and (Config.AllowHomoRelations=false) then begin
                  no_homo_relations;
                  pause;
                 end
                 else if player.IntimacyActs<1 then begin
                  {no acts of intimacy left}
                  no_intimate_acts;
                 end
                 else begin
                  crlf;
                  ch:='?';

                  repeat

                   {menu}
                   if ch='?' then begin
                    crlf;
                    d(5,'How would you like to spend your time with '+uplc+pl0^.name2+umag+'.');
                    d(5,'You have '+uyellow+commastr(player.IntimacyActs)+umag+' intimate sessions left.');
                    crlf;
                    menu2('(H)old hands  '); {finished!}
                    menu2('(D)inner  ');     {finished!}
                    menu2('(K)iss  ');       {finished!}

                    if Config.AllowAdultOptions then begin
                     menu2('(G)o to bed!  '); {not finished!}
                    end
                    else begin
                     {}
                    end;

                    menu2('(R)eturn  ');
                    crlf;
                    sd(config.textcolor,'Romantic move :');
                   end;

                   {get user-input}
                   ch:=upcase(getchar);

                   {evaluate user-input}
                   case ch of
                    'G':begin {go to bed}
                         crlf;
                         crlf;
                         if player.IntimacyActs<1 then begin
                          No_Intimate_Acts;
                          pause;
                         end
                         else if not Config.AllowAdultOptions then begin
                          crlf;
                          crlf;
                          d(12,'The Adult Options have been disabled by the Sysop.');
                          pause;
                         end
                         else begin

                          if relation^.relation1=global_RelationMarried then begin
                           {married coupled sleep at home}
                           d(12,'Married couples entertain themselves at home! (go home)');
                           pause;
                          end
                          else begin

                           {how should Computer player respond?}
                           {how should offline human player respond?..se below if pl0.ai='C'}

                           if pl0^.ai='C' then begin

                            if random(3)<>0 then begin
                             d(global_plycol,pl0^.name2+ulred+' refuses to be intimate with you!');
                             pause;
                            end
                            else if relation^.relation2 in [
                             global_RelationEnemy,
                             global_RelationAnger,
                             global_RelationHate] then begin

                             {npc hates player! no bed!}
                             d(global_plycol,pl0^.name2+ulred+' hates you!');
                             d(12,'You can forget about sex!');
                             pause;

                            end
                            else begin
                             {npc agrees to sleep with player, provided npc isn't married!}

                             s:=is_player_married(pl0^.name2,pl0^.id);
                             if s<>'' then begin

                              case pl0^.sex of
                               1: s:=' his wife!';
                               2: s:=' her husband!';
                              end; {case .end.}

                              d(global_plycol,pl0^.name2+config.textcol1+' is married to '+uplc+s+config.textcol1+'!');
                              d(global_plycol,pl0^.name2+config.textcol1+' is faithful to '+s);
                              pause;
                             end
                             else begin
                              {lets date!}

                              {should npc improve relations with player
                               after this date}
                              if random(2)=0 then begin
                               {improve pl0:s attitude to player}
                               Update_Relation(Relation_Better,1,pl0^,player,false,false);
                               load_relation(fload,relation^,relation^.recnr);
                              end;

                              {earn experience}
                              x:=player.level*244;
                              y:=pl0^.level*244;
                              x:=x+y;
                              x:=x div 2;
                              if x<100 then x:=100;

                              {sex act!}
                              d(config.textcolor,'You embrace '+uplc+pl0^.name2+config.textcol1+' passionately!');
                              {sexual act described}
                              sex_act_routine(player,pl0^,true);

                              d(14,'Great Event!');
                              d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');

                              {inc players exp}
                              IncPlayerExp(player,x);
                              IncPlayerExp(pl0^,x);

                              {inform jealous husband/wife to player and pl0}
                              Jealousy(2,player,pl0^);

                              {news-paper}
                              newsy(true,
                              'Romantic Event',
                              ' '+uplc+player.name2+config.textcol1+' slept with '+uplc+pl0^.name2+config.textcol1
                                 +'!',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                             end;

                            end;

                           end
                           else begin

                            d(15,'Do you really think that '+uplc+pl0^.name2+uwhite+' wants to be intimate with you?');
                            sd(15,'Inviting '+uplc+pl0^.name2+config.textcol1+'...');

                            {mail "have sex" request}
                            post(MailSend,
                            pl0^.name2,
                            pl0^.ai,
                            false,
                            mailrequest_HaveDiscreteSex,
                            player.name2,
                            '', {first message line holds nothing right now}
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
                            '',
                            '',
                            '');

                            d(14,'Done!');
                            crlf;

                           end;

                           {reduce # of intimate sessions left today}
                           dec(player.IntimacyActs);

                           {save updated relation record}
                           load_relation(fsave,relation^,relation^.recnr);

                          end;

                         end;


                        end;
                    'K':begin {kiss}
                         crlf;
                         crlf;
                         if player.IntimacyActs<1 then begin
                          No_Intimate_Acts;
                          pause;
                         end
                         else begin

                          if relation^.relation1=global_RelationMarried then begin
                           {married coupled don't kiss}
                           d(12,'Married couples entertain themselves at home! (go home)');
                           pause;
                          end
                          else begin

                           {how should offline player respond}
                           if pl0^.ai='C' then begin

                            if random(3)<>0 then begin
                             d(global_plycol,pl0^.name2+ulred+' refuses to be kissed by you!');
                             pause;
                            end
                            else if relation^.relation2 in [
                             global_RelationEnemy,
                             global_RelationAnger,
                             global_RelationHate] then begin

                             {npc hates player! no kiss!}
                             d(global_plycol,pl0^.name2+ulred+' doesn''t like you!');
                             d(12,'You can forget about kissing!');
                             pause;

                            end
                            else begin
                             {npc agrees to kiss player, provided npc isn't married!}

                             s:=is_player_married(pl0^.name2,pl0^.id);
                             if s<>'' then begin

                              case pl0^.sex of
                               1: s:=' his wife!';
                               2: s:=' her husband!';
                              end; {case .end.}

                              d(global_plycol,pl0^.name2+config.textcol1+' is married to '+uplc+s+config.textcol1+'!');
                              d(global_plycol,pl0^.name2+config.textcol1+' is faithful to '+s);
                              pause;
                             end
                             else begin
                              {lets date!}

                              {should npc improve relations with player
                               after this date}
                              if random(2)=0 then begin
                               {improve pl0:s attitude to player}
                               Update_Relation(Relation_Better,1,pl0^,player,false,false);
                               load_relation(fload,relation^,relation^.recnr);
                              end;

                              {earn experience}
                              x:=player.level*234;
                              y:=pl0^.level*234;
                              x:=x+y;
                              x:=x div 2;
                              if x<100 then x:=100;

                              {kissing!}
                              d(config.textcolor,'You kiss '+uplc+pl0^.name2+config.textcol1+' passionately!');
                              d(config.textcolor,'Great Lips!');
                              d(config.textcolor,'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!');

                              {inc players exp}
                              IncPlayerExp(player,x);
                              IncPlayerExp(pl0^,x);

                              {inform jealous husband/wife to player and pl0}
                              Jealousy(2,player,pl0^);

                              {news-paper}
                              newsy(true,
                              'Love',
                              ' '+uplc+player.name2+config.textcol1+' kissed '+uplc+pl0^.name2+config.textcol1
                                 +'!',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                             end;

                            end;

                           end
                           else begin

                            d(15,'Do you really think that '+uplc+pl0^.name2+uwhite+' wanna be kissed by you?');
                            sd(15,'Inviting '+uplc+pl0^.name2+config.textcol1+'...');

                            {mail "kiss" request}
                            post(MailSend,
                            pl0^.name2,
                            pl0^.ai,
                            false,
                            mailrequest_Kiss,
                            player.name2,
                            '', {first message line holds nothing right now}
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
                            '',
                            '',
                            '');

                            d(14,'Done!');
                            crlf;

                           end;

                           {reduce # of intimate sessions left today}
                           dec(player.IntimacyActs);

                           {save updated relation record}
                           load_relation(fsave,relation^,relation^.recnr);

                          end;

                         end;


                        end;
                    'D':begin {dinner}
                         crlf;
                         crlf;
                         if player.IntimacyActs<1 then begin
                          No_Intimate_Acts;
                          pause;
                         end
                         else begin

                          if relation^.relation1=global_RelationMarried then begin
                           {married coupled don't have dinner}
                           d(12,'You are married! Go home and eat instead!');
                           pause;
                          end
                          else begin

                           {how should offline player respond}
                           if pl0^.ai='C' then begin

                            if random(3)<>0 then begin
                             d(global_plycol,pl0^.name2+ulred+' refuses to eat with you!');
                             pause;
                            end
                            else if relation^.relation2 in [
                             global_RelationEnemy,
                             global_RelationAnger,
                             global_RelationHate] then begin

                             {npc hates player! no date!}
                             d(global_plycol,pl0^.name2+ulred+' doesn''t like you!');
                             d(12,'You can forget about dinner!');
                             pause;

                            end
                            else begin
                             {npc agrees to have dinner with player, provided npc isn't
                              married!}

                             s:=is_player_married(pl0^.name2,pl0^.id);
                             if s<>'' then begin

                              case pl0^.sex of
                               1: s:=' his wife!';
                               2: s:=' her husband!';
                              end; {case .end.}

                              d(global_plycol,pl0^.name2+config.textcol1+' is married to '+uplc+s+config.textcol1+'!');
                              d(global_plycol,pl0^.name2+config.textcol1+' is faithful to '+s);
                              pause;
                             end
                             else begin
                              {lets date!}

                              {should npc improve relations with player
                               after this date}
                              if random(2)=0 then begin
                               {improve pl0:s attitude to player}
                               Update_Relation(Relation_Better,1,pl0^,player,false,false);
                               load_relation(fload,relation^,relation^.recnr);
                              end;

                              {earn experience}
                              x:=player.level*155;
                              y:=pl0^.level*155;
                              x:=x+y;
                              x:=x div 2;
                              if x<100 then x:=100;

                              {having dinner}
                              d(config.textcolor,'You have dinner '+uplc+pl0^.name2+config.textcol1+' and enjoy yourself!');
                              d(config.textcolor,'Everything was great, except the check.');
                              d(config.textcolor,'You both earn '+uwhite+commastr(x)+config.textcol1+' experience points!');

                              {inc players exp}
                              IncPlayerExp(player,x);
                              IncPlayerExp(pl0^,x);

                              {inform jealous husband/wife to player and pl0}
                              Jealousy(2,player,pl0^);

                              {news-paper}
                              newsy(true,
                              'Dinner Date',
                              ' '+uplc+player.name2+config.textcol1+' and '+uplc+pl0^.name2+config.textcol1
                                 +' were seen having dinner this evening.',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                             end;

                            end;

                           end
                           else begin

                            d(15,'We will see if '+uplc+pl0^.name2+uwhite+' agrees to go out with you...');
                            sd(15,'Posting invitation...');

                            {mail "dinner" request}
                            post(MailSend,
                            pl0^.name2,
                            pl0^.ai,
                            false,
                            mailrequest_Dinner,
                            player.name2,
                            '', {first message line holds nothing right now}
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
                            '',
                            '',
                            '');

                            d(14,'Done!');
                            crlf;

                           end;

                           {reduce # of intimate sessions left today}
                           dec(player.IntimacyActs);

                           {save updated relation record}
                           load_relation(fsave,relation^,relation^.recnr);

                          end;

                         end;

                        end; {dinner *end*}
                    'H':begin {hold hands}
                         crlf;
                         crlf;
                         if player.IntimacyActs<1 then begin
                          No_Intimate_Acts;
                          pause;
                         end
                         else begin

                          if relation^.relation1=global_RelationMarried then begin
                           {married coupled don't hold hands}
                           d(12,'You are married! (not a couple of love-birds).');
                           pause;

                          end
                          else begin

                           {how should offline player respond}
                           if pl0^.ai='C' then begin

                            if random(3)<>0 then begin
                             d(global_plycol,pl0^.name2+ulred+' refuses to meet you!');
                             pause;
                            end
                            else if relation^.relation2 in [
                             global_RelationEnemy,
                             global_RelationAnger,
                             global_RelationHate] then begin

                             {npc hates player! no date!}
                             d(global_plycol,pl0^.name2+ulred+' doesn''t like you very much!');
                             d(12,'You can forget about a date!');
                             pause;

                            end
                            else begin
                             {npc agrees to date player, provided npc isn't
                              married!}

                             s:=is_player_married(pl0^.name2,pl0^.id);
                             if s<>'' then begin

                              case pl0^.sex of
                               1: s:=' his wife!';
                               2: s:=' her husband!';
                              end; {case .end.}

                              d(global_plycol,pl0^.name2+config.textcol1+' is married to '+uplc+s+config.textcol1+'!');
                              d(global_plycol,pl0^.name2+config.textcol1+' is faithful to '+s);
                              pause;
                             end
                             else begin
                              {lets date!}

                              {should npc improve relations with player
                               after this date}
                              if random(2)=0 then begin
                               {improve pl0:s attitude to player}
                               Update_Relation(Relation_Better,1,pl0^,player,false,false);
                               load_relation(fload,relation^,relation^.recnr);
                              end;

                              {earn experience}
                              x:=player.level*155;
                              y:=pl0^.level*155;
                              x:=x+y;
                              x:=x div 2;
                              if x<100 then x:=100;

                              {walk together, hand in hand}
                              d(config.textcolor,'You go out with '+uplc+pl0^.name2+config.textcol1+' and have a great time!');
                              d(config.textcolor,'You both earn '+uwhite+commastr(x)+config.textcol1+' experience points!');

                              {inc players exp}
                              IncPlayerExp(player,x);
                              IncPlayerExp(pl0^,x);

                              {inform jealous husband/wife to player and pl0}
                              Jealousy(2,player,pl0^);

                              {news-paper}
                              newsy(true,
                              'Dating',
                              ' '+uplc+player.name2+config.textcol1+' and '+uplc+pl0^.name2+config.textcol1
                                 +' were seen together today.',
                              ' They two of them were necking on a park bench.',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                             end;

                            end;

                           end
                           else begin

                            d(15,'We will see if '+uplc+pl0^.name2+uwhite+' agrees to go out with you...');
                            sd(15,'Posting invitation...');

                            {mail "holding hands" request}
                            post(MailSend,
                            pl0^.name2,
                            pl0^.ai,
                            false,
                            mailrequest_HoldHands,
                            player.name2,
                            '', {first message line holds nothing right now}
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
                            '',
                            '',
                            '');

                            d(14,'Done!');
                            crlf;

                           end;

                           {reduce # of intimate sessions left today}
                           dec(player.IntimacyActs);

                           {save updated relation record}
                           load_relation(fsave,relation^,relation^.recnr);

                          end;

                         end;

                        end; {hold hands *end*}

                   end; {case .end.}

                   if ch<>'R' then begin
                    ch:='?';
                   end;

                  until (ch='R') or (player.IntimacyActs<1);
                 end;

                 crlf;
                end; {intimate *end*}

            'M':begin {marry}
                 crlf;
                 sd(15,'.....hang on....');
                 marry_routine;
                end;

            'C':begin {change feelings/attitude}
                 change_feelings_menu;
                end;

           end; {case .end.}

          until really_done;

          {remove offline player PL0}
          add_shadow(SRemove,pl0^,'','',0);

         end;
        end; {if found .end.}
       end;
       end; {approach somebody .end.}

  end; {case .end.}

 until location_done;

 {exit text}
 crlf;
 crlf;
 sd(config.textcolor,'You leave '+config.textcol2+local_place+config.textcol1+'.');
 crlf;

 {dispose pointer vars}
 dispose(pl0);
 dispose(king);
 dispose(relation);

end; {Love_Corner *end*}

end. {Unit Lovers .end.}

       {Suggestions}

       {flatter}
       {kiss}
       {bouquet}
       {dinner}

       {buy me a drink stranger, ok, she fooled ya out of a free drink}

       {go kiss my mamas behind!}

       {beauty contest, paid for by user, bribe judges}
       {what kind of babies are produced when a troll and a human make out?}
       {crowd pleaser : let other players react to couple relations!}

       {Royal Orphanage, all *bastards* are gathered here}
       {the king has to pay for the bastard, or set them out to the wolves}

