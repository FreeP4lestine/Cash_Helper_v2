class Sell {
    __New(DefaultLocation := 'setting\defs', ItemPropFile := 'setting\ItemProperties', SellMethodsFile := 'setting\SellMethods', SellCurrencyFile := 'setting\SellCurrency', SellPropertiesFile := 'setting\SellProperties') {
        This.DefaultLocation := DefaultLocation
        This.ItemPropFile := ItemPropFile
        This.SellMethodsFile := SellMethodsFile
        This.SellCurrencyFile := SellCurrencyFile
        This.SellPropertiesFile := SellPropertiesFile
        This.tempRow := 0
		This.SellProperties := []
		This.SellPropertiesMap := Map()
        This.PropertyName := Map()
        This.Property := []
        This.SellCurrencyName := Map()
        This.SellCurrency := []
        This.ViewCurrency := ''
		This.Rounder := 3
        This.SellMethods := Map()
		This.SellList := Map()
		This.Session := 1
		This.SessionList := [This.Session]
		This.sessionUpdate := True
		This.switchSession := True
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
	getSellProperties() {
		If FileExist(This.SellPropertiesFile) {
			O := FileOpen(This.SellPropertiesFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellProperties.Push({Name: Definition[1], Value: Definition[2], ViewValue: Definition[3]})
			}
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
					If !IsNumber(Property.Value) {
						Property.Value := 0
					}
					Currency := This.ViewCurrency
					This.SellCurrencyName[Currency].ConvertFactor
					Property.ViewValue := Round(Property.Value * This.SellCurrencyName[Currency].ConvertFactor, This.Rounder)
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
		RegExMatch(This.PropertyName['Sell Method'].ViewValue, '\((P|G|L)\)', &Unit)
		Unit := Unit[1]
        This.tempRow := mainList.Add(,, This.PropertyName['Code'].ViewValue
                                      , This.PropertyName['Name'].ViewValue
                                      , This.PropertyName['Sell Amount'].ViewValue
                                      , Unit
                                      , This.PropertyName['Sell Value'].ViewValue
                                      , This.PropertyName['Added Value'].ViewValue
                                      , This.PropertyName['Sell Value'].ViewValue
									  , This.ViewCurrency)
        mainListCLV.Row(This.tempRow,, 0xFF999999)
		mainListCLV.Cell(This.tempRow, 1, 0xFF999999)
		mainListCLV.Cell(This.tempRow, 8, 0xFFB2B2B2)
    }
	updateItemAmount(Code, Amount, Timer := False) {
		This.SellList[Code]['Amount'] := Amount
		This.SellList[Code]['Price'] := Round(This.SellList[Code]['Amount'] / This.SellList[Code]['Sell Amount'] * (This.SellList[Code]['Sell Value'] + This.SellList[Code]['Added Value']), This.Rounder)
		This.SellList[Code]['Cost'] := Round(This.SellList[Code]['Amount'] / This.SellList[Code]['Sell Amount'] * (This.SellList[Code]['Buy Value']), This.Rounder)
		This.SellList[Code]['Profit'] := This.SellList[Code]['Price'] - This.SellList[Code]['Cost']
		This.clearTempRow()
		This.updatePriceSum()
		SetTimer(updateRow, -10)
		updateRow() {
			If !This.SellList.Has(Code) {
				Return
			}
			mainList.Modify(This.SellList[Code]['Row'],,,,, This.SellList[Code]['Amount'],,, This.SellList[Code]['Added Value'], This.SellList[Code]['Price'])
			This.saveSessionList()
		}
	}
	updateQuantityPrice(Row, Amount) {
		Code := mainList.GetText(Row, 2)
		Amount := StrReplace(Amount, ',', '.')
		If !IsNumber(Amount) {
			Amount := 0
		}
		If This.SellList.Has(Code) {
			This.updateItemAmount(Code, Amount, True)
		}
	}
	addItemToList() {
		Code := enteredCode.Value
		enteredCode.Value := ''
		If !This.tempRow {
			Return
		}
		If This.SellList.Has(Code) {
			This.updateItemAmount(Code, This.SellList[Code]['Amount'] += This.SellList[Code]['Sell Amount'])
			Return
		}
		This.SellList[Code] := Map()
		For Property, Value in This.PropertyName {
			This.SellList[Code][Property] := Value.ViewValue
		}
		This.SellList[Code]['Row'] := This.tempRow
		This.SellList[Code]['Amount'] := This.SellList[Code]['Sell Amount']
		This.SellList[Code]['Price'] := This.SellList[Code]['Sell Value'] + This.SellList[Code]['Added Value']
		This.SellList[Code]['Cost'] := This.SellList[Code]['Buy Value']
		This.SellList[Code]['Profit'] := This.SellList[Code]['Price'] - This.SellList[Code]['Cost']
		mainListCLV.Row(This.tempRow,, 0xFF000000)
		mainListCLV.Cell(This.tempRow, 1, 0xFF000000)
		mainListCLV.Cell(This.tempRow, 4,, 0xFF0000FF)
		mainListCLV.Cell(This.tempRow, 7,, 0xFF808080)
		mainListCLV.Cell(This.tempRow, 8,, 0xFFFF0000)
		mainListCLV.Cell(This.tempRow, 9, 0xFFFFC080)
		This.tempRow := 0
		mainList.Redraw()
		This.updatePriceSum()
		This.saveSessionList()
	}
	updatePriceSum() {
		Sum := 0
		For Code, Item in This.SellList {
			Sum += Item['Price']
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
		This.saveSessionList()
	}
	saveSessionList() {
		If !This.sessionUpdate {
			Return
		}
		O := FileOpen('setting\sessions\' This.Session, 'w')
		Loop mainList.GetCount() {
			O.Write(mainList.GetText(A_Index, 2))
			O.Write(',' mainList.GetText(A_Index, 4))
			O.WriteLine()
		}
		O.Close()
	}
	readSessionList() {
		mainList.Delete()
		priceSum.Value := 'CLEAR'
		If !FileExist('setting\sessions\' This.Session) {
			Return
		}
		This.sessionUpdate := False
		O := FileOpen('setting\sessions\' This.Session, 'r')
		This.SellList := Map()
		While !O.AtEOF {
			ItemData := StrSplit(O.ReadLine(), ',')
			Code := ItemData[1]
			Amount := ItemData[2]
			This.analyzeCode(Code)
			enteredCode.Value := Code
			This.addItemToList()
			This.updateItemAmount(Code, Amount)
		}
		O.Close()
		This.sessionUpdate := True
	}
	nextSession() {
		If !This.sessionUpdate {
			Return
		}
		This.Session += 1
		currentSession.Value := This.Session
		This.readSessionList()
	}
	prevSession() {
		If !This.sessionUpdate {
			Return
		}
		If (This.Session -= 1) = 0 {
			This.Session := 1
			Return
		}
		currentSession.Value := This.Session
		This.readSessionList()
	}
	commitSell() {
		If priceSum.Value = 'CLEAR' {
			MsgBox('Nothing to sell!', 'Sell', 0x30 ' T3')
			Return
		}
		payCheckWindow.Show()
		commitMsg.Opt('BackgroundWhite cGray')
		commitMsg.Value := 'Commit the sell?'
		commitAmount.Opt('cGreen')
		commitAmountPay.Opt('-ReadOnly BackgroundWhite cBlack')
		commitAmountPayBack.Opt('cRed')
		commitOK.Enabled := true
		commitCancel.Enabled := true
		commitLater.Enabled := true
		commitAmount.Value := priceSum.Value
		AC := StrSplit(priceSum.Value, ' ')
		commitAmountPay.Value := AC[1]
		commitAmountPayBack.Value := ''
		commitAmountPay.Focus()
		This.updateAmountPayBack()
	}
	updateAmountPayBack() {
		AC := StrSplit(priceSum.Value, ' ')
		If !IsNumber(commitAmountPay.Value) {
			commitAmountPayBack.Value := ''
			Return
		}
		commitAmountPayBack.Value := Round(commitAmountPay.Value - AC[1], This.Rounder) ' ' AC[2]
	}
	commitSellSubmit() {
		This.writeSellProperties()
		commitMsg.Opt('BackgroundGreen cWhite')
		commitMsg.Value := '✓ Commited!'
		commitAmount.Opt('ReadOnly BackgroundE6E6E6 cGray')
		commitAmountPay.Opt('ReadOnly BackgroundE6E6E6 cGray')
		commitAmountPayBack.Opt('ReadOnly BackgroundE6E6E6 cGray')
		commitOK.Enabled := False
		commitCancel.Enabled := False
		commitLater.Enabled := False
		commitMsg.Focus()
		mainList.Delete()
		This.SellList := Map()
		This.updatePriceSum()
		This.saveSessionList()
	}
	writeSellProperties() {
		Time := A_Now
		O := FileOpen('data\pending\' Time, 'w')
		For Item, Sell in This.SellList {
			O.WriteLine('[Item' A_Index ']')
			For Property in This.SellProperties {
				Switch Property.Name {
					Case 'Price', 'Cost', 'Profit':
						If !IsNumber(Sell[Property.Name]) {
							Sell[Property.Name] := 0
						}
						Currency := This.ViewCurrency
						This.SellCurrencyName[Currency].ConvertFactor
						convertedValue := Sell[Property.Name] / This.SellCurrencyName[Currency].ConvertFactor, This.Rounder
						O.WriteLine(convertedValue)
					Default : O.WriteLine(Sell[Property.Name])
				}
			}
		}
	}
}