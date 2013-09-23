{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{

Copyright 2007 Jakob Dangarden

 This file is part of Usurper.

    Usurper is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Usurper is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Usurper; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}




{$IFDEF MSDOS}
{$M 40000, 34000, 65000}
{$ENDIF}
{UTEST+}

program Usurper; {Door-Game by Jakob Dangarden
                  Written using - Borland Pascal 7.0 and DDplus 7.1
                   .. and miscellaneous routines .. }


uses
  {$IFDEF MSDOS}Overlay, {$ENDIF} Dos, {$IFDEF MSDOS}InitOver, {$ENDIF}
  DDplus, Init, Jakob, Maint, Cms, SortPl, VarGods, GodWorld, UserHunc, Gamec, Byebyec, Mail,
  Various, Various2, Rating, Relation, Relatio2, Post_To, Online, File_Io, {$IFDEF MSDOS}OverXms, {$ENDIF}
  Various3, News, Children, InitGods {$IFDEF FPC}, RPPort{$ENDIF};

 {bard : singing...love & battle hymns}
 {half-elves : hypnotize}
 {mutants : can't be affected by (bad) divine intervention}

     {record locking has so far been implemented in
      online file functions, player save, mail
     }

{ á = Beta sign}



 {suggestion: BE ABLE TO TEAM UP WITH A MONSTER!}
 {or even better : strangers offer their assistance}

 {Let the NPC girls court the players...send flowers etc}

      {NPC king should sack guards when new cheap guards are offering
      their service}

 { DDPlus new versions, remember this : }
 {  pause funktion at display of .asc+ .ans files}

 {monster b”r kunna togglas som SINGLAR. De dyker bara upp en † en}
 { l„gg in sl†ss tesammans i dngs funktion! kul! eller team fghts}

 {SKANDAL om det „r kungen som †ker dit f”r att m”rda eller ta droger!}

 {LOVE PARTY:}
 {beauty shop to enhance your looks}
 {snuck a love potion in Mirandellas drink}

 {turns to you with his hand extended}
 {Demonstration, (gatu)}
 {Dance on Your grave one day}

 {Spell competition}
 {DEMI-GOD}

 {f† brev fr†n sin morsa!! haha!}
 {toothless old fool}
 {top-boot : kragst”vel}
 {topknot : h†rknut p† hj„ssan  *mest kvinnor som anv„nder*}
 {a torrent of abuse = ett regn av okv„dinsord}
 {tormentors = pl†goandar}
 {torchlight procession = fackelt†g}
 {hey Jack!}
 {mannerly = v„luppfostrad}
 {lame-brain}
 {milksop = ynkrygg}
 {evil-doer = missd†dare}
 {blunderer = klantarsle}
 {displease = misshaga}
 {her eyes were full of mischief = hennes ”gon var fulla av rackartyg}
 {madcap = yrh„tta}
 {leprechaun = tomte, pyssling}
 {I wanna fuck you like an animal (indeed!)}
 {square-shouldered = bredaxlad}
 {sputter = spotta n„r man talar, fr„sande}
 {blood sucking society}
 {grubby little parasite = snuskig liten parasit}
 {hazardous to your health}
 {who are you trying to kid punk! haha!}
 {everybody is screwing everybody, indiscriminately!}
 {occupational hazard = yrkesrisk}
 {dont stop admiring your handywork = vila inte p† dina lagrar}
 {he's on a power trip = han ska ta h„mnd whatever}
 {for Paco its nothing left, nothing but the death collector!}
 {cartographer, draws maps....sell maps in the dungeons?!}
 {hobo,vagrant,tramp = luffare}
 {smoke him! = d”da honom...}
 {catapulte somebody in office}
 {shakedown = act of getting money by violence or threat}
 {shake like a leaf}
 {shaking his fist at you! = hytter med n„ven}
 {there is more to you than meets the eye}
 {the robbers all wore hoods to hide their faces}
 {hodded monks}
 {tradesman}
 {shopkeeper = aff„rsinnehavare}
 {the tides of war}
 {I don't speak your tongue}
 {sharp-tongued}
 {are you tongue-tied boy!}
 {Toghroul}
 {thick with dust}
 {through-paced = inpiskad}
 {she had her throat slashed}
 {stab wounds}
 {intragang warfare}
 {gypsy camp, slaughter them all, kids to!}
 {he tried to kiss her, but she fended him off}
 {what's your angel? (inte „ngel) }
 {domedags profet}
 {the old woman gave a loud cackle}
 {that old geezer over there}
 {poor old devil}
 {gr†tf„rdig = be ready to cry}
 {shut her up for good}
 {klumpfot = clump foot}
 {attack of cramp}
 {they pose a threat to me}
 {she has been cheating on you Jakob!}
 {Am I special to you Slash? (girl)}
 {patrified}
 {demi god}
 {take the ferry over to}
 {raghead}
 {aloud}
 {rebuke}
 {walk in the park}
 {hear him out}
 {Go and stay gone!}
 {rock-heart}
 {terror-gang}
 {this flagrant disregard for my orders}
 {five assorted trash = fem slyngh”gar}
 {fitting demise to this scoundrel}
 {enter the Morgue, where the bodies are laying in chalk}
 {"Take your medicine Boy!"}
 {who are you? His buttboy?}


      {"For we were young, and we knew that we could never die."
       Thomas Wolfe}

 {Damayanti = indisk prinsessa}

 {the gods can enter earth in a mortal disguise}

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
  {$O whores}{single combat man to man}
{$ENDIF}

const            {version number also in DDPLUS.PAS}
  uver     = '0.23f';
  uversion = 'Usurper ' + uver; {prog & version}
  ucomp    = '07/08/2013';      {compile date, mm/dd/yyyy}

  uctlfile = 'USURP.CTL'; {modem/fossil configuration file, used by DDPLUS}
  never    = False; {never leave the main loop}

  {test 7: overalyed: file_io, dorm}

     {marry the npc

     set out to marry routine takes too long (at maintenance)

     am I loved? respond to the love from a human? when human approaches
     relations: god-god / god-mortal

     something that should be fixed : challkng.pas => search for 'cheat'

     let the NPCs add comments to Write_to_Truth_file(player.name2,s) and
     chatfile:  write_to_inn_file(s,mess[1..5]);
     when an event takes place; like a marriage or divorce..this should be
     configurable of course


     {before releasing Usurper:
     ------------------------------

      *done! remove <"> CHEAT option from gamec.pas
      *done! remove MAZE.dat gorilla
      *done! remove cheat, ie "(pregnant) direct =>relation.pas=>give_birth"
      *done! labor_days constant (relation.pas => give_birth proc)

      *done! activate ramdrive in initovr.pas
      *make USURPER.EXE and .OVR read-only...with or without markers
      *convertera.pas!!

      *adoption in mail.pas
      *ritas child list looks bad..

      *global_ubeta=false + editor program beta variable
      *global_utest=false
      *done! compile JAKELOCK.PAS with only [STACK CHECKING] on
      *compile usurper project with compiler options. i/o checking off
      *remove bard songs from gamec.pas?

      *finish temple area
      *finish godworld
      *feeling_list in rating.pas should not use s15 in array
      }


var
  s:        string;

  username: s70;

  i:        longint;

  kill_file, exit_ordered, order_maint, dimmy, First, play: boolean;

  ch:       char;

  txt:      Text;

  Person:   OnlineRec; {Online record}

begin {* Main Program *}

      { Check that DATA\VERSION.DAT exists, and contains the same version number as this EXE }
  S := '';
  Write('   - Looking for ' + Global_VersionF + '...');
  if (F_Exists(Global_VersionF)) then
  begin
    WriteLn('FOUND');

    for i := 1 to 10 do
    begin
      Write('   - Trying to open file...');
      if (Open_TxtFile(TReset, Txt, Global_VersionF)) then
      begin
        WriteLn('SUCCESS');
        ReadLn_From_Text(Txt, S);
        Close_Text(Txt);
        WriteLn('   - Version from file: ' + S);
        break;
      end else
      begin
        WriteLn('FAILED');
        Delay2(500);
      end;
    end;
  end else
  begin
    WriteLn('NOT FOUND');
  end;
  Write('   - Expected version: ' + uver);
  if (S = uver) then
  begin
    WriteLn(' (MATCH)');
  end else
  begin
    WriteLn(' (DOES NOT MATCH)');
    WriteLn;
    WriteLn('   - Please run EDITOR to upgrade your version of Usurper');
    WriteLn('   - Aborting...');
    WriteLn;
    Halt;
  end;

{$IFDEF MSDOS}
  {Set Overlay FileMode}
  OvrFilemode := 64;
{$ENDIF}

  {Set Share}
  if Is_Share then
  begin
    filemode := 66;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
    global_ushare := True;
  end else
  begin
    global_ushare := False;
  end;
  global_lockmode := filemode;


 {make npcs pay for kidnapped children .. add this function please..

 {initializing global variables}
  Init_Usu;

  {Read Configuration Values and directories and vital DATA files}
  Read_Start_CfgValues;

  {Set UserName}
  player.name2 := '';
  player.name1 := '';

  {Setup Beta version indicators}
  global_ubeta := False;  {jakob beta version}
  global_utest := False; {jakob test version}

  global_checkcarrier := False;
  exit_ordered := False;

 {MAINTENANCE/SCORES/PACKMAIL/PACKMOAT/PACKUSERS/PACKNPCS/SENDMAIL
             /PACKRELATIONS/PACKCHILDREN}
  if param_hunt('?') or
    param_hunt('/?') or
    param_hunt('HELP') or
    param_hunt('/HELP') or
    param_hunt('/SCORES') or
    param_hunt('/DO_PACKMAIL') or
    param_hunt('/DO_PACKMOAT') or
    param_hunt('/DO_PACKUSERS') or
    param_hunt('/DO_PACKNPCS') or
    param_hunt('/DO_SENDMAIL') or
    param_hunt('/DO_PACKRELATIONS') or
    param_hunt('/DO_PACKCHILDREN') then
  begin

    {Set necessary parameters if Usurper was invoked with cmd line parameter}
    maxtime := 999;
    localcol := True;
    local := True;
    exit_ordered := True;

  end;

  {Check for command line parameters}
  if (param_hunt('?')) or
    (param_hunt('/?')) or
    (param_hunt('HELP')) or
    (param_hunt('/HELP')) then
  begin
    {display command line options}
    command_help;
  end;

  {taxes problem}

  if param_hunt('/SCORES') then
  begin
    {Update Scores files}
    wrl(10, '');
    wrl(10, '');
    wrl(10, 'Creating external Score Files for Usurper');
    {writing 'hall of fame' score files, if they have been defined}
    ratings_and_scores('C');
  end;

  if param_hunt('/DO_PACKMAIL') then
  begin
    {Pack Mail file}
    pack_mail;
  end;

  if param_hunt('/DO_PACKRELATIONS') then
  begin
    {Pack Relation file}
    pack_relations;
  end;

  {Pack Children data-file}
  if param_hunt('/DO_PACKCHILDREN') then
  begin
    pack_children;
  end;

  {Pack Moat file}
  if param_hunt('/DO_PACKMOAT') then
  begin
    pack_moat;
  end;

  {Pack User file}
  if param_hunt('/DO_PACKUSERS') then
  begin
    pack_users(PUsers);
  end;

  if param_hunt('/DO_PACKNPCS') then
  begin
    {Pack NPC file}
    pack_users(PNpcs);
  end;

  if param_hunt('/DO_SENDMAIL') then
  begin
    {Send mail to user}
    send_a_letter(True);
  end;

  if exit_ordered = True then
  begin
    normal_exit;
  end;

  {does maintfile exists and has it existed too long?}
  if f_exists(global_maintfile) = True then
  begin
    kill_file := False;
    d(15, 'Maintenance in progress!');
    s := file_stamp_info2(global_maintfile, 1);

    {how many days have passed}
    i := days_between(fix_date(todays_date), s);
    if i > 0 then
    begin
      d(15, commastr(i) + ' days have passed.');
      kill_file := True;
    end else
    begin
      {how many hours have passed}
      {debug info}
      i := hours_between(todays_time, file_stamp_info2(global_maintfile, 2));
      if i > 0 then
      begin
        d(15, commastr(i) + ' hours have passed.');
        kill_file := True;
      end else
      begin
        i := minutes_between(todays_time, file_stamp_info2(global_maintfile, 2));
        if i > 0 then
        begin
          d(15, commastr(i) + ' minutes have passed.');
          if i > 45 then
            kill_file := True;
        end;
      end;
    end;

    if kill_file then
    begin
      d(15, 'Cleaning up maintenance...');
      delete_file(global_maintfile);
    end;
    {pause;}

  end;
  {should statline (bottom of screen) be displayed?}
  statline := True;


  {Init DoorDriver}
  InitDoorDriver(uctlfile);

  {set username retrieved from ddplus variables}
  username := user_first_name + ' ' + user_last_name;

  {Setup New Exitproc}
  ExitSave := Exitproc;
  Exitproc := @ByeBye;

  {$IFNDEF FPC}
    {Setup New HeapHandler}
    HeapError := @HeapHandler;
  {$ENDIF}

  {Setup Beta version indicators}
  global_ubeta := False;  {jakob beta version}
  global_utest := False; {jakob test version}

  {Set node#}
  global_cnode := commastr(node_num);
  case length(global_cnode) of
    1: global_cnode := '00' + global_cnode;
    2: global_cnode := '0' + global_cnode;
  end;


  {Set DDPlus Program variable}
  progname := uversion;

  {Time has Expired Message (DDplus variable)}
  notime := '*** TIME HAS EXPIRED ***';

  {Determine Graphics}
  if (Graphics = 1) or (Graphics = 2) then
    global_ansi := False
  else global_ansi := True;

  {Set color}
  if global_ansi then
  begin
    set_color(config.textcolor, 0);
  end;

  {Init misc. vars}
  s := '';
  randomize;
  global_registered := False;
  i := 0;


  {Maintenance variables}
  order_maint := False;

  {Date file}
  if f_exists(global_datefile) = False then
  begin
    d(config.textcolor, 'Could not find the date file.');
    d(config.textcolor, 'Creating a new one...');

    if open_txtfile(trewrite, txt, global_datefile) then
    begin
      writeln_to_text(txt, todays_date);
      close_text(txt);
    end else
    begin
      unable_to_create(global_datefile, access_error);
    end;

    order_maint := True;

  end;

  { /HMAINT = unconditional maintenance }
  if param_hunt('/HMAINT') = True then
  begin
    exit_ordered := True;
    order_maint := True;
  end;

  if (param_hunt('/FMAINT') = True) and (order_maint = False) then
  begin
    exit_ordered := True;
    if open_txtfile(treset, txt, global_datefile) then
    begin
      readln_from_text(txt, s);
      close_text(txt);
    end else
    begin
      unable_to_access(global_datefile, access_error);
    end;

    if s <> todays_date then
    begin
      order_maint := True;
    end else
    begin
      d(14, 'No maintenance is needed (use /HMAINT to force it).');
      normal_exit;
    end;

  end;

  if (Config.AutoMaint = True) and (order_maint = False) then
  begin
    if open_txtfile(treset, txt, global_datefile) then
    begin
      readln_from_text(txt, s);
      close_text(txt);
    end else
    begin
      unable_to_access(global_datefile, access_error);
    end;

    if s <> todays_date then
    begin
      order_maint := True;
    end;
  end;

  if Order_Maint then
  begin
    if open_txtfile(trewrite, txt, global_datefile) then
    begin
      writeln_to_text(txt, todays_date);
      close_text(txt);
    end else
    begin
      unable_to_create(global_datefile, access_error);
    end;

    {kick out overdue players}
    kick_out_old_onliners;

    {check that nobody is online}
    dimmy := False;
    if f_exists(global_onfile) then
    begin
      for i := 1 to fs(FsOnline) do
      begin
        person.Name := '';
        load_onliner(fload, person, i);
        if (person.Name <> '') and (person.shadow = False) then
        begin
          dimmy := True;
          break;
        end;
      end; {for i:= .end.}
    end;

    if dimmy then
    begin
      wrl(12, 'Maintenance not able to run! Players are reported ONLINE.');
      wrl(12, '');
    end else
    if f_exists(global_maintfile) then
    begin
      wrl(12, 'Maintenance in progress (' + global_maintfile + ' exists).');
    end else
    begin
      maintenance;
    end;

  end;

  if exit_ordered = True then
  begin
    normal_exit;
  end;




  {Do we need to move the .doc files?}
  i := 1;
  First := True;
  repeat
    case i of
      1: s := 'WHATS.NEW';
      2: s := 'README!';
      3: s := 'USURPER.DOC';
      4: s := 'SYSOP.DOC';
      5: s := 'SUPPORT.DOC';
      6: s := 'BETATEAM.DOC';
      7: s := 'FUTURE.DOC';
      8: s := 'USRPBETA.TXT';
      9: s := 'BOARDRM.TXT';
      10: s := '-LEGAL-.TXT';
    end; {case .end.}

    if f_exists(s) then
    begin
      if f_exists(global_docsdir + s) then
        delete_file(global_docsdir + s);
      if First = True then
      begin
        First := False;
        d(config.textcolor, 'Updating Usurper files... please wait!');
      end;
      move_file(s, global_docsdir);
    end;
    Inc(i);
  until i > 10;

  {Need to move TEXT.DAT file?}
  s := global_textdataf;
  if f_exists(s) then
  begin
    if f_exists(global_datadir + s) then
      delete_file(global_datadir + s);
    d(config.textcolor, 'Updating Usurper files... please wait!');
    move_file(s, global_datadir);
  end;

  {let's check the carrier}
  global_checkcarrier := True;

  {display random intro ANSI/ASCII screen}
  if not config.fastplay then
  begin
    show_usurper_data('LOGO_' + long2str(random(7) + 1), True);
  end else
  begin
    crlf;
    crlf;
    pause;
  end;

  {check if program is registered}
  muffis;

  if (not global_registered) and (global_ubeta) then
  begin
    crlf;
    crlf;
    d(15, 'This release of Usurper is only intended for BETA tester');
    d(15, 'boards. This is NOT an offical release.');
    crlf;
    d(15, 'If You would like to become BETA tester for Usurper then');
    d(15, 'visit ' + global_webaddress);
    d(15, 'or read usurpbeta.txt for more information.');
    crlf;
    pause;
    normal_exit;
  end;

  {if this is a local player then we check for his screen size [rows]}
  if local then
  begin
    {this is also used in Jakob.pas => drop_dos}
    global_screenlines := screenrows - 1; {-1 because the statline takes up 1}
  end;

  {Main loop *START*}
  repeat

    if not config.fastplay then
    begin
      clearscreen;
      d(1, uversion + ',  Compiled ' + ucomp);
      d(1, 'JAS Software 2009,  Dark Deception Series IV *original version*');
      d(1, 'GNU GPL License 2007');

   {no need for this..since its open source
   if global_registered then d(9,'[Registered Copy]')
                        else d(9,'[Unregistered Copy]');
   }

      crlf;
      menu2('(P)lay          ');
      menu2('(I)nstructions    ');
      menu2('(R)ecords   ');
      menu('(G)ods');

      menu2('(L)ist Players  ');
      menu2('(T)eam Rankings   ');
      menu2('(H)eroes    ');
      menu('(C)hildren');

      menu2('(E)nter as God  ');
      menu2('(W)ho is online   ');
      menu2('(S)ettings  ');
      menu('(A)uthor info');

      menu2('(N)ews          ');
      menu2('(Y)esterdays News ');
      menu('(1) Monarchs News');

      menu2('(Q)uit to BBS   ');
      menu2('(M)essage         ');
      menu('(2) Holy News');

      sd(config.textcolor, ':');

  {
   meminfo;
  t  }

      {get user-input}
      ch := upcase(getchar);

    {in ['P','I','R','L','T','H','E','W','S','N','Y','Q','M'];
    }

    end else
    begin
      {config.fastplay, no intro .ans or .asc pic displayed}
      ch := 'P';
    end;

    {evaluate user-input}
    case ch of
      'G': begin {list of gods}
        clearscreen;
        list_gods(True);
        crlf;
        pause;
      end;
      'X': begin {jakob, test functions while developing the program}

        {crlf;
        crlf;
        if get_random_god(spinge) then begin
         d(4,'Found : '+spinge);
        end
        else begin
         d(12,'Unable to find a God.');
        end;
        pause;
        }

        {if global_utest then begin
         relations_editor;
        end;
         }

        {display relations
        clearscreen;
        x:=2;
        for i:=1 to fs(FsRelation) do begin
         load_relation(fload,rel,i);
         if rel.deleted=false then begin
          display_relation(rel.name1,rel);
          inc(x,2);
          if x>global_screenlines-2 then begin
           x:=0;
           pause;
          end;

         end;
        end;}

        {d(15,commastr(days_between('02-01-96','01-01-94')));
        pause;

       { d(2,BackUblue+uwhite+'White text on blue background'+BackUBlack+'-  White text on black background');
        d(2,BackUGreen+uwhite+'White text on green background'+BackUBlack+'-  White text on black background');
        d(2,BackUCyan+uwhite+'White text on cyan background'+BackUBlack+'-  White text on black background');
        d(2,BackURed+uwhite+'White text on red background'+BackUBlack+'-  White text on black background');
        d(2,BackUMagenta+uwhite+'White text on magenta background'+BackUBlack+'-  White text on black background');
        d(2,BackUBrown+uwhite+'White text on brown background'+BackUBlack+'-  White text on black background');
        d(2,BackULGray+uwhite+'White text on light-gray background'+BackUBlack+'-  White text on black background');

        d(2,BackUblue+ulmag+'Light-Magenta text on blue background'+BackUBlack+'-  White text on black background');
       }


        {global_ansi:=true;
        sd(config.textcolor,'PICTURE NAME:');
        s:=get_string(20);
        show_usurper_data(s,true);

        {become_god(username,1);
        }

      end;
      'C': begin {list of children}
        crlf;
        crlf;
        children_in_realm('', '', True, False);
        pause;
      end;
      '1': begin {List of Monarchs, log of comings and goings}
        d(11, 'List of Monarchs');
        crlf;
        if global_ansi then
          display_file(global_MonarchsANSI)
        else display_file(global_MonarchsASCI);
        crlf;
        pause;
      end;
      '2': begin {List of Gods, log of comings and goings}
        d(11, 'Immortal News');
        crlf;
        if global_ansi then
          display_file(global_GodsANSI)
        else display_file(global_GodsASCI);
        crlf;
        pause;
      end;
      'E': begin {enter as GOD}

        clearscreen;
        d(11, 'Enter as Immortal');
        crlf;
        crlf;


        {does user have a immortal character?}
        play := True;

        {check so god doesnt have a mortal player as well}
        if (config.bothImmortalsAndMortals = False) and (user_search(username, False) = True) then
        begin
          play := False;
          crlf;
          d(12, 'You are not allowed to enter since you already have a mortal character.');
          d(12, 'You are not allowed to have both!');
          pause;
        end;


        if (play) and (god_search(username) = True) then
        begin

          pause;

          if config.log_divine_entrance then
          begin

            {put an entry in the news}
            newsy(True,
              'Heaven',
              ' The majestic God ' + ugodc + god.Name + config.textcol1 + ' made a mighty entrance!',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

          end;

          {enter god world}
          god_world;

        end else
        begin

          if global_utest then
          begin
            d(15, 'You have no recorded Immortals.');

            d(15, 'Entering Usurper Test Mode');

            crlf;

            if confirm('Create a God', 'N') = True then
            begin

           {
           jakob, development, used when testing God stuff
           }

              player.sex := 1;
              player.dark := 550;
              player.chiv := 1500;

              become_god(username, player.sex);

              god_world;

            end;

          end {global_utest -end-} else
          begin
            if play then
            begin
              d(12, 'You have no Divine Character!');
              d(12, 'Enter the Mortal world and EARN your place in heaven!');
              pause;
            end;
          end;

        end;

      end;

      'M': begin {Send message to online player}

        d(11, 'Message');
        crlf;
        if confirm('Send Anonymously', 'N') = True then
        begin
          onliner.Name := '*The Outside*';
        end else
        begin
          onliner.Name := username;
        end;

        online_message;
        onliner.Name := '';
        crlf;
        pause;

      end;
      'S': begin {display Game Settings, various3.pas}

        if config.viewgamesettings then
        begin
          display_game_settings(uversion);
        end else
        begin
          crlf;
          crlf;
          d(12, 'The Sysop has decided that players may not view the Game Settings.');
          pause;
        end;

      end;
      'W': begin {Who is playing}

        crlf;
        who_is_on(True, False);
        pause;

      end;
      'R': begin {Team records}

        crlf;
        display_file(global_teamrectxt);
        crlf;
        pause;

      end;
      'N': begin {News-Paper}

        d(11, 'News');
        crlf;
        if global_ansi then
          display_file(global_nwfileans)
        else display_file(global_nwfileasc);
        crlf;
        pause;

      end;
      'Y': begin {Yesterday news}

        d(11, 'Yesterdays News');
        crlf;
        if global_ansi then
          display_file(global_ynwfileans)
        else display_file(global_ynwfileasc);
        crlf;
        pause;

      end;
      'H': begin {Hero list, players who completed the game}

        d(11, 'Heroes');
        crlf;
        display_file(global_famefile);
        crlf;
        pause;

      end;
      'T': begin {List of Teams}

        crlf;
        if global_ansi then
          s := cfg_string(72)
        else s := cfg_string(73);
        display_file(s);
        crlf;
        pause;

      end;
      'L': begin {List of characters}

        crlf;
        sd(15, 'Sorting..');
        {if global_ansi then s:=cfg_string(70)  {score file ANSI}
        {else s:=cfg_string(71); {score file ASCII}
       { display_file(s);
       }
        sort_players(False);

      end;
      'I': begin {Instructions}

        d(15, 'Instructions');
        crlf;
        display_file(global_docsdir + 'USURPER.DOC');
        pause;

      end;
      'P': begin {Play The Game!}

        d(11, 'Play');

        {kick out overdue players}
        kick_out_old_onliners;


        if global_ubeta then
        begin
          clearscreen;
          crlf;
          crlf;
          d(2, cool_string(53, '=', '-', 5, 10));
          d(13, 'ALERT! This is an early test-version of ' + uversion + '.');
          d(13, 'Report any errors and bugs via e-mail to : jakob@dangarden.com');
          d(2, cool_string(53, '=', '-', 5, 10));
          pause;
          crlf;
        end;

        {check if game is registered}
        muffis;

        play := True;

        {check if player already have Immortals and the config disallows it}
        if (config.bothImmortalsAndMortals = False) and (player_has_a_god(username) = True) then
        begin
          d(12, 'You are NOT allowed to enter since you have Immortal characters active.');
          d(12, 'You are NOT allowed to have BOTH!');
          pause;
          play := False;
        end;

        if (config.simulnode = False) and (play = True) then
        begin

          {check if user is alredy online}
          if f_exists(global_onfile) = True then
          begin

            for i := 1 to fs(FsOnline) do
            begin

              load_onliner(fload, person, i);

              if (upcasestr(person.realname) = upcasestr(username)) and
                (person.realname <> '') then
              begin
                crlf;
                d(15, 'Playing on more than 1 node simultaneously is not allowed.');
                d(15, 'Your character is logged as being online');
                crlf;
                sd(11, 'Current status :');
                sd(12, '');
                d(config.textcolor, person.doing);
                crlf;
                pause;
                play := False;
                break;
              end;
            end; {for i:= .end.}
          end;
        end;


        if play = True then
        begin
          {checking if maintenance is running on another node}
          if f_exists(global_maintfile) then
          begin
                     {read maint.flg data}
            s := ''; {node}
            if open_txtfile(treset, txt, global_maintfile) then
            begin
              readln_from_text(txt, s); {node that started the session}
              Close(txt);
            end;

            repeat
              crlf;
              crlf;
              d(15, 'Maintenance is running. ' + ulcyan + s + uwhite + ' (file:' + global_maintfile + ' exists).');
              d(15, 'Maintenance started ' + file_stamp_info2(global_maintfile, 3));
              menu('(T)ry again');
              menu('(A)bort');
              menu('(B)ye (exit program)');
              sd(config.textcolor, ':');

              {get user-input}
              ch := getchar;

              {evaluate user-input}
              case ch of
                'T': begin {try again}
                  if f_exists(global_maintfile) = False then
                  begin
                    ch := 'B';
                  end else
                  begin
                    crlf;
                    crlf;
                    d(12, 'Sorry! The program is still busy.');
                    ch := ' ';
                  end;
                end;
                'B': begin {goodbye!}
                  d(config.textcolor, 'Bye bye!');
                  normal_exit;
                end;

              end; {case .end.}

            until ch in ['A', 'B'];
            crlf;
          end else
          begin
            ch := 'B';
          end;


          if ch = 'B' then
          begin

            {Initializing the Monsters}
            for i := 1 to global_maxmon do
            begin
              new(monster[i]);
            end; {for i:= .end.}

            global_monsterinit := True;

            if user_search(username, True) then
            begin
              {observe that there is an additional game entrance above}
              game;
              normal_exit;
            end;

          end;

        end;

      end;
      'A': begin {Author information}

        crlf;
        crlf;
        d(config.textcolor, 'Program Information');
        crlf;
        d(config.textcolor, 'Programmers:');
        d(14, '                   Original author : Jakob Dangarden jakob@dangarden.com');
        d(14, '            Win32/Linux/OS/2 Ports : Rick Parrish usurper@rickparrish.ca');
        d(14, '   Post 0.20e Fixes & Improvements : Dan dan1982code@hotmail.ca');
        crlf;
        {d(config.textcolor,'The Usurper project comprises approximately 180,000 lines of source code.');
        crlf;}
        d(config.textcolor, 'Web:');
        d(14, '   ' + global_webaddress);
        crlf;
        d(config.textcolor, 'Forum:');
        d(14, '   http://www.usurper.dangarden.com (currently unmoderated)');
        crlf;
        pause;
        crlf;

      end;
      'Q': begin {Quit}
        d(11, 'Quit');
        crlf;
        if confirm('Really QUIT', 'Y') then
        begin
          normal_exit;
        end;
      end;

    end;       {case .end.}

  until never; {Main loop *END*}

end.{* Main Program END *}
