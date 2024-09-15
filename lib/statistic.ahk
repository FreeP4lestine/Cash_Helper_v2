updateRowViewCurrency(Row := 0) {
	If Row {
		tmp := []
		For Each, Col in setting['Sell']['Session']['03'] {
			Value := details.GetText(Row, Each)
			Switch Col {
				Case 'Buy Value', 'Sell Value', 'Added Value', 'Price':
					Value := Round(Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) 
					tmp.Push(Value)
				Case 'CUR':
					tmp.Push(setting['DisplayCurrency'])
				Default: tmp.Push(Value)
			}
		}
		details.Modify(Row,, tmp*)
	}
}

autoResizeCols() {
    Loop details.GetCount('Col') {
        If A_Index = 11 {
            Continue
        }
        details.ModifyCol(A_Index, 'Center AutoHdr')
    }
    details.ModifyCol(11, 'Center 50')
}
addedRowColorize(Row) {
	detailsCLV.Row(Row, , 0xFF000000)
	detailsCLV.Cell(Row, 2,, 0xFF0000FF)
	detailsCLV.Cell(Row, 4,, 0xFF804000)
	detailsCLV.Cell(Row, 5,, 0xFF008040)
	detailsCLV.Cell(Row, 10,, 0xFFFF0000)
	detailsCLV.Cell(Row, 11, 0xFFFFC080)
}
displayUserSells(User) {
    Count := 0, Count2 := 0
    B := S := P := 0
    nonSubmitted.Delete()
    details.Delete()
    overall.Text := 'Selection summary: ( ' Count  ' )'
    overallUser.Text := 'Current user summary: ( ' Count2  ' )'
    nonSubmittedTxt.Text := 'Non reviewed sells ( ' Count  ' )'
    Bought.Value := B
    Sold.Value := S
    Profit.Value := P
    BoughtUser.Value := B
    SoldUser.Value := S
    ProfitUser.Value := P
    review['List'] := []
    Switch User {
        Case 'Everyone': loadNonSubmitted()
        Default:
            For Each, _Items in review['nonreview'] {
                Items := _Items['Items']
                If !Items.Has('Username') || User != Items['Username'] {
                    Continue
                }
                review['List'].Push(Items)
                DateTime := SubStr(A_LoopFileName, 1, -5)
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [HH:mm:ss]')
                C := 0
                For Item in Items['Items'] {
                    B += Item[4] * Item[7] / Item[6]
                    S += Item[10]
                    C++
                    Count2++
                }
                nonSubmitted.Add('icon1','( ' C ' ) '  DateTime )
                Count++
                nonSubmittedTxt.Text := 'Non reviewed sells ( ' Count  ' )'
            }
            If !Count {
                Return
            }
            overallUser.Text := 'Current user summary: ( ' Count2  ' )'
            BoughtUser.Value := Round(B * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
            SoldUser.Value := Round(S * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
            ProfitUser.Value := Round((S - B) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
    }
}
displayDetails() {
    details.Delete()
    B := S := P := 0
    Count := 0
    Count2 := 0
    next := 0
    While next := nonSubmitted.GetNext(next) {
        Items := review['List'][next]
        For Item in Items['Items'] {
            R := details.Add(, Item*)
            B += Item[4] * Item[7] / Item[6]
            S += Item[10]
            updateRowViewCurrency(R)
            addedRowColorize(R)
            Count++
        }
        Count2++
    }
    If Count2 = 1 {
        openTime.Value := 'Open Time: ' FormatTime(Items['OpenTime'], 'yyyy/MM/dd HH:mm:ss')
        commitTime.Value := 'Commit Time: ' FormatTime(Items['CommitTime'], 'yyyy/MM/dd HH:mm:ss')
    } Else {
        openTime.Value := 'Open Time: Multi'
        commitTime.Value := 'Commit Time : Multi'
    }
    autoResizeCols()
    overall.Text := 'Selection summary: ( ' Count  ' )'
    Bought.Value := Round(B * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
	Sold.Value := Round(S * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
	Profit.Value := Round((S - B) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
}
loadNonSubmitted() {
    users := readJson(A_AppData '\Cash Helper\users.json')
    For User, Info in users['Registered'] {
        If review['Users'].Has(User) {
            Continue
        }
        If Info['b64Thumbnail'] {
            Try Ico := IL_Add(IL, 'HBITMAP:*' hBitmapFromB64(Info['b64Thumbnail']))
            Catch
                Ico := -1
        } Else Ico := -1
        usersList.Add('Icon' Ico, User)
        review['Users'][User] := ''
    }
    Count := 0, Count2 := 0
    B := S := P := 0
    nonSubmitted.Delete()
    nonSubmittedTxt.Text := 'Non reviewed sells ( ' Count  ' )'
    overallTotal.Text := 'Overall Summary: ( ' Count2  ' )'
    BoughtTotal.Value := Round(B * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
	SoldTotal.Value := Round(S * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
	ProfitTotal.Value := Round((S - B) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
    review['nonreview'] := []
    review['List'] := []
    Loop Files, 'commit\archived\*.json', 'R' {
        review['nonreview'].Push(Map())
        review['nonreview'][A_Index]['File'] := A_LoopFileFullPath
        DateTime := SubStr(A_LoopFileName, 1, -5)
        DateTime := FormatTime(DateTime, 'yyyy/MM/dd [HH:mm:ss]')
        Items := readJson(review['nonreview'][A_Index]['File'])
        If Items.Has('Username') && Items['Username'] != '' && !review['Users'].Has(Items['Username']) {
            review['Users'][Items['Username']] := ''
            usersList.Add('Icon-1', Items['Username'])
        }
        review['nonreview'][A_Index]['Items'] := Items
        review['List'].Push(Items)
        C := 0
        For Item in Items['Items'] {
            B += Item[4] * Item[7] / Item[6]
            S += Item[10]
            C++
            Count2++
        }
        nonSubmitted.Add('icon1','( ' C ' ) '  DateTime )
        Count++
        nonSubmittedTxt.Text := 'Non reviewed sells ( ' Count  ' )'
    }
    overallTotal.Text := 'Overall Summary: ( ' Count2  ' )'
    BoughtTotal.Value := Round(B * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
	SoldTotal.Value := Round(S * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
	ProfitTotal.Value := Round((S - B) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency']
    usersList.AutoSize(2)
    Box5.ResizeShadow()
    Box5.RedrawShadow()
}
resizeControls(GuiObj, MinMax, Width, Height) {
    C2.Move(,, Width - 164)
    nonSubmitted.GetPos(, &Y)
    nonSubmitted.Move(,,, Height - Y - 28)
    details.GetPos(&X, &Y, &CWidth, &CHeight)
    details.Move(,, WW := Width - X - 40, Height - Y - 270)
    openTime.Move(,, WW // 2)
    commitTime.Move(X + WW // 2,, WW // 2)
    overallUser.Move(, Height - 230, WW)
    BoughtUser.Move(, Height - 200, WW // 3 - 10)
    SoldUser.Move(X + WW // 3 + 10, Height - 200 , WW // 3 - 10)
    ProfitUser.Move(X + WW // 3 * 2 + 10, Height - 200 , WW // 3 - 10)
    overall.Move(, Height - 170, WW)
    Bought.Move(, Height - 140, WW // 3 - 10)
    Sold.Move(X + WW // 3 + 10, Height - 140 , WW // 3 - 10)
    Profit.Move(X + WW // 3 * 2 + 10, Height - 140 , WW // 3 - 10)
    overallTotal.Move(, Height - 100, WW)
    BoughtTotal.Move(, Height - 70 , WW // 3 - 10)
    SoldTotal.Move(X + WW // 3 + 10, Height - 70 , WW // 3 - 10)
    ProfitTotal.Move(X + WW // 3 * 2, Height - 70 , WW // 3 - 10)
    Box1.ResizeShadow()
    Box2.ResizeShadow()
    Box3.ResizeShadow()
    Box5.ResizeShadow()
    Box6.ResizeShadow()
    Box7.ResizeShadow()
    SetTimer(boxRedraw, 0)
	SetTimer(boxRedraw, -500)
}
boxRedraw() {
    Box1.RedrawShadow()
    Box2.RedrawShadow()
    Box3.RedrawShadow()
    Box5.RedrawShadow()
    Box6.RedrawShadow()
    Box7.RedrawShadow()
}