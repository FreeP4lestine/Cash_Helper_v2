#Requires AutoHotkey v2
#SingleInstance Force

#Include <GuiEx\GuiEx>

#Include <shared\gdip>
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
mainWindow := GuiEx('Resize MinSize800x600', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.OnEvent('Size', resizeControls)
C1 := mainWindow.AddPicture('xm+20 ym+20', 'images\Stock Manager.png')
mainWindow.SetFont('s25')
C2 := mainWindow.AddText('ym+20', 'Stock Manager')
mainWindow.SetFont('s10')
propertiesWindow := mainWindow.AddScrollGui()
itemPropertiesForms := Map()
For Property in setting['Item'] {
	itemPropertiesForms[Property[1]] := Map()
	propertiesWindow.SetFont('s8')
	Text := propertiesWindow.AddText('xm w80 Right', Property[1] (Property[2] ? '*' : '') ': ')
	If A_Index = 1
		C3 := Text
	propertiesWindow.SetFont('s10')
	Form := propertiesWindow.AddEdit('xp+80 yp w140 -E0X200 Border Center')
	Form.SetFont('s12 Bold', 'Calibri')
	itemPropertiesForms[Property[1]]['Form'] := Form
	Switch Property[1] {
		Case 'Currency', 'Latest Update':
			Form.Opt('ReadOnly Backgroundd4d4d4')
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
			Form.Opt('ReadOnly Backgroundd4d4d4')
			Form.Visible := False
			propertiesWindow.SetFont('s8')
			BForm := propertiesWindow.AddButton('xp yp wp hp', 'Select')
			BForm.OnEvent('Click', (*) => pickItemThumbnail())
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicture('xp+36 yp+25 w64 h64 BackgroundFFFFFF')
			itemPropertiesForms[Property[1]]['PForm'] := PForm
		Case 'Code128':
			Form.Opt('ReadOnly Backgroundd4d4d4')
			Form.Visible := False
			propertiesWindow.SetFont('s8')
			BForm := propertiesWindow.AddButton('xp yp wp hp', 'Generate')
			BForm.OnEvent('Click', (*) => generateItemCode128(3, 1))
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicture('xp yp+25 w140 h32 BackgroundFFFFFF')
			itemPropertiesForms[Property[1]]['PForm'] := PForm
		Case 'Related':
			Form.Opt('ReadOnly')
			Form.Visible := False
			propertiesWindow.SetFont('Bold s12', 'Calibri')
			CBForm := propertiesWindow.AddComboBox('-E0X200 Border cBlue Center xp yp wp hp r10')
			CBForm.OnEvent('Change', nameDisplay)
			itemPropertiesForms[Property[1]]['CBForm'] := CBForm
			ENForm := propertiesWindow.AddEdit('wp -E0X200 Border Center ReadOnly Backgroundd4d4d4')
			itemPropertiesForms[Property[1]]['ENForm'] := ENForm
			EForm := propertiesWindow.AddEdit('wp -E0X200 Border Center')
			itemPropertiesForms[Property[1]]['EForm'] := EForm
	}
}
mainWindow.SetFont('s10')
Group := mainWindow.AddButton('xm+400 ym+125', 'New group')
Group.SetFont('Bold')
CreateImageButton(Group, 0, IBGreen2*)
Group.OnEvent('Click', (*) => newGroupCreate())
GroupPath := mainWindow.AddEdit('xm+400 ym+175 w980')
mainList := mainWindow.AddListView('xm+400 ym+225 w980 h440 -E0x200')
searchList := mainWindow.AddListView('xp yp wp hp Hidden -E0x200')
ILC_COLOR32 := 0x20 
ILC_ORIGINALSIZE := 0x00010000
IL := ImageList_Create(2, 32, ILC_COLOR32 | ILC_ORIGINALSIZE, 100, 100)
ImageList_Create(cx, cy, flags, cInitial, cGrow){
	return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow) 
} 
mainList.SetImageList(IL, 1)
searchList.SetImageList(IL, 1)
Box3 := Shadow(mainWindow, [Group, mainList, searchList])
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
currentTask := mainWindow.AddEdit('x' X ' ym+20 w' W ' ReadOnly BackgroundWhite -E0x200 Right cGray')
Box2 := Shadow(mainWindow, [C1, C2, currentTask])
updateItem := mainWindow.AddButton('xm+20 y' (Y + H - 27) ' w320', 'Update')
;Box4 := Shadow(mainWindow, [updateItem])
updateItem.SetFont('Bold')
CreateImageButton(updateItem, 0, [[0xFFFFFFFF,, 0xFF008000, 5, 0xFF008000], [0xFF009F00,, 0xFFFFFFFF], [0xFF00BB00,, 0xFFFFFF00]]*)
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
propertiesWindow.Show('x40 y130 h454 w320')
Box1 := Shadow(mainWindow, [updateItem, propertiesWindow])
mainWindow.Show('Maximize')
loadItemsDefinitions()

#HotIf WinActive(mainWindow)
^Enter::writeItemProperties(1)
Del::deleteItemProperties()
^F::searchItemInMainList(1)
^B::searchItemInMainListClear()
^N::clearItemViewProperties()
#HotIf