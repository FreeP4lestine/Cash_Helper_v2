#Requires AutoHotkey v2
#SingleInstance Force

#Include <GuiEx\GuiEx>

#Include <shared\barcoder>
#Include <stock>
#Include <setting>

If A_Args.Length != 1 || A_Args[1] = '' {
	ExitApp()
}
usersetting := readJson(A_AppData '\Cash Helper\users.json')
If !usersetting.Has('Registered') || !usersetting['Registered'].Has(A_Args[1]) {
	ExitApp()
}
username := A_Args[1]

setting := readJson()
currency := readJson('setting\currency.json')
pToken := Gdip_Startup()
mainWindow := GuiEx()
mainWindow.Default(1)

Logo := mainWindow.AddPicEx('xm+20 ym+20', 'images\Stock Manager.png', 0)
Title := mainWindow.AddTextEx('ym+20', 'Stock Manager', ['s25'])
currentTask := mainWindow.AddEditEx('xm+1140 yp ReadOnly Right cGray',,, ['s10'])
ControlBorder(
	mainWindow, [
		Logo,
		Title,
		currentTask
	]
)
propertiesWindow := mainWindow.AddScrollGui()
propertiesWindow.SetFont('s12 Bold', 'Calibri')
itemPropertiesForms := Map()
For Property in setting['Item'] {
	Switch Property[1] {
		Case 'Currency', 'Latest Update':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Backgroundd4d4d4', , Property[1])
		Case 'Code':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center cBlue', , Property[1],, '^[A-Za-z0-9_ ]+$')
		Case 'Buy Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center cRed BackgroundFFDEDE', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx(, 'Auto')
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Sell Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center c005800 BackgroundD8FFD8', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx(, 'Auto')
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Profit Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center BackgroundD8ECFF', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx('Checked', 'Auto')
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Profit Percent':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center BackgroundD8ECFF', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx('Checked', 'Auto')
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Thumbnail':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Backgroundd4d4d4', , Property[1])
			itemPropertiesForms[Property[1]]['Form'].Visible := False
			itemPropertiesForms[Property[1]]['Form'].GetPos(&X, &Y)
			itemPropertiesForms[Property[1]]['BForm'] := propertiesWindow.AddButtonEx('x' X ' y' Y ' w280', 'Select',, IBBlack1, 'images\buttons\image.png')
			itemPropertiesForms[Property[1]]['BForm'].OnEvent('Click', (*) => pickItemThumbnail())
			itemPropertiesForms[Property[1]]['PForm'] := propertiesWindow.AddPicEx('xm+108 w64 h64', , 0)
		Case 'Code128':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Backgroundd4d4d4 Hidden', , Property[1])
			itemPropertiesForms[Property[1]]['Form'].Visible := False
			itemPropertiesForms[Property[1]]['Form'].GetPos(&X, &Y)
			itemPropertiesForms[Property[1]]['BForm'] := propertiesWindow.AddButtonEx('x' X ' y' Y ' w280', 'Generate',, IBBlack1, 'images\buttons\bar.png')
			itemPropertiesForms[Property[1]]['BForm'].OnEvent('Click', (*) => generateItemCode128(3, 1))
			itemPropertiesForms[Property[1]]['PForm'] := propertiesWindow.AddPicEx('xm+70 w280 h32 BackgroundFFFFFF',, 0)
		Case 'Related':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly', , Property[1],, '^[A-Za-z0-9_ ]+$')
			itemPropertiesForms[Property[1]]['Form'].Visible := False
			itemPropertiesForms[Property[1]]['Form'].GetPos(&X, &Y)
			itemPropertiesForms[Property[1]]['CBForm'] := propertiesWindow.AddComboBoxEx('x' X ' y' Y ' cBlue Center w280 r10',, Property[1],, '^[A-Za-z0-9_ ]+$')
			itemPropertiesForms[Property[1]]['CBForm'].OnEvent('Change', nameDisplay)
			itemPropertiesForms[Property[1]]['ENForm'] := propertiesWindow.AddEditEx('w280 Center ReadOnly cRed -Border',, 'Product Name')
			itemPropertiesForms[Property[1]]['EForm'] := propertiesWindow.AddEditEx('w280 Center',, 'Multiplication Value',, '^\d+([.,]?\d+)?$')
		Case 'Sell Method':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddComboBoxEx('xm w280 Center Choose1', ['Piece (p)', 'Weight (g)', 'Volume (l)'] , Property[1])
		Case 'Sell Amount', 'Stock Value', 'Added Value', 'Discount Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
		Default:
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center', , Property[1])
	}
}

GroupPath := mainWindow.AddEditEx('xm+400 ym+135 yp+4 w790 hp cGreen -Border')
mainList := mainWindow.AddListViewEx('xm+400 ym+175 w890 h420 -E0x200',, ['s12'], 1, 32, 32)
searchList := mainWindow.AddListViewEx('xp yp wp hp Hidden -E0x200',,, 1, 32, 32)
mainList.OnEvent('DoubleClick', ItemSelect)
searchList.OnEvent('DoubleClick', ItemSelect)
ItemSelect(Ctrl, Item) {
	If !Item {
		Return
	}
	Code := Ctrl.GetText(Item)
	showItemProperties(Code)
}
mainList.Color.AlternateRows(0xFFF0F0F0)
searchList.Color.AlternateRows(0xFFE0FFE0)
For Property in setting['Item'] {
	mainList.InsertCol(A_Index, '100', Property[1])
	searchList.InsertCol(A_Index, '100', Property[1])
}
mainList.GetPos(&X, &Y, &W, &H)
updateItem := mainWindow.AddButtonEx('xm+20 y' (Y + H - 30) ' w320', 'Update', ['Bold'], IBBlack1, 'images\buttons\commit.png')
updateItem.OnEvent('Click', (*) => writeItemProperties(1))
ControlBorder(
	mainWindow, [
		mainList, 
		searchList
	]
)

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
propertiesWindow.Show('x40 y140 h410 w320')
ControlBorder(
	mainWindow, [
		propertiesWindow,
		updateItem
	]
)
mainWindow.Show()
mainWindow.AddGuiToProportion()
loadItemsDefinitions()

#HotIf WinActive(mainWindow)
^Enter:: writeItemProperties(1)
Del:: deleteItemProperties()
^F:: searchItemInMainList()
^B:: searchItemInMainListClear()
^N:: clearItemViewProperties()
#HotIf