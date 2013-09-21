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
  {$H-}
  {$V-}
  {$DEFINE USE32} // HELPFILE.PAS needs this to use the right ASM block
{$ENDIF}
