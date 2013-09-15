{$I DEFINES.INC}


unit comio;
{$V-,S-,R-}

interface

uses ddfossil;
type
 AsyncIoTypes=(Fossil,Internal,Bios,Digi);
var
 AsyncIoType: AsyncIotypes;
 initok, NoFossinit, fosBnu  : boolean;
 internalinsize,internaloutsize: word;

procedure AsyncSelectPort(pn: Integer);
procedure AsyncSendChar(ch: char);
procedure AsyncReceiveChar(var ch: char);
function  AsyncCarrierPresent: boolean;
function  AsyncCharPresent: boolean;
procedure AsyncSelectFossil(var fossilname:string);
procedure AsyncCloseUp;
procedure AsyncCloseCom(cp : Integer);
procedure AsyncSetBaud(n: longint);
procedure AsyncSetDTR(state: boolean);
procedure AsyncFlushOutput;
procedure AsyncPurgeOutput;
procedure AsyncSetFlow(SoftTran,Hard,SoftRecv: boolean);
Procedure AsyncBufferStatus(var Insize,infree,outsize,outfree: word;
                            var fossilname:string);

implementation

procedure AsyncSelectPort(pn: Integer);
begin;
 case AsyncIoType of
   Fossil: begin
             port_num:=pn;
             If NoFossInit then
               begin
                 async_purge_output;      { 10/29/94 SRL This may clear up}
                 async_purge_input;       {a problem xfoss had Ripdetect. }
                 initok:=true;
               end
             else
               begin
                 async_deinit_fossil;
                 initok:=async_init_fossil;
               end;
            end;
 end;
end;

procedure AsyncSendChar(ch: char);
begin;
 case AsyncIoType of
  Fossil  : async_send(ch);
 end;
end;

procedure AsyncReceiveChar(var ch: char);
var
 b: boolean;
begin;
 case asyncIotype of
  Fossil  : b:=async_receive(ch);
 end;
end;

function AsyncCarrierPresent: boolean;
begin;
 case asyncIoType of
  Fossil  : AsyncCarrierPresent:=async_carrier_present;
 end;
end;

function AsyncCharPresent: boolean;
begin;
 case asyncIoTYpe of
  Fossil  : asyncCharPresent:=Async_buffer_check;
 end;
end;

procedure AsyncSelectFossil;
var
  Insize,infree,outsize,outfree: word;
  s:string;
  p:byte;
begin;
 AsyncIoType:=Fossil;
 AsyncBufferStatus(Insize,infree,outsize,outfree,fossilname);
 s:='';
 for p:=1 to length(fossilname) do
  s:=s+Upcase(fossilname[p]);
 p:=Pos('BNU',s);
 if p>0 then fosbnu:=true;
end;

procedure AsyncCloseUp;
begin;
 case AsyncIoType of
  Fossil  : Async_deinit_fossil;
 end;
end;

procedure AsyncCloseCom;
begin;
 case AsyncIoType of
  Fossil  : Async_deinit_fossil;
 end;
end;

procedure AsyncSetBaud(n: longint);
var
 i:byte;
begin;
 case asynciotype of
  Fossil  : If not NoFossInit then
              If fosbnu then
                async_set_baudbnu(n)
              else
                async_set_baud(n);
 end;
end;

procedure AsyncSetDTR(state: boolean);
begin;
 case AsyncIOType of
  Fossil:   async_set_dtr(state);
 end;
end;

procedure AsyncFlushOutput;
begin;
 case AsyncIOType of
  Fossil  : async_flush_output;
 end;
end;

procedure AsyncPurgeOutput;
begin;
 case AsyncIOType of
  Fossil  : async_purge_output;
 end;
end;

procedure AsyncSetFlow(SoftTran,Hard,SoftRecv: boolean);
begin;
 {*srl}
 case AsyncIOType of
  Fossil:   async_set_flow(softtran,hard,softrecv);
 end;
end;

Procedure AsyncBufferStatus(var Insize,infree,outsize,outfree: word;
                            var fossilname:string);
begin;
  case asynciotype of
    Fossil: async_buffer_Status(insize,infree,outsize,outfree,fossilname);
 end;
end;

begin;
 AsyncIoType:=Fossil;
 internalinsize :=2048;
 internaloutsize:=2048;
end.
