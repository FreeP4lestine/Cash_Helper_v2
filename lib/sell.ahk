analyzeCode() {
	If Sells[currentSession.Value].Has('tmp') {
		mainList.Delete(Sells[currentSession.Value]['tmp']['Row'])
		Sells[currentSession.Value].Delete('tmp')
	}
	Thumb.Value := 'images\Default.png'
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
				If item[Detail] {
					Try
						Value := Round(item[Detail], setting['Rounder'])
					Catch
						Value := 0
				} Else Value := 0
				tmpData.Push(Value)
			Case 'Quantity':
				If !IsNumber(Item['Sell Amount']) {
					Item['Sell Amount'] := 1
				}
				tmpData.Push(Item['Sell Amount'])
			Case 'Unit':
				Try {
					RegExMatch(Item['Sell Method'], '\((P|p|G|g|L|l)\)', &Unit)
					Unit := Unit[1]
					tmpData.Push(Unit)
				} Catch
					tmpData.Push('P')
			Case 'Price':
				tmpData.Push(Round(tmpData[5] + tmpData[9], setting['Rounder']))
			case 'CUR':
				Try tmpData.Push(setting['DisplayCurrency'])
				Catch 
					tmpData.Push('TND')
			Default: tmpData.Push(Item[Detail])
		}
	}
	Row := mainList.Add(, updateRowView(tmpData)*)
	thumbCheck(Code)
	tmpRowColorize(Row)
	updateRowViewCurrency(Row)
	Sells[currentSession.Value]['tmp'] := Map()
	Sells[currentSession.Value]['tmp']['Row'] := Row
	Sells[currentSession.Value]['tmp']['Data'] := tmpData
}
thumbCheck(Code) {
	If (Code = '') || (Item := readJson(setting['ItemDefLoc'] '\' Code '.json')).Count = 0 {
		Return
	}
	Thumb.Value := 'images\Default.png'
	Code128.Value := ''
	Code128.Move(,, 140, 32)
	If item['Thumbnail']
		Try Thumb.Value := 'HBITMAP:*' hBitmapFromB64(item['Thumbnail'])
	If item['Code128']
		Try Code128.Value := 'HBITMAP:*' hBitmapFromB64(item['Code128'])
}
tmpRowColorize(Row) {
	mainListCLV.Row(Row, , 0xFF999999)
	mainListCLV.Cell(Row, 1, 0xFFCCCCCC)
	mainListCLV.Cell(Row, 2,, 0xFF999999)
	mainListCLV.Cell(Row, 4,, 0xFF999999)
	mainListCLV.Cell(Row, 5,, 0xFF999999)
	mainListCLV.Cell(Row, 10,, 0xFF999999)
	mainListCLV.Cell(Row, 11,, 0xFFCCCCCC)
}
addedRowColorize(Row) {
	mainListCLV.Row(Row, , 0xFF000000)
	mainListCLV.Cell(Row, 1, 0xFF000000)
	mainListCLV.Cell(Row, 2,, 0xFF0000FF)
	mainListCLV.Cell(Row, 4,, 0xFF804000)
	mainListCLV.Cell(Row, 5,, 0xFF008040)
	mainListCLV.Cell(Row, 10,, 0xFFFF0000)
	mainListCLV.Cell(Row, 11, 0xFFFFC080)
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
	Sells[currentSession.Value]['Username'] := username
	Sells[currentSession.Value]['Items'] := []
}
updateRowViewCurrency(Row := 0, isSum := False, isQuickResume := False) {
	If Row {
		tmp := []
		For Each, Col in setting['Sell']['Session']['03'] {
			Value := mainList.GetText(Row, Each)
			Switch Col {
				Case 'Buy Value', 'Sell Value', 'Added Value', 'Price':
					Value := Round(Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) 
					tmp.Push(Value)
				Case 'CUR':
					tmp.Push(setting['DisplayCurrency'])
				Default: tmp.Push(Value)
			}
		}
		tmp[4] := '--'
		mainList.Modify(Row,, tmp*)
	}
	If isSum{
		If priceSum.Value != 'CLEAR' {
			priceSum.Value := StrSplit(priceSum.Value, ' ')[1]
			If IsNumber(priceSum.Value)
				priceSum.Value := Round(priceSum.Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
		}
	}
	if isQuickResume {
		If pendingBought.Value != '' {
			pendingBought.Value := StrSplit(pendingBought.Value, ' ')[1]
			If IsNumber(pendingBought.Value)
				pendingBought.Value := Round(pendingBought.Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
		}
		If pendingSold.Value != '' {
			pendingSold.Value := StrSplit(pendingSold.Value, ' ')[1]
			If IsNumber(pendingSold.Value)
				pendingSold.Value := Round(pendingSold.Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
		}
		If pendingProfit.Value != '' {
			pendingProfit.Value := StrSplit(pendingProfit.Value, ' ')[1]
			If IsNumber(pendingProfit.Value)
				pendingProfit.Value := Round(pendingProfit.Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
		}
	}
}
updateRowView(Data) {
	Data[7] := Round(Data[7], 2)
	Data[10] := Round(Data[10], setting['Rounder'])
	Data[5] := Round(Data[5], setting['Rounder'])
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
		Sells[currentSession.Value]['Items'][Row] := updateRowView(Sells[currentSession.Value]['Items'][Row])
		mainList.Modify(Row,, Sells[currentSession.Value]['Items'][Row]*)
		enteredCode.Value := ''
		mainList.Delete(Sells[currentSession.Value]['tmp']['Row'])
		Sells[currentSession.Value].Delete('tmp')
		updatePriceSum()
		updateRowViewCurrency(Row, True)
		enteredCode.Focus()
		saveSessions()
		Return
	}
	Sells[currentSession.Value]['Items'].Push(Sells[currentSession.Value]['tmp']['Data'])
	R := Sells[currentSession.Value]['Items'].Length
	addedRowColorize(R)
	Sells[currentSession.Value].Delete('tmp')
	enteredCode.Value := ''
	mainList.Redraw()
	updatePriceSum()
	updateRowViewCurrency(, True)
	saveSessions()
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
		If mainList.GetCount() 
			Row := 1
		Else Return
	}
	If Row > Sells[currentSession.Value]['Items'].Length {
		Return
	}
	Sells[currentSession.Value]['Items'].RemoveAt(Row)
	mainList.Delete(Row)
	updatePriceSum()
	updateRowViewCurrency(, True)
	saveSessions()
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
	Thumb.Value := 'images\Default.png'
	Code128.Value := ''
	mainList.Delete()
	If !Sells.Has(currentSession.Value) {
		priceSum.Value := 'CLEAR'
		initiateSession()
		Return
	}
	; Added rows
	For Row, Item in Sells[currentSession.Value]['Items'] {
		Item := updateRowView(Item)
		R := mainList.Add(, Item*)
		updateRowViewCurrency(R)
		addedRowColorize(R)
	}
	; Tmp rows
	If Sells[currentSession.Value].Has('tmp') {
		enteredCode.Value := Sells[currentSession.Value]['tmp']['Data'][2]
		Sells[currentSession.Value]['tmp']['Data'] := updateRowView(Sells[currentSession.Value]['tmp']['Data'])
		R := mainList.Add(, Sells[currentSession.Value]['tmp']['Data']*)
		updateRowViewCurrency(R)
		tmpRowColorize(R)
	}
	updatePriceSum()
	updateRowViewCurrency(, True)
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
	Sells[currentSession.Value]['Items'][Row] := updateRowView(Sells[currentSession.Value]['Items'][Row])
	mainList.Modify(Row,, Sells[currentSession.Value]['Items'][Row]*)
	updatePriceSum()
	updateRowViewCurrency(Row, True)
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
	Sells[currentSession.Value]['Items'][Row] := updateRowView(Sells[currentSession.Value]['Items'][Row])
	mainList.Modify(Row,, Sells[currentSession.Value]['Items'][Row]*)
	updatePriceSum()
	updateRowViewCurrency(Row, True)
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
			mainList.Modify(quickRow.Value,, Sells[currentSession.Value]['Items'][quickRow.Value]*)
			updatePriceSum()
			updateRowViewCurrency(quickRow.Value, True)
		Case 10:
			Sells[currentSession.Value]['Items'][quickRow.Value][10] := quickEdit.Value / currency['rates'][setting['DisplayCurrency']]
			Sells[currentSession.Value]['Items'][quickRow.Value] := updatePrice(Sells[currentSession.Value]['Items'][quickRow.Value])
			mainList.Modify(quickRow.Value,, Sells[currentSession.Value]['Items'][quickRow.Value]*)
			updatePriceSum()
			updateRowViewCurrency(quickRow.Value, True)
	}
	quickWindow.Hide()
}
addCustomPrice() {
	If !IsNumber(CItemPrice.Value) || CItemPrice.Value < 0 {
		Msgbox('Invalid custom price!', setting['Name'], 0x30)
		Return
	}
	tmpData := []
	For Each, Detail in setting['Sell']['Session']['03'] {
		Switch Detail {
			Case 'Code': tmpData.Push('--')
			Case 'Name': tmpData.Push('--')
			Case 'Buy Value': tmpData.Push(CItemPrice.Value / currency['rates'][setting['DisplayCurrency']])
			Case 'Sell Value': tmpData.Push(CItemPrice.Value / currency['rates'][setting['DisplayCurrency']])
			Case 'Sell Amount': tmpData.Push(1)
			Case 'Quantity': tmpData.Push(1)
			Case 'Unit': tmpData.Push('P')
			Case 'Added Value': tmpData.Push(0)
			Case 'Price': tmpData.Push(CItemPrice.Value / currency['rates'][setting['DisplayCurrency']])
			Case 'CUR': 
				Try tmpData.Push(setting['DisplayCurrency'])
				Catch 
					tmpData.Push('TND')
			Default: tmpData.Push('')
		}
	}
	Sells[currentSession.Value]['Items'].Push(tmpData)
	R := mainList.Add(, updateRowView(tmpData)*)
	addedRowColorize(R)
	updatePriceSum()
	updateRowViewCurrency(R, True)
	CItemPrice.Value := ''
	saveSessions()
}
commitSell() {
	If priceSum.Value = 'CLEAR' {
		MsgBox('Nothing to sell!', 'Sell', 0x30 ' T3')
		Return
	}
	mainWindow.Opt('Disabled')
	payCheckWindow.Show()
	commitImg.Value := 'images\commitoff.png'
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
	commitAmountPayBack.Value := Round(commitAmountPay.Value - AC[1], setting['Rounder']) ' ' AC[2]
}
commitSellSubmit(Later := False) {
	If Sells[currentSession.Value].Has('tmp') {
		Sells[currentSession.Value].Delete('tmp')
	}
	Sells[currentSession.Value]['CommitTime'] := A_Now
	Sells[currentSession.Value]['Username'] := username
	Saveto := Later ? 'commit\pending\later' : 'commit\pending'
	writeJson(Sells[currentSession.Value], Saveto '\' Sells[currentSession.Value]['CommitTime'] '.json')
	latestSellsSave()
	updatePriceSum()
	commitImg.Value := 'images\commit.png'
	commitMsg.Opt('BackgroundGreen cWhite')
	commitMsg.Value := 'Commited!'
	commitAmount.Opt('ReadOnly BackgroundE6E6E6 cGray')
	commitAmountPay.Opt('ReadOnly BackgroundE6E6E6 cGray')
	commitAmountPayBack.Opt('ReadOnly BackgroundE6E6E6 cGray')
	commitOK.Enabled := False
	commitCancel.Enabled := False
	commitLater.Enabled := False
	commitMsg.Focus()
	mainList.Delete()
	mainWindow.Opt('-Disabled')
	pendingQuickResume()
	Thumb.Value := 'images\Default.png'
	Code128.Value := ''
	saveSessions()
	initiateSession()
	SetTimer(commitClose, -5000)
	commitClose() {
		payCheckWindow.Hide()
	}
}
tagUser(File) {
	tags := readJson('commit\tags.json')
	If !tags.has(username) {
		tags[username] := []
	}
	tags[username].Push(File)
	writeJson(tags, 'commit\tags.json')
}
latestSellsSave() {
	latest := readJson('commit\latestSells.json')
	If Type(latest) = 'Map' {
		latest := []
	}
	For Each, Item in Sells[currentSession.Value]['Items'] {
		If Item[2] = '--'
			Continue
		latest.InsertAt(1, [Item[2], Item[3]])
		latestSells.Insert(1,, latest[1]*)
		If latest.Length > 100 {
			latest.RemoveAt(101)
			latestSells.Delete(101)
		}
	}
	writeJson(latest, 'commit\latestSells.json')
}
latestSellsLoad() {
	Count := 0
	latest := readJson('commit\latestSells.json')
	If Type(latest) = 'Map' {
		latest := []
	}
	For Each, Item in latest {
		latestSells.Add(, Item*)
		Count += 1
	}
	latestSellsCount.Value := 'Latest sells: ( ' Count ' )'
}
pendingQuickResume() {
	Bought := 0
	Sold := 0
	Loop Files, 'commit\pending\*.json' {
		Items := readJson(A_LoopFileFullPath)
		For Each, Item in Items['Items'] {
			Bought += Item[4] * Item[7] / Item[6]
			Sold += Item[10]
		}
	}
	pendingBought.Value := Round(Bought, setting['Rounder']) ' ' setting['DisplayCurrency']
	pendingSold.Value := Round(Sold, setting['Rounder']) ' ' setting['DisplayCurrency']
	pendingProfit.Value := Round(Sold - Bought, setting['Rounder']) ' ' setting['DisplayCurrency']
	updateRowViewCurrency(,, True)
}
HideShowQuickies() {
	Static Display := False
	If Display := !Display {
		quickResume.Visible := True
		pendingBought.Visible := True
		pendingSold.Visible := True
		pendingProfit.Visible := True
	} Else {
		quickResume.Visible := False
		pendingBought.Visible := False
		pendingSold.Visible := False
		pendingProfit.Visible := False
	}
}
displayItemCode(Ctrl, Item) {
	enteredCode.Value := Ctrl.GetText(Item)
	analyzeCode()
}
resizeControls(GuiObj, MinMax, Width, Height) {
	latestSells.GetPos(&X, &Y, &CWidth, &CHeight)
	latestSells.Move(,,, Height - 190 - Y)
	quickResume.GetPos(&X, &Y, &CWidth, &CHeight)
	quickResume.Move(, Height - 172)
	pendingBought.GetPos(&X, &Y, &CWidth, &CHeight)
	pendingBought.Move(, Height - 134)
	pendingSold.GetPos(&X, &Y, &CWidth, &CHeight)
	pendingSold.Move(, Height - 96)
	pendingProfit.GetPos(&X, &Y, &CWidth, &CHeight)
	pendingProfit.Move(, Height - 58)
	mainList.GetPos(&X, &Y, &CWidth, &CHeight)
	mainList.Move(,, W := Width - 30 - X, Height - 160 - Y)
	prevSess.GetPos(&X, &Y, &CWidth, &CHeight)
	prevSess.Move(, Height - 89)
	currentSession.Move(, Height - 89)
	nextSess.Move(, Height - 89)
	priceSum.GetPos(&X, &Y, &CWidth, &CHeight)
	priceSum.Move(Width - 310, Height - 109)
	enteredCode.GetPos(&X, &Y, &CWidth, &CHeight)
	enteredCode.Move(Width - 480)
	CItemPrice.GetPos(&X, &Y, &CWidth, &CHeight)
	CItemPrice.Move(Width - 280)
	SetTimer(boxRedraw, 0)
	SetTimer(boxRedraw, -500)
	Box.ResizeShadow()
	Box2.ResizeShadow()
	Box3.ResizeShadow()
	Box4.ResizeShadow()
}
boxRedraw() {
	Box.RedrawShadow()
	Box2.RedrawShadow()
	Box3.RedrawShadow()
	Box4.RedrawShadow()
}