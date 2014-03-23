{$IFDEF VPASCAL}
  {&AlignRec-}
  {&Delphi-}
  {&Use32+}
  {$H-}
  {$V-}
  
  {$IFDEF LINUX}
    {$DEFINE UNIX}
  {$ENDIF}
  {$IFDEF WIN32}
    {$DEFINE WINDOWS}
  {$ENDIF}
{$ENDIF}

{$IFDEF FPC}
  {$mode tp}
  {$asmmode intel}
  {$PACKRECORDS 1}
  {$packset 1} // Default as of 2.5.1, but doesn't hurt to include
  {$H-}
  {$V-}
  {$DEFINE USE32} // HELPFILE.PAS needs this to use the right ASM block
{$ENDIF}
