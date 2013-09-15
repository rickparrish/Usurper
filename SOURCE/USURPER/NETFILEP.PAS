{$I DEFINES.INC}


{*********************************************************************}
{*                        N E T F I L E                              *}
{*-------------------------------------------------------------------*}
{*    Task          : Implements network supporting file functions.  *}
{*-------------------------------------------------------------------*}
{*    Author        : Michael Tischer                                *}
{*    Developed on  : 09/07/91                                       *}
{*    Last update   : 01/29/92                                       *}
{*********************************************************************}

Unit NetFileP;

Interface

uses Crt, Dos, DDPlus;             { Add CRT, DOS and DDPlus units }

const {-- Types of file access available -----------------------------}

      fm_r    = 0;                                        { Read-only }
      fm_w    = 1;                                       { Write-only }
      fm_rw   = 2;             { Read and write in normal Pascal mode }

      {-- Types of file protection -----------------------------------}

      sm_comp = $00;         { Compatibility mode, no file protection }
      sm_rw   = $10;            { Read and write prohibited by others }
      sm_r    = $20;   { Read by others permitted, writing prohibited }
      sm_w    = $30;        { Reading and writing by others permitted }
      sm_no   = $40;        { All permitted, protected by record lock }

      {-- Possible errors during procedure calls ---------------------}

      NE_OK            = $00;                              { No error }
      NE_FileNotFound  = $02;                 { Error: File not found }
      NE_PathNotFound  = $03;                 { Error: Path not found }
      NE_TooManyFiles  = $04;            { Error: Too many open files }
      NE_AccessDenied  = $05;          { Error: Access to file denied }
      NE_InvalidHandle = $06;            { Error: Invalid file handle }
      NE_AccessCode    = $07;            { Error: Illegal access code }
      NE_Share         = $20;             { Violation of Share rights }
      NE_Lock          = $21;      { Error while (un)locking a record }
      NE_ShareBuffer   = $24;                 { Share buffer overflow }

var NetError : integer;             { Error number from DOS interrupt }

function ShareInst : boolean;                      { Share installed? }

function NetErrorMsg( Number : word ) : string;       { Error message }

procedure NetReset(     FName  : string;                  { Open file }
                        AMode  : integer;
                        RecS   : word;
                    var DFile );

procedure NetRewrite(     FName  : string;            { Open new file }
                          AMode  : integer;
                          RecS   : word;
                      var DFile );

procedure NetClose( var DFile );                         { Close file }

function NetLock( var DFile;                        { Lock file range }
                      RecNo  : longint;
                      RngNum : longint ) : boolean;

function NetUnlock( var DFile;                    { Unlock file range }
                        RecNo  : longint;
                        RngNum : longint ) : boolean;

function Is_NetOpen( var DFile ) : boolean;           { Is file open? }

function Is_NetWriteOk( var DFile ) : boolean; { Writing to file O.K. }

function Is_NetReadOk( var DFile ) : boolean; { Reading from file O.K.}

{-- The Read, Write and Seek procedures only work with files set in  -}
{-- input-output mode. The following procedures must be used if      -}
{-- files must be opened in other modes.                             -}

procedure NetWrite( var DFile;                      { Write to a file }
                    var FData );

procedure NetRead( var DFile;                      { Read from a file }
                   var FData );

procedure NetSeek( var DFile;                 { Position file pointer }
                       RecNo : longint );

implementation

const {-- Function numbers for DOS calls -----------------------------}

      FCT_OPEN     = $3D;         { Function: Open file with handle   }
      FCT_CLOSE    = $3E;         { Function: Close file with handle  }
      FCT_CREATE   = $3C;         { Function: Create file with handle }
      FCT_WRITE    = $40;         { Function: Write to file           }
      FCT_READ     = $3F;         { Function: Read from file          }
      FCT_LSEEK    = $42;         { Function: Set file pointer        }
      FCT_REC_LOCK = $5C;         { Function: Record locking          }

      {-- Function & interrupt numbers for other interrupt calls -----}

      MULTIPLEX    = $2F;                       { Multiplex interrupt }
      FCT_SHARE    = $1000;                  { Install text for Share }

      {-- Turbo Pascal file identifiers ------------------------------}

      fmClosed     = $D7B0;                             { File closed }
      fmInput      = $D7B1;                 { File opened for reading }
      fmOutput     = $D7B2;                 { File opened for writing }
      fmInOut      = $D7B3;     { File opened for reading and writing }

{*********************************************************************}
{* ShareInst   : Installs test for Share.                            *}
{* Input       : None                                                *}
{* Output      : TRUE if Share is installed                          *}
{* Global var. : NetError/W (error status after call)                *}
{*********************************************************************}

function ShareInst : boolean;
begin
  ShareInst := true;
end;

{*********************************************************************}
{* NetErrorMsg : Error message text.                                 *}
{* Input       : Error number                                        *}
{* Output      : Meaning                                             *}
{*********************************************************************}

function NetErrorMsg( Number : word ) : string;

var Sdummy : string;

begin
  case Number of
    NE_OK            : NetErrorMsg := 'No error';
    NE_FileNotFound  : NetErrorMsg := 'File not found';
    NE_PathNotFound  : NetErrorMsg := 'Path not found';
    NE_TooManyFiles  : NetErrorMsg := 'Too many files open';
    NE_AccessDenied  : NetErrorMsg := 'File access denied';
    NE_InvalidHandle : NetErrorMsg := 'Invalid file handle';
    NE_AccessCode    : NetErrorMsg := 'Illegal access code';
    NE_Share         : NetErrorMsg := 'Violation of Share rights';
    NE_Lock          : NetErrorMsg := 'Error during record lock';
    NE_ShareBuffer   : NetErrorMsg := 'Share buffer overflow';
    else               begin
                         str( Number, Sdummy );
                         NetErrorMsg := 'DOS error: ' + Sdummy;
                       end;
  end;
end;

{*********************************************************************}
{* NetCreate   : Creates a file.                                     *}
{* Input       : Filename, opening mode, record size                 *}
{* Output      : Opened file                                         *}
{* Global var. : NetError/W (error status after call)                *}
{*********************************************************************}

procedure NetRewrite(     FName  : string;
                          AMode  : integer;
                          RecS   : word;
                      var DFile );
begin
  WriteLn('REEPORT NETFILEP NetRewrite');
end;

{*********************************************************************}
{* NetReset    : Opens a specific file.                              *}
{* Input       : Filename, open mode, record size                    *}
{* Output      : Opened file                                         *}
{* Global var. : NetError/W (error status after call)                *}
{*********************************************************************}

procedure NetReset(     FName  : string;
                        AMode  : integer;
                        RecS   : word;
                    var DFile );
begin
  WriteLn('REEPORT NETFILEP NetReset');
end;

{*********************************************************************}
{* NetClose  : Closes a file.                                        *}
{* Input     : File handle                                           *}
{* Output    : None                                                  *}
{*********************************************************************}

procedure NetClose( var DFile );
begin
  WriteLn('REEPORT NETFILEP NetClose');
end;

{*********************************************************************}
{* Locking     : Locks or unlocks a file range.                      *}
{* Input       : File handle, operation, offset for start of file,   *}
{*               length of range to be (un)locked                    *}
{* Output      : TRUE if successful                                  *}
{* Global var. : NetError/W (error status after call)                *}
{* Info        : Call NetLock and NetUnlock for internal access only.*}
{*********************************************************************}

function Locking( Handle    : word;
                  Operation : byte;
                  Offset    : longint;
                  WrdLen    : longint ) : boolean;
begin
  WriteLn('REEPORT NETFILEP Locking');
end;

{*********************************************************************}
{* NetLock     : Locks records.                                      *}
{* Input       : File, record number, number of records to be locked *}
{* Output      : TRUE if successful                                  *}
{* Global var. : NetError/W (error status after call)                *}
{*********************************************************************}

function NetLock( var DFile;
                      RecNo  : longint;
                      RngNum : longint ) : boolean;

begin
  NetLock := Locking( filerec( DFile ).Handle, 0,
                      filerec( DFile ).Recsize * RecNo,
                      filerec( DFile ).Recsize * RngNum );
end;

{*********************************************************************}
{* NetUnLock   : Unlocks locked records.                             *}
{* Input       : File, record number, number of records to be locked *}
{* Output      : TRUE if successful                                  *}
{* Global var. : NetError/W (error status after call)                *}
{*********************************************************************}

function NetUnlock( var DFile;
                        RecNo  : longint;
                        RngNum : longint ) : boolean;
begin
  NetUnLock := Locking( filerec( DFile).Handle, 1,
                        filerec( DFile ).Recsize * RecNo,
                        filerec( DFile ).Recsize * RngNum );
end;

{*********************************************************************}
{* Is_NetWriteOk : Enables file output.                              *}
{* Input         : File                                              *}
{* Output        : TRUE if output is enabled                         *}
{*********************************************************************}

function Is_NetWriteOk( var DFile ) : boolean;

begin
  with Filerec( DFile ) do
    Is_NetWriteOk := ( Mode = fmOutput ) or ( Mode = fmInOut );
end;

{*********************************************************************}
{* Is_NetReadOk : Enables file input.                                *}
{* Input        : File                                               *}
{* Output       : TRUE if output is enabled                          *}
{*********************************************************************}

function Is_NetReadOk( var DFile ) : boolean;

begin
  with Filerec( DFile ) do
    Is_NetReadOk := ( Mode = fmInput ) or ( Mode = fmInOut );
end;

{*********************************************************************}
{* Is_NetOpen  : Opens file.                                         *}
{* Input       : File                                                *}
{* Output      : TRUE if file is open                                *}
{*********************************************************************}

function Is_NetOpen( var DFile ) : boolean;

begin
  with Filerec( DFile ) do
    Is_Netopen := ( Mode = fmInput ) or ( Mode = fmOutput ) or
               ( Mode = fmInOut );
end;

{*********************************************************************}
{* NetWrite    : Writes to file.                                     *}
{* Input       : File, data                                          *}
{* Output      : None                                                *}
{* Info        : Output is only possible in Pascal procedures when   *}
{*               files have been opened in input-output mode.        *}
{*               Attention: No type checking performed here.         *}
{*********************************************************************}

procedure NetWrite( var DFile;
                    var FData );
begin
  WriteLn('REEPORT NETFILEP NetWrite');
end;

{*********************************************************************}
{* NetRead     : Reads from file.                                    *}
{* Input       : File, variable for accessing data                   *}
{* Output      : Data                                                *}
{* Info        : Output is only possible in Pascal procedures when   *}
{*               files have been opened in input-output mode.        *}
{*               Attention: No type checking performed here.         *}
{*********************************************************************}

procedure NetRead( var DFile;
                   var FData );
begin
  WriteLn('REEPORT NETFILEP NetRead');
end;

{*********************************************************************}
{* NetSeek     : Sets file pointer.                                  *}
{* Input       : File, record number                                 *}
{* Output      : None                                                *}
{* Info        : Output is only possible in Pascal procedures when   *}
{*               files have been opened in input-output mode.        *}
{*********************************************************************}

procedure NetSeek( var DFile;
                       RecNo : longint );
begin
  WriteLn('REEPORT NETFILEP NetSeek');
end;

begin
end.
