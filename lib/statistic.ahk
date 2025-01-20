resizeControls(GuiObj, MinMax, Width, Height) {
    C2.Move(,, Width - 164)
    details.Move(,,, Height - 230)
    detailsA.Move(,,, Height - 230)
    sellDetails.Move(,, Width - 430, Height - 300)
    W := Width - 430
    W //= 3
    itemsBuyValue.Move(390, Height - 90, W)
    itemsSellValue.Move(390 + W, Height - 90, W)
    itemsProfitValue.Move(390 + W * 2, Height - 90, W)
    ;buyBar.Move(Width - 205, 145, 30, Height - 300)
    ;sellBar.Move(Width - (205 - 60), 145, 30, Height - 300)
    ;profitBar.Move(Width - (205 - 120), 145, 30, Height - 300)
    ;profitBar.Redraw()
    Box1.ResizeShadow()
    Box3.ResizeShadow()
    Box4.ResizeShadow()
    Box5.ResizeShadow()
    ;Box6.ResizeShadow()
    SetTimer(boxRedraw, 0)
	SetTimer(boxRedraw, -500)
}
boxRedraw() {
    Box1.RedrawShadow()
    Box3.RedrawShadow()
    Box4.RedrawShadow()
    Box5.RedrawShadow()
    ;Box6.RedrawShadow()
}
loadAll(Flag := 1) {
    details.Delete()
    statistic['clears'] := []
    statistic['year'] := []
    statistic['month'] := []
    statistic['day'] := []
    statistic['user'] := []
    statistic['hour'] := []
    C4.Enabled := False
    Switch Flag {
        Case 1:
            If statistic['items'].Length {
                For Sell in statistic['items'] {
                    DateTime := Sell['CommitTime']
                    DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                    details.Add('Icon' . 2,, '#' A_Index ' | ' DateTime) 
                }
            } Else Loop Files, 'commit\archived\*.json', 'R' {
                statistic['items'].Push(Items := readJson(A_LoopFileFullPath))
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                details.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
        Case 2:
            statistic['clears'] := []
            Loop Files, 'commit\archived\*', 'D' {
                statistic['clears'].Push(A_LoopFileFullPath)
                DateTime := A_LoopFileName
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                R := details.Add('Icon' . 3,, '#' A_Index ' | ' DateTime)
                C := 0
                Loop Files, A_LoopFileFullPath '\*.json'
                    ++C
                details.Modify(R,,, '#' A_Index ' | ' DateTime ' (' C ')')
            }
        Case 3:
            statistic['year'] := []
            tmp := Map()
            For Sell in statistic['items'] {
                DateTime := Sell['CommitTime']
                Date := FormatTime(DateTime, 'yyyy')
                If !tmp.Has(Date) {
                    tmp[Date] := 1
                    statistic['year'].Push([])
                    R := details.Add('Icon' . 4,, '#' tmp.Count ' | ' Date)
                }
                statistic['year'][tmp.Count].Push(Sell)
                details.Modify(R,,, '#' tmp.Count ' | ' Date ' (' statistic['year'][tmp.Count].Length ')')
            }
        Case 4:
            statistic['month'] := []
            tmp := Map()
            For Sell in statistic['items'] {
                DateTime := Sell['CommitTime']
                Month := FormatTime(DateTime, 'yyyy/MM')
                If !tmp.Has(Month) {
                    tmp[Month] := 1
                    statistic['month'].Push([])
                    R := details.Add('Icon' . 5,, '#' tmp.Count ' | ' Month)
                }
                statistic['month'][tmp.Count].Push(Sell)
                details.Modify(R,,, '#' tmp.Count ' | ' Month ' (' statistic['month'][tmp.Count].Length ')')
            }
        Case 5:
                statistic['day'] := []
            tmp := Map()
            For Sell in statistic['items'] {
                DateTime := Sell['CommitTime']
                Day := FormatTime(DateTime, 'yyyy/MM/dd')
                If !tmp.Has(Day) {
                    tmp[Day] := 1
                    statistic['day'].Push([])
                    R := details.Add('Icon' . 6,, '#' tmp.Count ' | ' Day)
                }
                statistic['day'][tmp.Count].Push(Sell)
                details.Modify(R,,, '#' tmp.Count ' | ' Day ' (' statistic['day'][tmp.Count].Length ')')
            }
        Case 6:
            statistic['hour'] := []
            tmp := Map()
            For Sell in statistic['items'] {
                DateTime := Sell['CommitTime']
                Hour := FormatTime(DateTime, 'yyyy/MM/dd [ HH:00:00 ]')
                If !tmp.Has(Hour) {
                    tmp[Hour] := 1
                    statistic['hour'].Push([])
                    R := details.Add('Icon' . 7,, '#' tmp.Count ' | ' Hour)
                }
                statistic['hour'][tmp.Count].Push(Sell)
                details.Modify(R,,, '#' tmp.Count ' | ' Hour ' (' statistic['hour'][tmp.Count].Length ')')
            }
        Case 7:
            statistic['user'] := []
            tmp := Map()
            details.Add('Icon' . 8,, '#1 | Unknown')
            tmp['Unknown'] := 1
            statistic['user'].Push([])
            For Sell in statistic['items'] {
                If Sell.Has('Username') && Sell['Username'] != '' {
                    If !tmp.Has(Username) {
                        tmp[Username] := 1
                        statistic['user'].Push([])
                        R := details.Add('Icon' . 8,, '#' tmp.Count ' | ' Username)
                    }
                    statistic['user'][tmp.Count].Push(Sell)
                    details.Modify(R,,, '#' tmp.Count ' | ' Username ' (' statistic['user'][tmp.Count].Length ')')
                } Else {
                    statistic['user'][1].Push(Sell)
                    details.Modify(1,,, '#' tmp.Count ' | Unknown (' statistic[1][tmp.Count].Length ')')
                }
            }
    }
    details.ModifyCol(1, 'AutoHdr')
    details.ModifyCol(2, 'AutoHdr')
    C4.Enabled := True
    ;Loop Files, 'commit\archived\' A_LoopFileName '\*.json' {
        ;    SellID := A_Index
        ;    Items := readJson(A_LoopFileFullPath)
        ;    C := S := P := Q := 0
        ;    For Item in Items['Items'] {
        ;        Co := Item[4] * Item[7]
        ;        Se := Item[5] * Item[7]
        ;        Qa := Item[7] / Item[6]
        ;        C += Co
        ;        S += Se
        ;        Q += Qa
        ;        Item.InsertAt(1, [DateTime, Co, Se, Se - Co]*)
        ;        If SellID = 1 {
        ;            details.Modify(R,, Item*)
        ;        }
        ;        Else R := details.Add(, Item*)
        ;        ;--R
        ;        addedRowColorize(R, 4)
        ;        updateRowViewCurrency(R, 4)
        ;        detailsCLV.Cell(R, 2,, 0xFFFF0000)
        ;        detailsCLV.Cell(R, 3,, 0xFF008000)
        ;        detailsCLV.Cell(R, 4,, 0xFF008000)
        ;    }
        ;    P := S - C
        ;}
    ;autoResizeCols()
}
ShowLess(Ctrl, Info) {
    details.Visible := True
    C4.Visible := True
    detailsA.Visible := False
    C5.Visible := False
    If !Row := details.GetNext()
        Return
    details.Focus()
}
ShowMore(Ctrl, Info) {
    If !Row := Ctrl.GetNext()
        Return
    If C4.Value = 1
        Return
    details.Visible := False
    detailsA.Visible := True
    C4.Visible := False
    C5.Visible := True
    detailsA.Delete()
    statistic['list'] := []
    Switch C4.Value {
        Case 2:
            Loop Files, statistic['clears'][Row] '\*.json' {
                Items := readJson(A_LoopFileFullPath)
                statistic['list'].Push(Items)
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                detailsA.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
        Case 3:
            For Items in statistic['year'][Row] {
                statistic['list'].Push(Items)
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                detailsA.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
        Case 4:
            For Items in statistic['month'][Row] {
                statistic['list'].Push(Items)
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                detailsA.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
        Case 5:
            For Items in statistic['day'][Row] {
                statistic['list'].Push(Items)
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                detailsA.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
        Case 6:
            For Items in statistic['hour'][Row] {
                statistic['list'].Push(Items)
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                detailsA.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
        Case 7:
            For Items in statistic['user'][Row] {
                statistic['list'].Push(Items)
                DateTime := Items['CommitTime']
                DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
                detailsA.Add('Icon' . 2,, '#' A_Index ' | ' DateTime)
            }
    }
}
ShowDetails(Ctrl, Item, Selected) {
    If !Selected
        Return
    If Ctrl.Hwnd = details.Hwnd && C4.Value != 1
        Return
    ItemsList := Ctrl.Hwnd = details.Hwnd ? statistic['items'] : statistic['list']
    sellDetails.Delete()
    itemsBuyValue.Value := 0
    itemsSellValue.Value := 0
    itemsProfitValue.Value := 0
    S := B := P := 0
    While Next := Ctrl.GetNext(IsSet(Next) ? Next : 0) {
        Items := ItemsList[Next]
        For Each, Item in Items['Items'] {
            Row := sellDetails.Add(, Item*)
            S += Item[5] * Item[7] / Item[6]
            B += Item[4] * Item[7] / Item[6]
        }
    }
    If S {
        itemsBuyValue.Value := Round(B * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        itemsSellValue.Value := Round(S * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        itemsProfitValue.Value := Round((S - B) * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
    }
    Loop sellDetails.GetCount() {
        Row := A_Index
        updateRowViewCurrency(Row)
        addedRowColorize(Row)
    }
    autoResizeCols()
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
cSPASort(Items) {
    Costs := []
    Sells := []
    Profits := []
    Quantitys := []
    For Item, Detail in statistic['items'] {
        Costs.Push([Detail.C, Item])
        Sells.Push([Detail.S, Item])
        Profits.Push([Detail.S - Detail.C, Item])
        Quantitys.Push([Detail.Q, Item])
    }
    Costs := sortDecrease(Costs)
    Sells := sortDecrease(Sells)
    Profits := sortDecrease(Profits)
    Quantitys := sortDecrease(Quantitys)
    Return [Costs, Sells, Profits, Quantitys]
}
sortDecrease(List) {
    Loop List.Length {
        Max := List[O := A_Index][1]
        Loop List.Length - O {
            Val := List[O + (I := A_Index)][1]
            If Val > Max {
                Aux := List[O]
                List[O] := List[O + I]
                List[O + I] := Aux
                Max := Val
            }
        }
    }
    Return List
}
updateRowViewCurrency(Row := 0, StartCol := 0) {
    If Row {
        tmp := []
        Loop StartCol - 1 {
            Value := sellDetails.GetText(Row, 1 + A_Index)
            If IsNumber(Value) {
                Value := Round(Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
            }
            tmp.Push(Value)
        }
        For Each, Col in setting['Sell']['Session']['03'] {
            Value := sellDetails.GetText(Row, StartCol + Each)
            Switch Col {
                Case 'Buy Value', 'Sell Value', 'Added Value', 'Price':
                    Value := Round(Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
                    tmp.Push(Value)
                Case 'CUR':
                    tmp.Push(setting['DisplayCurrency'])
                Default: tmp.Push(Value)
            }
        }
        sellDetails.Modify(Row,, tmp*)
    }
}
autoResizeCols() {
    Loop sellDetails.GetCount('Col') {
        If A_Index = 11 {
            sellDetails.ModifyCol(11, 'Center 50')
            Continue
        }
        sellDetails.ModifyCol(A_Index, 'Center AutoHdr')
    }
}
addedRowColorize(Row, StartCol := 0) {
    sellDetailsCLV.Row(Row, , 0xFF000000)
    sellDetailsCLV.Cell(Row, StartCol + 2, , 0xFF0000FF)
    sellDetailsCLV.Cell(Row, StartCol + 4, , 0xFFFF0000)
    sellDetailsCLV.Cell(Row, StartCol + 5, , 0xFF008040)
    sellDetailsCLV.Cell(Row, StartCol + 10, , 0xFF008000)
    sellDetailsCLV.Cell(Row, StartCol + 11, 0xFFFFC080)
}