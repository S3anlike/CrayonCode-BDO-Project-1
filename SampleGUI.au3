;=======================================================
;	Name:			SampleGUI.au3
;	Description:	Example for MultiLang.au3
;	Author:			Brett Francis (BrettF)
;	Website:		http://www.signa5.com
;	Last Updated:	14 August 2010
;=======================================================
;Include Constants
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

;Include MultiLang UDF
#include "MultiLang.au3"

;Set location of the language files *OPTIONAL*
Local $LANG_DIR = @ScriptDir & "\LanguageFiles"; Where we are storing the language files.

;This is the language we will load.  You could load this value from an INI file or saved
;location to stop the user having to select a Language every time they run your program.
Local $user_lang = -1


;Create an array of available language files
; ** n=0 is the default language file
; [n][0] = Display Name in Local Language (Used for Select Function)
; [n][1] = Language File (Full path.  In this case we used a $LANG_DIR
; [n][2] = [Space delimited] Character codes as used by @OS_LANG (used to select correct lang file)
Local $LANGFILES[3][3]

$LANGFILES[0][0] = "English (US)" ;
$LANGFILES[0][1] = $LANG_DIR & "\ENGLISH.XML"
$LANGFILES[0][2] = "0409 " & _ ;English_United_States
		"0809 " & _ ;English_United_Kingdom
		"0c09 " & _ ;English_Australia
		"1009 " & _ ;English_Canadian
		"1409 " & _ ;English_New_Zealand
		"1809 " & _ ;English_Irish
		"1c09 " & _ ;English_South_Africa
		"2009 " & _ ;English_Jamaica
		"2409 " & _ ;English_Caribbean
		"2809 " & _ ;English_Belize
		"2c09 " & _ ;English_Trinidad
		"3009 " & _ ;English_Zimbabwe
		"3409" ;English_Philippines

$LANGFILES[1][0] = "Deutsch" ; German
$LANGFILES[1][1] = $LANG_DIR & "\GERMAN.XML"
$LANGFILES[1][2] = "0407 " & _ ;German_Standard
		"0807 " & _ ;German_Swiss
		"0c07 " & _ ;German_Austrian
		"1007 " & _ ;German_Luxembourg
		"1407" ;German_Liechtenstei

$LANGFILES[2][0] = "Français" ; French
$LANGFILES[2][1] = $LANG_DIR & "\FRENCH.XML"
$LANGFILES[2][2] = "040c " & _ ;French_Standard
		"080c " & _ ;French_Belgian
		"0c0c " & _ ;French_Canadian
		"100c " & _ ;French_Swiss
		"140c " & _ ;French_Luxembourg
		"180c" ;French_Monaco

;Set the available language files, names, and codes.
_MultiLang_SetFileInfo($LANGFILES)
If @error Then
	MsgBox(48, "Error", "Could not set file info.  Error Code " & @error)
	Exit
EndIf

;Check if the loaded settings file exists.  If not ask user to select language.
If $user_lang = -1 Then
	;Create Selection GUI
	$user_lang = _MultiLang_SelectGUI("Select Language", "Please select a language")
	If @error Then
		MsgBox(48, "Error", "Could not create selection GUI.  Error Code " & @error)
		Exit
	EndIf
	;It is here where you could save the settings.
EndIf

;Un comment this if you want to see the default language file loaded.
;Default will only be loaded with an invalid $user_lang, which normally
;is the same as returned by @OS_LANG.

;$user_lang = "Z"

;Load the language file
$ret = _MultiLang_LoadLangFile($user_lang)
If @error Then
	MsgBox(48, "Error", "Could not load lang file.  Error Code " & @error)
	Exit
EndIf

;If you supplied an invalid $user_lang, we will load the default language file
If $ret = 2 Then
	MsgBox (64, "Information", "Just letting you know that we loaded the default language file")
EndIf

;GUI CREATION

;Create GUI
$MAIN_GUI = GUICreate(_MultiLang_GetText("main_gui"), 625, 443, 229, 113)
;Create File Menu
$mnu_file = GUICtrlCreateMenu(_MultiLang_GetText("mnu_file"))
;Create Exit Sub Menu
$mnu_file_exit = GUICtrlCreateMenuItem(_MultiLang_GetText("mnu_file_exit"), $mnu_file)
;Create a picture with a tool tip
$pic1 = GUICtrlCreatePic(@ScriptDir & "\SamplePic.jpg", 8, 8, 380, 240)
GUICtrlSetTip($pic1, _MultiLang_GetText("pic1tip"))
;Create A Group Control
$grp_random = GUICtrlCreateGroup(_MultiLang_GetText("grp_random"), 400, 0, 209, 249)
;Combo Control
$combo = GUICtrlCreateCombo("", 416, 24, 177, 25, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, _MultiLang_GetText("combo"))
;Checkbox
$chkbox = GUICtrlCreateCheckbox(_MultiLang_GetText("chkbox"), 416, 56, 177, 17)
;Radio Controls
$radio1 = GUICtrlCreateRadio(_MultiLang_GetText("radio1"), 416, 80, 177, 17)
$radio2 = GUICtrlCreateRadio(_MultiLang_GetText("radio2"), 416, 104, 177, 17)
$radio3 = GUICtrlCreateRadio(_MultiLang_GetText("radio3"), 416, 128, 177, 17)
;List Box
$list = GUICtrlCreateList("", 416, 160, 177, 71)
GUICtrlSetData(-1, _MultiLang_GetText("list"), "")
;Edit Control
$edit1 = GUICtrlCreateEdit(_MultiLang_GetText("edit1", 1), 8, 256, 297, 153)
;Edit Control 2
$edit2 = GUICtrlCreateEdit(_MultiLang_GetText("edit2", 1), 312, 256, 297, 153)

;Show the GUI
GUISetState(@SW_SHOW)

;Clear opened data.
_MultiLang_Close()

;Loop and wait for GUI to close
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $mnu_file_exit
			Exit
	EndSwitch
WEnd