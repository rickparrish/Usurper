{$I DEFINES.INC}
{************************************************}

{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }

{************************************************}

 {slightly modified by Jakob, search for 'Jakob' to see where he has
  added / changed stuff}


unit ViewText;

{$O+,X+,S-,D-}

interface

uses
  Objects, Views, Dos, Drivers;

type

  { TLineCollection }

  PLineCollection = ^TLineCollection;
  TLineCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

  { TFileViewer }

  PFileViewer = ^TFileViewer;
  TFileViewer = object(TScroller)
    FileName:  PString;
    FileLines: PCollection;
    IsValid:   boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar; const AFileName: PathStr);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure ReadFile(const FName: PathStr);
    procedure SetState(AState: word; Enable: boolean); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: word): boolean; virtual;
  end;

  { TTextWindow }

  PTextWindow = ^TTextWindow;
  TTextWindow = object(TWindow)
    constructor Init(R: TRect; const FileName: PathStr);
    procedure HandleEvent(var Event: TEvent); virtual; {Jakob added this}
  end;

const

  RFileViewer: TStreamRec = (
    ObjType: 10080;
    VmtLink: Ofs(TypeOf(TFileViewer)^);
    Load: @TFileViewer.Load;
    Store: @TFileViewer.Store
    );
  RTextWindow: TStreamRec = (
    ObjType: 10081;
    VmtLink: Ofs(TypeOf(TTextWindow)^);
    Load: @TTextWindow.Load;
    Store: @TTextWindow.Store
    );

procedure RegisterFViewer;

implementation

uses
  Memory, MsgBox;

{ TLineCollection }
procedure TLineCollection.FreeItem(P: Pointer);
begin
  DisposeStr(P);
end;

{ TFileViewer }
constructor TFileViewer.Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar; const AFileName: PathStr);
begin
  TScroller.Init(Bounds, AHScrollbar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  FileName := nil;
  ReadFile(AFileName);
end;

constructor TFileViewer.Load(var S: TStream);
var
  FName: PathStr;
begin
  TScroller.Load(S);
  FileName := S.ReadStr;
  FName := FileName^;
  ReadFile(FName);
end;

destructor TFileViewer.Done;
begin
  Dispose(FileLines, Done);
  DisposeStr(FileName);
  TScroller.Done;
end;

procedure TFileViewer.Draw;
var
  B: TDrawBuffer;
  C: byte;
  I: integer;
  S: string;
  P: PString;
begin
  C := GetColor(1);
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    if Delta.Y + I < FileLines^.Count then
    begin
      P := FileLines^.At(Delta.Y + I);
      if P <> nil then S := Copy(P^, Delta.X + 1, Size.X)
      else S := '';
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TFileViewer.ReadFile(const FName: PathStr);
var
  FileToView: Text;
  Line:       string;
  MaxWidth:   integer;
begin
  IsValid := True;
  if FileName <> nil then DisposeStr(FileName);
  FileName := NewStr(FName);
  FileLines := New(PLineCollection, Init(5, 5));
  {$I-}
  Assign(FileToView, FName);
  Reset(FileToView);
  if IOResult <> 0 then
  begin
    MessageBox('Cannot open file ' + FName + '.', nil, mfError + mfOkButton);
    IsValid := False;
  end else
  begin
    MaxWidth := 0;
    while not EOF(FileToView) and not LowMemory do
    begin
      Readln(FileToView, Line);
      if Length(Line) > MaxWidth then MaxWidth := Length(Line);
      FileLines^.Insert(NewStr(Line));
    end;
    Close(FileToView);
  end;
  {$I+}
  Limit.X := MaxWidth;
  Limit.Y := FileLines^.Count;
end;

procedure TFileViewer.SetState(AState: word; Enable: boolean);
begin
  TScroller.SetState(AState, Enable);
  if Enable and (AState and sfExposed <> 0) then SetLimit(Limit.X, Limit.Y);
end;

procedure TFileViewer.Store(var S: TStream);
begin
  TScroller.Store(S);
  S.WriteStr(FileName);
end;

function TFileViewer.Valid(Command: word): boolean;
begin
  Valid := IsValid;
end;

{ TTextWindow }
procedure TTextWindow.HandleEvent(var Event: TEvent); {Jakob added this proc}
begin

  inherited HandleEvent(event);

  case event.what of
    EvKeyDown: begin
      case Event.KeyCode of
        kbEsc: begin
          Event.What := evCommand;
          Event.Command := cmClose;
          PutEvent(Event);
        end;
      end;
      DrawView;
      ClearEvent(Event);
    end;
    EvCommand: begin
      case Event.Command of
        CmCancel: begin
          EndModal(CmClose);
        end;
      end;
      DrawView;
      ClearEvent(Event);
    end;
  end;

end;



constructor TTextWindow.Init(R: TRect; const FileName: PathStr);
begin
  inherited Init(R, Filename, wnNoNumber);
  Options := Options or ofTileable;
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PFileViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard), Filename)));
end;

procedure RegisterFViewer;
begin
  RegisterType(RFileViewer);
  RegisterType(RTextWindow);
end;

end.
