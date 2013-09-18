{$I DEFINES.INC}
unit shadow;

{ Provides basic routines needed to implement Shadow Classes }
interface

function ValidVMT(VMT: pointer): boolean;
function FindMethodSlot(AMethod: pointer; ClassVMT: pointer): pointer;
function ReplaceMethod(ClassVMT, OldMethod, NewMethod: pointer): boolean;

{ Basic VMT structure }
const
  MaxVMTPointers = 192;
type
  PMethodTable = ^TMethodTable;
  TMethodTable = array[0..MaxVMTPointers] of pointer;

  PVMT = ^TVMT;
  TVMT = record
    Size:  word; NegSize: integer;
    Table: TMethodTable;
  end;

  PDMT = ^TDMT;
  TDMT = record
    BaseDMT: word;
    Cache: record
      Index, Entry: word;
    end;
    Cnt: word;
  end;

implementation

{===============================================}
function ValidVMT(VMT: pointer): boolean;
   { Checks to see if VMT is a pointer to a valid Virtual
     Method Table. This is not foolproof, but is all TP has
     provided for such a check.  This is the same check used
     by runtime system with range checking.                   }
begin
  ValidVMT := ((PVMT(VMT)^.size <> 0) and
    ((PVMT(VMT)^.Size + PVMT(VMT)^.NegSize) = 0));
end;

{------------------------------------------------------}
  {Find a Method in a Virtual Method Table (VMT).  If found return
   pointer to the location of the Method's reference in the
   VMT.  If not found, return a nil pointer.                        }
function FindMethodSlot(AMethod: pointer; ClassVMT: pointer): pointer;
var
  VMT:  PVMT absolute ClassVmt;
  Slot: word;
begin
  { Returns a pointer to AMethod's location in the VMT Table }
  if ValidVMT(VMT) then with VMT^ do
    begin
      Slot := 0;
      while (Slot < MaxVMTPointers) and (Table[Slot] <> AMethod) do Inc(Slot);
      if Slot < MaxVMTPointers then FindMethodSlot := @Table[Slot]
      else
        FindMethodSlot := nil;
    end;
end;

{---------------------------------------------------------}
function ReplaceMethod(ClassVMT, OldMethod, NewMethod: pointer): boolean;
var
  P: ^Pointer;
  { Find OldMethod in VMT/DMT and Replace it with NewMethod }
begin
  P := FindMethodSlot(OldMethod, ClassVmt);
  if P <> nil then
  begin
    P^ := NewMethod;
    ReplaceMethod := True;
  end else
    ReplaceMethod := False;
end;

end.
