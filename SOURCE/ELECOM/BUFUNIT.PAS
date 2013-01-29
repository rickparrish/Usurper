unit BufUnit;
{$I-,R-,S-,Q-}
(*
**
** Large char-buffer handling routines for EleCOM
**
** Copyright (c) 1998-2002 by Maarten Bekers
**
** Version : 1.03
** Created : 05-Jan-1999
** Last update : 12-Jan-2003
**
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

Type CharBufType = Array[0..65520] of Char;

type BufArrayObj = Object
          TxtArr     : CharBufType;
          TxtMaxLen  : Longint;
          TxtStartPtr: Longint;                      { Start of buffer ptr }
          CurTxtPtr  : Longint;                 { Maximum data entered yet }
          TmpBuf     : CharBufType;

          constructor Init(TxtSize: Longint);
          destructor Done;

          function BufRoom: Longint;
          function BufUsed: Longint;
          function Put(var Buf; Size: Longint): Longint;
          function Get(var Buf; Size: Longint; Remove: Boolean): Longint;

          procedure Clear;
     end; { BufArrayObj }


(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor BufArrayObj.Init(TxtSize: Longint);
begin
  TxtMaxLen := TxtSize;
  CurTxtPtr := -1;
  TxtStartPtr := 0;

  FillChar(TxtArr, TxtMaxLen, #00);
  FillChar(TmpBuf, TxtMaxLen, #00);
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor BufArrayObj.Done;
begin
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function BufArrayObj.BufRoom: Longint;
begin
  BufRoom := (TxtMaxLen - (CurTxtPtr + 1));
end; { func. BufRoom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function BufArrayObj.BufUsed: Longint;
begin
  BufUsed := (CurTxtPtr + 01);
end; { func. BufUsed }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function BufArrayObj.Put(var Buf; Size: Longint): Longint;
var RetSize: Longint;
begin
  Put := 0;
  if Size < 0 then EXIT;

  if TxtStartPtr > 0 then
   if (CurTxtPtr + TxtStartPtr) > TxtMaxLen then
     begin
       Move(TxtArr[TxtStartPtr], TxtArr[0], Succ(CurTxtPtr));
       TxtStartPtr := 0;
     end; { if }

  if Size > BufRoom then RetSize := BufRoom
    else RetSize := Size;

  Move(Buf, TxtArr[TxtStartPtr + BufUsed], RetSize);

  Inc(CurTxtPtr, RetSize);
  TxtArr[TxtStartPtr + BufUsed + 1] := #0;
  Put := RetSize;
end; { func. Put }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function BufArrayObj.Get(var Buf; Size: Longint; Remove: Boolean): Longint;
var RetSize: Longint;
begin
  Get := 0;
  if Size < 0 then EXIT;

  if Size > BufUsed then RetSize := BufUsed
     else RetSize := Size;

  Move(TxtArr[TxtStartPtr], Buf, RetSize);

  Get := RetSize;

  if Remove then
    begin
      if RetSize = BufUsed then
        begin
          CurTxtPtr := -1;
          TxtStartPtr := 0;
          TxtArr[0] := #0;
        end
          else begin
                 Inc(TxtStartPtr, RetSize);
                 Dec(CurTxtPtr, RetSize);
                 TxtArr[CurTxtPtr + TxtStartPtr + 1] := #0;
               end; { if }
    end; { if }
end; { func. Get }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure BufArrayObj.Clear;
begin
  CurTxtPtr := -1;
end; { proc. Clear }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end.
