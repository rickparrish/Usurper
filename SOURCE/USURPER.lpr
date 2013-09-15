{$I DEFINES.INC}
{$IFDEF MSDOS}{$M 40000, 34000, 65000}{$ENDIF}
program USURPER;

uses
  UsurperU;

{$IFDEF MSDOS}
  {$O ddovr}
  {$O ddovr2}
  {$O alchemi}
  {$O ansicolr}
  {$O armshop}
  {$O autogang}
  {$O bank}
  {$O beerst}
  {$O bobs}
  {$O bounty}
  {---$O byebyec}
  {$O brawlc}
  {$O challeng}
  {$O challkng}
  {$O chestlo}
  {$O children}
  {$O cast}
  {$O castle}
  {$O cms}
  {$O comp_use}
  {$O compwar}
  {$O crtmage}
  {$O darkc}
  {$O ddplus}
  {$O disptext}
  {$O dorm}
  {$O drinking}
  {$O drugs}
  {$O dungeonc}
  {$O dungevc}
  {$O dungev2}
  {$O file_io}
  {$O file_io2}
  {$O gamec}
  {$O gangwars}
  {$O gigoloc}
  {$O godworld}
  {$O goodc}
  {$O groggo}
  {$O gym}
  {$O hagglec}
  {$O healerc}
  {$O home}
  {$O icecaves}
  {$O init}
  {$O innc}
  {$O invent}
  {$O jakob}
  {$O kmaint}
  {$O levmast}
  {$O lovers}
  {$O magic}
  {$O mail}
  {$O maint}
  {$O market}
  {$O murder}
  {$O news}
  {$O npc_chec}
  {$O npcmaint}
  {$O onduel}
  {$O online}
  {$O ontrade}
  {$O orb}
  {$O plcomp}
  {$O plmarket}
  {$O plvsmon}
  {$O plvsplc}
  {$O plvspl2}
  {$O plyquest}
  {$O post_to}
  {$O prisonc}
  {$O prisonc1}
  {$O prisonf}
  {$O recruite}
  {$O relation}
  {$O rating}
  {$O resetg}
  {$O revival}
  {$O rquests}
  {$O senditem}
  {$O shady}
  {$O sortpl}
  {$O sortteam}
  {$O spellsu}
  {$O statusc}
  {$O steroids}
  {$O suicid}
  {$O supremec}
  {$O swapeq}
  {$O tcorner}
  {$O teamrec}
  {$O uman}
  {$O userhunc}
  {$O various}
  {$O various2}
  {$O various3}
  {$O wantedsc}
  {$O weapshop}
  {$O whores}        {single combat man to man}
{$ENDIF}

begin
  UsurperMain;
end.


