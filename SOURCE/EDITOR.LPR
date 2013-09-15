{$I DEFINES.INC}
program EDITOR;

uses
  EditorU;

{$IFDEF MSDOS}
  {---$O Addit}
  {---$O CfgHelp}
  {---$O helpfile}
  {$O CfgVal}
  {$O CfgDef}
  {$O Extra}
  {$O Edweap01}
  {$O Edweap}
  {$O Edweap2}
  {$O Edweap3}
  {$O Edmonst}
  {$O edface}          {*biker game*}
  {$O eddrink}         {*grave.diggers* *vultures* *slaves* *black hawks*}
  {$O edrings}         {undertaker,}
  {$O edshield}        {zonk,septic,death,buzzard,69,ferret,stinky,}
  {$O edbody}          {bad max,scrag,hooks,toad,pinball,stone,midnight,}
  {$O edhead}          {vanessa,stinkfinger,ferret}
  {$O edneck}
  {$O edarms}
  {$O edhands}
  {$O edwaist}
  {$O edfeets}
  {$O edabody}
  {$O edlegs}
  {$O edfood}
  {$O guardres}
  {$O levres}
  {$O mon_arm}
  {$O Npc}
  {$O resettn}
{$ENDIF}

begin
  EditorMain;
end.

