#Requires AutoHotkey v2
#SingleInstance Force

#Include <Gdip_All>
#Include <Imaging>
#Include <BarCoder>
#Include <CreateImageButton>
#Include <LV_Colors>
#Include <SetExplorerTheme>
#Include <_JXON>
#Include <InCellEdit>

#Include <Setting>
#Include <Stock>

appSetting := Setting()
appImage := Imaging()
appStock := Stock()

appStock.getPropertiesNames()
appStock.getSellMethods()
appStock.getSellCurrency()
appImage.loadAppImages()

mainWindow := Gui('', appSetting.Title)
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.AddPicture(, appImage.Picture['Stock Manager'])
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Stock Manager')
mainWindow.SetFont('s10')

Thumb := mainWindow.AddPicture('xm+93 ym+80 w64 h64', 'images\Default.png')
itemForms := mainWindow.AddListView('xm ym+161 w250 h419 -E0x200 -ReadOnly NoSort -Hdr', ['Property', 'Value'])
itemForms.SetFont('s12', 'Calibri')
SetExplorerTheme(itemForms.Hwnd)
For Property in appStock.Property {
	itemForms.Add(, Property.Name ': ', Property.Value)
}
itemForms.ModifyCol(1, 'Right AutoHdr')
itemForms.ModifyCol(2, 'AutoHdr Center')
IgnoreCell := {Row: Map(3, 1, 13, 1), Col: Map(1, 1)}
InCellEdit(itemForms, IgnoreCell)
itemFormsCLV := LV_Colors(itemForms)
itemFormsCLV.AlternateRows(0xFFF0F0F0)
Loop itemForms.GetCount() {
	itemFormsCLV.Cell(A_Index, 1, 0xFFF0F0F0)
}
mainList := mainWindow.AddListView('xm+270 ym+80 w1000 h500 -Multi')
searchList := mainWindow.AddListView('xp yp wp hp Hidden -Multi')
SetExplorerTheme(mainList.Hwnd)
SetExplorerTheme(searchList.Hwnd)
mainList.OnEvent('Click', showProperties)
mainList.OnEvent('itemFocus', showProperties)
searchList.OnEvent('Click', showProperties)
searchList.OnEvent('itemFocus', showProperties)
showProperties(Ctrl, Info) {
	Code := (!Row := Ctrl.GetNext()) ? '' : Ctrl.GetText(Row)
	appStock.showPropertiesValues(Code)
}
mainListCLV := LV_Colors(mainList)
searchListCLV := LV_Colors(searchList)
mainListCLV.AlternateRows(0xFFF0F0F0)
searchListCLV.AlternateRows(0xFFE0FFE0)
mainList.SetFont('s12', 'Calibri')
searchList.SetFont('s12', 'Calibri')
For Property in appStock.Property {
	mainList.InsertCol(A_Index, '100', Property.Name)
	searchList.InsertCol(A_Index, '100', Property.Name)
}
itemForms.OnNotify(-2, pickThumbnail)
pickThumbnail(List, L) {
	Critical -1
	Row := NumGet(L + (A_PtrSize * 3), 0, "Int")
    Col := NumGet(L + (A_PtrSize * 3), 4, "Int")
    If (Row = 2 && Col = 1) {
		appStock.pickThumbnail()
    }
}
itemForms.OnNotify(-176, updatePropertyValue)
updatePropertyValue(List, L) {
	Critical -1
    OffText := 16 + (A_PtrSize * 4)
    Row := NumGet(L + (A_PtrSize * 3), 4, "Int")
    ItemText := ''
    If (TxtPtr := NumGet(L, OffText, "UPtr")) {
    	ItemText := StrGet(TxtPtr)
    	appStock.writePropertyValues(Row + 1, ItemText)
    }
    SetTimer(updateValueColors, -100)
    updateValueColors() {
    	Switch Row + 1 {
    		Case 7 : appStock.updateBuyValueRelatives()
    		Case 8 : appStock.updateSellValueRelatives()
    		Case 9 : appStock.updateProfitValueRelatives()
    		Case 10 : appStock.updateProfitPercentageRelatives()
    	}
    	appStock.showPropertiesValues(appStock.PropertyName['Code'].Value,, False)
    }
}
mainList.GetPos(&X, &Y, &W)
currentTask := mainWindow.AddEdit('x' X + 500 ' y' Y - 25 ' w' W - 500 ' ReadOnly BackgroundWhite -E0x200 Right cGray')
updateItem := mainWindow.AddButton('xm w250', 'Update')
updateItem.OnEvent('Click', (*) => appStock.writeProperties())
updateItem.SetFont('Bold')
mainWindow.SetFont('s8')
chargeItem := mainWindow.AddButton('xp+270 yp w100 hp', 'Load')
chargeItem.OnEvent('Click', (*) => appStock.chargeOldDefinitions())
genBarcode := mainWindow.AddButton('xp+100 yp w200 hp', 'Generate Barcode')
genBarcode.OnEvent('Click', (*) => appStock.generateCode128(3, True))
FileMenu := Menu()
FileMenu.Add "&New", (*) => appStock.inputsClear()
FileMenu.Add "&Load", (*) => appStock.chargeOldDefinitions()
FileMenu.Add "&Update`tCtrl + S", (*) => appStock.writeProperties()
FileMenu.Add "E&xit", (*) => ExitApp()
HelpMenu := Menu()
HelpMenu.Add "&Return from search", (*) => appStock.searchClear()
HelpMenu.Add "&Find an item (And)", (*) => appStock.searchItemInList(1)
HelpMenu.Add "&Find an item (Or)", (*) => appStock.searchItemInList()
HelpMenu.Add "&Choose a thumbnail", (*) => appStock.pickThumbnail(False)
HelpMenu.Add "&Generate a barcode", (*) => appStock.generateCode128(3, True)
CurrencyMenu := Menu()
For Definition in appStock.SellCurrency {
	CurrencyMenu.Add(Definition.Symbol '`t' Definition.Name, changeCurrencyView)
	If Definition.Symbol = 'TND' {
		CurrencyMenu.Check(Definition.Symbol '`t' Definition.Name)
	}
}
changeCurrencyView(ItemName, ItemPos, MyMenu) {
	For Definition in appStock.SellCurrency {
		CurrencyMenu.UnCheck(Definition.Symbol '`t' Definition.Name)
	}
	CurrencyMenu.Check(ItemName)
	Currency := StrSplit(ItemName, '`t')
	appStock.changeCurrencyView(Currency[1])
}
ValueMenu := Menu()
ValueMenu.Add('0 (exp. 1)', changeValueRounder)
ValueMenu.Add('1 (exp. 1.0)', changeValueRounder)
ValueMenu.Add('2 (exp. 1.00)', changeValueRounder)
ValueMenu.Add('3 (exp. 1.000)', changeValueRounder)
ValueMenu.Check('3 (exp. 1.000)')
ValueMenu.Add('4 (exp. 1.0000)', changeValueRounder)
changeValueRounder(ItemName, ItemPos, MyMenu) {
	ValueMenu.Uncheck('0 (exp. 1)')
	ValueMenu.Uncheck('1 (exp. 1.0)')
	ValueMenu.Uncheck('2 (exp. 1.00)')
	ValueMenu.Uncheck('3 (exp. 1.000)')
	ValueMenu.Uncheck('4 (exp. 1.0000)')
	ValueMenu.Check(ItemName)
	Rounder := StrSplit(ItemName, ' ')
	appStock.changeValueRounder(Rounder[1])
}
Menus := MenuBar()
Menus.Add "&File", FileMenu  ; Attach the two submenus that were created above.
Menus.Add "&Edit", HelpMenu
Menus.Add "&Currency", CurrencyMenu
Menus.Add "&Values", ValueMenu
mainWindow.MenuBar := Menus
mainWindow.Show()

appStock.viewDefinitionsList()
appStock.updateValueColors()

#HotIf WinActive(mainWindow)
^S::appStock.writeProperties()
Del::appStock.deleteProperties()
^F::appStock.searchItemInList(1)
^B::appStock.searchClear()
^N::appStock.inputsClear()
#HotIf