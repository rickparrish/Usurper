{$IFDEF WIN32}
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



Unit Children; {Usurper - Children}

Interface

Uses Init;

type ChildrenType = (AnyChild,OwnChild,KidnappedChild); {"select child" procs/functions}
     ChildrenType2= (ExcludeNone,ExcludeOwn); {"select child" procs/functions}


{children}
Procedure Kidnapped_Children;
Procedure Name_Babies(var pl1:userrec; npc_calling:boolean);
Procedure Child_List_Description;
Procedure Children_Maintenance;
Procedure Display_Own_Children(const ply:userrec;numbers,parent,descript:boolean);
Procedure Display_Own_Kidnapped_Children(const ply:userrec;numbers,parents:boolean);
Procedure Children_in_Orphanage;
Procedure Children_in_Realm(const excludename,excludeid:s30;numbers,point_to_own:boolean);
Function Add_Couples_Children_Online(const pl1,pl2:userrec;const description:s70):boolean;
Function Remove_Couples_Children_Online(const pl1,pl2:userrec):boolean;

Procedure Free_Kidnapped_Children(const ply:userrec);
Function Child_Status(const child:childrec) : s70;
Function Child_Health(const child:childrec) : s70;
Function Child_Soul(const child:childrec) : s70;

Function Numbers_In_Orphanage : word;

Procedure Better_Child_Soul(var child:childrec; change:integer);
Procedure Worsen_Child_Soul(var child:childrec; change:integer);
Function Select_A_Child(const ply:userrec;var child:childrec;
                        typeofkids:childrentype;excludetype:childrentype2;
                        numbers:boolean):boolean;

Function Child_Name_Exist(const name:s20):boolean;
Function My_Child(const ply:userrec;const child:childrec):boolean;


Procedure New_ChildRecord(var Child:ChildRec); {Initialize Kid Record}
Procedure Create_Child(var Child:ChildRec;
                     const mother,father: UserRec;
                     bastard : boolean);

Procedure Remove_Parent(const ply:userrec);


Implementation


Uses CMS, Jakob, Relatio2,
     Various, Various2, Various3,
     StatusC, News, Mail,
     Online, Relation, GenNews,
     File_Io;


Function Numbers_In_Orphanage : word;
var
    i,
    result : word;
    child : ChildRec;
begin

 {init}
 result:=0;

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.location=ChildLocation_Orphanage) and
      (child.deleted=false) and
      (child.named=true) then begin
    inc(result);
   end;
  end;
 end; {for i:= .end.}

 {return result}
 numbers_in_orphanage:=result;

end; {numbers_in_orphanage *end*}


Function My_Child(const ply:userrec;const child:childrec):boolean;
var result : boolean;
begin {is ply the father/mother to child?}

 {init}
 result:=false;

 if (child.fatherid=ply.id) and
    (child.father=ply.name2) and
    (child.deleted=false) then result:=true;

 if (child.motherid=ply.id) and
    (child.mother=ply.name2) and
    (child.deleted=false) then result:=true;

 {return result}
 my_child:=result;

end; {my_child *end*}


Function Child_Name_Exist(const name:s20):boolean;
var
    i : word;
    child : childrec;
    result : boolean;

begin
 {does child name exist in children database?}

 {init}
 result:=false;

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (upcasestr(child.name)=upcasestr(name)) and
      (child.deleted=false) and
      (child.named=true) then begin
    result:=true;
    break;
   end;
  end;
 end; {for i:= .end.}

 {return result}
 child_name_exist:=result;

end; {child_name_exist *end*}


Function Add_Couples_Children_Online(const pl1,pl2:userrec;const description:s70):boolean;
var
    i : word;
    result : boolean;
    child : ^childrec;
begin {adds ALL of pl1 and pl2 produced children online}
      {returns false if for some reason not ALL children could be placed online}
      {see also "remove_couples_children_online"}

 {init}
 result:=true;
 new(child);

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child^,i)=true then begin

   if (child^.deleted=false) and
      (child^.named=true) and
      (my_child(pl1,child^)=true) and
      (my_child(pl2,child^)=true) then begin

    if add_child(SAddChild,child^,pl1.name2,description,0)=false then begin
     {operation failed}
     result:=false;
     break;
    end;

   end;
  end;

 end; {for i:= .end.}

 {dispose pointer vars}
 dispose(child);

 {return result}
 Add_Couples_Children_Online:=result;

end; {Add_Couples_Children_Online *end*}

Function Remove_Couples_Children_Online(const pl1,pl2:userrec):boolean;
var
    i : word;
    result : boolean;
    child : ^childrec;

begin {removes ALL of pl1 and pl2 produced children from online list}
      {returns false if for some reason not ALL children could be remove}
      {see also "add_couples_children_online"}

 {init}
 result:=true;
 new(child);

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child^,i)=true then begin

   if (child^.deleted=false) and
      (child^.named=true) and
      (my_child(pl1,child^)=true) and
      (my_child(pl2,child^)=true) then begin

    if add_child(SRemoveChild,child^,'','',0)=false then begin
     {operation failed}
     result:=false;
    end;

   end;
  end;

 end; {for i:= .end.}

 {dispose pointer vars}
 dispose(child);

 {return result}
 remove_couples_children_online:=result;

end; {Remove_Couples_Children_Online *end*}


Procedure Name_Babies; {look for and name babies. can be called by human
                        or npc=totally automated routine}
var
   i,
   tries : word;

   id : s15;

   name : s30;

   s : s70;

   done,
   my_baby : boolean;

   ReturnFileId : byte;

   x : word;

   father_active,
   mother_active : boolean;

   ply0 : ^userrec; {user}
   child : childrec; {child}

begin

 {Notes: called from mail.pas => mailrequest_ScanForBabies
         maint.pas

 {parameters explained:
   npc_calling=true; computer controlled character calls this routine}

 {init pointer variables}
 new(ply0);
 name:='';

 {scan for babies to name, only own babies of course}
 for i:=1 to fs(fschildren) do begin

  {load child}
  load_child(fload,child,i);

  my_baby:=false;
  father_active:=false;
  mother_active:=false;

  {is this pl1s child?}
  if (child.deleted=false) and
     (child.named=false) and
     (child.father=pl1.name2) and
     (child.fatherId=pl1.Id) then begin
   my_baby:=true;
   father_active:=true;
  end
  else if
     (child.deleted=false) and
     (child.named=false) and
     (child.mother=pl1.name2) and
     (child.motherId=pl1.Id) then begin
   my_baby:=true;
   mother_active:=true;
  end;

  if my_baby=true then begin

   {decide name for child}
   if npc_calling then begin
    {computer controlled character is calling this routine}
    done:=false;
    tries:=0;
    name:='';
    repeat
     {give child a random name, depending on gender of course}
     s:=give_me_newborn_childname(child);
     if (s<>'') and (child_name_exist(s)=false) then begin
      name:=s;
      done:=true;
     end;
     inc(tries);
    until (done=true) or (tries>200);

    {we didn't come up with a name! perhaps all names in the database
     files are taken...not impossible at all...since the Npc's will
     produce a helluva lot of children, given enough time.}
    if name='' then begin
     name:='*Add More Kid Names*';
    end;

   end
   else begin
    {human controlled character is calling this routine}
    done:=false;
    repeat
     crlf;
     s:='Give your new baby '+sex6[child.sex]+' a name';
     d(11,s);
     d(5,mkstring(length(s),underscore));
     d(config.textcolor,'Name (max 20 chars)');
     sd(config.textcolor,':');
     name:=get_string(20);

     if length(name)<3 then begin
      d(12,'at least 3 letters!');
     end
     else begin
      if confirm(ukidc+name+config.textcol1+', is what you want','N')=true then begin
       crlf;
       sd(config.textcolor,'searching the parish register...');
       if child_name_exist(name)=true then begin
        crlf;
        d(12,'Sorry, but this name is already registered.');
       end
       else begin
        crlf;
        if child.bastard then begin
         d(14,name+config.textcol1+','+ulred+' the bastard-child'+config.textcol1+', has been baptized!');
        end
        else begin
         d(14,name+config.textcol1+' has been baptized!');
        end;
        done:=true;
       end;

      end;
     end;

    until done;

   end;

   if name<>'' then begin

    {save baby}
    child.named:=true;
    child.name:=name;
    load_child(fsave,child,i);

    if child.royal>0 then begin
     s:=' '+ukidc+child.name+config.textcol1+' has '+uyellow+'Royal'+config.textcol1+' blood floating in '
      +sex3[child.sex]+' veins!';
    end
    else begin
      s:='';
    end;

    {news-paper}
    newsy(true,
    'Baby Citizen',
    ' '+uplc+pl1.name2+config.textcol1+' named '+sex3[pl1.sex]+' new-born '+sex7[child.sex]+'; '+ukidc+name
       +config.textcol1+'!',
    ' The town welcomes its new member. May '+sex2[child.sex]+' grow up to become',
    ' a responsible citizen.',
    ''+s,
    '',
    '',
    '',
    '',
    '');

    s:='';
    {royal,bastard?}
    if child.bastard then s:=s+ulred+' *Bastard*';
    if child.royal>0 then s:=s+uyellow+' *ROYAL*';


    if mother_active then begin

     {child-birth/death-log}
     Generic_News(ChildBirthNews,
      false,
      ugreen+'['+fix_date(todays_date)+'] '+uplc+child.mother+ugreen+' gave birth to; '+ukidc+child.name+config.textcol1+'!'+s,
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

     {birth-log}
     Generic_News(ChildBirthNews,
      false,
      ugreen+'['+fix_date(todays_date)+'] '+ukidc+child.name+ugreen+' was born!'+s,
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

    {inform spouse}
    if father_active then id:=child.motherId;
    if mother_active then id:=child.fatherId;

    {locate spouse}
    x:=look_for_id(id,'H',ReturnFileId);

    if x>0 then begin
     load_character(ply0^,ReturnFileId,x);
    end;

    {was spouse found?}
    if Id=ply0^.Id then begin
     post(MailSend,
     ply0^.name2,
     ply0^.ai,
     false,
     mailrequest_nothing,
     '',
     ulcyan+'Your Child'+config.textcol1,
     mkstring(10,underscore),
     uplc+pl1.name2+config.textcol1+' named your baby '+sex6[child.sex]+': '+ukidc+child.name+config.textcol1+'!',
     uplc+pl1.name2+config.textcol1+' think this is a great name for your '+sex7[child.sex]+'.',
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

 end; {for i:= .end.}

 {dispose pointer variables}
 dispose(ply0);

end; {name_babies *end*}


Procedure Remove_Parent(const ply:userrec);
var i : word;
   ok : boolean;
   s : s70;
   child : ChildRec;
begin

 {make all children produced by ply fatherless/motherless}
 for i:=1 to fs(fschildren) do begin

  if load_child(fload,child,i)=true then begin

   if (child.deleted=false) and
      (child.name<>'') then begin

    ok:=false;
    if (child.mother=ply.name2) and (child.motherid=ply.id) then begin

     {child-birth/death-log}
      Generic_News(ChildBirthNews,
       false,
       ugreen+'['+fix_date(todays_date)+'] '+ukidc+child.name+ugreen+' lost '+sex3[child.sex]+' mother, '+uplc+child.mother
        +config.textcol1+'!',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');


     ok:=true;
     child.mother:='';
     child.motherid:='';

    end
    else if (child.father=ply.name2) and (child.fatherid=ply.id) then begin

     {child-birth/death-log}
      Generic_News(ChildBirthNews,
       false,
       ugreen+'['+fix_date(todays_date)+'] '+ukidc+child.name+ugreen+' lost '+sex3[child.sex]+' father, '+uplc+child.father
         +config.textcol1+'!',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');


     ok:=true;
     child.father:='';
     child.fatherid:='';
    end;

    if ok then begin

     {if child misses both parents then we delete the child}
     if (child.father='') and (child.mother='') then begin

      child.deleted:=true;

      {news-paper}
      Newsy(true,
      'Child Dead!',
      ' '+ukidc+child.name+config.textcol1+' has died from a '+ulred+'depression'+config.textcol1+', a direct result',
      ' of the loss of '+sex3[child.sex]+' parents.',
      ' '+ukidc+child.name+config.textcol1+' died at the age of '+commastr(child.age)+'.',
      '',
      '',
      '',
      '',
      '',
      '');

      {child-birth/death-log}
      Generic_News(ChildBirthNews,
       false,
       ugreen+'['+fix_date(todays_date)+'] '+ukidc+child.name+ugreen+' died after losing '+sex3[child.sex]+' parents.',
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

     {give the other parent access}
     if (child.motheraccess=false) and (child.mother<>'') and
        (child.mother<>ply.name2) then begin
      child.motheraccess:=true;
      {inform mother of gained custody}
      s:='Your Child';
      post(MailSend,
      child.mother,
      child.motherai,
      false,
      mailrequest_nothing,
      '',
      uyellow+s+config.textcol1,
      mkstring(length(s),underscore),
      ukidc+child.name+config.textcol1+', your '+sex7[child.sex]+', is now in your custody!',
      'The tragic death of '+ukidc+child.name+'s'+config.textcol1+' father: '+uplc+ply.name2+config.textcol1+' has',
      ' made you fully responsible for '+ukidc+child.name+config.textcol1+'!',
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

     if (child.fatheraccess=false) and (child.father<>'') and
        (child.father<>ply.name2) then begin
      child.fatheraccess:=true;
      {inform father of gained custody}
      s:='Your Child';
      post(MailSend,
      child.father,
      child.fatherai,
      false,
      mailrequest_nothing,
      '',
      uyellow+s+config.textcol1,
      mkstring(length(s),underscore),
      ukidc+child.name+config.textcol1+', your '+sex7[child.sex]+', is now in your custody!',
      'The tragic death of '+ukidc+child.name+'s'+config.textcol1+' mother: '+uplc+ply.name2+config.textcol1+' has',
      ' made you fully responsible for '+ukidc+child.name+config.textcol1+'!',
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

     {update child}
     load_child(fsave,child,i);

    end;
   end;
  end;

 end; {for i:= .end.}

end; {remove_parent *end*}


Procedure Free_Kidnapped_Children(const ply:userrec);
var i : word;
   ok : boolean;
   child : ChildRec;
begin
 {set kids by player free, this routine is used by the deactivate_player
  routine...when a player comits suicide, quits or completes the game}

 for i:=1 to fs(fschildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.deleted=false) and
      (child.name<>'') and
      (child.location=childlocation_kidnapped) and
      (child.kidnapper=ply.name2) and
      (child.kidnapperid=ply.id) then begin

    {setting child free!}
    child.location:=childlocation_home;
    child.kidnapper:='';
    child.kidnapperid:='';
    load_child(fsave,child,i);

    {inform parents}
    inform_parents_online(child,ukidc+child.name+config.textcol1+' has been released!');

    inform_parents(child,
    mailrequest_nothing,
    uyellow+'Child Release!'+config.textcol1,
    mkstring(14,underscore),
    'Your '+sex7[child.sex]+ukidc+' '+child.name+config.textcol1+' has been released!',
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
    config.textcol1+'Child Released!',
    ' '+ukidc+child.name+config.textcol1+', the '+sex7[child.sex]+' of '+uplc+child.mother
       +config.textcol1+' and '+uplc+child.father+config.textcol1+' was',
    ' released by '+sex3[child.sex]+' kidnappers!',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

   end;
  end;

 end;  {for i:= .end.}

end; {Free_Kidnapped_Children *end*}


Function Child_Status(const child:childrec) : s70;
var s : s30;
begin {child.location : byte; {0=home,1=royal orphanage,2=kidnapped}

 case child.location of
  ChildLocation_Home     : s:=ulcyan+'Home'+config.textcol1; {home with parents, default}
  ChildLocation_Orphanage: s:=ulcyan+'Orphanage'+config.textcol1; {royal orphanage}
  ChildLocation_Kidnapped: s:=ulred+'Kidnapped!'+config.textcol1; {kidnapped}
  else s:='';
 end; {case .end.}

 {return result}
 child_status:=s;

end; {child_status *end*}

Function Child_Health(const child:childrec) : s70;
var s : s30;
begin

 case child.health of
  ChildHealth_Normal   : s:=uwhite+'excellent'+config.textcol1;
  ChildHealth_Poisoned : s:=ulred+'*poisoned*'+config.textcol1;
  ChildHealth_Cursed   : s:=ulred+'*cursed*'+config.textcol1;
  ChildHealth_Depressed: s:=ulred+'*depressed*'+config.textcol1;
  else s:='';
 end; {case .end.}

 {return result}
 child_health:=s;

end; {child_health *end*}

Function Child_Soul(const child:childrec) : s70;
var s : s70;
begin

 case child.soul of
  -500..-300: s:='evil brat';
  -299..-100: s:='vicious kid';
  -99..0    : s:='naughty kid';
  1..100    : s:='kid';
  101..200  : s:='nice kid';
  201..400  : s:='well-mannered child';
  401..500  : s:='angel-heart';
  else s:='*unknown*';
 end; {case .end.}

 {return result}
 child_soul:=s;

end; {child_soul *end*}


Function Select_A_Child(const ply : userrec;
                        var child : childrec;
                        typeofkids : childrentype;
                        excludetype : childrentype2;
                        numbers : boolean):boolean;
                        {returns false if no child is selected}
var
    s : s30;
    i : word;

    ok,
    my_kid,
    result,
    go_ahead : boolean;
begin

 {let the user pick a child that is not deleted
 typeofkids=anychild, select any child
           =ownchild, select own children only
 }

 {init}
 result:=false;

 repeat
  crlf;
  case typeofkids of
   anychild:begin
    d(config.textcolor,'childs name (press '+config.textcol2+'?'+config.textcol1+' for list of children)');
            end;
   ownchild:begin
             d(config.textcolor,'your child (press '+config.textcol2+'?'+config.textcol1+' for list of children)');
            end;
   kidnappedchild:begin
                   d(config.textcolor,'kidnapped child (press '+config.textcol2+'?'+config.textcol1+' for list of children)');
                  end;

  end; {case .end.}
  sd(config.textcolor,':');

  s:=get_string(20);

  if s='?' then begin
   case typeofkids of
    AnyChild:begin
              case excludetype of
               excludenone: children_in_realm('','',numbers,true);
               excludeown : children_in_realm(ply.name2,ply.id,numbers,false);
              end; {case .end.}
             end;
    OwnChild:begin
              display_own_children(ply,numbers,true,true);
             end;
    KidnappedChild:begin
                    display_own_kidnapped_children(ply,true,true);
                   end;
   end; {case .end.}
  end;
 until s<>'?';

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (findsub(s,child.name)) and
      (child.deleted=false) and
      (child.named=true) then begin

    ok:=true;
    my_kid:=false;
    if my_child(ply,child)=true then my_kid:=true;
    if (typeofkids=ownchild) and (my_kid=false) then ok:=false;

    if typeofkids=kidnappedchild then begin
     ok:=false;
     if (child.kidnapper=ply.name2) and
        (child.kidnapperid=ply.id) and
        (child.location=childlocation_kidnapped) then begin
      ok:=true;
     end;
    end;

    if (excludetype=excludeown) and (my_kid=true) then ok:=false;

    if ok then begin
     sd(config.textcolor,ukidc+child.name);

     if my_kid then begin
      sd(config.textcolor,', your '+sex7[child.sex]);
     end
     else begin
      sd(config.textcolor,' ('+sex7[child.sex]+' of '+uplc+child.mother+
      config.textcol1+' and '+uplc+child.father+config.textcol1+')');
     end;

     if confirm('','N')=true then begin

      go_ahead:=true;
      if (my_kid=true) and (player.sex=1) and
         (child.fatheraccess=false) then begin
       crlf;
       d(12,'Sorry, you have no custody of your '+sex7[child.sex]+' '+child.name+'.');
       d(12,child.name+' is living with '+sex3[child.sex]+' mother '+child.mother+'.');
       pause;
       go_ahead:=false;
      end;

      if (my_kid=true) and (player.sex=2) and
         (child.motheraccess=false) then begin
       crlf;
       d(12,'Sorry, you have no custody of your '+sex7[child.sex]+' '+child.name+'.');
       d(12,child.name+' is living with '+sex3[child.sex]+' father '+child.father+'.');
       pause;
       go_ahead:=false;
      end;

      if go_ahead=true then begin
       result:=true;
       break;
      end;

     end
     else begin
      if confirm('Continue search','Y')=false then begin
       break;
      end;
     end;
    end;
   end;
  end;
 end; {for i:= .end.}

 {return result}
 select_a_child:=result;

end; {select_a_child *end*}


Procedure Worsen_Child_Soul(var child:childrec; change:integer);
begin
 dec(child.soul,change);
 if child.soul<-500 then child.soul:=-500;
end; {worsen_child_soul *end*}

Procedure Better_Child_Soul(var child:childrec; change:integer);
begin
 inc(child.soul,change);
 if child.soul>500 then child.soul:=500;
end; {better_child_soul *end*}


Procedure Children_in_Realm(const excludename,excludeid : s30; numbers,point_to_own : boolean);
var
    s : s30;

    unknown : s70;

    ok,
    found : boolean;

    i,
    counter : word;

    lines : byte;

    child : childrec;

begin

 {displays a list of all the children in the Realm
  excludename  : name to exclude from list
  excludeid    : child.id to exclude from list
  numbers      : include counter in list?
  point_to_own : mark players own children? }

 {init}
 counter:=0;
 lines:=2;
 found:=false;

 unknown:= ulred+'<Unknown>';

 s:='Children in the Realm';
 d(5,s);
 d(2,cool_string(length(s),'=','-',14,14));

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.deleted=false) and
      (child.named=true) then begin

    ok:=true;

    if excludename<>'' then begin
     if (child.father=excludename) and (child.fatherid=excludeid) then ok:=false;
     if (child.mother=excludename) and (child.motherid=excludeid) then ok:=false;
    end;

    if ok then begin

     found:=true;

     if numbers then begin
      {#}
      inc(counter);

      s:=commastr(counter);
      case length(s) of
       1: s:=s+' ';
       2: s:=s+' ';
       3: s:=s+' ';
      end; {case .end.}
      sd(7,s);
     end;

     {set child marks}
     s:=child_marks(child);

     {name}
     sd(11,child.name+config.textcol1+s+config.textcol1+', ');

     if child.father = '' then child.father:= unknown;
     if child.mother = '' then child.mother:= unknown;

     {parents}
     sd(config.textcolor,sex7[child.sex]+' of '+uplc+child.mother+config.textcol1
                         +' and '+uplc+child.father+config.textcol1+'.');

     {point to own children}
     if point_to_own=true then begin
      if my_child(player,child)=true then begin
       sd(15,'  **YOUR CHILD!**');
      end;
     end;

     {crlf}
     crlf;

     {pause?}
     inc(lines);
     if lines>global_screenlines-2 then begin
      lines:=0;
      if confirm('Continue','Y')=false then begin
       break;
      end;
     end;

    end;
   end;
  end;

 end; {for i:= .end.}

 if found=false then begin
  d(12,'No children in the Realm right now.');
 end
 else begin
  crlf;
  child_list_description;
 end;

end; {children_in_realm *end*}


Procedure Children_in_Orphanage;
var
    s : s90;

    found : boolean;

    i,
    counter : word;

    adjust,
    lines : byte;

    child : childrec;

begin

 {displays a list of the kids in the royal orphanage
  used by the King to manage his royal orphanage.}

 { blaha

 {init}
 counter:=0;
 lines:=2;
 found:=false;

 s:='Children in the Royal Orphanage';
 d(5,s);
 d(2,cool_string(length(s),'=','-',14,14));

 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.location=ChildLocation_Orphanage) and
      (child.deleted=false) and
      (child.named=true) then begin

    found:=true;

    {#}
    inc(counter);

    s:=commastr(counter);
    case length(s) of
     1: s:=s+'   ';
     2: s:=s+'  ';
     3: s:=s+' ';
    end;
    sd(7,s);

    {name}
    s:=child.name;
    adjust:=length(child_marks(child));
    s:=s+' ';

    sd(global_kidcol,ljust(s,17+adjust));

    {age}
    if child.age=1 then s:=' year'
                   else s:=' years';
    sd(7,' '+rjust(commastr(child.age)+s,8));

    {parents}
    sd(config.textcolor,'  ('+uplc+child.father+config.textcol1+' the '+race_display(2,child.fatherrace,0)+' '
     +config.textcol1+'/ '+uplc+child.mother+config.textcol1+' the '+race_display(2,child.motherrace,0)+')');

    {crlf}
    crlf;

    {pause}
    inc(lines);
    if lines>global_screenlines-2 then begin
     lines:=0;
     if confirm('Continue','Y')=false then begin
      break;
     end;
    end;
   end;
  end;

 end; {for i:= .end.}

 if found=false then begin
  d(12,'No children are staying here.');
 end
 else begin
  crlf;
  child_list_description;
 end;

end; {children_in_orphanage *end*}


Procedure Create_Child(var Child:ChildRec;
                     const mother,father: UserRec;
                     bastard : boolean);

const max_children = 65500; {max kids allowed in database}

var
   i : longint;
 found : boolean;
 tempchild : childrec;
begin

 {Create a kid and store in database}
 New_ChildRecord(Child);

 {set necessary child parameters}
 child.sex:=random(2)+1; {sex, 1=male, 2=female}
 child.bastard:=bastard; {set to true if product of secret lay or whore intercourse}

 child.mother:=mother.name2; {mother to the child}
 child.father:=father.name2; {father to the child}
 child.orgmother:=mother.name2; {mother to the child}
 child.orgfather:=father.name2; {father to the child}

 child.motherid:=mother.id; {unique mother ID - to match userrec ID}
 child.fatherid:=father.id; {unique father ID - to match userrec ID}
 child.orgmotherid:=mother.id; {unique mother ID - to match userrec ID}
 child.orgfatherid:=father.id; {unique father ID - to match userrec ID}

 child.motherai:=mother.ai; {mother ai}
 child.fatherai:=father.ai; {father ai}
 child.orgmotherai:=mother.ai; {mother ai}
 child.orgfatherai:=father.ai; {father ai}

 child.motherrace:=mother.race; {important info so we can evaluate what the child is!}
 child.fatherrace:=father.race; {important info so we can evaluate what the child is!}
 child.orgmotherrace:=mother.race; {important info so we can evaluate what the child is!}
 child.orgfatherrace:=father.race; {important info so we can evaluate what the child is!}

 {is child of royal birth?}
 child.royal:=0;
 if mother.king then inc(child.royal);
 if father.king then inc(child.royal);

 {if child is a bastard then only the mother will get custody!}
 if child.bastard=true then begin
  child.fatheraccess:=false;
 end;

 {save kid}
 found:=false;

 {look for empty/deleted record}
 for i:=1 to fs(fschildren) do begin

  if load_child(fload,tempchild,i)=true then begin

   {is quest available}
   if tempchild.deleted then begin
    child.recnr:=i;
    load_child(fsave,child,i);
    found:=true;
    break;
   end;
  end;

 end; {for i:= .end.}

 if found=false then begin
  {we must append the new relation to the end of the children file}

  i:=fs(fschildren)+1;

  if i>max_children then begin
   {database is full}
   crlf;
   d(12,'ALERT! Children database is full ('+global_childrenf+').');
   d(12,'The Sysop/Programmers should be informed.');
  end
  else begin
   {saving new child}
   child.recnr:=i;
   load_child(fsave,child,i);
  end;

 end;

end; {create_child *end*}

Procedure New_ChildRecord(var Child:ChildRec); {Initialize Kid Record}
begin

 With Child do begin
  name    :=emptystr;  {name}
  sex     :=1; {sex, 1=male, 2=female}
  age     :=1; {age}
  birth   :=todays_date; {date of birth}
  recnr   :=1; {record #, position in file}
  ageplus :=0; {how many days since getting one year older}
  bastard:=false; {set to true if product of secret lay or whore intercourse}
  named  :=false; {has kid been named yet? if not it is not accessible in lists etc etc}
  deleted:=false; {is this record deleted}

  mother :=emptystr;  {mother to the child}
  father :=emptystr;  {father to the child}

  motherid :=emptystr; {unique mother ID - to match userrec ID}
  fatherid :=emptystr; {unique father ID - to match userrec ID}

  motherai :='H'; {mother ai}
  fatherai :='H'; {father ai}

  motherrace :=Human; {important info so we can evaluate what the child is!}
  fatherrace :=Human; {important info so we can evaluate what the child is!}

  motheraccess :=true; {does the mother have access to the kid}
  fatheraccess :=true; {does the father have access to the kid}

  location :=childlocation_home; {see cms.pas and childlocation_XX constants}
  soul     :=50; {soul -500=bad}
  health   :=childhealth_normal; {see cms.pas and childhealth_XX constants}

  kidnapper:=emptystr; {name of kidnapper}
  kidnapperid:=''; {kidnapper id}
  ransom_demanded:=0; {gold demanded for the release of child}

 end;

end; {new_childRecord *end*}


Procedure Display_Own_Kidnapped_Children(const ply:userrec;numbers,parents:boolean);
var {display ply:s children, the kidnapped ones}

   i,
   counter : word;

   adjust,
   lines : byte;

   s : s90;
   parent_string : string[7];

   ok,
   found : boolean;

   Child : ChildRec; {a kid!}

begin

 {init}
 found:=false;
 counter:=0;
 lines:=0;

 for i:=1 to fs(fschildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.deleted=false) and
      (child.name<>'') and
      (child.named=true) and
      (child.location=childlocation_kidnapped) and
      (child.kidnapper=ply.name2) and
      (child.kidnapperid=ply.id) then begin

    {players kidnapped children}

    inc(counter);

    {header}
    if not found then begin
     s:='  -*-Your Victims-*-';
     d(11,s);
     sd(5,mkstring(5,underscore)+'name'
         +mkstring(23,underscore)+'age');

     if parents=true then begin
      parent_string:='ransom demanded';
      sd(5,mkstring(11,underscore)+parent_string);
      crlf;
     end;

     found:=true;
    end;

    if numbers then begin
     {#}
     s:=commastr(counter);
     case length(s) of
      1: s:=s+'   ';
      2: s:=s+'  ';
      3: s:=s+' ';
     end;
     sd(7,s);
    end;

    {name}
    s:=ukidc+child.name;
    adjust:=length(child_marks(child));

    s:=s+' ';

    {name}
    sd(global_kidcol,ljust(s,24+adjust)+' ');

    {age}
    if child.age=1 then s:=' year    '
                   else s:=' years    ';
    sd(7,ljust(commastr(child.age)+s,14));

    {ransom demanded}
    d(14,commastr(child.ransom_demanded));

    {father/mother}
    if parents=true then begin
     s:=uplc+child.mother+config.textcol1+' / '+uplc+child.father+config.textcol1;
     sd(config.textcolor ,'     (parents are '+uplc+s+config.textcol1+')');
    end
    else begin
     sd(9,'-unknown parents-');
    end;

    {crlf}
    crlf;

    {pause}
    inc(lines);
    if lines>global_screenlines-2 then begin
     lines:=0;
     if confirm('Continue','Y')=false then begin
      break;
     end;
    end;
   end;
  end;

 end; {for i:= .end.}

 if not found then begin
  d(12,'You don''t have any children.');
 end
 else begin
  crlf;
  {child_list_description;}
 end;

end; {Display_Own_Kidnapped_Children *end*}


Procedure Children_Maintenance; {runs at maintenance / every day}
var

   able_to_pay : boolean;

   i,
   j : word;

   ReturnFileId : byte;

   double_cost,
   x,cost : longint;

   s : s90;

   king : KingRec;
   child : ChildRec;
   ply  : UserRec;

begin

 {the grubby little hands of the johnson kid was found in the cookie jar!}
 if f_exists(global_childrenf)=false then begin
  exit;
 end;

 {updates the children records}
 for i:=1 to fs(FsChildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.deleted=false) and
      (child.named=true) then begin

    {birthday?}
    if child.ageplus<32000 then begin
     inc(child.ageplus);
    end;

    {is it birthday?}
    if (child.ageplus>34) and
       (child.age<18) and
       (random(4)=0) then begin

     {child gets older}
     inc(child.age);
     child.ageplus:=0;

     {inform parents}
     inform_parents(child,
     mailrequest_nothing,
     uyellow+'Birthday'+config.textcol1,
     mkstring(8,underscore),
     'You celebrated your '+sex7[child.sex]+'s '+ukidc+child.name+config.textcol1+' '+uwhite+commastr(child.age)+'th'
        +config.textcol1+' birthday.',
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

     {should child be deactivated because of old age?}
     if child.age>18 then begin

      {deleteing child}
      child.deleted:=true;

      {inform parents}
      inform_parents(child,
       mailrequest_nothing,
       ulred+'Child Lost'+config.textcol1,
       mkstring(10,underscore),
       'You said goodbye to your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+'.',
       ukidc+child.name+config.textcol1+' is a big '+sex6[child.sex]+' and '+sex2[child.sex]+' must seek '+sex3[child.sex]
            +' own luck now!',
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
      newsy(true,'Grownup',
      ' '+ukidc+child.name+config.textcol1+' the child to '+uplc+child.mother+config.textcol1+' and '+uplc+child.father
         +config.textcol1+' has ',
      ' left home to seek '+sex3[child.sex]+' luck in the world.',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      {child-birth/death-log}
      Generic_News(ChildBirthNews,
       false,
       ugreen+'['+fix_date(todays_date)+'] '+ukidc+child.name+ugreen+' left childhood.',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

     end; {deactivate child .end.}

    end; {child birthday .end.}

    if not child.deleted then begin
     {upbringing costs money for the parents or the royal orphanage}

     cost:=child.age*5500; {5500 is declared in castle.pas}

     {double the cost if only one parent is responsible for the child}
     double_cost:=0;
     if (child.mother='') or (child.father='') then double_cost:=cost;
     if (child.motheraccess=false) or (child.fatheraccess=false) then begin
      double_cost:=cost;
     end;

     {the parents share the cost of the upbringing.}
     {if one parent is gone or fundless the remaining spouse
      must pay the whole sum. If the parents can't pay, the child
      is placed in the Royal Orphanage.
      If the child already is in the orphanage and the king can't
      pay then the child is tossed to the wolves.}

     if child.location=ChildLocation_Home then begin

      {parents must pay for childs upbringing}
      able_to_pay:=false;

      {load mother}
      if child.mother<>'' then begin

       j:=Look_for_ID(child.motherId,'H',ReturnFileId);

       if j>0 then begin

        if load_character(ply,ReturnFileId,j)=true then begin

         if ply.gold>=(cost+double_cost) then begin
          decplayermoney(ply,cost+double_cost);
          user_save(ply);
          able_to_pay:=true;
         end
         else if ply.bankgold>=(cost+double_cost) then begin
          decbankmoney(ply,cost+double_cost);
          user_save(ply);
          able_to_pay:=true;
         end;
        end;

       end;

      end;

      {load father}
      if child.father<>'' then begin
       j:=Look_for_ID(child.fatherId,'H',ReturnFileId);
       if j>0 then begin
        if load_character(ply,ReturnFileId,j)=true then begin

         if ply.gold>=(cost+double_cost) then begin
          decplayermoney(ply,cost+double_cost);
          user_save(ply);
          able_to_pay:=true;
         end
         else if ply.bankgold>=(cost+double_cost) then begin
          decbankmoney(ply,cost+double_cost);
          user_save(ply);
          able_to_pay:=true;
         end;

        end;
       end;
      end;

      if not able_to_pay then begin

       {place child in the royal orphanage}
       child.location:=Childlocation_Orphanage;

       {inform parents}
       inform_parents(child,
        mailrequest_nothing,
        ulred+'Child Lost!'+config.textcol1,
        mkstring(11,underscore),
        'Your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+' has been sent to the Royal Orphanage!',
        'You don''t have the funds to support your own children! SHAME ON YOU!',
        'The Royal Family is responsible for the future of '+ukidc+child.name+config.textcol1+'.',
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

       {load king data}
       load_king(fload,king);

       {inform the King}
       if (king.name<>'') and (king.ai='H') then begin
        post(MailSend,
        king.name,
        king.ai,
        false,
        mailrequest_nothing,
        '',
        uwhite+'New Child'+config.textcol1,
        mkstring(9,underscore),
        'Poverty has struck the parents of '+ukidc+child.name+config.textcol1+'!',
        'You are now responsible for the well-being of '+ukidc+child.name+config.textcol1+'!',
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
       'Family Tragedy!',
       ' '+ukidc+child.name+config.textcol1+' was sent to the Royal Orphanage!',
       ' The parents of '+ukidc+child.name+config.textcol1+' are too poor to support their children!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

      end;

     end
     else if child.location=ChildLocation_Kidnapped then begin
      {kidnapper must pay}

      {try to load kidnapper}

      j:=Look_for_ID(child.kidnapperID,'H',ReturnFileId);

      if j=0 then begin
       child.location:=ChildLocation_Home;
      end
      else begin

       {load kidnapper}
       if load_character(ply,ReturnFileId,j)=false then begin
        child.location:=ChildLocation_Home;
       end
       else begin

        {does kidnapper have the money?}
        able_to_pay:=false;

        if ply.gold>=(cost+2500) then begin
         decplayermoney(ply,cost+double_cost);
         user_save(ply);
         able_to_pay:=true;
        end
        else if ply.bankgold>=(cost+2500) then begin
         decbankmoney(ply,cost+double_cost);
         user_save(ply);
         able_to_pay:=true;
        end;

        if able_to_pay=true then begin
         {inform kidnapper of expenses}

         {mail}
         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         umailheadc+'Kidnapped Child'+config.textcol1,
         mkstring(15,underscore),
         'You had to pay '+uyellow+commastr(cost+2500)+config.textcol1+' '+many_money(cost+2500)+' for keeping',
         ukidc+child.name+config.textcol1+' alive.',
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
         {kidnapper was unable to pay}

         {place child in the royal orphanage}
         child.location:=Childlocation_Orphanage;

         {inform kidnapper}
         post(MailSend,
         ply.name2,
         ply.ai,
         false,
         mailrequest_nothing,
         '',
         umailheadc+'Kidnapped Child'+config.textcol1,
         mkstring(15,underscore),
         'You were unable to pay '+uyellow+commastr(cost+2500)+config.textcol1+' '+many_money(cost+2500)+' to keep',
         ukidc+child.name+config.textcol1+' alive. The child has been transfered to the Royal Care House.',
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

         {inform parents}
         inform_parents(child,
          mailrequest_nothing,
          ulred+'Child Lost!'+config.textcol1,
          mkstring(11,underscore),
          'Your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+' has been sent to the Royal Orphanage!',
          'The kidnapper didn''t have the funds to sustain your child!',
          'The Royal Family is responsible for the future of '+ukidc+child.name+config.textcol1+'.',
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

         {load king data}
         load_king(fload,king);

         {inform the King}
         if (king.name<>'') and (king.ai='H') then begin
          post(MailSend,
          king.name,
          king.ai,
          false,
          mailrequest_nothing,
          '',
          uwhite+'New Child'+config.textcol1,
          mkstring(9,underscore),
          'Poverty has struck the kidnapper of '+ukidc+child.name+config.textcol1+'!',
           'You are now responsible for the well-being of '+ukidc+child.name+config.textcol1+'!',
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
         'Family Tragedy!',
         ' '+ukidc+child.name+config.textcol1+' was sent to the Royal Orphanage!',
         ' The kidnapper of '+ukidc+child.name+config.textcol1+' was too poor to support the child!',
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

     end
     else begin {ChildLocation_Orphanage}

      {king must pay}
      able_to_pay:=false;

      {load king data}
      load_king(fload,king);

      {king pays}
      if king.treasury>=cost then begin
       DecKingTreasury(king,cost);
       load_king(fsave,king);
       able_to_pay:=true;
      end;

      if not able_to_pay then begin
       {the child is put to the wolves}

       {inform parents}
       inform_parents(child,
        mailrequest_nothing,
        ulred+'Child Dead!'+config.textcol1,
        mkstring(11,underscore),
        'Your '+sex7[child.sex]+' '+ukidc+child.name+config.textcol1+' was tossed to the wolves!',
        'The Royal Orphanage was unable to sustain poor '+ukidc+child.name+config.textcol1+'.',
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

       {inform the King}
       if (king.name<>'') and (king.ai='H') then begin
        post(MailSend,
        king.name,
        king.ai,
        false,
        mailrequest_nothing,
        '',
        ulred+'Child Dead in Orphanage'+config.textcol1,
        mkstring(23,underscore),
        'The poor orphant '+ukidc+child.name+config.textcol1+' was put out to the wolves!',
        'The Royal Treasury is bankrupt and can''t sustain the orphants!',
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
       'Family Tragedy!',
       ' '+ukidc+child.name+config.textcol1+' was tossed to the wolves!',
       ' The Royal Orphanage is out of funds!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');

       {child-birth/death log}
       Generic_News(ChildBirthNews,
        false,
        ugreen+'['+fix_date(todays_date)+'] '+ukidc+child.name+ulred+' DIED'+ugreen+' in the Royal Orphanage!',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '');


       {kill child}
       child.deleted:=true;

      end;

     end;

    end; {upbringing .end.}

    if (child.deleted=false) and
       (child.location=ChildLocation_Home) then begin

     if child.health=childhealth_poisoned then begin
      {child is posioned! parents grieving cost them experience}
      {experience cost for child being ill}
      x:=child.age*850;

      if (child.mother<>'') and (child.motheraccess=true) then begin
       {mail xp mother}
       post(MailSend,
       child.mother,
       child.motherai,
       false,
       mailrequest_ChildPoisonedExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;

      if (child.father<>'') and (child.fatheraccess=true) then begin
       {mail xp to father}
       post(MailSend,
       child.father,
       child.fatherai,
       false,
       mailrequest_ChildPoisonedExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;
     end
     else if child.health=childhealth_cursed then begin
      {child is cursed! parents grieving cost them experience}
      {experience cost for child being cursed}
      x:=child.age*550;

      if (child.mother<>'') and (child.motheraccess=true) then begin
       {mail xp mother}
       post(MailSend,
       child.mother,
       child.motherai,
       false,
       mailrequest_ChildCursedExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;

      if (child.father<>'') and (child.fatheraccess=true) then begin
       {mail xp to father}
       post(MailSend,
       child.father,
       child.fatherai,
       false,
       mailrequest_ChildCursedExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;
     end
     else if child.health=childhealth_depressed then begin
      {child is depressed(divorce)! parents grieving cost them experience}

      {experience cost for child being cursed}
      x:=child.age*850;

      if child.mother<>'' then begin
       {mail xp mother}
       post(MailSend,
       child.mother,
       child.motherai,
       false,
       mailrequest_ChildDepressedExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;

      if child.father<>'' then begin
       {mail xp to father}
       post(MailSend,
       child.father,
       child.fatherai,
       false,
       mailrequest_ChildDepressedExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;
     end
     else if child.health=childhealth_normal then begin
      {give parents xp for their efforts in raising their child}
      {experience earned for child}
      x:=child.age*750;

      if (child.mother<>'') and (child.motheraccess=true) then begin
       {mail xp mother}
       post(MailSend,
       child.mother,
       child.motherai,
       false,
       mailrequest_ChildRaisingExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;

      if (child.father<>'') and (child.fatheraccess=true) then begin
       {mail xp to father}
       post(MailSend,
       child.father,
       child.fatherai,
       false,
       mailrequest_ChildRaisingExp,
       '',
       child.name,
       long2str(child.sex),
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
       '');
      end;
     end;

    end;

    {return to normal health}
    child.health:=ChildHealth_Normal;

    {save updated child record}
    load_child(fsave,child,child.recnr);

   end;
  end;

 end; {for i:= .end.}

end; {children_maintenance *end*}

procedure child_list_description;
begin

 {this text is displayed at the end of every child list routine.}
 d(config.textcolor,'(<A>dopted, <R>oyal, <B>astard, <K>idnapped, <O>rphanage, <P>oisoned)');

end; {child_list_description *end*}


Procedure Display_Own_Children(const ply:userrec;
                               numbers,parent,descript:boolean);
var {display ply:s children, all children including *out of marriage* and
     bastards}

   i,
   counter : word;

   adjust,
   lines : byte;

   s : s70;

   parent_string : string[6];

   ok,
   found : boolean;

   Child : ChildRec; {a kid!}

begin

 {init}
 found:=false;
 counter:=2;
 lines:=0;

 for i:=1 to fs(fschildren) do begin

  {load child}
  if load_child(fload,child,i)=true then begin

   if (child.deleted=false) and
      (child.name<>'') and
      (child.named=true) then begin

    {ply:s children}
    if my_child(ply,child) then begin
     inc(counter);

     {header}
     if not found then begin
      if ply.id=player.id then s:='  -*-Your Children-*-'
                          else s:='  -*-'+ply.name2+adds(ply.name2)+' Children-*-';

      d(11,s);
      sd(5,mkstring(5,underscore)+'name'
          +mkstring(9,underscore)+'gender'
          +mkstring(6,underscore)+'age'
          +mkstring(4,underscore)+'status'
          +mkstring(4,underscore)+'health');

      if parent=true then begin
       case ply.sex of
        1: parent_string:='mother';
        2: parent_string:='father';
       end; {case .end.}
       sd(5,mkstring(6,underscore)+parent_string+mkstring(5,underscore));
      end;

      crlf;

     end;

     found:=true;

     if numbers then begin
      {#}
      s:=commastr(counter);
      case length(s) of
       1: s:=s+'   ';
       2: s:=s+'  ';
       3: s:=s+' ';
      end; {case .end.}
      sd(7,s);
     end;

     {name}
     s:=ukidc+child.name;
     adjust:=length(child_marks(child));
     s:=s+' ';

     {name}
     sd(global_kidcol,ljust(s,20+adjust)+' ');

     {gender}
     sd(7,ljust(sex7[child.sex],9));

     {age}
     if child.age=1 then s:=' year    '
                    else s:=' years    ';
     sd(7,ljust(commastr(child.age)+s,10));

     {status}
     sd(14,ljust(child_status(child),16));

     {health}
     sd(11,ljust(child_health(child),14));

     {father/mother}
     if parent=true then begin
      if child.father=ply.name2 then s:=child.mother
                                else s:=child.father;
      sd(global_plycol,ljust('   '+s,15));
     end;

     {crlf}
     crlf;

     {pause}
     inc(lines);
     if lines>global_screenlines-2 then begin
      lines:=0;
      if confirm('Continue','Y')=false then begin
       break;
      end;
     end;
    end;
   end;

  end;

 end; {for i:= .end.}

 if not found then begin
  if ply.id=player.id then begin
   d(12,'You don''t have any children.');
  end
  else begin
   d(global_plycol,ply.name2+config.textcol1+' doesn''t have any children.');
  end;

 end
 else begin
  crlf;
  if descript=true then begin
   child_list_description;
  end;
 end;

end; {display_own_children *end*}


Procedure Kidnapped_Children; {players manage kidnapped children, kids
                              they have kidnapped..}
const offset = 20;
      max_ransom = 250000000; {guess..}
var
   refresh,
   kidnappmenu_done : boolean;

   ch : char;

   x : longint;

   child : childrec;

begin

 kidnappmenu_done:=false;
 ch:='?';

 repeat

  {update online location, only if necessary}
  if onliner.location<>onloc_kidnapper then begin
   refresh:=true;
   onliner.location:=onloc_kidnapper;
   onliner.doing   :=location_desc(onliner.location);
   add_onliner(OUpdateLocation,onliner);
  end;

  if ch='?' then begin
   {kidnapper menu}
   clearscreen;
   crlf;
   d(5,'The Cellar'+config.textcol1+', where you keep the wine and kidnapped children.');
   d(5,'You must keep everything nice and clean down here...');

   crlf;
   menu2(ljust('(L)ist of victims',offset));
   menu('(T)ransfer child to the '+ulcyan+'Royal Care-House'+config.textcol1+'.');

   menu2(ljust('(F)ree child.',offset));
   menu('(D)emand ransom');

   menu('(S)tatus');
   menu('(R)eturn');
   crlf;
  end;

  sd(config.textcolor,'Cellar ('+config.textcol2+'?'+config.textcol1+' for menu):');

  {get user-input}
  ch:=upcase(getchar);
  crlf;

  {evaluate User-input}
  case ch of
   'S':begin {status}
        status(player);
       end;
   'R':begin {return}
        kidnappmenu_done:=true;
       end;
   'L':begin {list of kidnapped children}
        crlf;
        crlf;
        display_own_kidnapped_children(player,true,true);
       end;
   'D':begin {demand ransom}
        crlf;
        crlf;
        crlf;
        d(15,'Demand ransom! '+uyellow+'*get some '+config.moneytype+' for your effort*');

        if select_a_child(player,child,kidnappedchild,excludenone,false)=true then begin

         {add child to online list}
         if add_child(SAddChild,child,player.name2,'being roughed up',0)=false then begin
          d(12,child.name+' is busy. try again soon!');
         end
         else if child.ransom_demanded>0 then begin
          {ransom already demanded for child}

          crlf;
          crlf;
          d(config.textcolor,'A ransom for '+uyellow+commastr(child.ransom_demanded)+config.textcol1
            +' '+many_money(child.ransom_demanded)+' is already demanded for '+ukidc+child.name+config.textcol1+'!');

          if confirm('Would you like to set a new Ransom','N')=true then begin
           {demand ransom}
           crlf;
           d(config.textcolor,'How much '+config.moneytype+' do you demand for '+ukidc+child.name+config.textcol1+'?');
           sd(config.textcolor,':');

           x:=get_number(0,max_ransom);

           if x=0 then begin
            {ransom removed}
            child.ransom_demanded:=x;

            {update child record}
            load_child(fsave,child,child.recnr);

            {news-paper}
            newsy(true,
            umailheadc+'Ransom removed!'+config.textcol1,
            ' The kidnappers of '+ukidc+child.name+config.textcol1+' has removed their demand for ransom!',
            ' '+ukidc+child.name+config.textcol1+' parents are '+uplc+child.mother+config.textcol1+' and '+uplc+child.father
               +config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

            {inform parents online}
            Inform_Parents_Online(child,'The ransom has been removed for your '+sex7[child.sex]+ukidc+' '+child.name
                                        +config.textcol1+'!');

            {inform parents offline}
            inform_parents(child,
            mailrequest_nothing,
            umailheadc+'Ransom removed!'+config.textcol1,
            mkstring(15,underscore),
            'The kidnappers of your '+sex7[child.sex]+ukidc+' '+child.name+config.textcol1+' has removed their',
            'demand for ransom in exchange for your child.',
            'The kidnappers has not revealed their intentions to what they will do',
            'to the young '+ukidc+child.name+config.textcol1+'.',
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
           else if x>child.ransom_demanded then begin
            {ransom raised}
            child.ransom_demanded:=x;

            {update child record}
            load_child(fsave,child,child.recnr);

            {news-paper}
            newsy(true,
            umailheadc+'Ransom raised!'+config.textcol1,
            ' The kidnappers of '+ukidc+child.name+config.textcol1+' demand '+uyellow+commastr(x)+config.textcol1
              +' '+many_money(x),
            ' in exhange for the child.',
            ' '+ukidc+child.name+config.textcol1+' parents are '+uplc+child.mother+config.textcol1+' and '+uplc+child.father
               +config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '');

            {inform parents online}
            Inform_Parents_Online(child,'The ransom has been '+ulred+'raised'+config.textcol1+' for your '+sex7[child.sex]
                                        +ukidc+' '+child.name+config.textcol1+'!');

            {inform parents offline}
            inform_parents(child,
            mailrequest_nothing,
            umailheadc+'Ransom raised!'+config.textcol1,
            mkstring(14,underscore),
            'The kidnappers of your '+sex7[child.sex]+ukidc+' '+child.name+config.textcol1+' demand',
            uyellow+commastr(x)+config.textcol1+' '+many_money(x)+' in exchange for your child.',
            'The kidnappers has raised their demand for '+config.moneytype+'.',
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
           else if x<child.ransom_demanded then begin

            {ransom lowered}
            child.ransom_demanded:=x;

            {update child record}
            load_child(fsave,child,child.recnr);

            {news-paper}
            newsy(true,
            umailheadc+'Ransom lowered!'+config.textcol1,
            ' The kidnappers of '+ukidc+child.name+config.textcol1+' demand '+uyellow+commastr(x)+config.textcol1
              +' '+many_money(x),
            ' in exhange for the child.',
            ' '+ukidc+child.name+config.textcol1+' parents are '+uplc+child.mother+config.textcol1+' and '+uplc+child.father
               +config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '');

            {inform parents online}
            Inform_Parents_Online(child,'The ransom has been lowered for your '+sex7[child.sex]+ukidc+' '+child.name
                                        +config.textcol1+'!');

            {inform parents offline}
            inform_parents(child,
            mailrequest_nothing,
            umailheadc+'Ransom lowered!'+config.textcol1,
            mkstring(15,underscore),
            'The kidnappers of your '+sex7[child.sex]+ukidc+' '+child.name+config.textcol1+' demand',
            uyellow+commastr(x)+config.textcol1+' '+many_money(x)+' in exchange for your child.',
            'The kidnappers has lowered their demands.',
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
           else if x=child.ransom_demanded then begin
            {no change!}
            d(15,'No change.');
            crlf;
           end;

          end;

          {remove shadow child}
          add_child(SRemoveChild,child,'','',0);
          crlf;

         end
         else begin
          {demand ransom}
          crlf;
          d(config.textcolor,'How much '+config.moneytype+' do you demand for '+ukidc+child.name+config.textcol1+'?');
          sd(config.textcolor,':');

          x:=get_number(0,max_ransom);

          if x>0 then begin
           if confirm('Demand '+uyellow+commastr(x)+config.textcol1+' '+many_money(x)+' for '+ukidc+child.name
                      +config.textcol1,'Y')=true then begin
            {set ransom}
            child.ransom_demanded:=x;
            crlf;
            d(15,'Done.');
            d(15,'Informing '+ukidc+child.name+'s'+config.textcol1+' parents...');

            if child.mother<>'' then begin
             d(config.textcolor,' mother: '+uplc+child.mother+config.textcol1+' the '+race_display(2,child.motherrace,1));
            end
            else begin
             d(12,'*unknown mother*');
            end;

            if child.father<>'' then begin
             d(config.textcolor,' father: '+uplc+child.father+config.textcol1+' the '+race_display(2,child.fatherrace,1));
            end
            else begin
             d(12,'*unknown father*');
            end;

            {save updated child record}
            load_child(fsave,child,child.recnr);

            {news-paper}
            newsy(true,
            umailheadc+'Ransom demanded'+config.textcol1,
            ' The kidnappers of '+ukidc+child.name+config.textcol1+' demand '+uyellow+commastr(x)+config.textcol1
              +' '+many_money(x),
            ' in exhange for the child.',
            ' '+ukidc+child.name+config.textcol1+' parents are '+uplc+child.mother+config.textcol1+' and '+uplc+child.father
               +config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '');

            {inform parents online}
            Inform_Parents_Online(child,'A ransom has been set for your '+sex7[child.sex]+ukidc+' '+child.name
                                        +config.textcol1+'!');

            {inform parents offline}
            inform_parents(child,
            mailrequest_nothing,
            ulred+'Ransom Demanded!'+config.textcol1,
            mkstring(16,underscore),
            'The kidnappers of your '+sex7[child.sex]+ukidc+' '+child.name+config.textcol1+' demand',
            uyellow+commastr(x)+config.textcol1+' '+many_money(x)+' in exchange for your child.',
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
           end;
          end
          else begin
           crlf;
           d(12,'Ransom operation aborted.');
          end;

          {remove shadow kid}
          add_child(SRemoveChild,child,'','',0);

          crlf;

         end;
        end;

       end;
   'T':begin {transfer a kidnapped child to the Royal Orphanage}

        crlf;
        crlf;
        d(15,'*Get rid of those screaming kids*');

        if select_a_child(player,child,kidnappedchild,excludenone,false)=true then begin

         {add child to online list}
         if add_child(SAddChild,child,player.name2,'being transfered',0)=false then begin
          d(12,child.name+' is busy. try again soon!');
         end
         else begin
          if child.health<>childhealth_normal then begin
           d(12,child.name+' can''t get up from '+sex3[child.sex]+' bed!');
          end
          else begin
           {transfer child to Royal Orphanage}
           crlf;
           d(config.textcolor,'Are you really sure about this!? You will not see '+ukidc+child.name+config.textcol1
               +' again.');

           if confirm('Transfer '+ukidc+child.name+config.textcol1+' to the '+ulmag+'Royal Orphanage'
                      +config.textcol1,'N')=true then begin
            crlf;
            d(15,'Done.');
            d(2,ukidc+child.name+config.textcol1+' is ready to cry when '+sex2[child.sex]
                     +' is dragged out by the royal servants.');
            d(2,ukidc+child.name+config.textcol1+' is transported to the Royal Castle.');
            d(config.textcolor,'(you are a bad '+classnames[player.class]+'!)');
            crlf;

            {update child}
            child.location:=ChildLocation_Orphanage;
            child.kidnapper:='';
            child.kidnapperid:='';
            load_child(fsave,child,child.recnr);

            {inform the king}
            inform_king(
            ulcyan+'Child Arrival'+config.textcol1,
            cool_string(13,'=','-',11,5),
            uplc+player.name2+config.textcol1+' sent the kidnapped child; '+ukidc+child.name
                +config.textcol1+' to the Royal Orphanage.',
            'Your royal highness is now responsible for this child.',
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
            ulred+'Your Children!'+config.textcol1,
            mkstring(14,underscore),
            uplc+player.name2+config.textcol1+' the '+classnames[player.class]+' sent your '+sex7[child.sex]+' '+ukidc
                +child.name+config.textcol1,
            'to the Royal Orphanage. '+ukidc+child.name+config.textcol1+' wants to come home to you!',
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
            'Child Transport',
            ' '+uplc+player.name2+config.textcol1+' transfered one of '+sex3[player.sex]+' kidnapped children',
            ' to the Royal Orphanage.',
            ' '+ukidc+child.name+config.textcol1+', the '+sex7[child.sex]+' of '+uplc+child.mother
              +config.textcol1+' and '+uplc+child.father+config.textcol1+'.',
            '',
            '',
            '',
            '',
            '',
            '');

           end;

           {remove shadow kid}
           add_child(SRemoveChild,child,'','',0);

          end;
         end;
        end;

       end;

   'F':begin {free kidnapped child}
        crlf;
        crlf;
        d(15,'*Set a kid free*');

        if select_a_child(player,child,kidnappedchild,excludenone,false) then begin

         {add child to online list}
         if add_child(SAddChild,child,player.name2,'screaming',0)=false then begin
          d(12,child.name+' is busy. try again soon!');
         end
         else begin
          {transfer child back to parents}
          crlf;
          d(config.textcolor,'Are you really sure about this!? You may never see '+ukidc+child.name+config.textcol1
               +' again.');
          if confirm('Release '+ukidc+child.name+config.textcol1,'N')=true then begin
           crlf;
           d(15,'Done.');
           if child.age<3 then begin
            d(2,ukidc+child.name+config.textcol1+' crawls back home...');
           end
           else begin
            d(2,ukidc+child.name+config.textcol1+' runs back home...');
           end;

           d(2,ukidc+child.name+config.textcol1+' is happy when '+sex2[child.sex]+' is returned to '+sex3[child.sex]
              +' parents.');
           d(config.textcolor,'(you did the right thing!)');

           {update child}
           child.location:=ChildLocation_Home;
           child.kidnapper:='';
           child.kidnapperid:='';
           child.ransom_demanded:=0;
           load_child(fsave,child,child.recnr);

           {inform parents}
           inform_parents_online(child,ukidc+child.name+config.textcol1+' has been '+uyellow+'RELEASED'+config.textcol1+'!');

           {inform parents offline, via mail}
           inform_parents(child,
           mailrequest_nothing,
           uwhite+'Child Released!'+config.textcol1,
           mkstring(15,underscore),
           'Your '+sex7[child.sex]+ukidc+' '+child.name+config.textcol1+' was released by '+sex3[child.sex]+' kidnapper!',
           '('+uplc+player.name2+config.textcol1+' the '+classnames[player.class]+')',
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
           'Child Released!',
           ' '+ukidc+child.name+config.textcol1+', the '+sex7[child.sex]+' of '+uplc+child.mother
              +config.textcol1+' and '+uplc+child.father+config.textcol1+' was released by '
              +sex3[child.sex]+' kidnapper!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

          end;

          {remove shadow kid}
          add_child(SRemoveChild,child,'','',0);

         end;
        end;

       end;

  end; {case .end.}

 until kidnappmenu_done=true;

end; {Kidnapped_Children *end*}



end. {Unit Children .end.}
