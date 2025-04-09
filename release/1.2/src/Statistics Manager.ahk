#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\gdip>
#Include <shared\explorertheme>
#Include <shared\lv_colors>
#Include <shared\createimagebutton>
#Include <shared\scrollbars>
#Include <inc\ui-base>
#Include <statistic>
#Include <setting>
#Include <shadow>
#Include <imagebuttons>

If A_Args.Length != 1 || A_Args[1] = '' {
	ExitApp()
}
usersetting := readJson(A_AppData '\Cash Helper\users.json')
If !usersetting.Has('Registered') || !usersetting['Registered'].Has(A_Args[1]) {
	ExitApp()
}
username := A_Args[1]

WM_USER               := 0x00000400
PBM_SETMARQUEE        := WM_USER + 10
PBM_SETSTATE          := WM_USER + 16
PBS_MARQUEE           := 0x00000008
PBS_SMOOTH            := 0x00000001
PBS_VERTICAL          := 0x00000004
PBST_NORMAL           := 0x00000001
PBST_ERROR            := 0x00000002
PBST_PAUSE            := 0x00000003
STAP_ALLOW_NONCLIENT  := 0x00000001
STAP_ALLOW_CONTROLS   := 0x00000002
STAP_ALLOW_WEBCONTENT := 0x00000004
WM_THEMECHANGED       := 0x0000031A

setting := readJson()
currency := readJson('setting\currency.json')
statistic := Map()
statistic['items'] := []
pToken := Gdip_Startup()
mainWindow := AutoHotkeyUxGui(setting['Name'], '-DPIScale Resize MinSize800x600')
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
Box1 := Shadow(mainWindow, [C1, C2])
mainWindow.SetFont('s10')
ILC_COLOR32 := 0x20 
ILC_ORIGINALSIZE := 0x00010000
IL := ImageList_Create(32, 32, ILC_COLOR32 | ILC_ORIGINALSIZE, 100, 100)
ImageList_Create(cx,cy,flags,cInitial,cGrow){
	return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow) 
} 
IL_Add(IL, 'images\filter.png')
IL_Add(IL, 'images\archived.png')
IL_Add(IL, 'images\clear.png')
IL_Add(IL, 'images\year.png')
IL_Add(IL, 'images\month.png')
IL_Add(IL, 'images\day.png')
IL_Add(IL, 'images\hour.png')
IL_Add(IL, 'images\user.png')
mainWindow.SetFont('s10 Bold')
C4 := mainWindow.AddComboBox('xm+20 ym+140 w300 Center Choose1', ['→ Sells date', '→ Submit date', '→ Year', '→ Month', '→ Day', '→ Hour', '→ Username'])
C4.OnEvent('Change', (*) => loadAll(C4.Value))
C5 := mainWindow.AddButton('xp yp wp hp Hidden Left', ' ← Go Back')
CreateImageButton(C5, 0, IBGray1*)
C5.OnEvent('Click', ShowLess)
mainWindow.SetFont('s10')
details := mainWindow.AddListView('w300 xm+20 ym+180 BackgroundWhite -Hdr -E0x200', ['Icon', 'Title'])
details.OnEvent('ItemSelect', ShowDetails)
details.SetImageList(IL, 1)
SetExplorerTheme(details.Hwnd)
details.OnEvent('DoubleClick', ShowMore)
detailsCLV := LV_Colors(details)
detailsA := mainWindow.AddListView('xp yp wp hp BackgroundWhite -Hdr -E0x200 Hidden', ['Icon', 'Title'])
detailsA.OnEvent('ItemSelect', ShowDetails)
detailsA.SetImageList(IL, 1)
SetExplorerTheme(detailsA.Hwnd)
mainWindow.SetFont('norm s12')
sellDetails := mainWindow.AddListView('xp+350 ym+140 -E0x200 Grid')
For Each, Col in setting['Sell']['Session']['03'] {
    sellDetails.InsertCol(Each, , Col)
}
sellDetailsCLV := LV_Colors(sellDetails)
SetExplorerTheme(sellDetails.Hwnd)
autoResizeCols()
mainWindow.SetFont('Bold s20')
itemsBuyValue := mainWindow.AddEdit('xp ym+600 w200 cRed -E0x200 Center', 0)
itemsSellValue := mainWindow.AddEdit('yp wp cGreen -E0x200 Center', 0)
itemsProfitValue := mainWindow.AddEdit('yp wp cGreen -E0x200 Center', 0)
;buyBar := mainWindow.AddText('BackgroundRed', 10)
;sellBar := mainWindow.AddText('BackgroundGreen', 0)
;profitBar := mainWindow.AddText('BackgroundGreen', 0)
Box4 := Shadow(mainWindow, [sellDetails])
Box3 := Shadow(mainWindow, [C4, details])
Box5 := Shadow(mainWindow, [itemsBuyValue, itemsSellValue, itemsProfitValue])
;Box6 := Shadow(mainWindow, [buyBar, sellBar, profitBar])
mainWindow.Show()
loadAll(1)