#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\gdip>
#Include <shared\barcoder>
#Include <shared\createimagebutton>
#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\incelledit>
#Include <custom\class_setting>
#Include <custom\class_stock>
#Include <custom\class_image>

appSetting := Setting()
appImage := Imaging()
appStock := Stock()

pToken := Gdip_Startup()
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
	backColor := !Mod(A_Index, 2) ? 0xFFFFFFFF : 0xFFE6E6E6
	itemPropertiesFormsCLV.Cell(A_Index, 1, 0xFFFFFFFF)
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
		appStock.itemProperties[Row + 1].ViewValue := ItemText
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
mainList := mainWindow.AddListView('xm+270 ym+80 w1000 h540 -Multi BackgroundE6E6E6')
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
mainList.GetPos(&X, &Y, &W, &H)
currentTask := mainWindow.AddEdit('x' X + 500 ' y' Y - 25 ' w' W - 500 ' ReadOnly BackgroundWhite -E0x200 Right cGray')
updateItem := mainWindow.AddButton('xm y' (Y + H - 27) ' w250', 'Update')
updateItem.SetFont('Bold')
CreateImageButton(updateItem, 0, [[0xFF008000,, 0xFFFFFFFF, 3], [0xFF009F00], [0xFF00BB00]]*)
updateItem.OnEvent('Click', (*) => appStock.writeItemProperties(1))
mainWindow.SetFont('s8')
FileMenu := Menu()
FileMenu.Add("Exit", (*) => ExitApp())
FileMenu.Add("Load item old definition", (*) => appStock.loadItemsOldDefinitions())
HelpMenu := Menu()
HelpMenu.Add("&Clear", (*) => appStock.clearItemViewProperties())
HelpMenu.Add("&Return from search", (*) => appStock.searchItemInMainListClear())
HelpMenu.Add("&Find an item (And)", (*) => appStock.searchItemInMainList(1))
HelpMenu.Add("&Find an item (Or)", (*) => appStock.searchItemInMainList())
HelpMenu.Add("&Generate item barcode", (*) => appStock.generateItemCode128(3, True))
ViewMenu := Menu()
ViewMenu.Add('Currency', (*) => Run('Currency Manager.ahk'))

Menus := MenuBar()
Menus.Add("File", FileMenu)
Menus.Add("Edit", HelpMenu)
Menus.Add("View", ViewMenu)
mainWindow.MenuBar := Menus
mainWindow.Show()
Gdip_Shutdown(pToken)
appStock.loadItemsDefinitions()
appStock.colorizeItemViewProperties()

#HotIf WinActive(mainWindow)
^Enter::appStock.writeItemProperties(1)
Del::appStock.deleteItemProperties()
^F::appStock.searchItemInMainList(1)
^B::appStock.searchItemInMainListClear()
^N::appStock.clearItemViewProperties()
#HotIf