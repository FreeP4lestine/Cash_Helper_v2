#Requires AutoHotkey v2
#SingleInstance Force
A_HotkeyInterval := 2000
A_MaxHotkeysPerInterval := 200

#Include <GuiEx\GuiEx>

#Include <shared\incelledit>
#Include <shared\cuebanner>
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

mainWindow := GuiEx()
mainWindow.Default(1)

Logo := mainWindow.AddPicEx(, 'images\Sell Manager.png', 0)
Title := mainWindow.AddText('ym+10', 'Sell Manager')
enteredCode := mainWindow.AddEditEx('yp w927 Right c0000ff -Border',, '→ Code', ['s25'])
enteredCode.OnEvent('Change', (*) => analyzeCode())
enteredCode.GetPos(,, &W)

searchList := mainWindow.AddComboBoxEx('xp yp w' W ' r10 Hidden',,, ['s25'])
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
searchList.GetPos(&X, &Y, &W)

CItemPrice := mainWindow.AddEditEx('x' X ' y' Y + 5 ' w' W ' cRed Right -Border',, '→ Price', ['s14'])
mainWindow.AddBorder([Logo,  Title,  enteredCode,  CItemPrice], 20)

mainWindow.MarginY := 10
Thumb := mainWindow.AddPicEx('xm+20 yp+50 w64 h64', 'images\Default.png', 0)
Stock := mainWindow.AddEditEx('xp+80 yp+10 w60 cRed ReadOnly Center -Border',,, ['s15'])
Code128 := mainWindow.AddPicEx('xm+20 yp+20 w140 h32 -Border',, 0)

latestSellsCount := mainWindow.AddTextEx('cBlue xm yp+50 w192 Center', 'Latest sells:', ['s8 norm'])
latestSells := mainWindow.AddListViewEx('w192 h326 -Hdr h200 -HScroll', ['Code', 'Name'], ['s10'])
latestSells.OnEvent('Click', displayItemCode)
latestSells.Color.AlternateRows(0xFFE6E6E6)
latestSells.ModifyCol(1, 'Center ' 0)
latestSells.ModifyCol(2, 'Center ' 174)

quickResume := mainWindow.AddTextEx('Hidden cBlue w192 Center', 'Quick resume:', ['s8 norm'])
pendingBought := mainWindow.AddEditEx('Hidden w192 Center ReadOnly cRed',,, ['s12 Bold'])
pendingSold := mainWindow.AddEditEx('Hidden w192 Center ReadOnly cGreen',,, ['s12 Bold'])
pendingProfit := mainWindow.AddEditEx('Hidden w192 Center ReadOnly cGreen',,, ['s12 Bold'])
mainWindow.AddBorder([Thumb, Code128, latestSellsCount, latestSells, quickResume, pendingBought, pendingSold, pendingProfit], 20)

mainList := mainWindow.AddListViewEx('xm+240 ym+160 w980 h365 NoSortHdr -E0x200',, ['s14 norm'])
mainList.OnNotify(-3, quickListEdit)
mainList.OnEvent('ItemSelect', (*) => thumbCheck())
mainList.OnEvent('Click', (*) => thumbCheck())
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

mainWindow.AddBorder([mainList], 20)

mainList.GetPos(, &Y, &W)

priceSum := mainWindow.AddEditEx('xm+820 y' Y + 415 ' w400 Right cRed ReadOnly -Border',,, ['s35', 'Calibri'])
priceSum.GetPos(, &Y)

prevSess := mainWindow.AddButtonEx('xm+240 y' Y + 15 ' w45  Center', , ['s12 Bold'], IBGray2, 'images\buttons\prev.png')
prevSess.OnEvent('Click', (*) => prevSession())
currentSession := mainWindow.AddEditEx('xp+45 yp+4 w70 Center Number -Border', Session := 1,, ['s14 Bold'])
currentSession.OnEvent('Change', (*) => readSessionList())
currentSession.GetPos(, &Y)
nextSess := mainWindow.AddButtonEx('xp+70 y' Y - 4 ' w45  Center', , ['s12 Bold'], IBGray2, 'images\buttons\next.png')
nextSess.OnEvent('Click', (*) => nextSession())

mainWindow.AddBorder([prevSess, currentSession, nextSess, priceSum], 20)

payCheckWindow := GuiEx()
payCheckWindow.Default()
payCheckWindow.OnEvent('Close', (*) => mainWindow.Opt('-Disabled'))

commitImg := payCheckWindow.AddPicEx('xm+186', 'images\commit.png', 0)
commitMsg := payCheckWindow.AddTextEx('xm cGray w500 Center -Border', 'Commit the sell?', ['s30'])
commitAmount := payCheckWindow.AddEditEx('w500 Center cGreen ReadOnly BackgroundE6E6E6 -Border')
commitAmountPay := payCheckWindow.AddEditEx('w500 Center -Border')
commitAmountPay.OnEvent('Change', (*) => updateAmountPayBack())
commitAmountPayBack := payCheckWindow.AddEditEx('w500 Center cRed ReadOnly BackgroundE6E6E6 -Border')
commitOK := payCheckWindow.AddButtonEx('w500', 'Commit', ['s15 Bold'], IBBlack1, 'images\buttons\commit.png')
commitOK.OnEvent('Click', (*) => commitSellSubmit())
payCheckWindow.MarginY := 5
commitLater := payCheckWindow.AddButtonEx('w250', 'Commit later', ['s10'], IBBlack1, 'images\buttons\commitLater.png')
commitLater.OnEvent('Click', (*) => commitSellSubmit(1))

Invoice := payCheckWindow.AddButtonEx('xp+250 yp w250 hp Disabled', 'Invoice',, IBBlack1, 'images\buttons\invoice.png')
InvoiceLocation := payCheckWindow.AddEdit('xp yp wp hp Hidden')
Invoice.OnEvent('Click', (*) => Run('Invoice.ahk -f ' InvoiceLocation.Value))

commitCancel := payCheckWindow.AddButtonEx('xm w500 hp', 'Cancel',, IBBlack1, 'images\buttons\cancel.png')
commitCancel.OnEvent('Click', (*) => (mainWindow.Opt('-Disabled'), payCheckWindow.Hide()))

payCheckWindow.AddBorder([], 20, 10)

CommitLaterName := GuiEx()
CommitLaterName.Default()

CommitLaterName.OnEvent('Close', (*) => payCheckWindow.Opt('-Disabled'))
LaterClient := CommitLaterName.AddTextEx('w400 Center', 'Commit later for:', ['s15', 'Segoe UI'])
CommitLaterNameList := CommitLaterName.AddComboBoxEx('w400')
LaterClientOK := CommitLaterName.AddButtonEx('xm+100 w200', 'OK',, IBBlack1, 'images\buttons\commit.png')
LaterClientOK.OnEvent('Click', (*) => commitLaterSell())
CommitLaterName.AddBorder([], 20, 20)

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

quickWindow := GuiEx()
quickWindow.Default()

quickText := quickWindow.AddTextEx('w500 Center',, ['s10 Bold'])
quickEdit := quickWindow.AddEditEx('w500 Center',,, ['s18'])
quickEdit.GetPos(&X, &Y)
quickRow := quickWindow.AddEditEx('x' X ' y' Y ' w500 Hidden')
quickCol := quickWindow.AddEditEx('x' X ' y' Y ' w500 Hidden')
quickCode := quickWindow.AddEditeX('x' X ' y' Y ' w500 Hidden')
quickOK := quickWindow.AddButtonEx('w500', 'OK',, IBBlack1, 'images\buttons\commit.png')
quickOK.OnEvent('Click', (*) => quickListSubmit())
quickWindow.AddBorder([], 20, 20)

mainWindow.Show()
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
^s::QuickEditStock()
#HotIf