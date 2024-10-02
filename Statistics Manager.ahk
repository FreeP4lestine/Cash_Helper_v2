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
currency := readJson('setting\currency.json')
statistic := Map()
statistic['clears'] := Map()
statistic['year'] := Map()
statistic['month'] := Map()
statistic['day'] := Map()
statistic['user'] := Map()
statistic['hour'] := Map()
statistic['items'] := Map()
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
Box1 := Shadow(mainWindow, [C1, C2])
mainWindow.SetFont('s10')
;C3 := mainWindow.AddText('xm+20 ym+140 cBlue w200 Center', 'Filters:')
;mainWindow.SetFont('s12')
;IL := IL_Create(,, True)
;IL_Add(IL, 'images\filter.png')
;IL_Add(IL, 'images\archived.png')
;IL_Add(IL, 'images\user.png')
;IL_Add(IL, 'images\clear.png')
;IL_Add(IL, 'images\year.png')
;IL_Add(IL, 'images\month.png')
;IL_Add(IL, 'images\day.png')
;IL_Add(IL, 'images\hour.png')
;IL_Add(IL, 'images\get.png')
;IL_Add(IL, 'images\give.png')
;IL_Add(IL, 'images\amount.png')
;filtersList := mainWindow.AddListMenu('w200 BackgroundWhite', ['Filter'])
;filtersList.OnEvent('Click', (*) => displayFiltersDetails())
;filtersList.SetImageList(IL, 0)
;filtersList.Add('Icon4', 'Clears')
;filtersList.Add('Icon5', 'Year')
;filtersList.Add('Icon6', 'Month')
;filtersList.Add('Icon7', 'Day')
;filtersList.Add('Icon3', 'User')
;filtersList.Add('Icon8', 'Hour')
;filtersList.Add('Icon10', 'Costs')
;filtersList.Add('Icon9', 'Sells')
;filtersList.Add('Icon9', 'Profits')
;filtersList.Add('Icon11', 'Sell Amount')
;Box2 := Shadow(mainWindow, [C3, filtersList])
;mainWindow.SetFont('s10')
C4 := mainWindow.AddText('xm+20 ym+140 cBlue', 'Details:')
;filteredList := mainWindow.AddListMenu('w300 BackgroundWhite', ['Filtered'])
;filteredList.SetImageList(IL, 0)
;filteredList.OnEvent('Click', (*) => displayDetails())
mainWindow.SetFont('s12')
details := mainWindow.AddListView('xm+20 ym+180 -E0x200')
For Each, Col in setting['Extra'] {
    details.InsertCol(Each,, Col)
	Ind := Each
}
For Each, Col in setting['Sell']['Session']['03'] {
    details.InsertCol(Ind + Each,, Col)
}
SetExplorerTheme(details.Hwnd)
detailsCLV := LV_Colors(details)
autoResizeCols()
Box3 := Shadow(mainWindow, [C4, details])
mainWindow.Show('Maximize')
loadAll()
;loadFilters()