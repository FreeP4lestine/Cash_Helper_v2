; Look for an item in the main list
findItemInListView(Code, List := mainList, Vis := False) {
	foundRow := 0
	Loop List.GetCount() {
		rowCode := List.GetText(A_Index)
		If rowCode = Code {
			foundRow := A_Index
			If Vis {
				List.Focus()
				List.Modify(foundRow, 'Select Vis')
			}
			Break
		}
	}
	Return foundRow
}
clearForms() {
	For Property, Form in ItemPropertiesForms {
		Form['Form'].Value := ''
		If Form.Has('PForm') {
			Form['PForm'].Value := ''
		}
	}
}
writeItemProperties(backUp := False) {
	setting := readJson()
	Code := ItemPropertiesForms['Code']['Form'].Value
	If Code = '' || Code ~= '[^A-Za-z0-9_]' {
		MsgBox('The code is invalid', 'Create', 0x30)
		Return False
	}
	If FileExist(setting['ItemDefLoc'] '\' Code '.json') {
		If 'Yes' != MsgBox(Code ' already exist you want to update it?', 'Confirm [1]', 0x30 + 0x4) {
			Return False
		}
		If 'Yes' != MsgBox(Code ' already exist you want to update it?', 'Confirm [2]', 0x30 + 0x4) {
			Return False
		}
	}
	If backUp && FileExist(setting['ItemDefLoc'] '\' Code) {
		If !DirExist(setting['ItemBakLoc'] '\' Code) {
			DirCreate(setting['ItemBakLoc'] '\' Code)
		}
		FileCopy(setting['ItemDefLoc'] '\' Code, setting['ItemBakLoc'] '\' Code '\' A_Now)
	}
	item := Map()
	currency := readJson('setting\currency.json')
	Loop itemPropertiesForms.Count {
		Property := setting['Item'][A_Index][1]
		Value := ItemPropertiesForms[Property]['Form'].Value
		Switch Property {
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
				Try
					item[Property] := Round( Value / currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
				Catch
					item[Property] := 0
			Case 'Latest Update':
				item[Property] := FormatTime(A_Now, 'yyyy.MM.dd [HH:mm:ss]')
			Default: item[Property] := Value
		}
	}
	writeJson(item, setting['ItemDefLoc'] '\' Code '.json')
	clearForms()
	rowInfo := populateRow(item, currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
	If foundRow1 := findItemInListView(Code,, 1) {
		mainList.Modify(foundRow1,, rowInfo*)
	} Else {
		mainList.Insert(1,, rowInfo*)
	}
	If foundRow2 := findItemInListView(Code, searchList, 1) {
		searchList.Modify(foundRow2,, rowInfo*)
		fitItemsListContent(searchList)
	}
	MsgBox(item['Code'] (item['Name'] ? ' (' item['Name'] ') ' : '') ' is updated!', setting['Name'], 0x40)
}
showItemProperties(Code) {
	setting := readJson()
	currency := readJson('setting\currency.json')
	item := readJson(setting['ItemDefLoc'] '\' Code '.json')
	For Property in setting['Item'] {
		If Property[1] = 'Currency' {
			itemPropertiesForms[Property[1]]['Form'].Value := setting['DisplayCurrency']
			Continue
		}
		If !item.Has(Property[1]) {
			Continue
		}
		Switch Property[1] {
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
				Try
					itemPropertiesForms[Property[1]]['Form'].Value := Round(currency['rates'][setting['DisplayCurrency']] * item[Property[1]], setting['Rounder'])
				Catch
					itemPropertiesForms[Property[1]]['Form'].Value := 0
				Case 'Thumbnail':
					itemPropertiesForms[Property[1]]['Form'].Value := item[Property[1]]
				If item[Property[1]] {
					Try {
						itemPropertiesForms[Property[1]]['PForm'].Value := 'HBITMAP:*' hBitmapFromB64(item[Property[1]])
						itemPropertiesForms[Property[1]]['BForm'].Text := 'Remove'
					} Catch {
						itemPropertiesForms[Property[1]]['PForm'].Value := ''
						itemPropertiesForms[Property[1]]['BForm'].Text := 'Select'
					}
				} Else {
					itemPropertiesForms[Property[1]]['PForm'].Value := ''
					itemPropertiesForms[Property[1]]['BForm'].Text := 'Select'
				}
				Case 'Code128':
					itemPropertiesForms[Property[1]]['Form'].Value := item[Property[1]]
				If item[Property[1]] {
					Try {
						itemPropertiesForms[Property[1]]['PForm'].Move(,, 140, 32)
						itemPropertiesForms[Property[1]]['PForm'].Value := 'HBITMAP:*' hBitmapFromB64(item[Property[1]])
						itemPropertiesForms[Property[1]]['BForm'].Text := 'Remove'
					} Catch {
						itemPropertiesForms[Property[1]]['PForm'].Value := ''
						itemPropertiesForms[Property[1]]['BForm'].Text := 'Generate'
					}
				} Else {
					itemPropertiesForms[Property[1]]['PForm'].Value := ''
					itemPropertiesForms[Property[1]]['BForm'].Text := 'Generate'
				}
			Default: itemPropertiesForms[Property[1]]['Form'].Value := item[Property[1]]
		}
	}
}
deleteItemProperties() {
	Code := itemPropertiesForms['Code']['Form'].Value
	If Code = '' {
		MsgBox('Nothing to delete!', 'Create', 0x30)
		Return
	}
	Name := itemPropertiesForms['Name']['Form'].Value
	If 'Yes' != MsgBox('Are you sure to remove ' Name ' ?', 'Delete', 0x30 + 0x4) {
		Return
	}
	setting := readJson()
	FileDelete(setting['ItemDefLoc'] '\' Code '.json')
	If Row := findItemInListView(Code, mainList) {
		mainList.Delete(Row)
	}
	If Row := findItemInListView(Code, searchList) {
		searchList.Delete(Row)
	}
	MsgBox(Name ' is deleted!', 'Delete', 0x40)
}
pickItemThumbnail() {
	If itemPropertiesForms['Thumbnail']['Form'].Value {
		itemPropertiesForms['Thumbnail']['BForm'].Text := 'Select'
		itemPropertiesForms['Thumbnail']['Form'].Value := ''
		itemPropertiesForms['Thumbnail']['PForm'].Value := ''
		Return
	}
	Image := FileSelect(,, "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico)")
	If !Image {
		Return
	}
	itemPropertiesForms['Thumbnail']['Form'].Value := b64ResizeImage(Image, 64, 64)
	itemPropertiesForms['Thumbnail']['PForm'].Value := 'HBITMAP:*' hBitmapFromB64(itemPropertiesForms['Thumbnail']['Form'].Value)
	itemPropertiesForms['Thumbnail']['BForm'].Text := 'Remove'
}
colorizeItemsList(List, ListCLV) {
	setting := readJson()
	Loop List.GetCount() {
		Row := A_Index
		backColor := !Mod(Row, 2) ? 0xFFFFFFFF : 0xFFE6E6E6
		For Property in setting['Item'] {
			Switch Property[1] {
				Case 'Code': ListCLV.Cell(Row, A_Index, backColor, 0xFF0000FF)
				Case 'Buy Value': ListCLV.Cell(Row, A_Index, backColor, 0xFFFF0000)
				Case 'Sell Value': ListCLV.Cell(Row, A_Index, backColor, 0xFF008000)
				Default: ListCLV.Cell(Row, A_Index, backColor, 0xFF000000)
			}
		}
	}
}
fitItemsListContent(List) {
	Loop List.GetCount('Col') {
		List.ModifyCol(A_Index, 'AutoHdr Center')
	}
}
loadItemsOldDefinitions() {
	Default := FileSelect('D')
	setting := readJson()
	BackupTo := (Default = setting['ItemDefLoc']) ? Default '\olddefs' : Default
	If !Default || !BackupTo {
		Return
	}
	If !DirExist(BackupTo) {
		DirCreate(BackupTo)
	}
	formatContent(Name, Content) {
		Code := SubStr(Name, 1, -4)
		If FileExist(setting['ItemDefLoc'] '\' Code '.json') {
			Return True
		}
		item := Map()
		For Property in setting['Item'] {
			item[Property[1]] := ''
		}
		Try {
			item['Code'] := Code
			item['Name'] := Content[1]
			item['Currency'] := 'TND'
			item['Sell Method'] := 'Piece (P)'
			item['Sell Amount'] := 1
			item['Buy Value'] := Round(Content[2] / 1000, 3)
			item['Sell Value'] := Round(Content[3] / 1000, 3)
			item['Profit Value'] := Round(item['Sell Value'] - item['Buy Value'], 3)
			item['Profit Percentage'] := Round(item['Profit Value'] / item['Buy Value'] * 100, 2)
			item['Stock Value'] := Content[4]
		} Catch {
			Return False
		}
		writeJson(item, setting['ItemDefLoc'] '\' Code '.json')
		Return True
	}
	Counted := 0
	Loop Files, Default '\*.def' {
		++Counted
		currentTask.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
		Content := StrSplit(FileRead(A_LoopFileFullPath), ';')
		If !formatContent(A_LoopFileName, Content) {
			Break
		}
		If !FileExist(BackupTo '\' A_LoopFileName) {
			FileMove(A_LoopFileFullPath, BackupTo)
		}
	}
	Msgbox('Load Complete!', 'Load', 0x40)
}
populateRow(item, currency, rounder) {
	rowInfo := []
	For Property in setting['Item'] {
		If Property[1] = 'Currency' {
			rowInfo.Push(setting['DisplayCurrency'])
			Continue
		}
		If !item.Has(Property[1]) {
			rowInfo.Push('')
			Continue
		}
		Value := item[Property[1]]
		Switch Property[1] {
			Case 'Thumbnail', 'Code128':
				Value := Value != '' ? 'Yes' : ''
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
				Try
					Value := Round(Value * currency, rounder)
				Catch
					Value := 0
		}
		rowInfo.Push(Value)
	}
	Return rowInfo
}
loadItemsDefinitions() {
	Counted := 0
	StartTime := A_TickCount
	mainList.Delete()
	setting := readJson()
	currency := readJson('setting\currency.json')
	Loop Files, setting['ItemDefLoc'] '\*' {
		If A_LoopFileExt != 'JSON' {
			Continue
		}
		currentTask.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
		item := readJson(A_LoopFileFullPath)
		rowInfo := populateRow(item, currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
		mainList.Add(, rowInfo*)
		++Counted
	}
	currentTask.Value := 'Loaded ' A_LoopFileName '... [ ' Counted ' ]'
	fitItemsListContent(mainList)
	colorizeItemsList(mainList, mainListCLV)
	currentTask.Value := Counted ' Item(s) loaded in ' Round((A_TickCount - StartTime) / 1000, 2) ' second(s)'
	mainList.Redraw()
}
; Buy value auto update
buy_SellProfit(Sell, Profit) {
	Sell := !IsNumber(Sell) ? 0 : Sell
	Profit := !IsNumber(Profit) ? 0 : Profit
	Return Sell - Profit
}
buy_SellPercent(Sell, Percent) {
	Sell := !IsNumber(Sell) ? 0 : Sell
	Percent := !IsNumber(Percent) ? 0 : Percent
	If Percent = -100 {
		Return 0
	}
	Return Sell / (1 + (Percent / 100))
}
buy_ProfitPercent(Profit, Percent) {
	Profit := !IsNumber(Profit) ? 0 : Profit
	Percent := !IsNumber(Percent) ? 0 : Percent
	If !Percent || !Profit {
		Return 0
	}
	Return 1 / ((Percent / 100) * Profit)
}
; Sell value auto update
sell_BuyProfit(Buy, Profit) {
	Buy := !IsNumber(Buy) ? 0 : Buy
	Profit := !IsNumber(Profit) ? 0 : Profit
	Return Buy + Profit
}
sell_BuyPercent(Buy, Percent) {
	Buy := !IsNumber(Buy) ? 0 : Buy
	Percent := !IsNumber(Percent) ? 0 : Percent
	Return Buy + Buy * (Percent / 100)
}
sell_ProfitPercent(Profit, Percent) {
	Profit := !IsNumber(Profit) ? 0 : Profit
	Percent := !IsNumber(Percent) ? 0 : Percent
	Buy := buy_ProfitPercent(Profit, Percent)
	Return Buy + Profit
}
; Profit value auto update
profit_BuySell(Buy, Sell) {
	Buy := !IsNumber(Buy) ? 0 : Buy
	Sell := !IsNumber(Sell) ? 0 : Sell
	Return Sell - Buy
}
profit_BuyPercent(Buy, Percent) {
	Buy := !IsNumber(Buy) ? 0 : Buy
	Percent := !IsNumber(Percent) ? 0 : Percent
	Sell := sell_BuyPercent(Buy, Percent)
	Return Sell - Buy
}
profit_SellPercent(Sell, Percent) {
	Sell := !IsNumber(Sell) ? 0 : Sell
	Percent := !IsNumber(Percent) ? 0 : Percent
	Buy := buy_SellPercent(Sell, Percent)
	Return Sell - Buy 
}
; Percetage value auto update
percent_BuySell(Buy, Sell) {
	Buy := !IsNumber(Buy) ? 0 : Buy
	If !Buy {
		Return 0
	}
	Sell := !IsNumber(Sell) ? 0 : Sell
	Profit := profit_BuySell(Buy, Sell)
	Return Profit / Buy * 100
}
percent_BuyProfit(Buy, Profit) {
	Buy := !IsNumber(Buy) ? 0 : Buy
	If !Buy {
		Return 0
	}
	Profit := !IsNumber(Profit) ? 0 : Profit
	Return Profit / Buy * 100
}
percent_SellProfit(Sell, Profit) {
	Sell := !IsNumber(Sell) ? 1 : Sell
	Profit := !IsNumber(Profit) ? 0 : Profit
	Buy := sell_BuyProfit(Sell, Profit)
	If !Buy {
		Return 0
	}
	Return Profit / Buy * 100
}
;updateItemBuyValueRelatives() {
;	Code := itemProperties[1]
;	Buy := itemProperties[7]
;	If !Code.ViewValue || !Buy.ViewValue {
;		roundItemRelatives()
;		Return
;	}
;	Sell := itemProperties[8]
;	Profit := itemProperties[9]
;	Percent := itemProperties[10]
;	If Sell.ViewValue {
;		Profit.ViewValue := profit_BuySell(Buy.ViewValue, Sell.ViewValue)
;		Percent.ViewValue := percent_BuySell(Buy.ViewValue, Sell.ViewValue)
;	}
;	roundItemRelatives()
;}
;updateItemSellValueRelatives() {
;	Code := itemProperties[1]
;	Sell := itemProperties[8]
;	If !Code.ViewValue || !Sell.ViewValue {
;		roundItemRelatives()
;		Return
;	}
;	Buy := itemProperties[7]
;	Profit := itemProperties[9]
;	Percent := itemProperties[10]
;	If Buy.ViewValue {
;		Profit.ViewValue := profit_BuySell(Buy.ViewValue, Sell.ViewValue)
;		Percent.ViewValue := percent_BuySell(Buy.ViewValue, Sell.ViewValue)
;	}
;	roundItemRelatives()
;}
;updateItemProfitValueRelatives() {
;	Code := itemProperties[1]
;	Profit := itemProperties[9]
;	If !Code.ViewValue || !Profit.ViewValue {
;		roundItemRelatives()
;		Return
;	}
;	Buy := itemProperties[7]
;	Sell := itemProperties[8]
;	Percent := itemProperties[10]
;	If Buy.ViewValue {
;		Sell.ViewValue := sell_BuyProfit(Buy.ViewValue, Profit.ViewValue)
;		Percent.ViewValue := percent_BuyProfit(Buy.ViewValue, Profit.ViewValue)
;	} Else If Percent.ViewValue {
;		Sell.ViewValue := sell_ProfitPercent(Profit.ViewValue, Percent.ViewValue)
;	}
;	roundItemRelatives()
;}
;updateItemProfitPercentageRelatives() {
;	Code := itemProperties[1]
;	Percent := itemProperties[10]
;	If !Code.ViewValue || !Percent.ViewValue {
;		roundItemRelatives()
;		Return
;	}
;	Buy := itemProperties[7]
;	Sell := itemProperties[8]
;	Profit := itemProperties[9]
;	If Buy.ViewValue {
;		Sell.ViewValue := sell_BuyPercent(Buy.ViewValue, Percent.ViewValue)
;		Profit.ViewValue := profit_BuyPercent(Buy.ViewValue, Percent.ViewValue)
;	} Else If Profit.ViewValue {
;		Sell.ViewValue := sell_ProfitPercent(Profit.ViewValue, Percent.ViewValue)
;	}
;	roundItemRelatives()
;}
;updateItemAddedValue() {
;	Added := itemProperties[12]
;	If IsNumber(Added.ViewValue) {
;		Added.ViewValue := Round(Added.ViewValue, Rounder)
;	}
;	showItemViewProperties()
;}
searchItemInMainList(andSearch := False) {
	Counted := 0
	currentTask.Value := 'Looking...'
	searchIndexes := [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	searchList.Delete()
	setting := readJson()
	Loop mainList.GetCount() {
		Row := A_Index
		ok1 := True
		ok2 := False
		hit1 := False
		hit2 := False
		For Index in searchIndexes {
			Col := Index
			Needle := itemPropertiesForms.GetText(A_Index, 2)
			If !Needle {
				Continue
			}
			itemValue := mainList.GetText(Row, Col)
			ok1 := ok1 && (InStr(itemValue, Needle))
			ok2 := ok2 || (InStr(itemValue, Needle))
			hit1 := ok1
			hit2 := ok2 ? (!hit2 ? ok2 : hit2) : hit2
		}
		ok := andSearch ? hit1 : hit2
		If ok {
			Info := []
			Loop mainList.GetCount('Col') {
				Info.Push(mainList.GetText(Row, A_Index))
			}
			searchList.Add(, Info*)
			++Counted
		}
		currentTask.Value := '[ ' Counted ' ] Items are found!'
	}
	Loop searchList.GetCount('Col') {
		searchList.ModifyCol(A_Index, 'AutoHdr Center')
	}
	mainList.Visible := False
	searchList.Visible := True
	fitItemsListContent(searchList)
	colorizeItemsList(searchList, searchListCLV)
	searchList.Redraw()
}
clearItemViewProperties() {
	Loop itemPropertiesForms.GetCount() {
		itemPropertiesForms.Modify(A_Index,,, '')
	}
}
searchItemInMainListClear() {
	mainList.Visible := True
	searchList.Visible := False
	searchList.Delete()
}
generateItemCode128(Thickness := 1, Caption := False, BackColor := '0xFFFFFFFF', CodeColor := '0xFF000000') {
	Code := itemPropertiesForms['Code']['Form'].Value
	If !Code {
		MsgBox('The code is required', 'Create', 0x30)
		Return
	}
	Overwrite := True
	setting := readJson()
	item := readJson(setting['ItemDefLoc'] '\' Code '.json')
	if itemPropertiesForms['Code128']['Form'].Value != '' {
		itemPropertiesForms['Code128']['Form'].Value := ''
		itemPropertiesForms['Code128']['PForm'].Value := ''
		itemPropertiesForms['Code128']['BForm'].Text := 'Generate'
		Return
	}
	If Overwrite {
		HEIGHT_OF_IMAGE := (Thickness * 20)
		HEIGHT_OF_CODE := HEIGHT_OF_IMAGE
		If Caption {
			HEIGHT_OF_IMAGE += (HEIGHT_OF_IMAGE // 2) * 2
		}
		MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_128B(Code)
		WIDTH_OF_IMAGE := (MATRIX_TO_PRINT.Length * Thickness) + 8
		
		pBitmap := Gdip_CreateBitmap(WIDTH_OF_IMAGE, HEIGHT_OF_IMAGE)
		Gdip_SetSmoothingMode(pBitmap, 3)
		G := Gdip_GraphicsFromImage(pBitmap)
		pBrush := Gdip_BrushCreateSolid(BackColor)
		Gdip_FillRectangle(G, pBrush, 0, 0, WIDTH_OF_IMAGE, HEIGHT_OF_IMAGE)
		Gdip_DeleteBrush(pBrush)
		Loop HEIGHT_OF_CODE {
			CURRENT_ROW := A_Index
			Loop MATRIX_TO_PRINT.Length {
				CURRENT_COLUMN := A_Index * Thickness
				If (MATRIX_TO_PRINT[A_Index] = 1) {
					Loop Thickness {
						Gdip_SetPixel(pBitmap, CURRENT_COLUMN + 3 + A_Index - 1, CURRENT_ROW, CodeColor)
					}
				}
			}
		}
		If Caption {
			CAPTION_W := WIDTH_OF_IMAGE
			CAPTION_H := HEIGHT_OF_IMAGE - (HEIGHT_OF_CODE + 5)
			CAPTION_SIZE := CAPTION_H / 2.5
			Name := itemPropertiesForms['Name']['Form'].Value
			Gdip_TextToGraphics(G, Code '`n' Name, "s" CAPTION_SIZE " Bold x0 y" (HEIGHT_OF_CODE + 5) " w" CAPTION_W " h" CAPTION_H " cFF0000FF Center", "Arial")
		}
		pBitmap2 := Gdip_CloneBitmapArea(pBitmap, 0, 0, WIDTH_OF_IMAGE, HEIGHT_OF_CODE)
		base64Picture := Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
		itemPropertiesForms['Code128']['Form'].Value := Gdip_EncodeBitmapTo64string(pBitmap2, "JPG")
		itemPropertiesForms['Code128']['PForm'].Move(,, 140, 32)
		itemPropertiesForms['Code128']['PForm'].Value := 'HBITMAP:*' Gdip_CreateHBITMAPFromBitmap(pBitmap2)
		itemPropertiesForms['Code128']['BForm'].Text := 'Remove'
		Gdip_DisposeImage(pBitmap)
		Gdip_DisposeImage(pBitmap2)
		Gdip_DeleteGraphics(G)
	}
	barcoderWindow := Gui(, 'Barcode Code128')
	barcoderWindow.OnEvent('Close', (*) => barcoderWindow.Destroy())
	barcoderWindow.MarginX := 10
	barcoderWindow.MarginY := 10
	barcoderWindow.BackColor := 'White'
	barcoderPicture := barcoderWindow.AddPicture(, 'HBITMAP:*' hBitmapFromB64(base64Picture))
	barcoderWindow.AddButton('xm', 'Copy image to clipboard').OnEvent('Click', (*) => saveImageToClipboard())
	saveImageToClipboard() {
		pBitmap := Gdip_BitmapFromBase64(base64Picture)
		Gdip_SetBitmapToClipboard(pBitmap)
		Gdip_DisposeImage(pBitmap)
	}
	barcoderWindow.AddButton('yp', 'Copy base 64 image to clipboard').OnEvent('Click', (*) => savebase64ImageToClipboard())
	savebase64ImageToClipboard() {
		A_Clipboard := base64Picture
	}
	barcoderWindow.AddButton('yp', 'Save as JPG').OnEvent('Click', (*) => saveImageAsJPG())
	saveImageAsJPG() {
		saveLocation := FileSelect('S', Name '.jpg')
		If !saveLocation {
			Return
		}
		
		pBitmap := Gdip_BitmapFromBase64(base64Picture)
		Gdip_SaveBitmapToFile(pBitmap, saveLocation)
		Gdip_DisposeImage(pBitmap)
		
	}
	barcoderWindow.Show()
	barcoderPicture.GetPos(,, &bW)
	barcoderWindow.GetPos(,, &wW)
	barcoderPicture.Move((wW - bW) / 2 - 5)
}