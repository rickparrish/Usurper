{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{ OVERXMS - Loads overlays in XMS.  Written by Wilbert van Leijen }

Unit OverXMS;

{$O- }

Interface
uses Overlay;

Const
  ovrNoXMSDriver = -7;  { No XMS driver installed }
  ovrNoXMSMemory = -8;  { Insufficient XMS memory available }

Procedure OvrInitXMS;

Implementation

Procedure OvrInitXMS; External;
{$L OVERXMS.OBJ }

end.  { OverXMS }
