{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}

unit InitOver;

(**) interface (**)

uses
  Overlay, OverXms, DOS;

var Over_Ems, Over_Xms: boolean;

(**) implementation (**)

  (*NOTE: You will have to choose the buffer size
    for each particular program.  The bigger it is,
    the less "thrashing" as the program reads from
    disk.  However, the bigger it is, the less Heap
    memory is available.  Hence we define the buffer
    size in terms of the amount of heap space needed
    by the program.*)


const
  HeapNeeded = 180000; {Change this to suit your own heap requirements}

procedure Upper4(var Str: string);
InLine(
 $8C/$DA/               {      mov   DX,DS               }
 $5E/                   {      pop   SI                  }
 $1F/                   {      pop   DS                  }
 $FC/                   {      cld                       }
 $AC/                   {      lodsb                     }
 $30/$E4/               {      xor   AH,AH               }
 $89/$C1/               {      mov   CX,AX               }
 $E3/$12/               {      jcxz  @30                 }
 $BB/Ord('a')/Ord('z')/ {      mov   BX,'za'             }
 $AC/                   { @15: lodsb                     }
 $38/$D8/               {      cmp   AL,BL               }
 $72/$08/               {      jb    @28                 }
 $38/$F8/               {      cmp   AL,BH               }
 $77/$04/               {      ja    @28                 }
 $80/$6C/$FF/$20/       {      sub   BYTE PTR [SI-1],$20 }
 $E2/$F1/               { @28: loop  @15                 }
 $8E/$DA);              { @30: mov   DS,DX               }

procedure wrl(const s: string);
begin
  writeln(s);
end;

function UpCaseStr(s: string): string;
begin
  upper4(s);
  UpcaseStr := s;
end;

function Param_Hunt(const h: string): boolean; {checking for Command Line parameters}
var i: byte;
begin

  param_hunt := False;
  if paramcount > 0 then
  begin
    for i := 1 to paramcount do
    begin
      if upcasestr(ParamStr(i)) = h then
      begin
        param_hunt := True;
        break;
      end;
    end; {for i:= .end.}
  end;

end; {param_hunt .end.}

procedure SetUpOverlay;
const
  {Overlay file Environment variable, jakob}
  USU_OVR_SET = 'USUOVR';

var
  emsok, xmsok: boolean; {jakob}

  OverlayName: string[79];
  OverlayPath: string[79]; {jakob}

  BufferSize, OrigBufferSize: longint;
  N: word;
  X: longint;
begin

  {used by Usurper prog to display whether ems or xms is used}
  over_ems := False;
  over_xms := False;

  {Get USUOVR environment variable}
  overlaypath := '';
  for x := 1 to envcount do
  begin
    if pos(USU_OVR_SET, ENVSTR(x)) > 0 then
    begin
      {bingo!}
      overlaypath := copy(envstr(x), length(usu_ovr_set) + 2, 99);
      if overlaypath[length(overlaypath)] <> '\' then
      begin
        overlaypath := overlaypath + '\';
      end;
    end;
  end; {for x:= .end.}

       {OverlayPath:=''; {skit jakob! this line should be commented out in release version}
  OverlayName := OverLayPath + 'USURPER.OVR';
  OvrInit(OverlayName); {Initializes the overlay manager and opens
                        the overlay file}

  if OvrResult = OvrNotFound then
  begin
    Write('Overlay file not found: ');
    WriteLn(OverlayName);
    Halt(2);
  end;

  if OvrResult <> OvrOK then
  begin
    WriteLn('Error loading overlay file: ');
    WriteLn(OverlayName);
    Halt(3);
  end;

  xmsok := False;
  emsok := False;

  if param_hunt('/X') then
    xmsok := True;
  if param_hunt('/E') then
    emsok := True;

  if XMSOk then
  begin
    wrl('Detecting XMS capability ...');
    OvrInitXMS;

    case OvrResult of
      ovrIOError: Wrl('Overlay file I/O error.');
      ovrNoEMSDriver: Wrl('XMS driver not installed.');
      ovrNoEMSMemory: Wrl('Not enough XMS memory.');
      else begin
        Wrl('Using XMS for faster overlay swapping.');
        over_xms := True;
      end;
    end; {case .end.}

  end else
  if EMSOK then
  begin
    OvrInitEMS; {Loads the overlay file into EMS
               - EMSOK is variable flag set by
               Sysop using the /E parameter to
               tell us it's OK to use EMS}

    case OvrResult of
      ovrIOError: Wrl('Overlay file I/O error.');
      ovrNoEMSDriver: Wrl('EMSS driver not installed.');
      ovrNoEMSMemory: Wrl('Not enough EMS memory.');
      else begin
        Wrl('Using EMS for faster overlay swapping.');
        over_ems := True;
      end;
    end; {case .end.}

  end;

  OrigBufferSize := OvrGetBuf;
  BufferSize := MaxAvail - HeapNeeded;
  OvrSetBuf(BufferSize);

{ IF OvrResult <> OvrOK THEN BEGIN
  Write('Could not set overlay buffer to ');
  Write(BufferSize,'.  Remaining at default: ');
  WriteLn(OrigBufferSize);
 END;
 }
end;

begin
  SetUpOverlay;
end.
