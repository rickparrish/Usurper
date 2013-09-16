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


Unit SendItem; {Usurper - Transfer Items to team members}

Interface

Procedure Team_Transfer; {Send stuff to offline team-member}

Implementation

Uses Init, Cms, Jakob,
     Mail, Statusc, Invent,
     Comp_Use, Npc_Chec, Various,
     Various2, Various3, Relation,
     Online, File_Io;

Procedure Team_Transfer;
var
     cho : char;
     s : s70;

     xx,
     yy : longint;

     i,
     j,
     size : word;

     pmode : byte;

     pl0    : ^UserRec;
     objekt : ^orec;

     done,
     break_out : boolean;

begin

 {init}
 new(pl0);
 new(objekt);

 done:=false;
 break_out:=false;
 pmode:=0;

 repeat
  crlf;
  crlf;
  d(config.textcolor,'Who do you wanna send stuff to? (enter '+config.textcol2+'?'+config.textcol1+' to see your team)');
  sd(config.textcolor,':');

  {get user input}
  s:=get_string(20);

  if s='?' then begin
   {display team-members}
   display_members(player.team,true);
  end
  else begin
   done:=true;

   for i:=1 to 2 do begin

    case i of
     1: size:=fs(FsPlayer);
     2: size:=fs(FsNpc);
    end;

    for j:=1 to Size do begin

     {load character}
     load_character(pl0^,i,j);

     if (findsub(s,pl0^.name2)) and
        (pl0^.name2<>player.name2) and
        (pl0^.name2<>global_delname2) and
        (pl0^.deleted=false) and
        (pl0^.team=player.team) then begin

      if confirm(uplc+pl0^.name2+config.textcol1,'n')=true then begin

       if is_online(pl0^.name2,online_player)=true then begin
        crlf;
        d(12,'You can''t send stuff to a character who is online from here.');
        d(12,'(use command from main street instead)');
        crlf;
        break_out:=true;
       end
       else begin
        break_out:=true;
       end;

       pmode:=i;

      end
      else begin
       if confirm('Continue search','Y')=false then begin
        break_out:=true;
       end;
      end;

     end;

     if break_out=true then break;

    end; {for j:= .end.}

    if break_out=true then break;

   end; {for i:= .end.}

  end;

 until done;


 if pmode in [1,2] then begin

  if add_shadow(SAdd,pl0^,player.name2,'talking to '+uplc+player.name2+config.textcol1,0)=false then begin
   {unable to add pl0}
   crlf;
   d(global_plycol,pl0^.name2+config.textcol1+' has entered the Realm!');
   d(config.textcolor,'Try sending your stuff to '+sex[pl0^.sex]+' directly insted.');
   pause;
  end
  else begin

  repeat

   cho:='?';
   repeat
    if cho='?' then begin
     crlf;
     crlf;
     d(config.textcolor,'Send stuff to '+uplc+pl0^.name2+config.textcol1);
     crlf;
     menu('(E)xamine '+uplc+pl0^.name2+config.textcol1);
     menu('(M)oney');
     menu('(H)ealing Potions');
     menu('(I)tems');
     menu('(S)tatus');
     menu('(D)one');
     sd(config.textcolor,':');
    end;

    cho:=upcase(getchar);

    if (cho='I') and (config.classic) then begin
     crlf;
     d(15,'Not available in CLASSIC mode');
     cho:='?';
    end;

   until cho in ['E','M','H','I','S','D'];

   case cho of
    'S':begin {status}
         status(player);
        end;
    'E':begin {examine team member}
         status(pl0^);
        end;
    'I':begin {send item from inventory}
         repeat
          inventory_sort(player);

          d(config.textcolor,'Item # to Send ('+config.textcol2+'?'+config.textcol1+'=list, Enter=abort)');
          sd(config.textcolor,':');

          s:=get_String(5);
          yy:=0;

          if s='?' then begin
           inventory_display(player);
          end
          else begin
           yy:=str_to_nr(s);
           if (yy<1) or (yy>global_maxitem) then yy:=0;
          end;

          if yy>0 then begin
           if player.item[yy]>0 then begin
            xx:=player.item[yy];
            load_objekt(objekt^,player.itemtype[yy],xx);

            crlf;
            sd(config.textcolor,'Send ');
            sd(global_itemcol,objekt^.name+' '+item_power_display(objekt^));

            if confirm('','N')=true then begin
             sd(config.textcolor,'You give ');
             sd(global_itemcol,objekt^.name);
             sd(config.textcolor,' to ');
             sd(global_plycol,pl0^.name2);
             d(config.textcolor,'.');
             crlf;

             if class_restricted(pl0^.class,objekt^,0) then begin
              sd(global_talkcol,'I can''t use this! It''s class restricted!');
              sd(config.textcolor,', ');
              sd(global_plycol,pl0^.name2);
              d(config.textcolor,' complains and');
              sd(config.textcolor,'returns the ');
              sd(global_itemcol,objekt^.name);
              d(config.textcolor,'.');
             end
             else if objekt^.cursed then begin
              sd(global_talkcol,'I wont take any CURSED items!');
              sd(config.textcolor,', ');
              sd(global_plycol,pl0^.name2);
              d(config.textcolor,' says and');
              sd(config.textcolor,'returns the ');
              sd(global_itemcol,objekt^.name);
              d(config.textcolor,'.');
             end
             else if pmode=1 then begin
              inventory_empty(pl0^);

              check_inventory(pl0^,player.item[yy],objekt^.ttype,true,5);

              player.item[yy]:=0;

              {inform player}
              post(MailSend,
              pl0^.name2,
              pl0^.ai,
              false,
              mailrequest_nothing,
              '',
              umailheadc+'Items received'+config.textcol1,
              mkstring(14,underscore),
              uplc+player.name2+config.textcol1+' sent you '+uitemc+objekt^.name+' '+item_power_display(objekt^)
               +config.textcol1+'.',
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
              pause;
             end
             else begin
              {SENDING TO NPC}
              check_inventory(pl0^,player.item[yy],objekt^.ttype,true,5);

              {computer_use(pl0^,objekt^,player.item[yy],true);}
              player.item[yy]:=0;
             end;
            end;
           end;
          end;
         until s='';
        end;
    'M':begin {send money}
         crlf;
         d(config.textcolor,'How much ? (you have '+uyellow+commastr(player.gold)+config.textcol1+' in '+config.moneytype+')');
         sd(config.textcolor,':');

         xx:=get_number(0,player.gold);

         if (xx>player.gold) then begin
          d(config.textcolor,'You don''t have that kind of '+config.moneytype+'!');
          xx:=0;
         end
         else if (xx<=player.gold) and (xx>0) then begin
          yy:=xx;

          sd(config.textcolor,'Send ');
          sd(14,commastr(yy));
          sd(config.textcolor,' '+many_money(yy)+' to ');
          sd(global_plycol,pl0^.name2);

          if confirm('','n')=true then begin

           incplayermoney(pl0^,yy);
           decplayermoney(player,yy);

           sd(config.textcolor,'The '+config.moneytype+' has been sent to ');
           sd(global_plycol,pl0^.name2);
           d(config.textcolor,'.');
           crlf;

           if pmode=2 then begin

            {the NPCs loyalty will go up when money is give to him/her}
            xx:=0;
            if (yy>0) and (yy<10001) then begin
             xx:=10;
            end
            else if (yy>=10001) and (yy<50001) then begin
             xx:=15;
            end
            else if (yy>=50001) and (yy<250001) then begin
             xx:=20;
            end
            else if (yy>=250001) and (yy<1500001) then begin
             xx:=25;
            end
            else if (yy>=1500001) and (yy<15000001) then begin
             xx:=30;
            end
            else if (yy>=15000001) and (yy<150000001) then begin
             xx:=35;
            end
            else if (yy>=150000001) and (yy<2000000001) then begin

             if random(2)=0 then begin
              {improve pl0:s attitude to player}
              Update_Relation(Relation_Better,1,pl0^,player,false,false);
             end;

             xx:=40;
            end;

            if xx>0 then begin
             pl0^.loyalty:=pl0^.loyalty+xx;
             d(14,pl0^.name2+'s loyalty increased!');
             pause;
            end;

            if pl0^.loyalty>100 then begin
             pl0^.loyalty:=100;
            end;


           end
           else if pmode=1 then begin

            {mail a letter to receiver of money}
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+'Team'+config.textcol1,
            mkstring(4,underscore)+config.textcol1,
            uplc+player.name2+config.textcol1+' sent you '+uyellow+commastr(yy)+config.textcol1+' '+many_money(yy)+'!',
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

            pause;

           end;
          end;
         end
         else begin
          d(15,'Aborted.');
          {}
         end;
        end;
    'H':begin {send healing potions}
         crlf;
         d(config.textcolor,'How many ? (you have '+commastr(player.healing)+' potions)');
         sd(config.textcolor,':');

         yy:=get_number(0,player.healing);

         if (yy>player.healing) then begin
          d(config.textcolor,'You don''t have that many!');
          yy:=0;
         end
         else if pl0^.healing+yy>config.maxheals then begin
          d(config.textcolor,'You can send max '+commastr(config.maxheals-pl0^.healing)+' potions!');
          yy:=0;
         end
         else if (player.healing>=yy) and (yy>0) then begin
          if confirm('Send '+commastr(yy)+' potions to '+pl0^.name2,'n')=true then begin
           pl0^.healing:=pl0^.healing+yy;
           player.healing:=player.healing-yy;

           sd(config.textcolor,'The potions have been sent to ');
           sd(global_plycol,pl0^.name2);

           d(config.textcolor,'.');
           crlf;

           if pmode=1 then begin
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+'Team'+config.textcol1,
            mkstring(4,underscore)+config.textcol1,
            uplc+player.name2+config.textcol1+' has sent you '+uwhite+commastr(yy)+config.textcol1+' healing potions!',
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
            pause;
           end;
          end;
         end
         else begin
         end;
        end;
   end;
  until cho='D'; {bye bye}

  d(5,'Done');

  {remove shadow player}
  add_shadow(SRemove,pl0^,'','',0);

  {save receiving player}
  user_save(pl0^);
  end;

 end;

 {dispose pointer vars}
 dispose(objekt);
 dispose(pl0);

end; {Team_Transfer *end*}

end. {Unit SendItem .end.}

