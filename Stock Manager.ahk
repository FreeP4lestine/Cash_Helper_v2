#Requires AutoHotkey v2.0
#SingleInstance Force

#Include <UseGDIP>
#Include <ImageButton>
#Include <LV_Colors>
#Include <UserDefinedFunctions>
#Include <Gdip_All>
#Include <ScrollBar>
#Include <DBManager>
#Include <IButtons>

Properties := ['I#Icon', 'E#Category', 'E#Barcode', 'E#Name', 'C#Physique Status', 'C#Sell Method', 'E#Sell Amount', 'C#Base Currency', 'E#Buy Value', 'E#Sell Value', 'C#Benefit Percentage', 'E#Benefit Value', 'C#Stock Type', 'E#Stock']
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
Stock.SetFont('s20')
Stock.AddText('xm+900 yp+20 h50', 'Items Table')
Stock.SetFont('s10 Norm')
Stock.BackColor := 'White'

Stock.MarginY := 5

InputType := Stock.AddButton('xm w300', '✓ ' InputTypes[1])
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

ItemsTV := Stock.AddTreeView('xp+305 ym+90 w220 h835 BackgroundF0F0FF ImageList' ImageListID)

ProgressBar := Stock.AddProgress('xp yp-30 w220 h18 Hidden')
ProgressText := Stock.AddText('yp w980 h20 Hidden cBlue')
ProgressText.SetFont('s10 Italic')

ItemsLV := Stock.AddListView('xp yp+30 w980 h800 Center', PropertiesCols)
ItemsLV.SetFont('Bold', 'Calibri')
ItemsLV.SetImageList(ImageListID)
ItemsLVColors := LV_Colors(ItemsLV)
ItemsLVColors.SelectionColors(0xFF80C0FF)

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

Stock.AddText('ym w5 h1')
Stock.AddText('xm w1 h5')

ScrollBar(Stock, 1, 1)
Stock.Show()
WindowSizeFix(Stock)
ChargeItems('DB\Items', ItemsLV, ItemsLVColors, ItemsTV)

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
	If !ImportFrom {
		Return
	}
	FilesCount := 0
	Loop Files, ImportFrom '\' '*.Def', 'R' {
		FilesCount++
	}
	ProgressBar.Visible := True
	ProgressText.Visible := True
	ProgressBar.Value := 0
	ProgressBar.Opt('Range0-' FilesCount)
	Loop Files, ImportFrom '\*.Def', 'R' {
		ProgressBar.Value++
		ProgressText.Value := 'Importing ' A_LoopFileName '...'
		Barcode := SubStr(A_LoopFileName, 1, -4)
		DBPath := 'DB\Items\' Barcode '.DB'
		If FileExist(DBPath) {
			Continue
		}
		Try {
			PropertiesValues := ClearArray(PropertiesValues)
			TableName := 'Properties'
			Property := StrSplit(FileRead(A_LoopFileFullPath), ';')
			Property[2] += 0
			Property[3] += 0
			PropertiesValues[1] := ''
			PropertiesValues[2] := 'General'
			PropertiesValues[3] := Barcode
			PropertiesValues[4] := Property[1]
			PropertiesValues[5] := 'Solid'
			PropertiesValues[6] := 'Piece'
			PropertiesValues[7] := 1
			PropertiesValues[8] := 'TND - Tunisian Dinar'
			BuyValue := Round(Property[2] / 1000, 3)
			SellValue := Round(Property[3] / 1000, 3)
			ProfitValue := Round(SellValue - BuyValue, 3)
			IncreasePercentage := Round((1 - (BuyValue / SellValue)) * 100, 2) ' %'
			PropertiesValues[9] := BuyValue ' TND'
			PropertiesValues[10] := SellValue ' TND'
			PropertiesValues[11] := IncreasePercentage
			PropertiesValues[12] := ProfitValue ' TND'
			PropertiesValues[13] := 'Individual'
			PropertiesValues[14] := Property[4]
			SerilizedData := ArrayMerge(PropertiesCols, PropertiesValues,, '')
			DBCreateDefinition(StrReplace(A_LoopFileFullPath, ImportFrom '\'), SerilizedData)
		} Catch As Err {
			If 'Yes' != Msgbox('Found corrupted defintion in:`n`n"' A_LoopFileFullPath '"`n`n Continue?', 'Warning', 0x30 + 0x4) {
				Break
			}
		}
		
	}
	Msgbox('Import ' FilesCount ' items complete', 'Info', 0x40)
	ProgressBar.Visible := False
	ProgressText.Visible := False
	ChargeItems('DB\Items', ItemsLV, ItemsLVColors, ItemsTV)
}