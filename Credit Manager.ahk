#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\gdip>
#Include <credit>
#Include <setting>
#Include <shared\createimagebutton>
#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <imagebuttons>
#Include <shadow>
#Include <inc\ui-base>

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
names := Map()

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
GoBack := mainWindow.AddButton('xm w220 Hidden', ' ← ')
GoBack.OnEvent('Click', ReturnMainList)
CreateImageButton(GoBack, 0, IBBlack1*)

mainWindow.MarginY := 10
mainWindow.SetFont('s12')

CommitLaterList := mainWindow.AddListView('wp r10 -E0x200 -Hdr', ['Names'])
CommitLaterList.OnEvent('DoubleClick', ShowNameSells)
CommitLaterList.OnEvent('ItemSelect', ShowNameResume)
mainWindow.SetFont('s10')
CommitLaterListZoom := mainWindow.AddListView('xp yp wp hp r10 -E0x200 Hidden NoSortHdr', ['Sells', 'Amount'])
CommitLaterListZoomCLV := LV_Colors(CommitLaterListZoom)
CommitLaterListZoomCLV.SelectionColors(, 0xFF000000)
CommitLaterListZoom.OnEvent('ItemSelect', CashoutInfo)
mainWindow.SetFont('Bold')
Clearout := mainWindow.AddButton('wp', 'Clear out')
Clearout.OnEvent('Click', ClearName)
CreateImageButton(Clearout, 0, IBRed1*)
CommitListBox := Shadow(mainWindow, [GoBack, CommitLaterList, CommitLaterListZoom, Clearout])
ILC_COLOR32 := 0x20 
ILC_ORIGINALSIZE := 0x00010000
IL := ImageList_Create(32, 32, ILC_COLOR32 | ILC_ORIGINALSIZE, 100, 100)
ImageList_Create(cx, cy, flags, cInitial, cGrow){
	return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow) 
} 
IL_Add(IL, 'images\user.png')
IL_Add(IL, 'images\pending.png')
IL_Add(IL, 'images\archived.png')
CommitLaterList.SetImageList(IL, 1)
CommitLaterListZoom.SetImageList(IL, 1)
SetExplorerTheme(CommitLaterList.Hwnd)
SetExplorerTheme(CommitLaterListZoom.Hwnd)

mainWindow.SetFont('norm s12')

DetailsList := mainWindow.AddListView('xm+275 ym+140 -E0x200 BackgroundF0F0F0')
DetailsListCLV := LV_Colors(DetailsList)
For Each, Col in setting['Sell']['Session']['03'] {
    DetailsList.InsertCol(Each, , Col)
}
CashoutProgress := mainWindow.AddProgress('h15 -Smooth')
DetailsBox := Shadow(mainWindow, [CashoutProgress, DetailsList])

DetailsList.GetPos(&X, &Y, &Width)
mainWindow.SetFont('s10')
CommitPaybackHistory := mainWindow.AddListView('-E0x200 w240 x' X + Width + 40 ' y' Y ' NoSortHdr', ['Date', 'Amount'])
CommitPaybackHistoryCLV := LV_Colors(CommitPaybackHistory)
CommitPaybackHistoryCLV.SelectionColors(, 0xFF000000)
SetExplorerTheme(CommitPaybackHistory.Hwnd)
mainWindow.SetFont('Bold s14')
CommitPaybackValue := mainWindow.AddEdit('-E0x200 w240 ReadOnly cGreen Center BackgroundWhite', '-')
CommitPaybackHistoryBox := Shadow(mainWindow, [CommitPaybackHistory, CommitPaybackValue])
CommitPaybackHistory.SetImageList(IL, 1)

mainWindow.SetFont('s10')
TotalAmountText := mainWindow.AddText('xm Center', 'Total')
mainWindow.SetFont('s14')
TotalAmount 	:= mainWindow.AddEdit('-E0x200 BackgroundFFFFFF ReadOnly Center cRed', '-')

mainWindow.SetFont('s10')
PaidAmountText 	:= mainWindow.AddText('Center', 'Paid Amount')
mainWindow.SetFont('s14')
PaidAmount 		:= mainWindow.AddEdit('-E0x200 BackgroundFFFFFF ReadOnly Center cGreen', '-')

mainWindow.SetFont('s10')
LeftAmountText 	:= mainWindow.AddText('Center', 'Left Amount')
mainWindow.SetFont('s14')
LeftAmount 		:= mainWindow.AddEdit('-E0x200 BackgroundFFFFFF ReadOnly Center cRed', '-')

ResumeBox := Shadow(mainWindow, [TotalAmountText, TotalAmount, PaidAmountText, PaidAmount, LeftAmountText, LeftAmount])

payCheckWindow := Gui('', setting['Name'])
payCheckWindow.BackColor := 'White'
payCheckWindow.OnEvent('Close', (*) => (mainWindow.Opt('-Disabled'), SetTimer(commitClose, 0)))
payCheckWindow.MarginX := 20
payCheckWindow.MarginY := 20
payCheckWindow.SetFont('s30')
commitImg := payCheckWindow.AddPicture('xm+186', 'images\commitoff.png')
commitMsg := payCheckWindow.AddText('xm cGray w500 Center', 'Enter payback amount')
commitAmount := payCheckWindow.AddEdit('w500 Center cGreen ReadOnly BackgroundE6E6E6 -E0x200')
commitAmountPay := payCheckWindow.AddEdit('w500 Center BackgroundWhite -E0x200 Border')
commitAmountPay.OnEvent('Change', (*) => updateAmountPayBack())
commitAmountPayBack := payCheckWindow.AddEdit('w500 Center cRed ReadOnly BackgroundE6E6E6 -E0x200')
payCheckWindow.SetFont('s15 norm')
commitOK := payCheckWindow.AddButton('w500 hp', 'Commit')
commitOK.OnEvent('Click', (*) => commitCheckout())
commitOK.SetFont('Bold')
payCheckWindow.MarginY := 5

Invoice := payCheckWindow.AddButton('w500 hp-20', 'Invoice')
;commitLater.OnEvent('Click', (*) => commitSellSubmit(1))
Invoice.SetFont('s10')

commitCancel := payCheckWindow.AddButton('xm w500 hp', 'Cancel')
commitCancel.OnEvent('Click', (*) => (mainWindow.Opt('-Disabled'), payCheckWindow.Hide()))
commitCancel.SetFont('s10')

mainWindow.Show('Maximize')
LoadCommitLaterNames()
autoResizeCols()

#HotIf WinActive(mainWindow) && CommitLaterListZoom.GetNext() && CashoutProgress.Value < 100
	Space::enterCheckout()
#HotIf

#HotIf WinActive(payCheckWindow)
	Enter::commitCheckout()
#HotIf