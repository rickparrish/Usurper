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
Unit Castle; {Usurper - The Kings Castle}

Interface

Procedure The_Castle;

Implementation

Uses Init, Cms, Jakob,
     Statusc, Various2, Prisonc1,
     CrtMage, Rquests, Post_to,
     GenNews, Relation, Various,
     Various3, News, Mail,
     Children, Online, File_IO;

var refresh : boolean;

Procedure Meny;
const offset = 20;
var king : kingrec;
begin

 {load king data}
 load_king(fload,king);

 clearscreen;
 crlf;
 d(11,'<** The Royal Castle **>');

 {damn! i'm a lousy artist: so there is no display of the Castle yet}
 draw_picture('ROYAL_CASTLE');

 crlf;
 d(2,'You have entered the Great Hall. Upon your arrival your are');
 d(2,'immediately surrounded by a flock of servants and advisors.');
 d(2,'You greet your staff with a subtle nod.');
 crlf;
 sd(10,'The Royal Purse'+config.textcol1+' has ');
 sd(14,commastr(king.treasury));
 d(2,' '+many_money(king.treasury)+'.');
 crlf;

 menu2(ljust('(P)rison cells',offset));
 menu2(ljust('(O)rders',offset));
 menu('(1) royal mail');

 menu2(ljust('(G)o to sleep',offset));
 menu2(ljust('(C)heck Security',offset));
 menu('(H)istory of Monarchs');

 menu2(ljust('(A)bdicate',offset));
 menu2(ljust('(M)agic',offset));
 menu('(F)iscal matters');

 menu2(ljust('(S)tatus',offset));
 menu2(ljust('(Q)uests',offset));
 menu('(T)he Royal Orphanage');

 menu('(R)eturn to town');

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
   sd(2,'Royal Castle ('+ulgreen+'?'+ugreen+' for menu) :');
  end
  else begin

   crlf;
   sd(2,'Royal Castle (P,O,Q,C,G,A,M,F,1,H,S,T,R,?) :');
  end;
 end
 else begin
  if (player.expert=false) or (force=true) then begin
   meny;
  end;
 end;

end; {display_menu *end*}

Procedure The_Castle;
Const
      opencol  =15; {color of open establishments}
      closecol =12; {color of closed establishments}
      opentxt  ='OPEN'; {open estab. text}
      closetxt ='closed'; {closed estab. text}

      {moat stuff}
      maxmoatguards =100; {max creatures a king can have in the moat}
var

   k,
   till,
   action,
   offset,
   offset2 : byte;

   ok,
   found,
   search,
   finito,
   accept  : boolean;

   pl0,
   pl1       : ^UserRec; {user records}
   King      : ^KingRec; {king record}
   MoatGuard : ^MoatRec; {moat guard record}
   A_Letter  : ^MailRec; {mail record}

Procedure Disposal; {dispose pointer variables}
begin
 dispose(pl0);
 dispose(pl1);
 dispose(King);
 dispose(MoatGuard);
 dispose(A_Letter);
end; {disposal *end*}

Function Get_Person(const s:s30; var ply:UserRec) : boolean;
var

    i,
    j,
    size : word;

    abort,
    found,
    result : boolean;

begin

 {used by royal_matrimonial proc to search for player S}

 {init}
 abort:=false;
 found:=false;
 result:=false;

 {searching among the humans and NPCs}
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end; {case .end.}

  for j:=1 to size do begin

   {load character}
   if load_character(ply,i,j)=true then begin

    if (findsub(s,ply.name2)) and
       (ply.name2<>player.name2) and
       (ply.king=false) and
       (ply.deleted=false) then begin

     if confirm(uplc+ply.name2+config.textcol1,'N')=true then begin
      found:=true;
      result:=true;
     end
     else begin
      if confirm('Continue search','Y')=false then begin
       abort:=true;
      end;
     end;
    end;
   end;

   if (abort) or (found) then break;
  end; {for j:= .end.}
  if (abort) or (found) then break;
 end; {for i:= .end.}

 {return result}
 get_person:=result;

end; {get_person *end*}

Procedure Royal_Matrimonial;
var
   s : s70;

   ch : char;

   done,
   abort : boolean;

   i,
   j : word;

   x : longint;

   Relation : RelationRec; {relation record}

begin {the king has the authority to dissolve or ban marriage between
       two characters}
 crlf;
 done:=false;
 ch:='?';
 repeat

  if ch='?' then begin
   {ban menu}
   crlf;
   d(5,'Social Order'+config.textcol1+', people don''t know their own good.');
   crlf;
   menu('(U)ndesirable relations');
   menu('(B)an');;
   menu('(D)issolve marriage');
   menu('(A)nnul ban');
   menu('(R)eturn');
   crlf;
  end;

  sd(config.textcolor,'Social Order ('+config.textcol2+'?'+config.textcol1+' for menu):');
  {get user-input}
  ch:=upcase(getchar);
  crlf;

  {evaluate User-input}
  case ch of
   'R':begin {return to castle}
        done:=true;
       end;
   'U':begin {undesirable relations, [list]}
        list_banned_relations;
       end;
   'A':begin {annul [remove] ban}
        crlf;
        crlf;

        d(config.textcolor,'Who would you like set free?');
        sd(config.textcolor,':');

        {get string from user}
        s:=get_string(20);

        abort:=true;
        if get_person(s,pl0^)=true then begin

         {look for the second person}

         crlf;
         d(config.textcolor,'Who is the person with whom '+uplc+pl0^.name2+config.textcol1+' has a relation?');
         sd(config.textcolor,':');

         {get string from user}
         s:=get_string(20);

         if get_person(s,pl1^)=true then begin
          {are they already married?}

          {load relation}
          Social_Relation(pl0^,pl1^,relation);

          if relation.BannedMarry=false then begin
           {not banned}
           crlf;
           d(global_plycol,pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1+' relationship is not '
             +'banned'+config.textcol1+'! (dummy)');
           pause;
          end
          else begin
           {green light to remove ban from this couple!}
           abort:=false;
          end;

         end;

         if not abort then begin
          {let us remove the ban on this relation}

          {display current relation}
          view_one_relation(pl0^.name2,pl1^.name2,true);

          crlf;
          if confirm('Remove '+ulred+'ban'+config.textcol1+' on '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2
                     +config.textcol1+'','Y')=true then begin

           d(15,'Done!');
           d(config.textcolor,'The Church has been instructed to accept this couple.');

           {load relation}
           Social_Relation(pl0^,pl1^,relation);

           {set "banned marriage" flag}
           relation.BannedMarry:=false;

           {save updated relation}
           load_relation(fsave,relation,relation.recnr);

           s:=KingString(player.sex)+' '+ukingc+player.name2+config.textcol1;

           {news-paper}
           Newsy(true,
           'Couple Redeemed from Sin',
           ' '+s+' has forgiven '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1,
           ' for their earlier life of immorality.',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {mail pl0 and pl1 if they are online}
           if is_online(pl0^.name2,online_player)=true then begin
            online_send_to_player(pl0^.name2,online_player,'Your sins with '+uplc+pl1^.name2+config.textcol1+' has been '
             +uyellow+' forgiven'+config.textcol1+'!');
           end;

           if is_online(pl1^.name2,online_player)=true then begin
            online_send_to_player(pl1^.name2,online_player,'Your sins with '+uplc+pl0^.name2+config.textcol1+' has been '+ulred
                                  +' forgiven'+config.textcol1+'!');
           end;

           {mail pl0}
           s:='Forgiven!';
           post(MailSend,
           pl0^.name2,
           pl0^.ai,
           false,
           mailrequest_nothing,
           '',
           uyellow+s+config.textcol1,
           mkstring(length(s),underscore),
           kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' has forgiven the immoral relationship',
           'between you and '+uplc+pl1^.name2+config.textcol1+'!',
           'Try to act decent in the future, or you will be banned forever!',
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

           {mail pl0}
           s:='Forgiven!';
           post(MailSend,
           pl1^.name2,
           pl1^.ai,
           false,
           mailrequest_nothing,
           '',
           uyellow+s+config.textcol1,
           mkstring(length(s),underscore),
           kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' has forgiven the immoral relationship',
           'between you and '+uplc+pl0^.name2+config.textcol1+'!',
           'Try to act decent in the future, or you will be banned forever!',
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

           {pause}
           pause;

          end;

         end;

        end;

       end; {remove ban *end*}
   'B':begin {ban, a relation [not able to marry]}

        {any marital options left today?}
        load_king(fload,king^);

        if king^.MarryActions<1 then begin
         crlf;
         crlf;
         d(12,'You have no marital actions left today.');
         pause;
        end
        else begin
         crlf;
         crlf;
         d(5,'Ban Relation');
         d(config.textcolor,'If you ban a relationship, the persons involved');
         d(config.textcolor,'will not be able to marry.');
         crlf;
         d(config.textcolor,'Who would you like to ban?');
         sd(config.textcolor,':');

         {get string from user}
         s:=get_string(20);

         abort:=true;
         if get_person(s,pl0^)=true then begin
          {look for the second person}

          crlf;
          d(config.textcolor,'Who is the person with whom '+uplc+pl0^.name2+config.textcol1+' has a relation?');
          sd(config.textcolor,':');

          {get string from user}
          s:=get_string(20);

          if get_person(s,pl1^)=true then begin
           if (pl0^.sex=pl1^.sex) and (Config.AllowHomoRelations=false) then begin
            {same sex and Homo not allowed. no need for banning}
            d(config.textcolor,'Why bother, '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2
              +config.textcol1+' can''t marry anyway.');
            pause;
           end
           else begin
            {are they already married?}

            {load relation}
            Social_Relation(pl0^,pl1^,relation);

            if relation.BannedMarry=true then begin
             {already banned}
             crlf;
             d(global_plycol,pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1+' relationship is already '
               +ulred+'banned'+config.textcol1+'!');
             pause;
            end
            else if (Relation.Relation1=global_RelationMarried) and
               (Relation.Relation2=global_RelationMarried) then begin
             crlf;
             d(12,'They are already married! You must dissolve their marriage!');
             pause;
            end
            else begin
             {green light to ban this couple!}
             abort:=false;
            end;
           end;

          end;

          if not abort then begin
           {let us ban the relation between players pl0 and pl1}

           {display current relation}
           view_one_relation(pl0^.name2,pl1^.name2,true);

           crlf;
           if confirm('Forbid '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1
                      +' to marry','Y')=true then begin

            d(15,'Banned!');
            d(config.textcolor,'The Church has been instructed not to accept this couple.');

            {load relation}
            Social_Relation(pl0^,pl1^,relation);

            {set "banned marriage" flag}
            relation.BannedMarry:=true;

            {save updated relation}
            load_relation(fsave,relation,relation.recnr);

            s:=' /'+KingString(player.sex)+' '+ukingc+player.name2+config.textcol1;

            {load king}
            load_king(fload,king^);

            {decrease kings marital actions}
            Dec(king^.MarryActions);

            {save king}
            load_king(fsave,king^);

            {news-paper}
            Newsy(true,
            'Undesirable Couple',
            ' '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1+' have been barred from the Church.',
            ''+s,
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            {mail pl0 and pl1 if they are online}
            if is_online(pl0^.name2,online_player)=true then begin
             online_send_to_player(pl0^.name2,online_player,'Your relation with '+uplc+pl1^.name2+config.textcol1+' has been '
              +ulred+' banned'+config.textcol1+'!');
            end;

            if is_online(pl1^.name2,online_player)=true then begin
             online_send_to_player(pl1^.name2,online_player,'Your relation with '+uplc+pl0^.name2+config.textcol1+' has been '
              +ulred+' banned'+config.textcol1+'!');
            end;

            {mail pl0}
            s:='Banned!';
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+s+config.textcol1,
            mkstring(length(s),underscore),
            kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' has barred you and '+uplc+pl1^.name2,
            'from the Church.',
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

            {mail pl1}
            s:='Banned!';
            post(MailSend,
            pl1^.name2,
            pl1^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+s+config.textcol1,
            mkstring(length(s),underscore),
            kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' has barred you and '+uplc+pl0^.name2,
            'from the Church.',
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

            {pause}
            pause;
           end;

          end;

         end;

        end;

       end; {ban *end*}

   'D':begin {dissolve marriage}

        {any marital options left today?}
        load_king(fload,king^);
        if king^.MarryActions<1 then begin
         crlf;
         crlf;
         d(12,'You have no marital actions left today.');
         pause;
        end
        else begin
         crlf;
         crlf;
         d(5,'Dissolve Marriage');
         d(config.textcolor,'Destryoing a marriage is considered an act of evil.');
         d(config.textcolor,'Your soul will '+ulgray+'darken'+config.textcol1+' and the press will not be merciful.');

         crlf;
         d(config.textcolor,'Whose marriage would you like to abolish?');
         sd(config.textcolor,':');

         {get string from user}
         s:=get_string(20);

         abort:=true;
         if get_person(s,pl0^)=true then begin
          {look for the second person}

          crlf;
          d(config.textcolor,'Who is the person with whom '+uplc+pl0^.name2+config.textcol1+' is married?');
          sd(config.textcolor,':');

          {get string from user}
          s:=get_string(20);

          if get_person(s,pl1^)=true then begin

           {are they married?}

           {load relation}
           Social_Relation(pl0^,pl1^,relation);

           if (Relation.Relation1=global_RelationMarried) and
              (Relation.Relation2=global_RelationMarried) then begin
            {green light to dissolve this marriage!}
            abort:=false;
           end
           else begin
            crlf;
            d(12,'They are not married! (dummy)');
            pause;
           end;

          end;

          if not abort then begin
           {let us dissolve the marriage between players pl0 and pl1}

           {display current relation}
           view_one_relation(pl0^.name2,pl1^.name2,true);

           crlf;
           if confirm('Dissolve the marriage between '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1
                      ,'Y')=true then begin

            {kings darkness increases}
            x:=player.level*15;
            Give_Darkness(player,x);

            d(15,'Dissolved!');
            d(config.textcolor,'The Church has declared the marriage unlawful.');
            d(config.textcolor,'Your soul darkens for '+uwhite+commastr(x)+config.textcol1+' points.');

            {load relation}
            Social_Relation(pl0^,pl1^,relation);

            {set "banned marriage" flag}
            relation.BannedMarry:=true;
            relation.Relation1:=global_relationPassion;
            relation.Relation2:=global_relationPassion;

            {save updated relation}
            load_relation(fsave,relation,relation.recnr);

            s:=' /'+KingString(player.sex)+' '+ukingc+player.name2+config.textcol1;

            {load king}
            load_king(fload,king^);

            {decrease kings marital actions}
            Dec(king^.MarryActions);

            {save king}
            load_king(fsave,king^);

            {news-paper}
            Newsy(true,
            'Abuse of Power',
            ' The marriage between '+uplc+pl0^.name2+config.textcol1+' and '+uplc+pl1^.name2+config.textcol1
            +' has been dissolved.',
            ''+s,
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            {mail pl0 and pl1 if they are online}
            if is_online(pl0^.name2,online_player)=true then begin
             online_send_to_player(pl0^.name2,online_player,'Your marriage to '+uplc+pl1^.name2+config.textcol1+' has been '
              +ulred+' dissolved'+config.textcol1+'!');
            end;

            if is_online(pl1^.name2,online_player)=true then begin
             online_send_to_player(pl1^.name2,online_player,'Your marriage to '+uplc+pl0^.name2+config.textcol1+' has been '
              +ulred+' dissolved'+config.textcol1+'!');
            end;

            {mail pl0}
            s:='Marriage Dissolved!';
            post(MailSend,
            pl0^.name2,
            pl0^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+s+config.textcol1,
            mkstring(length(s),underscore),
            kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' has dissolved your marriage to '+uplc+pl1^.name2
                                  +config.textcol1+'!',
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

            {mail pl1}
            s:='Marriage Dissolved!';
            post(MailSend,
            pl1^.name2,
            pl1^.ai,
            false,
            mailrequest_nothing,
            '',
            ulred+s+config.textcol1,
            mkstring(length(s),underscore),
            kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' has dissolved your marriage to '+uplc+pl0^.name2
                                  +config.textcol1,
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

            {pause}
            pause;
           end;

          end;

         end;

        end;

       end; {dissolove marriage *end*}
  end; {case .end.}

 until done;

end; {Royal_Matrimonial *END*}

Procedure Royal_Orders;
var
  cho : char;
  i : word;
  x : longint;

  s,
  s3,
  s2 : s70;

  orders_done : boolean;

begin
 crlf;
 crlf;

 {load king}
 load_king(fload,king^);

 {entering royal office}
 sd(2,'You enter the ');
 sd(10,'Royal Office');
 d(2,'.');

 orders_done:=false;
 cho:='?';
 repeat

  if cho='?' then begin
   {menu}
   crlf;
   sd(3,'Issue Orders, ');
   sd(10,'The Royal Purse');
   if king^.treasury>0 then begin
    sd(2,' has ');
    sd(14,commastr(king^.treasury));
   d(2,' '+many_money(king^.treasury)+'.');
   end
   else begin
    d(2,' is empty!');
   end;

   menu('(E)stablishments');
   menu('(P)roclamation');
   menu('(M)atrimonial decisions');
   menu('(L)evel-Masters');
   menu('(R)eturn');
   crlf;
  end;

  sd(2,'Orders ('+config.textcol2+'?'+config.textcol1+' for menu):');
  {get user-input}
  cho:=upcase(getchar);
  crlf;

  {evaluate user-input}
  case cho of
   'R':begin {return}
        orders_done:=true;
       end;
   'L':begin {level masters .start.}
        crlf; {jakob, fixa!}
        d(7,'This part is still under construction.');
        crlf;
        pause;
       end; {level masters .end.}
   'M':begin {matrimonial decisions}
        royal_matrimonial;
       end;
   'P':begin {royal proclamation}
        crlf;
        crlf;
        s:='Royal Proclamation';
        d(15,s);
        d(2,cool_string(length(s),'=','-',10,2));

        d(config.textcolor,'Use this option only when you have something really');
        d(config.textcolor,'important to tell your subjects.');


        if confirm('Go ahead','N')=true then begin

         {let user write his letter}
         a_letter^.mess[1]:='';

         {}
         create_letter(a_letter^,
         global_destination,
         player.name2,
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

         if a_letter^.mess[1]<>'' then begin

          {post letter to all subjects}

          for i:=1 to fs(FsPlayer) do begin

           if load_character(pl0^,1,i)=true then begin

            if (pl0^.name2<>player.name2) and
               (pl0^.deleted=false) and
               (pl0^.name2<>global_delname2) then begin

             sd(config.textcolor,'mailing '+uplc+pl0^.name2+config.textcol1+' ...');

             post(MailSend,
             pl0^.name2,
             pl0^.ai,
             false,
             mailrequest_nothing,
             player.name2,
             a_letter^.mess[1],
             a_letter^.mess[2],
             a_letter^.mess[3],
             a_letter^.mess[4],
             a_letter^.mess[5],
             a_letter^.mess[6],
             a_letter^.mess[7],
             a_letter^.mess[8],
             a_letter^.mess[9],
             a_letter^.mess[10],
             a_letter^.mess[11],
             a_letter^.mess[12],
             a_letter^.mess[13],
             a_letter^.mess[14],
             a_letter^.mess[15]);

             {online mess to reciever, only if he is online (of course)}
             if (is_online(pl0^.name2,online_player)) and (pl0^.name2<>player.name2) then begin
              online_send_to_player(pl0^.name2,online_player,uplc+player.name2+config.textcol1+' posted a letter to you.');
             end;
             crlf;
            end;
           end;

          end; {for i:= .end.}

          crlf;
          d(15,'Done your Highness!');

         end;

        end;

       end; {royal proclamation .end.}
   'E':begin {establishments .start.}

        repeat

         offset:=21;
         offset2:=7;
         crlf;
         d(5,'Establishments');

         {load king record}
         load_king(fload,king^);

         {weapon shop}
         sd(13,ljust('1. Weapon Shop',offset));
         if king^.shop_weapon then sd(opencol,ljust(opentxt,offset2))
                              else sd(closecol,ljust(closetxt,offset2));

         {evil mage}
         sd(13,ljust('A. Evil Mage',offset));
         if king^.shop_evilmagic then d(opencol,opentxt)
                                 else d(closecol,closetxt);

         {armor shop}
         sd(13,ljust('2. Armor Shop',offset));
         if king^.shop_armor then sd(opencol,ljust(opentxt,offset2))
                             else sd(closecol,ljust(closetxt,offset2));

         {Bobs Beer}
         sd(13,ljust('B. Bobs Beer',offset));
         if king^.shop_bobs then d(opencol,opentxt)
                            else d(closecol,closetxt);

         {Magic shop}
         sd(13,ljust('3. Magic Shop',offset));
         if king^.shop_magic then sd(opencol,ljust(opentxt,offset2))
                             else sd(closecol,ljust(closetxt,offset2));

         {Whore House}
         sd(13,ljust('C. Whore house',offset));
         if king^.shop_whores then d(opencol,opentxt)
                              else d(closecol,closetxt);

         {Alabats shop}
         sd(13,ljust('4. Alabats Shop',offset));
         if king^.shop_alabat then sd(opencol,ljust(opentxt,offset2))
                              else sd(closecol,ljust(closetxt,offset2));

         {Gigolos place}
         sd(13,ljust('D. Gigolos Nest',offset));
         if king^.shop_gigolos then d(opencol,opentxt)
                               else d(closecol,closetxt);

         {Player Market shop}
         sd(13,ljust('5. Player Market',offset));
         if king^.shop_plmarket then d(opencol,opentxt)
                                else d(closecol,closetxt);

         {Healing Center}
         sd(13,ljust('6. Healing Center',offset));
         if king^.shop_healing then d(opencol,opentxt)
                               else d(closecol,closetxt);

         {Drug Palace}
         sd(13,ljust('7. Drug Palace',offset));
         if king^.shop_drugs then d(opencol,opentxt)
                             else d(closecol,closetxt);

         {Steroid Shop}
         sd(13,ljust('8. Steroid Shop',offset));
         if king^.shop_steroids then d(opencol,opentxt)
                                else d(closecol,closetxt);

         {Orbs Health Club}
         sd(13,ljust('9. Orbs Club',offset));
         if king^.shop_orbs then d(opencol,opentxt)
                            else d(closecol,closetxt);

         d(11,'0. done');
         crlf;

         {Get User-Input}
         repeat
          sd(13,'(? for menu):');
          cho:=upcase(getchar);
          crlf;

          if cho in ['1','2'] then begin
           d(12,'sorry, people must be able to buy their weapon and armor!');
           cho:=' ';
           crlf;
           sd(13,':');
          end
          else if (cho<>'0') and (cho<>' ') and (cho<>'?') and
                  (config.allowcloseshops=false) then begin
           d(12,'Sorry, the System Operator (SYSOP) has ruled that the Shops');
           d(12,'should be open to the public.');
           cho:=' ';
           crlf;
           sd(13,':');
          end;

         until cho in ['0','1','2','3','4','5','6','7','8','9',
                       'A','B','C','D','?'];
         crlf;

         action:=0;

         {not allowed to close shops}
         
         case cho of
          '1':begin
               s3:='Weapon Shop';
               if king^.shop_weapon then begin
                if confirm('Close the '+s3,'N') then begin
                
                 d(3,s3+' is closed!');
                 king^.shop_weapon:=false;
                 action:=1;

                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_weapon:=true;
                 action:=2;
                end;
               end;

              end;
          '2':begin
               s3:='Armor Shop';
               if king^.shop_armor then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_armor:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_armor:=true;
                 action:=2;
                end;
               end;
              end;
          '3':begin
               s3:='Magic Shop';
               if king^.shop_magic then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_magic:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_magic:=true;
                 action:=2;
                end;
               end;
              end;
          '4':begin
               s3:='Alabats Shop';
               if king^.shop_alabat then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_alabat:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_alabat:=true;
                 action:=2;
                end;
               end;
              end;
          '5':begin
               s3:='Player Market';
               if king^.shop_plmarket then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_plmarket:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_plmarket:=true;
                 action:=2;
                end;
               end;
              end;
          '6':begin
               s3:='Healing Center';
               if king^.shop_healing then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_healing:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_healing:=true;
                 action:=2;
                end;
               end;
              end;
          '7':begin
               s3:='Drug Palace';
               if king^.shop_drugs then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_drugs:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_drugs:=true;
                 action:=2;
                end;
               end;
              end;
          '8':begin
               s3:='Steroid Shop';
               if king^.shop_steroids then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_steroids:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_steroids:=true;
                 action:=2;
                end;
               end;
              end;
          '9':begin
               s3:='Orbs Health Club';
               if king^.shop_orbs then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_orbs:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_orbs:=true;
                 action:=2;
                end;
               end;
              end;
          'A':begin
               s3:='Evil Mages Shop';
               if king^.shop_evilmagic then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_evilmagic:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_evilmagic:=true;
                 action:=2;
                end;
               end;
              end;
          'B':begin
               s3:='Bobs Beer';
               if king^.shop_bobs then begin
                if confirm('Close '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_bobs:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_bobs:=true;
                 action:=2;
                end;
               end;
              end;
          'C':begin
               s3:='Whore House';
               if king^.shop_whores then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_whores:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_whores:=true;
                 action:=2;
                end;
               end;
              end;
          'D':begin
               s3:='Gigolos Nest';
               if king^.shop_gigolos then begin
                if confirm('Close the '+s3,'N') then begin
                 d(3,s3+' is closed!');
                 king^.shop_gigolos:=false;
                 action:=1;
                end;
               end
               else begin
                if confirm('Open the '+s3,'N') then begin
                 d(3,s3+' is open again!');
                 king^.shop_gigolos:=true;
                 action:=2;
                end;
               end;
              end;

         end; {case .end.}

         {save king order file}
         if action<>0 then begin
          if player.sex=1 then s:='King'
                          else s:='Queen';

          case action of
           1: s2:='closed';
           2: s2:='opened';
          end; {case .end.}

          {inform other nodes}
          online_send_to_all(ukingc+player.name2+ugreen+' '+s2+' the '+uestabc+s3+ugreen+'!',player.name2,'');

          {news-paper}
          newsy(true,'Royal Decree!',
          ' '+s+ukingc+' '+player.name2+ugreen+' '+s2+' the '+uestabc+s3+ugreen+'!',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

          {save king}
          load_king(fsave,king^);

         end;
        until cho='0';

       end; {establishments .end.}
  end; {case .end.}

 until orders_done;

 {leaving royal office}
 sd(config.textcolor,'You leave the ');
 sd(10,'Royal Office');
 d(config.textcolor,'.');

end; {royal_orders *end*}


Procedure Royal_Orphanage; {The King controls the Royal Orphanage}
var
    ch : char;

    x : longint;
    i : word;
    s : s70;

    done,
    proc_done : boolean;

    cost : longint;

    child : ^childrec;

begin

 {init pointer vars}
 new(child);

 clearscreen;
 crlf;
 crlf;
 proc_done:=false;
 ch:='?';
 repeat

  {menu}
  {d(11,'Royal Treasury holds '+uyellow+commastr(king^.treasury)+ulcyan+' '+many_money(king^.treasury)+'.');
  }

  {update onliner location, if necessary}
  if onliner.location<>onloc_royorphanag then begin
   refresh:=true;
   onliner.location:=onloc_royorphanag;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  if ch='?' then begin
   clearscreen;
   d(config.textcolor,'The '+ulgreen+'Royal Orphanage'+config.textcol1+'.');
   crlf;
   d(config.textcolor,'The nannies are busy taking care of the children.');
   crlf;
   menu('(O)rphants and foster-children residing here.');
   menu('(L)ist all children in the realm.');
   menu('(F)eed the wolves.');
   menu('(P)ut a child in the Orphanage.');
   menu('(K)ick child from Orphanage!');
   menu('(E)xpenses');
   menu('(R)eturn');
   crlf;
  end;
  sd(config.textcolor,'Royal Orphanage ('+config.textcol2+'?'+config.textcol1+' for menu) :');

  {get user-input}
  ch:=upcase(getchar);
  crlf;

  {evaluate user-input}
  case ch of
   'R':begin {return}
        proc_done:=true;
       end;
   'L':begin {list of children in the realm}
        crlf;
        crlf;
        children_in_realm('','',true,true);
        crlf;
       end;

   'K':begin {kick child from orphanage}
        crlf;

        d(config.textcolor,'Who must be kicked out?');
        sd(config.textcolor,':');

        s:=get_string(20);
        done:=false;
        {searching among the children}
        for i:=1 to fs(fschildren) do begin

         if load_child(fload,child^,i)=true then begin

          if (findsub(s,child^.name)) and
             (child^.deleted=false) and
             (child^.named=true) and
             (child^.location=ChildLocation_Orphanage) then begin

           {perhaps this child has nowhere to go...both parents could be
            dead...or the child could be rejected}

           if confirm(ukidc+child^.name+config.textcol1+' ('+sex7[child^.sex]+' to '+uplc+child^.mother+config.textcol1+' and '
              +uplc+child^.father+config.textcol1+')','N')=true then begin

            {d(7,'Evil Deed');
            show_usurper_data(picture_DEATH_HEAD,false);
            }

            d(15,'Ok. '+ukidc+child^.name+config.textcol1+' has been sent home to '+sex3[child^.sex]+' parents!');
            crlf;

            {update child}
            child^.location:=childlocation_Home;
            load_child(fsave,child^,child^.recnr);

            {inform parents}
            inform_parents_online(child^,ukidc+child^.name+config.textcol1+' was sent home by '+kingstring(player.sex)+uplc
                                  +player.name2+config.textcol1+'!');

            inform_parents(child^,
                           mailrequest_nothing,
                           uyellow+'Child Returns!'+config.textcol1,
                           mkstring(14,underscore),
                           'Your '+sex7[child^.sex]+' '+ukidc+child^.name+config.textcol1+' was sent home from the'+
                                  ' Royal Orphanage',
                           'by '+kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+'!',
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
            'Child returns Home!',
            ' '+ukidc+child^.name+config.textcol1+' was sent home from the Royal Orphanage.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            crlf;
            {give chivalry points}
            pre_chivalry;
            x:=random(15)+5;
            give_chivalry(player,x);

            done:=true;

           end
           else begin
            if confirm('Continue search','Y')=false then begin
             done:=true;
            end;
           end;
          end;
         end;
         if done then break;
        end; {for i:= .end.}

       end;
   'F':begin {let the wolves have a feast}

        {load king}
        load_king(fload,king^);

        {is the King allowed to put children to death?}
        if config.allowfeedingthewolves=0 then begin
         crlf;
         d(12,'Your Sysop has disabled this function.');
         d(12,'You are not allowed to feed the wolves with tasty children');
         pause;
        end
        else if king^.wolffeed<1 then begin
         crlf;
         d(12,'The wolves are not hungry. They sleep.');
         pause;
        end
        else begin

         crlf;

         d(config.textcolor,'Who must die?');
         sd(config.textcolor,':');

         s:=get_string(20);
         done:=false;
         {searching among the children}
         for i:=1 to fs(fschildren) do begin

          load_child(fload,child^,i);

          if (findsub(s,child^.name)) and
             (child^.deleted=false) and
             (child^.named=true) and
             (child^.location=ChildLocation_Orphanage) then begin

           if confirm(ukidc+child^.name+config.textcol1+' ('+sex7[child^.sex]+' to '+uplc+child^.mother+config.textcol1+' and '
              +uplc+child^.father+config.textcol1+')','N')=true then begin

            {evil deed}
            d(7,'Evil Deed');
            show_usurper_data(picture_DEATH_HEAD,false);
            d(15,'Growl! The wolves have a feast on '+ukidc+child^.name+uwhite+'!');
            sd(15,'....this evil deed will be remembered for years to come...');
            crlf;

            {load king}
            load_king(fload,king^);

            {update king record}
            dec(king^.wolffeed);

            {load king}
            load_king(fsave,king^);


            {update child}
            child^.deleted:=true;
            load_child(fsave,child^,child^.recnr);

            {inform parents}
            inform_parents_online(child^,ukidc+child^.name+config.textcol1+' was killed by '+kingstring(player.sex)+uplc
                                 +player.name2+config.textcol1+'!');

            inform_parents(child^,
                          mailrequest_nothing,
                          ulred+'Child Killed!'+config.textcol1,
                          mkstring(13,underscore),
                          'Your '+sex7[child^.sex]+' '+ukidc+child^.name+config.textcol1+' was tossed in a wolf-pit by',
                          'the vicious '+kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+'!',
                          ulgray+'++++R.I.P++++'+config.textcol1,
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

            {inform all nodes}
            online_send_to_all('A child has been murdered in the Royal Orphanage!',player.name2,player.name2);

            {news-paper}
            newsy(true,
            'Orphant Killed!',
            ' The poor orphant '+ukidc+child^.name+config.textcol1+' was tossed to the wolves by the',
            ' evil '+kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+'!',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            if player.sex=1 then s:='King'
                            else s:='Queen';

            {child-birth/death log}
            Generic_News(ChildBirthNews,
             false,
             ugreen+'['+fix_date(todays_date)+'] '+ukidc+child^.name+ugreen+' was killed by the evil '+s+' '+player.name2
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

            crlf;
            {give penalty darkness points}
            pre_darkness;
            x:=random(15)+5;
            give_darkness(player,x);

            done:=true;

           end
           else begin
            if confirm('Continue search','Y')=false then begin
             done:=true;
            end;
           end;
          end;
          if done then break;
         end; {for i:= .end.}

         crlf;
        end;

       end;
   'P':begin {put a in the Orphanage, probably agains the wills of the parents}

        {load king}
        load_king(fload,king^);

        {is king allowed to do this?}
        if config.AllowRoyalAdoption=0 then begin
         crlf;
         d(12,'Your SYSOP has disabled this function.');
         d(12,'You are '+ulred+'NOT'+ulred+' allowed to put children in the Royal Orphange.');
         pause;
        end
        else if king^.royaladoptions<1 then begin
         crlf;
         d(12,'You have used up your actions for today. Come back tomorrow.');
         pause;
        end
        else begin

         crlf;
         d(config.textcolor,'Who should be put in the Orphanage?');
         sd(config.textcolor,':');

         s:=get_string(20);
         done:=false;
         {searching among the children}
         for i:=1 to fs(fschildren) do begin

          load_child(fload,child^,i);

          if (findsub(s,child^.name)) and
             (child^.deleted=false) and
             (child^.named=true) and
             (child^.location=ChildLocation_Home) then begin

           if confirm(ukidc+child^.name+config.textcol1+' ('+sex7[child^.sex]+' of '+uplc+child^.mother+config.textcol1+' and '
              +uplc+child^.father+config.textcol1+')','N')=true then begin

            if my_child(player,child^) then begin
             {the king is not allowed to put his own children here!}
             d(12,'You Evil Ruler!');
             d(12,'You are not allowed to put your own children in here!');
            end
            else begin

             d(15,'Done Sir!');
             d(config.textcolor,'The Royal Guards have taken the child to your Castle.');
             d(2,ukidc+child^.name+config.textcol1+' has been separated from '+sex3[child^.sex]+' parents!');
             d(2,ukidc+child^.name+config.textcol1+' is now a permanent guest at the '+ulcyan+'Orphanage'
                +config.textcol1+'!');
             crlf;

             {load king}
             load_king(fload,king^);

             {decrease kings adoption actions}
             Dec(king^.RoyalAdoptions);

             {save king}
             load_king(fsave,king^);

             {update child}
             child^.location:=ChildLocation_Orphanage;
             load_child(fsave,child^,child^.recnr);

             {inform parents}
             inform_parents_online(child^,'Your '+sex7[child^.sex]+' has been sent to the Royal Orphanage!');

             inform_parents(child^,
             mailrequest_nothing,
             ulred+'Royal Abduction'+config.textcol1,
             mkstring(15,underscore),
             'Your '+sex7[child^.sex]+' '+ukidc+child^.name+config.textcol1+' has been transfered to the Royal Orphanage.',
             kingstring(player.sex)+' '+ukingc+player.name2+config.textcol1+' made this happen.',
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
             'Child separated from Parents!',
             ' '+ukidc+child^.name+config.textcol1+' ('+sex7[child^.sex]+' to '+uplc+child^.mother+config.textcol1+' and '
               +uplc+child^.father+config.textcol1+') was sent',
             ' to the '+ulcyan+'Royal Orphanage'+config.textcol1+' on direct orders from '+kingstring(player.sex)+uplc+' '
               +player.name2+config.textcol1+'.',
             '',
             '',
             '',
             '',
             '',
             '',
             '');

             done:=true;
            end;

           end
           else begin
            if confirm('Continue search','Y')=false then begin
             done:=true;
            end;
           end;

          end;

          if done then break;

         end; {for i:= .end.}

        end;
       end; {Put child in royal orphange .end.}

   'E':begin {expenses, grand total cost for feeding the children here}
        crlf;
        cost:=5500; {5500 is also delcared in relation.pas}
        d(config.textcolor,'The Orphanage expanditures amounts to '+uyellow+commastr(numbers_in_orphanage*cost)
          +config.textcol1+' '+many_money(numbers_in_orphanage*cost)+'.');
        crlf;

       end;
   'O':begin {orphants staying here}
        crlf;
        crlf;
        children_in_orphanage;
        crlf;
       end;
  end; {case .end.}

 until proc_done;

 {dispose of pointer vars}
 dispose(child);

 crlf;
 crlf;

end; {royal_orphanage *END*}

Procedure Treasury_Transactions; {take or give gold - royal treasury}
var
   cho : char;

   done,
   abort,
   detected : boolean;

   s : s70;

   pause_counter : byte;

   j,
   size,
   counter : word;

   i,
   x : longint;

begin

 clearscreen;
 crlf;
 crlf;
 d(config.textcolor,'You enter the '+ulgreen+'Royal Treasury'+config.textcol1+'.');

 done:=false;
 cho:='?';
 repeat

  {load king data}
  load_king(fload,king^);

  if king^.tax<1 then begin
   s:=' (no tax set!)';
  end
  else begin
   case king^.taxalignment of
    0: s:=' (current tax is '+commastr(king^.tax)+'%, all)';
    1: s:=' (current tax is '+commastr(king^.tax)+'%, good characters only)';
    2: s:=' (current tax is '+commastr(king^.tax)+'%, evil characters only)';
   end;
  end;

  {menu}
  if cho='?' then begin
   clearscreen;
   crlf;
   crlf;
   d(11,'The Royal Treasury'+config.textcol1+' holds '+uyellow+commastr(king^.treasury)+config.textcol1+' '
        +many_money(king^.treasury)+'.');
   crlf;
   menu('(T)axes'+s);
   menu('(S)et tax privileges.');
   menu('(A)dd your own '+config.moneytype+' to the Treasury (good).');
   menu('(W)ithdraw '+config.moneytype+' from the Treasury to your personal account (bad).');
   menu('(R)eturn');
   crlf;
  end;

  sd(2,'Treasury ('+config.textcol2+'?'+config.textcol1+' for menu) :');

  {get user-input}
  cho:=upcase(getchar);
  crlf;

  {evaluate user-input}
  case cho of
   'S':begin {special tax privileges}
        cho:='?';
        repeat

         if cho='?' then begin
          clearscreen;
          crlf;
          crlf;
          d(10,'Special Tax Menu');
          crlf;
          menu('(L)ist people relieved from taxes');
          menu('(A)dd character to list');
          menu('(D)elete character from list');
          menu('(T)ax refund!');
          menu('(R)eturn');
          crlf;
         end;

         sd(config.textcolor,'Special Taxes ('+config.textcol2+'?'+config.textcol1+' for menu) :');

         {get user-input}
         cho:=upcase(getchar);
         crlf;

         {evaluate user-input}
         case cho of
          'D':begin {deleted player from "list of tax benefactors"}
               crlf;
               crlf;
               d(config.textcolor,'Whos benefits should be withdrawn?');

               if Select_Character(pl0^,false)=false then begin
                d(12,'Aborted.');
               end
               else begin

                if pl0^.tax_relief=false then begin
                 d(12,pl0^.name2+' doesn''t enjoy any tax-privileges.');
                 pause;
                 crlf;
                end
                else begin
                 crlf;
                 crlf;
                 d(14,'*** Royal Decision ***');
                 d(config.textcolor,'You have revoked '+uplc+pl0^.name2+config.textcol1+' tax privileges!');
                 sd(config.textcolor,'Informing '+uplc+pl0^.name2+config.textcol1+'...');

                 {update player}
                 pl0^.tax_relief:=false;
                 user_save(pl0^);

                 if is_online(pl0^.name2,online_player)=true then begin
                  online_send_to_player(pl0^.name2,online_player,broadcast_TaxReinstate);
                 end;

                 {mail subject}
                 s:='Royal Taxes!';
                 post(MailSend,
                 pl0^.name2,
                 pl0^.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 ulred+s+config.textcol1,
                 mkstring(length(s),underscore),
                 kingstring(player.sex)+' '+uplc+player.name2+config.textcol1+' decided you unworthy of any Tax Privileges!',
                 'You should be grateful contributing to maintaining a prosperous Realm.',
                 'Paying taxes is a privilege in itself.',
                 'Long Live the '+kingstring(player.sex)+'!',
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
                 online_send_to_all(uplc+pl0^.name2+config.textcol1+' no longer enjoys Tax Freedom!',player.name2,
                                    pl0^.name2);

                 {news-paper}
                 newsy(true,
                 'Privilege Revoked',
                 ' '+uplc+pl0^.name2+config.textcol1+' is no longer relieved from Royal Taxes!',
                 ' '+kingstring(player.sex)+' '+uplc+player.name2+config.textcol1+' revoked '+uplc+pl0^.name2+'s'
                    +config.textcol1+' privileges.',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '');
                 crlf;
                end;
               end;
               crlf;

              end;
          'A':begin {relief player from taxes}
               crlf;
               crlf;
               d(config.textcolor,'Who should be honored with tax-relief?');

               if Select_Character(pl0^,false)=false then begin
                d(12,'Aborted.');
               end
               else begin

                if pl0^.tax_relief=true then begin
                 d(12,pl0^.name2+' already enjoys tax relaxation!');
                 pause;
                 crlf;
                end
                else begin
                 crlf;
                 crlf;
                 d(14,'*** Royal Decision ***');
                 d(config.textcolor,'You have relieved '+uplc+pl0^.name2+config.textcol1+' from the Royal Tax!');
                 sd(config.textcolor,'Informing '+uplc+pl0^.name2+config.textcol1+'...');

                 {update player}
                 pl0^.tax_relief:=true;
                 user_save(pl0^);

                 if is_online(pl0^.name2,online_player)=true then begin
                  online_send_to_player(pl0^.name2,online_player,broadcast_TaxRelieved);
                 end;

                 {mail subject}
                 s:='Free from Royal Tax!';
                 post(MailSend,
                 pl0^.name2,
                 pl0^.ai,
                 false,
                 mailrequest_nothing,
                 '',
                 uyellow+s+config.textcol1,
                 mkstring(length(s),underscore),
                 kingstring(player.sex)+' '+uplc+player.name2+config.textcol1+' decided you worthy of Tax Relief!',
                 'You should feel very grateful, being one of a few chosen ones.',
                 'Long Live the '+kingstring(player.sex)+'!',
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
                 online_send_to_all(uplc+pl0^.name2+config.textcol1+' has been relieved from Royal Tax!',player.name2,
                                    pl0^.name2);

                 {news-paper}
                 newsy(true,
                 'Special Treatment',
                 ' '+uplc+pl0^.name2+config.textcol1+' was relieved from the Royal Tax!',
                 ' '+uplc+pl0^.name2+config.textcol1+' has a special place in '+kingstring(player.sex)+' '+uplc+player.name2
                    +config.textcol1+' heart.',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '',
                 '');

                 crlf;
                end;
               end;
               crlf;

              end;
          'L':begin {list people relieved from taxes}

               load_king(fload,king^);
               if king^.tax=0 then begin
                crlf;
                d(12,'The Royal Tax is set to 0 for everybody!');
                pause;
                crlf;
               end
               else begin
                crlf;
                s:='Subjects relieved from Royal Taxes';
                d(11,s);
                d(2,cool_string(length(s),'=','-',5,10));

                counter:=0;
                pause_counter:=0;
                abort:=false;
                for i:=1 to 1 do begin {obs!! jakob skit npcs not included
                                        since they don't pay taxes.}

                 case i of
                  1: size:=fs(FsPlayer);
                  2: size:=fs(FsNpc);
                 end; {case .end.}

                 for j:=1 to size do begin

                  if load_character(pl0^,i,j)=true then begin

                   if (pl0^.tax_relief=true) and
                      (pl0^.name2<>player.name2) and
                      (pl0^.king=false) and
                      (pl0^.deleted=false) and
                      (pl0^.name1<>global_delname1) and
                      (pl0^.name2<>global_delname2) then begin

                    {#counter#}
                    inc(counter);
                    inc(pause_counter);

                    s:=commastr(counter);
                    case length(s) of
                     1: s:=s+' ';
                     2: s:=s+' ';
                     3: s:=s+' ';
                    end; {case .end.}
                    sd(7,s);

                    {name}
                    sd(global_plycol,pl0^.name2+config.textcol1);

                    {pause listing?}
                    if pause_counter>global_screenlines-2 then begin
                     pause_counter:=0;
                     if confirm('Continue','Y')=false then begin
                      abort:=true;
                     end;
                    end;

                   end;
                  end;
                  if abort then break;
                 end; {for j:= .end.}
                 if abort then break;
                end; {for i:= .end.}

                if counter=0 then begin
                 crlf;
                 d(12,'Nobody benefits from tax relaxation.');
                end;
                crlf;

               end;

              end;
         end; {case .end.}

        until cho='R';

        cho:=' ';
       end;
   'T':begin {set taxes}
        crlf;
        d(13,'Taxes are deducted from Players Bank Accounts every day.');
        d(13,'You can set the tax to be for GOOD, EVIL or ALL characters.');
        crlf;
        sd(2,'Set tax (0-5%) :');
        x:=get_number(0,5);

        {New Tax}
        if x<>king^.tax then begin

         if x>0 then begin
          d(2,'Tax alignment');
          menu('(A)ll must pay');
          menu('(G)ood characters must pay');
          menu('(E)vil characters must pay');
          menu('(0) abort');
          sd(2,':');

          repeat
           cho:=upcase(getchar);
          until cho in ['A','G','E','0'];

         end
         else begin
          cho:='A';
          d(2,'You have removed the Royal Tax!');
         end;

         if cho<>'0' then begin
          case cho of {set tax alignment}
           'A': king^.taxalignment:=0; {all must pay}
           'G': king^.taxalignment:=1; {only good must pay}
           'E': king^.taxalignment:=2; {only evil must pay}
          end; {case .end.}

          {news}
          s:=KingString(player.sex);

          if x=0 then begin
           {news-paper}
           newsy(true,'Royal Tax',
           ' '+s+ukingc+' '+player.name2+ugreen+uwhite+' removed'+ugreen+' the '+ulgreen+'Royal Tax!'+ugreen,
           ' The people are happy!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

          end
          else if x>king^.tax then begin

           {news-paper}
           newsy(true,'Royal Tax',
           ' '+s+ukingc+' '+player.name2+ugreen+ulred+' raised'+ugreen+' the '+ulgreen+'Royal Tax'+ugreen+
           ' to '+commastr(x)+'% !',
           ' The people are not happy!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');
          end
          else if x<king^.tax then begin

           {news-paper}
           newsy(true,'Royal Tax',
           ' '+s+ukingc+' '+player.name2+uwhite+' lowered'+ugreen+' the '+ulgreen+'Royal Tax to '+ugreen
              +commastr(x)+'% !',
           ' The people are pleased.',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

          end;

          {update king taxes}
          king^.tax:=x;

          {save king}
          load_king(fsave,king^);

          d(8,'New Tax set.');
          d(12,'You let the Herald proclaim the new tax to the people.');


         end; {if cho<>'0' .end.}

        end;

       end; {taxes .end.}
   'A':begin {Add money to the Treasury, from personal funds}
   if player.gold<=0 then begin
    crlf;
    crlf;
    d(12,'You have no '+config.moneytype+'!');
 end
 else begin
        crlf;
        crlf;
        d(2,'Your personal funds amount to '+uyellow+commastr(player.gold)+ugreen+'.');
        d(2,'How much would you like to donate to the '+ulgreen+'Royal Treasury'+ugreen+'?');
        sd(2,':');

        {get value}
        x:=get_number(0,player.gold);

        if x>0 then begin
         if confirm('Donate '+uyellow+commastr(x)+ugreen+' '+many_money(x),'Y')=true then begin

          {update king record}
          load_king(fload,king^);
          if IncKingTreasury2(king^,x)=true then begin
           DecPlayerMoney(player,x);
           load_king(fsave,king^);


           case random(4) of
            0: s:='celebrating';
            1: s:='content';
            2: s:='happy';
            3: s:='satisfied';
           end;

           {news-paper}
           Newsy(true,
           'Royal Donator',
           ' '+kingstring(player.sex)+' '+ukingc+player.name2+ugreen+' donated '+uyellow+commastr(x)+ugreen
              +' '+many_money(x)+' to the Royal Treasury!',
           ' The People are '+s+'!',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

           {tell other nodes}
           online_send_to_all(uplc+player.name2+ugreen+' donated to the Royal Treasury from '+sex3[player.sex]
                                 +' own purse.',player.name2,'');

           d(15,'The People rejoice!');
           pause;
          end
          else begin
            d(12,'They Royal Purse can not accept such an amount!');
            pause;
          end;
end;
         end;
        end;

       end;
   'W':begin {Transfer from Treasury to Personal account (stealing)}

        {load king}
        load_king(fload,king^);
 if king^.treasury<=0 then begin
  crlf;
  crlf;
  d(12,'The treasury is empty!');
 end
else begin
        crlf;
        crlf;
        d(2,'You decide to put your hand in the cookie-jar.');
        crlf;
        d(2,'The '+ulgreen+'Royal Treasury'+ugreen+' has '+uyellow+commastr(king^.treasury)+ugreen+' '
            +many_money(king^.treasury)+'.');
        crlf;

        d(2,'How much will you take for yourself?');
        sd(2,':');

        {get value}
        x:=get_number(0,king^.treasury);

        if x>0 then begin

         {should it leak to the Press?}
         detected:=false;
         i:=random(2);
         if i=0 then detected:=true;

         if detected then begin
          {news-leak}
          d(15,'Oops! It leaked to the Press!');

          case random(7) of
           0: s:='upset';
           1: s:='angry';
           2: s:='discontent';
           3: s:='outraged';
           4: s:='talking about revolution';
           5: s:='in a state of uproar';
           6: s:='protesting';
          end;

          {news-paper}
          Newsy(true,
          'Royal Embezzler',
          ' '+kingstring(player.sex)+' '+ukingc+player.name2+ugreen+' transfered a considerable amount of '+config.moneytype,
          ' from the Royal Treasury to '+sex3[player.sex]+' personal account!',
          ' The people are '+s+'!',
          '',
          '',
          '',
          '',
          '',
          '');

          {tell other nodes}
          online_send_to_all(uplc+player.name2+ugreen+' transfered public funds to '+sex3[player.sex]
                             +' own account!',player.name2,'');

         end;

         {transfer the money}
         load_king(fload,king^);

         if king^.treasury>=x then begin

          if detected=false then begin
           d(2,'You manage to get away with this little transaction without being noticed!');
          end
          else begin
           d(2,'You carry away with the '+config.moneytype+'...');
           d(2,'Hopefully there wont be any strong reaction from the people.');
          end;

          DecKingTreasury(king^,x);
          load_king(fsave,king^);
          IncPlayerMoney(player,x);

          pause;

         end
         else begin
          d(12,'Something went wrong! You were unable to get the '+config.moneytype+'!');
         end;
end;
        end;

       end;
   'R':begin {return}
        done:=true;
       end;
  end; {case .end.}

 until done;

end; {treasury_transactions *END*}

Procedure List_Of_Creatures; {List of MOAT CREATURES}
const headline = '#  Creature                    Cost';
var
    i : word;
    y : longint;
    pc : byte; {pause counter}

begin

 y:=0;
 pc:=1;
 d(5,headline);
 for i:=1 to fs(FsMoat) do begin

  {load moat creature}
  load_moat(fload,moatguard^,i);

  if (moatguard^.Id<>'') and
     (moatguard^.deleted=false) and
     (moatguard^.name<>'') then begin

   {counter}
   inc(y);

   {#}
   sd(15,ljust(commastr(y)+'.',3));

   {name}
   sd(global_moncol,ljust(moatguard^.Name,20));

   {cost}
   sd(14,rjust(commastr(moatguard^.Cost),12));

   crlf;

   {should we pause?}
   if pc>global_screenlines-2 then begin
    pc:=0;
    if confirm('Continue','Y')=false then begin
     break;
    end;
   end;

  end;

 end; {for i:= .end.}

end; {List_of_Creatures *end*}


var

 cho : char;

 s,
 s2 : s70;

 j,
 size : word;

 i,
 x,
 y,
 cost,
 money : longint;


 done : boolean;

begin {THE_CASTLE, MAIN PROC **START**}

 {init pointer vars}
 new(pl0);
 new(pl1);
 new(King);
 new(MoatGuard);
 new(A_Letter);

 if global_auto_probe=Slottet then begin
  global_auto_probe:=NoWhere;
  d(15,'Good Morning Your highness!');
  d(2,'You are lying in the Royal Bed. Another day awaits...');
  pause;
 end;

 repeat

  {update onliner location, if necessary}
  if onliner.location<>onloc_castle then begin
   refresh:=true;
   onliner.location:=onloc_castle;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

 { if player.ear=1 then begin
   who_is_here;
  end;}

  case global_auto_probe of
   NoWhere:begin
            display_menu(true,true);
            cho:=upcase(getchar);
           end;
  end;

  case cho of
   '?':begin {display menu}
        if player.expert=true then display_menu(true,false)
                              else display_menu(false,false);
       end;
   'S':begin {status}
        status(player);
       end;
   'T':begin {the royal orphanage}
        royal_orphanage;
       end;
   'F':begin {fiscal transactions, manipulating the peoples gold!}
        treasury_transactions;
       end;
   'H':begin {History of Monarchs}
        crlf;
        crlf;
        d(11,'List of Monarchs');
        crlf;
        if global_ansi then display_file(global_MonarchsANSI)
                       else display_file(global_MonarchsASCI);
        crlf;
        pause;
       end;
   'M':begin {magic .start.}
        crlf;
        court_magician;
       end;
   '1':begin {mail scan .start.}
        crlf;

        crlf;
        d(12,'Let''s see if Your Majesty has any important mail pending...');

        onliner.location:=onloc_royalmail;
        onliner.doing   :=location_desc(onliner.location);
        add_onliner(OUpdateLocation,onliner);

        {lets read our mail}
        read_my_mail(player);

       end;  {mail scan .end.}
   'C':begin {check security .start.}

        {royal war chamber}
        {Update player location & doing}
        onliner.location:=onloc_warchamber;
        onliner.doing   :=location_desc(onliner.location);
        add_onliner(OUpdateLocation,onliner);

        {load king}
        load_king(fload,king^);

        {warn user if moatfile does not exist!}
        if (f_exists(global_moatfile)=false) or (fs(fsmoat)=0) then begin
         crlf;
         d(12,'Alert! Sysop has not reset the file '+uwhite+global_moatfile+ulred+'!');
         d(12,'(the Moat file)');
         d(12,'Please inform him/her.');
         pause;
        end;

        cho:='?';
        repeat

         if cho='?' then begin
          crlf;
          crlf;
          d(12,'Royal Security');
          d(7,mkstring(14,underscore));

          {moat}
          menu2('(M)oat (');
          if king^.moatnr=0 then begin
           d(2,' nothing)');
          end
          else begin

           {lets see if moat creatures with ID is still active in the database}
           if king^.MoatID<>'' then begin

            found:=false;
            for i:=1 to fs(FsMoat) do begin
             load_moat(fload,moatguard^,i);

             if (moatguard^.Id=king^.moatID) and
                (moatguard^.deleted=false) and
                (moatguard^.name<>'') then begin
              found:=true;
              break;
             end;

            end; {for i:= .end.}

            if found then begin
             sd(15,commastr(king^.moatnr));
             d(2,' '+moatguard^.name+')');
            end;

           end;
          end;

          d(2,'   ---');
          {body-guards}
          menu('(G)uards');
          menu('(H)ire guard');
          menu('(S)ack guard');

          {abort}
          menu('(R)eturn');
          crlf;

         end;

         sd(config.textcolor,'Royal Security ('+config.textcol2+'?'+config.textcol1+' for menu) :');

         {get user-input}
         cho:=upcase(getchar);
         crlf;

         {evaluate user-input}
         case cho of
          'S':begin {sack guard}
               load_king(fload,king^);

               crlf;
               d(2,'Who must be SACKED?');
               sd(2,':');

               s:=get_string(20);
               s:=upcasestr(s);

               k:=0;
               for i:=1 to global_kingguards do begin
                if (findsub(s,king^.guard[i])) and (king^.guard[i]<>'') then begin
                 sd(global_plycol,king^.guard[i]);
                 if confirm('','n')=true then begin
                  k:=i;
                  break;
                 end
                 else begin
                  if confirm('Continue search ','Y')=false then begin
                   break;
                  end;
                 end;
                end;
               end; {for i:= .end.}

               if k>0 then begin
                sd(global_plycol,king^.guard[k]);
                d(2,' has been sacked!');

                if king^.guardai[k]='H' then begin
                 if is_online(king^.guard[k],online_player) then begin
                  online_send_to_player(king^.guard[k],online_player,broadcast_YouAreSacked);
                 end;

                 {mail the poor player who was sacked}
                 post(MailSend,
                 king^.guard[k],
                 king^.guardai[k],
                 false,
                 mailrequest_nothing,
                 '',
                 ulred+'SACKED'+ugreen,
                 mkstring(6,underscore),
                 uplc+player.name2+ugreen+' SACKED you from your job as '+ulcyan+'Royal Guard'+ugreen+'.',
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

                {send news to all + news paper}
                online_send_to_all(uplc+king^.guard[k]+ugreen+' was SACKED from the Royal Guard!',player.name2,king^.guard[k]);

                case random(4) of
                 0: s:=utalkc+' This isn''t fair!  '+uplc+king^.guard[k]+ugreen+' cries.';
                 1: s:=uplc+' '+king^.guard[k]+ugreen+' was not pleased with the decision.';
                 2: s:=uplc+' '+king^.guard[k]+ugreen+' hates '+uplc+player.name2+'s'+ugreen+' guts!';
                 3: s:=uplc+' '+king^.guard[k]+ugreen+' was furious when '+sex2[king^.guardsex[k]]+' found out!';
                end;

                {news-paper}
                Newsy(true,
                'Royal Dismissal',
                ' '+uplc+king^.guard[k]+ugreen+' was fired from '+sex3[king^.guardsex[k]]+' job as '+ulcyan
                   +'Royal Guard'+ugreen+'!',
                s,
                '',
                '',
                '',
                '',
                '',
                '',
                '');

                {init guard fields}
                king^.guard[k]:=emptystr;
                king^.guardpay[k]:=0;

                {update king record}
                load_king(fsave,king^);

               end;

              end; {sack guard *end*}

          'H':begin {recruit personal guard}

               {load king record}
               load_king(fload,king^);

               {are there any vacancies?}
               x:=0;
               for i:=1 to global_kingguards do begin
                if king^.guard[i]<>'' then begin
                 inc(x);
                end;
               end; {for i:= .end.}

               if x>=global_kingguards then begin
                d(12,'But your Highness! You already have the maximum number of');
                d(12,'guards!');
               end
               else begin
                crlf;
                d(2,'Who would you like to make an offer?');
                sd(2,':');

                s:=get_string(20);
                s:=upcasestr(s);

                search:=false;
                finito:=false;

                {searching among the humans and NPCs}
                for i:=1 to 2 do begin

                 case i of
                  1: size:=fs(FsPlayer);
                  2: size:=fs(FsNpc);
                 end;

                 if search then break;

                 for j:=1 to size do begin

                  if finito then begin
                   break;
                  end;

                  {load character}
                  if load_character(pl0^,i,j)=true then begin

                   if (findsub(s,pl0^.name2)) and
                      (pl0^.name2<>player.name2) and
                      (pl0^.name2<>global_delname2) and
                      (pl0^.deleted=false) then begin

                    if confirm(uplc+pl0^.name2+ugreen,'n')=true then begin

                     {first we must check that the player/NPC not already is a guard!}
                     ok:=true;
                     load_king(fload,king^);
                     for k:=1 to global_kingguards do begin
                      if king^.guard[k]=pl0^.name2 then begin
                       d(12,pl0^.name2+' is already in the Guard Force (stupid!)');
                       pause;
                       ok:=false;
                       break;
                      end;
                     end; {for k:= .end.}

                     if ok then begin

                      crlf;
                      s:='Character Profile';
                      d(7,s);
                      d(5,mkstring(length(s),underscore));

                      player_profile(player,pl0^);
                      pause;
                      {offer as daily salary}
                      crlf;
                      sd(2,'OK. And what daily salary do you offer ');
                      sd(global_plycol,pl0^.name2);
                      d(2,'.');

                      d(2,'The salaries are taken from the Royal Treasury.');
                      d(2,'Should you not be able to pay, the guards will be');
                      d(2,'sacked.');
                      crlf;

                      sd(13,'Offer :');
                      sd(14,'');
                      cost:=get_number(0,50000000);

                      sd(2,'Offer ');
                      sd(global_plycol,pl0^.name2+' ');
                      sd(14,commastr(cost));
                      sd(2,' '+many_money(cost)+' to be in your Force');
                      if confirm('','Y')=true then begin
                       {we have found our target}
                       search:=true;
                       break;
                      end;
                     end;

                    end
                    else begin

                     if confirm('Continue search ','Y')=false then begin
                      {abort search}
                      finito:=true;
                      break;
                     end;
                    end;
                   end;
                  end;

                 end; {for j:= .end.}

                end; {for i:= .end.}


                {target found}
                if search then begin
                 case pl0^.ai of
                  'H':begin {human player}

                       post(MailSend,
                       pl0^.name2,
                       pl0^.ai,
                       false,
                       mailrequest_BeMyGuard,
                       player.name2,
                       long2str(cost), {first message line has the salary offer}
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
                       sd(2,'Your Offer has been sent to ');
                       sd(global_plycol,pl0^.name2);
                       d(2,'.');

                       if is_online(pl0^.name2,online_player) then begin
                        online_send_to_player(pl0^.name2,online_player,broadcast_kingWantsYou);
                       end;

                      end; {human player .end.}
                  'C':begin {computer player}

                       {npcs must be bargained with}

                       if is_online(pl0^.name2,online_player) then begin
                        d(12,pl0^.name2+' is busy right now, try again later.');
                       end
                       else if pl0^.hps<1 then begin
                        d(12,pl0^.name2+' is DEAD. try again tomorrow.');
                       end
                       else begin


                        ok:=true;
                        if ok then begin
                         cost:=(pl0^.level*900)+(random(3)*150);

                         sd(global_plycol,pl0^.name2);
                         sd(2,' wants ');
                         sd(14,commastr(cost));
                         d(2,' '+many_money(cost)+' / day.');
                         crlf;

                         if confirm('Accept','Y')=true then begin

                          {check for a free spot}
                          load_king(fload,king^);
                          k:=0;
                          for i:=1 to global_kingguards do begin
                           if king^.guard[i]='' then begin
                            k:=i;
                            break;
                           end;
                          end; {for i:= .end.}

                          if k=0 then begin
                           d(12,'Sorry! Your Guard Force is filled to the brim with soldiers.');
                           d(12,'You must SACK somebody before recruiting a new guard.');
                           pause;
                          end
                          else begin
                           {There IS room for a new guard}

                           king^.guard[k]   :=pl0^.name2; {guard}
                           king^.guardpay[k]:=cost; {salary}
                           king^.guardai[k] :=pl0^.ai; {control/AI}
                           king^.guardsex[k]:=pl0^.sex; {sex}

                           {text}
                           crlf;
                           sd(global_plycol,pl0^.name2);
                           d(2,' kneels before you and swear the Royal Oath.');

                           d(15,'To Protect and Serve is our motto!');
                           d(15,'May the Royal Family never come to any harm.');

                           {save updated king record}
                           load_king(fsave,king^);

                           {send news to all + news paper}
                           case random(2) of
                            0: online_send_to_all(uplc+pl0^.name2+ugreen+' became a Royal Guard!',player.name2,pl0^.name2);
                            1: online_send_to_all(uplc+pl0^.name2+ugreen+' joined the Royal Guard!',player.name2,pl0^.name2);
                           end;

                           case random(9) of
                            0: s:='lovely';
                            1: s:='self-minded';
                            2: s:='good-hearted';
                            3: s:='promising';
                            4: s:='insane';
                            5: s:='charming';
                            6: s:='boastful';
                            7: s:='dark-hearted';
                            8: s:='terrible';
                           end;

                           case random(2) of
                            0:begin
                               Newsy(true,
                               'Royal Employment',
                               ' The '+s+' '+urac+race_display(2,pl0^.race,0)+' '+uplc+pl0^.name2+ugreen+' became a '+ulcyan
                                      +'Royal Guard'+ugreen+'!',
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
                               Newsy(true,
                               'Royal Employment',
                               ' The '+s+' '+urac+race_display(2,pl0^.race,0)+' '+uplc+pl0^.name2+ugreen+' joined the '+ulcyan
                                      +'Royal Guard'+ugreen+'!',
                               '',
                               '',
                               '',
                               '',
                               '',
                               '',
                               '',
                               '');
                              end;

                           end; {case .end. }
                          end;
                         end;
                        end;
                       end;

                      end; {computer player .end.}
                 end; {case .end.}
                end;

               end; {recruit guard .end.}
              end;

          'G':begin {display guards}
               d(7,'Employed Muscle...');

               x:=0;
               for i:=1 to global_KingGuards do begin

                if king^.guard[i]<>'' then begin

                 y:=look_for_alias(king^.guard[i],king^.guardai[i]);

                 if y>0 then begin

                  pl0^.name2:='';

                  if y<=fs(fsplayer) then begin
                   {load from player file}
                   load_character(pl0^,1,y);
                  end;

                  if pl0^.name2<>king^.guard[i] then begin

                   if y<=fs(fsnpc) then begin
                    {lets try load from npc file}
                    load_character(pl0^,2,y);
                   end;

                   if pl0^.name2<>king^.guard[i] then begin
                    {damn! guard does not exist in the player/npc files}
                    y:=0;
                   end;

                  end;

                  if y>0 then begin

                   {inc counter}
                   inc(x);

                   {#}
                   sd(15,commastr(x)+'. ');

                   {name}
                   sd(global_plycol,pl0^.name2);

                   {level}
                   sd(2,' (the level '+commastr(pl0^.level)+' '+race_display(2,pl0^.race,0)+')');

                   {salary}
                   sd(2,'  (salary ');
                   sd(14,commastr(king^.guardpay[i]));
                   sd(2,' '+many_money(king^.guardpay[i])+')');

                   crlf;
                  end;
                 end;
                end;
               end; {for i:= .end.}

               if x=0 then begin
                d(12,'You have no personal guard! THIS IS DANGEROUS!');
               end;

               pause;

              end; {body-guards .end.}

          'M':begin {moat security}

               {check if current moat guards are valid}
               if king^.moatnr>0 then begin
                if Find_MoatID(king^.MoatID)=false then begin
                 {guards not found in database! we remove them now!}
                 king^.moatnr:=0;
                 king^.moatid:='';
                 load_king(fsave,king^);
                end;

               end;

               repeat
                crlf;
                sd(2,'--the--moat--------(');
                if king^.moatnr=0 then begin
                 d(2,'nothing)');
                end
                else begin

                 {lets see if moat creatures with ID is still active in the database}
                 if king^.moatId<>'' then begin

                  found:=false;
                  for i:=1 to fs(FsMoat) do begin
                   load_moat(fload,moatguard^,i);

                   if (moatguard^.Id=king^.moatID) and
                      (moatguard^.deleted=false) and
                      (moatguard^.name<>'') then begin
                    found:=true;
                    break;
                   end;

                  end; {for i:= .end.}

                  if found then begin
                   sd(15,commastr(king^.moatnr));
                   d(2,' '+moatguard^.name+')');
                  end;
                 end;
                end;

                menu('(A)dd moat creature');
                menu('(R)emove moat creature');
                menu('(L)ist available creatures');
                menu('(D)one');
                sd(2,':');


                {get user-input}
                cho:=upcase(getchar);
                crlf;

                case cho of
                 'A':begin {add creature}

                      load_king(fload,king^);

                     
                      {The Moat is empty, we let the King pick a creature}
                      if king^.moatnr=0 then begin

                       repeat
                        d(11,'Select type of creature');

                        {display the creatures}
                        List_Of_Creatures;

                        sd(2,':');

                        {get user-input}
                        x:=get_number(0,y);

                        if x>0 then begin
                         {load correct Moat Creature}
                         j:=0;
                         found:=false;
                         for i:=1 to fs(FsMoat) do begin
                          load_moat(fload,moatguard^,i);

                          if (moatguard^.Id<>'') and
                             (moatguard^.deleted=false) and
                             (moatguard^.name<>'') then begin
                           inc(j);

                           if j=x then begin

                            {display creature description}
                            for k:=1 to 5 do begin
                             if moatguard^.descp[k]<>'' then begin
                              d(2,moatguard^.descp[k]);
                             end;
                            end; {for k:=}

                            {confirm selection}
                            if confirm('Buy some '+umonc+moatguard^.Name+ugreen,'Y')=true then begin
                             found:=true;
                             break;
                            end;

                           end;

                          end;

                         end; {for i:= .end.}
                        end;

                       until (found) or (x=0);

                       if (x>0) and (found=true) then begin

                        {should king use the Royal Treasury or his personal funds}
                        d(2,'What funds will you use?');
                        menu('(I) will use my own funds.');
                        menu('(T)he royal treasury must pay (illegal).');
                        sd(2,':');
                        repeat
                         cho:=upcase(getchar);
                        until cho in ['I','T'];

                        case cho of
                         'I':begin
                              till:=1;
                             end;
                         'T':begin
                              till:=2;


                              {illegal ,the people must know how the king
                               spends the royal funds}
                              case player.sex of
                               1: s:='King';
                               2: s:='Queen';
                              end;

                              case random(2) of
                               0:begin
                                  crlf;
                                  d(15,'(ops! it leaked to the press)');

                                  {news-paper}
                                  Newsy(true,
                                  'Royal Embezzler',
                                  ' '+s+' '+ukingc+player.name2+ugreen+' used the Royal Treasury for '+sex3[player.sex]
                                     +' own personal use.',
                                  ' The People will certainly not accept this kind of misuse much longer.',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '');

                                 end;
                              end; {case random .end.}

                             end;
                        end;

                        {load king}
                        load_king(fload,king^);

                        {Setup Kings New Moat Guards}
                        king^.MoatID:=moatguard^.Id;

                        {how many can the King afford}
                        case till of
                         1: i:=player.gold div moatguard^.Cost;
                         2: i:=king^.treasury div moatguard^.Cost;
                        end;

                        if i>global_maxmon then i:=global_maxmon;

                        sd(11,moatguard^.Name+' cost ');
                        sd(14,commastr(moatguard^.Cost));
                        sd(11,', how many (max ');
                        sd(10,commastr(i));
                        d(11,')');

                        {get user-input}
                        sd(2,':');
                        x:=get_number(0,global_maxmon);

                        if x>0 then begin

                         Cost:=x*moatguard^.Cost;

                         case till of
                          1: money:=player.gold;
                          2: money:=king^.treasury;
                         end;

                         if cost>money then begin
                          d(12,'You can''t afford that!');
                         end
                         else begin
                          if confirm('Buy','Y')=true then begin

                           sd(10,commastr(x));

                           sd(11,' '+moatguard^.Name);

                           king^.moatnr:=x;
                           if king^.moatnr<2 then s:=' is '
                                            else s:=' are ';

                           sd(11,s+'swimming in the moat.');

                           case till of
                            1: decplayermoney(player,cost);
                            2: decKingTreasury(king^,cost);
                           end;

                           load_king(fsave,king^);

                           case player.sex of
                            1: s:='King';
                            2: s:='Queen';
                           end;

                           s2:=umonc+moatguard^.Name+'s'+ugreen;

                           {news-paper}
                           Newsy(true,'Swimming Around',
                           ' '+s+' '+ukingc+player.name2+ugreen+' put some '+s2+' in the moat.',
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

                      end
                      else begin

                       {Add creature to the already invaded moat}

                       if king^.moatnr>=global_maxmon then begin

                        {the moat is full!}
                        Load_MoatId(MoatGuard^,king^.MoatID);

                        s:=moatguard^.Name;

                        d(12,'The moat is full of '+s+'!');
                        pause;

                       end
                       else begin
                        x:=global_maxmon-king^.moatnr;


                        {load correct Moat Guard}
                        Load_MoatId(MoatGuard^,king^.MoatID);

                        s:=moatguard^.Name;
                        cost:=x*moatguard^.Cost;

                        {should king use the Royal Treasury or his personal funds}
                        d(2,'What funds will you use?');
                        menu('(I) will use my own funds.');
                        menu('(T)he royal treasury must pay.');
                        sd(2,':');

                        {get user-input}
                        repeat
                         cho:=upcase(getchar);
                        until cho in ['I','T'];

                        case cho of
                         'I':begin {use own funds}
                              till:=1;
                             end;
                         'T':begin {use the royal treasury}
                              till:=2;
                              case random(2) of
                               0:begin
                                  d(15,'(ops! it leaked to the press)');
                                  Newsy(true,
                                  'Royal Embezzler',
                                  ' '+s+' '+ukingc+player.name2+ugreen+' used the Royal Treasury for '+sex3[player.sex]
                                     +' own personal use.',
                                  ' The People will certainly not accept this kind of misuse much longer.',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '',
                                  '');
                                 end;
                              end; {case random .end.}
                             end;
                        end; {case .end.}

                        load_king(fload,king^);

                        case till of
                         1:begin
                            if player.gold<cost then begin
                             x:=player.gold div moatguard^.Cost;
                            end;
                           end;
                         2:begin
                            if king^.treasury<cost then begin
                             x:=king^.treasury div moatguard^.Cost;
                            end;
                           end;
                        end; {case .end.}

                        sd(11,'You can buy max ');
                        sd(10,commastr(x)+' '+s);
                        d(11,', how many');
                        sd(2,':');

                        i:=get_number(0,x);

                        if i>0 then begin

                         cost:=i*moatguard^.Cost;

                         d(15,'OK.');

                         inc(king^.moatnr,i);

                         case till of
                          1: decplayermoney(player,cost);
                          2: decKingTreasury(king^,cost);
                         end;

                         load_king(fsave,king^);

                         case player.sex of
                          1: s:='King';
                          2: s:='Queen';
                         end;

                         s2:=umonc+moatguard^.Name+'s'+ugreen;

                         {news-paper}
                         Newsy(true,'Swimming Around',
                         ' '+s+' '+ukingc+player.name2+ugreen+' put some '+s2+' in the moat.',
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

                      load_king(fsave,king^);

                     end;
                 'R':begin {remove creature}
                      d(15,'Remove moat creature');
                      if king^.moatnr=0 then begin
                       d(12,'There are no creatures in the moat!');
                      end
                      else begin
                       d(2,'How many creatures should we remove sire? (1-'+commastr(king^.moatnr)+')');
                       sd(2,':');
                       x:=get_number(0,king^.moatnr);

                       if x>0 then begin
                        d(11,commastr(x)+' creature(s) removed.');
                        dec(king^.moatnr,x);
                       end;

                       load_king(fsave,king^);

                      end;
                     end;
                 'L':begin {list of available creatures}
                      crlf;
                      crlf;
                      list_of_creatures;
                      crlf;
                      pause;
                     end;
                end;
               until cho='D'; {until done}
               cho:=' ';

              end;
         end;

        until cho='R'; {until return from Security/War Chamber}
        cho:=' ';

        {save king record / even if changes might not have occurred...I guess that's lazy programming}
        load_king(fsave,king^);

       end;
   'A':begin {Abdicate .start.}
        crlf;
        crlf;
        d(5,'Abdicate!');
        d(12,'Are you mad? Leaving the land without ruler could lead to');
        d(12,'unforeseeable consequences. If you have no successor to the');
        d(12,'throne then you must reconsider!');

        crlf;
        if confirm('Really Abdicate','N') then begin

         {text}
         crlf;
         d(12,'You pack your few personal belongings and leave your Crown');
         d(12,'to the royal treasurer. You dress yourself in simple clothes');
         d(12,'and walk out from the Castle, never to return (?).');

         s:=kingstring(player.sex);

         {news-paper}
         newsy(true,
         'The '+s,
         ' '+s+ukingc+' '+player.name2+ugreen+' has '+ulred+'ABDICATED'+ugreen+'!',
         ' The land is in disarray! Who will claim the Throne?',
         '',
         '',
         '',
         '',
         '',
         '',
         '');

         {general procedure}
         king_is_gone;

         {update player}
         player.king:=false;
         user_save(player);

         {inform royal guards that they have been sacked}
         sack_royal_guards;

         {delete king order file}
         if f_exists(global_kingf) then begin
          delete_file(global_kingf);
         end;

         {kick user from Castle}
         cho:='R';

         {send info to all players}
         online_send_to_all(uplc+player.name2+ugreen+' HAS ABDICATED FROM THE THRONE!',player.name2,'');

         {put the news in the Monarch News-file}
         Generic_News(RoyalNews,
         true,
         ' '+ugreen+s+' '+ukingc+player.name2+ugreen+' abdicated.',
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
         {no abdication today}
         crlf;
         d(15,'Phew! Thank you!');
        end;

       end; {Abdicate .end.}
   'P':begin {Prison START}
        royal_prison;
       end; {Prison END}
   'Q':begin {QUESTS .start.}
        royal_quests;
       end; {QUESTS .end.}
   'O':begin {Orders .start.}
        royal_orders;
       end;  {Order .end.}
   'G':begin {Get Some Sleep .start.}
        crlf;
        crlf;

        d(2,'Taking your rest within the Castle walls can be the difference');
        d(2,'between life or death.');
        crlf;

        if confirm('Take your Royal Rest here','N')=true then begin

         crlf;
         d(2,'You go to sleep in the Royal bed...');
         crlf;

         {set player location to the Castle}
         player.location:=offloc_castle;
         normal_exit;
        end
        else begin
         crlf;
         d(12,'Nah, You are not really tired.');
         crlf;
        end;

       end; {get some sleep .end.}

  end; {case .end.}

 until cho='R';

 {remove temporary pointer variables}
 disposal;
 crlf;

end; {The_Castle *end*}

end. {Unit Castle .end.}
