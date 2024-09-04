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

#Include <setting>
#Include <sell>

setting := readJson()

mainWindow := Gui('', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.AddPicture(, 'iamges\Sell Manager.png')
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Sell Manager')
mainWindow.MarginY := 10

mainWindow.SetFont('s10 norm')
;mainWindow.MarginY := 16
latestSells := mainWindow.AddListView('xm ym+100 -E0x200 w192 h500 Center Grid -Hdr', ['Code', 'Name'])
SetExplorerTheme(latestSells.Hwnd)
latestSells.ModifyCol(1, 0)
latestSells.ModifyCol(2, 188)
mainWindow.SetFont('s14')
mainWindow.MarginY := 10
mainList := mainWindow.AddListView('xm+200 ym+100 w1000 h500 Grid NoSortHdr', ['Flag', 'Code', 'Name', 'Sell Amount', 'Unit', 'Sell Value', 'Added Value', 'Price', 'CUR'])
;SetExplorerTheme(mainList.Hwnd)
mainListCLV := LV_Colors(mainList)
mainListCLV.SelectionColors(0xFFACD6FF)
mainList.ModifyCol(1, 10)
Loop C := mainList.GetCount('Col') - 2 {
    mainList.ModifyCol(A_Index + 1, 1000 / C - 12 ' Center')
}
mainList.ModifyCol(9, 60 ' Center')
mainList.OnNotify(-176, updatePrice)
updatePrice(List, L) {
    Critical -1
    OffText := 16 + (A_PtrSize * 4)
    Row := NumGet(L + (A_PtrSize * 3), 4, "Int")
    ItemText := ''
    If (TxtPtr := NumGet(L, OffText, "UPtr")) {
    	ItemText := StrGet(TxtPtr)
    	updateQuantityPrice(Row + 1, ItemText)
    }
}
mainList.GetPos(, &Y, &W)
mainWindow.SetFont('s18')
enteredCode := mainWindow.AddEdit('xm+' (W - 500 + 200) ' yp-45 w500 Center c0000ff')
EM_SETCUEBANNER(enteredCode.Hwnd, 'Code')
enteredCode.OnEvent('Change', codeChange)
codeChange(Ctrl, Info) {
    analyzeCode(Ctrl.Value)
}
mainWindow.SetFont('s40')
priceSum :=  mainWindow.AddEdit('xm+400 w800 -E0x200 Right cRed ReadOnly BackgroundWhite')
priceSum.SetFont('', 'Calibri')
mainWindow.SetFont('s10')
mainWindow.AddButton('xp-200 yp-10 w50 h25 Center', 'Prev').OnEvent('Click', (*) => prevSession())
mainWindow.SetFont('s14')
currentSession := mainWindow.AddEdit('xp+50 yp w50 h25 Center Number -E0x200', 1)
mainWindow.SetFont('s10')
mainWindow.AddButton('xp+50 yp w50 h25 Center', 'Next').OnEvent('Click', (*) => nextSession())
mainWindow.MarginY := 20

payCheckWindow := Gui('', setting['Name'])
payCheckWindow.BackColor := 'White'
payCheckWindow.MarginX := 20
payCheckWindow.MarginY := 20
payCheckWindow.SetFont('s30 Bold')
commitMsg := payCheckWindow.AddText('cGray w500 Center', 'Commit the sell?')
commitAmount := payCheckWindow.AddEdit('w500 Center cGreen ReadOnly BackgroundE6E6E6 -E0x200')
commitAmountPay := payCheckWindow.AddEdit('w500 Center BackgroundWhite -E0x200 Border')
commitAmountPay.OnEvent('Change', (*) => updateAmountPayBack())
commitAmountPayBack := payCheckWindow.AddEdit('w500 Center cRed ReadOnly BackgroundE6E6E6 -E0x200')
payCheckWindow.SetFont('s15 norm')
commitOK := payCheckWindow.AddButton('w500 hp', 'Commit')
commitOK.OnEvent('Click', (*) => commitSellSubmit())
commitOK.SetFont('Bold')
payCheckWindow.MarginY := 5
commitCancel := payCheckWindow.AddButton('w500 hp-20', 'Cancel')
commitCancel.OnEvent('Click', (*) => payCheckWindow.Hide())
commitCancel.SetFont('s10')
commitLater := payCheckWindow.AddButton('w500 hp', 'Commit later')
commitLater.SetFont('s10')
payCheckWindow.MarginY := 20

OptionMenu := Menu()
OptionMenu.Add('Exit', (*) => ExitApp())
OptionMenu.Add('Commit', (*) => ExitApp())
OptionMenu.Add('Quick resume', (*) => ExitApp())
OptionMenu.Add('Add item to the list', (*) => ExitApp())
OptionMenu.Add('Increase item amount in the list', (*) => ExitApp())
OptionMenu.Add('Decrease item amount in the list', (*) => ExitApp())
OptionMenu.Add('Delete item from the sell list', (*) => ExitApp())
OptionMenu.Add('Switch to the next session', (*) => ExitApp())
OptionMenu.Add('Switch to the previous session', (*) => ExitApp())
Menus := MenuBar()
Menus.Add('Options', OptionMenu)
mainWindow.MenuBar := Menus
mainWindow.Show()

#HotIf WinActive(mainWindow) && enteredCode.Focused
Enter::addItemToList()
#HotIf

#HotIf WinActive(payCheckWindow)
Enter::commitSellSubmit()
#HotIf

#HotIf WinActive(mainWindow)
^Enter::commitSell()
Delete::removeItemFromList()
Left::prevSession()
Right::nextSession()
#HotIf