{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
unit SwagDate;

interface

function Swag_Date: longint;

implementation

uses
  DOS;

const DaysPerYear = 365;

type Month = (Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec);
  (* REMEMBER: ORD values for Month are 0..11 - NOT 1..12 ! *)
  Date     = record
    da: 1..31;
    mo: Month;
    yr: 1..9999
  end;

var maxDay:   array [Month] of integer;
  daysBefore: array [Month] of integer;

procedure GetSysDate(var d: Date);
  (* Reads the system clock and assigns the date to d
     and the day of the week to dayOfWeek.            *)
var SysYear, SysMonth, SysDay, SysDOW: word;
begin
  GetDate(SysYear, SysMonth, SysDay, SysDOW);
  d.yr := SysYear;
  d.mo := Month(SysMonth - 1);
  d.da := SysDay;
  { dayOfWeek := DayType(SysDOW+1);   }
end;

procedure MonthsInit;
var mo: Month;
begin
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
  for mo := Jan to Nov do daysBefore[Month(Ord(mo) + 1)] := daysBefore[mo] + maxDay[mo];
end;

function IsLeapYear(const yr: integer): boolean;
begin
  IsLeapYear := ((yr mod 4 = 0) and (yr mod 100 <> 0)) or (yr mod 400 = 0);
end;

function NumDays(const d: Date): longint;
  (* NumDays returns an ordinal value for the date
     with January 1, 0001 assigned the value 1.    *)
var Result, leapYears, lYr: longint;
begin
  with d do
  begin
    lYr := yr - 1;
    Result := (da);
    Inc(Result, daysBefore[mo]);
    Inc(Result, lYr * DaysPerYear);
    leapYears := (lYr div 4) - (lYr div 100) + (lYr div 400);
    Inc(Result, leapYears);
    if (mo > Feb) and IsLeapYear(yr) then Inc(Result);
  end;
  NumDays := Result;
end;

var currentDay: date;

function Swag_Date;
begin
  GetSysDate(currentDay);
  MonthsInit;
  swag_date := NumDays(currentDay);
end;

end.
