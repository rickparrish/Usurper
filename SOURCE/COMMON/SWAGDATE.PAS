{$I DEFINES.INC}
Unit SwagDate;

Interface

Function Swag_Date : longint;

Implementation

Uses DOS;

CONST DaysPerYear = 365;

TYPE Month = (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec);
             (* REMEMBER: ORD values for Month are 0..11 - NOT 1..12 ! *)
     Date = RECORD
              da: 1..31;
              mo: Month;
              yr: 1..9999
            END;

 VAR maxDay: ARRAY [Month] OF INTEGER;
     daysBefore: ARRAY [Month] OF INTEGER;

PROCEDURE GetSysDate(VAR d: Date);
  (* Reads the system clock and assigns the date to d
     and the day of the week to dayOfWeek.            *)
  VAR SysYear,SysMonth,SysDay,SysDOW : word;
BEGIN
 GetDate(SysYear,SysMonth,SysDay,SysDOW);
 d.yr := SysYear;
 d.mo := Month(SysMonth-1);
 d.da := SysDay
{ dayOfWeek := DayType(SysDOW+1);   }
END;

PROCEDURE MonthsInit;
  VAR mo: Month;
BEGIN
  maxDay[Jan] := 31;
  maxDay[Feb] := 28;  (* adjust for leap years later *)
  maxDay[Mar] := 31;
  maxDay[Apr] := 30;
  maxDay[May] := 31;
  maxDay[Jun] := 30;
  maxDay[Jul] := 31;
  maxDay[Aug] := 31;
  maxDay[Sep] := 30;
  maxDay[Oct] := 31;
  maxDay[Nov] := 30;
  maxDay[Dec] := 31;

  daysBefore[Jan] := 0;
  FOR mo := Jan TO Nov DO
    daysBefore[Month(ORD(mo)+1)] := daysBefore[mo] + maxDay[mo]
END;

FUNCTION IsLeapYear(Const yr: INTEGER): BOOLEAN;
BEGIN
  IsLeapYear := ((yr MOD 4 = 0) AND (yr MOD 100 <> 0)) OR (yr MOD 400 = 0)
END;

FUNCTION NumDays(CONST d: Date): LONGINT;
  (* NumDays returns an ordinal value for the date
     with January 1, 0001 assigned the value 1.    *)
  VAR result, leapYears, lYr: LONGINT;
BEGIN
  WITH d DO BEGIN
    lYr:=yr-1;
    result := (da);
    INC(result, daysBefore[mo]);
    INC(result,lYr * DaysPerYear);
    leapYears := (lYr DIV 4) - (lYr DIV 100) + (lYr DIV 400);
    INC(result, leapYears);
    IF (mo > Feb) AND IsLeapYear(yr) THEN INC(result)
  END;
  NumDays := result
END;

VAR currentDay : date;

Function Swag_Date;
begin
  GetSysDate(currentDay);
  MonthsInit;
  swag_date:=NumDays(currentDay);
end;
end.

