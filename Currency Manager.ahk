#Requires AutoHotkey v2
#SingleInstance Force

#Include <Gdip_All>
#Include <Imaging>
#Include <Setting>
#Include <LV_Colors>
#Include <SetExplorerTheme>
#Include <_JXON>
#Include <ConnectedToInternet>
#Include <Currency>

appSetting := Setting()
appImage := Imaging()
appCurrency := Currency()

appImage.loadAppImages()
appCurrency.getSellCurrency()

mainWindow := Gui('', appSetting.Title)
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
loginThumbnail := mainWindow.AddPicture(, appImage.Picture['Currency Manager'])
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Currency Manager')
mainWindow.MarginY := 10
mainWindow.SetFont('s10 Bold', 'Calibri')
mainWindow.AddText('xm', '*Note: The reference currency is the Tunisian Dinar!')
mainWindow.MarginY := 2
mainWindow.AddText(, '*Exp.: ')
mainWindow.AddText('yp cRed', 'TND')
mainWindow.AddText('yp', ' = ')
FormulaResult := mainWindow.AddText('yp cBlue', '0.000')
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
mainList.OnEvent('Click', showCurrentCurrency)
showCurrentCurrency(Ctrl, Row) {
    Currency := Ctrl.GetText(Row)
    appCurrency.showCurrentCurrency(Currency)
}
mainList.ModifyCol(1, '100 Center')
mainList.ModifyCol(2, '200 Center')
mainList.ModifyCol(3, '195 Center')
SetExplorerTheme(mainList.Hwnd)
mainListCLV := LV_Colors(mainList)
mainWindow.SetFont('Norm s10')
mainWindow.AddText(, 'Round Values By:')
Rounder := mainWindow.AddEdit('xp+100 cBlue yp-3 w100 Number')
Rounder.OnEvent('Change', (*) => appCurrency.updateRoundValue())
mainWindow.MarginY := 10
mainList.GetPos(, &Y)
mainWindow.AddText('xm+520 y' Y, 'Symbol:')
Symbol := mainWindow.AddEdit('w300')
mainWindow.AddText(, 'Name:')
Name := mainWindow.AddEdit('w300')
mainWindow.AddText(, 'Convert Factor:')
ConvertF := mainWindow.AddEdit('w300 cBlue')
mainWindow.SetFont('Bold s12')
Default := mainWindow.AddButton('xp yp+60 w300', 'Set As Default')
Default.OnEvent('Click', (*) => appCurrency.setDefaultCurrency())
Update := mainWindow.AddButton('w300', 'Update')
Update.OnEvent('Click', (*) => appCurrency.updateCurrencies())
onlineUpdate := mainWindow.AddButton('w300', 'Auto Update')
onlineUpdate.OnEvent('Click', onlineUpdateCurrencies)
onlineUpdateCurrencies(Ctrl, Info) {
    Ctrl.Enabled := False
    appCurrency.onlineUpdateCurrencies()
    Ctrl.Enabled := True
}
NewAPI := mainWindow.AddButton('wp hp-10', 'New API Key')
NewAPI.SetFont('Norm s10')
NewAPI.OnEvent('Click', (*) => appCurrency.newAPIKey())
Delete := mainWindow.AddButton('wp hp', 'Delete')
Delete.SetFont('Norm s10')
Delete.OnEvent('Click', (*) => appCurrency.deleteCurrencies())
LatestCheck := mainWindow.AddText('xm w820 cRED Center', '...')
LatestCheck.SetFont('s10')
mainWindow.MarginY := 20
mainWindow.Show()

appCurrency.List4 := mainList
appCurrency.List4CLV := mainListCLV
appCurrency.FormulaResult := FormulaResult
appCurrency.Symbol := Symbol
appCurrency.Name := Name
appCurrency.ConvertF := ConvertF

appCurrency.readCurrencies()
appCurrency.latestCurrencyCheck()