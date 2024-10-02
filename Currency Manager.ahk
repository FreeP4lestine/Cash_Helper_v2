#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\jxon>
#Include <shared\connected>
#Include <currency>
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

mainWindow := Gui('Resize MinSize800x600', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => Quit)
Quit(HGui) {
	ExitApp()
}
mainWindow.OnEvent('Size', resizeControls)
loginThumbnail := mainWindow.AddPicture('xm+20 ym+20', 'images\Currency Manager.png')
mainWindow.SetFont('s25')
C1 := mainWindow.AddText('ym+20', 'Currency Manager')
mainWindow.MarginY := 10
mainWindow.SetFont('s10 Bold', 'Calibri')
C2 := mainWindow.AddText('xm+20', '*Note: The reference currency is the Tunisian Dinar!')
mainWindow.MarginY := 2
C3 := mainWindow.AddText(, '*Exp.: ')
C4 := mainWindow.AddText('yp cRed', 'TND')
C5 := mainWindow.AddText('yp', ' = ')
FormulaResult := mainWindow.AddText('yp cBlue', '1.000')
FormulaResult.SetFont('Underline Italic')
C6 := mainWindow.AddText('yp', '  x ')
C7 := mainWindow.AddText('yp cRed', 'USD')
C8 := mainWindow.AddText('xm+20', '`t   = ')
C9 := mainWindow.AddText('yp cBlue', 'Factor')
C9.SetFont('Underline Italic')
C10 := mainWindow.AddText('yp', ' x ')
C11 := mainWindow.AddText('yp cRed', 'USD')
Box1 := Shadow(mainWindow, [loginThumbnail, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11])
mainWindow.MarginY := 20
mainWindow.SetFont('Norm s12')
mainList := mainWindow.AddListView('xm+20 w500 h400 -E0x200 -ReadOnly NoSort', ['Symbol', 'Name', 'Factor'])
Box3 := Shadow(mainWindow, [mainList])
mainList.OnEvent('Click', (*) => showCurrentCurrency())
mainList.ModifyCol(1, '100 Center')
mainList.ModifyCol(2, '200 Center')
mainList.ModifyCol(3, '195 Center')
SetExplorerTheme(mainList.Hwnd)
mainListCLV := LV_Colors(mainList)
mainWindow.SetFont('Norm s10')
C15 := mainWindow.AddText('xm+20', 'Round Values By:')
Rounder := mainWindow.AddEdit('xp+100 cBlue yp-3 w50 Number Center', setting['Rounder'])
Rounder.OnEvent('Change', (*) => updateRoundValue())
Link := mainWindow.AddLink('xp+260 yp', '<a href="https://apilayer.com/marketplace/exchangerates_data-api">Exchange Rates Data API</a>')
Link.SetFont('Bold')
mainWindow.MarginY := 10
mainList.GetPos(, &Y)
C12 := mainWindow.AddText('xm+520 y' Y, 'Symbol:')
Symbol := mainWindow.AddEdit('w300')
C13 := mainWindow.AddText(, 'Name:')
Name := mainWindow.AddEdit('w300')
C14 := mainWindow.AddText(, 'Convert Factor:')
ConvertF := mainWindow.AddEdit('w300 cBlue')
mainWindow.SetFont('Bold s12')
Default := mainWindow.AddButton('xp yp+30 w300', 'Set As Default')
Default.OnEvent('Click', (*) => setDefaultCurrency())
Update := mainWindow.AddButton('w300', 'Update')
Update.OnEvent('Click', (*) => updateCurrencies())
onlineUpdate := mainWindow.AddButton('w300', 'Auto Update')
onlineUpdate.OnEvent('Click', (*) => onlineUpdateCurrencies())
Get := mainWindow.AddButton('wp hp-10', 'Get Currencies')
Get.SetFont('Norm s10')
Get.OnEvent('Click', (*) => readSymbols())
NewAPI := mainWindow.AddButton('wp hp', 'New API Key')
NewAPI.SetFont('Norm s10')
NewAPI.OnEvent('Click', (*) => newAPIKey())
Delete := mainWindow.AddButton('wp hp', 'Delete')
Delete.SetFont('Norm s10')
Delete.OnEvent('Click', (*) => deleteCurrency())
LatestCheck := mainWindow.AddText('xp wp yp+50 cRed Center', '...')
Box2 := Shadow(mainWindow, [C12, C13, C14, Symbol, Name, ConvertF, Default, Update, onlineUpdate, Get, NewAPI, Delete])
LatestCheck.SetFont('s10')
Box4 := Shadow(mainWindow, [LatestCheck, C15, Rounder, Link])
mainWindow.MarginY := 20
mainWindow.Show('Maximize')
readCurrencies()
latestCurrencyCheck()