class Stock {
	__New(ItemPropFile := 'setting\ItemProperties', SellMethodsFile := 'setting\SellMethods', SellCurrencyFile := 'setting\SellCurrency', DefaultLocation := 'setting\defs') {
		This.ItemPropFile := ItemPropFile
		This.SellMethodsFile := SellMethodsFile
		This.SellCurrencyNameFile := SellCurrencyFile
		This.DefaultLocation := DefaultLocation
		This.Property := []
		This.PropertyName := Map()
		This.SellMethods := Map()
		This.SellCurrency := []
		This.SellCurrencyName := Map()
		This.ViewCurrency := ''
		This.Rounder := 3
	}
	getSellCurrency() {
		If FileExist(This.SellCurrencyNameFile) {
			O := FileOpen(This.SellCurrencyNameFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellCurrency.Push({ Symbol: Definition[1], Name: Definition[2], ConvertFactor: Definition[3] })
				This.SellCurrencyName[Definition[1]] := { Name: Definition[2], ConvertFactor: Definition[3] }
			}
			This.ViewCurrency := 'TND'
		}
	}
	getSellMethods() {
		If FileExist(This.SellMethodsFile) {
			O := FileOpen(This.SellMethodsFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellMethods[Definition[1]] := { Value: Definition[2] }
			}
		}
	}
	getPropertiesNames() {
		If FileExist(This.ItemPropFile) {
			O := FileOpen(This.ItemPropFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.Property.Push({ Name: Definition[1], Value: Definition[2], ViewValue: Definition[3] })
				This.PropertyName[This.Property[A_Index].Name] := This.Property[A_Index]
			}
		}
	}
	cleanPropertyValues() {
		For Property in This.Property {
			Property.Value := ''
			Property.ViewValue := ''
		}
	}
	writePropertyValues(Row, Value) {
		This.Property[Row].ViewValue := Value
		Switch This.Property[Row].Name {
			Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value': This.Property[Row].Value := Value != '' ? Value / This.SellCurrencyName[This.ViewCurrency].ConvertFactor : ''
			Default: This.Property[Row].Value := This.Property[Row].ViewValue
		}
	}
	showPropertiesValues(Code, SelectInList := False, readFromFile := True) {
		If readFromFile {
			Thumb.Value := 'images\Default.png'
			This.updateValueColors()
			This.cleanPropertyValues()
			If !FileExist(This.DefaultLocation '\' Code) || DirExist(This.DefaultLocation '\' Code) {
				Return
			}
			If !This.readProperties(Code) {
				Return
			}
		}
		For Property in This.Property {
			Switch Property.Name {
				Case 'Profit Percentage': itemForms.Modify(A_Index, , , Property.ViewValue != '' ? Round(Property.ViewValue, 2) : 'N/A')
				Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
					itemForms.Modify(A_Index, , , Property.ViewValue != '' ? Round(Property.ViewValue, This.Rounder) : 'N/A')
				Default: itemForms.Modify(A_Index, , , Property.ViewValue)
			}
		}
		If SelectInList && Row := This.findItemInList(Code) {
			mainList.Focus()
			mainList.Modify(Row, 'Select Vis')
		}
		This.updateValueColors()
		Return True
	}
	updateValueColors() {
		For Property in This.Property {
			If Property.Value = '' {
				itemFormsCLV.Cell(A_Index, 2, , 0xFF808080)
				itemForms.Modify(A_Index, , , 'N/A')
			} Else Switch Property.Name {
				Case 'Code': itemFormsCLV.Cell(A_Index, 2, , 0xFF0000FF)
				Case 'Buy Value': itemFormsCLV.Cell(A_Index, 2, , 0xFFFF0000)
				Case 'Sell Value': itemFormsCLV.Cell(A_Index, 2, , 0xFF008000)
				Default: itemFormsCLV.Cell(A_Index, 2, , 0xFF000000)
			}
		}
		;itemForms.Redraw()
	}
	showItemInList(Code, List) {
		If Row := This.findItemInList(Code) {
			List.Focus()
			List.Modify(Row, 'Select Vis')
		}
	}
	findItemInList(Code, List) {
		foundCode := ''
		Loop List.GetCount() {
			foundCode := List.GetText(A_Index)
			If foundCode = Code {
				foundCode := A_Index
				Break
			}
			foundCode := ''
		}
		Return foundCode
	}
	readProperties(Code) {
		This.cleanPropertyValues()
		O := FileOpen(This.DefaultLocation '\' Code, 'r')
		For Property in This.Property {
			Property.Value := O.ReadLine()
			Switch Property.Name {
				Case 'Thumbnail':
					If Property.Value != '' {
						Thumb.Value := 'HBITMAP:*' appImage.hBitmapFromB64(Property.Value)
						Property.ViewValue := 'True'
					}
				Case 'Sell Method':
					Method := This.PropertyName['Sell Method'].Value
					If Property.Value = '' || !This.SellMethods.Has(Method) {
						Property.Value := 'Piece (P)'
					}
					Property.ViewValue := Property.Value
				Case 'Sell Amount':
					Method := This.PropertyName['Sell Method'].Value
					If Property.Value = '' {
						Property.Value := This.SellMethods[Method].Value
					}
					Property.ViewValue := Property.Value
				Case 'Code128':
					If This.Property[A_Index].Value != '' {
						Property.ViewValue := 'True'
					}
				Case 'Currency': Property.ViewValue := This.ViewCurrency
				Case 'Profit Percentage': Property.ViewValue := Round(Property.Value ? Property.Value : 0, 2)
				Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
					If IsNumber(Property.Value) {
						Currency := This.ViewCurrency
						This.SellCurrencyName[Currency].ConvertFactor
						Property.ViewValue := Round(Property.Value * This.SellCurrencyName[Currency].ConvertFactor, This.Rounder)
					}
				Case 'Stock Value':
					Property.Value := (!Property.Value || Property.Value) < 0 ? 0 : Property.Value
					Property.ViewValue := Property.Value
				Default: Property.ViewValue := (Property.Value != '') ? Property.Value : 'N/A'
			}
		}
		O.Close
		Return True
	}
	writeProperties(Prompt := True, Insert := True) {
		Try {
			Code := This.PropertyName['Code'].Value
			If Code = '' || Code = 'N/A' {
				MsgBox('The code is required', 'Create', 0x30)
				Return
			}
			If Code ~= '[^A-Za-z0-9_]' {
				MsgBox('The code is incorrect', 'Create', 0x30)
				Return
			}
			If Prompt && FileExist(This.DefaultLocation '\' Code) {
				If 'Yes' != MsgBox(Code ' already exist you want to update it?', 'Confirm [1]', 0x40 + 0x4) {
					Return
				}
				If 'Yes' != MsgBox(Code ' already exist you want to update it?', 'Confirm [2]', 0x40 + 0x4) {
					Return
				}
				If 'Yes' != MsgBox('Overwriting other defintions may create unwanted issues`nPlease be aware of what are you doing!`nContinue?', 'Confirm [3]', 0x30 + 0x4)
					Return
			}
			O := FileOpen(This.DefaultLocation '\' Code, 'w')
			For Property in This.Property {
				O.WriteLine(Property.Value)
				itemForms.Modify(A_Index, , , 'N/A')
			}
			O.Close
			updateInList(Code)
			updateInList(Code) {
				If !This.readProperties(Code) {
					Return
				}
				foundCode := This.findItemInList(Code, mainList)
				Info := []
				For Property in This.Property {
					Info.Push(Property.ViewValue)
				}
				IsNumber(foundCode) ? mainList.Modify(foundCode, , Info*) : (Insert ? mainList.Insert(1, , Info*) : '')
			}
		} Catch as Err {
			Return False
		}
		If Prompt {
			Thumb.Value := 'images\Default.png'
			This.cleanPropertyValues()
			This.updateValueColors()
			Msgbox(Code ' is updated!', 'Update', 0x40)
		}
		Return True
	}
	deleteProperties(Prompt := True) {
		Code := This.PropertyName['Code'].Value
		If Code = '' || Code = 'N/A' {
			MsgBox('The code is required', 'Create', 0x30)
			Return
		}
		Name := This.PropertyName['Name'].Value
		If Prompt && 'Yes' != MsgBox('Are you sure to remove ' Name ' ?', 'Delete', 0x30 + 0x4) {
			Return
		}
		FileDelete(This.DefaultLocation '\' Code)
		If Row := This.findItemInList(Code, mainList) {
			mainList.Delete(Row)
		}
		If Row := This.findItemInList(Code, searchList) {
			searchList.Delete(Row)
		}
		This.cleanPropertyValues()
		This.showPropertiesValues(Code)
		MsgBox(Name ' is deleted!', 'Delete', 0x40)
	}
	pickThumbnail(autoRemove := True) {
		If autoRemove && This.PropertyName['Thumbnail'].Value != '' {
			This.PropertyName['Thumbnail'].Value := ''
			itemForms.Modify(3, , , 'N/A')
			Thumb.Value := This.Picture['Default']
			Return
		}
		Image := FileSelect(, , "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico)")
		If !Image {
			Return
		}
		b64 := This.b64ResizeImage(Image, 64, 64)
		This.PropertyName['Thumbnail'].Value := b64
		itemForms.Modify(3, , , 'True')
		Thumb.Value := 'HBITMAP:*' appImage.hBitmapFromB64(b64)
	}
	chargeOldDefinitions() {
		Default := FileSelect('D')
		BackupTo := (Default = This.DefaultLocation) ? Default '\olddefs' : Default
		If !Default || !BackupTo {
			Return
		}
		If !DirExist(BackupTo) {
			DirCreate(BackupTo)
		}
		FormatContent(Name, Content) {
			Code := SubStr(Name, 1, -4)
			If FileExist(This.DefaultLocation '\' Code) {
				Return True
			}
			This.cleanPropertyValues()
			This.PropertyName['Code'].Value := Code
			This.PropertyName['Code'].ViewValue := Code
			This.PropertyName['Name'].Value := Content[1]
			This.PropertyName['Name'].ViewValue := Content[1]
			This.PropertyName['Currency'].Value := 'TND'
			This.PropertyName['Currency'].ViewValue := 'TND'
			This.PropertyName['Sell Method'].Value := 'Piece (P)'
			This.PropertyName['Sell Method'].ViewValue := 'Piece (P)'
			This.PropertyName['Sell Amount'].Value := 1
			This.PropertyName['Sell Amount'].ViewValue := 1
			This.PropertyName['Buy Value'].Value := Content[2]
			This.PropertyName['Buy Value'].ViewValue := Content[2] / 1000
			This.PropertyName['Sell Value'].Value := Content[3] / 1000
			This.PropertyName['Sell Value'].ViewValue := Content[3] / 1000
			This.PropertyName['Stock Value'].Value := Content[4] / 1000
			This.PropertyName['Stock Value'].ViewValue := Content[4]
			If !IsNumber(This.PropertyName['Buy Value'].Value)
				|| !IsNumber(This.PropertyName['Sell Value'].Value)
				|| !IsNumber(This.PropertyName['Stock Value'].Value) {
					Return False
			}
			This.updateBuyValueRelatives()
			This.writeProperties(0, 0)
			Return True
		}
		Counted := 0
		Loop Files, Default '\*.def' {
			++Counted
			Log.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
			Content := StrSplit(FileRead(A_LoopFileFullPath), ';')
			If !FormatContent(A_LoopFileName, Content) {
				Break
			}
			If !FileExist(BackupTo '\' A_LoopFileName) {
				FileMove(A_LoopFileFullPath, BackupTo)
			}
		}
		This.viewDefinitionsList()
		Msgbox('Load Complete!', 'Load', 0x40)
	}
	viewDefinitionsList() {
		Counted := 0
		StartTime := A_TickCount
		mainList.Delete()
		Loop Files, This.DefaultLocation '\*' {
			If A_LoopFileExt {
				Continue
			}
			Log.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
			Code := A_LoopFileName
			If !This.readProperties(Code) {
				If 'Yes' = Msgbox('Invalid definition`n' Code, 'Abort?', 0x30 + 0x4) {
					Break
				}
			}
			Info := []
			For Property in This.Property {
				Info.Push(Property.ViewValue)
			}
			mainList.Add(, Info*)
			++Counted
		}
		Log.Value := 'Loaded ' A_LoopFileName '... [ ' Counted ' ]'
		Loop mainList.GetCount('Col') {
			mainList.ModifyCol(A_Index, 'AutoHdr Center')
		}
		Log.Value := Counted ' Item(s) loaded in ' Round((A_TickCount - StartTime) / 1000, 2) ' second(s)'
		updateList2Colors()
		This.cleanPropertyValues()
		updateList2Colors() {
			Loop mainList.GetCount() {
				Row := A_Index
				For Propery in This.Property {
					Switch Propery.Name {
						Case 'Code': mainListCLV.Cell(Row, A_Index, Mod(Row, 2) = 0 ? 0xFFF0F0F0 : 0xFFFFFFFF, 0xFF0000FF)
						Case 'Buy Value': mainListCLV.Cell(Row, A_Index, Mod(Row, 2) = 0 ? 0xFFF0F0F0 : 0xFFFFFFFF, 0xFFFF0000)
						Case 'Sell Value': mainListCLV.Cell(Row, A_Index, Mod(Row, 2) = 0 ? 0xFFF0F0F0 : 0xFFFFFFFF, 0xFF008000)
					}
				}
			}
			mainList.Redraw()
		}
	}
	updateCurrencyValues() {
		If This.PropertyName['Buy Value'].ViewValue != ''
			This.PropertyName['Buy Value'].Value := This.PropertyName['Buy Value'].ViewValue / This.SellCurrencyName[This.ViewCurrency].ConvertFactor
		If This.PropertyName['Sell Value'].ViewValue != ''
			This.PropertyName['Sell Value'].Value := This.PropertyName['Sell Value'].ViewValue / This.SellCurrencyName[This.ViewCurrency].ConvertFactor
		If This.PropertyName['Profit Value'].ViewValue != ''
			This.PropertyName['Profit Value'].Value := This.PropertyName['Profit Value'].ViewValue / This.SellCurrencyName[This.ViewCurrency].ConvertFactor
		This.PropertyName['Profit Percentage'].Value := This.PropertyName['Profit Percentage'].ViewValue
		If This.PropertyName['Added Value'].ViewValue != ''
			This.PropertyName['Added Value'].Value := This.PropertyName['Added Value'].ViewValue / This.SellCurrencyName[This.ViewCurrency].ConvertFactor
	}
	updateBuyValueRelatives() {
		If !(Code := This.PropertyName['Code'].ViewValue)
			|| !IsNumber(This.PropertyName['Buy Value'].ViewValue)
			|| !(IsNumber(This.PropertyName['Sell Value'].ViewValue)
				|| IsNumber(This.PropertyName['Profit Value'].ViewValue)
				|| IsNumber(This.PropertyName['Profit Percentage'].ViewValue)) {
					Return
		}
		If IsNumber(This.PropertyName['Sell Value'].ViewValue) {
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100
		} Else If IsNumber(This.PropertyName['Profit Value'].ViewValue) {
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Profit Value'].ViewValue + This.PropertyName['Buy Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100
		} Else If IsNumber(This.PropertyName['Profit Percentage'].ViewValue) {
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Profit Percentage'].ViewValue / 100 * This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Buy Value'].ViewValue
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
		}
		This.updateCurrencyValues()
	}
	updateSellValueRelatives() {
		If !(Code := This.PropertyName['Code'].ViewValue)
			|| !IsNumber(This.PropertyName['Sell Value'].ViewValue)
			|| (!IsNumber(This.PropertyName['Buy Value'].ViewValue)
				&& !IsNumber(This.PropertyName['Profit Value'].ViewValue)
				&& !IsNumber(This.PropertyName['Profit Percentage'].ViewValue)) {
					Return
		}
		If IsNumber(This.PropertyName['Buy Value'].ViewValue) {
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100
		} Else If IsNumber(This.PropertyName['Profit Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Profit Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100
		} Else If IsNumber(This.PropertyName['Profit Percentage'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - (This.PropertyName['Sell Value'].ViewValue / (1 + This.PropertyName['Profit Percentage'].ViewValue / 100))
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
		}
		This.updateCurrencyValues()
	}
	updateProfitValueRelatives() {
		If !(Code := This.PropertyName['Code'].ViewValue)
			|| !IsNumber(This.PropertyName['Profit Value'].ViewValue)
			|| (!IsNumber(This.PropertyName['Sell Value'].ViewValue)
				&& !IsNumber(This.PropertyName['Buy Value'].ViewValue)
				&& !IsNumber(This.PropertyName['Profit Percentage'].ViewValue)) {
					Return
		}
		If IsNumber(This.PropertyName['Buy Value'].ViewValue) {
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Profit Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100
		} Else If IsNumber(This.PropertyName['Sell Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Profit Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100
		} Else If IsNumber(This.PropertyName['Profit Percentage'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := (1 / (This.PropertyName['Profit Percentage'].ViewValue / 100) * This.PropertyName['Profit Value'].ViewValue)
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Profit Value'].ViewValue
		}
		This.updateCurrencyValues()
	}
	updateProfitPercentageRelatives() {
		If !(Code := This.PropertyName['Code'].ViewValue)
			|| !IsNumber(This.PropertyName['Profit Percentage'].ViewValue)
			|| (!IsNumber(This.PropertyName['Buy Value'].ViewValue)
				&& !IsNumber(This.PropertyName['Sell Value'].ViewValue)
				&& !IsNumber(This.PropertyName['Profit Value'].ViewValue)) {
					Return
		}
		If IsNumber(This.PropertyName['Buy Value'].ViewValue) {
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Buy Value'].ViewValue * This.PropertyName['Profit Percentage'].ViewValue / 100
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
		} Else If IsNumber(This.PropertyName['Sell Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue / (1 + This.PropertyName['Profit Percentage'].ViewValue / 100)
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
		} Else If IsNumber(This.PropertyName['Profit Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := 1 / (This.PropertyName['Profit Percentage'].ViewValue / 100) * This.PropertyName['Profit Value'].ViewValue
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Profit Value'].ViewValue
		}
		This.updateCurrencyValues()
	}
	generateCode128(Thickness := 1, Caption := False, BackColor := '0xFFFFFFFF', CodeColor := '0xFF000000') {
		If !Code := This.PropertyName['Code'].Value {
			MsgBox('The code is required', 'Create', 0x30)
			Return
		}
		NAME := This.PropertyName['Name'].Value
		Overwrite := True
		if This.PropertyName['Code128'].Value != '' {
			If 'Yes' != Msgbox('The barcode already generated!, overwrite?', 'Barcode', 0x40 + 0x4) {
				Overwrite := False
			}
		}
		If Overwrite {
			HEIGHT_OF_IMAGE := (Thickness * 20)
			HEIGHT_OF_CODE := HEIGHT_OF_IMAGE
			If Caption {
				HEIGHT_OF_IMAGE += HEIGHT_OF_IMAGE // 2
			}
			MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_128B(Code)
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
				CAPTION_SIZE := (CAPTION_H) / 1.25
				Gdip_TextToGraphics(G, NAME, "s" CAPTION_SIZE " Bold x0 y" (HEIGHT_OF_CODE + 5) " w" CAPTION_W " h" CAPTION_H " C" CodeColor ' Center', "Arial")
			}
			This.PropertyName['Code128'].Value := Gdip_EncodeBitmapTo64string(pBitmap, "JPG")
			This.writeProperties(False)
			This.showPropertiesValues(Code)
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
		barcoderPicture := barcoderWindow.AddPicture(, 'HBITMAP:*' appImage.hBitmapFromB64(This.PropertyName['Code128'].Value))
		base64Picture := This.PropertyName['Code128'].Value
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
	searchItemInList(andSearch := False) {
		Counted := 0
		Log.Value := 'Looking...'
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
				If This.Property[Col].ViewValue = '' {
					Continue
				}
				itemValue := mainList.GetText(Row, Col)
				ok1 := ok1 && (InStr(itemValue, This.Property[Col].ViewValue))
				ok2 := ok2 || (InStr(itemValue, This.Property[Col].ViewValue))
				hit1 := ok1
				hit2 := ok2 ? (!hit2 ? ok2 : hit2) : hit2
			}
			ok := andSearch ? hit1 : hit2
			If ok {
				Info := []
				Loop This.Property.Length {
					Info.Push(mainList.GetText(Row, A_Index))
				}
				searchList.Add(, Info*)
				++Counted
			}
			Log.Value := '[ ' Counted ' ] Items are found!'
		}
		Loop searchList.GetCount('Col') {
			searchList.ModifyCol(A_Index, 'AutoHdr Center')
		}
		mainList.Visible := False
		searchList.Visible := True
		updateList3Colors()
		updateList3Colors() {
			Loop searchList.GetCount() {
				Row := A_Index
				For Propery in This.Property {
					Switch Propery.Name {
						Case 'Code': searchListCLV.Cell(Row, A_Index, Mod(Row, 2) = 0 ? 0xFFE0FFE0 : 0xFFFFFFFF, 0xFF0000FF)
						Case 'Buy Value': searchListCLV.Cell(Row, A_Index, Mod(Row, 2) = 0 ? 0xFFE0FFE0 : 0xFFFFFFFF, 0xFFFF0000)
						Case 'Sell Value': searchListCLV.Cell(Row, A_Index, Mod(Row, 2) = 0 ? 0xFFE0FFE0 : 0xFFFFFFFF, 0xFF008000)
					}
				}
			}
			searchList.Redraw()
		}
	}
	searchClear() {
		mainList.Visible := True
		searchList.Visible := False
		searchList.Delete()
	}
	inputsClear() {
		This.cleanPropertyValues()
		This.showPropertiesValues('')
	}
	changeCurrencyView(Currency) {
		This.ViewCurrency := Currency
		This.viewDefinitionsList()
	}
	changeValueRounder(Rounder) {
		This.Rounder := Rounder
		This.viewDefinitionsList()
	}
}