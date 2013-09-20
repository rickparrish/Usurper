{$IFDEF VPASCAL}
  {&AlignRec-}
  {&Delphi-}
  {&Use32+}
  {$H-}
  {$V-}
{$ENDIF}

{$IFDEF FPC}
  {$mode tp}
  {$H-}
  {$V-}
  {$DEFINE USE32} // HELPFILE.PAS needs this to use the right ASM block
{$ENDIF}
