#Requires AutoHotkey v2
#SingleInstance Force
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 200
#Include <shared\gdip>
#Include <shared\createimagebutton>
#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\incelledit>
#Include <shared\cuebanner>
#Include <imagebuttons>
#Include <setting>
#Include <sell>
#Include <shadow>

FileEncoding('UTF-8')

If A_Args.Length != 1 || A_Args[1] = '' {
	ExitApp()
}
usersetting := readJson(A_AppData '\Cash Helper\users.json')
If !usersetting.Has('Registered') || !usersetting['Registered'].Has(A_Args[1]) {
	ExitApp()
}
username := A_Args[1]
setting := readJson()
currency := readJson('setting\currency.json')
Sells := readJson('setting\sessions\sessions.json')

allItems := Map()
searchItems := []
pToken := Gdip_Startup()
mainWindow := Gui('Resize MinSize800x600', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 30
mainWindow.MarginY := 30
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.OnEvent('Size', resizeControls)
C1 := mainWindow.AddPicture(, 'images\Sell Manager.png')
mainWindow.SetFont('s25', 'Segoe UI')
C2 := mainWindow.AddText('ym+10', 'Sell Manager')
mainWindow.MarginY := 10
quickWindow := Gui('-MinimizeBox', setting['Name'])
quickWindow.BackColor := 'White'
quickWindow.MarginX := 5
quickWindow.MarginY := 5
quickWindow.SetFont('s10')
quickText := quickWindow.AddText('w200')
quickWindow.SetFont('s18')
quickEdit := quickWindow.AddEdit('wp Center')
quickRow := quickWindow.AddEdit('xp yp wp hp Hidden')
quickCol := quickWindow.AddEdit('xp yp wp hp Hidden')
quickCode := quickWindow.AddEdit('xp yp wp hp Hidden')
quickOK := quickWindow.AddButton('hp yp', '✓')
quickOK.OnEvent('Click', (*) => quickListSubmit())
C3 := mainWindow.AddText('xm ym+140 w192 h100 Hidden')
Thumb := mainWindow.AddPicture('xm+20 yp w64 h64', 'images\Default.png')
Stock := mainWindow.AddEdit('xp+80 yp+10 w60 r1 BackgroundWhite cRed ReadOnly -E0x200 Center')
Stock.SetFont('s15')
Code128 := mainWindow.AddPicture('xm+20 yp+70 w140 h32')
mainWindow.SetFont('s8 norm')
latestSellsCount := mainWindow.AddText('cBlue xm ym+295 w192 Center', 'Latest sells:')
mainWindow.SetFont('s10')
latestSells := mainWindow.AddListView('-E0x200 w192 h326 -Hdr', ['Code', 'Name'])
latestSells.OnEvent('Click', displayItemCode)
SetExplorerTheme(latestSells.Hwnd)
latestSellsCLV := LV_Colors(latestSells)
latestSellsCLV.AlternateRows(0xFFE6E6E6)
latestSells.ModifyCol(1, 'Center ' 0)
latestSells.ModifyCol(2, 'Center ' 192)
mainWindow.SetFont('s8 norm')
quickResume := mainWindow.AddText('Hidden cBlue w192 Center', 'Quick resume:')
mainWindow.SetFont('s12 Bold')
pendingBought := mainWindow.AddEdit('Hidden w192 Center ReadOnly cRed -E0x200')
pendingSold := mainWindow.AddEdit('Hidden wp Center ReadOnly cGreen -E0x200')
pendingProfit := mainWindow.AddEdit('Hidden wp Center ReadOnly cGreen -E0x200')
Box2 := Shadow(mainWindow, [C3, Thumb, Code128, latestSellsCount, latestSells, quickResume, pendingBought, pendingSold, pendingProfit])
mainWindow.SetFont('s14 norm')
mainWindow.MarginY := 10
mainList := mainWindow.AddListView('xm+240 ym+140 w980 h422 NoSortHdr -E0x200')
mainList.OnNotify(-3, quickListEdit)
mainList.OnEvent('ItemSelect', (*) => thumbCheck())
mainList.OnEvent('Click', (*) => thumbCheck())
SetExplorerTheme(mainList.Hwnd)
mainListCLV := LV_Colors(mainList)
For Each, Col in setting['Sell']['Session']['03'] {
    mainList.InsertCol(Each, , Col)
}
mainList.ModifyCol(1, 'Center ' 10)
mainList.ModifyCol(2, 'Center ' 150)
mainList.ModifyCol(3, 'Center ' 150)
mainList.ModifyCol(4, 'Center ' 0)
mainList.ModifyCol(5, 'Center ' 100)
mainList.ModifyCol(6, 'Center ' 0)
mainList.ModifyCol(7, 'Right ' 100)
mainList.ModifyCol(8, '')
mainList.ModifyCol(9, 'Center ' 150)
mainList.ModifyCol(10, 'Center ' 200)
mainList.ModifyCol(11, 'Center ' 60)
mainList.ModifyCol(12, 'Center ' 200)

mainList.GetPos(, &Y, &W)
mainWindow.SetFont('s25')
enteredCode := mainWindow.AddEdit('xm+' (W - 500 + 200) ' ym+10 w450 Right c0000ff -E0x200')
EM_SETCUEBANNER(enteredCode.Hwnd, '→ Code')
enteredCode.OnEvent('Change', (*) => analyzeCode())
searchList := mainWindow.AddComboBox('xp yp wp hp Hidden r10')
searchList.OnEvent('Change', searchAnalyzeCode)
searchAnalyzeCode(Ctrl, Info) {
	If Ctrl.Value && IsDigit(Ctrl.Value '') && Ctrl.Value <= searchItems.Length {
		enteredCode.Value := searchItems[Ctrl.Value]['Code']
		analyzeCode()
	}
	enteredCode.Visible := True
	searchList.Visible := False
}
searchList.OnCommand(CBN_CLOSEUP := 8, (*) => searchListHide())
searchListHide() {
	enteredCode.Visible := True
	searchList.Visible := False
}
mainWindow.SetFont('s14')
CItemPrice := mainWindow.AddEdit('xp+250 yp+55 w250 cRed Right -E0x200')
EM_SETCUEBANNER(CItemPrice.Hwnd, '→ Price')
Box := Shadow(mainWindow, [C1, C2, enteredCode, CItemPrice])
mainWindow.SetFont('s35')
priceSum := mainWindow.AddEdit('xm+350 ym+600 w330 -E0x200 Right cRed ReadOnly BackgroundWhite')
priceSum.SetFont('', 'Calibri')
mainWindow.SetFont('s12')
prevSess := mainWindow.AddButton('xm+240 yp+50 w70  Center', '← Prev')
CreateImageButton(prevSess, 0, IBGray1*)
prevSess.OnEvent('Click', (*) => prevSession())
mainWindow.SetFont('s14')
currentSession := mainWindow.AddEdit('xp+70 yp w70 Center Number -E0x200', Session := 1)
currentSession.OnEvent('Change', (*) => readSessionList())
mainWindow.SetFont('s12')
nextSess := mainWindow.AddButton('xp+70 yp w70  Center', 'Next →')
CreateImageButton(nextSess, 0, IBGray1*)
nextSess.OnEvent('Click', (*) => nextSession())
mainWindow.MarginY := 30
mainWindow.MarginX := 30
Box3 := Shadow(mainWindow, [mainList])
Box4 := Shadow(mainWindow, [prevSess, currentSession, nextSess, priceSum])
payCheckWindow := Gui('', setting['Name'])
payCheckWindow.BackColor := 'White'
payCheckWindow.OnEvent('Close', (*) => mainWindow.Opt('-Disabled'))
payCheckWindow.MarginX := 20
payCheckWindow.MarginY := 20
payCheckWindow.SetFont('s30')
commitImg := payCheckWindow.AddPicture('xm+186', 'images\commit.png')
commitMsg := payCheckWindow.AddText('xm cGray w500 Center', 'Commit the sell?')
commitAmount := payCheckWindow.AddEdit('w500 Center cGreen ReadOnly BackgroundE6E6E6 -E0x200')
commitAmountPay := payCheckWindow.AddEdit('w500 Center BackgroundWhite -E0x200 Border')
commitAmountPay.OnEvent('Change', (*) => updateAmountPayBack())
commitAmountPayBack := payCheckWindow.AddEdit('w500 Center cRed ReadOnly BackgroundE6E6E6 -E0x200')
payCheckWindow.SetFont('s15 norm')
commitOK := payCheckWindow.AddButton('w500 hp', 'Commit')
commitOK.OnEvent('Click', (*) => commitSellSubmit())
commitOK.SetFont('Bold')
payCheckWindow.MarginY := 5

commitLater := payCheckWindow.AddButton('w250 hp-20', 'Commit later')
commitLater.OnEvent('Click', (*) => commitSellSubmit(1))
commitLater.SetFont('s10')

Invoice := payCheckWindow.AddButton('xp+250 yp w250 hp Disabled', 'Invoice')
InvoiceLocation := payCheckWindow.AddEdit('xp yp wp hp Hidden')
Invoice.OnEvent('Click', (*) => Run('Invoice.ahk -f ' InvoiceLocation.Value))
Invoice.SetFont('s10')

commitCancel := payCheckWindow.AddButton('xm w500 hp', 'Cancel')
commitCancel.OnEvent('Click', (*) => (mainWindow.Opt('-Disabled'), payCheckWindow.Hide()))
commitCancel.SetFont('s10')

CommitLaterName := Gui(, setting['Name'])
CommitLaterName.OnEvent('Close', (*) => payCheckWindow.Opt('-Disabled'))
commitLaterName.SetFont('s15', 'Segoe UI')
LaterClient := CommitLaterName.AddText('w400 Center', 'Commit later for:')
CommitLaterNameList := CommitLaterName.AddComboBox('w400')
LaterClientOK := CommitLaterName.AddButton('xm+100 w200', 'OK')
LaterClientOK.OnEvent('Click', (*) => commitLaterSell())


;OptionMenu := Menu()
;OptionMenu.Add('Exit', (*) => ExitApp())
;OptionMenu.Add('Commit', (*) => ExitApp())
;OptionMenu.Add('Quick resume', (*) => ExitApp())
;OptionMenu.Add('Add item to the list', (*) => ExitApp())
;OptionMenu.Add('Increase item amount in the list', (*) => ExitApp())
;OptionMenu.Add('Decrease item amount in the list', (*) => ExitApp())
;OptionMenu.Add('Delete item from the sell list', (*) => ExitApp())
;OptionMenu.Add('Switch to the next session', (*) => ExitApp())
;OptionMenu.Add('Switch to the previous session', (*) => ExitApp())
;Menus := MenuBar()
;Menus.Add('Options', OptionMenu)
;mainWindow.MenuBar := Menus
mainWindow.Show('Maximize')
loadDefinitions()
readSessionList()
latestSellsLoad() 
pendingQuickResume()
SetTimer(saveSessions, setting['SessAutoSave'])
enteredCode.Focus()

#HotIf enteredCode.Focused
Enter::addItemToList()
#HotIf

#HotIf mainList.Focused

#HotIf

#HotIf WinActive(quickWindow)
Enter::quickListSubmit()
#HotIf

#HotIf CItemPrice.Focused
Enter::addCustomPrice()
#HotIf

#HotIf WinActive(payCheckWindow)
Enter::commitSellSubmit()
#HotIf

#HotIf WinActive(mainWindow)
Enter:: enteredCode.Focus()
Space:: commitSell()
Delete:: removeItemFromList()
Left:: prevSession()
Right:: nextSession()
^Tab:: HideShowQuickies()
^F:: searchCode()
PgUp::IncreaseQ()
PgDn::DecreaseQ()
#HotIf