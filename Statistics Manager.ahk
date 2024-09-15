#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\gdip>
#Include <shared\explorertheme>
#Include <shared\lv_colors>
#Include <shared\createimagebutton>
#Include <inc\ui-base>
#Include <statistic>
#Include <setting>
#Include <shadow>

setting := readJson()
currency := readJson('setting\currency.json')
review := Map()
review['Users'] := Map()
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
C1 := mainWindow.AddPicture('xm+20 ym+20', 'images\Statistics Manager.png')
mainWindow.SetFont('s25', 'Segoe UI')
C2 := mainWindow.AddText('ym+20', 'Statistics Manager')
Box7 := Shadow(mainWindow, [C1, C2])
IL := IL_Create(,, True)
IL_Add(IL, 'images\pending.png')
IL_Add(IL, 'images\archived.png')
mainWindow.SetFont('Bold s10')
C5 := mainWindow.AddText('xm+20 ym+140 w250 Center', 'Users')
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
    displayUserSells(User)
}
usersList.ModifyCol(1, 'Center')
usersList.AutoSize(2)
mainWindow.SetFont('s10 Bold')
openTime := mainWindow.AddEdit('xm+330 ym+140 w425 Left ReadOnly BackgroundWhite -E0x200')
commitTime := mainWindow.AddEdit('xm+755 ym+140 w425 Right ReadOnly BackgroundWhite -E0x200')
box6 := Shadow(mainWindow, [openTime, commitTime])
nonSubmittedTxt := mainWindow.AddText('xm+20 ym+300 w250 cred Center', 'Non reviewed sells')
mainWindow.SetFont('norm')
nonSubmitted := mainWindow.AddListMenu('wp LV0x40 BackgroundF0F0F0 Multi h424', ['Not Submitted'])
nonSubmitted.SetImageList(IL, 0)
Box1 := Shadow(mainWindow, [nonSubmitted, nonSubmittedTxt])
mainWindow.SetFont('s12')
details := mainWindow.AddListView('xm+330 ym+210 w850 h180 NoSortHdr -E0x200')
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
overallUser := mainWindow.AddText('xm+330 ym+420', 'Current user summary: ( 0 )')
mainWindow.SetFont('norm s12')
BoughtUser := mainWindow.AddEdit('w280 Center -E0x200 BackgroundWhite ReadOnly cRed', 0)
SoldUser := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
ProfitUser := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
mainWindow.SetFont('s10')
overall := mainWindow.AddText('xm+330 ym+470', 'Selection summary: ( 0 )')
mainWindow.SetFont('norm s15')
Bought := mainWindow.AddEdit('w280 Center -E0x200 BackgroundWhite ReadOnly cRed', 0)
Sold := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
Profit := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
mainWindow.SetFont('s10 Bold')
overallTotal := mainWindow.AddText('xm+330 ym+520', 'Overall Summary:')
mainWindow.SetFont('s20')
BoughtTotal := mainWindow.AddEdit('w280 Center -E0x200 BackgroundWhite ReadOnly cRed', 0)
SoldTotal := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
ProfitTotal := mainWindow.AddEdit('yp w280 Center -E0x200 BackgroundWhite ReadOnly cGreen', 0)
Box3 := Shadow(mainWindow, [overall, Bought, Sold, Profit
                          , overallUser, BoughtUser, SoldUser, ProfitUser
                          , overallTotal, BoughtTotal, SoldTotal, ProfitTotal])
mainWindow.Show()
loadNonSubmitted()