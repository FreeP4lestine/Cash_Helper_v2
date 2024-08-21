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

mainWindow := Gui('', appSetting.Title)
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.AddPicture(, appImage.Picture['Stock Manager'])
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Stock Manager')
mainWindow.SetFont('s10')

Thumb := mainWindow.AddPicture('xm+93 ym+80 w64 h64', appImage.Picture['Default'])
itemPropertiesForms := mainWindow.AddListView('xm ym+161 w250 h419 -E0x200 NoSort -Hdr', ['Property', 'Value'])
itemPropertiesForms.SetFont('s12', 'Calibri')
SetExplorerTheme(itemPropertiesForms.Hwnd)
For Property in appStock.itemProperties {
	itemPropertiesForms.Add(, Property.Name ': ', Property.Value)
}
itemPropertiesForms.ModifyCol(1, 'Right AutoHdr')
itemPropertiesForms.ModifyCol(2, 'AutoHdr Center')
IgnoreCell := {Row: Map(3, 1, 13, 1), Col: Map(1, 1)}
InCellEdit(itemPropertiesForms, IgnoreCell)
itemPropertiesFormsCLV := LV_Colors(itemPropertiesForms)
Loop itemPropertiesForms.GetCount() {
	backColor := !Mod(A_Index, 2) ? 0xFFFFFFFF : 0xFFE3FFE3
	itemPropertiesFormsCLV.Cell(A_Index, 1, 0xFFD6FFD6)
	itemPropertiesFormsCLV.Cell(A_Index, 2, backColor)
}
itemPropertiesForms.OnNotify(-2, pickItemThumbnail)
pickItemThumbnail(List, L) {
	Critical -1
	Row := NumGet(L + (A_PtrSize * 3), 0, "Int")
    Col := NumGet(L + (A_PtrSize * 3), 4, "Int")
    If (Row = 2 && Col = 1) {
		appStock.pickItemThumbnail()
    }
}
itemPropertiesForms.OnNotify(-176, updateItemRelativeValues)
updateItemRelativeValues(List, L) {
	Critical -1
    OffText := 16 + (A_PtrSize * 4)
    Row := NumGet(L + (A_PtrSize * 3), 4, "Int")
    ItemText := ''
    If (TxtPtr := NumGet(L, OffText, "UPtr")) {
    	ItemText := StrGet(TxtPtr)
		appStock.itemProperties[Row + 1].ViewValue := ItemText != '' ? ItemText : 'N/A'
    }
    SetTimer(Update, -100)
    Update() {
    	Switch (Row + 1) {
    		Case 7: appStock.updateItemBuyValueRelatives()
    		Case 8: appStock.updateItemSellValueRelatives()
    		Case 9: appStock.updateItemProfitValueRelatives()
    		Case 10: appStock.updateItemProfitPercentageRelatives()
    		Case 12: appStock.updateItemAddedValue()
    	}
    }
}
mainList := mainWindow.AddListView('xm+270 ym+80 w1000 h500 -Multi')
searchList := mainWindow.AddListView('xp yp wp hp Hidden -Multi')
SetExplorerTheme(mainList.Hwnd)
SetExplorerTheme(searchList.Hwnd)
mainList.OnEvent('itemFocus', showItemViewProperties)
searchList.OnEvent('itemFocus', showItemViewProperties)
showItemViewProperties(Ctrl, Info) {
	If !(Row := Ctrl.GetNext()) {
		Return
	}
	Code := Ctrl.GetText(Row)
	appStock.readItemProperties(Code)
	appStock.readItemViewProperties()
	appStock.showItemViewProperties()
}
mainListCLV := LV_Colors(mainList)
searchListCLV := LV_Colors(searchList)
mainListCLV.AlternateRows(0xFFF0F0F0)
searchListCLV.AlternateRows(0xFFE0FFE0)
mainList.SetFont('s12', 'Calibri')
searchList.SetFont('s12', 'Calibri')
For Property in appStock.itemProperties {
	mainList.InsertCol(A_Index, '100', Property.Name)
	searchList.InsertCol(A_Index, '100', Property.Name)
}
mainList.GetPos(&X, &Y, &W)
currentTask := mainWindow.AddEdit('x' X + 500 ' y' Y - 25 ' w' W - 500 ' ReadOnly BackgroundWhite -E0x200 Right cGray')
updateItem := mainWindow.AddButton('xm w250', 'Update')
updateItem.OnEvent('Click', (*) => appStock.writeItemProperties())
updateItem.SetFont('Bold')
mainWindow.SetFont('s8')
chargeItem := mainWindow.AddButton('xp+270 yp w100 hp', 'Load')
chargeItem.OnEvent('Click', (*) => appStock.loadItemsOldDefinitions())
genBarcode := mainWindow.AddButton('xp+100 yp w200 hp', 'Generate Barcode')
genBarcode.OnEvent('Click', (*) => appStock.generateItemCode128(3, True))
FileMenu := Menu()
FileMenu.Add "&New", (*) => appStock.clearItemViewProperties()
FileMenu.Add "&Load", (*) => appStock.loadItemsOldDefinitions()
FileMenu.Add "&Update`tCtrl + S", (*) => appStock.writeItemProperties()
FileMenu.Add "E&xit", (*) => ExitApp()
HelpMenu := Menu()
HelpMenu.Add "&Return from search", (*) => appStock.searchItemInMainListClear()
HelpMenu.Add "&Find an item (And)", (*) => appStock.searchItemInMainList(1)
HelpMenu.Add "&Find an item (Or)", (*) => appStock.searchItemInMainList()
HelpMenu.Add "&Choose a thumbnail", (*) => appStock.pickItemThumbnail()
HelpMenu.Add "&Generate a barcode", (*) => appStock.generateItemCode128(3, True)
CurrencyMenu := Menu()
For Cur, Definition in appStock.itemCurrency {
	CurrencyMenu.Add(Cur '`t' Definition.Name, changeItemCurrencyView)
	If Cur = 'TND' {
		CurrencyMenu.Check(Cur '`t' Definition.Name)
	}
}
changeItemCurrencyView(ItemName, ItemPos, MyMenu) {
	For Cur, Definition in appStock.SellCurrency {
		CurrencyMenu.UnCheck(Cur '`t' Definition.Name)
	}
	CurrencyMenu.Check(ItemName)
	Currency := StrSplit(ItemName, '`t')
	appStock.changeItemCurrencyView(Currency[1])
}
ValueMenu := Menu()
ValueMenu.Add('0 (exp. 1)', changeItemValueRounder)
ValueMenu.Add('1 (exp. 1.0)', changeItemValueRounder)
ValueMenu.Add('2 (exp. 1.00)', changeItemValueRounder)
ValueMenu.Add('3 (exp. 1.000)', changeItemValueRounder)
ValueMenu.Check('3 (exp. 1.000)')
ValueMenu.Add('4 (exp. 1.0000)', changeItemValueRounder)
changeItemValueRounder(ItemName, ItemPos, MyMenu) {
	ValueMenu.Uncheck('0 (exp. 1)')
	ValueMenu.Uncheck('1 (exp. 1.0)')
	ValueMenu.Uncheck('2 (exp. 1.00)')
	ValueMenu.Uncheck('3 (exp. 1.000)')
	ValueMenu.Uncheck('4 (exp. 1.0000)')
	ValueMenu.Check(ItemName)
	Rounder := StrSplit(ItemName, ' ')
	appStock.changeItemValueRounder(Rounder[1])
}
Menus := MenuBar()
Menus.Add "&File", FileMenu
Menus.Add "&Edit", HelpMenu
Menus.Add "&Currency", CurrencyMenu
Menus.Add "&Values", ValueMenu
mainWindow.MenuBar := Menus
mainWindow.Show()

appStock.loadItemsDefinitions()
appStock.colorizeItemViewProperties()

#HotIf WinActive(mainWindow)
^S::appStock.writeItemProperties()
Del::appStock.deleteItemProperties()
^F::appStock.searchItemInMainList(1)
^B::appStock.searchItemInMainListClear()
^N::appStock.clearItemViewProperties()
#HotIf