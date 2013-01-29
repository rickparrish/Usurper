unit IBMTCP32;

{$OrgName+ }

interface

uses OS2Def, SockDef;

{$CDECL+}
  (****************************************************************************)
  function IBM_gethostbyname(HName: pointer): pointer;
  (****************************************************************************)
  function IBM_gethostbyaddr(HAddr:     pointer;
                             HAddrLen:  longint;
                             HAddrType: ULong): pointer;
  (****************************************************************************)
  function IBM_gethostname(HName:  pointer;
                           HLength:ULong):  APIRET;
  (****************************************************************************)
  function IBM_getservbyname(_Name, _Proto: pChar): pServEnt;
  function inet_addr(_s: pChar): ULONG;

  function getprotobyname(_Name: pChar): pProtoEnt;

  function htonl(_a: LongInt): LongInt;
  function ntohl(_a: LongInt): LongInt;
{  function htons(_a: LongInt): LongInt; }
{  function ntohs(_a: SmallInt): SmallInt; }
{$CDECL-}

implementation

const
  Version    = '00.90';
  UseString:  string = '@(#)import interface unit for IBM TCP/IP tcp32dll.dll'+#0;
  CopyRight1: string = '@(#)ibmTCP32 Version '+Version+' - 10.10.96'+#0;
  CopyRight2: string = '@(#)(C) Chr.Hohmann BfS ST2.2 1996'+#0;

const
  sockets       = 'SO32DLL';
  network       = 'TCP32DLL';

{$CDECL+}
  function inet_addr;                   external network index 5;
  function IBM_gethostbyname;           external network index 11;
  function IBM_gethostbyaddr;           external network index 12;
  function IBM_gethostname;             external network index 44;
  function getprotobyname;              external network index 21;
  function IBM_getservbyname;           external network index 24;
  function htonl;                       external network index 3;
  function ntohl;                       external network index 3;
{$CDECL-}
end.
