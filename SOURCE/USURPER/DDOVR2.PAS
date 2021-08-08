{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
unit ddovr2;

{$O+,F+,V-}

interface

uses
  dos, jakob, crt;

procedure Loadconfig(fn: string; var bbs_software: byte; var user_first_name, user_last_name: string;
  var user_access_level: word; var bbs_time_left: integer;
  var com_port: {$IFDEF MSDOS}byte{$ENDIF}{$IFNDEF MSDOS}integer{$ENDIF}; var baud_rate: longint;
  var node_num: integer; {jakob; originally BYTE in DDplus version}
  var local: boolean; var Graphics: byte; var color1: boolean; var color_chg: boolean;
  var NoFossInit: boolean; var board_name: string; var pause_code: string; var sysop_first_name: string;
  var sysop_last_name: string; var maxtime: word; var localcol: boolean; var statfore: byte;
  var statback: byte; var statline: boolean; var EMSOk, NetOk, NoLocal: boolean; var fossilio, digiio: boolean;
  var dropfilepath: string; var GoRip: byte; var lockbaud: longint; var nodirect: boolean;
  var port1, port2, port3, port4: word; var irq1, irq2, irq3, irq4: byte);

var
  ddcfgp1, ddcfgp2, ddcfgps: string[80];
const
  DDUserConfigPtr: pointer = nil;

implementation

{$IFDEF FPC}
  uses
    RPPort;
{$ENDIF}

const
{$IFDEF UNIX}
  DIRECTORY_SEPARATOR = '/';
{$ENDIF}
{$IFNDEF UNIX}
  DIRECTORY_SEPARATOR = '\';
{$ENDIF}

type
  iomodetypes = (localu, remote, maint);
var
  iomode: iomodetypes;
  ctlnm:  string[2];

procedure CallProc;
{$IFDEF MSDOS}
inline($FF/$1E/DDUserConfigPtr);
{$ENDIF}
{$IFNDEF MSDOS}
begin
  // REENOTE Doesn't look like DDUserConfigPtr is ever assigned to, so it never needs to be called
end;

{$ENDIF}

procedure Loadconfig(fn: string; var bbs_software: byte; var user_first_name, user_last_name: string;
  var user_access_level: word; var bbs_time_left: integer;
  var com_port: {$IFDEF MSDOS}byte{$ENDIF}{$IFNDEF MSDOS}integer{$ENDIF}; var baud_rate: longint;
  var node_num: integer; var local: boolean; var Graphics: byte; var color1: boolean; var color_chg: boolean;
  var noFossInit: boolean; var board_name: string; var pause_code: string; var sysop_first_name: string;
  var sysop_last_name: string; var maxtime: word;
  { var quiet: boolean; }
  var localcol: boolean; var statfore: byte; var statback: byte; var statline: boolean;
  var EMSOk, NetOK, NoLocal: boolean; var fossilio, digiio: boolean; var dropfilepath: string;
  var GoRip: byte; var lockbaud: longint; var nodirect: boolean; var port1, port2, port3, port4: word;
  var irq1, irq2, irq3, irq4: byte);

  function getparam(s: string; n: integer): string;
  var
    a:  integer;
    s2: string;
  begin;

    while (length(s) > 0) and (s[1] = ' ') do
      Delete(s, 1, 1);
    while n > 1 do
    begin;
      while (length(s) > 0) and (s[1] <> ' ') do
        Delete(s, 1, 1);
      while (length(s) > 0) and (s[1] = ' ') do
        Delete(s, 1, 1);
      n := n - 1;
    end;
      a := 1;
      s2 := '';
      while (s[a] <> ' ') and (a <= length(s)) do
      begin;
        s2 := s2 + upcase(s[a]);
        a := a + 1;
      end;
      s := s2;
    while (length(s) > 0) and (s[length(s)] = ' ') do
      Delete(s, length(s), 1);
    for a := 1 to length(s) do
      s[a] := upcase(s[a]);
    getparam := s;
  end;

  function getsecond(s: string): string;
  begin;
    while (length(s) > 0) and (s[1] = ' ') do
      Delete(s, 1, 1);
    while (length(s) > 0) and (s[1] <> ' ') do
      Delete(s, 1, 1);
    while (length(s) > 0) and (s[1] = ' ') do
      Delete(s, 1, 1);
    while (length(s) > 0) and (s[length(s)] = ' ') do
      Delete(s, length(s), 1);
    getsecond := s;
  end;

  function numparams(s: string): integer;
  var
    i: integer;
  begin;
    i := 0;
    numparams := 0;
    if length(s) = 0 then
      exit;
    if s[1] = ';' then
      exit;
    if s[2] = ';' then
      exit;
    if getparam(s, 1) <> '' then
      Inc(i);
    if getparam(s, 2) <> '' then
      Inc(i);
    if getparam(s, 3) <> '' then
      Inc(i);
    numparams := i;
  end;

  procedure Port_rtn(var s2, s3: string; var portadd: word; var irq: byte);
  var
    a: integer;
  begin
    val('$' + s2, portadd, a);
    val(s3, irq, a);
  end;

  procedure DDError(s: string);
  begin;
    Write(^G^G);
    writeln('ERROR: ' + s);
    Write(^G^G);
    delay2(2000);
  end;

  procedure BadParam(s: string);
  begin;
    dderror('Invalid parameter: ' + s);
    halt;
  end;

  procedure processcmdline;
  var
    a, b:  integer;
    s, s2: string;
  begin;
    iomode := remote;
    dropfilepath := '';
    ctlnm := '';
    for a := 1 to paramcount do
    begin;
      s := ParamStr(a);
{$IFNDEF UNIX}
      for b := 1 to length(s) do
        s[b] := upcase(s[b]);
{$ENDIF}
      if (s[1] = '/') and (length(s) > 1) then
      begin;
        Delete(s, 1, 1);
        s2 := s;
        Delete(s2, 1, 1);
        EMSOK := False;
        case UpCase(s[1]) of
          'B': val(s2, lockbaud, b);
          'C': val(s2, com_port, b);
          'E': EMSOk := True;
          'H', 'F': iomode := maint;
          'L': iomode := localu;
          'N': val(s2, node_num, b);
          'M': ctlnm := s2;
          'P': begin;
            if s2[length(s2)] <> DIRECTORY_SEPARATOR then
              s2 := s2 + DIRECTORY_SEPARATOR;
            dropfilepath := s2;
          end;
          'R': GoRip := 4;
          'V': NoLocal := True;
          'W': NetOk := True;
        end; {case .end.}
      end;
    end;
  end;

  procedure SelectCtl;
  var
    P: PathStr;
    D: DirStr;
    N: NameStr;
    E: ExtStr;
  begin
    p := fn;
    Fsplit(p, d, n, e);
    fn := d + n + ctlnm + e;
  end;

var
  s:       string;
  f:       Text;
  a: integer;
  ps, p1, p2, p3: string[80];
  ofm:     word;
begin;

  maxtime := 999;
  localcol := True;
  sysop_first_name := 'STEVE';
  sysop_last_name := 'LORENZ';
  board_name := 'The Officers Club BBS';
  pause_code := '@PAUSE@';
  bbs_software := 11; {doorsys}
  statline := True;
  nodirect := False;
  color1 := False;
  EMSOK := False;
  NetOK := False;
  NoLocal := False;
  fossilio := True;
  noFossInit := False;
  digiio := False;
  lockbaud := 0;
  statfore := 7;
statback := 1;

  processcmdline;
  selectctl;
  ofm := filemode;
  filemode := 66;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
  Assign(f, fn);

 {$i-}reset(f);{$I+}

  if ioresult <> 0 then
  begin
    Assign(f, 'DDPLUS.CTL');
  {$i-}
    reset(f);
  {$I+}
  end;

  if ioresult = 0 then
  begin
    while not EOF(f) do
    begin;
      readln(f, s);
      if numparams(s) > 0 then
      begin;
        p1 := getparam(s, 1);
        p2 := getparam(s, 2);
        p3 := getparam(s, 3);
        ps := getsecond(s);

        if p1 = 'SYSOPFIRST' then
          sysop_first_name := ps else
        if p1 = 'SYSOPLAST' then
          sysop_last_name := ps else
        if p1 = 'BBSNAME' then
          board_name := ps else
        if p1 = 'BBSTYPE' then
        begin;
          if p2 = 'LOCAL' then
            bbs_software := 1;
          if p2 = 'QUICK' then
            bbs_software := 3 else
          if p2 = 'PCB12' then
            bbs_software := 4 else
          if p2 = 'WWIV' then
            bbs_software := 5 else
          if p2 = 'PCB15' then
            bbs_software := 6 else
          if p2 = 'RBBS' then
            bbs_software := 7 else
          if p2 = 'PHOENIX' then
            bbs_software := 8 else
          if p2 = 'DORINFO1' then
            bbs_software := 9 else
          if p2 = 'PCB14' then
            bbs_software := 10 else
          if p2 = 'DOORSYS' then
            bbs_software := 11 else
          if p2 = 'SPITFIRE' then
            bbs_software := 12 else
          if p2 = '2AM' then
            bbs_software := 13 else
          if p2 = 'TRIBBS' then
            bbs_software := 14 else
          if p2 = 'DOOR32' then
            bbs_software := 15 else
            badparam(s);
        end else
        if p1 = 'STATUS' then
        begin;
          if p2 = 'OFF' then
            statline := False else
          if p2 = 'ON' then
            statline := True else
            badparam(s);
        end else
        if p1 = 'DIGI' then
          digiio := True  else
        if p1 = 'FOSSIL' then
        begin
          fossilio := True;
          noFossInit := False;
        end else
        if p1 = 'XFOSSIL' then
        begin
          fossilio := True;
          noFossInit := True;
        end else
        if p1 = 'LOCKBAUD' then
          val(p2, lockbaud, a) else
        if p1 = 'PORT1' then
          port_rtn(p2, p3, port1, irq1) else
        if p1 = 'PORT2' then
          port_rtn(p2, p3, port2, irq2) else
        if p1 = 'PORT3' then
          port_rtn(p2, p3, port3, irq3) else
        if p1 = 'PORT4' then
          port_rtn(p2, p3, port4, irq4) else
        if p1 = 'STATFORE' then
          val(p2, statfore, a) else
        if p1 = 'STATBACK' then
          val(p2, statback, a) else
        if p1 = 'MAXTIME' then
          val(p2, maxtime, a) else
        if p1 = 'COLOR' then
          localcol := True else
        if p1 = 'MONO' then
          localcol := False else
        if p1 = 'COLOR1' then
          color1 := True else
        if p1 = 'COMPORT' then
          val(p2, com_port, a) else
        if p1 = 'PAUSECODE' then
          pause_code := ps else

        begin;
          ddcfgp1 := p1;
          ddcfgp2 := p2;
          ddcfgps := ps;
          if dduserconfigptr <> nil then
            callproc;
        end;

      end;
    end;
    Close(f);
  end;
  filemode := ofm;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

{$IFNDEF MSDOS}
  {$IFNDEF GO32V2}
    { ensure win32 doors run with fossil io (where we put the socket code) }
    bbs_software := 15;
    fossilio := True;
    noFossInit := False;
  {$ENDIF}
{$ENDIF}

  case iomode of
    remote: ;
    maint: bbs_software := 0;
    localu: bbs_software := 1;
  end;
end;

end.
{
 /E - Use EMS for extra memory for overlays
 /Bxxx - Specify locked baud rate (i.e. /B38400)
 /C    - Specify comport number.
 /H    - Specify maintenance mode 1.
 /F    - Specify maintenance mode 2.
 /L -    Local mode';
 /Nx   - Specify node number
 /Mx   - Specify multiple ctl file number
 /R    - Force RIP graphics
 /Pyyy - Specify path to drop file (i.e. /Pc:\bbs)
 /V    - Turn local vidio off (i.e. local blue screen
 /W - A Dos only Network is present

    }
