{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{ Usurper Editor - XBoxes
This Unit was originally taken from the SWAG collection (OOP section) and
then modified to meet with Jakob and Usurpers needs
}

unit XBoxes;

interface

uses
  Dialogs, Objects, Menus,
  Views, Drivers, MsgBox;

type
  XDialogP = ^XDialog;
  XDialog  = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure TxtEntry(x, y: byte; const txt: string; max, max2: byte; hint: word);
    procedure ValEntry(x, y: byte; const txt: string; max: byte; liten, stor: longint; hint: word);
    procedure MakeButton(x, y, w: byte; const Txt: string; cmd, mode, hint: word);
    procedure OKButton(x, y: byte);
    procedure CancelButton(x, y: byte);
    procedure Static(x, y: byte; const txt: string);
    procedure CheckBoxes(const txt: string; x, y, w, z: byte; Items: PSItem; shadow: boolean; hint: word);
    procedure RadioButtons(const txt: string; flat, top: boolean; x, y, w, z: byte; Items: PSItem; hint: word);
    function GetPalette: PPalette; virtual;

  end;

  TeckenSet = set of char;

const okTeck: TeckenSet = [#0..#31, '0'..'9', '.', ',', '+', '-'];

type

  JakeCheckBoxesP = ^TJakeCheckBoxes;
  TJakeCheckBoxes = object(TCheckBoxes)
    procedure HandleEvent(var Event: tevent); virtual;
  end;

  PValInputLine = ^TValInputLine;
  TValInputLine = object(TInputLine)
  private
    okTeck: TeckenSet;
  public
    small, big: longint;
    constructor Init(var inrad: trect; mlen: integer; aktteck: teckenset; liten, stor: longint);
    function Valid(Command: word): boolean; virtual;
    procedure HandleEvent(var Event: tevent); virtual;
    procedure GetData(var r); virtual;
    procedure SetData(var r); virtual;
    function DataSize: word; virtual;
  end;

type MyInputLineP = ^TMyInputLine;
  TMyInputLine    = object(TInputLine)
    procedure HandleEvent(var Event: tevent); virtual;
  end;


implementation

uses
  Init, Cms, Jakobe;

{----JAKE CHECKBOXES START------}
procedure TJakeCheckBoxes.HandleEvent(var Event: Tevent);
begin

  inherited HandleEvent(Event);

  case Event.What of
    evKeyDown: begin
      if Event.KeyCode = KbDown then
      begin

        with Event do
        begin
          What := EvKeyDown;
          Command := KbDown;
        end;
        {PutEvent(Event);}
        {ClearEvent(Event);}

      end else if Event.KeyCode = KbUp then
      begin
        with Event do
        begin
          What := EvKeyDown;
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
procedure TMyInputLine.HandleEvent(var Event: Tevent);
begin

  inherited HandleEvent(Event);

  case Event.What of
    evKeyDown: begin
      if Event.KeyCode = KbEnter then
      begin

        with Event do
        begin
          What := EvKeyDown;
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
constructor TValInputLine.Init(var inrad: trect; mlen: integer; aktTeck: teckenset; liten, stor: longint);
begin
  TInputLine.init(inrad, mlen);
  small := liten; big := stor;
  okteck := aktteck;
end;

function TValInputLine.Valid(Command: word): boolean;
var  l: longint;
  s:    string;
begin

  str(l, Data^);
  Valid := True;
  if (l < small) or (l > big) then
  begin
    str(small, s);
    Data^ := s;
    messagebox(commastr(l) + ' VALID ERROR!', nil, mfokbutton);

    valid := False;
  end;

end;

procedure TValInputLine.HandleEvent(var Event: Tevent);
var l:    longint;
  errorL: integer;
  n1, n2: string[30];
  def:    string;
begin

  str(small, n1); {min value allowed}
  str(big, n2);   {max value allowed}
  str(small, def);

  inherited HandleEvent(Event);

  case Event.What of
    evKeyDown: begin

      if not (Event.CharCode in OkTeck) then
      begin
        ClearEvent(Event);
      end else
      begin
        if Data^ <> '' then
        begin
          val(Data^, l, errorl);
          if (errorl <> 0) then
          begin
            messagebox('Error!', nil, mfokbutton);
          end else if (l < small) or (l > big) then
          begin
            Data^ := def;
            messagebox('Enter a Number between ' + n1 + ' and ' + n2 + '!', nil, mfokbutton);
            selectall(False);
          end else
          begin
            if Event.KeyCode = KbEnter then
            begin

              with Event do
              begin
                What := EvKeyDown;
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

procedure TValInputLine.GetData(var r);
var errorl: integer;
begin
  val(Data^, longint(r), errorl);
end;

procedure TValInputLine.SetData(var r);
begin
  str(longint(r), Data^);
  draw;
end;

function TValInputLine.DataSize: word;
begin
  datasize := sizeof(longint);
end;

{----VALUE InputLine END------}



{------ XDIALOG START--------}
procedure XDialog.HandleEvent(var Event: TEvent);
begin

  inherited HandleEvent(event);

  case event.what of
    evkeydown: begin
      case event.KeyCode of
        KbUp: FocusNext(True);
        KbDown: FocusNext(False);
        KbRight: FocusNext(False);
        KbLeft: FocusNext(True);
      end;
      ClearEvent(Event);
    end;
  end;

end;

procedure XDialog.MakeButton(x, y, w: byte; const Txt: string; cmd, mode, hint: word);
var
{ Insert a button with the specified text, command, width, and mode at
  the x,y coordinates in the dialog box; hint=constant pointing at HcX }
  R:    TRect;
  Temp: PButton;
begin;
  R.Assign(x, y, x + w, y + 2);
  Temp := New(PButton, Init(R, Txt, cmd, mode));

  Temp^.HelpCtx := hint;
  Insert(Temp);
end;

procedure XDialog.OKButton(x, y: byte);
{ Create and insert an 'OK' Button at x,y coordinates }
begin;
  MakeButton(x, y, 10, '~O~K', cmOK, bfNormal + bfgrabfocus, hcGenOk);
end;

procedure XDialog.CancelButton(x, y: byte);
{ Create and insert a 'Cancel' button }
begin;
  MakeButton(x, y, 10, '~C~ancel', cmCancel, bfNormal + bfgrabfocus, hcGENCancel);
end;

procedure XDialog.TxtEntry(x, y: byte; const txt: string; max, max2: byte; hint: word);
{max2 states how many chars you want to diaplay in your textbox.
 max has to be exactly specified or program will hang :) }
var
  w:  byte;
  ID: PView;
  R:  TRect;

begin;

  GetExtent(R);
  {R.Assign(x+Length(txt)+2,y,R.B.X-2,y+1);  old row, Jakob edits happily!}
  R.Assign(x + Length(txt) + 2, y, max2 + 1 + length(txt), y + 1);

  ID := New(MyInputLineP, Init(R, max));
  ID^.HelpCtx := hint;
  Insert(ID);

  R.Assign(x, y, x + Length(txt) + 1, y + 1);
  Insert(New(PLabel, Init(R, txt, ID)));

end;

procedure XDialog.ValEntry(x, y: byte; const txt: string; max: byte; liten, stor: longint; hint: word);
var
  ID: PView;
  R:  TRect;

begin;
  GetExtent(R);
  R.Assign(x + Length(txt) + 2, y, x + max + length(txt) + 2, y + 1);
  ID := New(PValInputLine, Init(R, max, okteck, liten, stor));
  Insert(ID);
  R.Assign(x, y, x + Length(txt) + 1, y + 1);
  ID^.HelpCtx := hint;
  Insert(New(PLabel, Init(R, txt, ID)));
end;

procedure XDialog.Static(x, y: byte; const txt: string);
{ Static text at x,y }
var
  R: TRect;
begin;
  R.Assign(x, y, x + Length(txt) + 1, y + 1);
  Insert(New(PStaticText, Init(R, txt)));
end;

procedure XDialog.CheckBoxes(const txt: string; x, y, w, z: byte; Items: PSitem; shadow: boolean; hint: word);
{ Insert check boxes for cluster 'Items' at x,y with a maximum width of
  w and a total of z items. }
var
  R:     TRect;
  amask: longint;
  ID:    PCheckboxes;
  lab:   PLabel;
begin;

  R.Assign(x, y, x + (w + 3) + 1, y + z);

  ID := New(PCheckBoxes, Init(R, Items));
  ID^.HelpCtx := Hint;
  Insert(ID);

  if shadow then
  begin
    AMask := ID^.EnableMask;
    ID^.SetButtonState(Amask, False);
  end;

  if txt <> '' then
  begin
    R.Assign(x, y - 1, x + Length(txt) + 1, y);
    lab := New(PLabel, Init(R, txt, ID));
    lab^.helpCtx := hcNada;
    Insert(lab);
  end;

end;

procedure XDialog.RadioButtons(const txt: string; flat, top: boolean; x, y, w, z: byte; Items: PSItem; hint: word);
{ Insert radio buttons for cluster 'Items' at x,y with a maximum width of
  w and a total of z items. }
var
  R:   TRect;
  ID:  PView;
  y2:  byte;
  lab: plabel;

begin;

  if flat then
  begin
    z := 1;
  end;

  if txt <> '' then y2 := 1
  else y2 := 0;

  if top then R.Assign(x, y + y2, x + (w + 3) + 1, y + z + y2)
  else R.Assign(x + 1 + length(txt), y, length(txt) + x + (w + 3) + 1 + 1 + 1, y + z);

  ID := New(PRadioButtons, Init(R, Items));
  id^.helpCtx := hint;
  insert(ID);

  if txt <> '' then
  begin
    R.Assign(x, y, x + Length(txt) + 1, y + 1);
    lab := New(PLabel, Init(R, txt, ID));
    lab^.helpCtx := hint;
    Insert(lab);
  end;

end;

{shit test}

const
  CNewDialog = CDialog + #64#65;

function Xdialog.GetPalette: PPalette;
const
  P: string[Length(CNewDialog)] = CNewDialog;
begin
  GetPalette := @P;
end;

end.
