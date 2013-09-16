{$I DEFINES.INC}
{*********************************************************}
{*                   ANSICOLR.PAS 1.0                    *}
{*            Copyright (c) Ì ·ETATech Ì 1991.           *}
{*                 All rights reserved.                  *}
{*********************************************************}
{ Wed  12-18-1991 v1.0                                    }
{ This unit is patterned after the TurboPower OPCOLOR     }
{ unit.  OPCOLOR allows the programmer to specify screen  }
{ colors with easily rememberable names like "RedOnBlue". }
{ I wanted a way to specify the same type of color        }
{ definitions, but have the ANSI escape sequence for that }
{ combination to be the output.  Hopfully this unit will  }
{ accomplish this task making ANSI colors easier for the  }
{ programmer.                                             }
{                                                         }
{ The naming conventions of ANSICOLR are similar to that  }
{ of OPCOLOR except that all names begin with a lower     }
{ case "a" (ie. aRedOnBlack).  This will return the ANSI  }
{ escape code that will enable this color combination.    }
{ All low intensity forground combinations start by       }
{ setting the previous colors off, then define the new    }
{ color set.  To get a color set with the foreground set  }
{ to blink, just preface the color combination with "ab"  }
{ (ie. abRedOnBlue).  Each low intensity color combination}
{ is 10 char., each high intensity color set is 12 char.  }
{ and each blinking color set is 14 char. long.           }
{                                                         }
{ I retain the copyright for this unit, but release it for}
{ public use with no royalties required.  You may use it  }
{ in any program that it would be of assistance to you.   }
{ In the same regard, I offer NO WARANTEE what so ever    }
{ either express or implied.                              }
{                                                         }
{ If you come up with enhancements or changes to this unit}
{ I would appreciate knowing about them as I would like to}
{ keep the unit up to date.  I can be reached at the      }
{ places listed below:                                    }
{                                                         }
{ ·ETATech Computer Consulting           The Paradigm BBS }
{ P. O. Box 566742                           404/671-1581 }
{ Atlanta, GA  30356-6013                  1200-19200 HST }
{*********************************************************}

UNIT AnsiColr; {Usurper - this ansi unit was taken from the SWAG archive}

INTERFACE

CONST

  aBlink    : BYTE =  16;
  
  aSt       : STRING [2] = #27'[';
  aEnd      : STRING [1] = 'm';
  aDef      : STRING [4] = #27'[0m';
  
  fgCol     : ARRAY [0..31] OF STRING [8] =
    ('0;30',   '0;34',   '0;32',   '0;36',
     '0;31',   '0;35',   '0;33',   '0;37',
     '0;1;30', '0;1;34', '0;1;32', '0;1;36', 
     '0;1;31', '0;1;35', '0;1;33', '0;1;37',
     '0;5;30', '0;5;34', '0;5;32', '0;5;36',
     '0;5;31', '0;5;35', '0;5;33', '0;5;37',
     '0;1;5;30', '0;1;5;34', '0;1;5;32', '0;1;5;36', 
     '0;1;5;31', '0;1;5;35', '0;1;5;33', '0;1;5;37');

  bgCol     : ARRAY [0..7] OF STRING [4] =
    (';40',   ';44',   ';42',   ';46',   ';41',   ';45',   ';43',   ';47');

TYPE
  Str14     = STRING [14];

  {Black background}
  FUNCTION aBlackOnBlack :       Str14;
  FUNCTION abBlackOnBlack :      Str14;
  FUNCTION aBlueOnBlack :        Str14;
  FUNCTION abBlueOnBlack :       Str14;
  FUNCTION aGreenOnBlack :       Str14;       
  FUNCTION abGreenOnBlack :      Str14;       
  FUNCTION aCyanOnBlack :        Str14;
  FUNCTION abCyanOnBlack :       Str14;
  FUNCTION aRedOnBlack :         Str14; 
  FUNCTION abRedOnBlack :        Str14; 
  FUNCTION aMagentaOnBlack :     Str14;      
  FUNCTION abMagentaOnBlack :    Str14;      
  FUNCTION aBrownOnBlack :       Str14;     
  FUNCTION abBrownOnBlack :      Str14;     
  FUNCTION aLtGrayOnBlack :      Str14; 
  FUNCTION abLtGrayOnBlack :     Str14; 
  FUNCTION aDkGrayOnBlack :      Str14;        
  FUNCTION abDkGrayOnBlack :     Str14;        
  FUNCTION aLtBlueOnBlack :      Str14;
  FUNCTION abLtBlueOnBlack :     Str14;
  FUNCTION aLtGreenOnBlack :     Str14;
  FUNCTION abLtGreenOnBlack :    Str14;
  FUNCTION aLtCyanOnBlack :      Str14;
  FUNCTION abLtCyanOnBlack :     Str14;
  FUNCTION aLtRedOnBlack :       Str14;      
  FUNCTION abLtRedOnBlack :      Str14;       
  FUNCTION aLtMagentaOnBlack :   Str14;    
  FUNCTION abLtMagentaOnBlack :  Str14;    
  FUNCTION aYellowOnBlack :      Str14;      
  FUNCTION abYellowOnBlack :     Str14;    
  FUNCTION aWhiteOnBlack :       Str14;       
  FUNCTION abWhiteOnBlack :      Str14;       

  {Blue background}
  FUNCTION aBlackOnBlue :        Str14; 
  FUNCTION abBlackOnBlue :       Str14;  
  FUNCTION aBlueOnBlue :         Str14; 
  FUNCTION abBlueOnBlue :        Str14;  
  FUNCTION aGreenOnBlue :        Str14; 
  FUNCTION abGreenOnBlue :       Str14;  
  FUNCTION aCyanOnBlue :         Str14; 
  FUNCTION abCyanOnBlue :        Str14;  
  FUNCTION aRedOnBlue :          Str14; 
  FUNCTION abRedOnBlue :         Str14;  
  FUNCTION aMagentaOnBlue :      Str14; 
  FUNCTION abMagentaOnBlue :     Str14;  
  FUNCTION aBrownOnBlue :        Str14; 
  FUNCTION abBrownOnBlue :       Str14;  
  FUNCTION aLtGrayOnBlue :       Str14; 
  FUNCTION abLtGrayOnBlue :      Str14;  
  FUNCTION aDkGrayOnBlue :       Str14; 
  FUNCTION abDkGrayOnBlue :      Str14;  
  FUNCTION aLtBlueOnBlue :       Str14; 
  FUNCTION abLtBlueOnBlue :      Str14;  
  FUNCTION aLtGreenOnBlue :      Str14; 
  FUNCTION abLtGreenOnBlue :     Str14;  
  FUNCTION aLtCyanOnBlue :       Str14; 
  FUNCTION abLtCyanOnBlue :      Str14;  
  FUNCTION aLtRedOnBlue :        Str14; 
  FUNCTION abLtRedOnBlue :       Str14;  
  FUNCTION aLtMagentaOnBlue :    Str14; 
  FUNCTION abLtMagentaOnBlue :   Str14;  
  FUNCTION aYellowOnBlue :       Str14; 
  FUNCTION abYellowOnBlue :      Str14;  
  FUNCTION aWhiteOnBlue :        Str14; 
  FUNCTION abWhiteOnBlue :       Str14;  

  {Green background}
  FUNCTION aBlackOnGreen :       Str14; 
  FUNCTION abBlackOnGreen :      Str14;  
  FUNCTION aBlueOnGreen :        Str14; 
  FUNCTION abBlueOnGreen :       Str14;  
  FUNCTION aGreenOnGreen :       Str14; 
  FUNCTION abGreenOnGreen :      Str14;  
  FUNCTION aCyanOnGreen :        Str14; 
  FUNCTION abCyanOnGreen :       Str14;  
  FUNCTION aRedOnGreen :         Str14; 
  FUNCTION abRedOnGreen :        Str14;  
  FUNCTION aMagentaOnGreen :     Str14; 
  FUNCTION abMagentaOnGreen :    Str14;  
  FUNCTION aBrownOnGreen :       Str14; 
  FUNCTION abBrownOnGreen :      Str14;  
  FUNCTION aLtGrayOnGreen :      Str14; 
  FUNCTION abLtGrayOnGreen :     Str14;  
  FUNCTION aDkGrayOnGreen :      Str14; 
  FUNCTION abDkGrayOnGreen :     Str14;  
  FUNCTION aLtBlueOnGreen :      Str14; 
  FUNCTION abLtBlueOnGreen :     Str14;  
  FUNCTION aLtGreenOnGreen :     Str14; 
  FUNCTION abLtGreenOnGreen :    Str14;  
  FUNCTION aLtCyanOnGreen :      Str14; 
  FUNCTION abLtCyanOnGreen :     Str14;  
  FUNCTION aLtRedOnGreen :       Str14; 
  FUNCTION abLtRedOnGreen :      Str14;  
  FUNCTION aLtMagentaOnGreen :   Str14; 
  FUNCTION abLtMagentaOnGreen :  Str14;  
  FUNCTION aYellowOnGreen :      Str14; 
  FUNCTION abYellowOnGreen :     Str14;  
  FUNCTION aWhiteOnGreen :       Str14; 
  FUNCTION abWhiteOnGreen :      Str14;  

  {Cyan background}
  FUNCTION aBlackOnCyan :        Str14; 
  FUNCTION abBlackOnCyan :       Str14;  
  FUNCTION aBlueOnCyan :         Str14; 
  FUNCTION abBlueOnCyan :        Str14;  
  FUNCTION aGreenOnCyan :        Str14; 
  FUNCTION abGreenOnCyan :       Str14;  
  FUNCTION aCyanOnCyan :         Str14; 
  FUNCTION abCyanOnCyan :        Str14;  
  FUNCTION aRedOnCyan :          Str14; 
  FUNCTION abRedOnCyan :         Str14;  
  FUNCTION aMagentaOnCyan :      Str14; 
  FUNCTION abMagentaOnCyan :     Str14;  
  FUNCTION aBrownOnCyan :        Str14; 
  FUNCTION abBrownOnCyan :       Str14;  
  FUNCTION aLtGrayOnCyan :       Str14; 
  FUNCTION abLtGrayOnCyan :      Str14;  
  FUNCTION aDkGrayOnCyan :       Str14; 
  FUNCTION abDkGrayOnCyan :      Str14;  
  FUNCTION aLtBlueOnCyan :       Str14; 
  FUNCTION abLtBlueOnCyan :      Str14;  
  FUNCTION aLtGreenOnCyan :      Str14; 
  FUNCTION abLtGreenOnCyan :     Str14;  
  FUNCTION aLtCyanOnCyan :       Str14; 
  FUNCTION abLtCyanOnCyan :      Str14;  
  FUNCTION aLtRedOnCyan :        Str14; 
  FUNCTION abLtRedOnCyan :       Str14;  
  FUNCTION aLtMagentaOnCyan :    Str14; 
  FUNCTION abLtMagentaOnCyan :   Str14;  
  FUNCTION aYellowOnCyan :       Str14; 
  FUNCTION abYellowOnCyan :      Str14;  
  FUNCTION aWhiteOnCyan :        Str14; 
  FUNCTION abWhiteOnCyan :       Str14;  

  {Red background}
  FUNCTION aBlackOnRed :         Str14; 
  FUNCTION abBlackOnRed :        Str14;  
  FUNCTION aBlueOnRed :          Str14; 
  FUNCTION abBlueOnRed :         Str14;  
  FUNCTION aGreenOnRed :         Str14; 
  FUNCTION abGreenOnRed :        Str14;  
  FUNCTION aCyanOnRed :          Str14; 
  FUNCTION abCyanOnRed :         Str14;  
  FUNCTION aRedOnRed :           Str14; 
  FUNCTION abRedOnRed :          Str14;  
  FUNCTION aMagentaOnRed :       Str14; 
  FUNCTION abMagentaOnRed :      Str14;  
  FUNCTION aBrownOnRed :         Str14; 
  FUNCTION abBrownOnRed :        Str14;  
  FUNCTION aLtGrayOnRed :        Str14; 
  FUNCTION abLtGrayOnRed :       Str14;  
  FUNCTION aDkGrayOnRed :        Str14; 
  FUNCTION abDkGrayOnRed :       Str14;  
  FUNCTION aLtBlueOnRed :        Str14; 
  FUNCTION abLtBlueOnRed :       Str14;  
  FUNCTION aLtGreenOnRed :       Str14; 
  FUNCTION abLtGreenOnRed :      Str14;  
  FUNCTION aLtCyanOnRed :        Str14; 
  FUNCTION abLtCyanOnRed :       Str14;  
  FUNCTION aLtRedOnRed :         Str14; 
  FUNCTION abLtRedOnRed :        Str14;  
  FUNCTION aLtMagentaOnRed :     Str14; 
  FUNCTION abLtMagentaOnRed :    Str14;  
  FUNCTION aYellowOnRed :        Str14; 
  FUNCTION abYellowOnRed :       Str14;  
  FUNCTION aWhiteOnRed :         Str14; 
  FUNCTION abWhiteOnRed :        Str14;  

  {Magenta background}
  FUNCTION aBlackOnMagenta :     Str14; 
  FUNCTION abBlackOnMagenta :    Str14;  
  FUNCTION aBlueOnMagenta :      Str14; 
  FUNCTION abBlueOnMagenta :     Str14;  
  FUNCTION aGreenOnMagenta :     Str14; 
  FUNCTION abGreenOnMagenta :    Str14;  
  FUNCTION aCyanOnMagenta :      Str14; 
  FUNCTION abCyanOnMagenta :     Str14;  
  FUNCTION aRedOnMagenta :       Str14; 
  FUNCTION abRedOnMagenta :      Str14;  
  FUNCTION aMagentaOnMagenta :   Str14; 
  FUNCTION abMagentaOnMagenta :  Str14;  
  FUNCTION aBrownOnMagenta :     Str14; 
  FUNCTION abBrownOnMagenta :    Str14;  
  FUNCTION aLtGrayOnMagenta :    Str14; 
  FUNCTION abLtGrayOnMagenta :   Str14;  
  FUNCTION aDkGrayOnMagenta :    Str14; 
  FUNCTION abDkGrayOnMagenta :   Str14;  
  FUNCTION aLtBlueOnMagenta :    Str14; 
  FUNCTION abLtBlueOnMagenta :   Str14;  
  FUNCTION aLtGreenOnMagenta :   Str14; 
  FUNCTION abLtGreenOnMagenta :  Str14;  
  FUNCTION aLtCyanOnMagenta :    Str14; 
  FUNCTION abLtCyanOnMagenta :   Str14;  
  FUNCTION aLtRedOnMagenta :     Str14; 
  FUNCTION abLtRedOnMagenta :    Str14;  
  FUNCTION aLtMagentaOnMagenta : Str14; 
  FUNCTION abLtMagentaOnMagenta : Str14;   
  FUNCTION aYellowOnMagenta :    Str14; 
  FUNCTION abYellowOnMagenta :   Str14;  
  FUNCTION aWhiteOnMagenta :     Str14; 
  FUNCTION abWhiteOnMagenta :    Str14;  

  {Brown background}
  FUNCTION aBlackOnBrown :       Str14; 
  FUNCTION abBlackOnBrown :      Str14;  
  FUNCTION aBlueOnBrown :        Str14; 
  FUNCTION abBlueOnBrown :       Str14;  
  FUNCTION aGreenOnBrown :       Str14; 
  FUNCTION abGreenOnBrown :      Str14;  
  FUNCTION aCyanOnBrown :        Str14; 
  FUNCTION abCyanOnBrown :       Str14;  
  FUNCTION aRedOnBrown :         Str14; 
  FUNCTION abRedOnBrown :        Str14;  
  FUNCTION aMagentaOnBrown :     Str14; 
  FUNCTION abMagentaOnBrown :    Str14;  
  FUNCTION aBrownOnBrown :       Str14; 
  FUNCTION abBrownOnBrown :      Str14;  
  FUNCTION aLtGrayOnBrown :      Str14; 
  FUNCTION abLtGrayOnBrown :     Str14;  
  FUNCTION aDkGrayOnBrown :      Str14; 
  FUNCTION abDkGrayOnBrown :     Str14;  
  FUNCTION aLtBlueOnBrown :      Str14; 
  FUNCTION abLtBlueOnBrown :     Str14;  
  FUNCTION aLtGreenOnBrown :     Str14; 
  FUNCTION abLtGreenOnBrown :    Str14;  
  FUNCTION aLtCyanOnBrown :      Str14; 
  FUNCTION abLtCyanOnBrown :     Str14;  
  FUNCTION aLtRedOnBrown :       Str14; 
  FUNCTION abLtRedOnBrown :      Str14;  
  FUNCTION aLtMagentaOnBrown :   Str14; 
  FUNCTION abLtMagentaOnBrown :  Str14;  
  FUNCTION aYellowOnBrown :      Str14; 
  FUNCTION abYellowOnBrown :     Str14;  
  FUNCTION aWhiteOnBrown :       Str14; 
  FUNCTION abWhiteOnBrown :      Str14;  

  {Light gray backgrouund}
  FUNCTION aBlackOnLtGray :      Str14; 
  FUNCTION abBlackOnLtGray :     Str14;  
  FUNCTION aBlueOnLtGray :       Str14; 
  FUNCTION abBlueOnLtGray :      Str14;  
  FUNCTION aGreenOnLtGray :      Str14; 
  FUNCTION abGreenOnLtGray :     Str14;  
  FUNCTION aCyanOnLtGray :       Str14; 
  FUNCTION abCyanOnLtGray :      Str14;  
  FUNCTION aRedOnLtGray :        Str14; 
  FUNCTION abRedOnLtGray :       Str14;  
  FUNCTION aMagentaOnLtGray :    Str14; 
  FUNCTION abMagentaOnLtGray :   Str14;  
  FUNCTION aBrownOnLtGray :      Str14; 
  FUNCTION abBrownOnLtGray :     Str14;  
  FUNCTION aLtGrayOnLtGray :     Str14; 
  FUNCTION abLtGrayOnLtGray :    Str14;  
  FUNCTION aDkGrayOnLtGray :     Str14; 
  FUNCTION abDkGrayOnLtGray :    Str14;  
  FUNCTION aLtBlueOnLtGray :     Str14; 
  FUNCTION abLtBlueOnLtGray :    Str14;  
  FUNCTION aLtGreenOnLtGray :    Str14; 
  FUNCTION abLtGreenOnLtGray :   Str14;  
  FUNCTION aLtCyanOnLtGray :     Str14; 
  FUNCTION abLtCyanOnLtGray :    Str14;  
  FUNCTION aLtRedOnLtGray :      Str14; 
  FUNCTION abLtRedOnLtGray :     Str14;  
  FUNCTION aLtMagentaOnLtGray :  Str14; 
  FUNCTION abLtMagentaOnLtGray : Str14;  
  FUNCTION aYellowOnLtGray :     Str14; 
  FUNCTION abYellowOnLtGray :    Str14;  
  FUNCTION aWhiteOnLtGray :      Str14; 
  FUNCTION abWhiteOnLtGray :     Str14;  

  {==========================================================================}

IMPLEMENTATION

CONST

{ Foreground and background color constants }

  Black         : BYTE =  0;
  Blue          : BYTE =  1;
  Green         : BYTE =  2;
  Cyan          : BYTE =  3;
  Red           : BYTE =  4;
  Magenta       : BYTE =  5;
  Brown         : BYTE =  6;
  LightGray     : BYTE =  7;

{ Foreground color constants }

  DarkGray      : BYTE =  8;
  LightBlue     : BYTE =  9;
  LightGreen    : BYTE = 10;
  LightCyan     : BYTE = 11;
  LightRed      : BYTE = 12;
  LightMagenta  : BYTE = 13;
  Yellow        : BYTE = 14;
  White         : BYTE = 15;



  FUNCTION MakeAnsiString (ForeG, BackG : BYTE) : Str14;
    BEGIN
      MakeAnsiString := aSt + fgCol [ForeG] + bgCol [BackG] + aEnd;
    END;
    


  {Black background}
  FUNCTION aBlackOnBlack :       Str14;
    BEGIN
      aBlackOnBlack := MakeAnsiString (Black, Black);
    END;
    

  FUNCTION abBlackOnBlack :      Str14;
    BEGIN
      abBlackOnBlack := MakeAnsiString (Black + aBlink, Black);
    END;
    

  FUNCTION aBlueOnBlack :        Str14;
    BEGIN
      aBlueOnBlack := MakeAnsiString (Blue, Black);
    END;
    

  FUNCTION abBlueOnBlack :       Str14;
    BEGIN
      abBlueOnBlack := MakeAnsiString (Blue + aBlink, Black);
    END;
    

  FUNCTION aGreenOnBlack :       Str14;       
    BEGIN
      aGreenOnBlack := MakeAnsiString (Green, Black);
    END;
    

  FUNCTION abGreenOnBlack :      Str14;       
    BEGIN
      abGreenOnBlack := MakeAnsiString (Green + aBlink, Black);
    END;
    

  FUNCTION aCyanOnBlack :        Str14;
    BEGIN
      aCyanOnBlack := MakeAnsiString (Cyan, Black);
    END;
    

  FUNCTION abCyanOnBlack :       Str14;
    BEGIN
      abCyanOnBlack := MakeAnsiString (Cyan + aBlink, Black);
    END;
    

  FUNCTION aRedOnBlack :         Str14; 
    BEGIN
      aRedOnBlack := MakeAnsiString (Red, Black);
    END;
    

  FUNCTION abRedOnBlack :        Str14; 
    BEGIN
      abRedOnBlack := MakeAnsiString (Red + aBlink, Black);
    END;
    

  FUNCTION aMagentaOnBlack :     Str14;      
    BEGIN
      aMagentaOnBlack := MakeAnsiString (Magenta, Black);
    END;
    

  FUNCTION abMagentaOnBlack :    Str14;      
    BEGIN
      abMagentaOnBlack := MakeAnsiString (Magenta + aBlink, Black);
    END;
    

  FUNCTION aBrownOnBlack :       Str14;
    BEGIN
      aBrownOnBlack := MakeAnsiString (Brown, Black);
    END;
    

  FUNCTION abBrownOnBlack :      Str14;     
    BEGIN
      abBrownOnBlack := MakeAnsiString (Brown + aBlink, Black);
    END;
    

  FUNCTION aLtGrayOnBlack :      Str14; 
    BEGIN
      aLtGrayOnBlack := MakeAnsiString (LightGray, Black);
    END;
    

  FUNCTION abLtGrayOnBlack :     Str14; 
    BEGIN
      abLtGrayOnBlack := MakeAnsiString (LightGray + aBlink, Black);
    END;
    

  FUNCTION aDkGrayOnBlack :      Str14;        
    BEGIN
      aDkGrayOnBlack := MakeAnsiString (DarkGray, Black);
    END;
    

  FUNCTION abDkGrayOnBlack :     Str14;        
    BEGIN
      abDkGrayOnBlack := MakeAnsiString (DarkGray + aBlink, Black);
    END;
    

  FUNCTION aLtBlueOnBlack :      Str14;
    BEGIN
      aLtBlueOnBlack := MakeAnsiString (LightBlue, Black);
    END;
    

  FUNCTION abLtBlueOnBlack :     Str14;
    BEGIN
      abLtBlueOnBlack := MakeAnsiString (LightBlue + aBlink, Black);
    END;
    

  FUNCTION aLtGreenOnBlack :     Str14;
    BEGIN
      aLtGreenOnBlack := MakeAnsiString (LightGreen, Black);
    END;
    

  FUNCTION abLtGreenOnBlack :    Str14;
    BEGIN
      abLtGreenOnBlack := MakeAnsiString (LightGreen + aBlink, Black);
    END;
    

  FUNCTION aLtCyanOnBlack :      Str14;
    BEGIN
      aLtCyanOnBlack := MakeAnsiString (LightCyan, Black);
    END;
    

  FUNCTION abLtCyanOnBlack :     Str14;
    BEGIN
      abLtCyanOnBlack := MakeAnsiString (LightCyan + aBlink, Black);
    END;
    

  FUNCTION aLtRedOnBlack :       Str14;      
    BEGIN
      aLtRedOnBlack := MakeAnsiString (LightRed, Black);
    END;
    

  FUNCTION abLtRedOnBlack :      Str14;       
    BEGIN
      abLtRedOnBlack := MakeAnsiString (LightRed + aBlink, Black);
    END;
    

  FUNCTION aLtMagentaOnBlack :   Str14;    
    BEGIN
      aLtMagentaOnBlack := MakeAnsiString (LightMagenta, Black);
    END;
    

  FUNCTION abLtMagentaOnBlack :  Str14;    
    BEGIN
      abLtMagentaOnBlack := MakeAnsiString (LightMagenta + aBlink, Black);
    END;
    

  FUNCTION aYellowOnBlack :      Str14;      
    BEGIN
      aYellowOnBlack := MakeAnsiString (Yellow, Black);
    END;
    

  FUNCTION abYellowOnBlack :     Str14;    
    BEGIN
      abYellowOnBlack := MakeAnsiString (Yellow + aBlink, Black);
    END;
    

  FUNCTION aWhiteOnBlack :       Str14;       
    BEGIN
      aWhiteOnBlack := MakeAnsiString (White, Black);
    END;
    

  FUNCTION abWhiteOnBlack :      Str14;       
    BEGIN
      abWhiteOnBlack := MakeAnsiString (White + aBlink, Black);
    END;
    


  {Blue background}
  FUNCTION aBlackOnBlue :        Str14; 
    BEGIN
      aBlackOnBlue := MakeAnsiString (Black, Blue);
    END;
    

  FUNCTION abBlackOnBlue :       Str14;  
    BEGIN
      abBlackOnBlue := MakeAnsiString (Black + aBlink, Blue);
    END;
    

  FUNCTION aBlueOnBlue :         Str14; 
    BEGIN
      aBlueOnBlue := MakeAnsiString (Blue, Blue);
    END;
    

  FUNCTION abBlueOnBlue :        Str14;  
    BEGIN
      abBlueOnBlue := MakeAnsiString (Blue + aBlink, Blue);
    END;
    

  FUNCTION aGreenOnBlue :        Str14; 
    BEGIN
      aGreenOnBlue := MakeAnsiString (Green, Blue);
    END;
    

  FUNCTION abGreenOnBlue :       Str14;  
    BEGIN
      abGreenOnBlue := MakeAnsiString (Green + aBlink, Blue);
    END;
    

  FUNCTION aCyanOnBlue :         Str14; 
    BEGIN
      aCyanOnBlue := MakeAnsiString (Cyan, Blue);
    END;
    

  FUNCTION abCyanOnBlue :        Str14;  
    BEGIN
      abCyanOnBlue := MakeAnsiString (Cyan + aBlink, Blue);
    END;
    

  FUNCTION aRedOnBlue :          Str14; 
    BEGIN
      aRedOnBlue := MakeAnsiString (Red, Blue);
    END;
    

  FUNCTION abRedOnBlue :         Str14;  
    BEGIN
      abRedOnBlue := MakeAnsiString (Red + aBlink, Blue);
    END;
    

  FUNCTION aMagentaOnBlue :      Str14; 
    BEGIN
      aMagentaOnBlue := MakeAnsiString (Magenta, Blue);
    END;
    

  FUNCTION abMagentaOnBlue :     Str14;  
    BEGIN
      abMagentaOnBlue := MakeAnsiString (Magenta + aBlink, Blue);
    END;
    

  FUNCTION aBrownOnBlue :        Str14; 
    BEGIN
      aBrownOnBlue := MakeAnsiString (Brown, Blue);
    END;
    

  FUNCTION abBrownOnBlue :       Str14;  
    BEGIN
      abBrownOnBlue := MakeAnsiString (Brown + aBlink, Blue);
    END;
    

  FUNCTION aLtGrayOnBlue :       Str14; 
    BEGIN
      aLtGrayOnBlue := MakeAnsiString (LightGray, Blue);
    END;
    

  FUNCTION abLtGrayOnBlue :      Str14;  
    BEGIN
      abLtGrayOnBlue := MakeAnsiString (LightGray + aBlink, Blue);
    END;
    

  FUNCTION aDkGrayOnBlue :       Str14; 
    BEGIN
      aDkGrayOnBlue := MakeAnsiString (DarkGray, Blue);
    END;
    

  FUNCTION abDkGrayOnBlue :      Str14;  
    BEGIN
      abDkGrayOnBlue := MakeAnsiString (DarkGray + aBlink, Blue);
    END;
    

  FUNCTION aLtBlueOnBlue :       Str14; 
    BEGIN
      aLtBlueOnBlue := MakeAnsiString (LightBlue, Blue);
    END;
    

  FUNCTION abLtBlueOnBlue :      Str14;  
    BEGIN
      abLtBlueOnBlue := MakeAnsiString (LightBlue + aBlink, Blue);
    END;
    

  FUNCTION aLtGreenOnBlue :      Str14; 
    BEGIN
      aLtGreenOnBlue := MakeAnsiString (LightGreen, Blue);
    END;
    

  FUNCTION abLtGreenOnBlue :     Str14;  
    BEGIN
      abLtGreenOnBlue := MakeAnsiString (LightGreen + aBlink, Blue);
    END;
    

  FUNCTION aLtCyanOnBlue :       Str14; 
    BEGIN
      aLtCyanOnBlue := MakeAnsiString (LightCyan, Blue);
    END;
    

  FUNCTION abLtCyanOnBlue :      Str14;  
    BEGIN
      abLtCyanOnBlue := MakeAnsiString (LightCyan + aBlink, Blue);
    END;
    

  FUNCTION aLtRedOnBlue :        Str14; 
    BEGIN
      aLtRedOnBlue := MakeAnsiString (LightRed, Blue);
    END;
    

  FUNCTION abLtRedOnBlue :       Str14;  
    BEGIN
      abLtRedOnBlue := MakeAnsiString (LightRed + aBlink, Blue);
    END;
    

  FUNCTION aLtMagentaOnBlue :    Str14; 
    BEGIN
      aLtMagentaOnBlue := MakeAnsiString (LightMagenta, Blue);
    END;
    

  FUNCTION abLtMagentaOnBlue :   Str14;  
    BEGIN
      abLtMagentaOnBlue := MakeAnsiString (LightMagenta + aBlink, Blue);
    END;
    

  FUNCTION aYellowOnBlue :       Str14; 
    BEGIN
      aYellowOnBlue := MakeAnsiString (Yellow, Blue);
    END;
    

  FUNCTION abYellowOnBlue :      Str14;  
    BEGIN
      abYellowOnBlue := MakeAnsiString (Yellow + aBlink, Blue);
    END;
    

  FUNCTION aWhiteOnBlue :        Str14; 
    BEGIN
      aWhiteOnBlue := MakeAnsiString (White, Blue);
    END;
    

  FUNCTION abWhiteOnBlue :       Str14;  
    BEGIN
      abWhiteOnBlue := MakeAnsiString (White + aBlink, Blue);
    END;
    


  {Green background}
  FUNCTION aBlackOnGreen :       Str14; 
    BEGIN
      aBlackOnGreen := MakeAnsiString (Black, Green);
    END;
    

  FUNCTION abBlackOnGreen :      Str14;  
    BEGIN
      abBlackOnGreen := MakeAnsiString (Black + aBlink, Green);
    END;
    

  FUNCTION aBlueOnGreen :        Str14; 
    BEGIN
      aBlueOnGreen := MakeAnsiString (Blue, Green);
    END;
    

  FUNCTION abBlueOnGreen :       Str14;  
    BEGIN
      abBlueOnGreen := MakeAnsiString (Blue + aBlink, Green);
    END;
    

  FUNCTION aGreenOnGreen :       Str14; 
    BEGIN
      aGreenOnGreen := MakeAnsiString (Green, Green);
    END;
    

  FUNCTION abGreenOnGreen :      Str14;  
    BEGIN
      abGreenOnGreen := MakeAnsiString (Green + aBlink, Green);
    END;
    

  FUNCTION aCyanOnGreen :        Str14; 
    BEGIN
      aCyanOnGreen := MakeAnsiString (Cyan, Green);
    END;
    

  FUNCTION abCyanOnGreen :       Str14;  
    BEGIN
      abCyanOnGreen := MakeAnsiString (Cyan + aBlink, Green);
    END;
    

  FUNCTION aRedOnGreen :         Str14; 
    BEGIN
      aRedOnGreen := MakeAnsiString (Red, Green);
    END;
    

  FUNCTION abRedOnGreen :        Str14;  
    BEGIN
      abRedOnGreen := MakeAnsiString (Red + aBlink, Green);
    END;
    

  FUNCTION aMagentaOnGreen :     Str14; 
    BEGIN
      aMagentaOnGreen := MakeAnsiString (Magenta, Green);
    END;
    

  FUNCTION abMagentaOnGreen :    Str14;  
    BEGIN
      abMagentaOnGreen := MakeAnsiString (Magenta + aBlink, Green);
    END;
    

  FUNCTION aBrownOnGreen :       Str14; 
    BEGIN
      aBrownOnGreen := MakeAnsiString (Brown, Green);
    END;
    

  FUNCTION abBrownOnGreen :      Str14;  
    BEGIN
      abBrownOnGreen := MakeAnsiString (Brown + aBlink, Green);
    END;
    

  FUNCTION aLtGrayOnGreen :      Str14; 
    BEGIN
      aLtGrayOnGreen := MakeAnsiString (LightGray, Green);
    END;
    

  FUNCTION abLtGrayOnGreen :     Str14;  
    BEGIN
      abLtGrayOnGreen := MakeAnsiString (LightGray + aBlink, Green);
    END;
    

  FUNCTION aDkGrayOnGreen :      Str14; 
    BEGIN
      aDkGrayOnGreen := MakeAnsiString (DarkGray, Green);
    END;
    

  FUNCTION abDkGrayOnGreen :     Str14;  
    BEGIN
      abDkGrayOnGreen := MakeAnsiString (DarkGray + aBlink, Green);
    END;
    

  FUNCTION aLtBlueOnGreen :      Str14; 
    BEGIN
      aLtBlueOnGreen := MakeAnsiString (LightBlue, Green);
    END;
    

  FUNCTION abLtBlueOnGreen :     Str14;  
    BEGIN
      abLtBlueOnGreen := MakeAnsiString (LightBlue + aBlink, Green);
    END;
    

  FUNCTION aLtGreenOnGreen :     Str14; 
    BEGIN
      aLtGreenOnGreen := MakeAnsiString (LightGreen, Green);
    END;
    

  FUNCTION abLtGreenOnGreen :    Str14;  
    BEGIN
      abLtGreenOnGreen := MakeAnsiString (LightGreen + aBlink, Green);
    END;
    

  FUNCTION aLtCyanOnGreen :      Str14; 
    BEGIN
      aLtCyanOnGreen := MakeAnsiString (LightCyan, Green);
    END;
    

  FUNCTION abLtCyanOnGreen :     Str14;  
    BEGIN
      abLtCyanOnGreen := MakeAnsiString (LightCyan + aBlink, Green);
    END;
    

  FUNCTION aLtRedOnGreen :       Str14; 
    BEGIN
      aLtRedOnGreen := MakeAnsiString (LightRed, Green);
    END;
    

  FUNCTION abLtRedOnGreen :      Str14;  
    BEGIN
      abLtRedOnGreen := MakeAnsiString (LightRed + aBlink, Green);
    END;
    

  FUNCTION aLtMagentaOnGreen :   Str14; 
    BEGIN
      aLtMagentaOnGreen := MakeAnsiString (LightMagenta, Green);
    END;
    

  FUNCTION abLtMagentaOnGreen :  Str14;  
    BEGIN
      abLtMagentaOnGreen := MakeAnsiString (LightMagenta + aBlink, Green);
    END;
    

  FUNCTION aYellowOnGreen :      Str14; 
    BEGIN
      aYellowOnGreen := MakeAnsiString (Yellow, Green);
    END;
    

  FUNCTION abYellowOnGreen :     Str14;  
    BEGIN
      abYellowOnGreen := MakeAnsiString (Yellow + aBlink, Green);
    END;
    

  FUNCTION aWhiteOnGreen :       Str14; 
    BEGIN
      aWhiteOnGreen := MakeAnsiString (White, Green);
    END;
    

  FUNCTION abWhiteOnGreen :      Str14;  
    BEGIN
      abWhiteOnGreen := MakeAnsiString (White + aBlink, Green);
    END;
    


  {Cyan background}
  FUNCTION aBlackOnCyan :        Str14; 
    BEGIN
      aBlackOnCyan := MakeAnsiString (Black, Cyan);
    END;
    

  FUNCTION abBlackOnCyan :       Str14;  
    BEGIN
      abBlackOnCyan := MakeAnsiString (Black + aBlink, Cyan);
    END;
    

  FUNCTION aBlueOnCyan :         Str14; 
    BEGIN
      aBlueOnCyan := MakeAnsiString (Blue, Cyan);
    END;
    

  FUNCTION abBlueOnCyan :        Str14;  
    BEGIN
      abBlueOnCyan := MakeAnsiString (Blue + aBlink, Cyan);
    END;
    

  FUNCTION aGreenOnCyan :        Str14; 
    BEGIN
      aGreenOnCyan := MakeAnsiString (Green, Cyan);
    END;
    

  FUNCTION abGreenOnCyan :       Str14;  
    BEGIN
      abGreenOnCyan := MakeAnsiString (Green + aBlink, Cyan);
    END;
    

  FUNCTION aCyanOnCyan :         Str14; 
    BEGIN
      aCyanOnCyan := MakeAnsiString (Cyan, Cyan);
    END;
    

  FUNCTION abCyanOnCyan :        Str14;  
    BEGIN
      abCyanOnCyan := MakeAnsiString (Cyan + aBlink, Cyan);
    END;
    

  FUNCTION aRedOnCyan :          Str14; 
    BEGIN
      aRedOnCyan := MakeAnsiString (Red, Cyan);
    END;
    

  FUNCTION abRedOnCyan :         Str14;  
    BEGIN
      abRedOnCyan := MakeAnsiString (Red + aBlink, Cyan);
    END;
    

  FUNCTION aMagentaOnCyan :      Str14; 
    BEGIN
      aMagentaOnCyan := MakeAnsiString (Magenta, Cyan);
    END;
    

  FUNCTION abMagentaOnCyan :     Str14;  
    BEGIN
      abMagentaOnCyan := MakeAnsiString (Magenta + aBlink, Cyan);
    END;
    

  FUNCTION aBrownOnCyan :        Str14; 
    BEGIN
      aBrownOnCyan := MakeAnsiString (Brown, Cyan);
    END;
    

  FUNCTION abBrownOnCyan :       Str14;  
    BEGIN
      abBrownOnCyan := MakeAnsiString (Brown + aBlink, Cyan);
    END;
    

  FUNCTION aLtGrayOnCyan :       Str14; 
    BEGIN
      aLtGrayOnCyan := MakeAnsiString (LightGray, Cyan);
    END;
    

  FUNCTION abLtGrayOnCyan :      Str14;  
    BEGIN
      abLtGrayOnCyan := MakeAnsiString (LightGray + aBlink, Cyan);
    END;
    

  FUNCTION aDkGrayOnCyan :       Str14; 
    BEGIN
      aDkGrayOnCyan := MakeAnsiString (DarkGray, Cyan);
    END;
    

  FUNCTION abDkGrayOnCyan :      Str14;  
    BEGIN
      abDkGrayOnCyan := MakeAnsiString (DarkGray + aBlink, Cyan);
    END;
    

  FUNCTION aLtBlueOnCyan :       Str14; 
    BEGIN
      aLtBlueOnCyan := MakeAnsiString (LightBlue, Cyan);
    END;
    

  FUNCTION abLtBlueOnCyan :      Str14;  
    BEGIN
      abLtBlueOnCyan := MakeAnsiString (LightBlue + aBlink, Cyan);
    END;
    

  FUNCTION aLtGreenOnCyan :      Str14; 
    BEGIN
      aLtGreenOnCyan := MakeAnsiString (LightGreen, Cyan);
    END;
    

  FUNCTION abLtGreenOnCyan :     Str14;  
    BEGIN
      abLtGreenOnCyan := MakeAnsiString (LightGreen + aBlink, Cyan);
    END;
    

  FUNCTION aLtCyanOnCyan :       Str14; 
    BEGIN
      aLtCyanOnCyan := MakeAnsiString (LightCyan, Cyan);
    END;
    

  FUNCTION abLtCyanOnCyan :      Str14;  
    BEGIN
      abLtCyanOnCyan := MakeAnsiString (LightCyan + aBlink, Cyan);
    END;
    

  FUNCTION aLtRedOnCyan :        Str14; 
    BEGIN
      aLtRedOnCyan := MakeAnsiString (LightRed, Cyan);
    END;
    

  FUNCTION abLtRedOnCyan :       Str14;  
    BEGIN
      abLtRedOnCyan := MakeAnsiString (LightRed + aBlink, Cyan);
    END;
    

  FUNCTION aLtMagentaOnCyan :    Str14; 
    BEGIN
      aLtMagentaOnCyan := MakeAnsiString (LightMagenta, Cyan);
    END;
    

  FUNCTION abLtMagentaOnCyan :   Str14;  
    BEGIN
      abLtMagentaOnCyan := MakeAnsiString (LightMagenta + aBlink, Cyan);
    END;
    

  FUNCTION aYellowOnCyan :       Str14; 
    BEGIN
      aYellowOnCyan := MakeAnsiString (Yellow, Cyan);
    END;
    

  FUNCTION abYellowOnCyan :      Str14;  
    BEGIN
      abYellowOnCyan := MakeAnsiString (Yellow + aBlink, Cyan);
    END;
    

  FUNCTION aWhiteOnCyan :        Str14; 
    BEGIN
      aWhiteOnCyan := MakeAnsiString (White, Cyan);
    END;
    

  FUNCTION abWhiteOnCyan :       Str14;  
    BEGIN
      abWhiteOnCyan := MakeAnsiString (White + aBlink, Cyan);
    END;
    


  {Red background}
  FUNCTION aBlackOnRed :         Str14; 
    BEGIN
      aBlackOnRed := MakeAnsiString (Black, Red);
    END;
    

  FUNCTION abBlackOnRed :        Str14;  
    BEGIN
      abBlackOnRed := MakeAnsiString (Black + aBlink, Red);
    END;
    

  FUNCTION aBlueOnRed :          Str14; 
    BEGIN
      aBlueOnRed := MakeAnsiString (Blue, Red);
    END;
    

  FUNCTION abBlueOnRed :         Str14;  
    BEGIN
      abBlueOnRed := MakeAnsiString (Blue + aBlink, Red);
    END;
    

  FUNCTION aGreenOnRed :         Str14; 
    BEGIN
      aGreenOnRed := MakeAnsiString (Green, Red);
    END;
    

  FUNCTION abGreenOnRed :        Str14;  
    BEGIN
      abGreenOnRed := MakeAnsiString (Green + aBlink, Red);
    END;
    

  FUNCTION aCyanOnRed :          Str14; 
    BEGIN
      aCyanOnRed := MakeAnsiString (Cyan, Red);
    END;
    

  FUNCTION abCyanOnRed :         Str14;  
    BEGIN
      abCyanOnRed := MakeAnsiString (Cyan + aBlink, Red);
    END;
    

  FUNCTION aRedOnRed :           Str14; 
    BEGIN
      aRedOnRed := MakeAnsiString (Red, Red);
    END;
    

  FUNCTION abRedOnRed :          Str14;  
    BEGIN
      abRedOnRed := MakeAnsiString (Red + aBlink, Red);
    END;
    

  FUNCTION aMagentaOnRed :       Str14; 
    BEGIN
      aMagentaOnRed := MakeAnsiString (Magenta, Red);
    END;
    

  FUNCTION abMagentaOnRed :      Str14;  
    BEGIN
      abMagentaOnRed := MakeAnsiString (Magenta + aBlink, Red);
    END;
    

  FUNCTION aBrownOnRed :         Str14; 
    BEGIN
      aBrownOnRed := MakeAnsiString (Brown, Red);
    END;
    

  FUNCTION abBrownOnRed :        Str14;  
    BEGIN
      abBrownOnRed := MakeAnsiString (Brown + aBlink, Red);
    END;
    

  FUNCTION aLtGrayOnRed :        Str14; 
    BEGIN
      aLtGrayOnRed := MakeAnsiString (LightGray, Red);
    END;
    

  FUNCTION abLtGrayOnRed :       Str14;  
    BEGIN
      abLtGrayOnRed := MakeAnsiString (LightGray + aBlink, Red);
    END;
    

  FUNCTION aDkGrayOnRed :        Str14; 
    BEGIN
      aDkGrayOnRed := MakeAnsiString (DarkGray, Red);
    END;
    

  FUNCTION abDkGrayOnRed :       Str14;  
    BEGIN
      abDkGrayOnRed := MakeAnsiString (DarkGray + aBlink, Red);
    END;
    

  FUNCTION aLtBlueOnRed :        Str14; 
    BEGIN
      aLtBlueOnRed := MakeAnsiString (LightBlue, Red);
    END;
    

  FUNCTION abLtBlueOnRed :       Str14;  
    BEGIN
      abLtBlueOnRed := MakeAnsiString (LightBlue + aBlink, Red);
    END;
    

  FUNCTION aLtGreenOnRed :       Str14; 
    BEGIN
      aLtGreenOnRed := MakeAnsiString (LightGreen, Red);
    END;
    

  FUNCTION abLtGreenOnRed :      Str14;  
    BEGIN
      abLtGreenOnRed := MakeAnsiString (LightGreen + aBlink, Red);
    END;
    

  FUNCTION aLtCyanOnRed :        Str14; 
    BEGIN
      aLtCyanOnRed := MakeAnsiString (LightCyan, Red);
    END;
    

  FUNCTION abLtCyanOnRed :       Str14;  
    BEGIN
      abLtCyanOnRed := MakeAnsiString (LightCyan + aBlink, Red);
    END;
    

  FUNCTION aLtRedOnRed :         Str14; 
    BEGIN
      aLtRedOnRed := MakeAnsiString (LightRed, Red);
    END;
    

  FUNCTION abLtRedOnRed :        Str14;  
    BEGIN
      abLtRedOnRed := MakeAnsiString (LightRed + aBlink, Red);
    END;
    

  FUNCTION aLtMagentaOnRed :     Str14; 
    BEGIN
      aLtMagentaOnRed := MakeAnsiString (LightMagenta, Red);
    END;
    

  FUNCTION abLtMagentaOnRed :    Str14;  
    BEGIN
      abLtMagentaOnRed := MakeAnsiString (LightMagenta + aBlink, Red);
    END;
    

  FUNCTION aYellowOnRed :        Str14; 
    BEGIN
      aYellowOnRed := MakeAnsiString (Yellow, Red);
    END;
    

  FUNCTION abYellowOnRed :       Str14;  
    BEGIN
      abYellowOnRed := MakeAnsiString (Yellow + aBlink, Red);
    END;
    

  FUNCTION aWhiteOnRed :         Str14; 
    BEGIN
      aWhiteOnRed := MakeAnsiString (White, Red);
    END;
    

  FUNCTION abWhiteOnRed :        Str14;  
    BEGIN
      abWhiteOnRed := MakeAnsiString (White + aBlink, Red);
    END;
    


  {Magenta background}
  FUNCTION aBlackOnMagenta :     Str14; 
    BEGIN
      aBlackOnMagenta := MakeAnsiString (Black, Magenta);
    END;
    

  FUNCTION abBlackOnMagenta :    Str14;  
    BEGIN
      abBlackOnMagenta := MakeAnsiString (Black + aBlink, Magenta);
    END;
    

  FUNCTION aBlueOnMagenta :      Str14; 
    BEGIN
      aBlueOnMagenta := MakeAnsiString (Blue, Magenta);
    END;
    

  FUNCTION abBlueOnMagenta :     Str14;  
    BEGIN
      abBlueOnMagenta := MakeAnsiString (Blue + aBlink, Magenta);
    END;
    

  FUNCTION aGreenOnMagenta :     Str14; 
    BEGIN
      aGreenOnMagenta := MakeAnsiString (Green, Magenta);
    END;
    

  FUNCTION abGreenOnMagenta :    Str14;  
    BEGIN
      abGreenOnMagenta := MakeAnsiString (Green + aBlink, Magenta);
    END;
    

  FUNCTION aCyanOnMagenta :      Str14; 
    BEGIN
      aCyanOnMagenta := MakeAnsiString (Cyan, Magenta);
    END;
    

  FUNCTION abCyanOnMagenta :     Str14;  
    BEGIN
      abCyanOnMagenta := MakeAnsiString (Cyan + aBlink, Magenta);
    END;
    

  FUNCTION aRedOnMagenta :       Str14; 
    BEGIN
      aRedOnMagenta := MakeAnsiString (Red, Magenta);
    END;
    

  FUNCTION abRedOnMagenta :      Str14;  
    BEGIN
      abRedOnMagenta := MakeAnsiString (Red + aBlink, Magenta);
    END;
    

  FUNCTION aMagentaOnMagenta :   Str14; 
    BEGIN
      aMagentaOnMagenta := MakeAnsiString (Magenta, Magenta);
    END;
    

  FUNCTION abMagentaOnMagenta :  Str14;  
    BEGIN
      abMagentaOnMagenta := MakeAnsiString (Magenta + aBlink, Magenta);
    END;
    

  FUNCTION aBrownOnMagenta :     Str14; 
    BEGIN
      aBrownOnMagenta := MakeAnsiString (Brown, Magenta);
    END;
    

  FUNCTION abBrownOnMagenta :    Str14;  
    BEGIN
      abBrownOnMagenta := MakeAnsiString (Brown + aBlink, Magenta);
    END;
    

  FUNCTION aLtGrayOnMagenta :    Str14; 
    BEGIN
      aLtGrayOnMagenta := MakeAnsiString (LightGray, Magenta);
    END;
    

  FUNCTION abLtGrayOnMagenta :   Str14;  
    BEGIN
      abLtGrayOnMagenta := MakeAnsiString (LightGray + aBlink, Magenta);
    END;
    

  FUNCTION aDkGrayOnMagenta :    Str14; 
    BEGIN
      aDkGrayOnMagenta := MakeAnsiString (DarkGray, Magenta);
    END;
    

  FUNCTION abDkGrayOnMagenta :   Str14;  
    BEGIN
      abDkGrayOnMagenta := MakeAnsiString (DarkGray + aBlink, Magenta);
    END;
    

  FUNCTION aLtBlueOnMagenta :    Str14; 
    BEGIN
      aLtBlueOnMagenta := MakeAnsiString (LightBlue, Magenta);
    END;
    

  FUNCTION abLtBlueOnMagenta :   Str14;  
    BEGIN
      abLtBlueOnMagenta := MakeAnsiString (LightBlue + aBlink, Magenta);
    END;
    

  FUNCTION aLtGreenOnMagenta :   Str14; 
    BEGIN
      aLtGreenOnMagenta := MakeAnsiString (LightGreen, Magenta);
    END;
    

  FUNCTION abLtGreenOnMagenta :  Str14;  
    BEGIN
      abLtGreenOnMagenta := MakeAnsiString (LightGreen + aBlink, Magenta);
    END;
    

  FUNCTION aLtCyanOnMagenta :    Str14; 
    BEGIN
      aLtCyanOnMagenta := MakeAnsiString (LightCyan, Magenta);
    END;
    

  FUNCTION abLtCyanOnMagenta :   Str14;  
    BEGIN
      abLtCyanOnMagenta := MakeAnsiString (Lightcyan + aBlink, Magenta);
    END;
    

  FUNCTION aLtRedOnMagenta :     Str14; 
    BEGIN
      aLtRedOnMagenta := MakeAnsiString (LightRed, Magenta);
    END;
    

  FUNCTION abLtRedOnMagenta :    Str14;  
    BEGIN
      abLtRedOnMagenta := MakeAnsiString (LightRed + aBlink, Magenta);
    END;
    

  FUNCTION aLtMagentaOnMagenta : Str14; 
    BEGIN
      aLtMagentaOnMagenta := MakeAnsiString (LightMagenta, Magenta);
    END;
    

  FUNCTION abLtMagentaOnMagenta : Str14;   
    BEGIN
      abLtMagentaOnMagenta := MakeAnsiString (LightMagenta + aBlink, Magenta);
    END;
    

  FUNCTION aYellowOnMagenta :    Str14; 
    BEGIN
      aYellowOnMagenta := MakeAnsiString (Yellow, Magenta);
    END;
    

  FUNCTION abYellowOnMagenta :   Str14;  
    BEGIN
      abYellowOnMagenta := MakeAnsiString (Yellow + aBlink, Magenta);
    END;
    

  FUNCTION aWhiteOnMagenta :     Str14; 
    BEGIN
      aWhiteOnMagenta := MakeAnsiString (White, Magenta);
    END;
    

  FUNCTION abWhiteOnMagenta :    Str14;  
    BEGIN
      abWhiteOnMagenta := MakeAnsiString (White + aBlink, Magenta);
    END;
    


  {Brown background}
  FUNCTION aBlackOnBrown :       Str14; 
    BEGIN
      aBlackOnBrown := MakeAnsiString (Black, Brown);
    END;
    

  FUNCTION abBlackOnBrown :      Str14;  
    BEGIN
      abBlackOnBrown := MakeAnsiString (Black + aBlink, Brown);
    END;
    

  FUNCTION aBlueOnBrown :        Str14; 
    BEGIN
      aBlueOnBrown := MakeAnsiString (Blue, Brown);
    END;
    

  FUNCTION abBlueOnBrown :       Str14;  
    BEGIN
      abBlueOnBrown := MakeAnsiString (Blue + aBlink, Brown);
    END;
    

  FUNCTION aGreenOnBrown :       Str14; 
    BEGIN
      aGreenOnBrown := MakeAnsiString (Green, Brown);
    END;
    

  FUNCTION abGreenOnBrown :      Str14;  
    BEGIN
      abGreenOnBrown := MakeAnsiString (Green + aBlink, Brown);
    END;
    

  FUNCTION aCyanOnBrown :        Str14; 
    BEGIN
      aCyanOnBrown := MakeAnsiString (Cyan, Brown);
    END;
    

  FUNCTION abCyanOnBrown :       Str14;  
    BEGIN
      abCyanOnBrown := MakeAnsiString (Cyan + aBlink, Brown);
    END;
    

  FUNCTION aRedOnBrown :         Str14; 
    BEGIN
      aRedOnBrown := MakeAnsiString (Red, Brown);
    END;
    

  FUNCTION abRedOnBrown :        Str14;  
    BEGIN
      abRedOnBrown := MakeAnsiString (Red + aBlink, Brown);
    END;
    

  FUNCTION aMagentaOnBrown :     Str14; 
    BEGIN
      aMagentaOnBrown := MakeAnsiString (Magenta, Brown);
    END;
    

  FUNCTION abMagentaOnBrown :    Str14;  
    BEGIN
      abMagentaOnBrown := MakeAnsiString (Magenta + aBlink, Brown);
    END;
    

  FUNCTION aBrownOnBrown :       Str14; 
    BEGIN
      aBrownOnBrown := MakeAnsiString (Brown, Brown);
    END;
    

  FUNCTION abBrownOnBrown :      Str14;  
    BEGIN
      abBrownOnBrown := MakeAnsiString (Brown + aBlink, Brown);
    END;
    

  FUNCTION aLtGrayOnBrown :      Str14; 
    BEGIN
      aLtGrayOnBrown := MakeAnsiString (LightGray, Brown);
    END;
    

  FUNCTION abLtGrayOnBrown :     Str14;  
    BEGIN
      abLtGrayOnBrown := MakeAnsiString (LightGray + aBlink, Brown);
    END;
    

  FUNCTION aDkGrayOnBrown :      Str14; 
    BEGIN
      aDkGrayOnBrown := MakeAnsiString (DarkGray, Brown);
    END;
    

  FUNCTION abDkGrayOnBrown :     Str14;  
    BEGIN
      abDkGrayOnBrown := MakeAnsiString (DarkGray + aBlink, Brown);
    END;
    

  FUNCTION aLtBlueOnBrown :      Str14; 
    BEGIN
      aLtBlueOnBrown := MakeAnsiString (LightBlue, Brown);
    END;
    

  FUNCTION abLtBlueOnBrown :     Str14;  
    BEGIN
      abLtBlueOnBrown := MakeAnsiString (LightBlue + aBlink, Brown);
    END;
    

  FUNCTION aLtGreenOnBrown :     Str14; 
    BEGIN
      aLtGreenOnBrown := MakeAnsiString (LightGreen, Brown);
    END;
    

  FUNCTION abLtGreenOnBrown :    Str14;  
    BEGIN
      abLtGreenOnBrown := MakeAnsiString (LightGreen + aBlink, Brown);
    END;
    

  FUNCTION aLtCyanOnBrown :      Str14; 
    BEGIN
      aLtCyanOnBrown := MakeAnsiString (LightCyan, Brown);
    END;
    

  FUNCTION abLtCyanOnBrown :     Str14;  
    BEGIN
      abLtCyanOnBrown := MakeAnsiString (LightCyan + aBlink, Brown);
    END;
    

  FUNCTION aLtRedOnBrown :       Str14; 
    BEGIN
      aLtRedOnBrown := MakeAnsiString (LightRed, Brown);
    END;
    

  FUNCTION abLtRedOnBrown :      Str14;  
    BEGIN
      abLtRedOnBrown := MakeAnsiString (LightRed + aBlink, Brown);
    END;
    

  FUNCTION aLtMagentaOnBrown :   Str14; 
    BEGIN
      aLtMagentaOnBrown := MakeAnsiString (LightMagenta, Brown);
    END;
    

  FUNCTION abLtMagentaOnBrown :  Str14;  
    BEGIN
      abLtMagentaOnBrown := MakeAnsiString (LightMagenta + aBlink, Brown);
    END;
    

  FUNCTION aYellowOnBrown :      Str14; 
    BEGIN
      aYellowOnBrown := MakeAnsiString (Yellow, Brown);
    END;
    

  FUNCTION abYellowOnBrown :     Str14;  
    BEGIN
      abYellowOnBrown := MakeAnsiString (Yellow + aBlink, Brown);
    END;
    

  FUNCTION aWhiteOnBrown :       Str14; 
    BEGIN
      aWhiteOnBrown := MakeAnsiString (White, Brown);
    END;
    

  FUNCTION abWhiteOnBrown :      Str14;  
    BEGIN
      abWhiteOnBrown := MakeAnsiString (White + aBlink, Brown);
    END;
    


  {Light gray backgrouund}
  FUNCTION aBlackOnLtGray :      Str14; 
    BEGIN
      aBlackOnLtGray := MakeAnsiString (Black, LightGray);
    END;
    

  FUNCTION abBlackOnLtGray :     Str14;  
    BEGIN
      abBlackOnLtGray := MakeAnsiString (Black + aBlink, LightGray);
    END;
    

  FUNCTION aBlueOnLtGray :       Str14; 
    BEGIN
      aBlueOnLtGray := MakeAnsiString (Blue, LightGray);
    END;
    

  FUNCTION abBlueOnLtGray :      Str14;  
    BEGIN
      abBlueOnLtGray := MakeAnsiString (Blue + aBlink, LightGray);
    END;
    

  FUNCTION aGreenOnLtGray :      Str14; 
    BEGIN
      aGreenOnLtGray := MakeAnsiString (Green, LightGray);
    END;
    

  FUNCTION abGreenOnLtGray :     Str14;  
    BEGIN
      abGreenOnLtGray := MakeAnsiString (Green + aBlink, LightGray);
    END;
    

  FUNCTION aCyanOnLtGray :       Str14; 
    BEGIN
      aCyanOnLtGray := MakeAnsiString (Cyan, LightGray);
    END;
    

  FUNCTION abCyanOnLtGray :      Str14;  
    BEGIN
      abCyanOnLtGray := MakeAnsiString (Cyan + aBlink, LightGray);
    END;
    

  FUNCTION aRedOnLtGray :        Str14; 
    BEGIN
      aRedOnLtGray := MakeAnsiString (Red, LightGray);
    END;
    

  FUNCTION abRedOnLtGray :       Str14;  
    BEGIN
      abRedOnLtGray := MakeAnsiString (Red + aBlink, LightGray);
    END;
    

  FUNCTION aMagentaOnLtGray :    Str14; 
    BEGIN
      aMagentaOnLtGray := MakeAnsiString (Magenta, LightGray);
    END;
    

  FUNCTION abMagentaOnLtGray :   Str14;  
    BEGIN
      abMagentaOnLtGray := MakeAnsiString (Magenta + aBlink, LightGray);
    END;
    

  FUNCTION aBrownOnLtGray :      Str14; 
    BEGIN
      aBrownOnLtGray := MakeAnsiString (Brown, LightGray);
    END;
    

  FUNCTION abBrownOnLtGray :     Str14;  
    BEGIN
      abBrownOnLtGray := MakeAnsiString (Brown + aBlink, LightGray);
    END;
    

  FUNCTION aLtGrayOnLtGray :     Str14; 
    BEGIN
      aLtGrayOnLtGray := MakeAnsiString (LightGray, LightGray);
    END;
    

  FUNCTION abLtGrayOnLtGray :    Str14;  
    BEGIN
      abLtGrayOnLtGray := MakeAnsiString (LightGray + aBlink, LightGray);
    END;
    

  FUNCTION aDkGrayOnLtGray :     Str14; 
    BEGIN
      aDkGrayOnLtGray := MakeAnsiString (DarkGray, LightGray);
    END;
    

  FUNCTION abDkGrayOnLtGray :    Str14;  
    BEGIN
      abDkGrayOnLtGray := MakeAnsiString (DarkGray + aBlink, LightGray);
    END;
    

  FUNCTION aLtBlueOnLtGray :     Str14; 
    BEGIN
      aLtBlueOnLtGray := MakeAnsiString (LightBlue, LightGray);
    END;
    

  FUNCTION abLtBlueOnLtGray :    Str14;  
    BEGIN
      abLtBlueOnLtGray := MakeAnsiString (LightBlue + aBlink, LightGray);
    END;
    

  FUNCTION aLtGreenOnLtGray :    Str14; 
    BEGIN
      aLtGreenOnLtGray := MakeAnsiString (LightGreen, LightGray);
    END;
    

  FUNCTION abLtGreenOnLtGray :   Str14;  
    BEGIN
      abLtGreenOnLtGray := MakeAnsiString (LightGreen + aBlink, LightGray);
    END;
    

  FUNCTION aLtCyanOnLtGray :     Str14; 
    BEGIN
      aLtCyanOnLtGray := MakeAnsiString (LightCyan, LightGray);
    END;
    

  FUNCTION abLtCyanOnLtGray :    Str14;  
    BEGIN
      abLtCyanOnLtGray := MakeAnsiString (LightCyan + aBlink, LightGray);
    END;
    

  FUNCTION aLtRedOnLtGray :      Str14; 
    BEGIN
      aLtRedOnLtGray := MakeAnsiString (LightRed, LightGray);
    END;
    

  FUNCTION abLtRedOnLtGray :     Str14;  
    BEGIN
      abLtRedOnLtGray := MakeAnsiString (LightRed + aBlink, LightGray);
    END;
    

  FUNCTION aLtMagentaOnLtGray :  Str14; 
    BEGIN
      aLtMagentaOnLtGray := MakeAnsiString (LightMagenta, LightGray);
    END;
    

  FUNCTION abLtMagentaOnLtGray : Str14;  
    BEGIN
      abLtMagentaOnLtGray := MakeAnsiString (LightMagenta + aBlink, LightGray);
    END;
    

  FUNCTION aYellowOnLtGray :     Str14; 
    BEGIN
      aYellowOnLtGray := MakeAnsiString (Yellow, LightGray);
    END;
    

  FUNCTION abYellowOnLtGray :    Str14;  
    BEGIN
      abYellowOnLtGray := MakeAnsiString (Yellow + aBlink, LightGray);
    END;
    

  FUNCTION aWhiteOnLtGray :      Str14; 
    BEGIN
      aWhiteOnLtGray := MakeAnsiString (White, LightGray);
    END;
    

  FUNCTION abWhiteOnLtGray :     Str14;  
    BEGIN
      abWhiteOnLtGray := MakeAnsiString (White + aBlink, LightGray);
    END;
    



BEGIN

END. {Unit AnsiColr .end.}
