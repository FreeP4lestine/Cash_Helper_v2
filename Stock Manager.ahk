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
currentTask := mainWindow.AddEditEx('xm+990 yp ReadOnly Right cGray w300 -Border',,, ['s10'])
ControlBorder(
	mainWindow, [
		Logo,
		Title,
		currentTask
	]
)
switchUpdate := mainWindow.AddButtonEx('xm+20 y150 w320', 'Single Item', ['s8 Bold'], IBBlue2, 'images\buttons\switch.png')
propertiesWindow := mainWindow.AddScrollGui()
itemPropertiesForms := Map()
For Property in setting['Item'] {
	propertiesWindow.SetFont('s12 Bold')
	Switch Property[1] {
		Case 'Currency', 'Latest Update':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Backgroundd4d4d4', , Property[1],,, 1)
		Case 'Code':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center cBlue', , Property[1],, '^[A-Za-z0-9_ ]+$', 1)
		Case 'Buy Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center cRed BackgroundFFDEDE', , Property[1],, '^\d+([.,]?\d+)?$', 1)
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx('xp yp+30', 'Auto', ['s9'])
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Sell Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center c005800 BackgroundD8FFD8', , Property[1],, '^\d+([.,]?\d+)?$', 1)
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx('xp yp+30', 'Auto', ['s9'])
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Profit Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center BackgroundD8ECFF', , Property[1],, '^\d+([.,]?\d+)?$', 1)
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx('xp yp+30 Checked', 'Auto', ['s9'])
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Profit Percent':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center BackgroundD8ECFF', , Property[1],, '^\d+([.,]?\d+)?$', 1)
			itemPropertiesForms[Property[1]]['Form'].OnEvent('Change', (*) => updateRelatives())
			itemPropertiesForms[Property[1]]['CForm'] := propertiesWindow.AddCheckboxEx('xp yp+30 Checked', 'Auto', ['s9'])
			itemPropertiesForms[Property[1]]['CForm'].OnEvent('Click', updateRelativesCheck)
		Case 'Thumbnail':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Backgroundd4d4d4 Hidden', , Property[1])
			itemPropertiesForms[Property[1]]['BForm'] := propertiesWindow.AddButtonEx('xp+65 w150', 'Select', ['s9'], IBBlack1, 'images\buttons\image.png')
			itemPropertiesForms[Property[1]]['BForm'].OnEvent('Click', (*) => pickItemThumbnail())
			itemPropertiesForms[Property[1]]['PForm'] := propertiesWindow.AddPicEx('xm+108 w64 h64', , 0)
		Case 'Code128':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Backgroundd4d4d4 Hidden', , Property[1])
			itemPropertiesForms[Property[1]]['BForm'] := propertiesWindow.AddButtonEx('xp+65 w150', 'Generate', ['s9'], IBBlack1, 'images\buttons\bar.png')
			itemPropertiesForms[Property[1]]['BForm'].OnEvent('Click', (*) => generateItemCode128(3, 1))
			itemPropertiesForms[Property[1]]['PForm'] := propertiesWindow.AddPicEx('xm+70 w280 h32 BackgroundFFFFFF',, 0)
		Case 'Related':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center ReadOnly Hidden', , Property[1],, '^[A-Za-z0-9_ ]+$', 1)
			itemPropertiesForms[Property[1]]['CBForm'] := propertiesWindow.AddComboBoxEx('xp yp cBlue Center wp r10',,,, '^[A-Za-z0-9_ ]+$')
			itemPropertiesForms[Property[1]]['CBForm'].OnEvent('Change', nameDisplay)
			itemPropertiesForms[Property[1]]['ENForm'] := propertiesWindow.AddEditEx('w280 Center ReadOnly cRed -Border',, 'Product Name',,, 1)
			itemPropertiesForms[Property[1]]['EForm'] := propertiesWindow.AddEditEx('w280 Center',, 'Multiply by',, '^\d+([.,]?\d+)?$', 1)
		Case 'Sell Method':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddComboBoxEx('xm w280 Center Choose1', ['Piece (p)', 'Weight (g)', 'Volume (l)'] , Property[1])
		Case 'Sell Amount', 'Stock Value', 'Added Value', 'Discount Value':
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
		Default:
			itemPropertiesForms[Property[1]] := Map()
			itemPropertiesForms[Property[1]]['Form'] := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],,, 1)
	}
}
propertiesWindow.AddTextEx()
GroupPath := mainWindow.AddButtonEx('xm+400 y150 w890 cGreen -Border ReadOnly', '---',, IBBlack1)
mainList := mainWindow.AddListViewEx('xm+400 ym+175 w890 h435',, ['s12'], 1, 32, 32)
searchList := mainWindow.AddListViewEx('xp yp wp hp Hidden',,, 1, 32, 32)
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
updateItem := mainWindow.AddButtonEx('xm+20 y' (Y + H - 30) ' w320', 'Update', ['s10 Bold'], IBBlack1, 'images\buttons\commit.png')
updateItem.OnEvent('Click', (*) => writeItemProperties(1))
ControlBorder(
	mainWindow, [
		mainList, 
		searchList,
		GroupPath
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
propertiesWindow.Show('x40 y180 h410 w320')
ControlBorder(
	mainWindow, [
		propertiesWindow,
		updateItem,
		switchUpdate
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