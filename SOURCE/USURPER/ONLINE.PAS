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


Unit Online; {Usurper - Online file-related (and other) routines}

Interface

Uses Init;

{Used by add_onliners proc to maintain the onliners.dat file}
type OnlineAction = (OAdd,ORemove,ORemoveMe,OUpdateLocation,OUpdateAll);
type ShadowAction = (SAdd,SAddChild,SAddGod,SAddFake,
                     SRemove,SRemoveChild,SRemoveGod,
                     SRemoveFake,SRemoveFakess,SRemoveShadows);

{Maint}
Function Add_Onliner(action:OnlineAction; var player0 : onlinerec) : boolean;
Function Add_Shadow(action:shadowaction;var chimp : userrec; const creator:s30; const doing:s90; const loc:integer) : boolean;

Function Add_Child(action:shadowaction;
                   const child:childrec;
                   const creator:s30;
                   const doing:s90;
                   const location:integer) : boolean;

Procedure Update_Shadow(const shadowname:s30; const doing:s90; dead : boolean);
Procedure Kick_Out_Old_Onliners;

Procedure Node_Check; {performed every X second, as defined in the .CFG}

{send stuff online}
Procedure Send_Stuff_Online(utman : boolean); {trade stuff node-to-node}
{release online prisoner}
Function Online_Release(const target:s30) : boolean;

{send messages}
Procedure Online_Message; {send message to online player}
Procedure Online_Send_To_Player(const target:s30; desttype:onlinetypes;const message:s100);
Procedure Online_Send_To_All (const message:s100; const from:s30; const except:s30);
Procedure Send_to_location(const mess : s100; const from:s30);
Function Tell_Onliner_Compact(const sender:onlinerec;const receiver:s30; const mess:s70):boolean;

{who is here}
Procedure Who_is_Here;
Procedure Who_is_On(override,pausetext:boolean);
Function Anybody_on_Location(location:integer;exclude:s30):boolean;
Function Is_Online(const wanted:s30;desttype:onlinetypes) : boolean;

{online location constants}
Function Location_Desc(const mode:integer) : s70;

Implementation

Uses Dos, DDplus, Cms, InitGods,
     Jakob, Various, Various2,
     Various3, OnTrade, News,
     Mail, OnDuel, File_Io;

Function Online_Release(const target:s30) : boolean;
var
    result : boolean;
    i : word;
    person : onlinerec;

begin

 {online prisoner[target] is being released by online king[player]}

 {init}
 result:=false;

 {lock onlinefile}
 if Lock_OnlineFile(FLock) then begin

  for i:=1 to global_onlinefilesize do begin

   {lock}
   lock_onlinerecord(flock,i);

   {load}
   load_onlinefile(fload,person,i);

   if (person.name=target) and
      (person.usertype=online_player) then begin
    person.bname  :=onliner.name;
    person.com    :=intercom_release;
    person.comfile:=onliner.comfile;
    {save}
    load_onlinefile(fsave,person,i);
    result:=true;
   end;

   {unlock}
   lock_onlinerecord(funlock,i);

   if result=true then begin
    break;
   end;

  end; {for i:= .end.}

  {unlock onlinefile so other nodes can process it}
  Lock_OnlineFile(FUnlock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

 {return result}
 online_release:=result;

end; {online_release *end*}


Function Tell_Onliner(const sender,receiver:onlinerec; const mess:s70; filnr:word) : boolean;
var
    i, j : word;

    ok,
    result: boolean;

    gubbe : onlinerec;

begin {sends a message(chatline) to receiver. see also related routine:
       tell_onliner_compact !!}

 {did message get through}
 result:=false;

 ok:=false;

 {lock onlinefile}
 if Lock_OnlineFile(FLock) then begin

  for i:=1 to global_onlinefilesize do begin

   lock_onlinerecord(flock,i);

   load_onlinefile(fload,gubbe,i);

   if (gubbe.name=receiver.name) and
      (gubbe.usertype=receiver.usertype) and
      (gubbe.ear in [global_ear_all,global_ear_personal]) then begin

    for j:=1 to global_maxnod do begin
     if gubbe.chatline[j]='' then begin
      gubbe.chatline[j]:=mess;
      gubbe.chatsend[j]:=sender.name;

      load_onlinefile(fsave,gubbe,i);
      result:=true;
      ok:=true;
      break;
     end;

    end; {for j:= .end.}

   end;

   {unlock record}
   lock_onlinerecord(funlock,i);

   if ok then begin
    break;
   end;

  end; {for i:= .end.}

  {unlock onlinefile so other nodes can process it}
  Lock_OnlineFile(FUnlock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

 {return result}
 tell_onliner:=result;

end; {Tell_Onliner *end*}

Function Tell_Onliner_Compact(const sender:onlinerec;const receiver:s30; const mess:s70):boolean;
var
    found,
    result : boolean;

    filnr,
    i : word;

    target : onlinerec;

begin {see the related "tell_onliner" routine for details...}

 result:=false;
 found:=false;
 {look for receiver}

 for i:=1 to fs(FsOnline) do begin
  load_onliner(fload,target,i);
  if target.name=receiver then begin
   found:=true;
   filnr:=i;
   break;
  end;
 end; {for i:= .end.}

 if found then begin
  result:=tell_onliner(sender,target,mess,filnr);
 end;

 {return result}
 tell_onliner_compact:=result;

end; {tell_onliner_compact *end*}

Procedure Online_Send_To_All (const message:s100; const from:s30; const except:s30);
{broadcasts a message to ALL online players except persons "FROM" and "EXCEPT"}
var
    i,
    j : word;

    person : onlinerec;

begin

 {lock onlinefile}
 if Lock_OnlineFile(FLock) then begin

  for i:=1 to global_onlinefilesize do begin

   {lock record}
   lock_onlinerecord(flock,i);

   {load}
   load_onlinefile(fload,person,i);

   if (person.name<>from) and
      (person.name<>except) and
      (person.ear=global_ear_all) then begin

    for j:=1 to global_maxnod do begin
     if person.info[j]='' then begin
      person.info[j]:=message;
      person.infosend[j]:=from;
      break;
     end;
    end; {for j:= .end.}

    {save}
    load_onlinefile(fsave,person,i);

   end;

   {unlock}
   lock_onlinerecord(funlock,i);

  end; {for i:= .end.}

  {unlock onlinefile so other nodes can process the file}
  Lock_OnlineFile(FUnLock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

end; {online_send_to_all *end*}

Procedure Send_to_location(const mess : s100; const from:s30);
 {send message to persons on a specific location}
var
    i,
    j : word;

    person : onlinerec;

begin

 {sending letter MESS from PERSON to all persons on the same location
  except player "FROM"}

 {lock onlinefile}
 if Lock_OnlineFile(FLock)=true then begin

  for i:=1 to global_onlinefilesize do begin

   lock_onlinerecord(flock,i);

   load_onlinefile(fload,person,i);

   if (person.name<>'') and
      (person.name<>from) and
      (person.location=onliner.location) then begin

    for j:=1 to global_maxnod do begin
     if person.info[j]='' then begin
      person.info[j]:=mess;
      person.infosend[j]:=from;
      break;
     end;
    end; {for j:= .end.}

    {save online record}
    load_onlinefile(fsave,person,i);

   end;

   lock_onlinerecord(funlock,i);

  end; {for i:= .end.}

  {unlock onlinefile so other nodes can process it}
  Lock_OnlineFile(FUnlock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

end; {Send to location *end*}

Procedure Online_Message; {send message to online player}
var
    i : longint;
    j : integer;

    s, he : s70;

    mem,
    found : boolean;

    gubbe : onlinerec;

const
    ok_to_enter : boolean = true;

begin

 {if (god_active) then begin
  exit;
 end;}

 mem:=global_multi;
 global_multi:=false;

 found:=false;

 if ok_to_enter then begin
  ok_to_enter:=false;

  crlf;
  crlf;
  sd(10,'[');
  sd(11,'Online message');
  d(10,']');

  sd(config.textcolor,'Send to:');
  he:=get_string(30);

  for i:=1 to fs(FsOnline) do begin

   load_onliner(fload,gubbe,i);

   if gubbe.name<>'' then begin
    s:=gubbe.name;

    if (findsub(he,s)=true) and (gubbe.name<>player.name2) then begin
     if confirm(uplc+gubbe.name+config.textcol1,'N')=true then begin
      if gubbe.name=onliner.name then begin
       d(12,'Mail yourself? (fool!)');
       found:=true;
       break;
      end
      else begin
       found:=true;
       if gubbe.ear=global_ear_quiet then begin
        sd(global_plycol,gubbe.name);
        d(config.textcolor,' doesn''t wanna listen to you right now!');
       end
       else if gubbe.location=onloc_MultiChat then begin
        sd(global_plycol,gubbe.name);
        d(config.textcolor,' is in a chat conference right now!');
       end
       else begin
        crlf;

        d(config.textcolor,'Say what [1 line]');
        sd(config.textcolor,':');
        s:=get_string(70);

        if s<>'' then begin

         {load_onliner(fsave,gubbe,i); {saving online record}

         {send message}
         if tell_onliner(onliner,gubbe,s,i)=true then begin
          sd(config.textcolor,'You tell ');
          sd(global_plycol,gubbe.name);
          d(config.textcolor,' :');
          d(global_talkcol,s);

          if player.ear=global_ear_quiet then begin
           d(12,'NOTE! Don''t expect to receive an answer!');
           d(12,'Your current configuration doesn''t allow any other nodes');
           d(12,'to send you messages/information.');
           d(12,'(to change your setup enter your status screen and press "C")');
          end;

         end
         else begin
          sd(12,'The message didn''t get through to ');
          sd(global_plycol,gubbe.name);
          d(12,'.');
         end;

        end
        else begin
         d(15,'Aborted.');
        end;
        break;
       end;
      end;
     end;
    end;
   end;

  end; {for i:= .end.}

  ok_to_enter:=true;
  if not found then begin
   d(15,'What are you babbling about?');
  end;
 end;

 {restore global_multi flag}
 global_multi:=mem;

end; {online_message *end*}

Procedure Online_Send_To_Player;
var
    i, j : integer;
    temp_guy : onlinerec;

begin

 {lock onlinefile}
 if Lock_OnlineFile(FLock)=true then begin

  for i:=1 to global_onlinefilesize do begin

   {lock record}
   lock_onlinerecord(flock,i);

   {load online record}
   load_onlinefile(fload,temp_guy,i);

   if (temp_guy.name=target) and
      (temp_guy.usertype=desttype) and
      (temp_guy.ear=global_ear_all) then begin

    {send/store the message}
    for j:=1 to global_maxnod do begin
     if temp_guy.info[j]='' then begin
      temp_guy.info[j]:=message;
      temp_guy.infosend[j]:=onliner.name;
      break;
     end;
    end; {for j:= .end.}

    {save online record}
    load_onlinefile(fsave,temp_guy,i);

   end;

   {unlock record}
   lock_onlinerecord(funlock,i);

  end; {for i:= .end.}

  {unlock onlinefile so other nodes can process it}
  Lock_OnlineFile(FUnlock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

end; {online send to player *end*}

Function Add_Onliner(action:OnlineAction; var player0 : onlinerec) : boolean;
var
    i,j     : longint;
    size : longint;
    result : boolean;
    memmy   : integer;
    error : integer;
    found,ok : boolean;
    onlinne : onlinerec;
    done    : boolean;
    OnlineFile  : file of OnlineRec;  {** Online record file **}
begin

 {action: OAdd, ORemove, OUpdateLocation, OUpdateAll}
 result:=true;

 if not f_exists(global_onfile) then begin

  i:=0;
  repeat
   ok:=true;
   error:=0;

   assign(onlinefile,global_onfile);
   {$I-}rewrite(onlinefile);{$I+}
   error:=IoResult;
   if error<>0 then begin
    unable_to_create(global_onfile,error);
    delay2(global_lockdelay);
    if f_exists(global_onfile) then begin
     break;
    end;
    ok:=false;
    inc(i);
   end
   else begin
    {$I-}close(onlinefile);{$I+}
    error:=IoResult;
    if error<>0 then unable_to_close(global_onfile,error);
   end;

  until (Ok) or (i>global_locknrs);

 end;

 case action of

  OAdd:begin {add player to online file}

        found:=false;
        ok:=true;

        {lock onlinefile}
        if Lock_OnlineFile(FLock) then begin
         size:=global_onlinefilesize;

         {check to see if player is already logged into another node}
         for i:=1 to size do begin

          load_onlinefile(fload,onlinne,i);

          if onlinne.name=player0.name then begin
           ok:=false;
           result:=false;
           break;
          end;

         end; {for i:= .end.}

         if ok then begin
          for i:=1 to size do begin

           lock_onlinerecord(flock,i);

           load_onlinefile(fload,onlinne,i);

           if (onlinne.name='') and (onlinne.realname='') then begin
            onlinne:=player0;
            onlinne.realname:=player.name1;
            {empty message buffert}
            for j:=1 to global_maxnod do begin
             onlinne.info[j]:=emptystr;
             onlinne.infosend[j]:=emptystr;
            end; {for j:= .end.}
            onlinne.recnr:=i;
            player0.recnr:=i;

            load_onlinefile(fsave,onlinne,i);
            found:=true;
           end;

           lock_onlinerecord(funlock,i);

           if found then begin
            break;
           end;

          end; {for i:= .end.}

         end;

         {unlock onlinefile}
         Lock_OnlineFile(FUnLock);

        end
        else begin

         {we were unable to get a lock on the file}
         unable_to_lockfile(global_onfile);

        end;

        if found=false then begin
         Append_OnlineGuy(player0);
        end;

       end; {Oadd .end.}

  ORemove:begin {remove player from list}

           if lock_onlinefile(FLock)=true then begin

            for i:=1 to global_onlinefilesize do begin

             lock_onlinerecord(flock,i);

             {lock onlinefile}
             load_onlinefile(fload,onlinne,i);

             if onlinne.name=player0.name then begin
              onlinne.name:=emptystr;
              onlinne.realname:=emptystr;
              load_onlinefile(fsave,onlinne,i);
             end;

             lock_onlinerecord(funlock,i);

            end; {for i:= .end.}

            {unlock onlinefile}
            lock_onlinefile(FUnlock);

           end
           else begin
            {we were unable to get a lock on the file}
            unable_to_lockfile(global_onfile);
           end;

          end; {Oremove .end.}
  OUpdateLocation:begin {update player location & doing}

                   {lock}
                   if lock_onlinefile(Flock) then begin

                    {lock record}
                    lock_onlinerecord(flock,player0.recnr);

                    {load}
                    load_onlinefile(fload,onlinne,player0.recnr);

                    {update}
                    onlinne.location:=onliner.location;
                    onlinne.doing:=onliner.doing;
                    onliner:=onlinne;

                    {save}
                    load_onlinefile(fsave,onliner,player0.recnr);

                    {unlock record}
                    lock_onlinerecord(funlock,player0.recnr);

                    {unlock file}
                    lock_onlinefile(FUnlock);
                   end
                   else begin
                    {we were unable to get a lock on the file}
                    unable_to_lockfile(global_onfile);
                   end;

                  end; {OupdateLocation .end.}

  OUpdateAll:begin {update player on list}

              {lock}
              if lock_onlinefile(Flock)=true then begin

               {load}
               load_onlinefile(fload,onlinne,player0.recnr);

               {lock record}
               lock_onlinerecord(flock,player0.recnr);

               {save}
               load_onlinefile(fsave,onliner,player0.recnr);

               {unlock record}
               lock_onlinerecord(funlock,player0.recnr);

               {unlock}
               lock_onlinefile(FUnlock);

              end
              else begin
               {we were unable to get a lock on the file}
               unable_to_lockfile(global_onfile);
              end;

             end; {OupdateAll .end.}
  ORemoveMe:begin {clean up, remove player who is online}

             {lock}
             if lock_onlinefile(FLock)=true then begin

              {lock record}
              lock_onlinerecord(flock,onliner.recnr);

              {load}
              load_onlinefile(fload,onlinne,onliner.recnr);

              {update}
              onlinne.name     :=emptystr;
              onlinne.realname :=emptystr;
              onlinne.doing    :=emptystr;
              onlinne.node     :=emptystr;
              onlinne.arrived  :=emptystr;
              onlinne.fake     :=false;
              onlinne.usertype :=online_player;
              onlinne.initiator:=emptystr;
              onlinne.bname    :=emptystr;
              onlinne.comfile  :=emptystr;
              onlinne.com      :=intercom_empty;
              for j:=1 to global_maxnod do begin
               onlinne.chatline[j]:=emptystr;
               onlinne.chatsend[j]:=emptystr;
               onlinne.info[j]:=emptystr;
               onlinne.infosend[j]:=emptystr;
              end; {for j:= .end.}

              {save}
              load_onlinefile(fsave,onlinne,onliner.recnr);

              {unlock record}
              lock_onlinerecord(funlock,onliner.recnr);

              {unlock}
              lock_onlinefile(FUnlock);
             end
             else begin
              {we were unable to get a lock on the file}
              unable_to_lockfile(global_onfile);
             end;

            end; {ORemoveMe .end.}

 end; {Case action .end.}

 {return result}
 add_onliner:=result;

end; {Add_Onliner *end*}


Function Add_Child(action:shadowaction;
                   const child:childrec;
                   const creator:s30;
                   const doing:s90;
                   const location:integer) : boolean;
var
   result : boolean;
   ply : userrec;
begin
 {tries to put a child online. uses the add_shadow func. to setup a fake
  "userrec"(ply) online}
 {hitler}
 ply:=player;
 ply.name1:='tempchild';
 ply.name2:=child.name;

 {add child}
 case action of
  SAddChild   : result:=add_shadow(SAddChild,ply,creator,doing,location);
  SRemoveChild: result:=add_shadow(SRemoveChild,ply,creator,doing,location);
 end; {case .end.}

 {return result}
 add_child:=result;

end; {add_child *end*}

Function Add_Shadow(action:shadowaction;var chimp : userrec; const creator:s30; const doing:s90; const loc:integer) : boolean;
{shadow players are players/children offline, called to fight/trade by
 online player
 fake players are online as long as the player who created them is online
 ..or if removed earlier}

var
    i,
    j,
    size : word;

    ok,
    found,
    result : boolean;

    usertype : onlinetypes;

    temp,
    shadow : ^onlinerec;

begin

 {init pointer vars}
 new(temp);
 new(shadow);

 {init result var}
 result:=true;

 {this is a bad habit..just to be on the safe side we check the .ear value}
 if (chimp.ear<>global_ear_all) and
    (chimp.ear<>global_ear_personal) and
    (chimp.ear<>global_ear_quiet) then begin
  chimp.ear:=global_ear_all;
 end;

 case action of
  SAdd,SAddChild,SAddGod,
  SAddFake:begin {add "shadowplayer" CHIMP to online list}

        shadow^.name     :=chimp.name2;
        shadow^.realname :=chimp.name1;
        shadow^.race     :=chimp.race;
        if action=SAddFake then shadow^.fake:=true
                           else shadow^.fake:=false;
        shadow^.class    :=chimp.class;
        shadow^.node     :='XXX';
        shadow^.arrived  :=give_me_time;
        case action of
         SAdd     : shadow^.usertype :=online_player;
         SAddChild: shadow^.usertype :=online_child;
         SAddGod  : shadow^.usertype :=online_god;
         SAddFake : shadow^.usertype :=online_fake;
        end; {case .end.}
        shadow^.shadow   :=true;
        shadow^.dead     :=false;
        shadow^.doing    :=doing;
        shadow^.ear      :=chimp.ear;
        shadow^.sex      :=chimp.sex;
        shadow^.initiator:=creator;
        shadow^.bname    :=emptystr;
        shadow^.com      :='!';
        shadow^.comfile  :='no-way';
        shadow^.location :=loc;

        for i:=1 to global_maxnod do begin
         shadow^.chatline[i]:=emptystr;
         shadow^.chatsend[i]:=emptystr;
         shadow^.info[i]:=emptystr;
         shadow^.infosend[i]:=emptystr;
        end; {for i:= .end.}

        {lock online file, so no other node may interfer}
        if lock_onlinefile(FLock)=true then begin

         {size of global_onlinefile}
         size:=global_onlinefilesize;

         {we must first check that SHADOW isn't already online}
         ok:=true;
         found:=false;
         for i:=1 to size do begin

          {load character from onlinefile}
          load_onlinefile(fload,temp^,i);

          {debug}
          {if temp^.name<>'' then begin
           d(15,'Scanning for duplicate Shadows, comparing: '+shadow^.name+' - '+temp^.name);
          end;}

          if (temp^.usertype=shadow^.usertype) and
             (temp^.name=shadow^.name) then begin
           ok:=false;
           result:=false; {unable to add shadow player}
           break;
          end;

         end; {for i:= .end.}

         if ok=true then begin
          found:=false;
          for i:=1 to size do begin

           {lock file record}
           lock_onlinerecord(flock,i);

           load_onlinefile(fload,temp^,i);
           if (temp^.name='') and (temp^.realname='') then begin
            {important! set correct rec #}
            shadow^.recnr:=i;
            {save updated onlinefile}
            load_onlinefile(fsave,shadow^,i);
            found:=true;
           end;

           {unlock file record}
           lock_onlinerecord(funlock,i);

           if found then begin
            break;
           end;

          end; {for i:= .end.}


         end;

         {unlock file}
         lock_onlinefile(FUnlock);

        end
        else begin

         {we were unable to get a lock on the file}
         unable_to_lockfile(global_onfile);

        end;

        if (found=false) and (ok=true) then begin
         Append_OnlineGuy(shadow^);
        end;

       end;

  SRemove,SRemoveChild,SRemoveGod,
    SRemoveFake:begin {remove "shadowplayer" CHIMP from list}
           found:=false;

           {lock file}
           if lock_onlinefile(FLock)=true then begin

            for i:=1 to global_onlinefilesize do begin

             lock_onlinerecord(flock,i);

             load_onlinefile(fload,shadow^,i);

             case action of
              SRemove     :usertype:=online_player;
              SRemoveChild:usertype:=online_child;
              SRemoveGod  :usertype:=online_god;
              SRemoveFake :usertype:=online_fake;
             end; {case .end.}

             if (shadow^.name=chimp.name2) and
                (shadow^.usertype=usertype) then begin

              shadow^.name    :=emptystr;
              shadow^.realname:=emptystr;
              shadow^.node    :=emptystr;
              shadow^.arrived :=emptystr;
              shadow^.usertype:=online_player;
              shadow^.shadow  :=true;
              shadow^.fake    :=false;
              shadow^.ear     :=global_ear_all;
              shadow^.initiator:=emptystr;

              for j:=1 to global_maxnod do shadow^.chatline[j]:=emptystr;
              for j:=1 to global_maxnod do shadow^.chatsend[j]:=emptystr;
              for j:=1 to global_maxnod do shadow^.info[j]:=emptystr;
              for j:=1 to global_maxnod do shadow^.infosend[j]:=emptystr;

              {update record}
              load_onlinefile(fsave,shadow^,i);

              found:=true;
             end;

             {unlock file}
             lock_onlinerecord(funlock,i);

             if found then begin
              break;
             end;

            end; {for i:= .end.}

            lock_onlinefile(FUnlock); {unlock file}

           end
           else begin
            {we were unable to get a lock on the file}
            unable_to_lockfile(global_onfile);
           end;

          end;

  SRemoveFAkess:begin {remove all fake players created by PLAYER}

                {lock file}
                if lock_onlinefile(FLock)=true then begin

                 for i:=1 to global_onlinefilesize do begin
                  lock_onlinerecord(flock,i);

                  load_onlinefile(fload,shadow^,i);

                  if (shadow^.initiator=chimp.name2) and
                     (shadow^.fake=true) and
                     (shadow^.usertype=online_fake) then begin

                   shadow^.name:=emptystr;
                   shadow^.realname:=emptystr;
                   load_onlinefile(fsave,shadow^,i);
                  end;

                  {unlock record}
                  lock_onlinerecord(funlock,i);

                 end; {for i:= .end.}

                 {unlock file}
                 lock_onlinefile(FUnlock);

                end
                else begin
                 {we were unable to get a lock on the file}
                 unable_to_lockfile(global_onfile);
                end;

               end;
  SRemoveShadows:begin {remove all shadows created by PLAYER}

                  {lock file}
                  if lock_onlinefile(FLock)=true then begin

                   for i:=1 to global_onlinefilesize do begin

                    lock_onlinerecord(flock,i);

                    load_onlinefile(fload,shadow^,i);

                    if (shadow^.initiator=chimp.name2) and
                       (shadow^.fake=false) then begin
                     shadow^.name:=emptystr;
                     shadow^.realname:=emptystr;
                     load_onlinefile(fsave,shadow^,i);
                    end;

                    {unlock record}
                    lock_onlinerecord(funlock,i);

                   end; {for i:= .end.}

                   {unlock file}
                   lock_onlinefile(FUnlock);

                  end
                  else begin
                   {we were unable to get a lock on the file}
                   unable_to_lockfile(global_onfile);
                  end;

                 end;
 end; {case .end.}

 {dispose temporary variables}
 dispose(temp);
 dispose(shadow);

 {return result}
 add_shadow:=result;

end; {Add_Shadow *end*}

Procedure Who_is_Here; {who are on a special location in the Game}
var                    {..see cms.pas for location constants}
    i     : longint;

    gubbe : onlinerec;

    j : boolean;

begin

 j:=false;

 for i:=1 to fs(FsOnline) do begin

  {load online character}
  load_onliner(fload,gubbe,i);

  {nota bene! "or " removed below}
  if (gubbe.location=onliner.location) or
     (gubbe.initiator=onliner.name) then begin

   if (gubbe.name<>onliner.name) and (gubbe.name<>'') then begin

    if gubbe.usertype=online_player then begin
     if j=false then begin
      crlf;
      j:=true;
     end;

     if gubbe.dead=true then begin
      sd(12,'the corpse of ');
      sd(global_plycol,gubbe.name);
      d(12,' is laying here');
     end
     else begin
      sd(global_plycol,gubbe.name);
      d(config.textcolor,' the '+classnames[gubbe.class]+' is here');
     end;
    end;

   end;
  end;
 end; {for i:= .end.}

end; {who_is_here *end*}

Procedure Who_is_On; {List of characters online}
var
    s,s1,s2 : s90;
    i       : word;
    justval : integer;
    ply     : onlinerec;
    already : boolean;
    already2: boolean;
    ok      : boolean;

begin

 if (global_multi=false) and (override=false) then begin
  exit;
 end;

 crlf;
 crlf;

 global_multi:=false;
 already:=false;
 already2:=false;

 for i:=1 to fs(fsonline) do begin

  {load onliner}
  load_onliner(fload,ply,i);

  ok:=true;
  if ply.name='' then ok:=false;

  if ok then begin

   if already=false then begin
    already:=true;
    d(14,'** People Online **');
    crlf;
    d(5,'Node    Character             Status                                   Arrived');
   end;

   {node}
   justval:=22;
   if ply.shadow then begin
    sd(11,'Ghost   ');
   end
   else if ply.node=global_onlocal then begin
    sd(11,'Local   ');
   end
   else begin
    sd(11,ply.node+'     ');
   end;

   if ply.shadow=false then begin
    sd(global_plycol,ljust(ply.name,justval));
   end
   else begin
    sd(global_plycol,ljust(ply.name,justval));
   end;

   {doing}
   s:=' ';
   s1:=ply.doing;
   s2:=strip(ply.doing);

   justval:=40;
   if length(s2)>justval then begin
    s1:=copy(s1,1,justval);
   end
   else if length(s2)<justval then begin
    justval:=justval-length(s2);
    s1:=s1+mkstring(justval,' ');
   end;

   sd(config.textcolor,s1);
   {arrived}
   {justval:=8;}
   d(config.textcolor,s+ply.arrived);

  end;
 end; {for i:= .end.}

 crlf;
 if pausetext then begin
  sd(config.textcolor,'Press '+Config.ReturnEnter+' :');
 end;

 global_multi:=true;

end; {Who_is_On *end*}

Function AnyBody_on_Location;
var
    i     : longint;
    gubbe : onlinerec;
    result: boolean;

begin

 result:=false;

 for i:=1 to fs(FsOnline) do begin
  load_onliner(fload,gubbe,i);
  if (gubbe.location=location) and
     (gubbe.name<>exclude) and
     (gubbe.name<>'') then begin
   result:=true;
   break;
  end;
 end; {for i:= .end.}

 {return result}
 anybody_on_location:=result;

end; {anybody_on_location *end*}

Function Is_Online(const wanted : s30; desttype : onlinetypes) : boolean;
{is WANTED online?}
var
    person : onlinerec;
    i : word;
    result : boolean;

begin

 {init}
 result:=false;

 for i:=1 to fs(FsOnline) do begin

  load_onliner(fload,person,i);

  if (person.name=wanted) and
     (person.usertype=desttype) then begin
   result:=true;
   break;

  end;
 end; {for i:= .end.}


 {return result}
 is_online:=result;


end; {is_online *end*}

Procedure Send_Stuff_Online(utman : boolean);
var
    i : longint;
    ch : char;
    s : s90;
    only : ^onlinerec;
    cc : longint;
    found,
    great : boolean;
    abort : boolean;

begin

 {init pointer vars}
 new(only);

 crlf;
 crlf;
 d(config.textcolor,'Who would you like to send stuff to?');
 sd(config.textcolor,':');
 s:=get_string(30);

 found:=false;
 great:=false;
 for i:=1 to fs(FsOnline) do begin

  {load online player}
  load_onliner(fload,only^,i);

  if (findsub(s,only^.name)) and
     (only^.name<>player.name2) and
     (only^.name<>'') then begin

   if confirm(uplc+only^.name+config.textcol1,'n')=true then begin

    found:=true;
    if only^.com<>' ' then begin
     crlf;
     sd(global_plycol,only^.name);
     d(config.textcolor,' is busy and can''t talk to you right now.');
    end
    else if only^.location in [onloc_mainstreet,
                               onloc_bank,
                               onloc_recruit,
                               onloc_church] then begin

     onliner.doing:='talking to '+uplc+only^.name+config.textcol1;
     onliner.com:=intercom_empty;

     if config.semaphore<>'' then begin
      onliner.comfile:=config.semaphore+crypt(8)+'.TMP';
     end
     else begin
      onliner.comfile:=crypt(8)+'.TMP';
     end;

     onliner.bname:=only^.name;
     add_onliner(OUpdateAll,onliner);

     crlf;
     sd(config.textcolor,'You send out a messenger looking for ');
     sd(global_plycol,only^.name);
     sd(config.textcolor,'... (press ');
     sd(config.hotkeycolor,'A');
     sd(config.textcolor,' to abort)');
     great:=true;
     break;
    end
    else begin
     crlf;
     sd(global_plycol,only^.name);
     d(config.textcolor,' is busy and can''t talk to you right now.');

     d(config.textcolor,'Tell '+uplc+only^.name+config.textcol1+' to come to one these locations:');
     d(11,'Mainstreet');
     d(11,'Bank');
     d(11,'Hall of recruitment');
     d(11,'The Church');

    end;
   end;
  end;
 end; {for i:= .end.}

 if great then begin

  {poll only^}
  only^.bname:=onliner.name;
  only^.com:=intercom_sendstuff;
  only^.comfile:=onliner.comfile;
  load_onliner(fsave,only^,i);

  cc:=0;
  abort:=false;
  repeat

   inc(cc);
   node_check;
   delay2(global_online_poll_delay);
   my_timeslice;

   if config.spincursor=true then begin
    spin_cursor(2,config.textcolor);
   end
   else begin
    sd(config.textcolor,'.');
   end;

   if cc>global_online_maxwaits then abort:=true;

   {check if user has pressed A to abort the scan}
   if ukeypressed then begin
    ch:=upcase(getchar);
    if ch='A' then begin
     crlf;
     d(12,'abort.');
     abort:=true;
    end;
   end;

  until (onliner.com in [intercom_accept,intercom_decline]) or (abort);

  if not abort then begin
   crlf;
   if onliner.com=intercom_accept then begin
    sd(global_plycol,only^.name);
    d(config.textcolor,' has arrived!');
    global_multi:=false;
    online_trade(true);
   end
   else if onliner.com=intercom_decline then begin
    sd(global_plycol,only^.name);
    d(15,' is not interested! (how rude!)');
   end
   else begin
    sd(global_plycol,only^.name);
    d(config.textcolor,' didn''t answer your message!');
   end;
  end;

 end
 else if not found then begin
  d(15,'couldn''t locate that character.');
 end;

 {reset online com vars}
 onliner.bname:=emptystr;
 onliner.com:=intercom_empty;
 add_onliner(OUpdateAll,onliner);
 global_multi:=true;

 {dispose pointer var}
 dispose(only);

end; {Stuff Sendo}

Procedure Update_Shadow(const shadowname:s30; const doing:s90; dead:boolean);
var
    i : word;
    temp : onlinerec;
    found : boolean;
begin

 found:=false;
 {lock onlinefile}
 if Lock_OnlineFile(FLock)=true then begin

  for i:=1 to global_onlinefilesize do begin

   {lock record}
   lock_onlinerecord(flock,i);

   {load character}
   load_onlinefile(fload,temp,i);

   if temp.name=shadowname then begin
    if doing<>'' then temp.doing:=doing;
    if dead=true then temp.dead:=true;
    load_onlinefile(fsave,temp,i);
    found:=true;
   end;

   {unlock record}
   lock_onlinerecord(funlock,i);

   if found then begin
    break;
   end;

  end; {for i:= .end.}

  {unlock onlinefile}
  Lock_OnlineFile(FUnlock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

end; {Update Shadow *end*}

Procedure Kick_Out_Old_Onliners;
var
   i : word;
   time_is_up : boolean;

   temp : OnlineRec;

 online_minutes : longint;
 hour, minute, second, sec100: word; {current time}
 ar_hr, ar_mn, ar_sc: word; {players arrival time}
 el_hr, el_mn, el_sc: longint; {elapsed time}

begin {scans the 'onliners.dat' file and deletes players who have
       been online longer than maxtime (defined in usurp.ctl). }

 {get current time}
 gettime(hour, minute, second, sec100);

 {lock onlinefile}
 if Lock_OnlineFile(FLock)=true then begin

  for i:=1 to global_onlinefilesize do begin

   {lock record}
   lock_onlinerecord(flock,i);

   {load character}
   load_onlinefile(fload,temp,i);

   if (temp.name<>emptystr) and (temp.realname<>emptystr) then begin

    {has player been online too long, and should be considered 'overdue' ?}
    time_is_up:=false;
    {converting temp.arrived string value to word variables}
    ar_hr:=str_to_nr(temp.arrived[1]+temp.arrived[2]);
    ar_mn:=str_to_nr(temp.arrived[4]+temp.arrived[5]);
    ar_sc:=str_to_nr(temp.arrived[7]+temp.arrived[8]);

    {elapsed time, ddplus.pas function. result returned in el_hr,el_mn,el_sc}
    elapsed(hour, minute, second, ar_hr, ar_mn, ar_sc, el_hr, el_mn, el_sc);
    {convert elapsed hours to minutes}
    online_minutes:=0;
    if el_hr>0 then online_minutes:=el_hr*60;
    online_minutes:=online_minutes+el_mn;
    if online_minutes>maxtime then begin {maxtime is a ddplus variable}
     time_is_up:=true;
    end;

    if time_is_up=true then begin
     {deactivating online player TEMP}
     wr(12,'Deactivating ');
     wr(14,temp.name);
     wr(12,' from ');
     wrl(15,global_onfile);

     temp.name:=emptystr;
     temp.realname:=emptystr;
     {updating file}
     load_onlinefile(fsave,temp,i);
    end
    else begin
     {should this be displayed?}
     wr(14,temp.name);
     wr(12,' has been online for ');
     wr(15,commastr(online_minutes));
     wr(12,' minutes ('+sex2[temp.sex]+' will be deactivated in ');
     wr(15,commastr(maxtime-online_minutes));
     wrl(12,' minutes).');
    end;

   end;

   {unlock record}
   lock_onlinerecord(funlock,i);

  end; {for i:= .end.}

  {unlock onlinefile}
  Lock_OnlineFile(FUnlock);

 end
 else begin
  {we were unable to get a lock on the file}
  unable_to_lockfile(global_onfile);
 end;

end; {kick_out_old_onliners *end*}

Procedure Give_Me_Exits_From(const caller:onlinerec;
                             var loc1,loc2,loc3,loc4,loc5,loc6,
                                 loc7,loc8,loc9,loc10,loc11,loc12,
                                 loc13,loc14:integer);
const location_exits = 14;
var i : byte;
begin

 {fake players make up their minds where to go based on the info on
  this routine. This routine bases its calcs on callers sex and
   whether the shops are open/closed! (the last one is not done!
   , that is : the shops closed/open signs are ignored by the ghosts)}

 {init}
 loc1:=onloc_closed;
 loc2:=onloc_closed;
 loc3:=onloc_closed;
 loc4:=onloc_closed;
 loc5:=onloc_closed;
 loc6:=onloc_closed;
 loc7:=onloc_closed;
 loc8:=onloc_closed;
 loc9:=onloc_closed;
 loc10:=onloc_closed;
 loc11:=onloc_closed;
 loc12:=onloc_closed;
 loc13:=onloc_closed;
 loc14:=onloc_closed;

 case caller.location of
  onloc_mainstreet:begin {possible exits from mainstreet}
                    loc1:=onloc_theinn;
                    loc2:=onloc_church;
                    loc3:=onloc_darkness;
                    loc4:=onloc_master;
                    loc5:=onloc_magicshop;
                    loc6:=onloc_dungeons;
                    loc7:=onloc_weaponshop;
                    loc8:=onloc_armorshop;
                    loc9:=onloc_bank;
                    loc10:=onloc_marketplace;
                    loc11:=onloc_darkalley;
                    loc12:=onloc_reportroom;
                    loc13:=onloc_healer;
                    loc14:=onloc_anchorroad;
                   end;
  onloc_theinn:begin
                loc1:=onloc_mainstreet;
                loc2:=onloc_teamcorner;
                loc3:=onloc_recruit;
               end;
  onloc_teamcorner:begin
                    loc1:=onloc_theinn;
                   end;
  onloc_recruit:begin
                 loc1:=onloc_theinn;
                end;
  onloc_church:begin
                loc1:=onloc_mainstreet;
               end;
  onloc_darkness:begin
                  loc1:=onloc_mainstreet;
                  loc2:=onloc_outsideinn;
                  if caller.sex=1 then loc3:=onloc_whores
                                  else loc3:=onloc_gigolos;
                 end;
  onloc_master:begin
                loc1:=onloc_mainstreet;
               end;
  onloc_magicshop:begin
                   loc1:=onloc_mainstreet;
                  end;
  onloc_dungeons:begin
                  loc1:=onloc_mainstreet;
                 end;
  onloc_weaponshop:begin
                    loc1:=onloc_mainstreet;
                   end;
  onloc_armorshop:begin
                   loc1:=onloc_mainstreet;
                  end;
  onloc_bank:begin
              loc1:=onloc_mainstreet;
             end;
  onloc_marketplace:begin
                     loc1:=onloc_mainstreet;
                     loc2:=onloc_foodstore;
                     loc3:=onloc_combmaster;
                     loc4:=onloc_beggarswall;
                    end;
  onloc_foodstore:begin
                   loc1:=onloc_marketplace;
                  end;
  onloc_combmaster:begin
                    loc1:=onloc_marketplace;
                   end;
 onloc_beggarswall:begin
                    loc1:=onloc_marketplace;
                   end;
 onloc_darkalley:begin
                  loc1:=onloc_mainstreet;
                  loc2:=onloc_drugs;
                  loc3:=onloc_steroids;
                  loc4:=onloc_orbs;
                  loc5:=onloc_madmage; {groggo}
                  loc6:=onloc_bobsbeer;
                  if caller.class=Alchemist then begin
                   loc7:=onloc_alchemist;
                  end;
                 end;
  onloc_drugs:begin
               loc1:=onloc_darkalley;
              end;
 onloc_steroids:begin
                 loc1:=onloc_darkalley;
                end;
 onloc_whores:begin
               loc1:=onloc_darkness;
              end;
 onloc_gigolos:begin
                loc1:=onloc_darkness;
               end;
 onloc_outsideinn:begin
                   loc1:=onloc_darkness;
                  end;
 onloc_orbs:begin
             loc1:=onloc_darkalley;
            end;
 onloc_madmage:begin
                loc1:=onloc_darkalley;
               end;
 onloc_bobsbeer:begin
                 loc1:=onloc_darkalley;
                end;
 onloc_alchemist:begin
                  loc1:=onloc_darkalley;
                 end;
  onloc_reportroom:begin
                    loc1:=onloc_mainstreet;
                   end;
  onloc_healer:begin
                loc1:=onloc_mainstreet;
               end;
  onloc_anchorroad:begin
                    loc1:=onloc_mainstreet;
                    loc2:=onloc_dormitory;
                    loc3:=onloc_bountyroom;
                    loc4:=onloc_questhall;
                    loc5:=onloc_gangprep;
                    loc6:=onloc_temple;
                    loc7:=onloc_lovestreet;
                    loc8:=onloc_outcastle;
                   end;
  onloc_dormitory:begin
                   loc1:=onloc_anchorroad;
                  end;
  onloc_bountyroom:begin
                    loc1:=onloc_anchorroad;
                   end;
  onloc_questhall:begin
                   loc1:=onloc_anchorroad;
                  end;
  onloc_gangprep:begin
                  loc1:=onloc_anchorroad;
                 end;
  onloc_temple:begin
                loc1:=onloc_anchorroad;
               end;
  onloc_outcastle:begin
                   loc1:=onloc_anchorroad;
                  end;
  onloc_lovestreet:begin
                    loc1:=onloc_anchorroad;
                    loc2:=onloc_giftshop;
                   end;
  onloc_giftshop:begin
                  loc1:=onloc_lovestreet;
                 end;

 end; {case .end.}

 {debug}
 if (loc1=onloc_closed) and
    (loc2=onloc_closed) and
    (loc3=onloc_closed) and
    (loc4=onloc_closed) and
    (loc5=onloc_closed) and
    (loc6=onloc_closed) and
    (loc7=onloc_closed) and
    (loc8=onloc_closed) and
    (loc9=onloc_closed) and
    (loc10=onloc_closed) and
    (loc11=onloc_closed) and
    (loc12=onloc_closed) and
    (loc13=onloc_closed) and
    (loc14=onloc_closed) then begin
  d(15,'Error! No way out from '+uyellow+location_desc(caller.location)+config.textcol1+'!');
 end;

end; {give_me_exits_from *end*}

Procedure Get_Random_Human_Onliner(var target:OnlineRec);
const max_search = 128;
var
    i,j : word;
    get_me_array : array[1..max_search] of word;
    temp : OnlineRec;
begin {returns a random human online player, see "move_fakeplayers" for use}

 {init variables}
 j:=0;
 for i:=1 to max_search do begin
  get_me_array[i]:=0;
 end;

 for i:=1 to fs(FsOnline) do begin

  {load online character}
  if load_onliner(fload,temp,i)=true then begin

   {we only want to find online players who are listening}
   if (temp.usertype=online_player) and {this excludes the gods!}
      (temp.shadow=false) and
      (temp.fake=false) and
      (temp.ear<>global_ear_quiet) and
      (temp.name<>'') then begin
    {debug
    d(15,'Matching Random Human Player : '+temp.name);
    }
    inc(j);
    get_me_array[j]:=i;
    if j=max_search then break;
   end;
  end;
 end; {for i:= .end.}

 {}
 if j>0 then begin
  i:=random(j)+1;
  if load_onliner(fload,target,i)=true then begin

   {debug
   d(15,'Selected Random Human Player : '+target.name);
   }

  end;
 end;

end; {Get_Random_Human_Onliner *end*}

Procedure Move_Fakeplayers; {move/init fake players}
const
      fakename1 = 'fake! *generated by game*';
      location_exits = 14;
var

   i,
   new_location : word;

   j,
   x,
   possible_exits : byte;

   save_needed : boolean;

   loc_array : array [1..location_exits] of integer;
   {exit locations, used when moving the fake players.}

   fakeplayer : ^UserRec;

   faker,
   target : OnlineRec;

begin

 {scan fake players initiated by player}
 if global_fakeplayers>0 then begin
  {load fakeplayers created by player, and make their moves}
  {move/send mess/answer messages}
  for i:=1 to fs(FsOnline) do begin

   {load online character}
   load_onliner(fload,faker,i);

   if (faker.realname=fakename1) and
      (faker.initiator=player.name2) and
      (faker.fake=true) then begin
    save_needed:=false;
    {we have found a fake player created by player}

    {let's answer unread mail}
    {note! we should lock our profile here..so no new mail may enter
     while reading}

    {debug
    d(15,'Processing : '+faker.name);
    }

    for j:=1 to global_maxnod do begin

     if faker.chatline[j]<>'' then begin
      faker.chatline[j]:='';
      save_needed:=true;

      {debug
      d(15,'sending mail reply to '+faker.chatsend[j]+'...');
      }

      {send reply to chatline[j].sender}
      if tell_onliner_compact(faker,faker.chatsend[j],fakeplayer_reply)=true then begin
       {reply got through!}
      end;

     end;
    end; {for j:= .end.}

    {should we send some random mail to a human player?}
    if config.fakeschatty then begin
     if random(30)=0 then begin

      {get a target for our mail}
      get_random_human_onliner(target);

      if tell_onliner_compact(faker,target.name,fakeplayer_new_message(target))=true then begin
       {message got through!}
      end;

     end; {send_random_mail *end}
    end;

    {should we move?}
    if random(7)=0 then begin

     {init locations array}
     for j:=1 to location_exits do begin
      loc_array[j]:=onloc_closed;
     end; {for j:= .end.}

     {set new location for fakeplayer}
     {fetch possible exits from current location}
     give_me_exits_from(faker,
                        loc_array[1],
                        loc_array[2],
                        loc_array[3],
                        loc_array[4],
                        loc_array[5],
                        loc_array[6],
                        loc_array[7],
                        loc_array[8],
                        loc_array[9],
                        loc_array[10],
                        loc_array[11],
                        loc_array[12],
                        loc_array[13],
                        loc_array[14]);

     {count possible exits}
     possible_exits:=0;
     for j:=1 to location_exits do begin
      if loc_array[j]<>onloc_closed then inc(possible_exits);
     end; {for j:= .end.}

     if possible_exits>0 then begin
      repeat
       x:=random(possible_exits)+1;
      until loc_array[x]<>onloc_closed;
      new_location:=loc_array[x];

      {update location}
      faker.location:=new_location;
      faker.doing   :=location_desc(faker.location);
      save_needed:=true;
     end;

    end;

    {save updated fakeplayer record, save only if necessary}
    if save_needed=true then begin
     load_onliner(fsave,faker,i);
    end;

    {fakeplayer leaves the game}
    if random(25)=0 then begin
     new(fakeplayer);
     Fakeplayer^.name2:=faker.name;
     add_shadow(SRemoveFake,FakePlayer^,'','',0);

     {d(15,'Debug: '+fakeplayer^.name2+' has left the building.');
     }

     if config.fakeschatty then begin
      online_send_to_all(broadcast_exitalive,fakeplayer^.name2,'');
     end;

     dispose(fakeplayer);

     {decrease counter}
     dec(global_fakeplayers);

    end;

   end;

  end; {for i:= .end.}

 end;

 {add a fake player?}
 if (global_fakeplayers<config.fakeplayers) and
    (random(3)=0) then begin

  {init pointer vars}
  new(fakeplayer);

  {fill fakeplayer with necessary values that add_shadow proc needs}
  get_fakeplayerdata(fakeplayer^); {name2, sex, race, class}

  if (fakeplayer^.name2<>'') and (fakeplayer^.sex in [1,2]) then begin
   fakeplayer^.name1:=fakename1;

   if add_shadow(SAddFake,fakeplayer^,player.name2,location_desc(onloc_mainstreet),onloc_mainstreet)=false then begin
    {failed!}
   end
   else begin

    {inform other nodes of fakeplayers entry}
    if config.fakeschatty then begin
     online_send_to_all(broadcast_MortalEnteredGame,fakeplayer^.name2,'');
    end;

    {increase counter}
    inc(global_fakeplayers);

   end;
  end;

  {dispose pointer vars}
  dispose(fakeplayer);

 end;

end; {move_fakeplayers *end*}

Procedure Node_Check; {Check if there is any incoming information
                       to process}
const
      already : boolean = true;

      {text displayed before showing inter node message/event}
      transmission = '-*Event*-';
      transcol = 7; {transmission message color}

var
   i,j,k,l,g : integer;
   saved : array[1..global_maxnod,1..2] of ^s70;

   save_needed,
   online_fight,
   online_trade2,
   found          : boolean;

   loc : byte;

   s : s70;

   x : longint;

   temp  : userrec;
   gubbe : onlinerec;
   king : kingrec;

begin

 {we exit if certain conditions are set}
 if (global_multi=false) or
    (already=false) or
    (onliner.name='') or
    (onliner.recnr<1) then begin
  {debug
  d(15,'Not allowed to enter node_check!');
  }
  exit;
 end;

 {init}
 already:=false;
 online_fight:=false;
 online_trade2:=false;

 for j:=1 to global_maxnod do begin
  new(saved[j,1]);
  new(saved[j,2]);
  saved[j,1]^:=emptystr;
  saved[j,2]^:=emptystr;
 end; {for j:= .end.}

 if time_left<3 then begin
  if f_exists(global_maintfile)=false then begin
   case time_left of
    1:begin
       if global_onemin=false then begin
        d(12,'Only 1 minute remaining!');
        global_onemin:=true;
       end;
      end;
    2:begin
       if global_twomin=false then begin
        d(12,'Only 2 minutes remaining!');
        global_twomin:=true;
       end;
      end;
   end; {case .end.}
  end;
 end;

 global_multi:=false;
 save_needed:=false;

 {we let the fake players make their moves, but only if the current player
  is a "player" and not a god or something else...}
 if (config.fakeplayers>0) and
    (onliner.usertype=online_player) then begin
  {debug
  d(15,'Entering "move_fakeplayers" routine.');
  }
  move_fakeplayers;
 end
 else begin
  {debug
  d(12,'Not Entering "move_fakeplayers" routine.!');
  }
 end;

 {Player online record is processed here!}
 load_onliner(fload,onliner,onliner.recnr);

 for j:=1 to global_maxnod do begin
  if onliner.info[j]<>'' then begin
   {leaving the game dead or alive!}
   if (onliner.info[j]=broadcast_exitalive) or
      (onliner.info[j]=broadcast_exitdead) then begin
    for g:=1 to global_maxnod do begin
     if saved[g,1]^='' then begin
      saved[g,1]^:=onliner.infosend[j];
      if onliner.info[j]=broadcast_exitdead then begin
       saved[g,2]^:='Killed!';
      end;
      break;
     end;
    end; {for g:= .end.}
   end
   else if findsub(broadcast_JoinTeam,onliner.info[j]) then begin
    {player has been allowed to join a team}

    {extract team name from string}
    delete(onliner.info[j],1,length(broadcast_JoinTeam));
    s:=onliner.info[j];
    {load first member in team s}
    load_teammember(s,temp);

    if temp.team=s then begin
     transfer_teamstatus(temp,player);
     user_save(player);
    end;

   end

   else if findsub(broadcast_GodDesecrated,onliner.info[j]) then begin
    {Gods altar has been desecrated}

    {extract power from string}
    delete(onliner.info[j],1,length(broadcast_GodDesecrated));
    x:=str_to_nr(onliner.info[j]);
    crlf;
    sd(config.textcolorH,'You lost ');
    sd(15,commastr(x));
    sd(config.textcolorH,' experience points!');
    d(config.textcolorH,'.');
    {decrease experience}
    DecGodExp(god,x);

   end
   else if findsub(broadcast_GodSacrificed,onliner.info[j]) then begin
    {Sacrifice has been made at Gods altar}

    {extract power from string}
    delete(onliner.info[j],1,length(broadcast_GodSacrificed));
    x:=str_to_nr(onliner.info[j]);
    crlf;
    d(14,'A sacrifice has been made at your Altar!');
    sd(config.textcolorH,'You gain ');
    sd(15,commastr(x));
    sd(config.textcolorH,' experience points!');
    d(config.textcolorH,'.');

    {increase experience}
    IncGodExp(god,x);

   end
 
   else if findsub(broadcast_ResetKingVote,onliner.info[j]) then begin
    {king has been removed. lets reset DAYS SINCE VOTE FOR KING variable}
    player.KingVotePoll:=200;
   end
   else if findsub(broadcast_Poison,onliner.info[j]) then begin
    {sender has drunk poison from player}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_Poison));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(8,deathsign+deathsign+deathsign);
    sd(8,' Poison ');
    d(8,deathsign+deathsign+deathsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' drank the poison you delivered!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,' for this evil deed!');

    {increase experience}
    IncPlayerExp(player,x);
   end
   else if findsub(broadcast_Poison,onliner.info[j]) then begin
    {sender has drunk poison from player}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_Poison));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(8,deathsign+deathsign+deathsign);
    sd(8,' Poison ');
    d(8,deathsign+deathsign+deathsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' drank the poison you delivered!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,' for this evil deed!');

    {increase experience}
    IncPlayerExp(player,x);
   end
   else if findsub(broadcast_ChildPartyExp,onliner.info[j]) then begin
    {receivers child has earned XP from party going}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_ChildPartyExp));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(8,heartsign+heartsign+heartsign);
    sd(8,' Children ');
    d(8,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' arranged a Children Party for your kids!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    d(config.textcolor,' experience points!');

    {increase experience}
    IncPlayerExp(player,x);
   end
   else if findsub(broadcast_HoldingHands,onliner.info[j]) then begin
    {sender has dated player, on players request}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_HoldingHands));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Date ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' dated you!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end
   else if findsub(broadcast_HaveSex,onliner.info[j]) then begin
    {sender just had Sex with player, on players request}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_HaveSex));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Sex ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' had '+uyellow+'SEX'+config.textcol1+' with you!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end
   else if findsub(broadcast_HaveDiscreteSex,onliner.info[j]) then begin
    {sender just had Sex with player, on players request}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_HaveDiscreteSex));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Sex ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' had '+uyellow+'SEX'+config.textcol1+' with you!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end

   else if findsub(broadcast_Dinner,onliner.info[j]) then begin
    {sender has dated player(dinner), on players request}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_Dinner));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Date ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' had dinner with you!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end
   else if findsub(broadcast_Kiss,onliner.info[j]) then begin
    {sender has kissed player, on players request}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_Kiss));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Kiss ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' kissed you!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end

   else if findsub(broadcast_BouquetRoses,onliner.info[j]) then begin
    {sender has accepted flowers from player}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_BouquetRoses));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Roses ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' accepted your flowers!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end

   else if findsub(broadcast_HoldingHands,onliner.info[j]) then begin
    {sender has dated player, on players request}

    {extract experience points earned from string}
    delete(onliner.info[j],1,length(broadcast_HoldingHands));
    x:=str_to_nr(onliner.info[j]);
    crlf;

    crlf;
    sd(4,heartsign+heartsign+heartsign);
    sd(4,' Date ');
    d(4,heartsign+heartsign+heartsign);
    crlf;

    d(global_plycol,onliner.infosend[j]+config.textcol1+' dated you!');
    sd(config.textcolor,'You earned ');
    sd(15,commastr(x));
    sd(config.textcolor,' experience points!');
    d(config.textcolor,'.');

    {increase experience}
    IncPlayerExp(player,x);
   end

   else if onliner.info[j]=broadcast_removeturf then begin
    {Town Control has been lost}
    crlf;
    d(12,'You have lost Town Control!');
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' gang wiped yout out!');

    player.cturf:=false;
    player.teamrec:=0;
    user_save(player);

   end
   else if onliner.info[j]=broadcast_TaxRelieved then begin
    {King has relieved player from Royal Tax}
    crlf;
    d(14,'You have been releieved from the Royal Tax!');
    d(config.textcolor,'Thank the Royal Family!');

    player.tax_relief:=true;
    user_save(player);

   end
   else if onliner.info[j]=broadcast_TaxReinstate then begin
    {King has reinstated player to Royal Tax}
    crlf;
    d(14,'You are obliged to pay Royal Tax!');
    d(config.textcolor,'The Royal Family has revoked your old privilege!');

    player.tax_relief:=false;
    user_save(player);

   end
   else if onliner.info[j]=broadcast_addGym then begin
    {Gym has been taken in players team control!}
    player.gym_owner:=1;
    player.gym_card:=0;
    user_save(player);
   end
   else if onliner.info[j]=broadcast_removegymcard then begin
    {player has been tossed out of the Gym, his membership has been revoked}
    player.gym_card:=0;
    user_save(player);
   end
   else if onliner.info[j]=broadcast_newgymcard then begin
    {player has invited to the Gym, new member}
    player.gym_card:=1;
    user_save(player);
   end
   else if onliner.info[j]=broadcast_removegym then begin
    {player is no longer a gym owner}
    player.gym_owner:=0;
    user_save(player);
   end

   else if findsub(broadcast_changeteampw,onliner.info[j]) then begin
    {Team Password has been changed by onliner.infosend[j]}
    {extract new team password from string}
    delete(onliner.info[j],1,length(broadcast_changeteampw));

    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' changed the Team-Password!');

    {change team password}
    player.teampw:=onliner.info[j];
    user_save(player);

   end
   else if findsub(broadcast_KingWantsYou,onliner.info[j]) then begin
    {King has posted a request to player to become his guard}

    crlf;
    sd(global_kingcol,onliner.infosend[j]);
    d(config.textcolor,' just offered you to become a Royal Guard!');
   end
   else if findsub(broadcast_RefusedGuard,onliner.info[j]) then begin
    {Player refused to become Royal Guard, this is sent to the king}

    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' refused to become a Royal Guard!');
   end
   else if findsub(broadcast_NoRoomForGuard,onliner.info[j]) then begin
    {Player tried to become Royal Guard, but there was no room}

    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' tried to become a Royal Guard, but there were no vacancies!');
   end
   else if findsub(broadcast_IbecameGuard,onliner.info[j]) then begin
    {Player became Royal Guard}

    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' became a Royal Guard! (accepting your offer)');
   end
   else if findsub(broadcast_YouAreSacked,onliner.info[j]) then begin
    {Player was sacked from Royal Guard duty}

    crlf;
    sd(global_kingcol,onliner.infosend[j]);
    d(config.textcolor,' sacked you from your Guard duty! (what a pig)');
   end
   else if findsub(broadcast_IQuitasGuard,onliner.info[j]) then begin
    {Player quits his Royal Guard duty}

    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' quit job as Royal Guard! (deserter)');
   end
   else if (findsub(broadcast_IWantToBeGuard,onliner.info[j])) and
           (player.king=true)  then begin
    {Player has applied for Guard Duty}

    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' filed an application for Guard Duty!');

   end
   else if findsub(broadcast_YouBecameGuard,onliner.info[j]) then begin
    {Player became guard, accepted by KING on other node}

    crlf;
    sd(global_kingcol,onliner.infosend[j]);
    d(config.textcolor,' accepted your application for Royal Guard Duty!');
   end
   else if findsub(broadcast_NoRoomForYou,onliner.info[j]) then begin
    {Player was accepted to become guard, but there was no ROOM}

    crlf;
    sd(global_kingcol,onliner.infosend[j]);
    d(config.textcolor,' would like to see you in the Royal Guard.');
    d(12,'BUT! There was no spare room in the Force.');
    d(12,'Your offer was declined.');
   end
   else if findsub(broadcast_sentmoney,onliner.info[j]) then begin
    {Money has been sent from player onliner.infosend[j]}

    {extract sum from string}
    delete(onliner.info[j],1,length(broadcast_sentmoney));
    x:=str_to_nr(onliner.info[j]);
    crlf;
    sd(config.textcolor,'You received ');
    sd(14,commastr(x));
    sd(config.textcolor,' '+many_money(x)+' from ');
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,'.');

    {receive money}
    incplayermoney(player,x);

   end
   else if onliner.info[j]=broadcast_senttoprison then begin
    crlf;
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' has been sent to PRISON.');
   end
   else if onliner.info[j]=broadcast_RoyalAngel then begin

    healing_royal_angel; {this proc is also called from mail.pas}

    {tell all nodes of this remarkable event}
    online_send_to_all('a '+uwhite+'Angel'+config.textcol1+' visited '+uplc+player.name2+config.textcol1+'!',player.name2,
                       onliner.infosend[j]);

    {we must send a reciept to the sender (the king or queen)}
    if is_online(onliner.infosend[j],online_player) then begin
     online_send_to_player(onliner.infosend[j],online_player,broadcast_RoyalAngelLand);
    end;

    pause;
   end
   else if onliner.info[j]=broadcast_RoyalAngelLand then begin
    crlf;
    sd(14,'The '+uwhite+'Angel'+uyellow+' has returned. ');
    sd(global_plycol,onliner.infosend[j]);
    d(14,' has been healed!');
    pause;
   end
   else if onliner.info[j]=broadcast_RoyalAvenger then begin

    hurting_royal_avenger; {this proc is also called from mail.pas}

    {tell all nodes of this remarkable event}
    online_send_to_all('a '+ulred+'Dark Avenger'+config.textcol1+' hurt '+uplc+player.name2+
                       config.textcol1+'!',player.name2,onliner.infosend[j]);

    {we must send a reciept to the sender (the king or queen)}
    if is_online(onliner.infosend[j],online_player) then begin
     online_send_to_player(onliner.infosend[j],online_player,broadcast_RoyalAvengerLand);
    end;

    pause;
   end
   else if onliner.info[j]=broadcast_RoyalAvengerLand then begin
    crlf;
    sd(config.textcolor,'The '+ulred+'Dark Avenger'+config.textcol1+' has returned. ');
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' has been hurt!');
    pause;
   end
   else if onliner.info[j]=broadcast_CellDoorOpens then begin

    if onliner.location=onloc_prisoner then begin
     {a player has broken into the prison and liberated PLAYER}
     crlf;
     d(15,'*****************************');
     d(15,'*******HELPING HAND *********');
     d(config.textcolor,'Suddenly the cell door swings wide open!');
     d(config.textcolor,'In the dim light you can see '+uplc+onliner.infosend[j]+config.textcol1+' standing in the hallway.');
     d(config.textcolor,'You have been rescued!');
     crlf;
     if confirm('Go out to freedom','Y')=false then begin
      {player refused to leave his cell!}
      {return receipt to rescuer}
      if is_online(onliner.infosend[j],online_player) then begin
       online_send_to_player(onliner.infosend[j],online_player,uplc+player.name2+config.textcol1+' refused to leave '
          +sex3[player.sex]+' cell!');
      end;

     end
     else begin

      {player walked out to freedom!}
      {return receipt to rescuer}

      {important! this means that the prisoner can open the cell door!}
      onliner.location:=onloc_prisonerop;

      if is_online(onliner.infosend[j],online_player) then begin
       online_send_to_player(onliner.infosend[j],online_player,uplc+player.name2+config.textcol1+' left '+sex3[player.sex]
         +' cell!');
      end;

      {news-paper}
      Newsy(true,
      'Escape from Prison',
      ' '+uplc+player.name2+config.textcol1+' escaped from Prison!',
      ' '+uplc+player.name2+config.textcol1+' had help from the outside.',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      {load the king}
      load_king(fload,king);

      {inform the King}
      if (is_online(king.name,online_player)=false) and (king.ai='H') then begin
       post(MailSend,
       king.name,
       king.ai,
       false,
       mailrequest_nothing,
       '',
       ulred+'Jail-Break!'+config.textcol1,
       mkstring(11,underscore),
       uplc+player.name2+config.textcol1+' escaped from Prison!',
       uplc+player.name2+config.textcol1+' had help from the outside.',
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
      online_send_to_all(uplc+player.name2+config.textcol1+' escaped from Prison!',player.name2,'');

     end;

     {we must send a reciept to the sender (the player who broke into JAIL)}
     if is_online(onliner.infosend[j],online_player) then begin
      online_send_to_player(onliner.infosend[j],online_player,uplc+player.name2+config.textcol1+' walked out of the cell!');
     end;

     pause;
    end
    else begin

     {player is no longer in his cell, return a receipt to rescuer}
     if is_online(onliner.infosend[j],online_player) then begin
      online_send_to_player(onliner.infosend[j],online_player,uplc+player.name2+config.textcol1+' is not in the Cell!');
     end;

    end;
   end

   else if onliner.info[j]=broadcast_MortalEnteredGame then begin
    crlf;
    d(transcol,transmission);
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' entered the game.');
   end
   else if onliner.info[j]=broadcast_GodEnteredGame then begin
    crlf;
    d(transcol,transmission);
    sd(global_plycol,onliner.infosend[j]);
    d(config.textcolor,' entered the game '+ulcyan+'<IMMORTAL>'+config.textcol1+'.');
   end

   else if onliner.info[j]=broadcast_kingenter then begin
    crlf;
    d(transcol,transmission);
    sd(global_kingcol,onliner.infosend[j]);
    d(config.textcolor,', THE KING!, entered the game.');
   end
   else if onliner.info[j]=broadcast_queenenter then begin
    crlf;
    d(transcol,transmission);
    sd(global_kingcol,onliner.infosend[j]);
    d(config.textcolor,', THE QUEEN!, entered the game.');
   end

   else begin
    {non-broadcast messages, STANDARD INFO STUFF}
    crlf;
    d(transcol,transmission);
    d(config.textcolor,onliner.info[j]);
    crlf;
   end;

   onliner.info[j]:=emptystr;
   save_needed:=true;
  end;

  if onliner.chatline[j]<>'' then begin
   crlf;
   d(transcol,transmission);
   sd(global_plycol,onliner.chatsend[j]);
   d(config.textcolor,' tells you :');
   d(global_talkcol,onliner.chatline[j]);
   crlf;
   onliner.chatline[j]:=emptystr;
   onliner.chatsend[j]:=emptystr;
   save_needed:=true;
  end;

 end; {for j:= .end.}


 if (onliner.bname<>'') and (onliner.com=intercom_sendstuff) then begin
  {somebody wants to send stuff...perhaps trade something..}

  save_needed:=true;

  crlf;
  d(transcol,transmission);
  sd(global_plycol,onliner.bname);
  d(config.textcolor,' wishes to trade stuff with you!');
  if confirm('Negotiate ','N')=true then begin

   d(15,'Let''s talk!');

   found:=false;
   for j:=1 to fs(FsOnline) do begin
    load_onliner(fload,gubbe,j);
    if gubbe.name=onliner.bname then begin
     found:=true;
     if gubbe.bname=onliner.name then begin
      gubbe.com:=intercom_accept;
      load_onliner(fsave,gubbe,j);

      onliner.bname  :=gubbe.name;
      onliner.doing  :='talking to '+uplc+gubbe.name+config.textcol1;
      onliner.com    :='T';
      onliner.comfile:=gubbe.comfile;
      add_onliner(OUpdateAll,onliner);

      online_trade2:=true;
     end
     else begin
      sd(global_plycol,gubbe.name);
      d(config.textcolor,' is not interested anymore!');
      d(15,'(Press '+Config.ReturnEnter+')');
      onliner.bname  :=emptystr;
      onliner.com    :=' ';
      onliner.comfile:=emptystr;
     end;
     break;
    end;
   end;

   if found=false then begin
    d(15,onliner.bname+' seems to have dropped out of the game!');
    d(15,'(Press '+Config.ReturnEnter+')');
   end;

  end
  else begin
   {decline the online challenge}
   for j:=1 to fs(FsOnline) do begin
    load_onliner(fload,gubbe,j);
    if gubbe.name=onliner.bname then begin
     gubbe.com:=intercom_decline;
     load_onliner(fsave,gubbe,j);
     break;
    end;
   end;
   onliner.com:=intercom_empty;
   onliner.comfile:=emptystr;
   onliner.bname:=emptystr;
  end;

 end
 else if (onliner.bname<>'') and (onliner.com=intercom_execute) then begin
  {kings guard come to fetch the prisoner to his execution!}

  save_needed:=true;

  d(transcol,transmission);
  crlf;
  sd(global_plycol,onliner.bname);
  d(config.textcolor,' has opened the cell-door!');

  found:=false;
  for j:=1 to fs(FsOnline) do begin

   {load onliner}
   load_onliner(fload,gubbe,j);

   if gubbe.name=onliner.bname then begin
    found:=true;
    if gubbe.bname=onliner.name then begin
     gubbe.com:=intercom_accept;
     load_onliner(fsave,gubbe,j);

     onliner.bname    :=gubbe.name;
     onliner.location :=onloc_prisonerop;
     onliner.doing    :='being executed';
     onliner.com      :=' ';
     onliner.comfile  :=gubbe.comfile;

     add_onliner(OUpdateAll,onliner);
    end
    else begin
     sd(global_plycol,gubbe.name);
     d(config.textcolor,' has closed the cell-door!');
     d(15,'(Press '+Config.ReturnEnter+')');
     onliner.bname:=emptystr;
     onliner.com:=' ';
     onliner.comfile:=emptystr;
    end;
    break;
   end;
  end;

  d(global_talkcol,'   You are to die for your crimes!');
  crlf;

  d(config.textcolor,'You are brought up to the court-yard and greeted by the Hangman');
  d(config.textcolor,'and his men. People have gathered to watch the spectacle and');
  d(config.textcolor,'you wave to the crowd, you don''t want to disappoint anyone.');
  d(config.textcolor,'Then there is silence when the Axe is swinged ....');

  {execute}
  crlf;
  sd(13,'Schwoooooop.........');
  delay2(global_online_poll_delay);
  d(13,'....!');
  crlf;

  d(config.textcolor,'Your soul takes off to a better place...');
  d(config.textcolor,'Darkness...');

  {bye}
  player.hps:=0;
  {player.allowed:=false;}
  Reduce_Player_Resurrections(player,true);
  pause;
  halt;

 end
 else if (onliner.bname<>'') and
         (onliner.com=intercom_release) then begin
  {somebody opened the prison cell door!}

  save_needed:=true;

  d(transcol,transmission);
  crlf;
  sd(global_plycol,onliner.bname);
  d(config.textcolor,' has opened the Cell door!');

  if confirm('Walk out to freedom ','Y')=true then begin
   d(13,'The door is unlocked! Open it! (press '+Config.ReturnEnter+')');
   found:=false;
   player.location:=offloc_dormitory;
   for j:=1 to fs(FsOnline) do begin
    load_onliner(fload,gubbe,j);
    if gubbe.name=onliner.bname then begin
     found:=true;
     if gubbe.bname=onliner.name then begin
      gubbe.com:=intercom_accept;
      load_onliner(fsave,gubbe,j);

      onliner.bname    :=gubbe.name;
      onliner.location :=onloc_prisonerop;
      onliner.doing    :='being set free';
      onliner.com      :=' ';
      onliner.comfile  :=gubbe.comfile;

      add_onliner(OUpdateAll,onliner);
     end
     else begin
      sd(global_plycol,gubbe.name);
      d(config.textcolor,' has closed the cell-door!');
      d(15,'(Press '+Config.ReturnEnter+')');
      onliner.bname:=emptystr;
      onliner.com:=' ';
      onliner.comfile:=emptystr;
     end;
     break;
    end;
   end; {for j:= .end.}

   if found=false then begin
    d(global_plycol,gubbe.name+uwhite+' has closed the cell-door!');
    d(15,'(Press '+Config.ReturnEnter+')');
   end;
  end
  else begin
   {decline freedom}
   for j:=1 to fs(FsOnline) do begin
    load_onliner(fload,gubbe,j);
    if gubbe.name=onliner.bname then begin
     gubbe.com:=intercom_decline;
     load_onliner(fsave,gubbe,j);
     break;
    end;
   end; {for j:= .end.}
   onliner.com:=' ';
   onliner.comfile:=emptystr;
   onliner.bname:=emptystr;
  end;
 end
 else if (onliner.bname<>'') and (onliner.com=intercom_challenge) then begin

  {somebody has challenged player to a online duel!}
  save_needed:=true;

  d(transcol,transmission);
  crlf;
  sd(global_plycol,onliner.bname);
  d(config.textcolor,' has challenged you to a duel!');

  if confirm('Accept this','N')=true then begin

   d(15,'Accepted!');

   found:=false;
   for j:=1 to fs(FsOnline) do begin

    load_onliner(fload,gubbe,j);

    if gubbe.name=onliner.bname then begin

     found:=true;

     if gubbe.bname=onliner.name then begin
      gubbe.com:=intercom_accept;
      load_onliner(fsave,gubbe,j);

      onliner.bname :=gubbe.name;
      onliner.doing  :='fighting '+uplc+gubbe.name+config.textcol1;
      onliner.com    :='F';
      onliner.comfile:=gubbe.comfile;

      add_onliner(OUpdateAll,onliner);

      online_fight:=true;
     end
     else begin
      {debug
      d(15,'debug:['+gubbe.bname+']');
      }
      sd(global_plycol,gubbe.name);
      d(config.textcolor,' is not interested anymore (the coward).');
      d(15,'('+Config.ReturnEnter+')');
      onliner.bname:=emptystr;
      onliner.com:=intercom_empty;
      onliner.comfile:=emptystr;
     end;
     break;
    end;
   end; {for j:= .end.}

   if found=false then begin
    d(15,'The scumbag seems to have dropped out of the game!');
    d(15,'(Press '+Config.ReturnEnter+')');
   end;

  end
  else begin
   {decline online challenge}
   for j:=1 to fs(FsOnline) do begin
    load_onliner(fload,gubbe,j);
    if gubbe.name=onliner.bname then begin
     gubbe.com:=intercom_decline;
     load_onliner(fsave,gubbe,j);
     break;
    end;
   end;
   onliner.com:=intercom_empty;
   onliner.comfile:=emptystr;
   onliner.bname:=emptystr;
  end;
 end;

 {display deaths and exits of other players}
 if saved[1,1]^<>'' then begin
  for j:=1 to global_maxnod do begin
   if saved[j,1]^<>'' then begin
    if saved[j,2]^<>'' then begin {leaving the game DEAD!}
     crlf;
     d(transcol,transmission);
     sd(global_plycol,saved[j,1]^);
     sd(config.textcolor,' has been killed! (leaving the game in a coffin)');
     crlf;
    end
    else begin
     crlf;
     d(transcol,transmission);
     sd(global_plycol,saved[j,1]^);
     sd(config.textcolor,' left the game.');
     crlf;
    end;
   end;
  end; {for j:= .end.}
 end;

 if online_fight=true then begin
  online_duel(false);
  onliner.comfile:=emptystr;
  onliner.com    :=' ';
  onliner.bname  :=emptystr;
 end
 else if online_trade2=true then begin
  online_trade(false);
  onliner.comfile:=emptystr;
  onliner.com    :=' ';
  onliner.bname  :=emptystr;
 end;

 if (save_needed) or (online_fight) or (online_trade2) then begin
  onliner.bname:=emptystr;
  add_onliner(OUpdateAll,onliner);
 end;

 global_multi:=true;
 already:=true;

 {dispose pointer vars}
 for j:=1 to global_maxnod do begin
  dispose(saved[j,1]);
  dispose(saved[j,2]);
 end; {for j:= .end.}


end; {Node Check *end*}


Function Location_Desc;  {returns a 30 characters string with description
                          of what a player is currently at/doing}
var
   s : s70;

begin

 {* Online Location Description *}
 case mode of
  onloc_gangprep   : s:='preparing for gangwar';
  onloc_readingmail: s:='reading mail';
  onloc_postingmail: s:='writing a letter';
  onloc_royalmail  : s:='reading Royal Mail';
  onloc_entering   : s:='entering game...';
  onloc_mainstreet : s:='Main street';
  onloc_theinn     : s:='the Inn';
  onloc_darkalley  : s:='outside the Shady Shops';
  onloc_church     : s:='Church';
  onloc_deathmaze  : s:='Death Maze';
  onloc_weaponshop : s:='Weapon shop';
  onloc_master     : s:='level master';
  onloc_magicshop  : s:='Magic shop';
  onloc_madmage    : s:='the Mad mage';
  onloc_armorshop  : s:='Armor store';
  onloc_bank       : s:='the Bank';
  onloc_reportroom : s:='report room';
  onloc_healer     : s:='the healer';
  onloc_marketplace: s:='Market Place';
  onloc_foodstore  : s:='Food Store';
  onloc_plymarket  : s:='players Market';
  onloc_recruit    : s:='Hall of Recruitment';
  onloc_dormitory  : s:='Dormitory';
  onloc_temples    : s:='Holy Temple';
  onloc_anchorroad : s:=config.anchor;
  onloc_orbs       : s:='Orbs Bar';
  onloc_orbs_mixing: s:='mixing cocktails at Orbs';
  onloc_orbs_browse: s:='browsing cocktail menu at Orbs';
  onloc_bobsbeer   : s:='Bobs Beer';
  onloc_bobthieves : s:='fighting thieves outside Bobs!';
  onloc_bobdrink   : s:='drinking beer at Bobs';
  onloc_alchemist  : s:='Alchemist store';
  onloc_steroids   : s:='Lizards Training Center';
  onloc_drugs      : s:='Ordlofs Beer House';
  onloc_darkness   : s:='Dirty alley';
  onloc_whores     : s:='Beauty Nest';
  onloc_darkeralley: s:='Very Dark Alley';
  onloc_gigolos    : s:='Pleasure Dome';
  onloc_outsideinn : s:='outside the Beer Hut';
  onloc_onaraid    : s:='on a raid!';
  onloc_teamcorner : s:='Teams Corner';
  onloc_mystic     : s:='*mystic secret*';
  onloc_robbingbank: s:='robbing the Bank!';
  onloc_bountyroom : s:='Bounty Room';
  onloc_readingnews: s:='reading the news';
  onloc_checkplys  : s:='checking player list';
  onloc_dormfists  : s:='FISTFIGHT IN THE DORMITORY';
  onloc_gymfists   : s:='FISTFIGHT IN THE GYM';
  onloc_temple     : s:='temple area';
  onloc_outCastle  : s:='outside the Castle';
  onloc_the_gym    : s:='the Gym';
  onloc_MultiChat  : s:='in a chat-room (the Inn).';
  onloc_outsideGym : s:='outside the Gym';
  onloc_gossipmonger:s:='gossip-monger';
  onloc_lovehistory: s:='love history room';
  onloc_beggarswall: s:='beggars wall';

  {above: tricked by robbers at Bobs Beer, perhaps going to get killed!}

  onloc_umanrest   : s:='Uman Caves';
  onloc_umantame   : s:='taming a '+umonc+'wild bear'+config.textcol1; {UMAN CAVES}
  onloc_umanwrest  : s:='Wrestling in the Uman Caves'; {UMAN CAVES}
  onloc_innfight   : s:='fighting at the Inn';
  onloc_dormfight  : s:='assaulting guest at the Dormitory';
  onloc_combmaster : s:='visiting training master';

  {relations}
  onloc_lovestreet : s:='Love corner';
  onloc_home       : s:='managing family affairs';
  onloc_nursery    : s:='the nursery';
  onloc_kidnapper  : s:='home and doing bad things.';
  onloc_giftshop   : s:='gift shop';

  {castle}
  onloc_castle     : s:='the Royal Castle';
  onloc_royorphanag: s:='the Royal Orphanage';
  onloc_courtmage  : s:='visiting the Court Magician';
  onloc_warchamber : s:='the Royal War Chamber';
  onloc_questmaster: s:='Quest Chamber';
  onloc_questhall  : s:='quest hall';
  onloc_questattemp: s:='on a Quest!';
  onloc_guardoffice: s:='the Royal Guard Office'; {players visiting}

  onloc_prison     : s:='in the '+udgray+'Royal Prison'+config.textcol1;
  onloc_prisoner   : s:='in a prison-cell.';
  onloc_prisonerop : s:='walking out of a cell.';
  onloc_prisonerex : s:='preparing to be executed!';
  onloc_prisonwalk : s:='outside the Royal Prison';
  onloc_prisonbreak: s:='breaking into Prison!';

  onloc_icecaves   : s:='exploring the '+uwhite+'Ice-Caves'+config.textcol1;

  {heaven - immortal areas}
  onloc_heaven : s:='Heaven';
  onloc_heaven_boss : s:='Visiting the almighty';

 end; {case .end.}

 {return result}
 location_desc:=s;

end; {location_desc *end*}

end. {Unit Online .end.}
