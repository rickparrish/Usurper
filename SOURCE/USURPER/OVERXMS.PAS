{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{ OVERXMS - Loads overlays in XMS.  Written by Wilbert van Leijen }

unit OverXMS;

{$O- }

interface

uses
  Overlay;

const
  ovrNoXMSDriver = -7;  { No XMS driver installed }
  ovrNoXMSMemory = -8;  { Insufficient XMS memory available }

procedure OvrInitXMS;

implementation

procedure OvrInitXMS; external;
{$L OVERXMS.OBJ }

end.  { OverXMS }
