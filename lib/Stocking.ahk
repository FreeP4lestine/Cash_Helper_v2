#Include <Imaging>
#Include <BarCoder>
class Stocking extends Imaging {
	__New(ItemPropFile := 'setting\ItemProperties'
	    , SellMethodsFile := 'setting\SellMethods'
	    , SellCurrencyFile := 'setting\SellCurrency'
		, DefaultLocation := 'setting\defs'
		, List1 := ''
		, List2 := ''
		, List3 := ''
		, List2CLV := ''
		, List1CLV := ''
		, List3CLV := ''
		, Thumb := ''
		, Log := '') {
		This.ItemPropFile := ItemPropFile
		This.SellMethodsFile := SellMethodsFile
		This.SellCurrencyFile := SellCurrencyFile
		This.DefaultLocation := DefaultLocation
		This.List1 := List1
		This.List2 := List2
		This.List3 := List3
		This.List2CLV := List2CLV
		This.List1CLV := List1CLV
		This.List3CLV := List3CLV
		This.Thumb := Thumb
		This.Log := Log
		This.Property := []
		This.PropertyName := Map()
		This.SellMethods := Map()
		This.SellCurrency := Map()
		This.ViewCurrency := ''
	}
	getSellCurrency() {
		If FileExist(This.SellCurrencyFile) {
			O := FileOpen(This.SellCurrencyFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellCurrency[Definition[1]] := {Unit: Definition[2], ConvertFactor: Definition[3]}
			}
			This.ViewCurrency := 'TNM'
		}
	}
	getSellMethods() {
		If FileExist(This.SellMethodsFile) {
			O := FileOpen(This.SellMethodsFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellMethods[Definition[1]] := {Value: Definition[2]}
			}
		}
	}
	getPropertiesNames() {
		If FileExist(This.ItemPropFile) {
			O := FileOpen(This.ItemPropFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.Property.Push({Name : Definition[1], Value : Definition[2], ViewValue : Definition[3]})
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
		This.Property[Row].Value := Value / This.SellCurrency[This.ViewCurrency].ConvertFactor
	}
	showPropertiesValues(Code, SelectInList := False, readFromFile := True) {
		If readFromFile {
			This.Thumb.Value := 'images\Default.png'
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
			This.List1.Modify(A_Index,,, Property.ViewValue)
		}
		If SelectInList && Row := This.findItemInList(Code) {
			This.List2.Focus()
			This.List2.Modify(Row, 'Select Vis')
		}
		This.updateValueColors()
		Return True
	}
	updateValueColors() {
		Loop This.List1.GetCount() {
			If This.Property[A_Index].Value = '' {
				This.List1CLV.Cell(A_Index, 2,, 0xFF808080)
				This.List1.Modify(A_Index,,, 'N/A')
			} Else Switch This.Property[A_Index].Name {
				Case 'Code' : This.List1CLV.Cell(A_Index, 2,, 0xFF0000FF)
				Case 'Buy Value' : This.List1CLV.Cell(A_Index, 2,, 0xFFFF0000)
				Case 'Sell Value' : This.List1CLV.Cell(A_Index, 2,, 0xFF008000)
				Default : This.List1CLV.Cell(A_Index, 2,, 0xFF000000)
			}
		}
		;This.List1.Redraw()
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
		;Try {
			This.cleanPropertyValues()
			O := FileOpen(This.DefaultLocation '\' Code, 'r')
			For Property in This.Property {
				Property.Value := O.ReadLine()
				Switch Property.Name {
					Case 'Thumbnail' :
						If Property.Value != '' {
							This.Thumb.Value := 'HBITMAP:*' This.hBitmapFromB64(Property.Value)
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
					Case 'Code128' :
						If This.Property[A_Index].Value != '' {
							Property.ViewValue := 'True'
						}
					Case 'Currency' :
						Property.ViewValue := This.ViewCurrency
					Case 'Buy Value', 'Sell Value', 'Profit Value', 'Added Value':
						If IsNumber(Property.Value) {
							Currency := This.ViewCurrency
							Property.ViewValue := Round(Property.Value * This.SellCurrency[Currency].ConvertFactor, 3)
						}
					Default : Property.ViewValue := (Property.Value != '') ? Property.Value : 'N/A'
				}
			}
			O.Close
		;} Catch as Err {
		;	Return False
		;}
		Return True
	}
	writeProperties(Prompt := True) {
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
				This.List1.Modify(A_Index,,, 'N/A')
			}
			O.Close
			updateInList(Code)
			updateInList(Code) {
				If !This.readProperties(Code) {
					Return
				}
				foundCode := This.findItemInList(Code, This.List2)
				Info := []
				For Property in This.Property {
					Info.Push(Property.ViewValue)
				}
				IsNumber(foundCode) ? This.List2.Modify(foundCode,, Info*) : This.List2.Insert(1,, Info*)
			}
		} Catch as Err {
			Return False
		}
		If Prompt {
			This.Thumb.Value := 'images\Default.png'
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
		If Row := This.findItemInList(Code, This.List2) {
			This.List2.Delete(Row)
		}
		If Row := This.findItemInList(Code, This.List3) {
			This.List3.Delete(Row)
		}
		This.cleanPropertyValues()
		This.showPropertiesValues(Code)
		MsgBox(Name ' is deleted!', 'Delete', 0x40)
	}
	pickThumbnail(autoRemove := True) {
		If autoRemove && This.PropertyName['Thumbnail'].Value != '' {
			This.PropertyName['Thumbnail'].Value := ''
			This.List1.Modify(3,,, 'N/A')
			This.Thumb.Value := This.Picture['Default']
			Return
		}
		Image := FileSelect(,, "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico)")
		If !Image {
			Return
		}
		b64 := This.b64ResizeImage(Image, 64, 64)
		This.PropertyName['Thumbnail'].Value := b64
		This.List1.Modify(3,,, 'True')
		This.Thumb.Value := 'HBITMAP:*' This.hBitmapFromB64(b64)
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
			If This.readProperties(Code) {
				Return True
			}
			Try {
				This.cleanPropertyValues()
				This.PropertyName['Code'].Value := Code
				This.PropertyName['Name'].Value := Content[1]
				This.PropertyName['Currency'].Value := 'TNM'
				This.PropertyName['Sell Method'].Value := 'Piece (P)'
				This.PropertyName['Sell Amount'].Value := 1
				If !IsNumber(This.PropertyName['Buy Value'].Value := Content[2]) 
				|| !IsNumber(This.PropertyName['Sell Value'].Value := Content[3])
				|| !IsNumber(This.PropertyName['Stock Value'].Value := Content[4]) {
					Return False
				}
				This.updateBuyValueRelatives() || This.updateSellValueRelatives() || This.updateProfitValueRelatives() || This.updateProfitPercentageRelatives()
			} Catch {
				If 'Yes' = Msgbox('Invalid old definition`n' Name, 'Abort?', 0x30 + 0x4) {
					Return False
				}
			}
			;This.showPropertiesValues(Code)
			This.writeProperties(0)
			Return True
		}
		Counted := 0
		Loop Files, Default '\*.def' {
			++Counted
			This.Log.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
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
		This.List2.Delete()
		Loop Files, This.DefaultLocation '\*' {
			If A_LoopFileExt {
				Continue
			}
			This.Log.Value := 'Loading ' A_LoopFileName '... [ ' Counted ' ]'
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
			This.List2.Add(, Info*)
			++Counted
		}
		This.Log.Value := 'Loaded ' A_LoopFileName '... [ ' Counted ' ]'
		Loop This.List2.GetCount('Col') {
			This.List2.ModifyCol(A_Index, 'AutoHdr Center')
		}
		This.Log.Value := Counted ' Item(s) loaded in ' Round((A_TickCount - StartTime) / 1000, 2) ' second(s)'
		updateList2Colors()
		updateList2Colors() {
			Loop This.List2.GetCount() {
				Row := A_Index
				For Propery in This.Property {
					Switch Propery.Name {
						Case 'Code' : This.List3CLV.Cell(Row, A_Index, Mod(A_Index, 2) = 0 ? 0xFFF0F0F0 : 0xFFFFFFFF, 0xFF0000FF)
						Case 'Buy Value' : This.List3CLV.Cell(Row, A_Index, Mod(A_Index, 2) = 0 ? 0xFFF0F0F0 : 0xFFFFFFFF, 0xFFFF0000)
						Case 'Sell Value' : This.List3CLV.Cell(Row, A_Index, Mod(A_Index, 2) = 0 ? 0xFFF0F0F0 : 0xFFFFFFFF, 0xFF008000)
					}
				}
			}
			This.List2.Redraw()
		}
	}
	updateCurrencyValues() {
		This.PropertyName['Buy Value'].Value := This.PropertyName['Buy Value'].ViewValue / This.SellCurrency[This.ViewCurrency].ConvertFactor
		This.PropertyName['Sell Value'].Value := This.PropertyName['Sell Value'].ViewValue / This.SellCurrency[This.ViewCurrency].ConvertFactor
		This.PropertyName['Profit Value'].Value := This.PropertyName['Profit Value'].ViewValue / This.SellCurrency[This.ViewCurrency].ConvertFactor
		This.PropertyName['Added Value'].Value := This.PropertyName['Added Value'].ViewValue / This.SellCurrency[This.ViewCurrency].ConvertFactor
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
			This.PropertyName['Profit Percentage'].ViewValue := Round(This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100, 2)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
		If IsNumber(This.PropertyName['Profit Value'].ViewValue) {
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Profit Value'].ViewValue + This.PropertyName['Buy Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := Round(This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100, 2)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
		If IsNumber(This.PropertyName['Profit Percentage'].ViewValue) {
			This.PropertyName['Sell Value'].ViewValue := Round(This.PropertyName['Profit Percentage'].ViewValue / 100 * This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Buy Value'].ViewValue)
			This.PropertyName['Profit Value'].ViewValue := Round(This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
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
			This.PropertyName['Profit Percentage'].ViewValue := Round(This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100, 2)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
		If IsNumber(This.PropertyName['Profit Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Profit Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := Round(This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100, 2)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
		If IsNumber(This.PropertyName['Profit Percentage'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := Round(This.PropertyName['Sell Value'].ViewValue - (This.PropertyName['Sell Value'].ViewValue / (1 + This.PropertyName['Profit Percentage'].ViewValue / 100)))
			This.PropertyName['Profit Value'].ViewValue := Round(This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
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
			This.PropertyName['Profit Percentage'].ViewValue := Round(This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100, 2)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
		If IsNumber(This.PropertyName['Sell Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Profit Value'].ViewValue
			This.PropertyName['Profit Percentage'].ViewValue := Round(This.PropertyName['Profit Value'].ViewValue / This.PropertyName['Buy Value'].ViewValue * 100, 2)
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
		If IsNumber(This.PropertyName['Profit Percentage'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := Round((1 / (This.PropertyName['Profit Percentage'].ViewValue / 100) * This.PropertyName['Profit Value'].ViewValue))
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Profit Value'].ViewValue
			This.showPropertiesValues(Code,, False)
			This.updateCurrencyValues()
			Return True
		}
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
			This.PropertyName['Sell Value'].ViewValue := Round(This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Buy Value'].ViewValue * This.PropertyName['Profit Percentage'].ViewValue / 100)
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
			This.showPropertiesValues(Code,, False)
			Return True
		}
		If IsNumber(This.PropertyName['Sell Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := Round(This.PropertyName['Sell Value'].ViewValue / (1 + This.PropertyName['Profit Percentage'].ViewValue / 100))
			This.PropertyName['Profit Value'].ViewValue := This.PropertyName['Sell Value'].ViewValue - This.PropertyName['Buy Value'].ViewValue
			This.showPropertiesValues(Code,, False)
			Return True
		}
		If IsNumber(This.PropertyName['Profit Value'].ViewValue) {
			This.PropertyName['Buy Value'].ViewValue := Round((1 / (This.PropertyName['Profit Percentage'].ViewValue / 100) * This.PropertyName['Profit Value'].ViewValue))
			This.PropertyName['Sell Value'].ViewValue := This.PropertyName['Buy Value'].ViewValue + This.PropertyName['Profit Value'].ViewValue
			This.showPropertiesValues(Code,, False)
			Return True
		}
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
		;MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_39(Code)
		;MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_ITF(Code)
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
		This.List2.Focus()
		Gdip_DisposeImage(pBitmap)
		Gdip_DeleteGraphics(G)
		Gdip_Shutdown(pToken)
		}
		barcoderWindow := Gui(, 'Barcode Code128B')
		barcoderWindow.OnEvent('Close', (*) => barcoderWindow.Destroy())
		barcoderWindow.MarginX := 10
		barcoderWindow.MarginY := 10
		barcoderWindow.BackColor := 'White'
		barcoderPicture := barcoderWindow.AddPicture(, 'HBITMAP:*' This.hBitmapFromB64(This.PropertyName['Code128'].Value))
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
		barcoderPicture.GetPos(,,&bW)
		barcoderWindow.GetPos(,,&wW)
		barcoderPicture.Move((wW - bW) / 2 - 5)
	}
	searchItemInList(andSearch := False) {
		searchIndexes := [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]
		This.List3.Delete()
		Loop This.List2.GetCount() {
			Row := A_Index
			ok1 := True
			ok2 := False
			hit1 := False
			hit2 := False
			For Index in searchIndexes {
				Col := A_Index
				If This.Property[Col].Value = '' {
					Continue
				}
				itemValue := This.List2.GetText(Row, Col)
				ok1 := ok1 && (InStr(itemValue, This.Property[Col].Value))
				ok2 := ok2 || (InStr(itemValue, This.Property[Col].Value))
				hit1 := ok1
				hit2 := ok2 ? (!hit2 ? ok2 : hit2) : hit2
			}
			ok := andSearch ? hit1 : hit2
			If ok {
				Info := []
				Loop This.Property.Length {
					Info.Push(This.List2.GetText(Row, A_Index))
				}
				This.List3.Add(, Info*)
			}
		}
		Loop This.List3.GetCount('Col') {
			This.List3.ModifyCol(A_Index, 'AutoHdr Center')
		}
		This.List2.Visible := False
		This.List3.Visible := True
		updateList3Colors()
		updateList3Colors() {
			Loop This.List3.GetCount() {
				Row := A_Index
				For Propery in This.Property {
					Switch Propery.Name {
						Case 'Code' : This.List3CLV.Cell(Row, A_Index, Mod(A_Index, 2) = 0 ? 0xFFDCEEFF : 0xFFFFFFFF, 0xFF0000FF)
						Case 'Buy Value' : This.List3CLV.Cell(Row, A_Index, Mod(A_Index, 2) = 0 ? 0xFFDCEEFF : 0xFFFFFFFF, 0xFFFF0000)
						Case 'Sell Value' : This.List3CLV.Cell(Row, A_Index, Mod(A_Index, 2) = 0 ? 0xFFDCEEFF : 0xFFFFFFFF, 0xFF008000)
					}
				}
			}
			This.List3.Redraw()
		}
	}
	searchClear() {
		This.List2.Visible := True
		This.List3.Visible := False
		This.List3.Delete()
	}
	inputsClear() {
		This.cleanPropertyValues()
		This.showPropertiesValues('')
	}
}
