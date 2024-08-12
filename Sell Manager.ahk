#Requires AutoHotkey v2
#SingleInstance Force

#Include <Gdip_All>
#Include <Imaging>
#Include <CreateImageButton>
#Include <LV_Colors>
#Include <SetExplorerTheme>
#Include <InCellEdit>
#Include <SetCueBanner>

#Include <Setting>
#Include <Sell>

appSetting := Setting()
appSell := Sell()
appImage := Imaging()
appImage.loadAppImages()

mainWindow := Gui('', appSetting.Title)
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.AddPicture(, appImage.Picture['Sell Manager'])
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Sell Manager')
mainWindow.MarginY := 10

mainWindow.SetFont('s14 Bold')
commitSell := mainWindow.AddButton('xm ym+100 w190', 'Commit')
addItem := mainWindow.AddButton('wp hp-15', 'Add to the list')
addItem.SetFont('s10 norm')
mainWindow.MarginY := 5
removeItem := mainWindow.AddButton('wp hp', 'Remove from the list')
removeItem.SetFont('s10 norm')
increaseItem := mainWindow.AddButton('wp hp', 'Increase amount')
increaseItem.SetFont('s10 norm')
deacreaseItem := mainWindow.AddButton('wp hp', 'Decrease amount')
deacreaseItem.SetFont('s10 norm')
chooseCurrency := mainWindow.AddButton('wp hp', 'Currency')
chooseCurrency.SetFont('s10 norm')
sellResume := mainWindow.AddButton('wp hp', 'Quick sell resume')
sellResume.SetFont('s10 norm')
mainWindow.SetFont('s10 norm')
mainWindow.MarginY := 16
latestSells := mainWindow.AddListView('wp r12 -E0x200 Center -Hdr', ['Code', 'Name'])
SetExplorerTheme(latestSells.Hwnd)
latestSells.ModifyCol(1, 0)
latestSells.ModifyCol(2, 188)
mainWindow.SetFont('s14')
mainWindow.MarginY := 10
mainList := mainWindow.AddListView('xm+200 ym+100 w1000 h500 ReadOnly NoSortHdr', ['Flag', 'Code', 'Name', 'Sell Method', 'Sell Amount', 'Sell Value', 'Price', 'CUR'])
SetExplorerTheme(mainList.Hwnd)
IgnoreCell := {Row: Map(), Col: Map(1, 1, 2, 1, 3, 1, 4, 1, 6, 1, 7, 1, 8, 1)}
InCellEdit(mainList, IgnoreCell)
mainListCLV := LV_Colors(mainList)
mainList.ModifyCol(1, 10)
Loop C := mainList.GetCount('Col') - 2 {
    mainList.ModifyCol(A_Index + 1, 1000 / C - 13 ' Center')
}
mainList.ModifyCol(8, 60 ' Center')
mainList.OnNotify(-176, updatePrice)
updatePrice(List, L) {
    Critical -1
    OffText := 16 + (A_PtrSize * 4)
    Row := NumGet(L + (A_PtrSize * 3), 4, "Int")
    ItemText := ''
    If (TxtPtr := NumGet(L, OffText, "UPtr")) {
    	ItemText := StrGet(TxtPtr)
    	appSell.updateQuantityPrice(Row + 1, ItemText)
    }
}
mainList.GetPos(, &Y, &W)
mainWindow.SetFont('s18')
enteredCode := mainWindow.AddEdit('xm+' (W - 500 + 200) ' yp-45 w500 Center cBlue')
EM_SETCUEBANNER(enteredCode.Hwnd, 'Code')
enteredCode.OnEvent('Change', analyzeCode)
analyzeCode(Ctrl, Info) {
    appSell.analyzeCode(Ctrl.Value)
}
mainWindow.SetFont('s40')
priceSum :=  mainWindow.AddEdit('xm+400 w800 -E0x200 Right cRed ReadOnly BackgroundWhite')
priceSum.SetFont('', 'Calibri')
mainWindow.MarginY := 20

mainWindow.Show()
appSell.getPropertiesNames()
appSell.getSellCurrency()
appSell.getSellMethods()
appSell.updatePriceSum()

#HotIf WinActive(mainWindow) && enteredCode.Focused
Enter::appSell.addItemToList()
#HotIf

#HotIf WinActive(mainWindow)
Delete::appSell.removeItemFromList()
#HotIf