{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}


unit comio;

{$V-,S-,R-}

interface

uses
  ddfossil{$IFDEF MSDOS}, async2, ddigi{$ENDIF};

type
  AsyncIoTypes = (Fossil, Internal, Bios, Digi);
var
  AsyncIoType: AsyncIotypes;
  initok, NoFossinit, fosBnu: boolean;
  internalinsize, internaloutsize: word;

procedure AsyncSelectPort(pn: {$IFDEF MSDOS}byte{$ENDIF}{$IFNDEF MSDOS}integer{$ENDIF});
procedure AsyncSendChar(ch: char);
procedure AsyncReceiveChar(var ch: char);
function AsyncCarrierPresent: boolean;
function AsyncCharPresent: boolean;
procedure AsyncSelectFossil(var fossilname: string);
procedure AsyncSelectInternal;
procedure AsyncSelectDigiBoard(var digiboardname: string);
procedure AsyncCloseUp;
procedure AsyncCloseCom(cp: {$IFDEF MSDOS}byte{$ENDIF}{$IFNDEF MSDOS}integer{$ENDIF});
procedure AsyncSetBaud(n: longint);
procedure AsyncSetDTR(state: boolean);
procedure AsyncFlushOutput;
procedure AsyncPurgeOutput;
procedure AsyncSetFlow(SoftTran, Hard, SoftRecv: boolean);
procedure AsyncBufferStatus(var Insize, infree, outsize, outfree: word; var fossilname: string);
procedure SetUpPorts;
procedure LoadPorts(var port1, port2, port3, port4: word; var irq1, irq2, irq3, irq4: byte);
procedure ResetPorts(var port1, port2, port3, port4: word; var irq1, irq2, irq3, irq4: byte);


implementation

procedure AsyncSelectPort(pn: {$IFDEF MSDOS}byte{$ENDIF}{$IFNDEF MSDOS}integer{$ENDIF});
begin;
  case AsyncIoType of
    Fossil: begin
      port_num := pn{$IFDEF MSDOS} - 1{$ENDIF};
      if NoFossInit then
      begin
        async_purge_output;      { 10/29/94 SRL This may clear up}
        async_purge_input;       {a problem xfoss had Ripdetect. }
        initok := True;
      end else
      begin
        async_deinit_fossil;
        initok := async_init_fossil;
      end;
    end;
{$IFDEF MSDOS}
    Internal: begin;
      comport := pn;
      closeallcoms;
      initok := opencom(pn, InternalInSize, InternalOutSize);
    end;
    Digi: begin
      dport_num := pn - 1;
      initok := digi_init_driver;
    end;
{$ENDIF}
  end;
end;

procedure AsyncSendChar(ch: char);
begin;
  case AsyncIoType of
    Fossil: async_send(ch);
{$IFDEF MSDOS}
    Internal: begin
      while CTSStat(comport) or RTSstat(comport) do
        if not AsyncCarrierPresent then
          exit;
      ComWriteChw(comport, ch);
    end;
    Digi: begin
      while (not OutReady) do
        if not AsyncCarrierPresent then
          exit;
      Digi_send(ch);
    end;
{$ENDIF}
  end;
end;

procedure AsyncReceiveChar(var ch: char);
var
  b: boolean;
begin;
  case asyncIotype of
    Fossil: b := async_receive(ch);
{$IFDEF MSDOS}
    Internal: ch := ComReadCh(comport);
    Digi: b := digi_receive(ch);
{$ENDIF}
  end;
end;

function AsyncCarrierPresent: boolean;
begin;
  case asyncIoType of
    Fossil: AsyncCarrierPresent := async_carrier_present;
{$IFDEF MSDOS}
    Internal: AsyncCarrierPresent := DCDStat(comport);
    Digi: AsyncCarrierPresent := digi_carrier_present;
{$ENDIF}
  end;
end;

function AsyncCharPresent: boolean;
begin;
  case asyncIoTYpe of
    Fossil: asyncCharPresent := Async_buffer_check;
{$IFDEF MSDOS}
    Internal: asynccharpresent := combufferleft(comport, 'I') <> c_insize[comport];
    Digi: asyncCharPresent := Digi_buffer_check;
{$ENDIF}
  end;
end;

procedure AsyncSelectFossil;
var
  Insize, infree, outsize, outfree: word;
  s: string;
  p: byte;
begin;
  AsyncIoType := Fossil;
  AsyncBufferStatus(Insize, infree, outsize, outfree, fossilname);
  s := '';
  for p := 1 to length(fossilname) do
    s := s + Upcase(fossilname[p]);
  p := Pos('BNU', s);
  if p > 0 then
    fosbnu := True;
end;

procedure AsyncSelectDigiBoard;
begin;
{$IFDEF MSDOS}
  AsyncIoType := Digi;
  digi_Get_Info(digiboardname);
{$ENDIF}
{$IFNDEF MSDOS}
  // REENOTE Only use FOSSIL in Win32, won't ever select digiboard
{$ENDIF}
end;

procedure AsyncCloseUp;
begin;
  case AsyncIoType of
    Fossil: Async_deinit_fossil;
{$IFDEF MSDOS}
    Internal: closeallcoms;
    Digi: Digi_deinit_driver;
{$ENDIF}
  end;
end;

procedure AsyncCloseCom;
begin;
  case AsyncIoType of
    Fossil: Async_deinit_fossil;
{$IFDEF MSDOS}
    Internal: closecom(cp);
    Digi: Digi_deinit_driver;
{$ENDIF}
  end;
end;

procedure AsyncSetBaud(n: longint);
begin;
  case asynciotype of
    Fossil: if not NoFossInit then
        if fosbnu then
          async_set_baudbnu(n)
        else
          async_set_baud(n);
{$IFDEF MSDOS}
    Internal: comparams(comport, n, 8, 'N', 1);
    Digi: begin
      {             initok:=digi_set_baud(n,8,'N',1);}
      digi_flush_io;
    end;
{$ENDIF}
  end;
end;

procedure AsyncSelectInternal;
begin;
  AsyncIOType := Internal;
end;

procedure AsyncSetDTR(state: boolean);
begin;
  case AsyncIOType of
    Fossil: async_set_dtr(state);
{$IFDEF MSDOS}
    Internal: SetDTR(comport, state);
{$ENDIF}
  end;
end;

procedure AsyncFlushOutput;
begin;
  case AsyncIOType of
    Fossil: async_flush_output;
{$IFDEF MSDOS}
    Internal: ComWaitForClear(comport);
    Digi: digi_flush_output;
{$ENDIF}
  end;
end;

procedure AsyncPurgeOutput;
begin;
  case AsyncIOType of
    Fossil: async_purge_output;
{$IFDEF MSDOS}
    Internal: ClearCom(comport, 'O');
    Digi: digi_flush_output;
{$ENDIF}
  end;
end;

procedure AsyncSetFlow(SoftTran, Hard, SoftRecv: boolean);
begin;
  {*srl}
  case AsyncIOType of
    Fossil: async_set_flow(softtran, hard, softrecv);
{$IFDEF MSDOS}
    Internal: begin;
      SetCTSMode(comport, hard);
      SetRTSMode(comport, hard, C_RTSOn[comport], C_RTSOff[comport]);
      SoftHandShake(comport, softtran, 'A', 'A');
    end;
{$ENDIF}
  end;
end;

procedure AsyncBufferStatus(var Insize, infree, outsize, outfree: word; var fossilname: string);
begin;
  case asynciotype of
    Fossil: async_buffer_Status(insize, infree, outsize, outfree, fossilname);
{$IFDEF MSDOS}
    Internal: begin;
      insize := internalinsize;
      outsize := internaloutsize;
      infree := combufferleft(comport, 'I');
      outfree := combufferleft(comport, 'O');
    end;
{$ENDIF}
  end;
end;

procedure SetUpPorts;
var
  i: byte;
begin
{$IFDEF MSDOS}
  for i := 1 to 4 do
  begin
    C_PortAddr[i] := D_PortAddr[i];
    C_PortInt[i] := D_PortInt[i];
  end;
{$ENDIF}
{$IFNDEF MSDOS}
  // REENOTE Only use FOSSIL in Win32, no need to setup the ports
{$ENDIF}
end;

procedure LoadPorts(var port1, port2, port3, port4: word; var irq1, irq2, irq3, irq4: byte);
begin
{$IFDEF MSDOS}
  port1 := D_PortAddr[1];
  irq1 := D_PortInt[1];
  port2 := D_PortAddr[2];
  irq2 := D_PortInt[2];
  port3 := D_PortAddr[3];
  irq3 := D_PortInt[3];
  port4 := D_PortAddr[4];
  irq4 := D_PortInt[4];
{$ENDIF}
{$IFNDEF MSDOS}
  // REENOTE Only use FOSSIL in Win32, no need to load the ports
{$ENDIF}
end;

procedure ResetPorts(var port1, port2, port3, port4: word; var irq1, irq2, irq3, irq4: byte);
begin
{$IFDEF MSDOS}
  C_PortAddr[1] := port1;
  C_PortInt[1] := irq1;
  C_PortAddr[2] := port2;
  C_PortInt[2] := irq2;
  C_PortAddr[3] := port3;
  C_PortInt[3] := irq3;
  C_PortAddr[4] := port4;
  C_PortInt[4] := irq4;
{$ENDIF}
{$IFNDEF MSDOS}
  // REENOTE Only use FOSSIL in Win32, no need to reset the ports
{$ENDIF}
end;

begin;
{$IFDEF MSDOS}
  AsyncIoType := Internal;
  comport := 1;
{$ENDIF}
{$IFNDEF MSDOS}
  AsyncIoType := Fossil;
{$ENDIF}
  internalinsize := 2048;
  internaloutsize := 2048;
end.
