#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\gdip>
#Include <shared\explorertheme>
#Include <shared\lv_colors>
#Include <shared\createimagebutton>
#Include <inc\ui-base>
#Include <review>
#Include <setting>
#Include <shadow>

setting := readJson()
currency := readJson('setting\currency.json')
review := Map()
review['Pending'] := []
review['File'] := []
review['OverAll'] := [0, 0]
review['OverAllItems'] := [0, 0]
review['OverAllUser'] := [0, 0]
review['OverAllDay'] := [0, 0]
review['Pointer'] := []
review['Users'] := Map()
review['Days'] := Map()
pToken := Gdip_Startup()
mainWindow := AutoHotkeyUxGui(setting['Name'], 'Resize MinSize800x600')
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.OnEvent('Size', resizeControls)
C1 := mainWindow.AddPicture('xm+20 ym+20', 'images\Review Manager.png')
mainWindow.SetFont('s25', 'Segoe UI')
C2 := mainWindow.AddText('ym+20', 'Review Manager')
Box7 := Shadow(mainWindow, [C1, C2])
IL := IL_Create(,, True)
IL_Add(IL, 'images\pending.png')
IL_Add(IL, 'images\archived.png')
IL_Add(IL, 'images\user.png')
IL_Add(IL, 'images\users.png')
IL_Add(IL, 'images\day.png')
mainWindow.SetFont('Bold s10')
C5 := mainWindow.AddText('xm+20 ym+140 w250 Center', 'Users:')
mainWindow.SetFont('norm')
usersList := mainWindow.AddListMenu('wp LV0x40 cBlue h100 BackgroundWhite', ['Users'])
Box5 := Shadow(mainWindow, [C5, usersList])
usersList.SetImageList(IL, 0)
usersList.OnEvent('ItemSelect', displayUserSellsFunc)
displayUserSellsFunc(Ctrl, Item, Selected) {
    If !Item || !Selected {
        Return
    }
    User := usersList.GetText(Item)
    loadPendingSells(1, User)
}
usersList.Add('Icon4 Select Focus', 'Everyone')
mainWindow.SetFont('Bold s10')
C6 := mainWindow.AddText('xm+20 ym+310 w250 Center', 'Days:')
mainWindow.SetFont('norm')
daysList := mainWindow.AddListMenu('wp LV0x40 h150 BackgroundWhite', ['Days'])
daysList.SetImageList(IL, 0)
daysList.OnEvent('ItemSelect', displayDateSellsFunc)
displayDateSellsFunc(Ctrl, Item, Selected) {
    If !Item || !Selected {
        Return
    }
    Day := daysList.GetText(Item)
    loadPendingSells(2,, Day)
}
Box8 := Shadow(mainWindow, [C6, daysList])
mainWindow.SetFont('s10 Bold')
openTime := mainWindow.AddEdit('xm+630 ym+140 w425 Left ReadOnly BackgroundWhite -E0x200')
commitTime := mainWindow.AddEdit('xm+755 ym+140 w425 Right ReadOnly BackgroundWhite -E0x200')
box6 := Shadow(mainWindow, [openTime, commitTime])
nonSubmittedTxt := mainWindow.AddText('xm+325 ym+140 w250 cred Center', 'Non reviewed sells')
mainWindow.SetFont('norm')
nonSubmittedPB := mainWindow.AddProgress('wp h18 Hidden -Smooth')
nonSubmitted := mainWindow.AddListMenu('wp LV0x40 BackgroundF0F0F0 Multi h424', ['Not Submitted'])
nonSubmitted.SetImageList(IL, 0)
Box1 := Shadow(mainWindow, [nonSubmitted, nonSubmittedPB, nonSubmittedTxt])
mainWindow.SetFont('s12')
details := mainWindow.AddListView('xm+630 ym+210 w850 h180 NoSortHdr -E0x200')
nonSubmitted.OnEvent('ItemSelect', displayDetailsFunc)
displayDetailsFunc(Ctrl, Item, Selected) {
    If !Item {
        Return
    }
    displayDetails()
}
For Each, Col in setting['Sell']['Session']['03'] {
    details.InsertCol(Each, , Col)
}
SetExplorerTheme(details.Hwnd)
detailsCLV := LV_Colors(details)
autoResizeCols()
Box2 := Shadow(mainWindow, [details])
mainWindow.SetFont('s10')
overAllUser := mainWindow.AddText('xm+630 ym+420', 'Current user summary: ( 0 )')
mainWindow.SetFont('norm s12')
totalUserBuyValue := mainWindow.AddEdit('w280 Center -E0x200 BackgroundWhite ReadOnly cRed', 0)
totalUserSellValue := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
totalUserProfitValue := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
mainWindow.SetFont('s10')
overAllItem := mainWindow.AddText('xm+630 ym+470', 'Selection summary: ( 0 )')
mainWindow.SetFont('norm s15')
itemsBuyValue := mainWindow.AddEdit('w280 Center -E0x200 BackgroundWhite ReadOnly cRed', 0)
itemsSellValue := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
itemsProfitValue := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
mainWindow.SetFont('s10 Bold')
overAllTotal := mainWindow.AddText('xm+630 ym+520', 'Overall Summary:')
mainWindow.SetFont('s20')
totalBuyValue := mainWindow.AddEdit('w280 Center -E0x200 BackgroundWhite ReadOnly cRed', 0)
totalSellValue := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
totalProfitValue := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
Box3 := Shadow(mainWindow, [overAllItem, itemsBuyValue, itemsSellValue, itemsProfitValue
                          , overallUser, totalUserBuyValue, totalUserSellValue, totalUserProfitValue
                          , overAllTotal, totalBuyValue, totalSellValue, totalProfitValue])
mainWindow.SetFont('s12 norm')
submit := mainWindow.AddButton('xm+325 ym+640 w250', 'Clear!')
submit.OnEvent('Click', (*) => clearSells())
submit.SetFont('Bold')
CreateImageButton(submit, 0, [[0xFFFFFFFF,, 0xFF008000, 5, 0xFF008000], [0xFF009F00,, 0xFFFFFFFF], [0xFF00BB00,, 0xFFFFFF00]]*)
Box4 := Shadow(mainWindow, [submit])
mainWindow.Show()
loadPendingSells(0)