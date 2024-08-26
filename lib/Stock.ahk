class Stock {
	__New() {
		This.defaultLocation 		:= 'setting\defs'
		This.defaultBackup 		    := 'setting\defs\backup'
		This.itemPropertiesDef 		:= 'setting\ItemProperties'
		This.sellPropertiesDef 		:= 'setting\SellMethods'
		This.currencyPropertiesDef 	:= 'setting\SellCurrency'
		This.itemProperties 		:= []
		This.itemSellMethod			:= Map()
		This.itemCurrency 			:= Map()
		This.selectedCurrency 		:= appSetting.selectedCurrency
		This.Rounder 				:= appSetting.Rounder
		This.readItemPropertiesDef()
		This.readSellPropertiesDef()
		This.readCurrencyPropertiesDef()
	}
	; Item values clear
	restoreItemPropertiesValues(ViewChanges := False) {
		For Property in This.itemProperties {
			Property.Value := ''
			Property.ViewValue := ''
			If ViewChanges
				itemPropertiesForms.Modify(A_Index,,, 'N/A')
		}
		If ViewChanges
			This.colorizeItemViewProperties()
	}
	; Definitions load
	readItemPropertiesDef(File := This.itemPropertiesDef) {
		If FileExist(File) {
			O := FileOpen(File, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.itemProperties.Push({Name: Definition[1], Value: '', ViewValue: ''})
			}
            O.Close()
		}
	}
	readSellPropertiesDef(File := This.SellPropertiesDef) {
		If FileExist(File) {
			O := FileOpen(File, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.itemSellMethod[Definition[1]] := Definition[2]
			}
			O.Close()
		}
	}
	readCurrencyPropertiesDef(File := This.currencyPropertiesDef) {
		If FileExist(File) {
			O := FileOpen(File, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.itemCurrency[Definition[1]] := {Name: Definition[2], ConvertFactor: Definition[3]}
			}
			O.Close()
		}
	}
	; Item definition read from a file
	readItemProperties(Code) {
		This.restoreItemPropertiesValues()
		O := FileOpen(This.defaultLocation '\' Code, 'r')
		While !O.AtEOF {
			lineValue := O.ReadLine()
			itemProperties := This.itemProperties[A_Index]
			Switch itemProperties.Name {
				Case 'Code':
					If lineValue = '' || Code ~= '[^A-Za-z0-9_]' {
						Return False
					}
					itemProperties.Value := lineValue
				Case 'Thumbnail', 'Code128':
					If lineValue != '' {
						If !appImage.hBitmapFromB64(lineValue) {
							lineValue := ''
						}
					}
					itemProperties.Value := lineValue
				Case 'Sell Method':
					If lineValue = '' || !This.itemSellMethod.Has(lineValue) {
						lineValue := 'Piece (P)'
					}
					itemProperties.Value := lineValue
					itemSellMethod := itemProperties.Value
				Case 'Sell Amount':
					If !IsNumber(lineValue) {
						lineValue := This.itemSellMethod[itemSellMethod]
					}
					itemProperties.Value := lineValue
				Case 'Currency':
					If lineValue = '' || !This.itemCurrency.Has(lineValue) {
						lineValue := This.selectedCurrency
					}
					itemProperties.Value := lineValue
				Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
					If !IsNumber(lineValue) {
						lineValue := 0
					}
					itemProperties.Value := lineValue
				Case 'Profit Percentage':
					If !IsNumber(lineValue) {
						lineValue := 0
					}
					itemProperties.Value := Round(lineValue, 2)
				Case 'Stock Value':
					If !IsNumber(lineValue) || lineValue < 1 {
						lineValue := 0
					}
					itemProperties.Value := lineValue
				Default: itemProperties.Value := lineValue
			}
		}
		O.Close
		Return True
	}
	; Item view values update from the read item values
	readItemViewProperties() {
		For Property in This.itemProperties {
			Switch Property.Name {
				Case 'Thumbnail', 'Code128':
					Property.ViewValue := Property.Value != '' ? 'True' : ''
				Case 'Currency':
					If Property.Value != '' || !This.itemCurrency.Has(Property.Value) {
						Property.Value := This.selectedCurrency
					}
					ConvertFactor := This.itemCurrency[Property.Value].ConvertFactor
					Property.ViewValue := Property.Value
				Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
					If !IsNumber(Property.Value) {
						Property.Value := 0
					}
					Property.ViewValue := Round(Property.Value * ConvertFactor, This.Rounder)
				Default: Property.ViewValue := Property.Value
			}
		}
	}
	; Barcode check before updating the item
	beforWriteItemProperties(backUp := True) {
		Code := ItemPropertiesForms.GetText(1, 2)
		If Code = '' || Code ~= '[^A-Za-z0-9_]' {
			MsgBox('The code is invalid', 'Create', 0x30)
			Return False
		}
		If FileExist(This.defaultLocation '\' Code) {
			If 'Yes' != MsgBox(Code ' already exist you want to update it?', 'Confirm [1]', 0x40 + 0x4) {
				Return False
			}
			If 'Yes' != MsgBox(Code ' already exist you want to update it?', 'Confirm [2]', 0x40 + 0x4) {
				Return False
			}
			If 'Yes' != MsgBox('Overwriting other defintions may create unwanted issues`nPlease be aware of what are you doing!`nContinue?', 'Confirm [3]', 0x30 + 0x4)
				Return False
		}
		If backUp && FileExist(This.defaultLocation '\' Code) {
			If !DirExist(This.defaultBackup '\' Code) {
				DirCreate(This.defaultBackup '\' Code)
			}
			FileCopy(This.defaultLocation '\' Code, This.defaultBackup '\' Code '\' A_Now)
		}
		Return True
	}
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
	; Finish after updating the item
	afterWriteItemProperties() {
		Code := ItemPropertiesForms.GetText(1, 2)
		foundRow1 := This.findItemInListView(Code,, 1)
		foundRow2 := This.findItemInListView(Code, searchList, 1)
		This.readItemViewProperties()
		rowInfo := []
		For Property in This.itemProperties {
			rowInfo.Push(Property.ViewValue)
		}
		foundRow1 ? mainList.Modify(foundRow1,, rowInfo*) : mainList.Insert(1,, rowInfo*)
		foundRow2 ? searchList.Modify(foundRow2,, rowInfo*) : searchList.Insert(1,, rowInfo*)
		Thumb.Value := appImage.Picture['Default']
		This.restoreItemPropertiesValues(True)
		This.fitItemsListContent(mainList)
		This.fitItemsListContent(searchList)
		Msgbox(Code ' is updated!', 'Update', 0x40)
	}
	; reverse of readItemViewProperties()
	submitItemViewProperties() {
		Loop ItemPropertiesForms.GetCount() {
			rowValue := ItemPropertiesForms.GetText(A_Index, 2)
			Property := This.itemProperties[A_Index]
			Switch Property.Name {
				Case 'Thumbanil', 'Code128': Continue
				Case 'Sell Method':
					Property.Value := Property.ViewValue
					If Property.Value = '' || !This.itemSellMethod.Has(Property.Value) {
						Property.Value := 'Piece (P)'
					}
					itemSellMethod := Property.Value
				Case 'Sell Amount':
					Property.Value := Property.ViewValue
					If !IsNumber(Property.Value) {
						Property.Value := This.itemSellMethod[itemSellMethod]
					}
				Case 'Currency':
					ConvertFromCurrency := Property.Value
					If ConvertFromCurrency = '' || !This.itemCurrency.Has(ConvertFromCurrency) {
						ConvertFromCurrency := This.selectedCurrency
					}
					ConvertFromFactor := This.itemCurrency[ConvertFromCurrency].ConvertFactor
					Property.Value := Property.ViewValue
					If Property.Value = '' || !This.itemCurrency.Has(Property.Value) {
						Property.Value := This.selectedCurrency
					}
					ConvertToCurrency := Property.Value
					ConvertToFactor := This.itemCurrency[ConvertToCurrency].ConvertFactor
				Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
					Property.Value := Property.ViewValue
					If !IsNumber(Property.Value) {
						Property.Value := 0
					}
					If ConvertFromCurrency != 'TND' {
						Property.Value := Property.ViewValue / ConvertFromFactor
					}
				Case 'Profit Percentage':
					Property.Value := Property.ViewValue
					If !IsNumber(Property.Value) {
						Property.Value := 0
					}
				Case 'Stock Value':
					Property.Value := Property.ViewValue
					If !IsNumber(Property.Value) || Property.Value < 0 {
						Property.Value := 0
					}
				Case 'Latest Update':
					Property.Value := FormatTime(A_Now, 'yyyy/MM/dd | HH:mm:ss')
				Default:
					Property.Value := Property.ViewValue
			}
		}
	}
	; Write or save item into the hard drive
	writeItemProperties(NormalMod := False) {
		If !This.beforWriteItemProperties() {
			Return
		}
		If NormalMod {
			This.submitItemViewProperties()
		}
		Code := ItemPropertiesForms.GetText(1, 2)
		O := FileOpen(This.defaultLocation '\' Code, 'w')
		For Property in This.itemProperties {
			O.WriteLine(Property.Value)
		}
		O.Close
		If NormalMod {
			This.afterWriteItemProperties()
		}
	}
	showItemViewProperties() {
		For Property in This.itemProperties {
			Switch Property.Name {
				Case 'Thumbnail':
					If Property.Value {
						Thumb.Value := 'HBITMAP:*' appImage.hBitmapFromB64(Property.Value)
						itemPropertiesForms.Modify(A_Index,,, 'True')
					} Else {
						Thumb.Value := appImage.Picture['Default']
						itemPropertiesForms.Modify(A_Index,,, 'N/A')
					}
				Case 'Code128':
					itemPropertiesForms.Modify(A_Index,,, Property.Value ? 'True' : 'N/A')
				Default:
					itemPropertiesForms.Modify(A_Index,,, Property.ViewValue ? Property.ViewValue : 'N/A')
			}
		}
		This.colorizeItemViewProperties()
	}
	colorizeItemViewProperties() {
		For Property in This.itemProperties {
			backColor := !Mod(A_Index, 2) ? 0xFFFFFFFF : 0xFFE6E6E6
			If !Property.ViewValue {
				itemPropertiesFormsCLV.Cell(A_Index, 2, backColor, 0xFF808080)
			} Else Switch Property.Name {
				Case 'Code': itemPropertiesFormsCLV.Cell(A_Index, 2, backColor, 0xFF0000FF)
				Case 'Buy Value': itemPropertiesFormsCLV.Cell(A_Index, 2, backColor, 0xFFFF0000)
				Case 'Sell Value': itemPropertiesFormsCLV.Cell(A_Index, 2, backColor, 0xFF008000)
				Default: itemPropertiesFormsCLV.Cell(A_Index, 2, backColor, 0xFF000000)
			}
		}
	}
	deleteItemProperties() {
		Code := This.itemProperties[1].Value
		If Code = '' {
			MsgBox('Nothing to delete!', 'Create', 0x30)
			Return
		}
		Name := This.itemProperties[2].Value
		If 'Yes' != MsgBox('Are you sure to remove ' Name ' ?', 'Delete', 0x30 + 0x4) {
			Return
		}
		FileDelete(This.defaultLocation '\' Code)
		If Row := This.findItemInListView(Code, mainList) {
			mainList.Delete(Row)
		}
		If Row := This.findItemInListView(Code, searchList) {
			searchList.Delete(Row)
		}
		This.restoreItemPropertiesValues(True)
		MsgBox(Name ' is deleted!', 'Delete', 0x40)
	}
	pickItemThumbnail() {
		itemThumb := This.itemProperties[3]
		If itemThumb.Value {
			itemThumb.Value := ''
			This.readItemViewProperties()
			This.showItemViewProperties()
			Return
		}
		Image := FileSelect(,, "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico)")
		If !Image {
			Return
		}
		itemThumb.Value := appImage.b64ResizeImage(Image, 64, 64)
		This.readItemViewProperties()
		This.showItemViewProperties()
	}
	colorizeItemsList(List, ListCLV) {
		Loop List.GetCount() {
			Row := A_Index
			backColor := !Mod(Row, 2) ? 0xFFFFFFFF : 0xFFE6E6E6
			For Property in This.itemProperties {
				Switch Property.Name {
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
		BackupTo := (Default = This.defaultLocation) ? Default '\olddefs' : Default
		If !Default || !BackupTo {
			Return
		}
		If !DirExist(BackupTo) {
			DirCreate(BackupTo)
		}
		formatContent(Name, Content) {
			Code := SubStr(Name, 1, -4)
			If FileExist(This.defaultLocation '\' Code) {
				Return True
			}
			This.restoreItemPropertiesValues() 
			Try {
				This.itemProperties[1].Value := Code
				This.itemProperties[2].Value := Content[1]
				;This.itemProperties[4].Value := 'TND'
				This.itemProperties[5].Value := 'Piece (P)'
				This.itemProperties[6].Value := 1
				This.itemProperties[7].Value := Round(Content[2] / 1000, 3)
				This.itemProperties[8].Value := Round(Content[3] / 1000, 3)
				This.itemProperties[9].Value := Round(This.itemProperties[8].Value - This.itemProperties[7].Value, 3)
				This.itemProperties[10].Value := Round(This.itemProperties[9].Value / This.itemProperties[7].Value * 100, 2)
				This.itemProperties[11].Value := Content[4]
			} Catch {
				Return False
			}
			itemPropertiesForms.Modify(1,,, Code)
			This.writeItemProperties()
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
		itemPropertiesForms.Modify(1,,, '')
		Msgbox('Load Complete!', 'Load', 0x40)
	}
	loadItemsDefinitions() {
		Counted := 0
		StartTime := A_TickCount
		mainList.Delete()
		Loop Files, This.defaultLocation '\*' {
			If A_LoopFileExt {
				Continue
			}
			currentTask.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
			Code := A_LoopFileName
			If !This.readItemProperties(Code) {
				If 'Yes' = Msgbox('Invalid definition`n' Code, 'Abort?', 0x30 + 0x4) {
					Break
				}
			}
			This.readItemViewProperties()
			rowInfo := []
			For Property in This.itemProperties {
				rowInfo.Push(Property.ViewValue)
			}
			mainList.Add(, rowInfo*)
			++Counted
		}
		currentTask.Value := 'Loaded ' A_LoopFileName '... [ ' Counted ' ]'
		This.fitItemsListContent(mainList)
		This.colorizeItemsList(mainList, mainListCLV)
		currentTask.Value := Counted ' Item(s) loaded in ' Round((A_TickCount - StartTime) / 1000, 2) ' second(s)'
		mainList.Redraw()
	}
	roundItemRelatives() {
		Values := [This.itemProperties[7], This.itemProperties[8], This.itemProperties[9]]
		For Value in Values {
			If IsNumber(Value.ViewValue) {
				Value.ViewValue := Round(Value.ViewValue, This.Rounder)
			}
		}
		If IsNumber(This.itemProperties[10].ViewValue) {
			This.itemProperties[10].ViewValue := Round(This.itemProperties[10].ViewValue, 2)
		}
		This.showItemViewProperties()
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
		Buy := This.buy_ProfitPercent(Profit, Percent)
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
		Sell := This.sell_BuyPercent(Buy, Percent)
		Return Sell - Buy
	}
	profit_SellPercent(Sell, Percent) {
		Sell := !IsNumber(Sell) ? 0 : Sell
		Percent := !IsNumber(Percent) ? 0 : Percent
		Buy := This.buy_SellPercent(Sell, Percent)
		Return Sell - Buy 
	}
	; Percetage value auto update
	percent_BuySell(Buy, Sell) {
		Buy := !IsNumber(Buy) ? 0 : Buy
		If !Buy {
			Return 0
		}
		Sell := !IsNumber(Sell) ? 0 : Sell
		Profit := This.profit_BuySell(Buy, Sell)
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
		Buy := This.sell_BuyProfit(Sell, Profit)
		If !Buy {
			Return 0
		}
		Return Profit / Buy * 100
	}
	updateItemBuyValueRelatives() {
		Code := This.itemProperties[1]
		Buy := This.itemProperties[7]
		If !Code.ViewValue || !Buy.ViewValue {
			This.roundItemRelatives()
			Return
		}
		Sell := This.itemProperties[8]
		Profit := This.itemProperties[9]
		Percent := This.itemProperties[10]
		If Sell.ViewValue {
			Profit.ViewValue := This.profit_BuySell(Buy.ViewValue, Sell.ViewValue)
			Percent.ViewValue := This.percent_BuySell(Buy.ViewValue, Sell.ViewValue)
		}
		This.roundItemRelatives()
	}
	updateItemSellValueRelatives() {
		Code := This.itemProperties[1]
		Sell := This.itemProperties[8]
		If !Code.ViewValue || !Sell.ViewValue {
			This.roundItemRelatives()
			Return
		}
		Buy := This.itemProperties[7]
		Profit := This.itemProperties[9]
		Percent := This.itemProperties[10]
		If Buy.ViewValue {
			Profit.ViewValue := This.profit_BuySell(Buy.ViewValue, Sell.ViewValue)
			Percent.ViewValue := This.percent_BuySell(Buy.ViewValue, Sell.ViewValue)
		}
		This.roundItemRelatives()
	}
	updateItemProfitValueRelatives() {
		Code := This.itemProperties[1]
		Profit := This.itemProperties[9]
		If !Code.ViewValue || !Profit.ViewValue {
			This.roundItemRelatives()
			Return
		}
		Buy := This.itemProperties[7]
		Sell := This.itemProperties[8]
		Percent := This.itemProperties[10]
		If Buy.ViewValue {
			Sell.ViewValue := This.sell_BuyProfit(Buy.ViewValue, Profit.ViewValue)
			Percent.ViewValue := This.percent_BuyProfit(Buy.ViewValue, Profit.ViewValue)
		} Else If Percent.ViewValue {
			Sell.ViewValue := This.sell_ProfitPercent(Profit.ViewValue, Percent.ViewValue)
		}
		This.roundItemRelatives()
	}
	updateItemProfitPercentageRelatives() {
		Code := This.itemProperties[1]
		Percent := This.itemProperties[10]
		If !Code.ViewValue || !Percent.ViewValue {
			This.roundItemRelatives()
			Return
		}
		Buy := This.itemProperties[7]
		Sell := This.itemProperties[8]
		Profit := This.itemProperties[9]
		If Buy.ViewValue {
			Sell.ViewValue := This.sell_BuyPercent(Buy.ViewValue, Percent.ViewValue)
			Profit.ViewValue := This.profit_BuyPercent(Buy.ViewValue, Percent.ViewValue)
		} Else If Profit.ViewValue {
			Sell.ViewValue := This.sell_ProfitPercent(Profit.ViewValue, Percent.ViewValue)
		}
		This.roundItemRelatives()
	}
	updateItemAddedValue() {
		Added := This.itemProperties[12]
		If IsNumber(Added.ViewValue) {
			Added.ViewValue := Round(Added.ViewValue, This.Rounder)
		}
		This.showItemViewProperties()
	}
	searchItemInMainList(andSearch := False) {
		Counted := 0
		currentTask.Value := 'Looking...'
		searchIndexes := [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]
		searchList.Delete()
		Loop mainList.GetCount() {
			Row := A_Index
			ok1 := True
			ok2 := False
			hit1 := False
			hit2 := False
			For Index in searchIndexes {
				Col := Index
				If This.itemProperties[Col].ViewValue = '' {
					Continue
				}
				itemValue := mainList.GetText(Row, Col)
				ok1 := ok1 && (InStr(itemValue, This.itemProperties[Col].ViewValue))
				ok2 := ok2 || (InStr(itemValue, This.itemProperties[Col].ViewValue))
				hit1 := ok1
				hit2 := ok2 ? (!hit2 ? ok2 : hit2) : hit2
			}
			ok := andSearch ? hit1 : hit2
			If ok {
				Info := []
				Loop This.itemProperties.Length {
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
		This.fitItemsListContent(searchList)
		This.colorizeItemsList(searchList, searchListCLV)
		searchList.Redraw()
	}
	clearItemViewProperties() {
		This.restoreItemPropertiesValues()
		This.showItemViewProperties()
	}
	searchItemInMainListClear() {
		mainList.Visible := True
		searchList.Visible := False
		searchList.Delete()
	}
	changeItemCurrencyView(Currency) {
		This.selectedCurrency := Currency
		This.loadItemsDefinitions()
	}
	changeItemValueRounder(Rounder) {
		This.Rounder := Rounder
		This.loadItemsDefinitions()
	}
	generateItemCode128(Thickness := 1, Caption := False, BackColor := '0xFFFFFFFF', CodeColor := '0xFF000000') {
		Code := This.itemProperties[1].Value
		NAME := This.itemProperties[2].Value
		THUMB := This.itemProperties[3]
		If !CODE {
			MsgBox('The code is required', 'Create', 0x30)
			Return
		}
		Overwrite := True
		if THUMB.Value != '' {
			If 'Yes' != Msgbox('It seems like the barcode already generated!, overwrite?', 'Barcode', 0x40 + 0x4) {
				Overwrite := False
			}
		}
		If Overwrite {
			HEIGHT_OF_IMAGE := (Thickness * 20)
			HEIGHT_OF_CODE := HEIGHT_OF_IMAGE
			If Caption {
				HEIGHT_OF_IMAGE += HEIGHT_OF_IMAGE // 2
			}
			MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_128B(CODE)
			WIDTH_OF_IMAGE := (MATRIX_TO_PRINT.Length * Thickness) + 8
			pToken := Gdip_Startup()
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
				CAPTION_SIZE := CAPTION_H / 1.25
				Gdip_TextToGraphics(G, NAME, "s" CAPTION_SIZE " Bold x0 y" (HEIGHT_OF_CODE + 5) " w" CAPTION_W " h" CAPTION_H " C" CodeColor ' Center', "Arial")
			}
			THUMB.Value := Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
			mainList.Focus()
			Gdip_DisposeImage(pBitmap)
			Gdip_DeleteGraphics(G)
			Gdip_Shutdown(pToken)
		}
		barcoderWindow := Gui(, 'Barcode Code128')
		barcoderWindow.OnEvent('Close', (*) => barcoderWindow.Destroy())
		barcoderWindow.MarginX := 10
		barcoderWindow.MarginY := 10
		barcoderWindow.BackColor := 'White'
		barcoderPicture := barcoderWindow.AddPicture(, 'HBITMAP:*' appImage.hBitmapFromB64(This.itemCode128))
		base64Picture := This.itemProperties[13].Value
		barcoderWindow.AddButton('xm', 'Copy image to clipboard').OnEvent('Click', (*) => saveImageToClipboard())
		saveImageToClipboard() {
			pToken := Gdip_Startup()
			pBitmap := Gdip_BitmapFromBase64(base64Picture)
			Gdip_SetBitmapToClipboard(pBitmap)
			Gdip_DisposeImage(pBitmap)
			Gdip_Shutdown(pToken)
		}
		barcoderWindow.AddButton('yp', 'Copy base 64 image to clipboard').OnEvent('Click', (*) => savebase64ImageToClipboard())
		savebase64ImageToClipboard() {
			A_Clipboard := base64Picture
		}
		barcoderWindow.AddButton('yp', 'Save as JPG').OnEvent('Click', (*) => saveImageAsJPG())
		saveImageAsJPG() {
			saveLocation := FileSelect('S', NAME '.jpg')
			If !saveLocation {
				Return
			}
			pToken := Gdip_Startup()
			pBitmap := Gdip_BitmapFromBase64(base64Picture)
			Gdip_SaveBitmapToFile(pBitmap, saveLocation)
			Gdip_DisposeImage(pBitmap)
			Gdip_Shutdown(pToken)
		}
		barcoderWindow.Show()
		barcoderPicture.GetPos(, , &bW)
		barcoderWindow.GetPos(, , &wW)
		barcoderPicture.Move((wW - bW) / 2 - 5)
	}
}