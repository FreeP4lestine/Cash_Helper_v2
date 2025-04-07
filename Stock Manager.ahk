#Requires AutoHotkey v2
#SingleInstance Force

#Include <GuiEx\GuiEx>

#Include <shared\barcoder>
#Include <shared\lv_colors>
#Include <shared\explorertheme>
#Include <shared\incelledit>
#Include <stock>
#Include <setting>
#Include <shadow>

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
mainWindow := GuiEx('-DPIScale Resize MinSize800x600', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.OnEvent('Size', Gui_Size)
Gui_Size(GuiObj, MinMax, Width, Height) {
	GuiObj.Resize(GuiObj, MinMax, Width, Height)
}
TitleIcon := mainWindow.AddPicEx('xm+20 ym+20', 'images\Stock Manager.png', 0)
mainWindow.SetFont('s25')
TitleText := mainWindow.AddText('ym+20', 'Stock Manager')
mainWindow.SetFont('s10')
currentTask := mainWindow.AddEdit('xm+1140 yp ReadOnly BackgroundWhite -E0x200 Right cGray')
ControlBorder(
	mainWindow, [
		TitleIcon,
		TitleText,
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
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1])
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('ReadOnly Backgroundd4d4d4')
		Case 'Code':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^[A-Za-z0-9_ ]+$')
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('cBlue')
		Case 'Buy Value':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('cRed BackgroundFFDEDE')
			Form.OnEvent('Change', (*) => updateRelatives())
			CForm := propertiesWindow.AddCheckbox(, 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Sell Value':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('c005800 BackgroundD8FFD8')
			Form.OnEvent('Change', (*) => updateRelatives())
			CForm := propertiesWindow.AddCheckbox(, 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Profit Value':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('BackgroundD8ECFF')
			Form.OnEvent('Change', (*) => updateRelatives())
			CForm := propertiesWindow.AddCheckbox('Checked', 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Profit Percent':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('BackgroundD8ECFF')
			Form.OnEvent('Change', (*) => updateRelatives())
			CForm := propertiesWindow.AddCheckbox('Checked', 'Auto')
			CForm.OnEvent('Click', updateRelativesCheck)
			itemPropertiesForms[Property[1]]['CForm'] := CForm
		Case 'Thumbnail':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1])
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('ReadOnly Backgroundd4d4d4')
			Form.Visible := False
			Form.GetPos(&X, &Y)
			BForm := propertiesWindow.AddButtonEx('x' X ' y' Y ' w280', 'Select')
			BForm.OnEvent('Click', (*) => pickItemThumbnail())
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicEx('xm+108 w64 h64', , 0)
			itemPropertiesForms[Property[1]]['PForm'] := PForm
		Case 'Code128':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1])
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('ReadOnly Backgroundd4d4d4 Hidden')
			Form.Visible := False
			Form.GetPos(&X, &Y)
			BForm := propertiesWindow.AddButton('x' X ' y' Y ' w280', 'Generate')
			BForm.OnEvent('Click', (*) => generateItemCode128(3, 1))
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicEx('xm+70 w280 h32 BackgroundFFFFFF',, 0)
			itemPropertiesForms[Property[1]]['PForm'] := PForm
		Case 'Related':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1], '^[A-Za-z0-9_ ]+$')
			itemPropertiesForms[Property[1]]['Form'] := Form
			Form.Opt('ReadOnly')
			Form.Visible := False
			Form.GetPos(&X, &Y)
			CBForm := propertiesWindow.AddComboBoxEx('x' X ' y' Y ' cBlue Center w280 r10',, Property[1],, '^[A-Za-z0-9_ ]+$')
			CBForm.OnEvent('Change', nameDisplay)
			itemPropertiesForms[Property[1]]['CBForm'] := CBForm
			ENForm := propertiesWindow.AddEditEx('w280 Center ReadOnly cRed -Border',, 'Product Name')
			itemPropertiesForms[Property[1]]['ENForm'] := ENForm
			EForm := propertiesWindow.AddEditEx('w280 Center',, 'Multiplication Value', '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['EForm'] := EForm
		Case 'Sell Method':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddComboBoxEx('xm w280 Center Choose1', ['Piece (p)', 'Weight (g)', 'Volume (l)'] , Property[1])
			itemPropertiesForms[Property[1]]['Form'] := Form
		Case 'Sell Amount', 'Stock Value', 'Added Value', 'Discount Value':
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1],, '^\d+([.,]?\d+)?$')
			itemPropertiesForms[Property[1]]['Form'] := Form
		Default:
			itemPropertiesForms[Property[1]] := Map()
			Form := propertiesWindow.AddEditEx('xm w280 Center', , Property[1])
			itemPropertiesForms[Property[1]]['Form'] := Form
	}
}

mainWindow.SetFont('s10')
Group := mainWindow.AddButton('xm+400 ym+135', 'New group')
Group.SetFont('Bold')
CreateImageButton(Group, 0, IBGreen2*)
Group.OnEvent('Click', (*) => newGroupCreate())
GroupPath := mainWindow.AddEditEx('xp+100 yp+4 w790 hp cGreen -Border ReadOnly BackgroundFFFFFF')
mainList := mainWindow.AddListView('xm+400 ym+175 w890 h420 -E0x200')
searchList := mainWindow.AddListView('xp yp wp hp Hidden -E0x200')
ILC_COLOR32 := 0x20
ILC_ORIGINALSIZE := 0x00010000
IL := ImageList_Create(2, 32, ILC_COLOR32 | ILC_ORIGINALSIZE, 100, 100)
ImageList_Create(cx, cy, flags, cInitial, cGrow) {
	return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow)
}
mainList.SetImageList(IL, 1)
searchList.SetImageList(IL, 1)
SetExplorerTheme(mainList.Hwnd)
SetExplorerTheme(searchList.Hwnd)
mainList.OnEvent('DoubleClick', ItemSelect)
searchList.OnEvent('DoubleClick', ItemSelect)
ItemSelect(Ctrl, Item) {
	If !Item {
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
updateItem := mainWindow.AddButton('xm+20 y' (Y + H - 30) ' w320', 'Update')
updateItem.SetFont('Bold')
CreateImageButton(updateItem, 0, [[0xFFFFFFFF, , 0xFF008000, 5, 0xFF008000], [0xFF009F00, , 0xFFFFFFFF], [0xFF00BB00, , 0xFFFFFF00]]*)
updateItem.OnEvent('Click', (*) => writeItemProperties(1))
mainWindow.SetFont('s8')
ControlBorder(
	mainWindow, [
		Group, 
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
propertiesWindow.Show('x40 y140 h440 w320')
ControlBorder(
	mainWindow, [
		propertiesWindow,
		updateItem
	]
)
mainWindow.Show('Maximize')
mainWindow.AddGuiToProportion()
loadItemsDefinitions()

#HotIf WinActive(mainWindow)
^Enter:: writeItemProperties(1)
Del:: deleteItemProperties()
^F:: searchItemInMainList(1)
^B:: searchItemInMainListClear()
^N:: clearItemViewProperties()
#HotIf