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
currency := readJson('setting\currency.json')
Sells := readJson('setting\sessions\sessions.json')

mainWindow := Gui('', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.AddPicture(, 'images\Sell Manager.png')
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Sell Manager')
mainWindow.MarginY := 10

mainWindow.SetFont('s8 norm')
;mainWindow.MarginY := 16
mainWindow.AddText('xm ym+100', 'Custom Quantity:')
mainWindow.SetFont('s14')
CQuantity := mainWindow.AddEdit('w192 Center')
mainWindow.SetFont('s8 norm')
mainWindow.AddText(, 'Custom Price:')
mainWindow.SetFont('s14')
CPrice := mainWindow.AddEdit('w192 cRed Center')
mainWindow.SetFont('s8 norm')
mainWindow.AddText(, 'Custom Item Price:')
mainWindow.SetFont('s14')
CItemPrice := mainWindow.AddEdit('w192 cRed Center')
mainWindow.SetFont('s8 norm')
mainWindow.AddText(, 'Latest sells:')
mainWindow.SetFont('s14')
latestSells := mainWindow.AddListView('-E0x200 w192 h320 Center Border -Hdr', ['Code', 'Name'])
SetExplorerTheme(latestSells.Hwnd)
latestSells.ModifyCol(1, 0)
latestSells.ModifyCol(2, 188)
mainWindow.SetFont('s14 norm')
mainWindow.MarginY := 10
mainList := mainWindow.AddListView('xm+200 ym+100 w980 h540 NoSortHdr')
mainList.OnEvent('Click', (*) => showCustoms())
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

mainList.GetPos(, &Y, &W)
mainWindow.SetFont('s18')
enteredCode := mainWindow.AddEdit('xm+' (W - 500 + 200) ' yp-45 w500 Center c0000ff')
EM_SETCUEBANNER(enteredCode.Hwnd, 'Code')
enteredCode.OnEvent('Change', (*) => analyzeCode())
mainWindow.SetFont('s40')
priceSum := mainWindow.AddEdit('xm+400 w780 -E0x200 Right cRed ReadOnly BackgroundWhite')
priceSum.SetFont('', 'Calibri')
mainWindow.SetFont('s10')
prevSess := mainWindow.AddButton('xp-200 yp-10 w50 h25 Center', 'Prev')
prevSess.OnEvent('Click', (*) => prevSession())
mainWindow.SetFont('s14')
Session := 1
currentSession := mainWindow.AddEdit('xp+50 yp w50 h25 Center Number -E0x200', 1)
currentSession.OnEvent('Change', (*) => readSessionList())
mainWindow.SetFont('s10')
nextSess := mainWindow.AddButton('xp+50 yp w50 h25 Center', 'Next')
nextSess.OnEvent('Click', (*) => nextSession())
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
readSessionList()
SetTimer(saveSessions, setting['SessAutoSave'])
enteredCode.Focus()
mainList.Redraw()

#HotIf enteredCode.Focused
Enter::addItemToList()
#HotIf

#HotIf mainList.Focused
Up::IncreaseQ()
Down::DecreaseQ()
#HotIf

#HotIf CQuantity.Focused
Enter::submitCustomQuantity()
#HotIf

#HotIf CPrice.Focused
Enter::submitCustomPrice()
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
#HotIf