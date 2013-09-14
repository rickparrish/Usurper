{$I DEFINES.INC}
Unit TxtShare;

{ This UNIT implements a TEXT file device driver to access TEXT files with a }
{ user specified network access mode (see DOS Technical Reference for DOS }
{ function 3Dh).  This can be accomplished for non-TEXT files by setting the }
{ standard global variable "FileMode" (part of the System unit) to the desired
}
{ value, and then calling the appropriate open function. This is not supported
}
{ for TEXT files in Turbo Pascal v4.0. }

{ To open a Text file with a user specified access mode, place a call to the }
{ procedure AssignText to associate a filename with the text file variable. }
{ Next, set the standard global variable FileMode with the desired DOS access }
{ mode value.  RESET, REWRITE, and APPEND will now use the access mode }
{ assigned to the FileMode variable when opening the file. }

{ By default, no EOF marker is written to text files that have been "assigned"
}
{ using this unit's routines.  If you require a ^Z at the end of any file }
{ opened for output, set the global variable WriteTextEofChar to TRUE before }
{ closing the file. }

Interface

Uses Dos;

Var
   WriteTextEofChar : Boolean;

Procedure AssignText(Var F : Text; const FileName : String);

Implementation

{$R-,S-}

Var
   ReadText_Addr  : Pointer;
   WriteText_Addr : Pointer;
   SeekText_Addr  : Pointer;
   DoNothing_Addr : Pointer;
   CloseText_Addr : Pointer;

Function ReadText(Var F : TextRec) : Word;
Begin
   Inline(
     $1E/                   {       push     ds          ;Save data segment
value}
     $C5/$76/$06/           {       lds      si,[bp+6]   ;Address the file var
structure}
     $AD/                   {       lodsw                ;Pick up file handle}
     $89/$C3/               {       mov      bx,ax       ; ... and store in bx}
     $46/                   {       inc      si          ;Skip past the Mode
field}
     $46/                   {       inc      si          ; ... and address the
BufSize field}
     $AD/                   {       lodsw                ;Pick up BufSize (# of
bytes to read)}
     $89/$C1/               {       mov      cx,ax       ; ... and store in cx}
     $81/$C6/$06/$00/       {       add      si,6        ;Address the BufPtr
field}
     $AD/                   {       lodsw                ;Pick up Offset part
of the pointer}
     $89/$C2/               {       mov      dx,ax       ; ... and store in dx}
     $AD/                   {       lodsw                ;Pick up Segment part
of the pointer}
     $8E/$D8/               {       mov      ds,ax       ; ... and store in ds}
     $B4/$3F/               {       mov      ah,$3F      ;DOS Read a
File/Device function}
     $CD/$21/               {       int      $21         ;Call DOS}
     $72/$0F/               {       jc       Error       ;Error if Carry Flag
set}
     $50/                   {       push     ax          ;Save # of bytes
actually read}
     $31/$C0/               {       xor      ax,ax       ;Clear ax to zero}
     $C4/$7E/$06/           {       les      di,[bp+6]   ;Address the file var
structure}
     $81/$C7/$08/$00/       {       add      di,8        ;Address the BufPos
field}
     $AB/                   {       stosw                ;Store 0 in the BufPos
field}
     $58/                   {       pop      ax          ;Retrieve bytes
actually read}
     $AB/                   {       stosw                ; ... and store in
BufEnd field}
     $31/$C0/               {       xor      ax,ax       ;Return 0 ==> no
errors}
     $1F/                   {Error: pop      ds          ;Restore ds value}
     $89/$46/$FE);          {       mov      [bp-2],ax   ;Store returned value}
End {ReadText};

Function WriteText(Var F : TextRec) : Word;
Begin
   Inline(
     $1E/                   {       push     ds          ;Save value of data
seg register}
     $C5/$76/$06/           {       lds      si,[bp+6]   ;DS:SI points to
TextRec structure}
     $AD/                   {       lodsw                ;Pick up file handle}
     $89/$C3/               {       mov      bx,ax       ; ... and store in BX}
     $81/$C6/$06/$00/       {       add      si,6        ;DS:SI points to
BufPos field}
     $AD/                   {       lodsw                ;Pick up # of bytes to
write}
     $89/$C1/               {       mov      cx,ax       ; ... and store in CX}
     $46/                   {       inc      si}
     $46/                   {       inc      si          ;DS:SI points to
BufPtr field}
     $AD/                   {       lodsw                ;Pick up offset part
of buffer addr.}
     $89/$C2/               {       mov      dx,ax       ; ... and store in DX}
     $AD/                   {       lodsw                ;Pick up segment part
of buffer addr.}
     $8E/$D8/               {       mov      ds,ax       ; ... and store in DS}
     $B4/$40/               {       mov      ah,$40      ;DOS write file/device
function}
     $CD/$21/               {       int      $21         ;Call DOS}
     $72/$0B/               {       jc       Error       ;Error if Carry Flag
is set on return}
     $31/$C0/               {       xor      ax,ax       ;Clear AX to zero}
     $C4/$7E/$06/           {       les      di,[bp+6]   ;ES:DI points to
TextRec structure}
     $81/$C7/$08/$00/       {       add      di,8        ;ES:DI points to
BufPos field}
     $AB/                   {       stosw                ;Reset BufPos to zero}
     $AB/                   {       stosw                ;Reset BufEnd to zero}
     $1F/                   {Error: pop      ds          ;Restore data seg
register}
     $89/$46/$FE);          {       mov      [bp-2],ax   ;Store function
result}
End {WriteText};

Function DoNothing(Var F : TextRec) : Word;
Begin
   Inline(
     $C7/$46/$FE/$00/$00);    {        mov    word [bp-2],0}
End {DoNothing};

Function SeekEofText(Var F : TextRec) : Word;
Begin
   Inline(
     $1E/                     {        push     ds                   ;Save Data
Seg register}
     $C4/$7E/$06/             {        les      di,[bp+6]            ;ES:DI
points to the TextRec}
     $26/$8B/$1D/             {    es: mov word bx,[di]              ;File
handle into BX}
     $31/$C9/                 {        xor      cx,cx                ;CX:DX =
Offset for Seek function}
     $89/$CA/                 {        mov      dx,cx                ;With AL=2
and CX:DX=0, will seek eof}
     $B8/$02/$42/             {        mov      ax,$4202}
     $CD/$21/                 {        int      $21                  ;DX:AX
should now contain filesize}
     $72/$7B/                 {        jc       Error}
     $2D/$80/$00/             {        sub      ax,128
;Reposition to read the last 128 bytes of}
     $81/$DA/$00/$00/         {        sbb      dx,0                 ;the file
(or as much as we can)}
     $79/$04/                 {        jns      NonNeg               ;If less
than 128 chars in file}
     $31/$C0/                 {        xor      ax,ax                ;  then
just read from beginning}
     $89/$C2/                 {        mov      dx,ax}
     $89/$D1/                 {NonNeg: mov      cx,dx                ;Set up
for Seek function}
     $89/$C2/                 {        mov      dx,ax                ;CX:DX =
Absolute position to seek}
     $26/$89/$55/$20/         {    es: mov word [di+32],dx           ;Save in
UserData field for later}
     $26/$89/$4D/$22/         {    es: mov word [di+34],cx}
     $26/$8B/$1D/             {    es: mov word bx,[di]              ;File
handle in BX}
     $B8/$00/$42/             {        mov      ax,$4200             ;Dos seek
(absolute) function}
     $CD/$21/                 {        int      $21}
     $72/$58/                 {        jc       Error}
     $06/                     {        push     es                   ;Set up
for call to read by pushing}
     $57/                     {        push     di                   ;TextRec
address onto stack}
     $FF/$1E/>READTEXT_ADDR/  {        call far [>ReadText_Addr]     ;Read the
file}
     $09/$C0/                 {        or       ax,ax                ;Any
errors?}
     $75/$4E/                 {        jnz      Error}
     $C5/$76/$06/             {        lds      si,[bp+6]            ;Use DS:SI
as TextRec ptr}
     $8B/$4C/$0A/             {        mov word cx,[si+10]           ;CX = #
bytes read}
     $E3/$44/                 {        jcxz     Done                 ;If 0
bytes read, then we're done}
     $8B/$44/$0C/             {        mov word ax,[si+12]           ;BufPtr
offset}
     $89/$C7/                 {        mov      di,ax                ;ES:DI
will point at the buffer of data}
     $4F/                     {        dec      di                   ;  that
was just read in}
     $01/$CF/                 {        add      di,cx}
     $8B/$44/$0E/             {        mov word ax,[si+14]}
     $8E/$C0/                 {        mov      es,ax}
     $B0/$1A/                 {        mov      al,$1A}
     $FD/                     {        std}
     $F2/$AE/                 {  repnz scasb                         ;Search
buffer for a ^Z}
     $FC/                     {        cld}
     $75/$2F/                 {        jnz      Done                 ;If no ^Z
found, then we're done}
     $C4/$7E/$06/             {        les      di,[bp+6]            ;Back to
using ES:DI for TextRec}
     $1F/                     {        pop      ds                   ;Point DS
back at global variable segment}
     $1E/                     {        push     ds                   ;But push
back for final pop}
     $89/$C8/                 {        mov      ax,cx                ;ax=offset
in buffer at which ^Z was found}
     $26/$8B/$55/$20/         {    es: mov word dx,[di+32]           ;Retrieve
saved file ptr pos.}
     $26/$8B/$4D/$22/         {    es: mov word cx,[di+34]}
     $01/$C2/                 {        add      dx,ax                ;Add in
offset of ^Z}
     $81/$D1/$00/$00/         {        adc      cx,0}
     $26/$8B/$1D/             {    es: mov word bx,[di]              ;file
handle back in BX}
     $B8/$00/$42/             {        mov      ax,$4200             ;Again
with the Seek function}
     $CD/$21/                 {        int      $21
;Reposition file pointer to ^Z char}
     $72/$12/                 {        jc       Error}
     $26/$C7/$44/$08/$00/$00/ {    es: mov word [si+8],0             ;BufPos=0
(write 0 bytes to truncate ...}
     $06/                     {        push     es                   ; ... the
file at the ^Z)}
     $57/                     {        push     di                   ;Setup for
call to write routine}
     $FF/$1E/>WRITETEXT_ADDR/ {        call far [>WriteText_Addr]}
     $09/$C0/                 {        or       ax,ax                ;Any
errors}
     $75/$02/                 {        jnz      Error}
     $31/$C0/                 {Done:   xor      ax,ax                ;Return 0
if no errors}
     $1F/                     {Error:  pop      ds}
     $89/$46/$FE);            {        mov      [bp-2],ax}
End {SeekEofText};

Function CloseText(Var F : TextRec) : Word;
Begin
   Inline(
     $1E/                           {         push     ds
;Must preserve DS for return}
     $C4/$7E/$06/                   {         les      di,[bp+6]
;ES:DI is our ptr to the TextRec}
     $26/$8B/$44/$02/               {     es: mov      ax,[si+2]
;Magic Number into AX}
     $3D/>FMOUTPUT/                 {         cmp word ax,>fmOutput
;File opened with Rewrite or Append?}
     $75/$2D/                       {         jnz      SkipEof
;No, skip ^Z stuff}
     $80/$3E/>WRITETEXTEOFCHAR/$01/ {         cmp byte [>WriteTextEofChar],1
;Use ^Z to mark end of file?}
     $75/$26/                       {         jnz      SkipEof
;No, skip ^Z stuff}
     $26/$8B/$45/$0C/               {     es: mov word ax,[di+12]
;Get address of output buffer}
     $26/$8B/$5D/$0E/               {     es: mov word bx,[di+14]}
     $89/$C7/                       {         mov      di,ax}
     $8E/$C3/                       {         mov      es,bx
;ES:DI points to buffer now}
     $B8/$1A/$00/                   {         mov      ax,$1A}
     $AB/                           {         stosw
;Put a ^Z into the buffer}
     $C4/$7E/$06/                   {         les      di,[bp+6]
;Point ES:DI back at the TextRec}
     $26/$C7/$45/$08/$01/$00/       {     es: mov word [di+8],1
;Set BufPos to show 1 char to write}
     $06/                           {         push     es
;Put TextRec Address onto stack}
     $57/                           {         push     di}
     $FF/$1E/>WRITETEXT_ADDR/       {         call far [>WriteText_Addr]
;Call Write routine to write the ^Z}
     $09/$C0/                       {         or       ax,ax
;Any problems with the write?}
     $75/$1D/                       {         jnz      Error
;Yes, exit with error code in AX}
     $C4/$7E/$06/                   {         les      di,[bp+6]
;ES:DI probably trashed in call}
                                    {SkipEof:}
     $26/$8B/$1D/                   {     es: mov      bx,[di]
;File handle in BX}
     $B8/$00/$3E/                   {         mov      ax,$3E00
;Dos Close function}
     $CD/$21/                       {         int      $21
;Close the file}
     $72/$10/                       {         jc       Error
;If error, exit with code in AX}
     $31/$C0/                       {         xor      ax,ax}
     $26/$89/$45/$08/               {     es: mov word [di+8],ax
;Stuff zeros in BufPos and BufEnd}
     $26/$89/$45/$0A/               {     es: mov word [di+10],ax}
     $26/$C7/$45/$02/>FMCLOSED/     {     es: mov word [di+2],>fmClosed
;Reset the magic number}
     $1F/                           {Error:   pop      ds}
     $89/$46/$FE);                  {         mov      [bp-2],ax
;Store function result}
End {CloseText};

Function OpenText(Var F : TextRec) : Word;
Begin
   Inline(
     $1E/                       {         push      ds                  ;Save
DS register}
     $C4/$7E/$06/               {         les       di,[bp+6]           ;ES:DI
is pointer to the TextRec structure}
     $B4/$3D/                   {Start:   mov       ah,$3D              ;DOS
open a file/device function}
     $26/$81/$7D/$02/>FMOUTPUT/ {     es: cmp word  [di+2],>fmOutput    ;Open
for Rewrite?}
     $75/$02/                   {         jnz       OpenIt              ;No,
skip next line}
     $B4/$3C/                   {         mov       ah,$3C              ;DOS
create new/truncate old file}
     $A0/>FILEMODE/             {OpenIt:  mov       al,[>FileMode]      ;Put
user specified access mode in AL}
     $B9/$00/$00/               {         mov       cx,0                ;File
attribute (nothing special) in CX}
     $8C/$C3/                   {         mov       bx,es}
     $8E/$DB/                   {         mov       ds,bx}
     $89/$FA/                   {         mov       dx,di}
     $81/$C2/$30/$00/           {         add       dx,48               ;DS:DX
points to asciiz filename}
     $CD/$21/                   {         int       $21                 ;Open
the file}
     $1F/                       {         pop       ds
;Restore DS to segment with global vars}
     $1E/                       {         push      ds                  ; ...
and save back on stack for later}
     $73/$15/                   {         jnc       OpenOk              ;If no
errors, continue}
     $3D/$02/$00/               {         cmp       ax,2                ;File
not found?}
     $75/$69/                   {         jnz       Error               ;No,
exit with error code in ax}
     $26/$81/$7D/$02/>FMINOUT/  {     es: cmp word  [di+2],>fmInOut     ;Opened
for Append?}
     $75/$61/                   {         jnz       Error               ;No,
exit with error code in ax}
     $26/$C7/$45/$02/>FMOUTPUT/ {     es: mov word  [di+2],>fmOutput    ;No
existing file to append ...}
     $EB/$C9/                   {         jmp short Start               ; ...
so try again with Rewrite}
     $AB/                       {OpenOk:  stosw                         ;Store
file handle (in AX) into TextRec}
     $BE/>CLOSETEXT_ADDR/       {         mov       si,>CloseText_Addr  ;DS:SI
points at addr. of CloseText fn.}
     $81/$C7/$1A/$00/           {         add       di,26               ;ES:DI
points to CloseFunc field}
     $B9/$02/$00/               {         mov       cx,2                ;Double
word address to move}
     $F2/$A5/                   {     rep movsw                         ;Store
address into CloseFunc field}
     $C4/$7E/$06/               {         les       di,[bp+6]           ;ES:DI
back to pointing at TextRec}
     $26/$81/$7D/$02/>FMINOUT/  {     es: cmp word  [di+2],>fmInOut     ;Opened
with Append?}
     $75/$13/                   {         jnz       NoSeek              ;No,
skip the search for ^Z}
     $06/                       {         push      es                  ;Set up
stack for call to SeekEofText}
     $57/                       {         push      di                  ;Addr
of TextRec goes on the stack}
     $FF/$1E/>SEEKTEXT_ADDR/    {         call far  [>SeekText_Addr]    ;Get
rid of any ^Z at end of file}
     $09/$C0/                   {         or        ax,ax               ;Any
errors?}
     $75/$37/                   {         jnz       Error               ;Yes,
exit with error code in AX}
     $C4/$7E/$06/               {         les       di,[bp+6]
;Restore ptr to TextRec trashed in call}
     $26/$C7/$45/$02/>FMOUTPUT/ {     es: mov word  [di+2],>fmOutput    ;Reset
TextRec mode to show output only}
                                {NoSeek:}
     $26/$C7/$45/$08/$00/$00/   {     es: mov word  [di+8],0            ;Set
BufPos to 0}
     $26/$C7/$45/$0A/$00/$00/   {     es: mov word  [di+10],0           ;Set
BufEnd to 0}
     $26/$81/$7D/$02/>FMINPUT/  {     es: cmp word  [di+2],>fmInput     ;Opened
with reset?}
     $74/$05/                   {         jz        InFunc              ;Yes,
set pointers accordingly}
     $BE/>WRITETEXT_ADDR/       {         mov       si,>WriteText_Addr  ;DS:SI
--> Address of WriteText func.}
     $EB/$03/                   {         jmp short SetFunc             ;Go set
TextRec function pointers}
     $BE/>READTEXT_ADDR/        {InFunc:  mov       si,>ReadText_Addr   ;DS:SI
--> Address of ReadText func.}
     $81/$C7/$14/$00/           {SetFunc: add       di,20               ;ES:DI
--> InOutFunc field}
     $B9/$02/$00/               {         mov       cx,2                ;Moving
a double word}
     $51/                       {         push      cx                  ;Save
this count for later}
     $F2/$A5/                   {     rep movsw                         ;Store
address of I/O routine}
     $BE/>DONOTHING_ADDR/       {         mov       si,>DoNothing_Addr  ;DS:SI
--> Address of DoNothing func.}
     $59/                       {         pop       cx                  ;ES:DI
--> FlushFunc field - move 2 words}
     $F2/$A5/                   {     rep movsw                         ;Store
address of flush routine}
     $31/$C0/                   {         xor       ax,ax               ;No
errors, return a 0 to caller}
     $1F/                       {Error:   pop       ds
;Restore DS register}
     $89/$46/$FE);              {         mov       [bp-2],ax           ;Store
function result}
End {OpenText};

Procedure AssignText(Var F : Text; const FileName : String);
Var
   I : Integer;
Begin
   With TextRec(F) do begin               { Initialize textrec record         }
      Handle   := $FFFF;                  { Set file handle to junk           }
      Mode     := fmClosed;               { Indicate the file is not yet open }
      BufSize  := SizeOf(Buffer);         { Set size of default buffer (128)  }
      BufPtr   := @Buffer;                { Set up pointer to default buffer  }
      OpenFunc := @OpenText;              { Set up pointer to OPEN function   }
      For I := 1 to Length(FileName) do   { Set up asciiz filename            }
         Name[I-1] := FileName[I];
      Name[Length(FileName)] := Chr(0);
   End {with};
End {AssignText};

Begin
   { Initialize global variable to suppress writing ^Z at the end of any     }
   { text file opened with Append or Rewrite.                                }
   WriteTextEofChar := FALSE;

   { Initialize internally used Address variables (pointers)                 }
   ReadText_Addr    := Addr(ReadText);
   WriteText_Addr   := Addr(WriteText);
   SeekText_Addr    := Addr(SeekEofText);
   DoNothing_Addr   := Addr(DoNothing);
   CloseText_Addr   := Addr(CloseText);
End {Unit TxtShare}.

{$F-}

{end}
