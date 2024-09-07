#Requires AutoHotkey v2
#SingleInstance Force

#Include <shared\gdip>
#Include <shared\barcoder>
#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\incelledit>
#Include <shared\createimagebutton>
#Include <shared\scrollbars>
#Include <stock>
#Include <setting>

setting := readJson()
currency := readJson('setting\currency.json')
pToken := Gdip_Startup()
mainWindow := Gui('Resize MinSize400x200', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.OnEvent('Size', resizeControls)
mainWindow.AddPicture(, 'images\Stock Manager.png')
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Stock Manager')
mainWindow.SetFont('s10')
propertiesWindow := Gui('Parent' mainWindow.Hwnd ' -Caption')
propertiesWindow.BackColor := '0xFFFFFFFF'
propertiesWindow.MarginY := 10
SB := ScrollBar(propertiesWindow, 270, 500)
itemPropertiesForms := Map()
For Property in setting['Item'] {
	itemPropertiesForms[Property[1]] := Map()
	propertiesWindow.SetFont('s8')
	Text := propertiesWindow.AddText('x0 w70 Right', Property[1] (Property[2] ? '*' : '') ': ')
	propertiesWindow.SetFont('s10')
	Form := propertiesWindow.AddEdit('xp+75 yp w140 -E0X200 Border Center')
	Form.SetFont('s12 Bold', 'Calibri')
	itemPropertiesForms[Property[1]]['Form'] := Form
	Switch Property[1] {
		Case 'Currency', 'Latest Update':
			Form.Opt('ReadOnly')
			If Property[1] = 'Latest Update' {
				Form.SetFont('s10')
			}
		Case 'Code':
			Form.Opt('cBlue')
		Case 'Buy Value':
			Form.Opt('cRed BackgroundFFDEDE')
			Form.OnEvent('Change', (*) => updateRelatives())
			propertiesWindow.SetFont('s8')
			CForm := propertiesWindow.AddCheckbox('xp+145 yp+4', 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Sell Value':
			Form.Opt('c005800 BackgroundD8FFD8')
			Form.OnEvent('Change', (*) => updateRelatives())
			propertiesWindow.SetFont('s8')
			CForm := propertiesWindow.AddCheckbox('xp+145 yp+4', 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Profit Value':
			Form.Opt('BackgroundD8ECFF')
			Form.OnEvent('Change', (*) => updateRelatives())
			propertiesWindow.SetFont('s8')
			CForm := propertiesWindow.AddCheckbox('xp+145 yp+4 Checked', 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Profit Percent':
			Form.Opt('BackgroundD8ECFF')
			Form.OnEvent('Change', (*) => updateRelatives())
			propertiesWindow.SetFont('s8')
			CForm := propertiesWindow.AddCheckbox('xp+145 yp+4 Checked', 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Thumbnail':
			Form.Opt('ReadOnly')
			Form.Visible := False
			propertiesWindow.SetFont('s8')
			BForm := propertiesWindow.AddButton('xp yp wp hp', 'Select')
			BForm.OnEvent('Click', (*) => pickItemThumbnail())
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicture('xp+36 yp+25 w64 h64 BackgroundFFFFFF')
			itemPropertiesForms[Property[1]]['PForm'] := PForm
		Case 'Code128':
			Form.Opt('ReadOnly')
			Form.Visible := False
			propertiesWindow.SetFont('s8')
			BForm := propertiesWindow.AddButton('xp yp wp hp', 'Generate')
			BForm.OnEvent('Click', (*) => generateItemCode128(3, 1))
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicture('xp yp+25 w140 h32 BackgroundFFFFFF')
			itemPropertiesForms[Property[1]]['PForm'] := PForm
	}
}
mainList := mainWindow.AddListView('xm+290 ym+80 w980 h540 -Multi')
searchList := mainWindow.AddListView('xp yp wp hp Hidden -Multi')
SetExplorerTheme(mainList.Hwnd)
SetExplorerTheme(searchList.Hwnd)
mainList.OnEvent('ItemSelect', ItemSelect)
searchList.OnEvent('ItemSelect', ItemSelect)
ItemSelect(Ctrl, Item, Selected) {
	If !Item || !Selected {
		Return
	}
	Code := Ctrl.GetText(Item)
	showItemProperties(Code)
}
mainListCLV := LV_Colors(mainList)
searchListCLV := LV_Colors(searchList)
mainListCLV.AlternateRows(0xFFF0F0F0)
searchListCLV.AlternateRows(0xFFE0FFE0)
mainList.SetFont('s12', 'Calibri')
searchList.SetFont('s12', 'Calibri')
For Property in setting['Item'] {
	mainList.InsertCol(A_Index, '100', Property[1])
	searchList.InsertCol(A_Index, '100', Property[1])
}
mainList.GetPos(&X, &Y, &W, &H)
currentTask := mainWindow.AddEdit('x' X + 500 ' y' Y - 25 ' w' W - 500 ' ReadOnly BackgroundWhite -E0x200 Right cGray')
updateItem := mainWindow.AddButton('x5 y' (Y + H - 27) ' w300', 'Update')
updateItem.SetFont('Bold')
CreateImageButton(updateItem, 0, [[0xFFFFFFFF,, 0xFF008000, 3, 0xFF008000], [0xFF009F00,, 0xFFFFFFFF], [0xFF00BB00,, 0xFFFFFF00]]*)

updateItem.OnEvent('Click', (*) => writeItemProperties(1))
mainWindow.SetFont('s8')
FileMenu := Menu()
FileMenu.Add("Exit", (*) => ExitApp())
FileMenu.Add("Load item old definition", (*) => loadItemsOldDefinitions())
HelpMenu := Menu()
HelpMenu.Add("&Clear", (*) => clearForms())
HelpMenu.Add("&Return from search", (*) => searchItemInMainListClear())
HelpMenu.Add("&Find an item (And)", (*) => searchItemInMainList(1))
HelpMenu.Add("&Find an item (Or)", (*) => searchItemInMainList())
ViewMenu := Menu()
ViewMenu.Add('Currency', (*) => Run('Currency Manager.ahk'))

Menus := MenuBar()
Menus.Add("File", FileMenu)
Menus.Add("Edit", HelpMenu)
Menus.Add("View", ViewMenu)
mainWindow.MenuBar := Menus
mainWindow.Show()
propertiesWindow.Show('x5 y85 h484 w300')
SB.ScrollMsg(1, 0, 0x115, propertiesWindow.Hwnd)
SB.ScrollMsg(0, 0, 0x115, propertiesWindow.Hwnd)
loadItemsDefinitions()

#HotIf WinActive(mainWindow)
^Enter::writeItemProperties(1)
Del::deleteItemProperties()
^F::searchItemInMainList(1)
^B::searchItemInMainListClear()
^N::clearItemViewProperties()
#HotIf