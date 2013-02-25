{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{
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

program ListBoxApp;
{$X+}

uses
  Drivers, Objects, Views, App, Dialogs, MsgBox, Dos,
  defcfg;

const maxcdef =100;

type
  PNewListBox = ^TNewListBox;
  TNewListBox = object(TListBox)
    procedure SelectItem(Item : integer); virtual;
  end; { TNewListBox }

  PListDialog = ^TListDialog;
  TListDialog = object(TDialog)
    ListBox: PNewListBox;
    ListCollection: PStringCollection;
    constructor Init(var Bounds: TRect; ATitle: TTitleStr);
    destructor Done; virtual;
    function Valid(Command: Word): Boolean; virtual;
  end; { TListDialog }

  TListBoxApp = object(TApplication)
    procedure Run; virtual;
  end; { TListBoxApp }

procedure TNewListBox.SelectItem(Item : integer);
begin
  TListBox.SelectItem(Item);
  { Tell us what we selected }
  MessageBox(String(List^.At(Focused)^),
             nil, mfInformation or mfOkButton);
end; { TNewListBox.SelectItem }

constructor TListDialog.Init(var Bounds: TRect;
  ATitle: TTitleStr);
var
  R: TRect;
  ScrollBar: PScrollBar;
  var i : byte;
  bu :string;
begin

  TDialog.Init(Bounds, ATitle);
  R.Assign(5,14,15,16);
  Insert(New(PButton, Init(R, '~O~k', cmOk, bfDefault)));

  R.Assign(16,14,26,16);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfDefault)));

  str(memavail,bu);
  R.Assign(28,14,40,16);
  Insert(New(PButton, Init(R, '!  '+bu, cmCancel, bfDefault)));

  R.Assign(71,2,72,13);
  New(ScrollBar, Init(R));
  Insert(ScrollBar);

  R.Assign(3,2,70,13); {display boxen}
  New(ListBox, Init(R, 1, ScrollBar));
  Insert(ListBox);

  New(ListCollection, Init(30, 10));
  { Fill list box with file names }
  for i:=1 to maxcdef do begin
   ListCollection^.ATInsert(i-1,NewStr(default_cfg(i,true)));
  end;

  ListBox^.NewList(ListCollection);
end; { TListDialog.Init }

destructor TListDialog.Done;
begin
  ListBox^.NewList(nil);
  TDialog.Done;
end; { TListDialog.Done }

function TListDialog.Valid(Command: Word): Boolean;
var
  P: PString;
begin
  Valid := True;
 { if Command = cmOk then begin
   Valid := False;
   begin
     with ListCollection^, ListBox^ do
       if Range > 0 then
       begin
         AtFree(Focused);
         SetRange(Count);
         if Range <> 0 then
           FocusItem(Focused - Byte(Focused = Range));
       end;
   end;
   ListBox^.DrawView;
  end; }
end; { TListDialog.Valid }

procedure TListBoxApp.Run;
var
  Dialog: PListDialog;
  R: TRect;
begin
  R.Assign(2,1,78,20);
  New(Dialog, Init(R, 'Usurper Configuration'));
  DeskTop^.ExecView(Dialog);
  Dispose(Dialog, Done);
end; { TListBoxApp.Run }


{------------------------}

var
  ListBoxMain: TListBoxApp;

begin
  ListBoxMain.Init;
  ListBoxMain.Run;
  ListBoxMain.Done;
end. { ListBoxApp }