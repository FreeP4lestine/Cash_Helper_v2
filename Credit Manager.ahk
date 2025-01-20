#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\jxon>
#Include <shared\gdip>
#Include <credit>
#Include <setting>
#Include <shared\createimagebutton>
#Include <imagebuttons>
#Include <shadow>
#Include <inc\ui-base>

If A_Args.Length != 1 || A_Args[1] = '' {
	MsgBox('No user input!', 'Login', 0x30)
	ExitApp()
}
usersetting := readJson(A_AppData '\Cash Helper\users.json')
If !usersetting.Has('Registered') || !usersetting['Registered'].Has(A_Args[1]) {
	Msgbox('<' A_Args[1] '> does not exist!', 'Login', 0x30)
	ExitApp()
}
username := A_Args[1]

setting := readJson()

pToken := Gdip_Startup()
mainWindow := AutoHotkeyUxGui(setting['Name'], 'Resize MinSize800x600')
mainWindow.BackColor := 'White'
mainWindow.MarginX := 30
mainWindow.MarginY := 30
mainWindow.SetFont('s25', 'Segoe UI')
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.OnEvent('Size', resizeControls)

HeaderImg := mainWindow.AddPicture(, 'images\Credit Manager.png')
HeaderText := mainWindow.AddText('ym+10', 'Credit Manager')
HeaderBox := Shadow(mainWindow, [HeaderImg, HeaderText])

mainWindow.SetFont('s12')
AddNew := mainWindow.AddButton('xm w200', '+ Add New')
CreateImageButton(AddNew, 0, IBBlack1*)
 
GoBack := mainWindow.AddButton('xp yp wp hp Hidden Left', ' ← Go Back')
CreateImageButton(GoBack, 0, IBBlack1*)

mainWindow.MarginY := 10

CommitLaterList := mainWindow.AddListMenu('Multi wp r10 -E0x200 BackgroundF0F0F0')
Commit := mainWindow.AddButton('wp', 'Clear out')
CreateImageButton(Commit, 0, IBRed1*)
CommitListBox := Shadow(mainWindow, [AddNew, CommitLaterList, Commit])

;Gui, Font, s14
;Gui, Add, ListView, % "xm+421 ym+20 w" qw * 3 - 391 " h" A_ScreenHeight - 200 " vLV", % "|" _38 "|" _68 "|" _39
;
;LV_ModifyCol(1, "0 Center")
;LV_ModifyCol(2, qw - 130)
;LV_ModifyCol(3, qw - 130)
;LV_ModifyCol(4, qw - 130)
;
;Gui, Font, s16
;Gui, Add, Edit, % "xp-201 yp w190 r2 vThisKridi -E0x200 Border Center ReadOnly HwndHCtrl -VScroll"
;CtlColors.Attach(HCtrl, "FFC080")
;
;Gui, Font, s14
;Gui, Add, ListBox, % "wp h" A_ScreenHeight - 425 " vKDate gSelectFromLv AltSubmit HwndHCtrl Multi 0x100"
;CtlColors.Attach(HCtrl, "FFC080")
;
;Gui, Font, s16
;Gui, Add, Edit, % "wp r2 vSubThisKridi -E0x200 Border Center ReadOnly HwndHCtrl -VScroll"
;CtlColors.Attach(HCtrl, "FFC080")
;
;Gui, Add, Edit, % "wp vKridi -E0x200 Border Center HwndHCtrl -VScroll Number"
;CtlColors.Attach(HCtrl, "FFFFFF")
;
;Gui, Add, Button, % "wp h30 HwndHCtrl gKridiOut", % _29
;ImageButton.Create(HCtrl, ButtonTheme3*)
;
;Gui, Add, Edit, % "xm+" qw * 3 - 391 + 12 + 421 " ym+20 wp r2 vPay -E0x200 Border Center ReadOnly HwndHCtrl -VScroll"
;CtlColors.Attach(HCtrl, "96C864")
;
;Gui, Font, s14
;Gui, Add, ListBox, % "wp h" A_ScreenHeight - 425 " vPDate HwndHCtrl AltSubmit gShowPayVal 0x100"
;CtlColors.Attach(HCtrl, "96C864")
;
;Gui, Font, s16
;Gui, Add, Edit, % "wp r2 vThisPay -E0x200 Border Center ReadOnly HwndHCtrl -VScroll"
;CtlColors.Attach(HCtrl, "96C864")
;
;Gui, Add, Edit, % "wp vPayBack -E0x200 Border Center HwndHCtrl -VScroll Number"
;CtlColors.Attach(HCtrl, "FFFFFF")
;
;Gui, Add, Button, % "wp h30 HwndHCtrl gPayOut", % _186
;ImageButton.Create(HCtrl, ButtonTheme4*)
;
;Gui, Font, s20
;Gui, Add, Edit, % "vBalance xm+421 y" A_ScreenHeight - 160 " w" qw * 3 - 391 " -E0x200 Border Center HwndHCtrl ReadOnly"
;CtlColors.Attach(HCtrl, "D8D8AD", "FF0000")

mainWindow.Show('Maximize')