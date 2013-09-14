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
Unit Home; {Usurper - Home, doesn''t require marriage}

Interface

Procedure Home_Sweet_Home;

Implementation

Uses Init, Cms, Jakob,
     News, Various, Various2,
     Various3, Relation, Statusc,
     ByeByeC, Mail, Invent,
     Online, Children, GenNews,
     File_Io;

const local_place = 'Home';
var
    refresh : boolean;

    spouse_name : s30;

    spouse : ^UserRec;
    relationtemp : ^RelationRec;

Procedure Disposal; {remove pointer variables}
begin
 dispose(spouse);
 dispose(relationtemp);
end; {disposal *end*}


Procedure Nursery; {the nursery}
const max_kidparty = 10; {how many kids can be on a kid-party simultaneously}
      max_mail_strings = 12; {how many mail info lines there is}
var
    i,
    j,
    whiners,
    left_overs : word;

    ReturnFileId : byte;

    x : longint;

    tries,
    current_kids : byte; {counter}

    ch : char;

    ok,
    done,
    found,
    child_mean,
    nursery_done,
    play_finished,
    other_kids_found : boolean;

    {kid fight variables}
    s : s90;

    round,
    action : byte;
    expreward : longint;

    attacker,
    defender : s30;

    attacker_sex,
    defender_sex : byte;

    kid_turn1,
    kid_turn2 : boolean;

    kid_power1,
    kid_power2 : integer;

    {records}
    child,
    OtherChild : childrec;

    Child_Array          : array[1..max_kidparty] of ^ChildRec;
    Child_Strength_Array : array[1..max_kidparty] of integer;
    Child_Fate_Array     : array[1..max_kidparty] of ^s100;
    Child_Wins_Array     : array[1..max_kidparty] of ^s30;
    Child_Nemesis_Array  : array[1..max_kidparty] of ^s30;

    mail_string : array[1..max_mail_strings] of ^s100;
    xp_string: s90;

procedure init_mailstrings;
var qq : word;
begin
 for qq:=1 to max_mail_strings do begin
  mail_string[qq]^:='';
 end;
end; {init_mailstrings}

begin

 {init pointer vars}
 for i:=1 to max_mail_strings do begin
  new(mail_string[i]);
 end;

 for i:=1 to max_kidparty do begin
  new(child_array[i]);
  new(child_fate_array[i]);
  new(child_nemesis_array[i]);
  new(child_wins_array[i]);
  child_array[i]^.name:='';
  child_fate_array[i]^:='';
  child_nemesis_array[i]^:='';
  child_wins_array[i]^:='';
 end; {for i:= .end.}

 nursery_done:=false;
 ch:='?';
 repeat

  {update online location, only if necessary}
  if onliner.location<>onloc_nursery then begin
   refresh:=true;
   onliner.location:=onloc_nursery;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  if ch='?' then begin
   {nursery menu}
   clearscreen;
   crlf;
   d(5,'Nursery'+config.textcol1+', activate your kids!');
   crlf;
   menu('(C)hildren');
   menu('(P)lay with other children (nice)');
   menu('(B)eat up a kid (bad)');
   menu('(T)ransfer your child to the '+ulcyan+'Royal Care-House'+config.textcol1+'.');
   menu('(S)tatus');
   menu('(R)eturn');
   crlf;
  end;
  sd(config.textcolor,'Nursery ('+config.textcol2+'?'+config.textcol1+' for menu):');

  {get user-input}
  ch:=upcase(getchar);
  crlf;

  {evaluate User-input}
  case ch of
   'S':begin {status}
        status(player);
       end;
   'R':begin {return}
        nursery_done:=true;
       end;
   'C':begin {list of players children}
        crlf;
        display_own_children(player,false,true,false);
       end;
   'P':begin {play with other children}
        crlf;
        crlf;
        if player.chivnr<1 then begin
         d(12,'You too tired.');
         pause;
        end
        else begin
         d(15,'Party!');
         {add own children online}
         other_kids_found:=false;
         current_kids:=0;
         for i:=1 to fs(fschildren) do begin
          load_child(fload,child,i);
          if (my_child(player,child)=true) and
             (child.name<>'') and
             (child.deleted=false) and
             (child.health=childHealth_normal) and
             (child.location=ChildLocation_Home) then begin

           if add_child(SAddChild,child,player.name2,'kid party',0)=true then begin
            d(global_kidcol,child.name+config.textcol1+' puts on a party-hat.');
            inc(current_kids);
            child_array[current_kids]^:=child;
           end;

          end;

          if current_kids>max_kidparty div 2 then break;

         end; {for i:= .end.}

         if current_kids=0 then begin
          d(12,'You have no kids available.');
         end
         else begin
          {invite other kids}
          repeat
           crlf;
           d(11,'Invite a bunch of kids to play with your children.');
           menu2('(P)ersonal invitations  ');
           menu2('(R)andom bunch of kids :');
           ch:=upcase(getchar);
          until ch in ['P','R'];

          case ch of
           'R':begin {random invitations}
                crlf;
                d(15,'Inviting children...');
                done:=false;
                tries:=0;
                repeat
                 i:=random(fs(fschildren))+1;
                 inc(tries);
                 load_child(fload,child,i);

                 ok:=true;
                 for j:=1 to max_kidparty do begin
                  if child_array[j]^.name=child.name then begin
                   ok:=false;
                   break;
                  end;
                 end; {for j:= .end.}

                 if (ok) and
                    (my_child(player,child)=false) and
                    (child.deleted=false) and
                    (child.name<>'') and
                    (child.health=childHealth_normal) and
                    (child.location=childlocation_home) then begin
                  if add_child(SAddChild,child,player.name2,'kid party',0)=true then begin
                   d(global_kidcol,child.name+config.textcol1+' the '+uwhite+commastr(child.age)+config.textcol1
                     +' year old '+child_soul(child)+' has arrived!');
                   inc(current_kids);
                   other_kids_found:=true;
                   child_array[current_kids]^:=child;
                  end;
                 end;

                 if (current_kids>=max_kidparty) or
                    (tries>150) then begin
                  done:=true;
                 end;

                until done;

               end; {random invitations *end*}
           'P':begin {personal invitations}
                crlf;
                done:=false;
                repeat
                 if select_a_child(player,child,anychild,excludeown,false)=true then begin
                  if (child.location=childlocation_home) and
                     (child.health=childHealth_normal) then begin
                   if add_child(SAddChild,child,player.name2,'kid party',0)=true then begin
                    d(9,'---');
                    d(global_kidcol,child.name+config.textcol1+' puts on a party-hat.');
                    other_kids_found:=true;
                    inc(current_kids);
                    child_array[current_kids]^:=child;
                   end;
                  end
                  else begin
                   d(12,child.name+' is not available.');
                  end;
                 end;
                 if current_kids>=max_kidparty then begin
                  done:=true;
                 end
                 else begin
                  if confirm('Invite some more','Y')=false then begin
                   done:=true;
                  end;
                 end;
                until done;
               end; {personal invitations *end*}

          end; {case .end.}

          {did we get other kids online? if not: abort}
          if other_kids_found=false then begin
           d(12,'Not enough kids active to have a party!');
           crlf;
           crlf;
          end
          else begin
           {child-play!}
           {init children strength}
           for i:=1 to max_kidparty do begin
            if child_array[i]^.name<>'' then begin
             child_strength_array[i]:=child_array[i]^.age*2;
            end
            else begin
             child_strength_array[i]:=0;
            end;
           end; {for i:= .end.}

           {it costs 1 good deed to arrange a children party}
           dec(player.chivnr);
       
           crlf;
           s:='The children play games';
           d(5,s);
           d(2,cool_string(length(s),'=','-',10,2));
           play_finished:=false;
           round:=0;
           repeat
            for i:=1 to max_kidparty do begin
             if child_array[i]^.name<>'' then begin
              found:=false;
              x:=0;
              for j:=1 to max_kidparty do begin
               if (child_array[j]^.name<>child_array[i]^.name) and
                  (child_array[j]^.name<>'') and
                  (child_strength_array[j]>0) and
                  (child_array[j]^.motherid<>child_array[i]^.motherid) and
                  (child_array[j]^.fatherid<>child_array[i]^.fatherid) then begin
                x:=j;
                found:=true;
                break;
               end;
              end; {for j:= .end.}

              if x>0 then begin
               j:=x;
               {is child going to be bad? this depends on his soul}
               if child_array[i]^.soul>0 then x:=random(3)
                                         else x:=random(2);
               if x=0 then child_mean:=true
                      else child_mean:=false;

               if child_mean then begin
                {child is mean}
                case random(4) of
                 0: d(global_kidcol,child_array[i]^.name+config.textcol1+' makes faces at '+ukidc+child_array[j]^.name
                                    +config.textcol1+'.');
                 1: d(global_kidcol,child_array[i]^.name+ulred+' kicks '+ukidc+child_array[j]^.name+config.textcol1+'!');
                 2: d(global_kidcol,child_array[i]^.name+config.textcol1+' pokes '+ukidc+child_array[j]^.name+config.textcol1
                                   +' in the eye!');
                 3: d(global_kidcol,child_array[i]^.name+ulred+' pours milk over '+ukidc+child_array[j]^.name+config.textcol1
                                    +'!');
                end; {case .end.}

                Worsen_Child_Soul(child_array[i]^,5);
                {weaken bullied child}
                child_strength_array[j]:=child_strength_array[j]-1;

                if child_strength_array[j]<1 then begin
                 case random(6) of
                  0: s:='nailed';
                  1: s:='messed up';
                  2: s:='bullied';
                  3: s:='bullied';
                  4: s:='terrorized';
                  5: s:='victimized';
                 end; {case .end.}
                 d(12,child_array[j]^.name+' bursts into tears (crawls back to mama).');
                 child_nemesis_array[j]^:=child_array[i]^.name;
                 child_wins_array[i]^:=child_array[j]^.name;
                 {child_fate_array[j]^:=ukidc+child_array[i]^.name+config.textcol1+' the '+uwhite+commastr(child_array[i]^.age)
                                       +config.textcol1+' year old '+child_soul(child_array[i]^)+' '+s+' your '
                                       +sex7[child_array[j]^.sex]+' '+ukidc+child_array[j]^.name+config.textcol1+'!';
                 }
                 child_fate_array[j]^:='Your '+sex7[child_array[j]^.sex]+' '+ukidc+child_array[j]^.name+config.textcol1
                                     +' was '+s+' by '+ukidc+child_array[i]^.name+config.textcol1+' the '+uwhite
                                     +commastr(child_array[i]^.age)+config.textcol1+' year old '+child_soul(child_array[i]^)
                                     +'.';

                end;

               end
               else if child_mean=false then begin
                {child is nice}
                if child_array[i]^.sex=child_array[j]^.sex then x:=4
                                                           else x:=5;

                case random(x) of
                 0: d(global_kidcol,child_array[i]^.name+config.textcol1+' plays with '+ukidc+child_array[j]^.name
                                    +config.textcol1+'.');
                 1: d(global_kidcol,child_array[i]^.name+config.textcol1+' hugs '+ukidc+child_array[j]^.name+config.textcol1
                                    +'.');
                 2: d(global_kidcol,child_array[i]^.name+config.textcol1+' gives '+ukidc+child_array[j]^.name+config.textcol1
                                    +' a toy.');
                 3: d(global_kidcol,child_array[i]^.name+config.textcol1+' plays with '+ukidc+child_array[j]^.name
                                   +config.textcol1+'.');
                 4: d(global_kidcol,child_array[i]^.name+config.textcol1+' gives '+ukidc+child_array[j]^.name
                                    +config.textcol1+' a kiss.');
                end; {case .end.}

                Better_Child_Soul(child_array[i]^,5);

               end;
              end
              else begin
               {no opponent found}
               play_finished:=true;
              end;

             end;
            end; {for i:= .end.}
            inc(round);

            if round>=50 then play_finished:=true;
            if play_finished=false then pause;

           until play_finished=true;
           crlf;
           crlf;
           s:='Party is over for the kids...';
           d(10,cool_string(length(s),'=','-',10,2));
           d(14,s);
           d(10,cool_string(length(s),'=','-',10,2));

           {did any of players kid make it?}
           left_overs:=0;
           whiners:=0;
           {setup/display mail strings containing childrens fate}
           x:=0;
           init_mailstrings;
           for i:=1 to max_kidparty do begin
            if (child_array[i]^.name<>'') and
               (my_child(player,child_array[i]^)=true) then begin
             if (child_strength_array[i]>0) then begin
              inc(left_overs);
              {create fate string for this child}
              child_fate_array[i]^:=ukidc+child_array[i]^.name+config.textcol1+' did well.';
             end
             else begin
              inc(whiners);
             end;

             d(7,child_fate_array[i]^);
             {transfer own childrens fate to mail strings, used in
              mail to spouse}
             if x<max_mail_strings then begin
              inc(x);
              mail_string[x]^:=child_fate_array[i]^;
             end;
            end;
           end; {for i:= .end.}

           {player kids didn't make it}
           if left_overs=0 then begin
            d(12,'Your kids are whiners! They didn''t make it all the way!');
            d(12,'You get no bonus for this miserable result!');
            crlf;
           end
           else begin
            {how many kids "survived"}
            x:=left_overs*500;
            if whiners=0 then begin
             d(14,'Great work! Your kids did well all they way!');
            end
            else begin
             d(14,'Nice! Some of your kids whimpered, but on the whole you can be proud.');
            end;
            d(15,'You deserve a BONUS. Your family gets '+commastr(x)+' experience points for this feat.');
            x:=x div 2;
            d(config.textcolor,'Your share is '+uwhite+commastr(x)+config.textcol1+' points.');
            crlf;

            {update spouse with new XP}
            if is_online(spouse^.name2,online_player)=true then begin
             online_send_to_player(spouse^.name2,online_player,Broadcast_ChildPartyExp+long2str(x));
            end
            else begin

             j:=Look_for_ID(spouse^.id,spouse^.ai,ReturnFileId);

             load_character(spouse^,ReturnFileId,j);
             IncPlayerExp(spouse^,x);
             user_save(spouse^);

            end;

            {inform spouse of his/her share of the xp earned}
            s:='Your Children';
            post(MailSend,
            spouse^.name2,
            spouse^.ai,
            false,
            mailrequest_nothing,
            '',
            uyellow+s+config.textcol1,
            cool_string(length(s),'=','-',2,10),
            'From your childrens participation in a party held by your '+sex5[player.sex]+' '+uplc+player.name2
                +config.textcol1,
            'You earn '+uwhite+commastr(x)+config.textcol1+' experience points!',
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

           {mail spouse}
           s:='Your children';
           post(MailSend,
           spouse^.name2,
           spouse^.ai,
           false,
           mailrequest_nothing,
           '',
           ulmag+s+config.textcol1,
           cool_string(length(s),'=','-',2,10),
           'Your '+sex5[player.sex]+' '+uplc+player.name2+config.textcol1+' the '+classnames[player.class]
                  +' arranged a party for some children.',
           mail_string[1]^,
           mail_string[2]^,
           mail_string[3]^,
           mail_string[4]^,
           mail_string[5]^,
           mail_string[6]^,
           mail_string[7]^,
           mail_string[8]^,
           mail_string[9]^,
           mail_string[10]^,
           mail_string[11]^,
           mail_string[12]^);

           {report to other kids parents}
           for i:=1 to max_kidparty do begin
            if (child_array[i]^.name<>'') and
               (my_child(player,child_array[i]^)=false) then begin
             if (child_strength_array[i]>0) then begin
              {create fate string for this child}
              child_fate_array[i]^:=ukidc+child_array[i]^.name+config.textcol1+' managed to stay on '+sex3[child_array[i]^.sex]
                                    +' feet all the time.';
              {give parent xp for his/her childs behaviour}
              x:=child_array[i]^.age*100;
              xp_string:='You get a family bonus of '+uwhite+commastr(x)+config.textcol1+' experience points!';

              {update both parents xp}
              inform_parents(child_array[i]^,
              mailrequest_SilentExp,
              long2str(x),
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

             end
             else begin
              {child failed to stand the party}
              xp_string:='';
             end;

             s:='Your '+sex7[child_array[i]^.sex];
             inform_parents(child_array[i]^,
             mailrequest_nothing,
             umailheadc+s+config.textcol1,
             cool_string(length(s),'=','-',2,10),
             'Your '+sex7[child_array[i]^.sex]+ukidc+' '+child_array[i]^.name+config.textcol1+' was invited to a Childrens'
                  +' Party held',
             'by '+uplc+player.name2+config.textcol1+' the '+classnames[player.class]+'.',
             child_fate_array[i]^,
             xp_string,
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
           end; {for i:= .end.}

           {news-paper}

           {creating mail strings from childrens fate, to go in the news-paper}
           init_mailstrings;

           x:=0;
           for i:=1 to max_kidparty do begin
            if (child_array[i]^.name<>'') and (x<8) then begin
             inc(x);
             if child_strength_array[i]>0 then begin
              mail_string[x]^:=' '+ukidc+child_array[i]^.name+config.textcol1+' enjoyed the activities';
              if child_wins_array[i]^<>'' then begin
               mail_string[x]^:=mail_string[x]^+' (especially victimizing '+ukidc+child_wins_array[i]^+config.textcol1+').';
              end
              else begin
               mail_string[x]^:=mail_string[x]^+'.';
              end;
             end
             else begin
              mail_string[x]^:=' '+ukidc+child_array[i]^.name+config.textcol1+' was bullied by '+ukidc+child_nemesis_array[i]^
                                +config.textcol1+'!';
             end;
            end;
           end; {for i:= .end.}

           {news-paper}
           newsy(true,
           'Childrens Party',
           ' '+uplc+player.name2+config.textcol1+' arranged a party for some of the Children.',
           mail_string[1]^,
           mail_string[2]^,
           mail_string[3]^,
           mail_string[4]^,
           mail_string[5]^,
           mail_string[6]^,
           mail_string[7]^,
           mail_string[8]^);

          end;

          {remove online children}
          for i:=1 to max_kidparty do begin
           if child_array[i]^.name<>'' then begin
            add_child(SRemoveChild,child_array[i]^,'','',0);
           end;
          end; {for i:= .end.}

         end;
        end;
       end; {play with other children *end*}

   'T':begin {transfer a child to the Royal Orphanage}

        crlf;
        crlf;
        d(15,'*Get rid of those annoying kids*');

        if select_a_child(player,child,ownchild,excludenone,false) then begin

         {add child to online list}
         if add_child(SAddChild,child,player.name2,'listening to parents',0)=false then begin
          d(12,child.name+' is busy. try again soon!');
         end
         else begin
          if child.location<>ChildLocation_Home then begin
           case child.location of
            ChildLocation_Orphanage:
                  d(12,child.name+' is locked up in the Royal Orphanage!');
             else d(12,child.name+' is not home!');
           end; {case .end.}
          end
          else if child.health<>childhealth_normal then begin
           d(12,child.name+' can''t get up from '+sex3[child.sex]+' bed!');
          end
          else begin

           {transfer child to Royal Orphanage}
           crlf;
           d(config.textcolor,'Are you really sure about this!? You may never see '+ukidc+child.name+config.textcol1
               +' again.');

           if confirm('Transfer '+ukidc+child.name+config.textcol1+' to the '+ulmag+'Royal Orphanage'
                      +config.textcol1,'N')=true then begin
            crlf;
            d(15,'Done.');
            d(2,ukidc+child.name+config.textcol1+' cries when '+sex2[child.sex]+' is dragged out by the royal servants.');
            d(2,ukidc+child.name+config.textcol1+' is promptly sent to the Royal Castle.');
            d(config.textcolor,'(you are a cruel '+sex8[player.sex]+'!)');
            crlf;

            {update child}
            child.location:=ChildLocation_Orphanage;
            load_child(fsave,child,child.recnr);


            {inform the king}
            inform_king(
            ulcyan+'Child Arrival'+config.textcol1,
            cool_string(13,'=','-',11,5),
            uplc+player.name2+config.textcol1+' sent '+sex3[player.sex]+' '+sex7[child.sex]+' '+ukidc+child.name
                +config.textcol1+' to the Royal Orphanage.',
            'You are now responsible for this brat.',
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

            {inform spouse}
            inform_parent(child,
            mailrequest_nothing,
            player,
            ulred+'Your child is gone!'+config.textcol1,
            mkstring(19,underscore),
            uplc+player.name2+config.textcol1+' sent your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1
               +' to the Royal Orphanage.',
            ukidc+child.name+config.textcol1+' wants to return home!',
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
            'Evil Parents',
            ' '+uplc+player.name2+config.textcol1+' sent '+sex3[player.sex]+' '+sex7[child.sex]+' '+ukidc+child.name
              +config.textcol1+' to the Royal Orphanage.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            {remove shadow kid}
            add_child(SRemoveChild,child,'','',0);


            {npc spouse should maybe file for divorce here?}
            {perhaps only if the spouse is father/mother to child}
            {NOTE that this divorce routine is more or less duplicated in
              Lovers.pas, when a Player executes a divorce}

            load_my_spouse(player,spouse^);

            if (spouse^.name2<>'') and (spouse^.ai='C') then begin

             if (child.orgmotherID=spouse^.id) or (child.orgFatherAI=spouse^.id) then begin


               {Ok, we have now confirmed that the NPC spouse is father/mother}

               {establish spouse online}
               if add_shadow(SAdd,spouse^,player.name2,'speaking with '+uplc+player.name2+config.textcol1,0)=false then begin
                {we were unable to add spouse to the online file}
                {this could be exploited..making the spouse go online..and then get rid of child}
               end

               else begin

                if add_couples_children_online(player,spouse^,'seeing parents')=false then begin

                 {we only divorce if we can establish all children online}

                 {remove couples children from being online}
                 remove_couples_children_online(player,spouse^);

                end
                else begin


                 {load relation}
                 Social_Relation(player,spouse^,relationtemp^);

                 {correct relation}
                 correct_relation(player.name2,relationtemp^);


                 {divorce or not! it is now decided by random chance}
                 {if random(2)=0 then begin}
                 x:=random(2);
                 if x=0 then begin

                  {divorce}
                  {jakob, add stuff here}
                  if relationtemp^.marrieddays<1 then begin
                   s:=' Their marriage lasted only a couple of hours!!';
                  end
                  else if relationtemp^.marrieddays<30 then begin
                   s:=' Their marriage lasted only '+uwhite+commastr(relationtemp^.marrieddays)+config.textcol1+' days.';
                  end
                  else begin
                   s:=' Their marriage lasted '+uwhite+commastr(relationtemp^.marrieddays)+config.textcol1+' days.';
                  end;

                  {update relation}
                  relationtemp^.relation1:=global_RelationNormal;
                  relationtemp^.relation2:=global_RelationHate;
                  relationtemp^.marrieddays:=0;

                  {set player married flags}
                  player.married:=false;
                  spouse^.married:=false;
                  user_save(player);
                  user_save(spouse^);

                  {save relation}
                  load_relation(fsave,relationtemp^,relationtemp^.recnr);

                  {news-paper}
                  Newsy(true,
                  'Divorce!',
                  ' '+uplc+spouse^.name2+config.textcol1+' divorced '+uplc+player.name2+config.textcol1+'!',
                  s,
                  ' '+spouse^.name2+config.textcol1+' accuses '+uplc+player.name2+config.textcol1+' of child mistreatment!',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                  {divorce-log, see duplicate code in relation.pas}
                  Generic_News(MarriageDivorceNews,
                  false,
                  ugreen+'['+fix_date(todays_date)+'] '+uplc+player.name2+ugreen+' and '+uplc+spouse^.name2+ugreen+' were '
                    +ulred+'Divorced'+ugreen+'!',
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
                       (my_child(spouse^,child)=true) then begin

                     {refuse player access to this child}
                     if player.sex=1 then child.fatheraccess:=false;
                     if player.sex=2 then child.motheraccess:=false;

                     d(12,'You have lost custody of your '+sex7[child.sex]+' '+ukidc+child.name+ulred+'!');

                     {set child health to depressed}
                     child.health:=ChildHealth_Depressed;

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
                  online_send_to_all(uplc+spouse^.name2+config.textcol1+' divorced '+uplc+player.name2+config.textcol1
                  +'!',player.name2,'');


                  {jakob}

                  {remove couples children}
                  remove_couples_children_online(player,spouse^);


                  {we kick the player out of the game..since we are lazy and don't
                   bother to kick him out of this routine (which would be the proper way)}
                  crlf;
                  d(12,'The divorce strikes You as unjust and unfortunate. Somehow, you can''t concentrate.');
                  d(12,'Your vision has dimmed...');
                  pause;
                  byebye;
                 end;
                end;

               end;
             end;
            end;

           end
           else begin
            {player decided NOT to send child to Royal Orphanage}
            crlf;
            d(15,'You are a forgiving '+sex8[player.sex]+'.');

            crlf;
           end;

           {remove shadow kid}
           add_child(SRemoveChild,child,'','',0);

          end;
         end;
        end;

       end;

   'B':begin {beat up a kid}

        {pick a kid}
        crlf;
        d(11,'*pick your kid*');
        if select_a_child(player,child,ownchild,excludenone,false) then begin

         {add child to online list}
         if add_child(SAddChild,child,player.name2,'listening to parents',0)=false then begin
          d(12,child.name+' is busy. try again soon!');
         end
         else begin
          if child.location<>ChildLocation_Home then begin
           case child.location of
            ChildLocation_Orphanage:
                  d(12,child.name+' is locked up in the Royal Orphanage!');
             else d(12,child.name+' is not home!');
           end; {case .end.}
          end
          else if child.health<>childhealth_normal then begin
           d(12,child.name+' can''t get up from '+sex3[child.sex]+' bed!');
          end
          else begin
           {beat up the other kid}
           crlf;
           d(config.textcolor,'alright, who''s the kid you wanna hurt?');

           if select_a_child(player,otherchild,anychild,excludeown,false) then begin
            if my_child(player,otherchild)=true then begin
             d(12,otherchild.name+' is your '+sex7[otherchild.sex]+' (idiot)');
            end
            else begin
             if confirm('Should '+ukidc+child.name+config.textcol1+' stomp '+ukidc+otherchild.name
                        +config.textcol1,'Y') then begin

              if add_child(SAddChild,otherchild,player.name2,'listening to parents',0)=false then begin
               d(12,child.name+' is busy. try again soon!');
              end
              else begin

               {chance of success depends on the age of the children}
               kid_power1:=child.age*2;
               kid_power2:=otherchild.age*2;
               kid_turn1:=true;
               kid_turn2:=false;

               crlf;
               d(2,ukidc+child.name+config.textcol1+' sneaks up behind '+ukidc+otherchild.name+config.textcol1+'!');
               repeat

                {whos turn is it?}
                if kid_turn1 then begin
                 attacker    :=child.name;
                 attacker_sex:=child.sex;
                 defender    :=otherchild.name;
                 defender_sex:=otherchild.sex;
                end
                else begin
                 attacker    :=otherchild.name;
                 attacker_sex:=otherchild.sex;
                 defender    :=child.name;
                 defender_sex:=otherchild.sex;
                end;

                {attack option}
                action:=random(8);
                case action of
                 0: s:=ukidc+attacker+config.textcol1+' slams '+sex3[attacker_sex]+' spoon in '+ukidc+defender+'s'
                            +config.textcol1+' head!';
                 1: s:=ukidc+attacker+config.textcol1+' pulls '+ukidc+defender+'s'+config.textcol1+' hair!';
                 2: s:=ukidc+attacker+config.textcol1+' wallops '+ukidc+defender+config.textcol1+'!';
                 3: s:=ukidc+attacker+config.textcol1+' puts a fork in '+ukidc+defender+'s'+config.textcol1+' back!';
                 4: s:=ukidc+attacker+config.textcol1+' kicks '+ukidc+defender+config.textcol1+'!';
                 5: s:=ukidc+attacker+config.textcol1+' box '+ukidc+defender+'s'+config.textcol1+' ear!';
                 6: s:=ukidc+attacker+config.textcol1+' bites '+ukidc+defender+'s'+config.textcol1+' ear!';
                 7: s:=ukidc+attacker+config.textcol1+' bites '+ukidc+defender+'s'+config.textcol1+' leg!';
                end; {case .end.}

                {attack result}
                sd(2,s);
                make_delay_dots(config.textcolor,4,400);
                if random(2)=0 then begin
                 d(12,'miss!');
                end
                else begin
                 d(15,'HIT!');
                 if kid_turn1 then dec(kid_power2)
                              else dec(kid_power1);
                end;

                {switch turns}
                if kid_turn1 then begin
                 kid_turn1:=false;
                 kid_turn2:=true;
                end
                else begin
                 kid_turn1:=true;
                 kid_turn2:=false;
                end;

               until (kid_power1<1) or (kid_power2<1);

               d(5,'Fight is over!');
               crlf;

               {calculate experience points reward, goes to parents}
               expreward:=otherchild.age-child.age;
               if expreward<1 then expreward:=1;
               expreward:=expreward*750;

               if kid_power2<1 then begin
                {player kid won!}
                d(15,'Your kid won! (but '+sex2[child.sex]+' is also becoming more evil)');
                {give players kid evil soul}
                worsen_child_soul(child,10);
                load_child(fsave,child,child.recnr);

                {experience points}
                d(config.textcolor,'You and your family gain '+uwhite+commastr(expreward)+config.textcol1
                                   +' experience points!');
                incplayerexp(player,expreward);

                {give expreward to player childs other parent}
                if (child.mother<>'') and (child.motherai<>player.ai) then begin
                 {mail xp to mother}
                 post(MailSend,
                 child.mother,
                 child.motherai,
                 false,
                 mailrequest_ChildFightExp,
                 '',
                 child.name,
                 otherchild.name,
                 long2str(child.sex),
                 long2str(expreward),
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
                else if (child.father<>'') and (child.fatherai<>player.ai) then begin
                 {mail xp to father}
                 post(MailSend,
                 child.father,
                 child.fatherai,
                 false,
                 mailrequest_ChildFightExp,
                 '',
                 child.name,
                 otherchild.name,
                 long2str(child.sex),
                 long2str(expreward),
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

                {news-paper}
                newsy(true,
                'Kid Fight',
                ' '+ukidc+child.name+config.textcol1+' beat '+ukidc+otherchild.name+config.textcol1+'!',
                ' '+ukidc+child.name+'s'+config.textcol1+' parents cheered when their '+sex7[child.sex]+' returned '
                   +'victorious!',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

                {inform player childs other parent}
                inform_parent(child,
                mailrequest_nothing,
                player,
                uyellow+'Your kid won'+config.textcol1,
                mkstring(12,underscore),
                uplc+player.name2+config.textcol1+' sent your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+' to',
                'beat the evil kid '+ukidc+otherchild.name+config.textcol1+'.',
                ukidc+child.name+config.textcol1+' won the fight!',
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

                {inform parents to attacked child}
                inform_parents(otherchild,
                mailrequest_nothing,
                ulred+'Your kid was hurt'+config.textcol1,
                mkstring(17,underscore),
                'Your '+sex7[otherchild.sex]+' '+ukidc+otherchild.name+config.textcol1+' was attacked by the vicious kid '
                   +ukidc+child.name+config.textcol1+'!',
                ukidc+otherchild.name+ulred+' lost'+config.textcol1+' the fight!',
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
                {player kid lost}
                d(12,'Your kid lost! '+sex2[child.sex]+' has dishonored the family!');
                d(2,ukidc+child.name+config.textcol1+' cries and wants to be comforted!');
                d(2,ukidc+otherchild.name+'s'+config.textcol1+' family is in a jubilant mood!');

                {news-paper}
                newsy(true,
                'Kid Fight',
                ' '+ukidc+child.name+ulred+' lost '+config.textcol1+'to '+ukidc+otherchild.name+config.textcol1+'!',
                ' '+ukidc+otherchild.name+'s'+config.textcol1+' parents cheered when their '+sex7[otherchild.sex]
                   +' returned victorious!',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

                {inform player childs other parent}
                inform_parent(child,
                mailrequest_nothing,
                player,
                ulred+'Your kid was hurt'+config.textcol1,
                mkstring(17,underscore),
                uplc+player.name2+config.textcol1+' sent your '+sex7[child.sex]+'; '+ukidc+child.name+config.textcol1+' to',
                'beat the evil kid '+ukidc+otherchild.name+config.textcol1+'.',
                ukidc+child.name+ulred+' lost'+config.textcol1+' the fight!',
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

                {give expreward to other childs parents}
                if otherchild.mother<>'' then begin
                 {mail xp to mother}
                 post(MailSend,
                 otherchild.mother,
                 otherchild.motherai,
                 false,
                 mailrequest_ChildFightExp,
                 '',
                 otherchild.name,
                 child.name,
                 long2str(otherchild.sex),
                 long2str(expreward),
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

                if otherchild.father<>'' then begin
                 {mail xp to father}
                 post(MailSend,
                 otherchild.father,
                 otherchild.fatherai,
                 false,
                 mailrequest_ChildFightExp,
                 '',
                 otherchild.name,
                 child.name,
                 long2str(otherchild.sex),
                 long2str(expreward),
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

                {inform parents to attacked child}
                inform_parents(otherchild,
                mailrequest_nothing,
                uyellow+'Your kid won'+config.textcol1,
                mkstring(12,underscore),
                'Your '+sex7[otherchild.sex]+' '+ukidc+otherchild.name+config.textcol1+' was attacked by the vicious kid '
                       +ukidc+child.name+config.textcol1+'!',
                ukidc+otherchild.name+config.textcol1+' kicked that lousy kids butt!',
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

               crlf;
               pause;

               {remove shadow kid}
               add_child(SRemoveChild,otherchild,'','',0);

              end;
             end;
            end;
           end;
          end;

          {remove shadow kid}
          add_child(SRemoveChild,child,'','',0);

         end;
        end;

       end; {naughty}

  end; {case .end.}

 until nursery_done;

 {dispose pointer vars}
 for i:=1 to max_mail_strings do begin
  dispose(mail_string[i]);
 end;

 for i:=1 to max_kidparty do begin
  dispose(child_array[i]);
  dispose(child_fate_array[i]);
  dispose(child_nemesis_array[i]);
  dispose(child_wins_array[i]);
 end; {for i:= .end.}

end; {nursery *end*}

Procedure Meny;
const offset = 17;
var s : s90;
begin

 s:='Home Sweet Home';

 clearscreen;
 crlf;
 d(5,s);
 d(5,mkstring(length(s),underscore));
 crlf;
 if spouse_name<>'' then begin
  d(config.textcolor,'You are married to '+uplc+spouse_name+config.textcol1+'.');
 end;
 d(config.textcolor,'Your place is nothing to write home about.');
 d(config.textcolor,'Most people would call it a dump...');
 crlf;

 menu2(ljust('(L)ist Children',offset));
 menu('(N)ursery');

 menu2(ljust('(P)ay ransom',offset));
 menu('(K)idnapped children');

 if Config.AllowAdultOptions then begin
  menu2(ljust('(H)ave Sex',offset));
 end
 else begin
  menu2(ljust('(x)xxx xxx',offset));
 end;

 menu('(M)anage custody of children');

 menu2(ljust('(S)tatus',offset));
 menu('(G)o to sleep');

 menu2(ljust('(R)eturn',offset));
 menu('(C)hest');

end; {meny {*end*}

Procedure Display_Menu(force,short : boolean);
begin

 if short=true then begin
  if player.expert=false then begin
   if (refresh) and (player.auto_meny) then begin
    refresh:=false;
    meny;
   end;

   if player.ear=global_ear_all then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,local_place+' ('+config.textcol2+'?'+config.textcol1+' for menu) :');
  end
  else begin

   if player.ear=1 then begin
    who_is_here;
   end;

   crlf;
   sd(config.textcolor,local_place+' (L,C,G,N,P,K,H,M,S,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure Home_Sweet_Home; {home, you get here from Main Street}
var
    i,
    j,
    size : word;

    ReturnFileId : byte;

    x : longint;

    ch,
    parent_ai : char;

    s,
    s2 : s30;

    done,
    abort,
    found,
    home_done,
    care_house,
    children_found : boolean;

    child : childrec;
    pl0 : userrec;

begin {Main proc START}

 crlf;
 crlf;
 sd(config.textcolor,'going Home ...');

 spouse_name:='';
 spouse_name:=is_player_married(player.name2,player.id);

 {init pointer vars}
 new(spouse);
 new(relationtemp);

 if spouse_name<>'' then begin
  {load spouse}
  found:=false;
  for i:=1 to 2 do begin

   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end;

   for j:=1 to size do begin
    load_character(spouse^,i,j);

    if (spouse^.name2=spouse_name) and
       (spouse^.name2<>'') and
       (spouse^.deleted=false) then begin
     found:=true;
     break;
    end
    else spouse^.name2:='';

   end; {for j:= .end.}

   if found then break;

  end; {for i:= .end.}

  crlf;
  if not found then begin
   d(12,'Your spouse has disappeared from the World of Usurper!');
   spouse_name:='';
  end;
 end;

 crlf;
 crlf;

 if spouse_name<>'' then begin
  {load relation}
  Social_Relation(player,spouse^,relationtemp^);

  d(14,'Home with '+uplc+spouse_name+uyellow+'!');
  sd(config.textcolor,'You have been married for '+uwhite+commastr(relationtemp^.marrieddays)+config.textcol1);
  if relationtemp^.marrieddays>1 then sd(config.textcolor,' days.')
                                 else sd(config.textcolor,' day.');

  if relationtemp^.marrieddays>10 then begin
   sd(15,' Nice going.');
  end
  else if relationtemp^.marrieddays>50 then begin
   sd(15,' Keep it up!');
  end
  else if relationtemp^.marrieddays>100 then begin
   sd(14,' Congratulations!');
  end
  else if relationtemp^.marrieddays>300 then begin
   sd(14,' *You are a golden couple*');
  end;
 end;

 d(14,'** Welcome Home! **');
 crlf;

 home_done:=false;
 repeat

  {update online location, only if necessary}
  if onliner.location<>onloc_home then begin
   refresh:=true;
   onliner.location:=onloc_home;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  {auto-probe, players is moving automatically}
  case global_auto_probe of
   NoWhere:begin
            display_menu(true,true);
            ch:=upcase(getchar);
            
           end;

   AtHome:begin
         global_auto_probe:=NoWhere;
                  ch:='?';

        end;
  end; {case .end.}

  {evaluate user-input}
  case ch of
   '?':begin {menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'R':begin {return}
        home_done:=true;
       end;
   'G':begin {go to sleep}

        crlf;
        crlf;
        if confirm('Go to sleep','N')=true then begin

         {set player location}
         player.location:=Offloc_Home;

         {news-paper}
         newsy(true,
         'Home sweet home',
         ' '+uplc+player.name2+config.textcol1+' fell asleep at home.',
         '',
         '',
         '',
         '',
         '',
         '',
         '',
         '');


         {exit}
         normal_exit;

        end
        else begin
         d(12,'Nah, you can sleep later!');
        end;

       end;
   
   'P':begin {pay ransom for kidnapped children}
        crlf;
        crlf;
        d(5,'Let''s see if you have any kidnapped children...');

        abort:=false;
        children_found:=false;
        for i:=1 to fs(FsChildren) do begin

         {load child}
         load_child(fload,child,i);

         if (child.deleted=false) and
            (child.named=true) and
            (child.ransom_demanded>0) and
            (child.kidnapper<>'') and
            (my_child(player,child)=true) then begin

          if confirm('Pay the '+uyellow+commastr(child.ransom_demanded)+config.textcol1+' ransom for your '+sex7[child.sex]
                     +' '+ukidc+child.name+config.textcol1,'Y')=true then begin

           children_found:=true;

           if player.gold<child.ransom_demanded then begin
            d(12,'You don''t have enough '+config.moneytype+'!');
           end
           else begin
            {add child to online list}
            if add_child(SAddChild,child,player.name2,'being cared for',0)=false then begin
             d(12,child.name+' is not available. try again soon!');
            end
            else begin

             {inform spouse}
             Inform_Parent(child,
              mailRequest_nothing,
              player,
              uyellow+'Child released!'+config.textcol1,
              mkstring(15,underscore),
              'Your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+' was released after your',
              sex5[player.sex]+uplc+' '+player.name2+config.textcol1+' paied the ransom of '+uyellow
               +commastr(child.ransom_demanded)+config.textcol1+' '+many_money(child.ransom_demanded)+'.',
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

             {inform kidnapper}
             post(MailSend,
             child.kidnapper,
             'H',  {this is bad..kidnapper could be npc.}
             false,
             mailrequest_nothing,
             '',
             uyellow+'Ransom Paied'+config.textcol1,
             mkstring(12,underscore),
             uplc+player.name2+config.textcol1+' paied the ransom for '+ukidc+child.name+config.textcol1+'!',
             'You received '+uyellow+commastr(child.ransom_demanded)+config.textcol1+' '+many_money(child.ransom_demanded)+'.',
             '(good work evil one!)',
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

             {update kidnappers account}
             if is_online(child.kidnapper,online_player)=true then begin
              {send money online}
              online_send_to_player(child.kidnapper,online_player,broadcast_sentmoney+long2str(child.ransom_demanded));
             end
             else begin
              {send money offline}

              {first we locate kidnapper/receiver of gold}
              x:=look_for_id(child.kidnapperId,'H',ReturnFileId);
              if x>0 then begin
               if ReturnFileId=1 then begin
                {we only pay human player their money...npcs should
                 get paied as well...but for now I don't bother.}

                load_character(pl0,ReturnFileId,x);

                {update offline player}
                incplayermoney(pl0,child.ransom_demanded);

                user_save(pl0);

               end;
              end;

             end;

             {news-paper}
             newsy(true,
             'Released!',
             ' '+ukidc+child.name+config.textcol1+', the '+sex7[child.sex]+' of '+uplc+child.mother
                +config.textcol1+' and '+uplc+child.father+config.textcol1+' was ',
             ' released by '+sex3[child.sex]+' kidnappers today!',
             ' The worried '+sex8[player.sex]+uplc+' '+player.name2+config.textcol1+' paied the ransom of '+uyellow
                +commastr(child.ransom_demanded)+config.textcol1+' '+many_money(child.ransom_demanded)+'.',
             '',
             '',
             '',
             '',
             '',
             '');


             {update player money}
             decplayermoney(player,child.ransom_demanded);

             {update child}
             child.kidnapper:='';
             child.kidnapperid:='';
             child.ransom_demanded:=0;
             child.location:=ChildLocation_Home;

             load_child(fsave,child,child.recnr);

             {remove shadow child}
             add_child(SRemoveChild,child,'','',0);

             crlf;
            end;

           end;
          end
          else begin
           if confirm('Continue','Y')=false then begin
            abort:=true;
           end;
          end;
         end;

         if abort then break;
        end; {for i:= .end.}

        if children_found=false then begin
         d(15,'None of your children are kidnapped!');
         crlf;
         pause;
         crlf;
        end;

       end;
   'K':begin {kidnappers menu}
        crlf;
        {are there any kidnapped children?}
        found:=false;

        for i:=1 to fs(FsChildren) do begin

         {load child}
         load_child(fload,child,i);


         if child.kidnapper<>'' then begin
          d(15,child.kidnapper);
          d(15,child.kidnapperid);
          d(15,commastr(child.ransom_demanded));
          crlf;
          d(2,player.id);

         end;

         if (child.deleted=false) and
            (child.named=true) and
            (child.kidnapper=player.name2) then begin

          found:=true;
          break;

         end;
        end; {for i:= .end.}

        if not found then begin
         crlf;
         d(12,'You have no kidnapped children in your cellar!');
         d(12,'Go to ''Dark Deeds''! There you can poison and kidnap kids');
         pause;
         crlf;
        end
        else begin
         crlf;
         d(config.textcolor,'You go down to the Cellar.');
         kidnapped_children;
        end;
       end;
   'N':begin {nursery}
        nursery;
       end;
   'M':begin {manage custody of children}
        done:=false;
        repeat

         ch:='?';
         repeat

          crlf;
          if ch='?' then begin
           crlf;
           d(5,'Child care');
           menu('(C)hildren');
           menu('(S)hare custody '+uyellow+'(nice)');
           menu('(A)bandon child '+ulred+'(bad)');
           menu('(O)rphanage '+ured+'(very bad)');
           menu('(H)elp');
           menu('(R)eturn');
           crlf;
          end;

          sd(config.textcolor,'Child care ('+config.textcol2+'?'+config.textcol1+' for menu) :');

          {get user-input}
          ch:=upcase(getchar);

         until ch in ['C','S','A','O','H','R'];

         crlf;
         case ch of
          'R':begin {return}
               done:=true;
              end;
          'C':begin {list of children}
               crlf;
               display_own_children(player,false,true,false);
              end;
          'S':begin {share custody with parent that is currently without
                     access. other parent has to consent/agree.}
               {jakob}
               crlf;
               d(12,'Select your child who you want to share custody:');

               if select_a_child(player,child,ownchild,excludenone,false)=true then begin

                if player.sex=1 then s:=child.mother;
                if player.sex=2 then s:=child.father;

                {no parent exist!}
                if s='' then begin
                 crlf;
                 if player.sex=1 then begin
                  d(12,child.name+'s mother has disappeared!');
                 end
                 else begin
                  d(12,child.name+'s father has disappeared!');
                 end;

                 d(12,'You are sole responsible for your '+sex7[child.sex]+'!');
                 crlf;
                 pause;
                end
                {custody can't be shared if parents already share it}
                else if (child.fatheraccess=true) and (child.motheraccess=true) and
                   (s<>'') then begin
                 crlf;
                 d(12,'You already share custody with '+uplc+spouse_name+ulred+'!');
                 crlf;
                 pause;
                end
                else if child.location<>childlocation_home then begin
                 {child must be home to be able to reject it..}
                 crlf;
                 d(12,child.name+' must be home before you can share custody.');
                 crlf;
                 pause;
                end
                else begin

                 if confirm('Share custody of '+ukidc+child.name+config.textcol1,'N')=true then begin

                  if add_child(SAddChild,child,player.name2,'seeing '+sex3[child.sex]+' parents!',0)=false then begin
                   crlf;
                   d(12,child.name+' is busy. try again soon!');
                   pause;
                  end
                  else begin

                   if player.sex=1 then s:='mother'
                                   else s:='father';

                   {news-paper}
                   Newsy(true,
                   'Child Happiness!',
                   ' '+uplc+player.name2+config.textcol1+' shared custody of '+sex3[player.sex]+' '+commastr(child.age)
                    +' year old '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+'!',
                   ' '+ukidc+child.name+config.textcol1+' can once again see '+sex3[child.sex]+' '+s+'!',
                   ' '+ukidc+child.name+config.textcol1+' is happy!',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '');


                   if player.sex=1 then s:='mother '+uplc+child.mother+config.textcol1
                                   else s:='father '+uplc+child.father+config.textcol1;

                   d(global_kidcol,child.name+config.textcol1+' has reunited with both of '+sex3[child.sex]+' parents!');
                   d(global_kidcol,child.name+config.textcol1+' is now seeing '+sex3[child.sex]+' '+s+' again!');
                   d(global_kidcol,child.name+config.textcol1+' is happy!');
                   d(14,'*nice deed*');

                   {inform parent}
                   if player.sex=1 then begin
                    s:=child.mother;
                    parent_ai:=child.motherai;
                   end
                   else begin
                    s:=child.father;
                    parent_ai:=child.fatherai;
                   end;

                   {send online message}
                   if is_online(s,online_player)=true then begin
                    online_send_to_player(s,online_player,uplc+player.name2+ulred+' shared custody of your '
                       +sex7[child.sex]+' '+ukidc+child.name+config.textcol1+'!');
                   end;

                   {offline mail to parent}
                   post(MailSend,
                   s,
                   parent_ai,
                   false,
                   mailrequest_nothing,
                   '',
                   uwhite+'Nice Parent'+config.textcol1,
                   mkstring(11,underscore),
                   uplc+player.name2+config.textcol1+' shared custody of your '+sex7[child.sex]+' '+ukidc+child.name
                     +config.textcol1+'!',
                   'You and '+uplc+player.name2+' are now responsible for the welfare of your '+sex7[child.sex]+'.',
                   'Together you will also reap the rewards of parenthood.',
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

                   {update child parameters}
                   child.fatheraccess:=true;
                   child.motheraccess:=true;

                   {update child record}
                   load_child(fsave,child,child.recnr);

                   {remove shadow child}
                   add_child(SRemoveChild,child,'','',0);
                   crlf;

                  end;

                 end;
                end;
               end;
              end;
          'O':begin {put kid in orphanage}

               {to put a kid in the orphanage the parent must be the
                sole caretaker of the child. the only parent with .access}
               crlf;
               d(12,'Select your child to be put in the Royal Orphanage:');

               if select_a_child(player,child,ownchild,excludenone,false)=true then begin

                {child can't be rejected if parents are married}
                if player.sex=1 then s:=child.mother;
                if player.sex=2 then s:=child.father;

                if (spouse_name<>'') and (spouse_name=s) then begin
                 crlf;
                 d(12,'A child can''t be transfered when the parents are married!');
                 d(12,'However, visit the nursery and commit your deed there.');
                 crlf;
                 pause;
                end
                else if child.location<>childlocation_home then begin
                 {child must be home to be able to reject it..}
                 crlf;
                 d(12,child.name+' must be home before you can transfer '+sex[child.sex]+'.');
                 crlf;
                 pause;
                end
                else begin

                 if confirm('Transfer '+ukidc+child.name+config.textcol1,'N')=true then begin

                  if add_child(SAddChild,child,player.name2,'being transfered!',0)=false then begin
                   crlf;
                   d(12,child.name+' is busy. try again soon!');
                   pause;
                  end
                  else begin

                   {news-paper}
                   Newsy(true,
                   'Child Transfered!',
                   ' The cruel parent '+uplc+player.name2+config.textcol1+' transfered '+sex3[player.sex]+' '
                     +commastr(child.age)+' year old '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+'!',
                   ' to the '+ulgray+'Royal Orphanage'+config.textcol1+'. '+ukidc+child.name+config.textcol1
                     +' was kicked out from '+sex3[child.sex]+' home!',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '');

                   d(global_kidcol,child.name+config.textcol1+' has been kicked out from the house!');
                   d(global_kidcol,child.name+config.textcol1+' is now living in the '+ulgray+'Royal Orphanage'
                    +config.textcol1+'!');

                   {update child}
                   child.location:=ChildLocation_Orphanage;

                   {inform parent}
                   if player.sex=1 then begin
                    s:=child.mother;
                    parent_ai:=child.motherai;
                   end
                   else begin
                    s:=child.father;
                    parent_ai:=child.fatherai;
                   end;

                   {send online message}
                   if is_online(s,online_player)=true then begin
                    online_send_to_player(s,online_player,uplc+player.name2+ulred+' transfered your '
                      +sex7[child.sex]+' '+ukidc+child.name+config.textcol1+' to the Royal Orphanage!');
                   end;

                   {offline mail to parent}
                   post(MailSend,
                   s,
                   parent_ai,
                   false,
                   mailrequest_nothing,
                   '',
                   ulred+'Evil Parent'+config.textcol1,
                   mkstring(11,underscore),
                   uplc+player.name2+config.textcol1+' rejected your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1
                      +'!',
                   ukidc+child.name+config.textcol1+' is suffering in the '+ulgray+'Royal Orphanage'+config.textcol1+'.',
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

                   {inform the king}
                   inform_king(
                   ulcyan+'Child Arrival'+config.textcol1,
                   cool_string(13,'=','-',11,5),
                   ukidc+child.name+config.textcol1+' has been transfered to the Royal Orphanage.',
                   'You are now responsible for this child.',
                   ukidc+child.name+config.textcol1+' was rejected by '+sex3[child.sex]+' '+sex8[player.sex]+uplc+' '
                    +player.name2+config.textcol1+'!',
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
                   'Child Transport',
                   ' '+uplc+player.name2+config.textcol1+' transfered '+sex3[player.sex]+' '+sex7[child.sex]+' '+ukidc
                      +child.name+config.textcol1+' to the',
                   ' Royal Orphanage. The townspeople are upset!',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '');

                  end;

                  {remove player access to child}
                  case player.sex of
                   1:begin
                      child.fatheraccess:=false;
                     end;
                   2:begin
                      child.motheraccess:=false;
                     end;
                  end; {case .end.}

                  {update child record}
                  load_child(fsave,child,child.recnr);

                  {remove shadow child}
                  add_child(SRemoveChild,child,'','',0);
                  crlf;

                 end;
                end;
               end;

              end;
          'A':begin {abandon/reject child}
               crlf;
               d(12,'Select your child that should be rejected:');

               if select_a_child(player,child,ownchild,excludenone,false)=true then begin

                {child can't be rejected if parents are married}
                if player.sex=1 then s:=child.mother;
                if player.sex=2 then s:=child.father;

                if (spouse_name<>'') and (spouse_name=s) then begin
                 crlf;
                 d(12,'A child can''t be rejected when the parents are married!');
                 crlf;
                 pause;
                end
                else if child.location<>childlocation_home then begin
                 {child must be home to be able to reject it..}
                 crlf;
                 d(12,child.name+' must be home before you can reject '+sex[child.sex]+'.');
                 crlf;
                 pause;
                end
                else begin

                 if confirm('Reject '+ukidc+child.name+config.textcol1,'N')=true then begin

                  if add_child(SAddChild,child,player.name2,'being rejected!',0)=false then begin
                   crlf;
                   d(12,child.name+' is busy. try again soon!');
                   pause;
                  end
                  else begin

                   {news-paper}
                   Newsy(true,
                   'Child Rejected!',
                   ' The cruel parent '+uplc+player.name2+config.textcol1+' rejected '+sex3[player.sex]+' '+commastr(child.age)
                    +' year old '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+'!',
                   ' '+ukidc+child.name+config.textcol1+' was kicked out from '+sex3[child.sex]+' home!',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '');

                   {can the other parent take care of the child?}
                   care_house:=false;
                   if (player.sex=1) and (child.mother='') then begin
                    care_house:=true;
                   end;
                   if (player.sex=2) and (child.father='') then begin
                    care_house:=true;
                   end;

                   if care_house=false then begin
                    if player.sex=1 then s2:='mother'
                                    else s2:='father';

                    d(global_kidcol,child.name+config.textcol1+' was kicked out from the house!');
                    d(global_kidcol,child.name+config.textcol1+' is now living with '+sex3[child.sex]+' '+s2+'.');

                     {custody transfered to other parent
                      let us inform the news and the parent}

                    {news-paper}
                    Newsy(true,
                    'Child Custody',
                    ' Custody of poor little '+ukidc+child.name+config.textcol1+' has been transfered',
                    ' to the '+s2+'; '+uplc+s+config.textcol1+', who now is responsible for the upbringing',
                    ' of '+ukidc+child.name+config.textcol1+'.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                    {inform parent}
                    if player.sex=1 then begin
                     s:=child.mother;
                     parent_ai:=child.motherai;
                    end
                    else begin
                     s:=child.father;
                     parent_ai:=child.fatherai;
                    end;

                    {send online message}
                    if is_online(s,online_player)=true then begin
                     online_send_to_player(s,online_player,uplc+player.name2+ulred+' rejected your '
                       +sex7[child.sex]+' '+ukidc+child.name+config.textcol1+'!');
                    end;

                    {offline mail to parent}
                    post(MailSend,
                    s,
                    parent_ai,
                    false,
                    mailrequest_nothing,
                    '',
                    ulred+'Evil Parent'+config.textcol1,
                    mkstring(11,underscore),
                    uplc+player.name2+config.textcol1+' rejected your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1
                       +'!',
                    'You are now on your own, with full responsibility for '+ukidc+child.name+config.textcol1+'.',
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

                    d(global_kidcol,child.name+config.textcol1+' has been kicked out from the house!');
                    d(global_kidcol,child.name+config.textcol1+' is now living in the '+ulgray+'Royal Orphanage'
                     +config.textcol1+'!');

                    {update child}
                    child.location:=ChildLocation_Orphanage;

                    {inform the king}
                    inform_king(
                    ulcyan+'Child Arrival'+config.textcol1,
                    cool_string(13,'=','-',11,5),
                    ukidc+child.name+config.textcol1+' has been transfered to the Royal Orphanage.',
                    'You are now responsible for this child.',
                    ukidc+child.name+config.textcol1+' was rejected by '+sex3[child.sex]+' '+sex8[player.sex]+uplc+' '
                     +player.name2+config.textcol1+'!',
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
                    'Child Transport',
                    ' '+uplc+player.name2+config.textcol1+' transfered '+sex3[player.sex]+' '+sex7[child.sex]+' '+ukidc
                       +child.name+config.textcol1+' to the',
                    ' Royal Orphanage. The townspeople are upset!',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                   end;

                   {remove player access to child}
                   case player.sex of
                    1:begin
                       child.fatheraccess:=false;
                       child.motheraccess:=true;
                      end;
                    2:begin
                       child.motheraccess:=false;
                       child.fatheraccess:=true;
                      end;
                   end; {case .end.}

                   {update child record}
                   load_child(fsave,child,child.recnr);

                   {remove shadow child}
                   add_child(SRemoveChild,child,'','',0);
                   crlf;

                  end;

                 end;
                end;
               end;
              end;

          'H':begin {Help on Custody issues}
               crlf;
               d(15,uyellow+'Share custody'+uwhite+' - when you divorce only one parent will');
               d(15,'get access to the children. By sharing custody you can');
               d(15,'again share the responsibility and reap the rewards of');
               d(15,'parenthood.');
               crlf;
               d(15,uyellow+'Abandon child'+uwhite+' - when you do this you no longer have');
               d(15,'responsibility for the child you have selected. This means that you');
               d(15,'don''t have to pay for the childs upbringing any more. On the');
               d(15,'downside you no longer will receive experience points for taking');
               d(15,'care of Your offspring. Your spouse will probably have something');
               d(15,'to say about this as well. Remember that your child will most likely');
               d(15,'not appreciate to be rejected.');
               crlf;
               d(15,uyellow+'Orphanage'+uwhite+' - when you do this you no longer have');
               d(15,'responsibility for the child you selected. This means that you');
               d(15,'don''t have to pay for the childs upbringing any more. On the');
               d(15,'downside you no longer will receive experience points for taking');
               d(15,'care of Your offspring. Your spouse will probably have something');
               d(15,'to say about this as well. Your child will certainly not like to');
               d(15,'be put in the '+ulgreen+'Royal Orphanage'+uwhite+'.');
               d(15,'Things can get real ugly if the Royals decide that your child costs');
               d(15,'too much to raise and simply throw the kid to the wolves.');
               crlf;
               pause;
              end;

         end; {case .end.}

        until done;
       end;

   'H':begin {have sex}

        if not config.allowadultoptions then begin
         crlf;
         crlf;
         d(12,'The Adult Options have been disabled by the Sysop.');
         pause;
        end
        else if spouse_name<>'' then begin

         {two ways....online or remote}
         {if your spouse is offline you can either request to have
          sex or you can force it.}

         {if spouse is online then there we send a direct request}
         crlf;
         crlf;
         if confirm('Have sex with '+uplc+spouse_name+config.textcol1,'N')=false then begin
          d(15,'Not right now. You have this headache.');
         end
         else begin
          crlf;
          if player.IntimacyActs<1 then begin
           {any intimate acts left?}
           no_intimate_acts;
           pause;
          end
          else begin
           {spouse is online[busy]}
           if is_online(spouse_name,online_player)=true then begin
            d(12,'Not right now. '+uplc+spouse_name+ulred+' is busy.');
           end
           else begin

            {lets put spouse online}
            if add_shadow(SAdd,spouse^,player.name2,'having sex with '+uplc+player.name2+config.textcol1,0)=false then begin
             {we were (for some reason) unable to add spouse to the online file}
             crlf;
             d(12,'Sorry, but '+uplc+spouse^.name2+ulred+' is busy right now!');
             pause;

            end
            else begin

             {mail request to have sex or FORCE it!}
             d(global_plycol,spouse_name+config.textcol1+' is not available right now.');
             d(config.textcolor,'Would you like to have '+sex3[spouse^.sex]+' consent to have sex');
             d(config.textcolor,'or will you '+uwhite+'FORCE'+config.textcol1+' it!');

             repeat
              crlf;
              menu('(A)sk (nice)');
              menu('(F)orce! (beware)');
              menu('(N)ever mind (wimpish)');
              crlf;
              sd(config.textcolor,'Decision :');

              {get user-input}
              ch:=upcase(getchar);

             until ch in ['A','F','N'];

             crlf;

             {evaluate user-input}
             case ch of
              'F':begin {force sex upon spouse}

                   {news-paper}
                   Newsy(true,
                   'Hot Passion',
                   ' '+uplc+player.name2+config.textcol1+' and '+uplc+spouse^.name2+config.textcol1
                       +' spent the night together.',
                   ' Well, they are married so they are entitled to have some fun...',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '',
                   '');

                   {sexual act described}
                   sex_act_routine(player,spouse^,true);

                   {experience earned}
                   x:=sex_experience(player,spouse^);

                   {give both players their experience points}
                   IncPlayerExp(spouse^,x);
                   IncPlayerExp(player,x);

                   {update spouse}
                   user_save(spouse^);

                   {one intimacyact less for player!}
                   dec(player.intimacyActs);

                   d(config.textcolor,'You earned '+uwhite+commastr(x)+config.textcol1+' experience points!');

                   {if this is an Npc and random event then we dislike this
                    forced sexual act..should be implemented!}

                   {mailing spouse to inform of night}
                   post(MailSend,
                   spouse^.name2,
                   spouse^.ai,
                   false,
                   mailrequest_nothing,
                   '',
                   uyellow+'Spending the Night'+config.textcol1,
                   mkstring(18,underscore),
                   uplc+player.name2+config.textcol1+' forced you to have '+uyellow+'Sex'+config.textcol1+' with '
                       +sex[player.sex]+'.',
                   'You had a wonderful time in bed with '+uplc+player.name2+config.textcol1+'.',
                   'You earned '+uwhite+commastr(x)+config.textcol1+' experience points.',
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

              'A':begin {consent for sex requested}

                   if spouse^.ai='C' then begin
                    {npc spouse, has to decide whether to sleep with player
                     or not}

                    if random(2)=0 then begin
                     crlf;
                     sd(global_plycol,spouse^.name2);
                     d(12,' doesn''t feel like doing it right now.');
                     pause;
                     crlf;
                    end
                    else begin

                     {sexual act described}
                     sex_act_routine(player,spouse^,true);

                     {experience earned}
                     x:=sex_experience(player,spouse^);

                     {give both players their experience points}
                     IncPlayerExp(spouse^,x);
                     IncPlayerExp(player,x);

                     {update spouse}
                     user_save(spouse^);

                     d(config.textcolor,'You earned '+uwhite+commastr(x)+config.textcol1+' experience points!');

                     {news-paper}
                     Newsy(true,
                     'In Bed',
                     ' '+uplc+player.name2+config.textcol1+' and '+uplc+spouse^.name2+config.textcol1+' shared a bed.',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '',
                     '');

                    end;

                   end
                   else begin
                    {Human Spouse}
                    crlf;
                    crlf;
                    d(15,'You will have to wait and see if '+uplc+spouse^.name2+uwhite+' is in');
                    d(15,'the mood to sleep with you.');
                    sd(15,'Leaving a '+ulblue+'note'+uwhite+' to '+uplc+spouse^.name2+uwhite+'...');

                    {mail "have sex" request}
                    post(MailSend,
                    spouse^.name2,
                    spouse^.ai,
                    false,
                    mailrequest_HaveSex,
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

                   {one intimacyact less for player!}
                   dec(player.intimacyActs);

                  end
                  else begin
                   d(15,'You''re all mouth and no action!');
                  end;
             end; {case .end.}

             {remove spouse^ from online list}
             add_shadow(SRemove,spouse^,'','',0);

            end;
           end;
          end;
         end;
        end;

       end; {have sex .end.}

   'L':begin {list of children, display own}
        crlf;
        crlf;

        display_own_children(player,false,true,false);

       end;

   'C':begin {chest of items}
        if config.classic then begin
         crlf;
         crlf;
         d(12,'This option is only available in Usurper NEW game mode.');
         pause;
        end
        else begin
         chest_with_items;
        end;

       end; {chest_of_items .end.}

  end; {case .end.}

 until home_done;

 crlf;
 crlf;
 d(config.textcolor,'Ahh, back in the busy streets.');

 {discard pointer vars}
 disposal;

end; {Home_Sweet_Home *end*}

end. {Unit Home .end.}
