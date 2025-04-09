newGroupCreate() {
	Msgbox('Comming Soon!', 'Info', 0x40)
	;UserInput := InputBox('Enter group name', 'Group', 'w400 h85', 'NewGroup')
	;If UserInput.Result != 'OK'
	;	Return
	;If UserInput.Value = '' {
	;	MsgBox('Nothing was entered', 'Group', 0x30)
	;	NewGroupCreate()
	;}
	;If !(UserInput.Value ~= '^[A-Za-z0-9_ ]+$') {
	;	MsgBox('The name must be alphanumeric! [ A-Z, a-z, 0-9, _, ] ', 'Group', 0x30)
	;	NewGroupCreate()
	;}
}
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
		For Each, Ctrl in Form {
			Switch Type(Ctrl) {
				Case 'Gui.Edit': Ctrl.Value := ''
				Case 'Gui.ComboBox': Ctrl.Value := 0
				Case 'Gui.Picture': Ctrl.Value := ''
			}
		}
	}
	ItemPropertiesForms['Thumbnail']['BForm'].Text := 'Select'
	ItemPropertiesForms['Code128']['BForm'].Text := 'Generate'
}
writeItemProperties(backUp := False) {
	Code := ItemPropertiesForms['Code']['Form'].Value
	If Code = '' || Code ~= '[^A-Za-z0-9_]' {
		MsgBox('The code is invalid', 'Create', 0x30)
		Return False
	}
	LCode := ''
	if mainList.Visible {
		LCode := (R := mainList.GetNext()) ? mainList.GetText(R) : ''
	}
	if searchList.Visible {
		LCode := (R := searchList.GetNext()) ? searchList.GetText(R) : ''
	}
	If FileExist(setting['ItemDefLoc'] '\' Code '.json') {
		If LCode != Code {
			MsgBox(Code ' already exist', setting['Name'], 0x30)
				Return
		}
		If 'Yes' != MsgBox(Code ' already exist you want to update it?', setting['Name'], 0x30 + 0x4) {
			Return False
		}
		If 'Yes' != MsgBox(Code ' already exist you want to update it?', setting['Name'], 0x30 + 0x4) {
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
	Loop itemPropertiesForms.Count {
		Property := setting['Item'][A_Index][1]
		Value := ItemPropertiesForms[Property]['Form'].Value
		Switch Property {
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value', 'Discount Value':
				Try
					item[Property] := Round( Value / currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
				Catch
					item[Property] := 0
			Case 'Sell Amount':
				item[Property] := Value
				If Value = '' || !IsNumber(Value) {
					item[Property] := 1
				}
			Case 'Stock Value':
				item[Property] := Value
				If Value = '' || !IsNumber(Value) {
					item[Property] := 0
				}
				ST := item[Property]
			Case 'Latest Update':
				item[Property] := FormatTime(A_Now, 'yyyy.MM.dd [HH:mm:ss]')
			Case 'Related':
				CBValue := ItemPropertiesForms[Property]['CBForm'].Text
				EValue := ItemPropertiesForms[Property]['EForm'].Value
				If !FileExist(setting['ItemDefLoc'] '\' CBValue '.json')
				|| !IsNumber(EValue) {
					item[Property] := ''
					Continue
				}
				item[Property] := CBValue 'x' EValue
				tmp := readJson(setting['ItemDefLoc'] '\' CBValue '.json')
				tmp['Related'] := Code 'x' (CF := Round(1 / EValue, setting['Rounder']))
				tmp['Stock Value'] := Round(ST / CF, setting['Rounder'])
				writeJson(tmp, setting['ItemDefLoc'] '\' CBValue '.json')
			Case 'Sell Method': item[Property] := ItemPropertiesForms[Property]['Form'].Text
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
	item := readJson(setting['ItemDefLoc'] '\' Code '.json')
	For Property in setting['Item'] {
		If !item.Has(Property[1]) {
			For Each, Ctrl in itemPropertiesForms[Property[1]] {
				Switch Type(Ctrl) {
					Case 'Gui.ComboBox': Ctrl.Value := 0
					Case 'Gui.Edit': Ctrl.Value := ''
				}
			}
			Continue
		}
		If Property[1] = 'Currency' {
			itemPropertiesForms[Property[1]]['Form'].Value := setting['DisplayCurrency']
			Continue
		}
		Switch Property[1] {
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value', 'Discount Value':
				If item[Property[1]] {
					Try
						itemPropertiesForms[Property[1]]['Form'].Value := Round(currency['rates'][setting['DisplayCurrency']] * item[Property[1]], setting['Rounder'])
					Catch
						itemPropertiesForms[Property[1]]['Form'].Value := 0
				}
				Else itemPropertiesForms[Property[1]]['Form'].Value := 0
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
			Case 'Stock Value':
				If IsNumber(item[Property[1]])
					itemPropertiesForms[Property[1]]['Form'].Value := LeadTrailZeroTrim(Round(item[Property[1]], 3))
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
			Case 'Related':
				If item[Property[1]] != ''
				&& (CF := StrSplit(item[Property[1]], 'x')).Length = 2
				&& FileExist(setting['ItemDefLoc'] '\' CF[1] '.json')
				&& IsNumber(CF[2]) {
					itemPropertiesForms[Property[1]]['CBForm'].Text := CF[1]
					itemPropertiesForms[Property[1]]['EForm'].Value := LeadTrailZeroTrim(CF[2])
					itemPropertiesForms[Property[1]]['Form'].Value := item[Property[1]]
					nameDisplay(itemPropertiesForms[Property[1]]['CBForm'], '')
				}
			Case 'Sell Method': ItemPropertiesForms[Property[1]]['Form'].Text := item[Property[1]]
			Default: itemPropertiesForms[Property[1]]['Form'].Value := item[Property[1]]
		}
	}
}
LeadTrailZeroTrim(N) {
	If !InStr(N, '.') {
		Return N
	}
	N := LTrim(N, '0')
	If SubStr(N, 1, 1) = '.' {
		N := '0' N
	}
	N := RTrim(N, '0')
	If SubStr(N, -1) = '.' {
		N := SubStr(N, 1, -1)
	}
	Return N
}
nameDisplay(Ctrl, Info) {
	If FileExist(setting['ItemDefLoc'] '\' Ctrl.Text '.json') {
		Item := readJson(setting['ItemDefLoc'] '\' Ctrl.Text '.json')
		If !Item.Has('Name') {
			itemPropertiesForms['Related']['ENForm'].Value := ''
			Return
		}
		itemPropertiesForms['Related']['ENForm'].Value := Item['Name']
	}
}
deleteItemProperties() {
	Code := itemPropertiesForms['Code']['Form'].Value
	If Code = '' && mainList.Visible {
		Code := mainList.GetText(mainList.GetNext())
	}
	If Code = '' && searchList.Visible {
		Code := searchList.GetText(searchList.GetNext())
	}
	If Code = '' {
		MsgBox('Nothing to delete!', 'Create', 0x30)
		Return
	}
	Name := itemPropertiesForms['Name']['Form'].Value
	If Name = '' && mainList.Visible {
		Name := mainList.GetText(mainList.GetNext(), 2)
	}
	If Name = '' && searchList.Visible {
		Name := searchList.GetText(searchList.GetNext(), 2)
	}
	If 'Yes' != MsgBox('Are you sure to remove ' Name ' ?', 'Delete', 0x30 + 0x4) {
		Return
	}
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
			item['Profit Percent'] := Round(item['Profit Value'] / item['Buy Value'] * 100, 2)
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
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value', 'Discount Value':
				If Value {
					Try
						Value := Round(Value * currency, rounder)
					Catch
						Value := 0
				} Else Value := 0
			Case 'Stock':
				If !IsNumber(Value) {
					Value := 0
				} Else Value := LeadTrailZeroTrim(Round(Value, 3))
		}
		rowInfo.Push(Value)
	}
	Return rowInfo
}
loadItemsDefinitions() {
	Counted := 0
	StartTime := A_TickCount
	mainList.Delete()
	Loop Files, setting['ItemDefLoc'] '\*' {
		If A_LoopFileExt != 'JSON' {
			Continue
		}
		currentTask.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
		item := readJson(A_LoopFileFullPath)
		rowInfo := populateRow(item, currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
		mainList.Add(, rowInfo*)
		++Counted
		itemPropertiesForms['Related']['CBForm'].Add([item['Code']])
	}
	currentTask.Value := 'Loaded ' A_LoopFileName '... [ ' Counted ' ]'
	fitItemsListContent(mainList)
	colorizeItemsList(mainList, mainListCLV)
	currentTask.Value := Counted ' Item(s) loaded in ' Round((A_TickCount - StartTime) / 1000, 2) ' second(s)'
	mainList.Redraw()
}
updateRelativesCheck(Ctrl, Info) {
	If Ctrl.Value {
		updateRelatives()
	}
}

updateRelatives() {
	Buy := itemPropertiesForms['Buy Value']['Form']
	Sell := itemPropertiesForms['Sell Value']['Form']
	Profit := itemPropertiesForms['Profit Value']['Form']
	Percent := itemPropertiesForms['Profit Percent']['Form']
	If itemPropertiesForms['Buy Value']['CForm'].Value
		Buy.Value := ''
	If itemPropertiesForms['Sell Value']['CForm'].Value
		Sell.Value := ''
	If itemPropertiesForms['Profit Value']['CForm'].Value
		Profit.Value := ''
	If itemPropertiesForms['Profit Percent']['CForm'].Value
		Percent.Value := ''
	If itemPropertiesForms['Buy Value']['CForm'].Value {
		Try Buy.Value := buy_SellProfit(Sell.Value, Profit.Value)
		Catch 
			Try Buy.Value := buy_SellPercent(Sell.Value, Percent.Value)
			Catch 
				Try Buy.Value := buy_ProfitPercent(Profit.Value, Percent.Value)
		Try Buy.Value := Round(Buy.Value, setting['Rounder'])
	}
	;---
	If itemPropertiesForms['Sell Value']['CForm'].Value {
		Try Sell.Value := sell_BuyProfit(Buy.Value, Profit.Value)
		Catch 
			Try Sell.Value := sell_BuyPercent(Buy.Value, Percent.Value)
			Catch 
				Try Sell.Value := sell_ProfitPercent(Profit.Value, Percent.Value)
		Try Sell.Value := Round(Sell.Value, setting['Rounder'])
	}
	;---
	If itemPropertiesForms['Profit Value']['CForm'].Value {
		Profit.Value := ''
		Try Profit.Value := profit_BuySell(Buy.Value, Sell.Value)
		Catch
			Try Profit.Value := profit_BuyPercent(Buy.Value, Percent.Value)
			Catch
				Try Profit.Value := profit_SellPercent(Sell.Value, Percent.Value)
		Try Profit.Value := Round(Profit.Value, setting['Rounder'])
	}
	;---
	If itemPropertiesForms['Profit Percent']['CForm'].Value {
		Percent.Value := ''
		Try Percent.Value := percent_BuySell(Buy.Value, Sell.Value)
		Catch
			Try Percent.Value := percent_BuyProfit(Buy.Value, Profit.Value)
			Catch
				Try Percent.Value := percent_SellProfit(Sell.Value, Profit.Value)
		Try Percent.Value := Round(Percent.Value, 2)
	}
	;---
}

; Buy value formulas
buy_SellProfit(Sell, Profit) {
	Return Sell - Profit
}
buy_SellPercent(Sell, Percent) {
	Return Sell / (1 + (Percent / 100))
}
buy_ProfitPercent(Profit, Percent) {
	Return 1 / ((Percent / 100) * Profit)
}
; Sell value formulas
sell_BuyProfit(Buy, Profit) {
	Return Buy + Profit
}
sell_BuyPercent(Buy, Percent) {
	Return Buy + Buy * (Percent / 100)
}
sell_ProfitPercent(Profit, Percent) {
	Buy := buy_ProfitPercent(Profit, Percent)
	Return Buy + Profit
}
; Profit value formulas
profit_BuySell(Buy, Sell) {
	Return Sell - Buy
}
profit_BuyPercent(Buy, Percent) {
	Sell := sell_BuyPercent(Buy, Percent)
	Return Sell - Buy
}
profit_SellPercent(Sell, Percent) {
	Buy := buy_SellPercent(Sell, Percent)
	Return Sell - Buy 
}
; Percentage value formulas
percent_BuySell(Buy, Sell) {
	Profit := profit_BuySell(Buy, Sell)
	Return Profit / Buy * 100
}
percent_BuyProfit(Buy, Profit) {
	Return Profit / Buy * 100
}
percent_SellProfit(Sell, Profit) {
	Buy := sell_BuyProfit(Sell, Profit)
	Return Profit / Buy * 100
}
updateItemBuyValueRelatives() {
	Code := itemPropertiesForms['Code']['Form']
	Buy := itemPropertiesForms['Buy Value']['Form']
	If !Code.Value || !Buy.Value {
		Return
	}
	Sell := itemPropertiesForms['Sell Value']['Form']
	Profit := itemPropertiesForms['Profit Value']['Form']
	Percent := itemPropertiesForms['Profit Percent']['Form']
	If Sell.Value {
		Profit.Value := Round(profit_BuySell(Buy.Value, Sell.Value), setting['Rounder'])
		Percent.Value := Round(percent_BuySell(Buy.Value, Sell.Value), 2)
	} Else If Profit.Value {
		Sell.Value := Round(sell_BuyProfit(Buy.Value, Profit.Value), setting['Rounder'])
		Percent.Value := Round(percent_BuyProfit(Buy.Value, Profit.Value), 2)
	} Else If Percent.Value {
		Sell.Value := Round(sell_BuyPercent(Buy.Value, Percent.Value), setting['Rounder'])
		Profit.Value := Round(profit_BuyPercent(Buy.Value, Percent.Value), setting['Rounder'])
	}
}
updateItemSellValueRelatives() {
	Code := itemPropertiesForms['Code']['Form']
	Sell := itemPropertiesForms['Sell Value']['Form']
	If !Code.Value || !Sell.Value {
		Return
	}
	Buy := itemPropertiesForms['Buy Value']['Form']
	Profit := itemPropertiesForms['Profit Value']['Form']
	Percent := itemPropertiesForms['Profit Percent']['Form']
	If Buy.Value {
		Profit.Value := Round(profit_BuySell(Buy.Value, Sell.Value), setting['Rounder'])
		Percent.Value := Round(percent_BuySell(Buy.Value, Sell.Value), 2)
	} Else If Profit.Value {
		Buy.Value := Round(buy_SellProfit(Sell.Value, Profit.Value), setting['Rounder'])
		Percent.Value := Round(percent_SellProfit(Sell.Value, Profit.Value), 2)
	} Else If Percent.Value {
		Buy.Value := Round(buy_SellPercent(Sell.Value, Percent.Value), setting['Rounder'])
		Profit.Value := Round(profit_SellPercent(Sell.Value, Percent.Value), setting['Rounder'])
	}
}
searchItemInMainList(andSearch := False) {
	Counted := 0
	currentTask.Value := 'Looking...'
	searchIndexes := [1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15]
	searchList.Delete()
	Loop mainList.GetCount() {
		Row := A_Index
		ok1 := True
		ok2 := False
		hit1 := False
		hit2 := False
		For Index in searchIndexes {
			Col := Index
			Needle := itemPropertiesForms[setting['Item'][Col][1]]['Form'].Value
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
			;Msgbox Row
			Info := []
			Loop mainList.GetCount('Col') {
				Info.Push(mainList.GetText(Row, A_Index))
			}
			searchList.Add(, Info*)
			++Counted
		}
		currentTask.Value := '[ ' Counted ' ] Items are found!'
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