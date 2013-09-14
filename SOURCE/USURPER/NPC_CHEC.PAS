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
Unit Npc_Chec; {Usurper - Npcs and offline players Check their Inventory}
               {"the computer players are not very smart" - jakob}
Interface

Uses Init;

Function Check_Inventory( var gubbe : UserRec;
                          onr   : longint; {object #, 0=reinventory}
                          otyp  : objtype;
                          shout : boolean;
                          location:byte ) : byte;

Implementation

Uses Jakob, Cms, Various,
     Various2, Invent, Mail,
     File_Io;

var
   objekt,
   objekt2 : ^orec; {Items}

Procedure Dispose_Vars; {dispose of pointer variables}
begin
 dispose(objekt);
 dispose(objekt2);
end;

Procedure Inform_By_Mail(const location:byte;
                         const newitem:orec;
                         const olditem:orec;
                         const situation:byte;
                         const ply:userrec);

Function Random_Header : s30;
var result : s30;
begin
 case random(4) of
  0: result:='Gold and Glory!';
  1: result:='Loot!';
  2: result:='Looting Party!';
  3: result:='New Stuff!';
 end; {case .end.}

 {return result}
 random_header:=result;

end; {random_header *end*}

var s : s100;
begin {inform offline player by mail how new item was found and how he
       decided to use it.}

 {situation: 1=nothing similar used before and the item is ok!
               ply starts to use it immediately.
             2=ply is already equipped with a similar type of equipment
               but decides to use the new item instead.}

 case location of

  1:begin {finding item in the dungeons}
     case situation of
      1:begin {nothing similar used on body...and item is ok! starts to use it!}

         s:=random_header;

         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         ulblue+s+config.textcol1,
         mkstring(length(s),underscore),
         'You found '+uitemc+newitem.name+config.textcol1+' in the Dungeons.',
         'You started to use it immediately.',
         'The '+uitemc+newitem.name+config.textcol1+' is worth approximately '+uyellow+commastr(newitem.value)
               +config.textcol1+' '+many_money(newitem.value)+'.',
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
      2:begin {similar item already in use...but decided to use the new
               item instead.}

         s:=random_header;

         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         ulblue+s+config.textcol1,
         mkstring(length(s),underscore),
         'You found '+uitemc+newitem.name+config.textcol1+' in the Dungeons.',
         'You started to use it instead of your old '+uitemc+olditem.name+config.textcol1+'.',
         'The '+uitemc+newitem.name+config.textcol1+' is worth approximately '+uyellow+commastr(newitem.value)
               +config.textcol1+' '+many_money(newitem.value)+'.',
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
     end; {case .end.}
    end;

  3:begin {finding item after killing monster (monster weapon/armor) }
     case situation of
      1:begin {nothing similar used on body...and item is ok! starts to use it!}

         s:='Monster Equipment';

         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         ulblue+s+config.textcol1,
         mkstring(length(s),underscore),
         'After killing a monster You found '+uitemc+newitem.name+config.textcol1+'.',
         'You started to use it immediately.',
         'The '+uitemc+newitem.name+config.textcol1+' is worth approximately '+uyellow+commastr(newitem.value)
               +config.textcol1+' '+many_money(newitem.value)+'.',
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
      2:begin {similar item already in use...but decided to use the new
               item instead.}

         s:='Monster Equipment';

         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         ulblue+s+config.textcol1,
         mkstring(length(s),underscore),
         'After killing a monster You found '+uitemc+newitem.name+config.textcol1+'.',
         'You started to use it instead of your old '+uitemc+olditem.name+config.textcol1+'.',
         'The '+uitemc+newitem.name+config.textcol1+' is worth approximately '+uyellow+commastr(newitem.value)
               +config.textcol1+' '+many_money(newitem.value)+'.',
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

     end; {case .end.}
    end;
  4:begin {finding item after other player killing a monster and not wanting
           the monster weapon/armor)}
     case situation of
      1:begin {nothing similar used on body...and item is ok! starts to use it!}

         s:='Monster Equipment';

         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         ulblue+s+config.textcol1,
         mkstring(length(s),underscore),
         'After your party killed a monster You claimed its '+uitemc+newitem.name+config.textcol1+'.',
         'You started to use it immediately.',
         'The '+uitemc+newitem.name+config.textcol1+' is worth approximately '+uyellow+commastr(newitem.value)
               +config.textcol1+' '+many_money(newitem.value)+'.',
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
      2:begin {similar item already in use...but decided to use the new
               item instead.}

         s:='Monster Equipment';

         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         ulblue+s+config.textcol1,
         mkstring(length(s),underscore),
         'After your party killed a monster You claimed its '+uitemc+newitem.name+config.textcol1+'.',
         'You started to use it instead of your old '+uitemc+olditem.name+config.textcol1+'.',
         'The '+uitemc+newitem.name+config.textcol1+' is worth approximately '+uyellow+commastr(newitem.value)
               +config.textcol1+' '+many_money(newitem.value)+'.',
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
     end; {case .end.}
    end;
 end; {case .end.}

end; {inform_by_mail *end*}

Function Objekt_Test(mode      : char; {vapen eller armor eller allm„nt}
                     var gubbe : userrec;
                     var o1,o2 : orec) : boolean;
var go : boolean;
begin

 go:=false;

 case mode of
  'A':begin {armor test}
       if (o2.armor>o1.armor) and
          (gubbe.strength>=o2.str_need) and
          (o2.attack>=0) and
          (o2.hps>=0) and
          (o2.defence>=0) then begin
        go:=true;
       end;
      end;
  'W':begin {weapon test}
       if (o2.attack>o1.attack) and
          (gubbe.strength>=o2.str_need) and
          (o2.armor>=0) and
          (o2.hps>=0) and
          (o2.defence>=0) then begin
         go:=true;
       end;
      end;

  'G':begin {general best test}
       if (o2.value>o1.value) and
          (o2.cursed=false) and
          (o2.armor>=0) and
          (o2.attack>=0) and
          (o2.hps>=0) then begin
        go:=true;
       end;

      end;
 end; {case .end.}

 if class_restricted(gubbe.class,o2,0)=true then begin
  {item is class restricted}
  go:=false;
 end
 else if (o2.good=true) and (gubbe.chiv<1) and (gubbe.dark>0) then begin
  {player too evil for object}
  if o2.value<15000 then begin
   go:=false;
  end;
 end
 else if (o2.evil=true) and (gubbe.chiv>0) and (gubbe.dark<1) then begin
  {player too good for object}
  if o2.value<15000 then begin
   go:=false;
  end;
 end;

 if (gubbe.class in [Magician,Cleric,Sage]) and (o2.mana<0) then begin
  go:=false;
 end;

 if o2.cursed=true then begin
  go:=false;
 end;

 {return result}
 objekt_test:=go;

end; {objekt_test *end*}

Function Objekt_Test2(var gubbe : userrec;
                      var o2    : orec) : boolean;
var go : boolean;
begin

 go:=true;

 if (gubbe.strength>=o2.str_need) and
    (o2.attack>=0) and
    (o2.hps>=0) and
    (o2.defence>=0) then begin
  go:=true;
 end;

 if (o2.good=true) and (gubbe.chiv<1) and (gubbe.dark>0) then begin
  {player too evil for object}
  go:=false;
 end
 else if (o2.evil=true) and (gubbe.chiv>0) and (gubbe.dark<1) then begin
  {player too good for object}
  go:=false;
 end;

 if (gubbe.class in [Magician,Cleric,Sage]) and (o2.mana<0) then begin
  go:=false;
 end;

 if o2.cursed=true then begin
  go:=false;
 end;

 if class_restricted(gubbe.class,o2,0)=true then begin
  {item is class restricted}
  go:=false;
 end;

 {return result}
 objekt_test2:=go;

end; {objekt_test2 *end*}

Procedure Shout_it(const gubbe : userrec);
begin

 sd(global_plycol,gubbe.name2);
 sd(config.textcolor,' removes the ');
 sd(global_itemcol,objekt2^.name);
 sd(config.textcolor,' and uses the ');
 sd(global_itemcol,objekt^.name);
 d(config.textcolor,' instead.');

end;

Procedure Shout_It2(const gubbe : userrec);
begin
 sd(global_plycol,gubbe.name2);
 sd(config.textcolor,' starts to use the ');
 sd(global_itemcol,objekt^.name);
 d(config.textcolor,'.');
end;

Procedure Back_Pack(var gubbe : userrec;
                    var objekt    : orec);
begin
 sd(global_plycol,gubbe.name2+config.textcol1+' puts the ');
 sd(global_itemcol,objekt.name);
 d(config.textcolor,' in '+sex3[gubbe.sex]+' backpack.');
end;

Procedure Throw_Away(var gubbe : userrec;
                     var objekt    : orec);
begin
 case random(5) of
  0: sd(global_talkcol,'Nah! I don''t need this crap!');
  1: sd(global_talkcol,'I can''t carry this!');
  2: sd(global_talkcol,'Have to throw it away');
  3: sd(global_talkcol,'My backpack is full!');
  4: sd(global_talkcol,'Nah! I don''t need this!');
 end; {case .end.}
 sd(config.textcolor,', ');
 sd(global_plycol,gubbe.name2);
 sd(config.textcolor,' says, and drops the ');
 sd(global_itemcol,objekt.name);
 d(config.textcolor,'.');
end; {throw_away *end*}

Procedure Stuff_Item(var gubbe:userrec;shout:boolean;onr:longint;var objekt : orec);
var discard:boolean;
    q : byte;
begin {gubbe kan inte ha prylen p† sig, inventoryt „r fullt! kan n†t sl„ngas?}
 discard:=true;
 for q:=1 to global_maxitem do begin
  load_objekt(objekt2^,gubbe.itemtype[q],gubbe.item[q]);
  if objekt_test('G',gubbe,objekt2^,objekt)=true then begin
   if shout then back_pack(gubbe,objekt);
   gubbe.item[q]:=onr;
   gubbe.itemtype[q]:=objekt.ttype;

   throw_away(gubbe,objekt2^);
   discard:=false;
   break;
  end;
 end; {for q:= .end.}

 if (discard) and (shout) then throw_away(gubbe,objekt);

end; {stuff_item *end*}

Function Check_Inventory( var gubbe : UserRec;
                          onr   : longint; {object #, 0=reinventory}
                          otyp  : objtype;
                          shout : boolean;
                          location:byte ) : byte;

                          {location:
                           0=reinventory
                           1=dngs finding item by random,
                           2=plVSpl,
                           3=plVSMon finding item after kill
                           4=plVSMon picking up item after other partymember
                             discarded/dropped it.
                           5=sending item...senditem.pas (team_transfer)
                           }

const mail_inform =true;
      shout_affect = false;
var
   i, j  : integer;
   result : byte;
   stuffit1, stuffit2 : boolean;

begin

 {** Character GUBBE scans his inventory and considers the use
     of his items, perhaps switch gear. This routine is only used
     in NEW game mode **}

 {returned resultcodes from this function:)
       0=item not touched
       1=is not wearing anything like the new item. starts using new item.
       2=new item is better than the already used. swapping items.}

 { name : s70;   {objektets namn}
 { ttype: objtype;      {typ av objekt :
{  value : longint;     {v„rdet p† objektet}
{  hps  : integer;      {ska objekt ”ka hps}
{  stamina : integer;   {stamina}
{  agility : integer;   {agility}
{  charisma : integer;  {charisma}
{  dex : integer;       {dexterity}
{  wisdom : integer;    {wisdom}
{  mana   : integer;    {mana}
{  armor : integer;     {ska objekt ”ka armor v„rdet}
{  attack : integer;    {ska objekt ”ka attack v„rdet}
{  owned  : s70;        {„gd av}
{  onlyone: boolean;    {bara finnas ett objekt ?}
{  cure   : cures;      {kan objektet hela?}
{  shop   : boolean;    {finnas i shoppen}
{  dng    : boolean;    {kunna hittas i dungeons?}
{  cursed : boolean;    {cursed item?}
{  minlev : integer;    {min level att hittas i dngs}
{  maxlev : integer;    {max level att hittas i dngs}
{  desc1 : array [1..5] of s70; {normal beskriving}
{  desc2 : array [1..5] of s70; {detaljerad beskriving}
{  strength : integer;
  defence : integer;
  str_need : integer; {strength needed}
{  good : boolean; {beh”ver man vara god f”r att anv„nda detta?}
{  evil : boolean; {beh”ver man vara ond f”r att anv„nda detta?}

 result:=0;

 if config.CLASSIC then begin
  check_inventory:=result;
  exit;
 end;

 {init pointer vars}
 new(objekt);
 new(objekt2);

 {gubbe shall only check newobj, SINGEL-check!}
 if onr>0 then begin

  {load object}
  load_objekt(objekt^,otyp,onr);

  i:=inventory_empty(gubbe);

  if shout then begin
   sd(global_plycol,gubbe.name2);
   sd(config.textcolor,' looks at the ');
   sd(global_itemcol,objekt^.name);
   d(config.textcolor,'.');
  end;

  stuffit1:=false;
  stuffit2:=false;

  case objekt^.ttype of
    Head:begin
          if config.allowitem[2]=false then begin
           if shout then d(config.textcolor,'I can''t use this type of item!');
          end
          else if gubbe.head>0 then begin

           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,head,gubbe.head);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.head,head,gubbe,shout_affect);

            j:=gubbe.head;
            gubbe.head:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=head;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.head,head,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=head;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin

            result:=1;

            gubbe.head:=onr;
            objekt_affect(1,gubbe.head,head,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=head;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

        end;
   Body:begin
          if config.allowitem[3]=false then begin
           if shout then d(config.textcolor,'I can''t use this type of item!');
         end
         else if gubbe.body>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,body,gubbe.body);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.body,body,gubbe,shout_affect);
            j:=gubbe.body;
            gubbe.body:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=body;
            end
            else begin
             stuffit2:=true
            end;
            objekt_affect(1,gubbe.body,body,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=body;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin
            result:=1;

            gubbe.body:=onr;
            objekt_affect(1,gubbe.body,body,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=body;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

        end;
   Arms:begin
         if config.allowitem[4]=false then begin
           if shout then d(config.textcolor,'I can''t use this type of item!');
         end
         else if gubbe.arms>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,arms,gubbe.arms);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.arms,arms,gubbe,shout_affect);
            j:=gubbe.arms;
            gubbe.arms:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=arms;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.arms,arms,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=arms;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin
            result:=1;

            gubbe.arms:=onr;
            objekt_affect(1,gubbe.arms,arms,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=arms;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

        end;
   Hands:begin
          if config.allowitem[1]=false then begin
           if shout then d(config.textcolor,'I can''t use this type of item!');
          end
          else if gubbe.hands>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,hands,gubbe.hands);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.hands,hands,gubbe,shout_affect);
            j:=gubbe.hands;
            gubbe.hands:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=hands;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.hands,hands,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=hands;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin
            result:=1;
            gubbe.hands:=onr;
            objekt_affect(1,gubbe.hands,hands,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=hands;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

         end;
   Legs:begin
         if config.allowitem[7]=false then begin
          if shout then d(config.textcolor,'I can''t use this type of item!');
         end
         else if gubbe.legs>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,legs,gubbe.legs);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.legs,legs,gubbe,shout_affect);
            j:=gubbe.legs;
            gubbe.legs:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=legs;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.legs,legs,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=legs;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin
            result:=1;

            gubbe.legs:=onr;
            objekt_affect(1,gubbe.legs,legs,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=legs;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

        end;
   Feet:begin
         if config.allowitem[8]=false then begin
          if shout then d(config.textcolor,'I can''t use this type of item!');
         end
         else if gubbe.feet>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,feet,gubbe.feet);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.feet,feet,gubbe,shout_affect);
            j:=gubbe.feet;
            gubbe.feet:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=feet;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.feet,feet,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=feet;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin

            result:=1;

            gubbe.feet:=onr;
            objekt_affect(1,gubbe.feet,feet,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=feet;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

        end;
   Waist:begin
          if config.allowitem[9]=false then begin
           if shout then d(config.textcolor,'I can''t use this type of item!');
          end
          else if gubbe.waist>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,waist,gubbe.waist);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.waist,waist,gubbe,shout_affect);
            j:=gubbe.waist;
            gubbe.waist:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=waist;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.waist,waist,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=waist;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin
            result:=1;
            gubbe.waist:=onr;
            objekt_affect(1,gubbe.waist,waist,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=waist;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;

          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

         end;
   Neck:begin
         if (config.allowitem[10]=false) and (config.allowitem[11]=false) then begin
          if shout then d(config.textcolor,'I can''t use this type of item!');
         end
         else if (gubbe.neck>0) and (config.allowitem[10]=true) then begin
          {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
          load_objekt(objekt2^,neck,gubbe.neck);

          if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

           result:=2;

           if shout then begin
            shout_it(gubbe);
           end;

           if mail_inform=true then begin
            inform_by_mail(location,objekt^,objekt2^,2,gubbe);
           end;

           objekt_affect(2,gubbe.neck,neck,gubbe,shout_affect);
           j:=gubbe.neck;
           gubbe.neck:=onr;
           if i>0 then begin
            if shout then back_pack(gubbe,objekt2^);
            gubbe.item[i]:=j;
            gubbe.itemtype[i]:=neck;
           end
           else begin
            stuffit2:=true;
           end;
           objekt_affect(1,gubbe.neck,neck,gubbe,shout_affect);
          end
          else begin
           {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
           if i>0 then begin
            if shout then back_pack(gubbe,objekt^);
            gubbe.item[i]:=onr;
            gubbe.itemtype[i]:=neck;
           end
           else begin
            stuffit1:=true;
           end;
          end;
         end
         else if (gubbe.neck2>0) and (config.allowitem[11]=true) then begin
          {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
          load_objekt(objekt2^,neck,gubbe.neck2);

          if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

           result:=2;

           if shout then begin
            shout_it(gubbe);
           end;

           if mail_inform=true then begin
            inform_by_mail(location,objekt^,objekt2^,2,gubbe);
           end;

           objekt_affect(2,gubbe.neck2,neck,gubbe,shout_affect);
           j:=gubbe.neck2;
           gubbe.neck2:=onr;
           if i>0 then begin
            if shout then back_pack(gubbe,objekt2^);
            gubbe.item[i]:=j;
            gubbe.itemtype[i]:=neck;
           end
           else begin
            stuffit2:=true;
           end;
           objekt_affect(1,gubbe.neck2,neck,gubbe,shout_affect);
          end
          else begin
           {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
           if i>0 then begin
            if shout then back_pack(gubbe,objekt^);
            gubbe.item[i]:=onr;
            gubbe.itemtype[i]:=neck;
           end
           else begin
            stuffit1:=true;
           end;
          end;
         end
         else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                     om plagget „r ok.}
          if objekt_test2(gubbe,objekt^)=true then begin
           result:=1;
           if (gubbe.neck=0) and (config.allowitem[10]=true) then begin
            gubbe.neck:=onr;
            objekt_affect(1,gubbe.neck,neck,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else if (gubbe.neck2=0) and (config.allowitem[11]=true) then begin
            gubbe.neck2:=onr;
            objekt_affect(1,gubbe.neck2,neck,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
           end
          end
          else begin
           {„r det inte ok kan man iaf stoppa det i ryggs„cken}
           if i>0 then begin
            gubbe.item[i]:=onr;
            gubbe.itemtype[i]:=neck;
            if shout then back_pack(gubbe,objekt^);
           end
           else begin
            stuffit1:=true;
           end;
          end;
         end;
        {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
         if (stuffit1) or (stuffit2) then begin
          if stuffit2 then objekt^:=objekt2^;
          stuff_item(gubbe,shout,onr,objekt^);
         end;

        end;
   Face:begin
         if config.allowitem[12]=false then begin
          if shout then d(config.textcolor,'I can''t use this type of item!');
         end
         else if gubbe.face>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,face,gubbe.face);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.face,face,gubbe,shout_affect);
            j:=gubbe.face;
            gubbe.face:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=face;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.face,face,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=face;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin

            result:=1;

            gubbe.face:=onr;
            objekt_affect(1,gubbe.face,face,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=face;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;
         {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

        end;
   Shield:begin
           if config.allowitem[13]=false then begin
            if shout then d(config.textcolor,'I can''t use this type of item!');
           end
           else if gubbe.shield>0 then begin
           {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
           load_objekt(objekt2^,shield,gubbe.shield);

           if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

            result:=2;

            if shout then begin
             shout_it(gubbe);
            end;

            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,2,gubbe);
            end;

            objekt_affect(2,gubbe.shield,shield,gubbe,shout_affect);
            j:=gubbe.shield;
            gubbe.shield:=onr;
            if i>0 then begin
             if shout then back_pack(gubbe,objekt2^);
             gubbe.item[i]:=j;
             gubbe.itemtype[i]:=shield;
            end
            else begin
             stuffit2:=true;
            end;
            objekt_affect(1,gubbe.shield,shield,gubbe,shout_affect);
           end
           else begin
            {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             if shout then back_pack(gubbe,objekt^);
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=shield;
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end
          else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
           if objekt_test2(gubbe,objekt^)=true then begin
            result:=1;
            gubbe.shield:=onr;
            objekt_affect(1,gubbe.shield,shield,gubbe,shout_affect);
            if shout then begin
             shout_it2(gubbe);
            end;
            if mail_inform=true then begin
             inform_by_mail(location,objekt^,objekt2^,1,gubbe);
            end;

           end
           else begin
            {„r det inte ok kan man iaf stoppa det i ryggs„cken}
            if i>0 then begin
             gubbe.item[i]:=onr;
             gubbe.itemtype[i]:=shield;
             if shout then back_pack(gubbe,objekt^);
            end
            else begin
             stuffit1:=true;
            end;
           end;
          end;
          {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
          if (stuffit1) or (stuffit2) then begin
           if stuffit2 then objekt^:=objekt2^;
           stuff_item(gubbe,shout,onr,objekt^);
          end;

          end;
   Fingers:begin
            if (config.allowitem[5]=false) and (config.allowitem[6]=false) then begin
             if shout then d(config.textcolor,'I can''t use this type of item!');
            end
            else if (gubbe.lfinger=0) and (config.allowitem[5]=true) then begin
             {kolla om plagget „r ok.}
             if objekt_test2(gubbe,objekt^)=true then begin
              gubbe.lfinger:=onr;
              objekt_affect(1,gubbe.lfinger,fingers,gubbe,shout_affect);
              if shout then begin
               shout_it2(gubbe);
              end;
             end
             else begin
              {„r det inte ok kan man iaf stoppa det i ryggs„cken}
              if i>0 then begin
               gubbe.item[i]:=onr;
               gubbe.itemtype[i]:=fingers;
               if shout then back_pack(gubbe,objekt^);
              end
              else begin
               stuffit1:=true;
              end;
             end;
            end
            else if (gubbe.rfinger=0) and (config.allowitem[6]=true) then begin
             {h”gra fingret „r tomt, put it there?}
             {kolla om plagget „r ok.}
             if objekt_test2(gubbe,objekt^)=true then begin
              gubbe.rfinger:=onr;
              objekt_affect(1,gubbe.rfinger,fingers,gubbe,shout_affect);
              if shout then begin
               shout_it2(gubbe);
              end;
             end
             else begin
              {„r det inte ok kan man iaf stoppa det i ryggs„cken}
              if i>0 then begin
               gubbe.item[i]:=onr;
               gubbe.itemtype[i]:=fingers;
               if shout then back_pack(gubbe,objekt^);
              end
              else begin
               stuffit1:=true;
              end;
             end;
            end
            else begin
             {inget finger var ledigt. kollar om n†got av de befintliga
              kan ers„ttas med det nya..}

             if (gubbe.lfinger>0) and (config.allowitem[5]=true) then begin
              {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
              load_objekt(objekt2^,fingers,gubbe.lfinger);

              if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

               result:=2;

               if shout then begin
                shout_it(gubbe);
               end;

               if mail_inform=true then begin
                inform_by_mail(location,objekt^,objekt2^,2,gubbe);
               end;

               objekt_affect(2,gubbe.lfinger,fingers,gubbe,shout_affect);
               j:=gubbe.lfinger;
               gubbe.lfinger:=onr;
               if i>0 then begin
                if shout then back_pack(gubbe,objekt2^);
                gubbe.item[i]:=j;
                gubbe.itemtype[i]:=fingers;
               end
               else begin
                stuffit2:=true;
               end;
               objekt_affect(1,gubbe.lfinger,fingers,gubbe,shout_affect);
              end;
             end
             else if (gubbe.rfinger>0) and (config.allowitem[6]=true) then begin
              {testa om nya prylen „r b„ttre „n h”gra ringen}
              load_objekt(objekt2^,fingers,gubbe.rfinger);

              if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

               result:=2;

               if shout then begin
                shout_it(gubbe);
               end;

               if mail_inform=true then begin
                inform_by_mail(location,objekt^,objekt2^,2,gubbe);
               end;

               objekt_affect(2,gubbe.rfinger,fingers,gubbe,shout_affect);
               j:=gubbe.rfinger;
               gubbe.rfinger:=onr;
               if i>0 then begin
                if shout then back_pack(gubbe,objekt2^);
                gubbe.item[i]:=j;
                gubbe.itemtype[i]:=fingers;
               end
               else begin
                stuffit2:=true;
               end;
               objekt_affect(1,gubbe.rfinger,fingers,gubbe,shout_affect);
              end;
             end;
            end;

            {item f†r inte plats, kolla om n†git i ryggs„cken kan ers„ttas}
            if (stuffit1) or (stuffit2) then begin
             if stuffit2 then objekt^:=objekt2^;
             stuff_item(gubbe,shout,onr,objekt^);
            end;

          end;
   Weapon:begin
           if gubbe.rhand>0 then begin
            {gubbe har redan objekt, kollar om nya prylen „r b„ttre}
            load_objekt(objekt2^,weapon,gubbe.rhand);

            if objekt_test('W',gubbe,objekt2^,objekt^)=true then begin

             result:=2;

             if shout then begin
              shout_it(gubbe);
             end;

             if mail_inform=true then begin
              inform_by_mail(location,objekt^,objekt2^,2,gubbe);
             end;

             objekt_affect(2,gubbe.rhand,weapon,gubbe,shout_affect);
             j:=gubbe.rhand;
             gubbe.rhand:=onr;
             if i>0 then begin
              if shout then back_pack(gubbe,objekt2^);
              gubbe.item[i]:=j;
              gubbe.itemtype[i]:=weapon;
             end
             else begin
              stuffit2:=true;
             end;
             objekt_affect(1,gubbe.rhand,weapon,gubbe,shout_affect);
            end
            else begin
             {„r det inte ok att byta kan man iaf stoppa det i ryggs„cken}
             if i>0 then begin
              if shout then back_pack(gubbe,objekt^);
              gubbe.item[i]:=onr;
              gubbe.itemtype[i]:=weapon;
             end
             else begin
              stuffit1:=true;
             end;
            end;
           end
           else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                      om plagget „r ok.}
            if objekt_test2(gubbe,objekt^)=true then begin
             result:=1;
             gubbe.rhand:=onr;
             objekt_affect(1,gubbe.rhand,weapon,gubbe,shout_affect);

             if shout then begin
              shout_it2(gubbe);
             end;

             if mail_inform=true then begin
              inform_by_mail(location,objekt^,objekt2^,1,gubbe);
             end;

            end
            else begin
             {„r det inte ok kan man iaf stoppa det i ryggs„cken}
             if i>0 then begin
              gubbe.item[i]:=onr;
              gubbe.itemtype[i]:=weapon;
              if shout then back_pack(gubbe,objekt^);
             end
             else begin
              stuffit1:=true;
             end;
            end;
           end;

           {item f†r inte plats, kolla om n†got i ryggs„cken kan ers„ttas}
           if (stuffit1) or (stuffit2) then begin
            if stuffit2 then objekt^:=objekt2^;
            stuff_item(gubbe,shout,onr,objekt^);
           end;

          end;
  end;


 end
 else begin {Reinventory (rescan whole backpack}

 for i:=1 to global_maxitem do begin
  if gubbe.item[i]>0 then begin
    load_objekt(objekt^,gubbe.itemtype[i],gubbe.item[i]);

    case objekt^.ttype of
     Weapon:
      begin
       if gubbe.rhand>0 then begin
        {gubbe har redan n†got i right hand, is†fall : „r prylen „r b„ttre?}
        load_objekt(objekt2^,weapon,gubbe.rhand);

        if objekt_test('W',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.rhand,weapon,gubbe,shout_affect);
         j:=gubbe.rhand;
         gubbe.rhand:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=weapon;
         objekt_affect(1,gubbe.rhand,weapon,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                   om plagget „r ok.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.rhand:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.rhand,weapon,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

       if gubbe.item[i]>0 then begin
        {gubbe har inte tagit grejen i sin h”gra hand. Kanske v„nster d†?}
        if gubbe.lhand>0 then begin
         {gubbe har redan n†got i right hand, is†fall : „r prylen „r b„ttre?}
         load_objekt(objekt2^,weapon,gubbe.lhand);

         if objekt_test('W',gubbe,objekt2^,objekt^)=true then begin

          result:=2;

          if shout then begin
           shout_it(gubbe);
          end;

          if mail_inform=true then begin
           inform_by_mail(location,objekt^,objekt2^,2,gubbe);
          end;

          objekt_affect(2,gubbe.lhand,weapon,gubbe,shout_affect);
          j:=gubbe.lhand;
          gubbe.lhand:=gubbe.item[i];
          gubbe.item[i]:=j;
          gubbe.itemtype[i]:=weapon;
          objekt_affect(1,gubbe.lhand,weapon,gubbe,shout_affect);
         end;
        end
        else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                    om plagget „r ok.}
         if objekt_test2(gubbe,objekt^)=true then begin
          result:=1;
          gubbe.lhand:=gubbe.item[i];
          gubbe.item[i]:=0;
          objekt_affect(1,gubbe.lhand,weapon,gubbe,shout_affect);

          if shout then begin
           shout_it2(gubbe);
          end;

          if mail_inform=true then begin
           inform_by_mail(location,objekt^,objekt2^,1,gubbe);
          end;

         end;
        end;

       end;

      end;
     Head:
      begin
       if gubbe.head>0 then begin
        {gubbe har redan en huvudbonad, kollar om inventory prylen „r b„ttre}
        load_objekt(objekt2^,head,gubbe.head);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.head,head,gubbe,shout_affect);
         j:=gubbe.head;
         gubbe.head:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=Head;
         objekt_affect(1,gubbe.head,head,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. F†r kolla
                   om plagget „r ok.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.head:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.head,head,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Body:
      begin
       if gubbe.body>0 then begin
        load_objekt(objekt2^,body,gubbe.body);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.body,body,gubbe,shout_affect);
         j:=gubbe.body;
         gubbe.body:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=body;
         objekt_affect(1,gubbe.body,body,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.body:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.body,body,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Arms:
      begin
       if gubbe.arms>0 then begin
        load_objekt(objekt2^,arms,gubbe.arms);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.arms,arms,gubbe,shout_affect);
         j:=gubbe.arms;
         gubbe.arms:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=arms;
         objekt_affect(1,gubbe.arms,arms,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.arms:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.arms,arms,gubbe,shout_affect);

         if shout then begin
          shout_it2(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Hands:
      begin
       if gubbe.hands>0 then begin
        load_objekt(objekt2^,hands,gubbe.hands);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.hands,hands,gubbe,shout_affect);
         j:=gubbe.hands;
         gubbe.hands:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=hands;
         objekt_affect(1,gubbe.hands,hands,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.hands:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.hands,hands,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Fingers:
      begin
       if gubbe.lfinger>0 then begin
        load_objekt(objekt2^,fingers,gubbe.lfinger);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.lfinger,fingers,gubbe,shout_affect);
         j:=gubbe.lfinger;
         gubbe.lfinger:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=fingers;
         objekt_affect(1,gubbe.lfinger,fingers,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.lfinger:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.lfinger,fingers,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

       if gubbe.item[i]>0 then begin
        if gubbe.rfinger>0 then begin
         load_objekt(objekt2^,fingers,gubbe.rfinger);

         if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

          result:=2;

          if shout then begin
           shout_it(gubbe);
          end;

          if mail_inform=true then begin
           inform_by_mail(location,objekt^,objekt2^,2,gubbe);
          end;

          objekt_affect(2,gubbe.rfinger,fingers,gubbe,shout_affect);
          j:=gubbe.rfinger;
          gubbe.rfinger:=gubbe.item[i];
          gubbe.item[i]:=j;
          gubbe.itemtype[i]:=fingers;
          objekt_affect(1,gubbe.rfinger,fingers,gubbe,shout_affect);
         end;
        end
        else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
         if objekt_test2(gubbe,objekt^)=true then begin
          result:=1;
          gubbe.rfinger:=gubbe.item[i];
          gubbe.item[i]:=0;
          objekt_affect(1,gubbe.rfinger,fingers,gubbe,shout_affect);

          if shout then begin
           shout_it2(gubbe);
          end;

          if mail_inform=true then begin
           inform_by_mail(location,objekt^,objekt2^,1,gubbe);
          end;

         end;
        end;

       end;


      end;
     Legs:
      begin
       if gubbe.legs>0 then begin
        load_objekt(objekt2^,legs,gubbe.legs);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.legs,legs,gubbe,shout_affect);
         j:=gubbe.legs;
         gubbe.legs:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=Legs;
         objekt_affect(1,gubbe.legs,legs,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.legs:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.legs,legs,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Feet:
      begin
       if gubbe.feet>0 then begin
        load_objekt(objekt2^,feet,gubbe.feet);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.feet,feet,gubbe,shout_affect);
         j:=gubbe.feet;
         gubbe.feet:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=feet;
         objekt_affect(1,gubbe.feet,feet,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.feet:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.feet,feet,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Waist:
      begin
       if gubbe.waist>0 then begin
        load_objekt(objekt2^,waist,gubbe.waist);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.waist,waist,gubbe,shout_affect);
         j:=gubbe.waist;
         gubbe.waist:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=waist;
         objekt_affect(1,gubbe.waist,waist,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin

         result:=1;

         gubbe.waist:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.waist,waist,gubbe,shout_affect);
         if shout then begin
          shout_it2(gubbe);
         end;
         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Neck:
      begin
       if gubbe.neck>0 then begin
        load_objekt(objekt2^,neck,gubbe.neck);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.neck,neck,gubbe,shout_affect);
         j:=gubbe.neck;
         gubbe.neck:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=neck;
         objekt_affect(1,gubbe.neck,neck,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.neck:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.neck,neck,gubbe,shout_affect);

         if shout then begin
          shout_it2(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Face:
      begin
       if gubbe.face>0 then begin
        load_objekt(objekt2^,face,gubbe.face);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.face,face,gubbe,shout_affect);
         j:=gubbe.face;
         gubbe.face:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=face;
         objekt_affect(1,gubbe.face,face,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.face:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.face,face,gubbe,shout_affect);

         if shout then begin
          shout_it2(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Shield:
      begin
       if gubbe.shield>0 then begin
        load_objekt(objekt2^,shield,gubbe.shield);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.shield,shield,gubbe,shout_affect);
         j:=gubbe.shield;
         gubbe.shield:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=shield;
         objekt_affect(1,gubbe.shield,shield,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin
         result:=1;
         gubbe.shield:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.shield,shield,gubbe,shout_affect);

         if shout then begin
          shout_it2(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
     Food:
      begin
      end;
     Drink:
      begin
      end;
     Abody:
      begin
       if gubbe.abody>0 then begin

        load_objekt(objekt2^,abody,gubbe.abody);

        if objekt_test('A',gubbe,objekt2^,objekt^)=true then begin

         result:=2;

         if shout then begin
          shout_it(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,2,gubbe);
         end;

         objekt_affect(2,gubbe.abody,abody,gubbe,shout_affect);
         j:=gubbe.abody;
         gubbe.abody:=gubbe.item[i];
         gubbe.item[i]:=j;
         gubbe.itemtype[i]:=abody;
         objekt_affect(1,gubbe.abody,abody,gubbe,shout_affect);
        end;
       end
       else begin {gubbe har inget p† denna kroppsdel. kolla innan anv„nd.}
        if objekt_test2(gubbe,objekt^)=true then begin

         result:=1;

         gubbe.abody:=gubbe.item[i];
         gubbe.item[i]:=0;
         objekt_affect(1,gubbe.abody,abody,gubbe,shout_affect);

         if shout then begin
          shout_it2(gubbe);
         end;

         if mail_inform=true then begin
          inform_by_mail(location,objekt^,objekt2^,1,gubbe);
         end;

        end;
       end;

      end;
    end;
   end;
  end;
 end;

 {dispose pointer var}
 dispose_vars;

 {return result}
 check_inventory:=result;

end; {Check_inventory *end*}

end. {Unit *end*}
