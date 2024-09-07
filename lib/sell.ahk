analyzeCode() {
	If Sells[currentSession.Value].Has('tmp') {
		mainList.Delete(Sells[currentSession.Value]['tmp']['Row'])
		Sells[currentSession.Value].Delete('tmp')
	}
	Code := Trim(enteredCode.Value, ' ')
	Code := Trim(Code, '`t')
	If (Code = '') || (Item := readJson(setting['ItemDefLoc'] '\' Code '.json')).Count = 0 {
		Return
	}
	tmpData := []
	For Each, Detail in setting['Sell']['Session']['03'] {
		Switch Detail {
			Case 'Flag':
				tmpData.Push('')
			Case 'Buy Value', 'Sell Value', 'Added Value':
				If Item[Detail] = ''
					Item[Detail] := 0
				Try tmpData.Push(Round(Item[Detail] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']))
				Catch
					tmpData.Push(0)
			Case 'Quantity':
				tmpData.Push(Item['Sell Amount'])
			Case 'Unit':
				Try {
					RegExMatch(Item['Sell Method'], '\((P|p|G|g|L|l)\)', &Unit)
					Unit := Unit[1]
					tmpData.Push(Unit)
				} Catch
					tmpData.Push('P')
			Case 'Price':
				Price := Item['Sell Value']
				Try tmpData.Push(Round(Price + Item['Added Value'], setting['Rounder']))
				Catch 
					tmpData.Push(Round(Price, setting['Rounder']))
			case 'CUR':
				Try tmpData.Push(setting['DisplayCurrency'])
				Catch 
					tmpData.Push('TND')
			Default: tmpData.Push(Item[Detail])
		}
	}
	tmpData := updateRounding(tmpData)
	Row := mainList.Add(, tmpData*)
	tmpRowColorize(Row)
	Sells[currentSession.Value]['tmp'] := Map()
	Sells[currentSession.Value]['tmp']['Row'] := Row
	Sells[currentSession.Value]['tmp']['Data'] := tmpData
}
tmpRowColorize(Row) {
	mainListCLV.Row(Row, , 0xFF999999)
	mainListCLV.Cell(Row, 1, 0xFFCCCCCC)
	mainListCLV.Cell(Row, 2,, 0xFF999999)
	mainListCLV.Cell(Row, 5,, 0xFF999999)
	mainListCLV.Cell(Row, 10,, 0xFF999999)
	mainListCLV.Cell(Row, 11, 0xFFCCCCCC)
	;mainList.Redraw()
}
addedRowColorize(Row) {
	mainListCLV.Row(Row, , 0xFF000000)
	mainListCLV.Cell(Row, 1, 0xFF000000)
	mainListCLV.Cell(Row, 2,, 0xFF0000FF)
	mainListCLV.Cell(Row, 5,, 0xFF800000)
	mainListCLV.Cell(Row, 10,, 0xFFFF0000)
	mainListCLV.Cell(Row, 11, 0xFFFFB365)
	;mainList.Redraw()
}
updateQuantity(Data) {
	QF := Data[7] / Data[6]
	Data[10] := Round((Data[5] + Data[9]) * QF, setting['Rounder'])
	Return Data
}
updatePrice(Data) {
	PF := (Data[5] + Data[9])
	Data[7] := Round((Data[10] / PF) * Data[6], 2)
	Return Data
}
initiateSession() {
	Sells[currentSession.Value] := Map()
	Sells[currentSession.Value]['OpenTime'] := A_Now
	Sells[currentSession.Value]['CommitTime'] := ''
	Sells[currentSession.Value]['Items'] := []
}
updateRounding(Data) {
	Data[7] := Round(Data[7], 2)
	Data[10] := Round(Data[10], setting['Rounder'])
	Return Data
}
addItemToList() {
	If !Sells[currentSession.Value].Has('tmp') {
		enteredCode.Value := ''
		enteredCode.Focus()
		Return
	}
	Code := Trim(enteredCode.Value, ' ')
	Code := Trim(Code, '`t')
	alreadyAdded() {
		For Row, dataRow in Sells[currentSession.Value]['Items'] {
			If dataRow[2] = Code {
				Return Row
			}
		}
		Return 0
	}
	If Row := alreadyAdded() {
		Sells[currentSession.Value]['Items'][Row][7] += Sells[currentSession.Value]['tmp']['Data'][7]
		Sells[currentSession.Value]['Items'][Row] := updateQuantity(Sells[currentSession.Value]['Items'][Row])
		Sells[currentSession.Value]['Items'][Row] := updateRounding(Sells[currentSession.Value]['Items'][Row])
		mainList.Modify(Row,, Sells[currentSession.Value]['Items'][Row]*)
		enteredCode.Value := ''
		mainList.Delete(Sells[currentSession.Value]['tmp']['Row'])
		Sells[currentSession.Value].Delete('tmp')
		updatePriceSum()
		enteredCode.Focus()
		Return
	}
	Sells[currentSession.Value]['Items'].Push([])
	Row := Sells[currentSession.Value]['Items'].Length
	For Each, Data in Sells[currentSession.Value]['tmp']['Data'] {
		Sells[currentSession.Value]['Items'][Row].Push(Data)
	}
	addedRowColorize(Row)
	Sells[currentSession.Value].Delete('tmp')
	enteredCode.Value := ''
	mainList.Redraw()
	updatePriceSum()
	enteredCode.Focus()
}
updatePriceSum() {
	Sum := 0
	For Code, Item in Sells[currentSession.Value]['Items'] {
		Sum += Item[10]
	}
	priceSum.Value := Sum > 0 ? Round(Sum, setting['Rounder']) ' ' setting['DisplayCurrency'] : 'CLEAR'
}
removeItemFromList() {
	If !Row := mainList.GetNext() {
		Return
	}
	Sells[currentSession.Value]['Items'].RemoveAt(Row)
	mainList.Delete(Row)
	updatePriceSum()
}
saveSessions() {
	If !FileExist('setting\sessions\sessions.json') {
		writeJson(Sells, 'setting\sessions\sessions.json', '')
		Return
	}
	SellsJson := JSON.Dump(Sells)
	If SellsJson != FileRead('setting\sessions\sessions.json') {
		writeJson(Sells, 'setting\sessions\sessions.json', '')
	}
}
readSessionList() {
	enteredCode.Value := ''
	mainList.Delete()
	If !Sells.Has(currentSession.Value) {
		priceSum.Value := 'CLEAR'
		initiateSession()
		Return
	}
	; Added rows
	For Row, Item in Sells[currentSession.Value]['Items'] {
		Item := updateRounding(Item)
		R := mainList.Add(, Item*)
		addedRowColorize(R)
	}
	; Tmp rows
	If Sells[currentSession.Value].Has('tmp') {
		enteredCode.Value := Sells[currentSession.Value]['tmp']['Data'][2]
		Sells[currentSession.Value]['tmp']['Data'] := updateRounding(Sells[currentSession.Value]['tmp']['Data'])
		R := mainList.Add(, Sells[currentSession.Value]['tmp']['Data']*)
		tmpRowColorize(R)
	}
	updatePriceSum()
}
nextSession() {
	currentSession.Value += 1
	readSessionList()
}
prevSession() {
	If (currentSession.Value -= 1) = 0 {
		currentSession.Value := 1
		Return
	}
	readSessionList()
}
IncreaseQ() {
	If !Row := mainList.GetNext() {
		Return
	}
	Sells[currentSession.Value]['Items'][Row][7] += Sells[currentSession.Value]['Items'][Row][6]
	Sells[currentSession.Value]['Items'][Row] := updateQuantity(Sells[currentSession.Value]['Items'][Row])
	Sells[currentSession.Value]['Items'][Row] := updateRounding(Sells[currentSession.Value]['Items'][Row])
	mainList.Modify(Row,, Sells[currentSession.Value]['Items'][Row]*)
	updatePriceSum()
}
DecreaseQ() {
	If !Row := mainList.GetNext() {
		Return
	}
	Sells[currentSession.Value]['Items'][Row][7] -= Sells[currentSession.Value]['Items'][Row][6]
	If Sells[currentSession.Value]['Items'][Row][7] <= 0 {
		Sells[currentSession.Value]['Items'][Row][7] := Sells[currentSession.Value]['Items'][Row][6]
	}
	Sells[currentSession.Value]['Items'][Row] := updateQuantity(Sells[currentSession.Value]['Items'][Row])
	Sells[currentSession.Value]['Items'][Row] := updateRounding(Sells[currentSession.Value]['Items'][Row])
	mainList.Modify(Row,, Sells[currentSession.Value]['Items'][Row]*)
	updatePriceSum()
}
quickListEdit(LV, L) {
	Row := NumGet(L + (A_PtrSize * 3), 0, "Int") + 1
	Col := NumGet(L + (A_PtrSize * 3), 4, "Int") + 1
	Switch Col {
		Case 7, 10:
			quickText.Value := mainList.GetText(0, Col) ":"
			quickEdit.Value := mainList.GetText(Row, Col)
			quickRow.Value := Row
			quickCol.Value := Col
			quickCode.Value := Sells[currentSession.Value]['Items'][Row][2]
			quickEdit.Focus()
			quickWindow.Show()
	}
}
quickListSubmit() {
	If !IsNumber(quickEdit.Value) {
		MsgBox(setting['Name'], 'Invalid', 0x30)
		Return
	}
	If quickRow.Value > Sells[currentSession.Value]['Items'].Length
	|| Sells[currentSession.Value]['Items'][quickRow.Value][2] != quickCode.Value {
		MsgBox('Target row is not found!', setting['Name'], '0x30')
		Return
	}
	Switch quickCol.Value {
		Case 7:
			Sells[currentSession.Value]['Items'][quickRow.Value][7] := quickEdit.Value
			Sells[currentSession.Value]['Items'][quickRow.Value] := updateQuantity(Sells[currentSession.Value]['Items'][quickRow.Value])
			mainList.Modify(quickRow.Value,, updateRounding(Sells[currentSession.Value]['Items'][quickRow.Value])*)
			updatePriceSum()
		Case 10:
			Sells[currentSession.Value]['Items'][quickRow.Value][10] := quickEdit.Value
			Sells[currentSession.Value]['Items'][quickRow.Value] := updatePrice(Sells[currentSession.Value]['Items'][quickRow.Value])
			mainList.Modify(quickRow.Value,, updateRounding(Sells[currentSession.Value]['Items'][quickRow.Value])*)
			updatePriceSum()
	}
	quickWindow.Hide()
}
commitSell() {
	;If priceSum.Value = 'CLEAR' {
	;	MsgBox('Nothing to sell!', 'Sell', 0x30 ' T3')
	;	Return
	;}
	;payCheckWindow.Show()
	;commitMsg.Opt('BackgroundWhite cGray')
	;commitMsg.Value := 'Commit the sell?'
	;commitAmount.Opt('cGreen')
	;commitAmountPay.Opt('-ReadOnly BackgroundWhite cBlack')
	;commitAmountPayBack.Opt('cRed')
	;commitOK.Enabled := true
	;commitCancel.Enabled := true
	;commitLater.Enabled := true
	;commitAmount.Value := priceSum.Value
	;AC := StrSplit(priceSum.Value, ' ')
	;commitAmountPay.Value := AC[1]
	;commitAmountPayBack.Value := ''
	;commitAmountPay.Focus()
	;updateAmountPayBack()
}
updateAmountPayBack() {
	;AC := StrSplit(priceSum.Value, ' ')
	;If !IsNumber(commitAmountPay.Value) {
	;	commitAmountPayBack.Value := ''
	;	Return
	;}
	;commitAmountPayBack.Value := Round(commitAmountPay.Value - AC[1], Rounder) ' ' AC[2]
}
commitSellSubmit() {
	;writeSellProperties()
	;commitMsg.Opt('BackgroundGreen cWhite')
	;commitMsg.Value := '✓ Commited!'
	;commitAmount.Opt('ReadOnly BackgroundE6E6E6 cGray')
	;commitAmountPay.Opt('ReadOnly BackgroundE6E6E6 cGray')
	;commitAmountPayBack.Opt('ReadOnly BackgroundE6E6E6 cGray')
	;commitOK.Enabled := False
	;commitCancel.Enabled := False
	;commitLater.Enabled := False
	;commitMsg.Focus()
	;mainList.Delete()
	;SellList := Map()
	;updatePriceSum()
	;saveSessionList()
}
writeSellProperties() {
	;Time := A_Now
	;O := FileOpen('data\pending\' Time, 'w')
	;For Item, Sell in SellList {
	;	O.WriteLine('[Item' A_Index ']')
	;	For Property in SellProperties {
	;		Switch Property.Name {
	;			Case 'Price', 'Cost', 'Profit':
	;				If !IsNumber(Sell[Property.Name]) {
	;					Sell[Property.Name] := 0
	;				}
	;				Currency := ViewCurrency
	;				SellCurrencyName[Currency].ConvertFactor
	;				convertedValue := Sell[Property.Name] / SellCurrencyName[Currency].ConvertFactor, Rounder
	;				O.WriteLine(convertedValue)
	;			Default : O.WriteLine(Sell[Property.Name])
	;		}
	;	}
	;}
}