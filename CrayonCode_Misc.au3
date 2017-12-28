#cs ----------------------------------------------------------------------------

	AutoIt Version: 3.3.14.2
	Author:         CrayonCode
	Version:		Alpha 0.51
	Contact:		https://discord.gg/yEqadvZ edited by s3anlike & Rodent11 & David

#ce ----------------------------------------------------------------------------


#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compile_Both=y  ;required for ImageSearch.au3
#AutoIt3Wrapper_UseX64=y  ;required for ImageSearch.au3
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#RequireAdmin
#include "ImageSearch.au3"
#include "FastFind.au3"
#include "Support.au3"
#include <File.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>

#Region - Autoupdate
Global $VersionsInfo = "https://raw.githubusercontent.com/davidgao93/CrayonCode-BDO-Project/master/version.ini"
Global $oldVersion = IniRead("updater.ini","Version","MVersion","NotFound")
Global $newVersion = "0.0"

$Ini = InetGet($VersionsInfo,@ScriptDir & "\version.ini") ;download version.ini

If $Ini = 0 Then ;was the download of version.ini successful?
    MsgBox(0,"ERROR","Unable to fetch from Github - maybe it's down?")
Else
    $newVersion = IniRead (@ScriptDir & "\version.ini","Version","MVersion","") ;reads the new version out of version.ini
    If $NewVersion = $oldVersion Then ;compare old and new
        MsgBox (0,"Autoupdate", "You're running version " & $NewVersion)
    Else
        $msg = MsgBox (4,"Autoupdate","Update available, revision: " & $newVersion & ". You are currently on revision: " & $oldVersion & ". Do you want to update?")
        If $msg = 7 Then ;No was pressed
            FileDelete(@ScriptDir & "\version.ini")
            Exit
        ElseIf $msg = 6 Then ;OK was pressed
            $downloadLink = IniRead(@ScriptDir & "\version.ini","Version","Mdownload","NotFound")
            $dlhandle = InetGet($downloadLink,@ScriptDir & "\CrayonCode_Misc" & $newVersion & ".au3",1,1)
            ProgressOn("", "", "",-1,-1,16) ;creates an progressbar
            $Size = InetGetSize($downloadLink,1) ;get the size of the update
            While Not InetGetInfo($dlhandle, 2)
                $Percent = (InetGetInfo($dlhandle,0)/$Size)*100
                ProgressSet( $Percent, $Percent & " percent");update progressbar
                Sleep(1)
            WEnd
            ProgressSet(100 , "Done", "Complete");show complete progressbar
            sleep(500)
            ProgressOff() ;close progress window
            IniWrite("updater.ini","Version","MVersion",$NewVersion) ;updates update.ini with the new version
            InetClose($dlhandle)
            MsgBox(-1,"Success","Update complete, please run the new version of the application with the new version number. Please see the releases page for changelog.")
			;FileDelete(@ScriptDir & "\version.ini")
			_terminate()
            EndIf
    EndIf
EndIf
;FileDelete(@ScriptDir & "\version.ini")
#EndRegion - Autoupdate

#Region ### START Koda GUI section ### Form=c:\program files (x86)\autoit3\scite\koda\forms\fish2.kxf
$Form1_1 = GUICreate("CrayonCode Marketplace", 615, 437, 231, 124)
$Tab1 = GUICtrlCreateTab(0, 0, 614, 400)
$Tab_StatusLog = GUICtrlCreateTabItem("Status Log")
GUICtrlSetState(-1,$GUI_SHOW)
$ELog = GUICtrlCreateEdit("", 8, 32, 593, 361, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 100)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 100)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 100)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 100)
GUICtrlCreateTabItem("")
$BQuit = GUICtrlCreateButton("Quit "& @CRLF & "[CTRL+F1]", 8, 400, 100, 33, $BS_MULTILINE)
;$BSave = GUICtrlCreateButton("Save Settings" & @CRLF & "[CTRL+F2]", 108, 400, 100, 33, $BS_MULTILINE)
$BMarketplace = GUICtrlCreateButton("Start MP" & @CRLF & "[Ctrl+F3]", 108, 400, 100, 33, $BS_MULTILINE)
$BMilk = GUICtrlCreateButton("Start Milking" & @CRLF & "[Ctrl+F4]", 208, 400, 100, 33, $BS_MULTILINE)
$BRoll = GUICtrlCreateButton("Start Rolling" & @CRLF & "[Ctrl+F5]", 308, 400, 100, 33, $BS_MULTILINE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

OnAutoItExitRegister(_ImageSearchShutdown)
Opt("MouseClickDownDelay", 100)
Opt("MouseClickDelay", 50)
Opt("SendKeyDelay", 50)

Global $Marketplace = False, $Milking = False
Global $Res[4] = [0, 0, @DesktopWidth, @DesktopHeight]
Global $hTitle = "BLACK DESERT - "
Global $LNG = "en"
Global $LogEnable = True
Global $IsRolling = False
HotKeySet("^{F1}", "_terminate")
;HotKeySet("^{F2}", "StoreGUI")
HotKeySet("^{F3}", "RunMarketplace")
HotKeySet("^{F4}", "Milking")
HotKeySet("^{F5}", "Rolling")

; # GUI
Func SetGUIStatus($data)
	Local Static $LastGUIStatus
	Local Static $Limits = _GUICtrlEdit_SetLimitText ( $ELog, 300000000 ) ; Increase Text Limit since Log usually stopped around 800 lines
	If $data <> $LastGUIStatus Then
		_GUICtrlEdit_AppendText($ELog, @HOUR & ":" & @MIN & "." & @SEC & " " & $data & @CRLF)
		ConsoleWrite(@CRLF & @HOUR & ":" & @MIN & "." & @SEC & " " & $data)
		If $LogEnable = True Then LogData(@HOUR & ":" & @MIN & "." & @SEC & " " & $data, "logs/MP_LOGFILE.txt")
		$LastGUIStatus = $data
	EndIf
EndFunc   ;==>SetGUIStatus

Func GUILoopSwitch()
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $BQuit
			_terminate()
		Case $BMarketplace
			RunMarketplace()
		;Case $BSave
		;	StoreGUI()
		Case $BMilk
			Milking()
		Case $BRoll
			Rolling()
	EndSwitch
EndFunc   ;==>GUILoopSwitch

Func InitGUI()
	; ClientSettings
	;Global $ClientSettings = IniReadSection("config/settings.ini", "ClientSettings")
	;GUICtrlSetData($IClientName, $ClientSettings[1][1])
	;GUICtrlSetData($CLang, "|en|de|fr", $ClientSettings[2][1])
	;GUICtrlSetState($CBLogFile, CBT($ClientSettings[3][1]))
EndFunc

Func StoreGUI()
	; ClientSettings
	Global $ClientSettings = IniReadSection("config/settings.ini", "ClientSettings")
	$ClientSettings[1][1] = GUICtrlRead($IClientName)
	$ClientSettings[2][1] = GUICtrlRead($CLang)
	$ClientSettings[3][1] = CBT(GUICtrlRead($CBLogFile))
	IniWriteSection("config/settings.ini", "ClientSettings", $ClientSettings)
	
	InitGUI()
EndFunc

Func CreateConfig()
	If FileExists("logs/") = False Then DirCreate("logs/")
	If FileExists("config/") = False Then DirCreate("config/")

	If FileExists("config/settings.ini") = False Then
		Local $ClientSettings = ""
		$ClientSettings &= "ClientName=BLACK DESERT - " & @LF
		$ClientSettings &= "ClientLanguage=en" & @LF
		$ClientSettings &= "Enable_Logfile=1" & @LF
		$ClientSettings &= "Enable_ScreencapLoot=0" & @LF
		IniWriteSection("config/settings.ini", "ClientSettings", $ClientSettings)
	EndIf
EndFunc   ;==>CreateConfig

; # Basic
Func DetectFullscreenToWindowedOffset($hTitle) ; Returns $Offset[4] left, top, right, bottom (Fullscreen returns 0, 0, Width, Height)
	Local $x1, $x2, $y1, $y2
	Local $Offset[4]
	Local $ClientZero[4] = [0, 0, 0, 0]

	WinActivate($hTitle)
	WinWaitActive($hTitle, "", 5)
	WinActivate($hTitle)
	Local $Client = WinGetPos($hTitle)
	If Not IsArray($Client) Then
		SetGUIStatus("E: ClientSize could not be detected")
		Return ($ClientZero)
	EndIf

	If $Client[2] = @DesktopWidth And $Client[3] = @DesktopHeight Then
		SetGUIStatus("Fullscreen detected (" & $Client[2] & "x" & $Client[3] & ") - No Offsets")
		Return ($Client)
	EndIf

	If Not VisibleCursor() Then CoSe("{LCTRL}")
	Opt("MouseCoordMode", 2)
	MouseMove(0, 0, 0)
	Opt("MouseCoordMode", 1)
	$x1 = MouseGetPos(0)
	$y1 = MouseGetPos(1)
	Opt("MouseCoordMode", 0)
	MouseMove(0, 0, 0)
	Opt("MouseCoordMode", 1)
	$x2 = MouseGetPos(0)
	$y2 = MouseGetPos(1)
	MouseMove($x1, $y1, 0)


	$Offset[0] = $Client[0] + $x1 - $x2
	$Offset[1] = $Client[1] + $y1 - $y2
	$Offset[2] = $Client[0] + $Client[2]
	$Offset[3] = $Client[1] + $Client[3]
	For $i = 0 To 3
		SetGUIStatus("ScreenOffset(" & $i & "): " & $Offset[$i])
	Next

	Return ($Offset)
EndFunc   ;==>DetectFullscreenToWindowedOffset

; #Region - Marketplace
Func RunMarketplace()
	$Marketplace = Not $Marketplace
	If $Marketplace = False Then
		SetGUIStatus("Stopping Marketplace")
	Else
		SetGUIStatus("Starting Marketplace")
		Marketplace()
	EndIf
EndFunc   ;==>RunMarketplace

Func Marketplace()
	Local Const $PurpleBags = "res/purplebags.png"
	Local $RegistrationCountOffset[4] = [70, -9, 110, 5]
	Local $RefreshOffset[2] = [-440, 480]
	Local $x, $y, $IS
	Local $Diff[4]
	Local $timer

	$ResOffset = DetectFullscreenToWindowedOffset($hTitle)
	
	$IS = _ImageSearchArea($PurpleBags, 1, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $x, $y, 50, 0)
	If $IS = False Then
		SetGUIStatus("Couldn't find MP anchor, are you on the right interface? Maybe restart the bot.")
		$Marketplace = False
	Else
		SetGUIStatus("PurpleBags anchor found with location " & $x & ", " & $y)
		MouseMove($x, $y)
	EndIf
		
	Local $count = 0, $breakout = 0
	While $Marketplace
		SetGUIStatus("Waiting for Registration Count change")
		$number = FastFindBidBuy($x, $y)
		If $number >= 0 Then BuyItem($x, $y, $number)

		$Diff[$count] = PixelChecksum($x + $RegistrationCountOffset[0], $y + $RegistrationCountOffset[1], $x + $RegistrationCountOffset[2], $y + $RegistrationCountOffset[3])
		For $i = 0 To UBound($Diff) - 1
			If $Diff[0] <> $Diff[$i] Then
				If TimerDiff($timer) > 1000 Then
					SetGUIStatus("Refresh (Registration Count change)")
					MouseClick("left", $x + $RefreshOffset[0], $y + $RefreshOffset[1], 1, 0)
					$timer = TimerInit()
					Sleep(50)
					ExitLoop
				Else
					$breakout += 1
					If $breakout > 10 Then
						$IS = _ImageSearchArea($PurpleBags, 1, $x - 10, $y - 10, $x + 10, $y + 10, $x, $y, 20, 0)
						If $IS = False Then
							SetGUIStatus("Marketplace anchor not found. Stopping.")
							$Marketplace = False
						Else
							$breakout = 0
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		If TimerDiff($timer) > 15000 Then
			SetGUIStatus("Refresh (15s no change detected)")
			MouseClick("left", $x + $RefreshOffset[0], $y + $RefreshOffset[1], 1, 0)
			$timer = TimerInit()
			Sleep(50)
		EndIf
		Sleep(50)
		$count += 1
		If $count = 4 Then $count = 0
	WEnd
EndFunc   ;==>Marketplace

Func FastFindBidBuy($x, $y)
	Local $Valid[2] = [0x979292, 0xB8B8B8]
	Local $SSN = 1, $FF
	Local $BidR[3] = [21, 12, 21]
	Local $Buy[3] = [3, 12, 21]
	Local $Bid[3] = [4, 12, 21]
	Local $BuyOffset[3] = [78, 54, 62] ; x, y, height 7
	Local $ButtonRegion[4] = [$x + $BuyOffset[0] - 15, $y + $BuyOffset[1] - 15, $x + $BuyOffset[0] + 15, $y + $BuyOffset[1] + 15]
	Local $MPImages[5] = ["res/mp_buy.png", "res/mp_max.png", "res/mp_purchase.png", "res/mp_bid.png", "mp_bidresult.png"]
	Local $count = 0
	Local $b, $n, $IS
	$ResOffset = DetectFullscreenToWindowedOffset($hTitle)
	
	;SetGUIStatus("Setting search area for snapshot")
	;MouseMove($x + $BuyOffset[0] - 15, $y + $BuyOffset[1] - 15)
	;Sleep(500)
	;MouseMove($x + $BuyOffset[0] + 15, $y + $BuyOffset[1] + 15)
	;Sleep(500)
	
	;FFSnapShot($ButtonRegion[0], $ButtonRegion[1], $ButtonRegion[2], $ButtonRegion[3] + $BuyOffset[2] * 6, $SSN)
	
	For $count = 0 To 4
		$IS = _ImageSearchArea($MPImages[$count], 0, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $b, $n, 50, 0)
		While $IS = True
			If $IS = True Then
				SetGUIStatus($MPImages[$count] & " found, clicking")
				MouseClick("left", $b, $n, 2, 0)
				Sleep(200)
				CoSe("{SPACE}")
			EndIf
		$IS = _ImageSearchArea($MPImages[$count], 0, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $b, $n, 50, 0)
		WEnd
	Next
	Return -1
EndFunc   ;==>FastFindBidBuy


Func BuyItem($x, $y, $number)
	Local $MaxOffset[2] = [-111, 297]
	Local $BuyOffset[3] = [78, 54, 62] ; x, y, height

	MouseClick("left", $x + $BuyOffset[0], $y + $BuyOffset[1] + $number * $BuyOffset[2], 2, 0) ; buy
	MouseClick("left", $x + $MaxOffset[0] - 30, $y + $MaxOffset[1], 1, 0) ; amount
	CoSe("f") ; max
	CoSe("r") ; confirm
	CoSe("{SPACE}") ; yes
EndFunc   ;==>BuyItem
; #EndRegion - Marketplace

Func Main()
	ObfuscateTitle($Form1_1)
	CreateConfig()
	InitGUI()
	While True
		GUILoopSwitch()
	WEnd
EndFunc   ;==>Main

Func Milking()
	$Milking = Not $Milking
	If $Milking = False Then Return False

	Local $x, $y, $IS
	Local Const $Milk[4] = ["res/milk_right.png", "res/milk_left.png", "res/milk_startL.png", "res/milk_startR.png"]
	Local $CowCDIni = 0;Int(IniRead("config/data.ini", "MilkingSettings", "MilkCD", 0))
	$ResOffset = DetectFullscreenToWindowedOffset($hTitle)
	Local $statustimer = TimerInit()
	Local $CowCDtimer = TimerInit()
	Local $CowCD = $CowCDIni * 1000

	SetGUIStatus("Ready for milking. Talk to a cow. (CD: " & $CowCDIni & ")")
	While $Milking
		GUILoopSwitch()
		Sleep(50)
		$IS = _ImageSearchArea($Milk[0], 0, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $x, $y, 40, 0)
		If $IS = True Then
			If VisibleCursor() = True Then CoSe("{LCTRL}")
			SetGUIStatus("milk RIGHT")
			MouseDown("right")
			Sleep(120)
			MouseUp("right")
			$statustimer = TimerInit()
			ContinueLoop
		EndIf
		$IS = _ImageSearchArea($Milk[1], 0, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $x, $y, 40, 0)
		If $IS = True Then
			If VisibleCursor() = True Then CoSe("{LCTRL}")
			SetGUIStatus("milk LEFT")
			MouseDown("left")
			Sleep(120)
			MouseUp("left")
			$statustimer = TimerInit()
			ContinueLoop
		EndIf
		$IS = _ImageSearchArea($Milk[2], 0, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $x, $y, 20, 0)
		If $IS = True Then
			$IS = _ImageSearchArea($Milk[3], 0, $ResOffset[0], $ResOffset[1], $ResOffset[2], $ResOffset[3], $x, $y, 20, 0)
			If $IS = True Then
				If VisibleCursor() = True Then CoSe("{LCTRL}")
				SetGUIStatus("Start Milking")
				MouseClick("left")
				$statustimer = TimerInit()
				Sleep(100)
				ContinueLoop
			EndIf
		EndIf
		If TimerDiff($statustimer) > 2000 Then SetGUIStatus("Ready for milking. Talk to a cow.")
		If TimerDiff($CowCDtimer) > $CowCD And $CowCD > 0 Then
			SetGUIStatus("Milking Cooldoown over. Pressing R.")
			CoSe("r")
			Sleep(2000)
			$CowCDtimer = TimerInit()
		EndIf
	WEnd
	SetGUIStatus("Stopped Milking")
EndFunc   ;==>Milking

Func Rolling()
	$IsRolling = Not $IsRolling

	If $IsRolling = False Then
		SetGUIStatus("Stopped Rolling")
	Else
		SetGUIStatus("Started rolling")
	EndIf
	
	While $IsRolling = True
		Sleep(50)
        CoSe("{q down}")
        Sleep(100)
        CoSe("{w down}")
        Sleep(50)
        CoSe("{w up}")
        Sleep(150)
		CoSe("{q up}")
	WEnd

EndFunc

Main()
