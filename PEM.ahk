#SingleInstance off
	;The variable 1 contains the argument
file=%1%
ifequal, file,
	goto nofile
ifnotexist, %file%
	{ msgbox,48,Error 404, The file:`n`n%file%`n`n either does not exist`, or is not a valid argument.
	  ExitApp
	}
Setworkingdir, %A_ScriptDir%
Splitpath, file,,,ext
	;Read from file for program
Iniread, program, pem.ini, key, %ext%
ifequal, program, error
	errorconsole("Program not set for extension","There is currently no program set for `n`n." ext "`n", file)
iniread, drv, pem.ini, config, drive
	;Autodetects if PEM is read
ifequal, drv, PEM
	Splitpath, A_scriptDir,,,,,drv
program=%drv%\%program%
	;Checks one last time if the program exists
ifnotexist, %program%
	errorconsole("Program not found", "The program:`n`n" program "`n`n does not seem to exist.", file)
full=`"%program%`" `"%file%`"
Splitpath, program,,dir
	;File is passed as paramater, with working directory
run, %full%,%dir%
exitapp
	

	;Just a universal error message.
errorconsole(Thing1, Thing2, file)
{ ;gui 1: +owndialogs
  Msgbox,51,%Thing1%,%Thing2%`n-----------------------`nDo you want to continue?`nYes = Open the file with the default system program`nNo = Open the PEM editor`nCancel = Do nothing	
ifmsgbox,Yes
	run, %file%
ifmsgbox, No
	run, %A_Scriptfullpath%
exitapp
}


	;The part of the program that's run if no paramater is passed.
nofile:

	;Tray menu
Menu, Tray, NoStandard
menu, tray, Click, 1
Menu, Tray, Tip, PEM - Context is installed
Menu, Tray, add, PEM Editor, PEMe
Menu, Tray, add, Install context, install
Menu, Tray, add, Remove Context, remove
Menu, Tray, add, About PEM, About
Menu, Tray, add, Exit, exittime
Menu, Tray, default,PEM Editor
	; ? button menu
Menu, main, add, About PEM, about
Menu, main, add, View Readme, readme
Menu, main, add
Menu, main, add, Check registry on exit, donothingforreg
Menu, main, add, Show balloon tip, showballoontip
Menu, main, add, Exit, exittime

	;Checks for config options in INI
Iniread, tempy, pem.ini, config, checkRegistry
if(tempy = "" or not tempy = 0)
	Menu, main, check,Check registry on exit

Iniread, tempy, pem.ini, config, balloon
if(tempy <> 0)
{	Menu, main, check, Show balloon tip
	balloon=1
}
Else
	balloon=0
	
	;GUI!
gui 1: add, listview, r10 w325 gLouisValkner -multi +sort, Ext|Program
gui 1: add, button, w40 x20 y170 h20, New
gui 1: add, button, w40 x70 y170 h20, Del
Gui 1:Add,text,x115 y173, Drive:
Gui 1:Add, dropdownlist, w50 y170 x150 r7 vddrive gwritedrive,%weedrives%
	iniread, drv, pem.ini, config, drive
	weedrives(drv)

gui 1: font, underline w600
gui 1: add, Button, x207 y170 w105 gcontextGO vcontext
gui 1: font
gui 1: add, button, y172 x317 w20 h20 gmainmenu voohshiny,?

	;Adding of entries
loop, read, pem.ini
{
	ifinstring, A_Loopreadline,=
	{ 
		Stringsplit,part, A_LoopReadLine,=
		Iniread, addit,pem.ini, key, %part1%
		ifnotequal, addit, error
			LV_Add("",part1,addit)
	}
}
LV_ModifyCol(1,40)
LV_ModifyCol(2,"autohdr")

	;Add/Edit window
Gui 2: +owner1
Gui 2:Add,groupbox,x5 y1 h70 w330 vgbox,Add
Gui 2:Add,text,x13 y20,Extension
Gui 2:Add,Edit,x13 y35 w50 veExt gifempty,
Gui 2:Add,text,x70 y20,Path\Program
Gui 2:Add,Edit,x70 y35 w240 vpPath gifempty2
Gui 2:Add,Button, y34 x315 w15 gpathselect,�
Gui 2:Add, Button, y80 x200 w60 vok2 default disabled, OK
Gui 2:Add, Button,y80 x270 w60, Cancel
Gui 2:Font, s10 underline cRed
Gui 2:Add, text, y80 x7 greadme, DO NOT include the drive letter!

	;About window
Gui 3: +owner1 +toolwindow
Gui 3: add, picture, icon1 x10 y10 w50 h50, %A_scriptname%
Gui 3: font, underline w600
Gui 3: add, text,y3 x70, PEM v0.925
gui 3: font
gui 3: add, text,y20 x70 w250, PEM stands for `"Portable Extension Manager`". It is designed to simplify opening files without adding file associations to registry. It was written in Autohotkey by Jon (me). For more information`, view the readme.
gui 3: font, underline
gui 3: add, text, CBlue y75 x70 gemail, amadmadhatter@gmail.com
Gui 3: add, text, CBlue y90 x70 gwebsite,www.FreewareWire.blogspot.com
gui 3: font

gosub checkcontext

gui 1: show, w345, PEM - Portable Extension Manager

	;Displays a "first time" message
iniread, firsttime, pem.ini, config, firsttime
ifnotequal, firsttime, 0
{	gui 1: +owndialogs
	msgbox, 68, Read the manual!, Greetings! It looks like this is your first time using PEM.`nIf it is, I highly suggest skimming the readme so you know`nwhat does what, the dos and donts, and such. It'll only take`nlike 2 minutes, I swear. It would make me ever so happy.`n-Jon		
	ifmsgbox, Yes
		gosub readme
	iniwrite, 0, pem.ini, config, firsttime
}


Return

	;For tray option
PEMe:
gui 1: show, w345, PEM - Portable Extension Manager
Return
	;For tray option
About:
gui 3: show, autosize, About PEM
Return

	;Readme
readme:
ifnotexist, readme.txt
	{ gui 1: +owndialogs
	  msgbox,48,File Not Found, The Readme does not seem to exist.	
	  Return
	}
run, readme.txt
return
	;In About window
website:
run, http:\\www.freewarewire.blogspot.com
return
	;In About window
email:
run, mailto:amadmadhatter@gmail.com
return

	;Makes sure there is something in both fields in the add/edit window
ifempty:
ifempty2:
gui 2: submit, nohide
ifequal, ppath,
{	guicontrol 2:disabled,ok2,
	Return
}
ifequal, eext,
{	guicontrol 2:disabled,ok2,
	Return
}
guicontrol 2:enabled,ok2,
return

	;For the "..." button in add/edit
pathselect:
FileselectFile, ppath,,,Select Program
Splitpath, ppath,p2,p1,,,pn
Stringreplace, p1, p1, %pn%\,
ppath:=p1 . "\" . p2
Guicontrol 2:,ppath,%ppath%
return

	;Checks if "registry check on exit" is enabled
Donothingforreg:
Iniread, tempy, pem.ini, config, checkRegistry
ifequal, tempy, 0
{	Menu, main, check, Check registry on exit
	iniwrite, 1, pem.ini, config, checkregistry
}
Else
{	Menu, main, uncheck, Check registry on exit
	iniwrite, 0, pem.ini, config, checkregistry
}
return

	;Checks if the balloon tip is enabled
showballoontip:
iniread, tempy, pem.ini, config, balloon
ifequal, tempy, 0
{	menu, main, check, Show balloon tip
	iniwrite, 1, pem.ini, config, balloon
	ballon=0
}
else
{	Menu, main, uncheck, Show balloon tip
	iniwrite, 0, pem.ini, config, balloon
	Ballon=1
}
return

	;Handles any double clicks on the ListView
LouisValkner:
ifequal, A_GuiEvent,DoubleClick
{ LV_GetText(rowExt, A_EventInfo,1)
LV_GetText(Rowpath, A_EventInfo,2)
numero:=A_EventInfo
Gui 2: show, autosize,Edit entry
Guicontrol 2:, gbox, Edit extension - %rowExt%
GuiControl 2:, eExt, %rowext%
GuiControl 2:, pPath, %rowpath%
}
return

	;Checks if the context is installed
checkcontext:
RegRead, UI, HKEY_CLASSES_ROOT, *\shell\PEM
ifequal, errorlevel, 1
	{ UI = in
	Guicontrol 1:, context, Install Context
	Menu, tray, disable, Remove context
	Menu, Tray, enable, Install context
	Menu, Tray, Tip, PEM - Context is not installed
	}
Else
	{ UI = un
	Guicontrol 1:, context, Remove Context
	Menu, tray, enable, Remove context
	Menu, Tray, disable, Install context
	Menu, Tray, Tip, PEM - Context is installed
	}
return

	;Checks if context is installed, then installs/removes
contextGO:
gosub checkcontext
ifequal, UI, In
{  	gosub, install
	return
}
ifequal, UI, Un
	gosub, remove
return

	;For "?" button
mainmenu:
Menu, main, show
return

	;Installs the registry
install:
RegWrite, REG_SZ, HKEY_CLASSES_ROOT, *\shell\PEM\,,Open with PEM
RegWrite, REG_SZ, HKEY_CLASSES_ROOT, *\shell\PEM\command,,`"%A_scriptfullpath%`" `"`%1`"
gosub, checkcontext
return
	;Removes the registry
remove:
Regdelete, HKEY_CLASSES_ROOT, *\shell\PEM
gosub, checkcontext
return

	;Handles if the main GUI closes
guiclose:
ifnotequal, balloon, 0
{ 	traytip,,PEM will stay in your tray because it loves you.
	Settimer, ontip, 3000
	Balloon=0
}
gui 1: hide
gui 2: hide
gui 3: hide
Return
	;Handles if Add/Edit window is closed
2guiclose:
gui 1: -Disabled
gui 2: hide
gui 1: show
return
	;Deletes tray balloon
ontip:
settimer, ontip, off
traytip
return

	;Handles "New" Button
ButtonNew:
gui 2: show, autosize,Add entry
gui 1: +disabled
Guicontrol 2:, ppath,
guicontrol 2:, eext,
Guicontrol 2:, gbox, New Extension
numero=0
return
	;Handles "Del" Button
ButtonDel:
gui 1: default
deleteIt:=LV_GetNext()
LV_GetText(tempExt,deleteIt,1)
LV_Delete(deleteIt)
ifequal, deleteIt, % LV_GetCount() + 1
 LV_Modify(deleteIT - 1, "Select")
Else
 LV_Modify(deleteIt, "Select")
Inidelete, pem.ini, key, %tempext%
return

	;Handles adding an entry
2ButtonOk:
Gui 2:submit
IniWrite, %pPath%, pem.ini, key, %eExt%
gui 1: default
if numero = 0
	LV_Add("",eext,ppath)
Else
	LV_Modify(numero,"",eext,ppath)
	;Handles if "Cancel" button is pressed in Add/Edit
2ButtonCancel:
gui 1: -Disabled
gui 2: hide
gui 1: show
return

	;For when it is time to exit
exittime:
Iniread, nothing, pem.ini, config, checkregistry
ifnotequal, nothing, 0
{
gosub checkcontext
ifequal, ui, un
{ gui 1: +owndialogs
	msgbox,51,Context still installed,The context is still installed. Do you want to remove it before quitting?`n`nYes = Remove context then quit`nNo = Quit without removing`nCancel = Do not remove or quit	
	ifmsgbox, Yes
		gosub remove
	else ifmsgbox, Cancel
		Return
}
}
iniwrite, 1, pem.ini, config, balloon
exitapp

	;Writes the drive to the INI file
writedrive:
gui 1:submit, nohide
iniwrite, %ddrive%, pem.ini, config, drive
Return

	;Massive function to determine the drive
weedrives(drv)
{ 	ifequal, drv, A:
		GuiControl 1:,ddrive, PEM|A:||B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, B:
		GuiControl 1:,ddrive, PEM|A:|B:||C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, C:
		GuiControl 1:,ddrive, PEM|A:|B:|C:||D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, D:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:||E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, E:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:||F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, F:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:||G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, G:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:||H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, H:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:||I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, I:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:||J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, J:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:||K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, K:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:||L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, L:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:||M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, M:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:||N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, N:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:||O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, O:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:||P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, P:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:||Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, Q:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:||R:|S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, R:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:||S:|T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, S:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:||T:|U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, T:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:||U:|V:|W:|X:|Y:|Z:
	else ifequal, drv, U:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:||V:|W:|X:|Y:|Z:
	else ifequal, drv, V:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:||W:||X:|Y:|Z:
	else ifequal, drv, W:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:||X:|Y:|Z:
	else ifequal, drv, X:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:||Y:|Z:
	else ifequal, drv, Y:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:||Z:
	else ifequal, drv, Z:
		GuiControl 1:,ddrive, PEM|A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:||
	else 
	{	GuiControl 1:,ddrive, PEM||A:|B:|C:|D:|E:|F:|G:|H:|I:|J:|K:|L:|M:|N:|O:|P:|Q:|R:|S:|T:|U:|V:|W:|X:|Y:|Z:
		Iniwrite, PEM, pem.ini, config, drive
	}
	
}
