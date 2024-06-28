#Requires AutoHotkey v2.0
#SingleInstance Force

#Include <UseGDIP>
#Include <ImageButton>
#Include <UserDefinedFunctions>
#Include <Gdip_All>
#Include <ScrollBar>
#Include <DBManager>
#Include <IButtons>

Properties := ['E#Category', 'I#Icon', 'E#Barcode', 'E#Name', 'C#Physique Status', 'C#Sell Method', 'C#Base Currency', 'C#Benefit Percentage', 'E#Buy Value', 'E#Sell Value', 'C#Stock Type', 'E#Stock']
PropertiesCols := ArrayItemSelectSlice(Properties)
PropertiesJoined := ArrayJoin(PropertiesCols)
PropertiesValues := CreateArray(Properties.Length)

Stock := Gui(, 'Stock Manager')
Stock.BackColor := 'White'
Stock.MarginX := 20
Stock.MarginY := 20
Stock.OnEvent('Close', (*) => ExitApp())
Stock.SetFont('s23 Bold')
Stock.AddText('xm y10 cGreen h50', 'Stock Manager')
Stock.SetFont('s10 Norm')
Stock.BackColor := 'White'

Stock.MarginY := 5

Item := Stock.AddButton('w150', '✓ Item')
CreateImageButton(Item, 0, IBGray*)
Item.OnEvent('Click', CreateItemSelect)

Group := Stock.AddButton('yp w150', 'Group')
CreateImageButton(Group, 0, IBBlack*)
Group.OnEvent('Click', CreateGroupSelect)

Stock.AddText()

Loop Properties.Length {
	CreateForm(Stock, Properties[A_Index])
}

;ItemProp := CloneArray(Properties, PropertiesObj, ['E#Category'])
;GroupProp := CloneArray(Properties, PropertiesObj, ['I#Icon', 'E#Barcode', 'E#Name', 'C#Physique Status', 'C#Sell Method', 'C#Base Currency', 'C#Benefit Percentage', 'E#Buy Value', 'E#Sell Value', 'C#Stock Type', 'E#Stock'])

Stock.SetFont('s12 Norm')
ItemsLV := Stock.AddListView('ym+60 w1200 h720', PropertiesCols)

Stock.SetFont('s10')
AddItem := Stock.AddButton('w100', 'Add')
CreateImageButton(AddItem, 0, IBBlack*)

ModifyItem := Stock.AddButton('yp w100', 'Modify')
CreateImageButton(ModifyItem, 0, IBBlack*)

RemoveItem := Stock.AddButton('yp w100', 'Remove')
CreateImageButton(RemoveItem, 0, IBRed*)

GroupItem := Stock.AddButton('xp+780 yp w100', 'Group Items')
CreateImageButton(GroupItem, 0, IBBlack*)

ImportItem := Stock.AddButton('yp w100', 'Import Items')
CreateImageButton(ImportItem, 0, IBGray*)
ImportItem.OnEvent('Click', ImportDef)

ScrollBar(Stock, 1, 1)
Stock.Show()
WindowSizeFix(Stock)

CreateItemSelect(Ctrl, Info) {
	Ctrl.Text := '✓ Item'
	Group.Text := 'Group'
	CreateImageButton(Group, 0, IBBlack*)
	CreateImageButton(Item, 0, IBGray*)
}

CreateGroupSelect(Ctrl, Info) {
	Ctrl.Text := '✓ Group'
	Item.Text := 'Item'
	CreateImageButton(Group, 0, IBGray*)
	CreateImageButton(Item, 0, IBBlack*)
}

ImportDef(Ctrl, Info) {
	Global PropertiesValues
	ImportFrom := FileSelect('D')
	Loop Files, ImportFrom '\' '*.Def', 'R' {
		Barcode := SubStr(A_LoopFileName, 1, -4)
		DBPath := 'DB\Items\' Barcode '.DB'
		If FileExist(DBPath) {
			Continue
		}
		PropertiesValues := ClearArray(PropertiesValues)
		TableName := 'Properties'
		Property := StrSplit(FileRead(A_LoopFileFullPath), ';')
		PropertiesValues[3] := Barcode
		PropertiesValues[4] := Property[1]
		PropertiesValues[9] := Property[2]
		PropertiesValues[10] := Property[3]
		PropertiesValues[12] := Property[4]
		SQLData := ArrayMerge(Properties, PropertiesValues)
		DBCreateTable(DBPath, TableName, PropertiesJoined)
		Table := DBReadTable(DBPath, TableName)
		DBInsertRowTable(DBPath, TableName)
		DBUpdateRowTable(DBPath, TableName, ArrayMerge(PropertiesCols, PropertiesValues), 1)
	}
}