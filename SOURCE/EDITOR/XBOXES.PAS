{$I DEFINES.INC}
{ Usurper Editor - XBoxes
This Unit was originally taken from the SWAG collection (OOP section) and
then modified to meet with Jakob and Usurpers needs
}

Unit XBoxes;

Interface

Uses Dialogs, Objects,
     Views, Drivers, MsgBox;

Type
  XDialogP = ^XDialog;
  XDialog = Object(TDialog)
     Procedure HandleEvent(var Event: TEvent); virtual;
     Procedure TxtEntry (x,y : Byte; const txt : string; max,max2 : Byte;hint:word);
     Procedure ValEntry (x,y : Byte; const txt : string; max : Byte;liten,stor:longint;hint:word);
     Procedure MakeButton(x,y,w: Byte; const Txt: string; cmd,mode,hint: Word);
     Procedure OKButton(x,y : Byte);
     Procedure CancelButton(x,y : Byte);
     Procedure Static(x,y : Byte; const txt : string);
     Procedure CheckBoxes(const txt:string;x,y,w,z : Byte; Items : PSItem;shadow:boolean;hint:word);
     Procedure RadioButtons(const txt: string;flat,top:boolean;x,y,w,z : Byte; Items : PSItem;hint:word);
     function GetPalette: PPalette; virtual;

  End;

TeckenSet = Set of Char;

Const okTeck  : TeckenSet = [#0..#31,'0'..'9','.',',','+','-'];

Type

     JakeCheckBoxesP = ^TJakeCheckBoxes;
     TJakeCheckBoxes = Object(TCheckBoxes)
                        Procedure HandleEvent(var Event:tevent);virtual;
                       end;

     PValInputLine = ^TValInputLine;
     TValInputLine = Object(TInputLine)
                     Private
                      okTeck:TeckenSet;
                      Public
                       small,big : longint;
                       Constructor Init(var inrad:trect;mlen:integer;aktteck:teckenset;liten,stor:longint);
                       Function  Valid(Command: Word): Boolean; virtual;
                       Procedure HandleEvent(var Event:tevent);virtual;
                       Procedure GetData(var r); virtual;
                       Procedure SetData(var r); virtual;
                       Function DataSize:sw_word; virtual;
                    end;

Type MyInputLineP = ^TMyInputLine;
     TMyInputLine = Object(TInputLine)
                     Procedure HandleEvent(var Event:tevent);virtual;
                    end;


Implementation

Uses Init, Cms, Jakobe;

{----JAKE CHECKBOXES START------}
Procedure TJakeCheckBoxes.HandleEvent(var Event:Tevent);
begin

 Inherited HandleEvent(Event);

 case Event.What of
  evKeyDown:begin
             if Event.KeyCode = KbDown then begin


              With Event do begin
               What    := EvKeyDown;
               Command := KbDown;
              end;
              {PutEvent(Event);}
              {ClearEvent(Event);}

             end
             else if Event.KeyCode = KbUp then begin
              With Event do begin
               What    := EvKeyDown;
               Command := KbUp;
              end;
              {PutEvent(Event);}
              {ClearEvent(Event);}
             end;
            end;
 end;

 TCheckBoxes.HandleEvent(event);

end;
{----JAKE CHECKBOXES END------}

{----MY INPUTLINE START------}
Procedure TMyInputLine.HandleEvent(var Event:Tevent);
begin

 Inherited HandleEvent(Event);

 case Event.What of
  evKeyDown:begin
             if Event.KeyCode = KbEnter then begin

              With Event do begin
               What    := EvKeyDown;
               Command := KbTab;
              end;
              {PutEvent(Event)}

             end;
            end;
 end;

 TInputline.HandleEvent(event);

end;
{----MY INPUTLINE END------}


{----VALUE InputLine START------}
Constructor TValInputLine.Init(var inrad:trect; mlen:integer;aktTeck:teckenset;liten,stor:longint);
begin
 TInputLine.init(inrad,mlen);
 small:=liten; big:=stor;
 okteck:=aktteck;
end;

Function TValInputLine.Valid(Command: Word): Boolean;
var  l : longint;
     s : string;
begin

 str(l,data^);
 Valid := true;
 if (l<small) or (l>big) then begin
  str(small,s);
  data^:=s;
  messagebox(commastr(l)+' VALID ERROR!',nil,mfokbutton);

  valid:=false;
 end;

end;

Procedure TValInputLine.HandleEvent(var Event:Tevent);
var l:longint;
    errorL: integer;
    n1,n2 : string[30];
    def :string;
begin

 str(small,n1); {min value allowed}
 str(big,n2);   {max value allowed}
 str(small,def);

 Inherited HandleEvent(Event);

 case Event.What of
  evKeyDown:begin

             if Not (Event.CharCode in OkTeck) then begin
              ClearEvent(Event);
             end
             else begin
              if data^<>'' then begin
               val(data^,l,errorl);
               if (errorl<>0) then begin
                messagebox('Error!',nil,mfokbutton);
               end
               else if (l<small) or (l>big) then begin
                data^:=def;
                messagebox('Enter a Number between '+n1+' and '+n2+'!',nil,mfokbutton);
                selectall(false);
               end
               else begin
                if Event.KeyCode = KbEnter then begin

                 With Event do begin
                  What    := EvKeyDown;
                  Command := KbTab;
                 end;
                 {PutEvent(Event);}

                end;
               end;
              end;
             end;
            end;
 end;

 TInputline.HandleEvent(event);

end;

Procedure TValInputLine.GetData(var r);
var errorl : integer;
begin
 val(Data^,longint(r),errorl);
end;

Procedure TValInputLine.SetData(var r);
begin
 str(longint(r),Data^);
 draw;
end;

Function TValInputLine.DataSize:sw_word;
begin
 datasize:=sizeof(longint);
end;
{----VALUE InputLine END------}



{------ XDIALOG START--------}
Procedure XDialog.HandleEvent(var Event: TEvent);
begin

 inherited HandleEvent(event);

 case event.what of
  evkeydown:begin
             case event.KeyCode of
              KbUp   : FocusNext(true);
              KbDown : FocusNext(false);
              KbRight: FocusNext(false);
              KbLeft : FocusNext(true);
             end;
             ClearEvent(Event);
            end;
 end;


end;

Procedure XDialog.MakeButton(x,y,w: Byte; const Txt: string; cmd, mode,hint: Word);
var
{ Insert a button with the specified text, command, width, and mode at
  the x,y coordinates in the dialog box; hint=constant pointing at HcX }
   R    : TRect;
   Temp : PButton;
Begin;
 R.Assign(x,y,x+w,y+2);
 Temp := New(PButton,Init(R,Txt,cmd,mode));

 Temp^.HelpCtx:=hint;
 Insert(Temp);
End;

Procedure XDialog.OKButton(x,y : Byte);
{ Create and insert an 'OK' Button at x,y coordinates }
Begin;
 MakeButton(x,y,10,'~O~K',cmOK,bfNormal+bfgrabfocus,hcGenOk);
End;

Procedure XDialog.CancelButton(x,y : Byte);
{ Create and insert a 'Cancel' button }
Begin;
 MakeButton(x,y,10,'~C~ancel',cmCancel,bfNormal+bfgrabfocus,hcGENCancel);
End;

Procedure XDialog.TxtEntry(x,y : Byte; const txt : string; max,max2 : Byte;hint:word);
{max2 states how many chars you want to diaplay in your textbox.
 max has to be exactly specified or program will hang :) }
Var
   ID : PView;
   R : TRect;

Begin;

   GetExtent(R);
   {R.Assign(x+Length(txt)+2,y,R.B.X-2,y+1);  old row, Jakob edits happily!}
   R.Assign(x+Length(txt)+2,y,max2+1+length(txt),y+1);

   ID := New(MyInputLineP,Init(R,max));
   ID^.HelpCtx:=hint;
   Insert(ID);

   R.Assign(x,y,x+Length(txt)+1,y+1);
   Insert(New(PLabel,Init(R,txt,ID)));

End;

Procedure XDialog.ValEntry( x,y : byte; const txt : string; max : Byte;
                            liten,stor : longint; hint : word);
Var
   ID : PView;
   R  : TRect;

Begin;
   GetExtent(R);
   R.Assign(x+Length(txt)+2,y,x+max+length(txt)+2,y+1);
   ID := New(PValInputLine,Init(R,max,okteck,liten,stor));
   Insert(ID);
   R.Assign(x,y,x+Length(txt)+1,y+1);
   ID^.HelpCtx:=hint;
   Insert(New(PLabel,Init(R,txt,ID)));
End;

Procedure XDialog.Static(x,y : Byte; const txt : string);
{ Static text at x,y }
Var
   R : TRect;
Begin;
   R.Assign(x,y,x+Length(txt)+1,y+1);
   Insert(New(PStaticText,Init(R,txt)));
End;

Procedure XDialog.CheckBoxes(const txt:string;x,y,w,z : Byte; Items : PSitem;shadow:boolean;hint:word);
{ Insert check boxes for cluster 'Items' at x,y with a maximum width of
  w and a total of z items. }
Var
   R : TRect;
   amask : longint;
   ID : PCheckboxes;
   lab : PLabel;
Begin;

 R.Assign(x,y,x+(w+3)+1,y+z);

 ID:=New(PCheckBoxes,Init(R,Items));
 ID^.HelpCtx:=Hint;
 Insert(ID);

 if shadow then begin
  AMask:=ID^.EnableMask;
  ID^.SetButtonState(Amask,False);
 end;

 if txt<>'' then begin
  R.Assign(x,y-1,x+Length(txt)+1,y);
  lab:=New(PLabel,Init(R,txt,ID));
  lab^.helpCtx:=hcNada;
  Insert(lab);
 end;

End;

Procedure XDialog.RadioButtons(const txt:string;flat,top:boolean;
                               x,y,w,z : Byte; Items : PSItem;hint:word);
{ Insert radio buttons for cluster 'Items' at x,y with a maximum width of
  w and a total of z items. }
Var
   R : TRect;
   ID: PView;
   y2 : byte;
   lab : plabel;

Begin;

 if flat then begin
  z:=1;
 end;

 if txt<>'' then y2:=1
            else y2:=0;

 if top then R.Assign(x,y+y2,x+(w+3)+1,y+z+y2)
        else R.Assign(x+1+length(txt),y,length(txt)+x+(w+3)+1+1+1,y+z);

 ID:=New(PRadioButtons,Init(R,Items));
 id^.helpCtx:=hint;
 insert(ID);

 if txt<>'' then begin
  R.Assign(x,y,x+Length(txt)+1,y+1);
  lab:=New(PLabel,Init(R,txt,ID));
  lab^.helpCtx:=hint;
  Insert(lab);
 end;

End;

{shit test}

  const
    CNewDialog = CDialog + #64#65;

function Xdialog.GetPalette: PPalette;
const
 P: String[Length (CNewDialog)] = CNewDialog;
begin
 GetPalette := @P;
end;

End.
