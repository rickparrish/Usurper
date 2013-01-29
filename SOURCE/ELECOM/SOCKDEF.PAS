unit SockDef;
(*
**
** SOCKDEF routines
**
** Copyright (c) 1998 by Thomas W. Mueller
**
** Created : 24-Oct-1998
** Last update : 24-Oct-1998
**
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses
  Sysutils,
{$IFDEF OS2}
  Os2def;
{$ENDIF}
{$IFDEF LINUX}
  Linux;
{$ENDIF}
{$IFDEF WIN32}
  Windows;
{$ENDIF}

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

{$IFDEF VER0_99_13}
type pInteger = ^Integer;
     tFarProc = pointer;
     SmallInt = System.Integer;
{$ENDIF}

{$IFDEF LINUX}
type ULONG    = longint;
{$ENDIF}

type
  tSockDesc  = LongInt;
  SmallWord  = System.Word;

type
  eSocketErr = class(Exception);

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

const
  MaxHostNameLen = 120;

(*
** Option flags per-socket.
*)
{$IFNDEF LINUX}
(*
** Level number for (get/set)sockopt() to apply to socket itself.
*)
  SOL_SOCKET      =$ffff;          // options for socket level

  SO_DEBUG        =$0001;          // turn on debugging info recording
  SO_ACCEPTCONN   =$0002;          // socket has had listen()
  SO_REUSEADDR    =$0004;          // allow local address reuse
  SO_KEEPALIVE    =$0008;          // keep connections alive
  SO_DONTROUTE    =$0010;          // just use interface addresses
  SO_BROADCAST    =$0020;          // permit sending of broadcast msgs
  SO_USELOOPBACK  =$0040;          // bypass hardware when possible
  SO_LINGER       =$0080;          // linger on close if data present
  SO_OOBINLINE    =$0100;          // leave received OOB data in line

(*
** Additional options, not kept in so_options.
*)
  SO_SNDBUF       =$1001;          // send buffer size
  SO_RCVBUF       =$1002;          // receive buffer size
  SO_SNDLOWAT     =$1003;          // send low-water mark
  SO_RCVLOWAT     =$1004;          // receive low-water mark
  SO_SNDTIMEO     =$1005;          // send timeout
  SO_RCVTIMEO     =$1006;          // receive timeout
  SO_ERROR        =$1007;          // get error status and clear
  SO_TYPE         =$1008;          // get socket type

{$ELSE}
  SOL_SOCKET      = 1;

  SO_DEBUG        = 1;
  SO_REUSEADDR    = 2;
  SO_TYPE         = 3;
  SO_ERROR        = 4;
  SO_DONTROUTE    = 5;
  SO_BROADCAST    = 6;
  SO_SNDBUF       = 7;
  SO_RCVBUF       = 8;
  SO_KEEPALIVE    = 9;
  SO_OOBINLINE    = 10;
  SO_NO_CHECK     = 11;
  SO_PRIORITY     = 12;
  SO_LINGER       = 13;
  SO_BSDCOMPAT    = 14;
{$ENDIF}


(*
** Address families.
*)
  AF_UNSPEC      =  0;              // unspecified
  AF_UNIX        =  1;              // local to host (pipes, portals)
  AF_INET        =  2;              // internetwork: UDP, TCP, etc.
  AF_IMPLINK     =  3;              // arpanet imp addresses
  AF_PUP         =  4;              // pup protocols: e.g. BSP
  AF_CHAOS       =  5;              // mit CHAOS protocols
  AF_NS          =  6;              // XEROX NS protocols
  AF_NBS         =  7;              // nbs protocols
  AF_ECMA        =  8;              // european computer manufacturers
  AF_DATAKIT     =  9;              // datakit protocols
  AF_CCITT       = 10;              // CCITT protocols, X.25 etc
  AF_SNA         = 11;              // IBM SNA
  AF_DECnet      = 12;              // DECnet
  AF_DLI         = 13;              // Direct data link interface
  AF_LAT         = 14;              // LAT
  AF_HYLINK      = 15;              // NSC Hyperchannel
  AF_APPLETALK   = 16;              // Apple Talk

  AF_OS2         = AF_UNIX;

  AF_NB          = 17;                // Netbios
  AF_NETBIOS     = AF_NB;

  AF_MAX         = 18;

(*
** Protocol families, same as address families for now.
*)
  PF_UNSPEC       = AF_UNSPEC;
  PF_UNIX         = AF_UNIX;
  PF_INET         = AF_INET;
  PF_IMPLINK      = AF_IMPLINK;
  PF_PUP          = AF_PUP;
  PF_CHAOS        = AF_CHAOS;
  PF_NS           = AF_NS;
  PF_NBS          = AF_NBS;
  PF_ECMA         = AF_ECMA;
  PF_DATAKIT      = AF_DATAKIT;
  PF_CCITT        = AF_CCITT;
  PF_SNA          = AF_SNA;
  PF_DECnet       = AF_DECnet;
  PF_DLI          = AF_DLI;
  PF_LAT          = AF_LAT;
  PF_HYLINK       = AF_HYLINK;
  PF_APPLETALK    = AF_APPLETALK;
  PF_NETBIOS      = AF_NB;
  PF_NB           = AF_NB;
  PF_OS2          = PF_UNIX;
  PF_MAX          = AF_MAX;

(*
** Maximum queue length specifiable by listen.
*)

  SOMAXCONN       = 5;

  FREAD  =1;
  FWRITE =2;

  MSG_OOB         =$1;             // process out-of-band data
  MSG_PEEK        =$2;             // peek at incoming message
  MSG_DONTROUTE   =$4;             // send without using routing tables
  MSG_FULLREAD    =$8;             // send without using routing tables

  MSG_MAXIOVLEN   =16;

const
{ All Windows Sockets error constants are biased by WSABASEERR from the "normal" }

  WSABASEERR              = 10000;

{ Windows Sockets definitions of regular Microsoft C error constants }

  WSAEINTR                = (WSABASEERR+4);
  WSAEBADF                = (WSABASEERR+9);
  WSAEACCES               = (WSABASEERR+13);
  WSAEFAULT               = (WSABASEERR+14);
  WSAEINVAL               = (WSABASEERR+22);
  WSAEMFILE               = (WSABASEERR+24);

{ Windows Sockets definitions of regular Berkeley error constants }

{$IFNDEF LINUX}
  WSAEWOULDBLOCK          = (WSABASEERR+35);
  WSAEINPROGRESS          = (WSABASEERR+36);
  WSAEALREADY             = (WSABASEERR+37);
  WSAENOTSOCK             = (WSABASEERR+38);
  WSAEDESTADDRREQ         = (WSABASEERR+39);
  WSAEMSGSIZE             = (WSABASEERR+40);
  WSAEPROTOTYPE           = (WSABASEERR+41);
  WSAENOPROTOOPT          = (WSABASEERR+42);
  WSAEPROTONOSUPPORT      = (WSABASEERR+43);
  WSAESOCKTNOSUPPORT      = (WSABASEERR+44);
  WSAEOPNOTSUPP           = (WSABASEERR+45);
  WSAEPFNOSUPPORT         = (WSABASEERR+46);
  WSAEAFNOSUPPORT         = (WSABASEERR+47);
  WSAEADDRINUSE           = (WSABASEERR+48);
  WSAEADDRNOTAVAIL        = (WSABASEERR+49);
  WSAENETDOWN             = (WSABASEERR+50);
  WSAENETUNREACH          = (WSABASEERR+51);
  WSAENETRESET            = (WSABASEERR+52);
  WSAECONNABORTED         = (WSABASEERR+53);
  WSAECONNRESET           = (WSABASEERR+54);
  WSAENOBUFS              = (WSABASEERR+55);
  WSAEISCONN              = (WSABASEERR+56);
  WSAENOTCONN             = (WSABASEERR+57);
  WSAESHUTDOWN            = (WSABASEERR+58);
  WSAETOOMANYREFS         = (WSABASEERR+59);
  WSAETIMEDOUT            = (WSABASEERR+60);
  WSAECONNREFUSED         = (WSABASEERR+61);
  WSAELOOP                = (WSABASEERR+62);
  WSAENAMETOOLONG         = (WSABASEERR+63);
  WSAEHOSTDOWN            = (WSABASEERR+64);
  WSAEHOSTUNREACH         = (WSABASEERR+65);
  WSAENOTEMPTY            = (WSABASEERR+66);
  WSAEPROCLIM             = (WSABASEERR+67);
  WSAEUSERS               = (WSABASEERR+68);
  WSAEDQUOT               = (WSABASEERR+69);
  WSAESTALE               = (WSABASEERR+70);
  WSAEREMOTE              = (WSABASEERR+71);

  WSAEDISCON              = (WSABASEERR+101);
{$ENDIF}

{$IFDEF LINUX}
  WSAEWOULDBLOCK          = 11;
  WSAEINPROGRESS          = 115;
  WSAEALREADY             = 114;
  WSAENOTSOCK             = 88;
  WSAEDESTADDRREQ         = 89;
  WSAEMSGSIZE             = 90;
  WSAEPROTOTYPE           = 91;
  WSAENOPROTOOPT          = 92;
  WSAEPROTONOSUPPORT      = 93;
  WSAESOCKTNOSUPPORT      = 94;
  WSAEOPNOTSUPP           = 95;
  WSAEPFNOSUPPORT         = 96;
  WSAEAFNOSUPPORT         = 97;
  WSAEADDRINUSE           = 98;
  WSAEADDRNOTAVAIL        = 99;
  WSAENETDOWN             = 100;
  WSAENETUNREACH          = 101;
  WSAENETRESET            = 102;
  WSAECONNABORTED         = 103;
  WSAECONNRESET           = 104;
  WSAENOBUFS              = 105;
  WSAEISCONN              = 106;
  WSAENOTCONN             = 107;
  WSAESHUTDOWN            = 108;
  WSAETOOMANYREFS         = 109;
  WSAETIMEDOUT            = 110;
  WSAECONNREFUSED         = 111;
  WSAELOOP                = 40;
  WSAENAMETOOLONG         = 36;
  WSAEHOSTDOWN            = 112;
  WSAEHOSTUNREACH         = 113;
  WSAENOTEMPTY            = 39;
  WSAEPROCLIM             = 00;
  WSAEUSERS               = 87;
  WSAEDQUOT               = 122;
  WSAESTALE               = 116;
  WSAEREMOTE              = 66;
{$ENDIF}

{ Extended Windows Sockets error constant definitions }

  WSASYSNOTREADY          = (WSABASEERR+91);
  WSAVERNOTSUPPORTED      = (WSABASEERR+92);
  WSANOTINITIALISED       = (WSABASEERR+93);

{ Error return codes from gethostbyname() and gethostbyaddr()
  (when using the resolver). Note that these errors are
  retrieved via WSAGetLastError() and must therefore follow
  the rules for avoiding clashes with error numbers from
  specific implementations or language run-time systems.
  For this reason the codes are based at WSABASEERR+1001.
  Note also that [WSA]NO_ADDRESS is defined only for
  compatibility purposes. }

{ Authoritative Answer: Host not found }

  WSAHOST_NOT_FOUND       = (WSABASEERR+1001);
  HOST_NOT_FOUND          = WSAHOST_NOT_FOUND;

{ Non-Authoritative: Host not found, or SERVERFAIL }

  WSATRY_AGAIN            = (WSABASEERR+1002);
  TRY_AGAIN               = WSATRY_AGAIN;

{ Non recoverable errors, FORMERR, REFUSED, NOTIMP }

  WSANO_RECOVERY          = (WSABASEERR+1003);
  NO_RECOVERY             = WSANO_RECOVERY;

{ Valid name, no data record of requested type }

  WSANO_DATA              = (WSABASEERR+1004);
  NO_DATA                 = WSANO_DATA;

{ no address, look for MX record }

  WSANO_ADDRESS           = WSANO_DATA;
  NO_ADDRESS              = WSANO_ADDRESS;

{ Windows Sockets errors redefined as regular Berkeley error constants.
  These are commented out in Windows NT to avoid conflicts with errno.h.
  Use the WSA constants instead. }

  EWOULDBLOCK        =  WSAEWOULDBLOCK;
  EINPROGRESS        =  WSAEINPROGRESS;
  EALREADY           =  WSAEALREADY;
  ENOTSOCK           =  WSAENOTSOCK;
  EDESTADDRREQ       =  WSAEDESTADDRREQ;
  EMSGSIZE           =  WSAEMSGSIZE;
  EPROTOTYPE         =  WSAEPROTOTYPE;
  ENOPROTOOPT        =  WSAENOPROTOOPT;
  EPROTONOSUPPORT    =  WSAEPROTONOSUPPORT;
  ESOCKTNOSUPPORT    =  WSAESOCKTNOSUPPORT;
  EOPNOTSUPP         =  WSAEOPNOTSUPP;
  EPFNOSUPPORT       =  WSAEPFNOSUPPORT;
  EAFNOSUPPORT       =  WSAEAFNOSUPPORT;
  EADDRINUSE         =  WSAEADDRINUSE;
  EADDRNOTAVAIL      =  WSAEADDRNOTAVAIL;
  ENETDOWN           =  WSAENETDOWN;
  ENETUNREACH        =  WSAENETUNREACH;
  ENETRESET          =  WSAENETRESET;
  ECONNABORTED       =  WSAECONNABORTED;
  ECONNRESET         =  WSAECONNRESET;
  ENOBUFS            =  WSAENOBUFS;
  EISCONN            =  WSAEISCONN;
  ENOTCONN           =  WSAENOTCONN;
  ESHUTDOWN          =  WSAESHUTDOWN;
  ETOOMANYREFS       =  WSAETOOMANYREFS;
  ETIMEDOUT          =  WSAETIMEDOUT;
  ECONNREFUSED       =  WSAECONNREFUSED;
  ELOOP              =  WSAELOOP;
  ENAMETOOLONG       =  WSAENAMETOOLONG;
  EHOSTDOWN          =  WSAEHOSTDOWN;
  EHOSTUNREACH       =  WSAEHOSTUNREACH;
  ENOTEMPTY          =  WSAENOTEMPTY;
  EPROCLIM           =  WSAEPROCLIM;
  EUSERS             =  WSAEUSERS;
  EDQUOT             =  WSAEDQUOT;
  ESTALE             =  WSAESTALE;
  EREMOTE            =  WSAEREMOTE;

  SockAddr_Len       = 16;
  In_Addr_Len        =  4;
  InAddr_Any         =  0;
  InAddr_Loopback    = $7F000001;
  InAddr_Broadcast   = $FFFFFFFF;
  InAddr_None        = $FFFFFFFF;

  SOCK_NULL      =  0;
  SOCK_STREAM    =  1;            // stream socket
  SOCK_DGRAM     =  2;            // datagram socket
  SOCK_RAW       =  3;            // raw-protocol interface
  SOCK_RDM       =  4;            // reliably-delivered message
  SOCK_SEQPACKET =  5;            // sequenced packet stream

  IPPROTO_NULL   =  0;
  IPPROTO_UDP    =  17;
  IPPROTO_TCP    =  6;


const
  IOCPARM_MASK = $7f;
  IOC_VOID     = $20000000;
  IOC_OUT      = $40000000;
  IOC_IN       = $80000000;
  IOC_INOUT    = (IOC_IN or IOC_OUT);

{$IFNDEF LINUX}
  FIONREAD     = IOC_OUT or { get # bytes to read }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 127;
  FIONBIO      = IOC_IN or { set/clear non-blocking i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 126;
  FIOASYNC     = IOC_IN or { set/clear async i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 125;
{$ENDIF}

type
  pLongInt = ^LongInt;

  pIoVec = ^tIoVec;
  tIoVec = packed record
    iov_base: POINTER;
    iov_len: LongInt;
  end;

(*
** Structure used for manipulating linger option.
*)
  tLinger = packed record
    l_onoff: LongInt;                // option on/off
    l_linger: LongInt;               // linger time
  END;

(*
** Structure used by kernel to pass protocol
** information in raw sockets.
*)

  tSockProto = packed record
    sp_family: WORD;              // address family
    sp_protocol: WORD;            // protocol
  END;

  off_t = LongInt;

  tuio = packed record
    uio_iov: pIoVec;
    uio_iovcnt: LongInt;
    uio_offset: off_t;
    uio_segflg: LongInt;
    uio_resid: LongInt;
  END;

  pIn_Addr = ^tIn_Addr;
  tIn_Addr = packed record
             case integer of
               0: (IPAddr:   ULong);
               1: (ClassA:   byte;
                   ClassB:   byte;
                   ClassC:   byte;
                   ClassD:   byte)
             end;

(*
** Structure used by kernel to store most
** addresses.
*)
  pSockAddr=^tSockAddr;
  tSockAddr=packed record
            case integer of
              0: (Sin_Family: SmallWord;
                  Sin_Port:   SmallWord;
                  Sin_Addr:   tIn_Addr;
                  Sin_Zero:   array[1.. 8] of byte);
              1: (Sa_Family:  SmallWord;
                  Sa_Addr:    array[1..14] of byte);
            end;

(*
** Message header for recvmsg and sendmsg calls.
*)
  pMsgHdr = ^tMsgHdr;
  tMsgHdr = packed record
    msg_name: pChar;               // optional address
    msg_namelen: LongInt;            // size of address
    msg_iov: pIoVec;         // scatter/gather array
    msg_iovlen: LongInt;             // # elements in msg_iov
    msg_accrights: pChar;          // access rights sent/received
    msg_accrightslen: LongInt;
  END;

  uio_rw = ( UIO_READ, UIO_WRITE );

  pHostEnt = ^tHostEnt;
  tHostEnt = packed record
    H_Name:      ^string;
    H_Alias:     pointer;
{$IFNDEF WIN32}
    H_AddrType:  longint;
    H_Length:    longint;
{$ELSE}
    h_addrtype: Smallint;
    h_length: Smallint;
{$ENDIF}
    H_Addr_List: ^pIn_Addr;
  END;

  pProtoEnt = ^tProtoEnt;
  TProtoEnt = packed record
    p_name:    pChar;     (* official protocol name *)
    p_aliases: ^pChar;   (* alias list *)
    p_proto:   SmallInt;       (* protocol # *)
  end;

  pServEnt = ^tServEnt;
  tServEnt = packed record
    s_name:    pChar;        // official service name
    s_aliases: ^pChar;       // alias list
    s_port:    SmallInt;      // port #
    s_proto:   pChar;        // protocol to use
  END;

// these types are only used in windows version
const
  FD_SETSIZE     =   64;

type
  PFDSet = ^TFDSet;
  TFDSet = packed record
    fd_count: ULONG;
    fd_array: array[0..FD_SETSIZE-1] of ULONG;
  end;

  PTimeVal = ^TTimeVal;
  TTimeVal = packed record
    tv_sec: Longint;
    tv_usec: Longint;
  end;

const
  WSADESCRIPTION_LEN     =   256;
  WSASYS_STATUS_LEN      =   128;

type
  PWSAData = ^TWSAData;
  TWSAData = packed record
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..WSADESCRIPTION_LEN] of Char;
    szSystemStatus: array[0..WSASYS_STATUS_LEN] of Char;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PChar;
  end;

(*
** The re-defination of error constants are necessary to avoid conflict with
** standard IBM C Set/2 V1.0 error constants.
**
** All OS/2 SOCKET API error constants are biased by SOCBASEERR from the "normal"
**
*)

const
  SOCBASEERR = 10000;

(*
** OS/2 SOCKET API definitions of regular Microsoft C 6.0 error constants
*)

const
  SOCEPERM = (SOCBASEERR+1);             (* Not owner *)
  SOCESRCH = (SOCBASEERR+3);             (* No such process *)
  SOCEINTR = (SOCBASEERR+4);             (* Interrupted system call *)
  SOCENXIO = (SOCBASEERR+6);             (* No such device or address *)
  SOCEBADF = (SOCBASEERR+9);             (* Bad file number *)
  SOCEACCES = (SOCBASEERR+13);            (* Permission denied *)
  SOCEFAULT = (SOCBASEERR+14);            (* Bad address *)
  SOCEINVAL = (SOCBASEERR+22);            (* Invalid argument *)
  SOCEMFILE = (SOCBASEERR+24);            (* Too many open files *)
  SOCEPIPE = (SOCBASEERR+32);            (* Broken pipe *)

  SOCEOS2ERR = (SOCBASEERR+100);            (* OS/2 Error *)

(*
** OS/2 SOCKET API definitions of regular BSD error constants
*)

const
  SOCEWOULDBLOCK = (SOCBASEERR+35);            (* Operation would block *)
  SOCEINPROGRESS = (SOCBASEERR+36);            (* Operation now in progress *)
  SOCEALREADY = (SOCBASEERR+37);            (* Operation already in progress *)
  SOCENOTSOCK = (SOCBASEERR+38);            (* Socket operation on non-socket *)
  SOCEDESTADDRREQ = (SOCBASEERR+39);            (* Destination address required *)
  SOCEMSGSIZE = (SOCBASEERR+40);            (* Message too long *)
  SOCEPROTOTYPE = (SOCBASEERR+41);            (* Protocol wrong type for socket *)
  SOCENOPROTOOPT = (SOCBASEERR+42);            (* Protocol not available *)
  SOCEPROTONOSUPPORT = (SOCBASEERR+43);            (* Protocol not supported *)
  SOCESOCKTNOSUPPORT = (SOCBASEERR+44);            (* Socket type not supported *)
  SOCEOPNOTSUPP = (SOCBASEERR+45);            (* Operation not supported on socket *)
  SOCEPFNOSUPPORT = (SOCBASEERR+46);            (* Protocol family not supported *)
  SOCEAFNOSUPPORT = (SOCBASEERR+47);            (* Address family not supported by protocol family *)
  SOCEADDRINUSE = (SOCBASEERR+48);            (* Address already in use *)
  SOCEADDRNOTAVAIL = (SOCBASEERR+49);            (* Can't assign requested address *)
  SOCENETDOWN = (SOCBASEERR+50);            (* Network is down *)
  SOCENETUNREACH = (SOCBASEERR+51);            (* Network is unreachable *)
  SOCENETRESET = (SOCBASEERR+52);            (* Network dropped connection on reset *)
  SOCECONNABORTED = (SOCBASEERR+53);            (* Software caused connection abort *)
  SOCECONNRESET = (SOCBASEERR+54);            (* Connection reset by peer *)
  SOCENOBUFS = (SOCBASEERR+55);            (* No buffer space available *)
  SOCEISCONN = (SOCBASEERR+56);            (* Socket is already connected *)
  SOCENOTCONN = (SOCBASEERR+57);            (* Socket is not connected *)
  SOCESHUTDOWN = (SOCBASEERR+58);            (* Can't send after socket shutdown *)
  SOCETOOMANYREFS = (SOCBASEERR+59);            (* Too many references: can't splice *)
  SOCETIMEDOUT = (SOCBASEERR+60);            (* Connection timed out *)
  SOCECONNREFUSED = (SOCBASEERR+61);            (* Connection refused *)
  SOCELOOP = (SOCBASEERR+62);            (* Too many levels of symbolic links *)
  SOCENAMETOOLONG = (SOCBASEERR+63);            (* File name too long *)
  SOCEHOSTDOWN = (SOCBASEERR+64);            (* Host is down *)
  SOCEHOSTUNREACH = (SOCBASEERR+65);            (* No route to host *)
  SOCENOTEMPTY = (SOCBASEERR+66);            (* Directory not empty *)

(*
** OS/2 SOCKET API errors redefined as regular BSD error constants
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end. { unit SockDef }
