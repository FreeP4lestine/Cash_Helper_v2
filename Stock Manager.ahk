#Requires AutoHotkey v2
#SingleInstance Force

#Include <CreateImageButton>
#Include <LV_Colors>
#Include <SetExplorerTheme>
#Include <InCellEdit>

#Include <Setting>
#Include <Stocking>
appSetting := Setting()
appStocking := Stocking()
appStocking.loadAppImages()

mainWindow := Gui(, appSetting.Title)
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', (*) => ExitApp())
loginThumbnail := mainWindow.AddPicture(, appStocking.Picture['Stock Manager'])
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Stock Manager')
mainWindow.SetFont('s10')

appStocking.getPropertiesNames()

itemThumbnail := mainWindow.AddPicture('xm+93 ym+80 w64 h64', 'images\Default.png')
itemForms := mainWindow.AddListView('xm ym+161 w250 h419 -E0x200 -ReadOnly NoSort -Hdr', ['Property', 'Value'])
itemForms.SetFont('s12', 'Calibri')
SetExplorerTheme(itemForms.Hwnd)
For Property in appStocking.Property {
	itemForms.Add(, Property.Name ': ', Property.Value)
}
itemForms.ModifyCol(1, 'Right AutoHdr')
itemForms.ModifyCol(2, 'AutoHdr Center')
itemFormsCell := InCellEdit(itemForms)
itemFormsColor := LV_Colors(itemForms)
itemFormsColor.AlternateRows(0xFFF0F0F0)
Loop itemForms.GetCount() {
	itemFormsColor.Cell(A_Index, 1, 0xFFF0F0F0)
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
	appStocking.showPropertiesValues(Code)
}
mainListCLV := LV_Colors(mainList)
searchListCLV := LV_Colors(searchList)
mainListCLV.AlternateRows(0xFFF0F0F0)
searchListCLV.AlternateRows(0xFFDCEEFF)
mainList.SetFont('s12', 'Calibri')
searchList.SetFont('s12', 'Calibri')
For Property in appStocking.Property {
	mainList.InsertCol(A_Index, '100', Property.Name)
	searchList.InsertCol(A_Index, '100', Property.Name)
}
itemForms.OnNotify(-2, pickThumbnail)
pickThumbnail(List, L) {
	Critical -1
	Row := NumGet(L + (A_PtrSize * 3), 0, "Int")
    Col := NumGet(L + (A_PtrSize * 3), 4, "Int")
    If (Row = 2 && Col = 1) {
		appStocking.pickThumbnail()
    }
}
itemForms.OnNotify(-176, updatePropertyValue)
updatePropertyValue(List, L) {
	Critical -1
    OffText := 16 + (A_PtrSize * 4)
    Row := NumGet(L + (A_PtrSize * 3), 4, "Int")
    ;Col := NumGet(L + (A_PtrSize * 3), 4, "Int")
    If (TxtPtr := NumGet(L, OffText, "UPtr")) {
    	ItemText := StrGet(TxtPtr)
    	appStocking.writePropertyValues(Row + 1, ItemText)
    }
    SetTimer(updateValueColors, -50)
    updateValueColors() {
    	appStocking.updateValueColors()
    	Switch Row + 1 {
    		Case 7 : appStocking.updateBuyValueRelatives()
    	}
    }
}
mainList.GetPos(&X, &Y, &W)
currentTask := mainWindow.AddEdit('x' X + 500 ' y' Y - 25 ' w' W - 500 ' ReadOnly BackgroundWhite -E0x200 Right cGray')
updateItem := mainWindow.AddButton('xm w250', 'Update')
updateItem.OnEvent('Click', (*) => appStocking.writeProperties())
updateItem.SetFont('Bold')
mainWindow.SetFont('s8')
chargeItem := mainWindow.AddButton('xp+270 yp w100 hp', 'Load')
chargeItem.OnEvent('Click', (*) => appStocking.chargeOldDefinitions())
genBarcode := mainWindow.AddButton('xp+100 yp w200 hp', 'Generate Barcode')
genBarcode.OnEvent('Click', (*) => appStocking.generateCode128(3, True))
FileMenu := Menu()
FileMenu.Add "&Load", (*) => appStocking.chargeOldDefinitions()
FileMenu.Add "&Update`tCtrl + S", (*) => appStocking.writeProperties()
FileMenu.Add "E&xit", (*) => ExitApp()
HelpMenu := Menu()
HelpMenu.Add "&Go back", (*) => appStocking.searchClear()
HelpMenu.Add "&Find an item (And)", (*) => appStocking.searchItemInList(1)
HelpMenu.Add "&Find an item (Or)", (*) => appStocking.searchItemInList()
HelpMenu.Add "&Choose a thumbnail", (*) => appStocking.pickThumbnail(False)
HelpMenu.Add "&Generate a barcode", (*) => appStocking.generateCode128(3, True)
Menus := MenuBar()
Menus.Add "&File", FileMenu  ; Attach the two submenus that were created above.
Menus.Add "&Edit", HelpMenu
mainWindow.MenuBar := Menus
mainWindow.Show()

appStocking.List1 := itemForms
appStocking.List2 := mainList
appStocking.List3 := searchList
appStocking.List2CLV := mainListCLV
appStocking.List1CLV := itemFormsColor
appStocking.List3CLV := searchListCLV
appStocking.Thumb := itemThumbnail
appStocking.Log := currentTask
appStocking.viewDefinitionsList()
appStocking.updateValueColors()

#HotIf WinActive(mainWindow)
^S::appStocking.writeProperties()
Del::appStocking.deleteProperties()
^F::appStocking.searchItemInList(1)
^B::appStocking.searchClear()
#HotIf