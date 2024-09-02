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
pToken := Gdip_Startup()

mainWindow := Gui(, setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 5
mainWindow.OnEvent('Close', Quit)
Quit(HGui) {
	Gdip_Shutdown(pToken)
	ExitApp()
}
mainWindow.AddPicture(, 'images\Stock Manager.png')
mainWindow.SetFont('s25')
mainWindow.AddText('ym+10', 'Stock Manager')
mainWindow.SetFont('s10')
propertiesWindow := Gui('Parent' mainWindow.Hwnd ' -Caption')
propertiesWindow.BackColor := 0xFFE6E6E6
SB := ScrollBar(propertiesWindow, 270, 500)
;ThumbEdit := mainWindow.AddEdit('x0 y0 w300 ReadOnly Hidden')
;Code128Edit := mainWindow.AddEdit('x0 y0 w300 ReadOnly Hidden')
;Thumb := mainWindow.AddPicture('xm+93 ym+80 w64 h64 Hidden', 'images\Default.png')
;Thumb.OnEvent('Click', (*) => pickItemThumbnail())
;itemPropertiesForms := mainWindow.AddListView('xm ym+161 w250 h419 -E0x200 NoSort -Hdr', ['Property', 'Value'])
;itemPropertiesForms.SetFont('s12', 'Calibri')
;SetExplorerTheme(itemPropertiesForms.Hwnd)
itemPropertiesForms := Map()
For Property in setting['Item'] {
	itemPropertiesForms[Property[1]] := Map()
	propertiesWindow.SetFont('s8')
	Text := propertiesWindow.AddText('x0 w100 Right', Property[1] (Property[2] ? '*' : '') ': ')
	propertiesWindow.SetFont('s10')
	Form := propertiesWindow.AddEdit('xp+105 yp w140 -E0X200 Border Center')
	Form.SetFont('s12 Bold', 'Calibri')
	itemPropertiesForms[Property[1]]['Form'] := Form
	Switch Property[1] {
		Case 'Currency', 'Latest Update':
			Form.Opt('ReadOnly BackgroundE6E6E6')
		Case 'Code':
			Form.Opt('cBlue')
		Case 'Buy Value':
			Form.Opt('cRed')
		Case 'Sell Value':
			Form.Opt('c005800')
		Case 'Thumbnail' :
			Form.Opt('ReadOnly BackgroundE6E6E6')
			propertiesWindow.SetFont('s8')
			BForm := propertiesWindow.AddButton('xp yp+25 w140', 'Select')
			BForm.OnEvent('Click', (*) => pickItemThumbnail())
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicture('xp+36 yp+25 w64 h64 BackgroundE6E6E6')
			itemPropertiesForms[Property[1]]['PForm'] := PForm
		Case 'Code128' :
			Form.Opt('ReadOnly BackgroundE6E6E6')
			propertiesWindow.SetFont('s8')
			BForm := propertiesWindow.AddButton('xp yp+25 w140', 'Generate')
			BForm.OnEvent('Click', (*) => generateItemCode128(3, 1))
			itemPropertiesForms[Property[1]]['BForm'] := BForm
			PForm := propertiesWindow.AddPicture('xp yp+25 w140 h32 BackgroundE6E6E6')
			itemPropertiesForms[Property[1]]['PForm'] := PForm
	}
}
;itemPropertiesForms.ModifyCol(1, 'Right AutoHdr')
;itemPropertiesForms.ModifyCol(2, 'AutoHdr Center')
;IgnoreCell := {Row: Map(3, 1, 13, 1), Col: Map(1, 1)}
;InCellEdit(itemPropertiesForms, IgnoreCell)
;itemPropertiesFormsCLV := LV_Colors(itemPropertiesForms)
;Loop itemPropertiesForms.GetCount() {
;	backColor := !Mod(A_Index, 2) ? 0xFFFFFFFF : 0xFFE6E6E6
;	itemPropertiesFormsCLV.Cell(A_Index, 1, 0xFFFFFFFF)
;	itemPropertiesFormsCLV.Cell(A_Index, 2, backColor)
;}
mainList := mainWindow.AddListView('xm+270 ym+80 w1000 h540 -Multi BackgroundE6E6E6')
searchList := mainWindow.AddListView('xp yp wp hp Hidden -Multi')
SetExplorerTheme(mainList.Hwnd)
SetExplorerTheme(searchList.Hwnd)
mainList.OnEvent('itemFocus', itemFocus)
searchList.OnEvent('itemFocus', itemFocus)
itemFocus(Ctrl, Info) {
	If !(Row := Ctrl.GetNext()) {
		Return
	}
	Code := Ctrl.GetText(Row)
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
updateItem := mainWindow.AddButton('xm y' (Y + H - 27) ' w250', 'Update')
updateItem.SetFont('Bold')
CreateImageButton(updateItem, 0, [[0xFFFFFFFF,, 0xFF008000, 3, 0xFF008000], [0xFF009F00,, 0xFFFFFFFF], [0xFF00BB00,, 0xFFFFFF00]]*)

updateItem.OnEvent('Click', (*) => writeItemProperties(1))
mainWindow.SetFont('s8')
FileMenu := Menu()
FileMenu.Add("Exit", (*) => ExitApp())
FileMenu.Add("Load item old definition", (*) => loadItemsOldDefinitions())
HelpMenu := Menu()
HelpMenu.Add("&Clear", (*) => clearItemViewProperties())
HelpMenu.Add("&Return from search", (*) => searchItemInMainListClear())
HelpMenu.Add("&Find an item (And)", (*) => searchItemInMainList(1))
HelpMenu.Add("&Find an item (Or)", (*) => searchItemInMainList())
HelpMenu.Add("&Generate item barcode", (*) => generateItemCode128(3, True))
ViewMenu := Menu()
ViewMenu.Add('Currency', (*) => Run('Currency Manager.ahk'))

Menus := MenuBar()
Menus.Add("File", FileMenu)
Menus.Add("Edit", HelpMenu)
Menus.Add("View", ViewMenu)
mainWindow.MenuBar := Menus
mainWindow.Show()
propertiesWindow.Show('x5 y85 h500 w280')
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