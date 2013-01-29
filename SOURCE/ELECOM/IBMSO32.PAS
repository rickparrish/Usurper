unit IBMSO32;

{$OrgName+ }

interface

uses OS2Def;

{$CDECL+}
  (****************************************************************************)
  function IBM_accept(SFamily:  ULong;
                      SAddr:    pointer;
                      SAddrL:   pointer): APIRET;
  (****************************************************************************)
  function IBM_bind(SSocket:    ULong;
                    SAddr:      pointer;
                    SAddrLen:   ULong):   APIRET;
  (****************************************************************************)
  function IBM_connect(SSocket: ULong;
                       SAddr:   pointer;
                       SAddrLen:ULong):   APIRET;
  (****************************************************************************)
  function IBM_gethostid: APIRET;
  (****************************************************************************)
  function IBM_select( Sockets: pointer;
                       noreads, nowrites, noexcepts: longint;
                       timeout: longint ): ApiRet;
  (****************************************************************************)
  function IBM_getsockname(SSocket: ULong;
                           SName:   pointer;
                           SLength: pointer): APIRET;
  (****************************************************************************)
  function IBM_ioctl(SSocket:  ULong;
                     SRequest: longint;
                     SArgp:    pointer;
                     ArgSize:  longint): APIRET;
  (****************************************************************************)
  function IBM_listen(SSocket: ULong;
                      SQueue:  ULong): APIRET;
  (****************************************************************************)
  function IBM_getsockopt(SSocket:  uLong;
                      sLevel:   LongInt;
                      sOptname: LongInt;
                      sOptVal:  pchar;
                      var sOptLen:  LongInt ): ApiRet;
  (****************************************************************************)
  FUNCTION IBM_setsockopt(sSocket:  ulong;
                          sLevel:   uLong;
                          sOptName: uLong;
                          sOptVal:  pointer;
                          sOptLen:  uLong ): ApiRet;
  (****************************************************************************)
  function IBM_recv(SSocket:   ULong;
                    SBuffer:   pointer;
                    SLength:   ULong;
                    SFlags:    ULong): APIRET;
  (****************************************************************************)
  function IBM_send(SSocket:   ULong;
                    SBuffer:   pointer;
                    SLength:   ULong;
                    SFlags:    ULong): APIRET;
  (****************************************************************************)
  function IBM_socket(SDomain:    ULong;
                     SType:      ULong;
                     SProtocol:  ULong): APIRET;
  (****************************************************************************)
  function IBM_soclose(SProtocol: ULong): APIRET;
  (****************************************************************************)
  function IBM_sock_errno: APIRET;
  (****************************************************************************)
  function IBM_shutdown(SSocket: ULong;
                        SFlags:  ULong): APIRET;
  (****************************************************************************)
  function IBM_sock_init: APIRET;
  (****************************************************************************)
  function IBM_so_cancel(SProtocol: ULong): APIRET;
  (****************************************************************************)
{$CDECL-}

implementation

const
  Version    = '00.90';
  UseString:  string = '@(#)import interface unit for IBM TCP/IP so32dll.dll'+#0;
  CopyRight1: string = '@(#)ibmso32dll Version '+Version+' - 10.10.96'+#0;
  CopyRight2: string = '@(#)(C) Chr.Hohmann BfS ST2.2 1996'+#0;

const
  sockets       = 'SO32DLL';
  network       = 'TCP32DLL';

{$CDECL+}
  function IBM_accept;             external sockets index 1;
  function IBM_bind;               external sockets index 2;
  function IBM_connect;            external sockets index 3;
  function IBM_gethostid;          external sockets index 4;
  function IBM_getsockname;        external sockets index 6;
  function IBM_ioctl;              external sockets index 8;
  function IBM_listen;             external sockets index 9;
  function IBM_recv;               external sockets index 10;
  function IBM_send;               external sockets index 13;
  function IBM_socket;             external sockets index 16;
  function IBM_soclose;            external sockets index 17;
  function IBM_sock_errno;         external sockets index 20;
  function IBM_shutdown;           external sockets index 25;
  function IBM_sock_init;          external sockets index 26;
  function IBM_so_cancel;          external sockets index 18;
  function IBM_getsockopt;         external sockets index 7;
  function IBM_setsockopt;         external sockets index 15;
  function IBM_select;             external sockets index 12;
{$CDECL-}

end.
