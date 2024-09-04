clearTempRow() {
    If tempRow {
        mainList.Delete(tempRow)
        tempRow := 0
    }
}
analyzeCode(Code) {
    Code := Trim(Code, ' ')
    If Code = '' 
    || !FileExist(DefaultLocation '\' Code) 
    || !readProperties(Code) {
        clearTempRow()
        Return
    }
    clearTempRow()
	RegExMatch(PropertyName['Sell Method'].ViewValue, '\((P|G|L)\)', &Unit)
	Unit := Unit[1]
    tempRow := mainList.Add(,, PropertyName['Code'].ViewValue
                                  , PropertyName['Name'].ViewValue
                                  , PropertyName['Sell Amount'].ViewValue
                                  , Unit
                                  , PropertyName['Sell Value'].ViewValue
                                  , PropertyName['Added Value'].ViewValue
                                  , PropertyName['Sell Value'].ViewValue
								  , ViewCurrency)
    mainListCLV.Row(tempRow,, 0xFF999999)
	mainListCLV.Cell(tempRow, 1, 0xFF999999)
	mainListCLV.Cell(tempRow, 8, 0xFFB2B2B2)
}
updateItemAmount(Code, Amount, Timer := False) {
	SellList[Code]['Amount'] := Amount
	SellList[Code]['Price'] := Round(SellList[Code]['Amount'] / SellList[Code]['Sell Amount'] * (SellList[Code]['Sell Value'] + SellList[Code]['Added Value']), Rounder)
	SellList[Code]['Cost'] := Round(SellList[Code]['Amount'] / SellList[Code]['Sell Amount'] * (SellList[Code]['Buy Value']), Rounder)
	SellList[Code]['Profit'] := SellList[Code]['Price'] - SellList[Code]['Cost']
	clearTempRow()
	updatePriceSum()
	SetTimer(updateRow, -10)
	updateRow() {
		If !SellList.Has(Code) {
			Return
		}
		mainList.Modify(SellList[Code]['Row'],,,,, SellList[Code]['Amount'],,, SellList[Code]['Added Value'], SellList[Code]['Price'])
		saveSessionList()
	}
}
updateQuantityPrice(Row, Amount) {
	Code := mainList.GetText(Row, 2)
	Amount := StrReplace(Amount, ',', '.')
	If !IsNumber(Amount) {
		Amount := 0
	}
	If SellList.Has(Code) {
		updateItemAmount(Code, Amount, True)
	}
}
addItemToList() {
	Code := enteredCode.Value
	enteredCode.Value := ''
	If !tempRow {
		Return
	}
	If SellList.Has(Code) {
		updateItemAmount(Code, SellList[Code]['Amount'] += SellList[Code]['Sell Amount'])
		Return
	}
	SellList[Code] := Map()
	For Property, Value in PropertyName {
		SellList[Code][Property] := Value.ViewValue
	}
	SellList[Code]['Row'] := tempRow
	SellList[Code]['Amount'] := SellList[Code]['Sell Amount']
	SellList[Code]['Price'] := SellList[Code]['Sell Value'] + SellList[Code]['Added Value']
	SellList[Code]['Cost'] := SellList[Code]['Buy Value']
	SellList[Code]['Profit'] := SellList[Code]['Price'] - SellList[Code]['Cost']
	mainListCLV.Row(tempRow,, 0xFF000000)
	mainListCLV.Cell(tempRow, 1, 0xFF000000)
	mainListCLV.Cell(tempRow, 4,, 0xFF0000FF)
	mainListCLV.Cell(tempRow, 7,, 0xFF808080)
	mainListCLV.Cell(tempRow, 8,, 0xFFFF0000)
	mainListCLV.Cell(tempRow, 9, 0xFFFFC080)
	tempRow := 0
	mainList.Redraw()
	updatePriceSum()
	saveSessionList()
}
updatePriceSum() {
	Sum := 0
	For Code, Item in SellList {
		Sum += Item['Price']
	}
	priceSum.Value := Sum > 0 ? Round(Sum, Rounder) ' ' ViewCurrency : 'CLEAR'
}
removeItemFromList() {
	If !Row := mainList.GetNext() {
		Return
	}
	Code := mainList.GetText(Row, 2)
	SellList.Delete(Code)
	mainList.Delete(Row)
	updatePriceSum()
	saveSessionList()
}
saveSessionList() {
	If !sessionUpdate {
		Return
	}
	O := FileOpen('setting\sessions\' Session, 'w')
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
	If !FileExist('setting\sessions\' Session) {
		Return
	}
	sessionUpdate := False
	O := FileOpen('setting\sessions\' Session, 'r')
	SellList := Map()
	While !O.AtEOF {
		ItemData := StrSplit(O.ReadLine(), ',')
		Code := ItemData[1]
		Amount := ItemData[2]
		analyzeCode(Code)
		enteredCode.Value := Code
		addItemToList()
		updateItemAmount(Code, Amount)
	}
	O.Close()
	sessionUpdate := True
}
nextSession() {
	If !sessionUpdate {
		Return
	}
	Session += 1
	currentSession.Value := Session
	readSessionList()
}
prevSession() {
	If !sessionUpdate {
		Return
	}
	If (Session -= 1) = 0 {
		Session := 1
		Return
	}
	currentSession.Value := Session
	readSessionList()
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
	updateAmountPayBack()
}
updateAmountPayBack() {
	AC := StrSplit(priceSum.Value, ' ')
	If !IsNumber(commitAmountPay.Value) {
		commitAmountPayBack.Value := ''
		Return
	}
	commitAmountPayBack.Value := Round(commitAmountPay.Value - AC[1], Rounder) ' ' AC[2]
}
commitSellSubmit() {
	writeSellProperties()
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
	SellList := Map()
	updatePriceSum()
	saveSessionList()
}
writeSellProperties() {
	Time := A_Now
	O := FileOpen('data\pending\' Time, 'w')
	For Item, Sell in SellList {
		O.WriteLine('[Item' A_Index ']')
		For Property in SellProperties {
			Switch Property.Name {
				Case 'Price', 'Cost', 'Profit':
					If !IsNumber(Sell[Property.Name]) {
						Sell[Property.Name] := 0
					}
					Currency := ViewCurrency
					SellCurrencyName[Currency].ConvertFactor
					convertedValue := Sell[Property.Name] / SellCurrencyName[Currency].ConvertFactor, Rounder
					O.WriteLine(convertedValue)
				Default : O.WriteLine(Sell[Property.Name])
			}
		}
	}
}