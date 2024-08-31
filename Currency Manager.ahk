#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\jxon>
#Include <shared\connected>
#Include <currency>
#Include <setting>

setting := readJson()

mainWindow := Gui('', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
loginThumbnail := mainWindow.AddPicture(, 'images\Currency Manager.png')
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Currency Manager')
mainWindow.MarginY := 10
mainWindow.SetFont('s10 Bold', 'Calibri')
mainWindow.AddText('xm', '*Note: The reference currency is the Tunisian Dinar!')
mainWindow.MarginY := 2
mainWindow.AddText(, '*Exp.: ')
mainWindow.AddText('yp cRed', 'TND')
mainWindow.AddText('yp', ' = ')
FormulaResult := mainWindow.AddText('yp cBlue', '1.000')
FormulaResult.SetFont('Underline Italic')
mainWindow.AddText('yp', '  x ')
mainWindow.AddText('yp cRed', 'USD')
mainWindow.AddText('xm', '`t   = ')
mainWindow.AddText('yp cBlue', 'Factor').SetFont('Underline Italic')
mainWindow.AddText('yp', ' x ')
mainWindow.AddText('yp cRed', 'USD')
mainWindow.MarginY := 20
mainWindow.SetFont('Norm s12')
mainList := mainWindow.AddListView('xm w500 h400 -ReadOnly NoSort', ['Symbol', 'Name', 'Factor'])
mainList.OnEvent('Click', (*) => showCurrentCurrency())
mainList.ModifyCol(1, '100 Center')
mainList.ModifyCol(2, '200 Center')
mainList.ModifyCol(3, '195 Center')
SetExplorerTheme(mainList.Hwnd)
mainListCLV := LV_Colors(mainList)
mainWindow.SetFont('Norm s10')
mainWindow.AddText(, 'Round Values By:')
Rounder := mainWindow.AddEdit('xp+100 cBlue yp-3 w50 Number Center', setting['Rounder'])
Rounder.OnEvent('Change', (*) => updateRoundValue())
mainWindow.AddLink('xp+260 yp', '<a href="https://apilayer.com/marketplace/exchangerates_data-api">Exchange Rates Data API</a>').SetFont('Bold')
mainWindow.MarginY := 10
mainList.GetPos(, &Y)
mainWindow.AddText('xm+520 y' Y, 'Symbol:')
Symbol := mainWindow.AddEdit('w300')
mainWindow.AddText(, 'Name:')
Name := mainWindow.AddEdit('w300')
mainWindow.AddText(, 'Convert Factor:')
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
LatestCheck := mainWindow.AddText('xp wp yp+50 cRed Right', '...')
LatestCheck.SetFont('s10')
mainWindow.MarginY := 20
mainWindow.Show()
readCurrencies()
latestCurrencyCheck()