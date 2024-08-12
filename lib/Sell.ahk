class Sell {
    __New(DefaultLocation := 'setting\defs', ItemPropFile := 'setting\ItemProperties', SellMethodsFile := 'setting\SellMethods', SellCurrencyFile := 'setting\SellCurrency') {
        This.DefaultLocation := DefaultLocation
        This.ItemPropFile := ItemPropFile
        This.SellMethodsFile := SellMethodsFile
        This.SellCurrencyFile := SellCurrencyFile
        This.tempRow := 0
        This.PropertyName := Map()
        This.Property := []
        This.SellCurrencyName := Map()
        This.SellCurrency := []
        This.ViewCurrency := ''
		This.Rounder := 3
        This.SellMethods := Map()
		This.SellList := Map()
		This.Session := []
    }
    clearTempRow() {
        If This.tempRow {
            mainList.Delete(This.tempRow)
            This.tempRow := 0
        }
    }
    cleanPropertyValues() {
		For Property in This.Property {
			Property.Value := ''
			Property.ViewValue := ''
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
	getSellCurrency() {
		If FileExist(This.SellCurrencyFile) {
			O := FileOpen(This.SellCurrencyFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellCurrency.Push({ Symbol: Definition[1], Name: Definition[2], ConvertFactor: Definition[3] })
				This.SellCurrencyName[Definition[1]] := { Name: Definition[2], ConvertFactor: Definition[3] }
			}
			This.ViewCurrency := 'TND'
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
            O.Close()
		}
	}
    readProperties(Code) {
		This.cleanPropertyValues()
		O := FileOpen(This.DefaultLocation '\' Code, 'r')
		For Property in This.Property {
			Property.Value := O.ReadLine()
			Switch Property.Name {
				Case 'Thumbnail':
					If Property.Value != '' {
						;Thumb.Value := 'HBITMAP:*' appImage.hBitmapFromB64(Property.Value)
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
    analyzeCode(Code) {
        Code := Trim(Code, ' ')
        If Code = '' 
        || !FileExist(This.DefaultLocation '\' Code) 
        || !This.readProperties(Code) {
            This.clearTempRow()
            Return
        }
        This.clearTempRow()
        This.tempRow := mainList.Add(,, This.PropertyName['Code'].ViewValue
                                      , This.PropertyName['Name'].ViewValue
                                      , This.PropertyName['Sell Method'].ViewValue
                                      , This.PropertyName['Sell Amount'].ViewValue
                                      , This.PropertyName['Sell Value'].ViewValue
                                      , This.PropertyName['Sell Value'].ViewValue
									  , This.ViewCurrency)
        mainListCLV.Row(This.tempRow,, 0xFF999999)
		mainListCLV.Cell(This.tempRow, 1, 0xFF999999)
		mainListCLV.Cell(This.tempRow, 8, 0xFFB2B2B2)
    }
	updateQuantityPrice(Row, Amount) {
		Code := mainList.GetText(Row, 2)
		If This.SellList.Has(Code) {
			This.SellList[Code].Quantity := Amount
			Quantity := Round(This.SellList[Code].Quantity / This.PropertyName['Sell Amount'].ViewValue, This.Rounder)
			This.SellList[Code].Price := Round(This.PropertyName['Sell Value'].ViewValue * Quantity, This.Rounder)
			mainList.Modify(This.SellList[Code].Row,,,,,, This.SellList[Code].Quantity,, This.SellList[Code].Price)
			This.clearTempRow()
			This.updatePriceSum()
		}
	}
	addItemToList() {
		enteredCode.Value := ''
		If !This.tempRow {
			Return
		}
		Code := This.PropertyName['Code'].ViewValue
		If This.SellList.Has(Code) {
			This.SellList[Code].Quantity += This.PropertyName['Sell Amount'].ViewValue
			Quantity := Round(This.SellList[Code].Quantity / This.PropertyName['Sell Amount'].ViewValue, This.Rounder)
			This.SellList[Code].Price := Round(This.PropertyName['Sell Value'].ViewValue * Quantity, This.Rounder)
			mainList.Modify(This.SellList[Code].Row,,,,,, This.SellList[Code].Quantity,, This.SellList[Code].Price)
			This.clearTempRow()
			This.updatePriceSum()
			Return
		}
		This.SellList[Code] := {Row: This.tempRow, Definition: This.PropertyName, Quantity: This.PropertyName['Sell Amount'].ViewValue, Price: This.PropertyName['Sell Value'].ViewValue}
		mainListCLV.Row(This.tempRow,, 0xFF000000)
		mainListCLV.Cell(This.tempRow, 1, 0xFF000000)
		mainListCLV.Cell(This.tempRow, 5,, 0xFF0000FF)
		mainListCLV.Cell(This.tempRow, 7,, 0xFFFF0000)
		mainListCLV.Cell(This.tempRow, 8, 0xFF000000, 0xFFFFFFFF)
		This.tempRow := 0
		mainList.Redraw()
		This.updatePriceSum()
	}
	updatePriceSum() {
		Sum := 0
		For Code, Item in This.SellList {
			Sum += Item.Price
		}
		priceSum.Value := Sum > 0 ? Round(Sum, This.Rounder) ' ' This.ViewCurrency : 'CLEAR'
	}
	removeItemFromList() {
		If !Row := mainList.GetNext() {
			Return
		}
		Code := mainList.GetText(Row, 2)
		This.SellList.Delete(Code)
		mainList.Delete(Row)
		This.updatePriceSum()
	}
}