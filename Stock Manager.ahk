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
InputTypes := ['Item', 'Group', 'Sub-Group']
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

InputType := Stock.AddButton('w300', '✓ ' InputTypes[1])
CreateImageButton(InputType, 0, IBBlack*)
InputType.OnEvent('Click', ToggleInputType)

Stock.AddText()

Loop Properties.Length {
	CreateForm(Stock, Properties[A_Index])
}

Stock.SetFont('s12 Norm')

ImageListID := IL_Create(3)
IL_Add(ImageListID, 'DB\Img\NoIcon.png')
IL_Add(ImageListID, 'DB\Img\Box.png')
IL_Add(ImageListID, 'DB\Img\Item.png')

ItemsTV := Stock.AddTreeView('xp+305 ym+60 w200 h720 -E0x200 BackgroundF0F0FF ImageList' ImageListID)

ItemsLV := Stock.AddListView('yp w980 h720', PropertiesCols)

Stock.SetFont('s10')
AddItem := Stock.AddButton('w100', 'Add')
CreateImageButton(AddItem, 0, IBBlack*)

ModifyItem := Stock.AddButton('yp w100', 'Modify')
CreateImageButton(ModifyItem, 0, IBBlack*)

RemoveItem := Stock.AddButton('yp w100', 'Remove')
CreateImageButton(RemoveItem, 0, IBRed*)

GroupItem := Stock.AddButton('xp+565 yp w100', 'Group Items')
CreateImageButton(GroupItem, 0, IBBlack*)

ImportItem := Stock.AddButton('yp w100', 'Import Items')
CreateImageButton(ImportItem, 0, IBGray*)
ImportItem.OnEvent('Click', ImportDef)

ScrollBar(Stock, 1, 1)
Stock.Show()
WindowSizeFix(Stock)
ChargeItems('DB\Items', ItemsLV, ItemsTV)

ToggleInputType(Ctrl, Info) {
	Switch Ctrl.Text {
		Case '✓ ' InputTypes[1]:
			InputType.Text := '✓ ' InputTypes[2]
		Case '✓ ' InputTypes[2]:
			InputType.Text := '✓ ' InputTypes[3]
		Case '✓ ' InputTypes[3]:
			InputType.Text := '✓ ' InputTypes[1]
	}
	CreateImageButton(InputType, 0, IBBlack*)
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