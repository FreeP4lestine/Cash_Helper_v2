resizeControls(GuiObj, MinMax, Width, Height) {
    C2.Move(,, Width - 164)
    ;filtersList.Move(,,, Height - 300)
    ;filteredList.Move(,,, Height - 300)
    details.Move(,, Width - 80, Height - 300)
    Box1.ResizeShadow()
    ;Box2.ResizeShadow()
    Box3.ResizeShadow()
    SetTimer(boxRedraw, 0)
	SetTimer(boxRedraw, -500)
}
boxRedraw() {
    Box1.RedrawShadow()
    ;Box2.RedrawShadow()
    Box3.RedrawShadow()
}
loadAll() {
    Loop Files, 'commit\archived\*', 'D' {
        DateTime := FormatTime(A_LoopFileName, 'yyyy/MM/dd [ HH:mm:ss ]')
        R := details.Add(, DateTime ': ')
        detailsCLV.Cell(R, 1,, 0xFF000080)
        Loop Files, 'commit\archived\' A_LoopFileName '\*.json' {
            SellID := A_Index
            Items := readJson(A_LoopFileFullPath)
            C := S := P := Q := 0
            For Item in Items['Items'] {
                Co := Item[4] * Item[7]
                Se := Item[5] * Item[7]
                Qa := Item[7] / Item[6]
                C += Co
                S += Se
                Q += Qa
                Item.InsertAt(1, [DateTime, Co, Se, Se - Co]*)
                If SellID = 1 {
                    details.Modify(R,, Item*)
                }
                Else R := details.Add(, Item*)
                ;--R
                addedRowColorize(R, 4)
                updateRowViewCurrency(R, 4)
                detailsCLV.Cell(R, 2,, 0xFFFF0000)
                detailsCLV.Cell(R, 3,, 0xFF008000)
                detailsCLV.Cell(R, 4,, 0xFF008000)
            }
            P := S - C
        }
    }
    autoResizeCols()
}
;loadFilters(Flag := 0) {
;    Switch Flag {
;        Case 0:
;            C := S := P := Q := 0
;            Loop Files, 'commit\archived\*', 'D' {
;                DateTime := FormatTime(A_LoopFileName, 'yyyy/MM/dd [ HH:mm:ss ]')
;                If !statistic['clears'].Has(DateTime)
;                    statistic['clears'][DateTime] := []
;                Loop Files, 'commit\archived\' A_LoopFileName '\*.json' {
;                    Items := readJson(A_LoopFileFullPath)
;                    statistic['clears'][DateTime].Push(Items)
;                    Name := SubStr(A_LoopFileName, 1, -5)
;                    Year := FormatTime(Name, 'yyyy')
;                    If !statistic['year'].Has(Year)
;                        statistic['year'][Year] := []
;                    statistic['year'][Year].Push(Items)
;                    Month := FormatTime(Name, 'yyyy/MM')
;                    If !statistic['month'].Has(Month)
;                        statistic['month'][Month] := []
;                    statistic['month'][Month].Push(Items)
;                    Day := FormatTime(Name, 'yyyy/MM/dd')
;                    If !statistic['day'].Has(Day)
;                        statistic['day'][Day] := []
;                    statistic['day'][Day].Push(Items)
;                    Hour := FormatTime(Name, 'yyyy/MM/dd [ HH ]')
;                    If !statistic['hour'].Has(Hour)
;                        statistic['hour'][Hour] := []
;                    statistic['hour'][Hour].Push(Items)
;                    If !Items.Has('Username') || Items['Username'] = '' {
;                        If !statistic['user'].Has('--Unknown--') {
;                            statistic['user']['--Unknown--'] := []
;                        }
;                        statistic['user']['--Unknown--'].Push(Items)
;                    } Else {
;                        If !statistic['user'].Has(Items['Username']) {
;                            statistic['user'][Items['Username']] := []
;                        }
;                        statistic['user'][Items['Username']].Push(Items)
;                    }
;                    For Item in Items['Items'] {
;                        If !statistic['items'].Has(Item[2]) {
;                            statistic['items'][Item[2]] := {C: 0, S: 0, Q: 0}
;                        }
;                        Co := Item[4] * Item[7]
;                        Se := Item[5] * Item[7]
;                        Qa := Item[7] / Item[6]
;                        statistic['items'][Item[2]].C += Co
;                        statistic['items'][Item[2]].S += Se
;                        statistic['items'][Item[2]].Q += Qa
;                        C += Co
;                        S += Se
;                        Q += Qa
;                    }
;                }
;            }
;            P := S - C
;            filtersList.Modify(1,, filtersList.GetText(1) ' - ( ' statistic['clears'].Count ' )')
;            filtersList.Modify(2,, filtersList.GetText(2) ' - ( ' statistic['year'].Count ' )')
;            filtersList.Modify(3,, filtersList.GetText(3) ' - ( ' statistic['month'].Count ' )')
;            filtersList.Modify(4,, filtersList.GetText(4) ' - ( ' statistic['day'].Count ' )')
;            filtersList.Modify(5,, filtersList.GetText(5) ' - ( ' statistic['user'].Count ' )')
;            filtersList.Modify(6,, filtersList.GetText(6) ' - ( ' statistic['hour'].Count ' )')
;            filtersList.Modify(7,, filtersList.GetText(7) ' - ( ' statistic['items'].Count ' )')
;            filtersList.Modify(8,, filtersList.GetText(8) ' - ( ' statistic['items'].Count ' )')
;            filtersList.Modify(9,, filtersList.GetText(9) ' - ( ' statistic['items'].Count ' )')
;            filtersList.Modify(10,, filtersList.GetText(10) ' - ( ' statistic['items'].Count ' )')
;        }
;}
;displayFiltersDetails() {
;    filteredList.Delete()
;    CSPA := cSPASort(statistic['items'])
;    Switch filtersList.GetNext() {
;        Case 1:
;            For Clear in statistic['clears'] {
;                filteredList.Add('Icon4', Clear)
;            }
;        Case 2:
;            For Year in statistic['year'] {
;                filteredList.Add('Icon5', Year)
;            }
;        Case 3:
;            For Month in statistic['month'] {
;                filteredList.Add('Icon6', Month)
;            }
;        Case 4:
;            For Day in statistic['day'] {
;                filteredList.Add('Icon7', Day)
;            }
;        Case 5:
;            For User in statistic['user'] {
;                filteredList.Add('Icon3', User)
;            }
;        Case 6:
;            For Hour in statistic['hour'] {
;                filteredList.Add('Icon8', Hour)
;            }
;        Case 7:
;            For Each, Item in CSPA[1] {
;                filteredList.Add('Icon10', Item[2] ' [ ' Round(Item[1], setting['Rounder']) ' ]')
;            }
;        Case 8:
;            For Each, Item in CSPA[2] {
;                filteredList.Add('Icon9', Item[2] ' [ ' Round(Item[1], setting['Rounder']) ' ]')
;            }
;        Case 9:
;            For Each, Item in CSPA[3] {
;                filteredList.Add('Icon9', Item[2] ' [ ' Round(Item[1], setting['Rounder']) ' ]')
;            }
;        Case 10:
;            For Each, Item in CSPA[4] {
;                filteredList.Add('Icon11', Item[2] ' [ ' LeadTrailZeroTrim(Round(Item[1], setting['Rounder'])) ' ]')
;            }
;    }
;}
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
        tmp := ['']
        Loop StartCol - 1 {
            Value := details.GetText(Row, 1 + A_Index)
            If IsNumber(Value) {
                Value := Round(Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
            }
            tmp.Push(Value)
        }
        For Each, Col in setting['Sell']['Session']['03'] {
            Value := details.GetText(Row, StartCol + Each)
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
addedRowColorize(Row, StartCol := 0) {
    detailsCLV.Row(Row, , 0xFF000000)
    detailsCLV.Cell(Row, StartCol + 2, , 0xFF0000FF)
    detailsCLV.Cell(Row, StartCol + 4, , 0xFFFF0000)
    detailsCLV.Cell(Row, StartCol + 5, , 0xFF008040)
    detailsCLV.Cell(Row, StartCol + 10, , 0xFF008000)
    detailsCLV.Cell(Row, StartCol + 11, 0xFFFFC080)
}
;displayDetails() {
;    filteredList.Enabled := False
;    details.Enabled := False
;    details.Delete()
;    If !R := filteredList.GetNext() {
;        Return
;    }
;    Key := filteredList.GetText(R)
;    Switch filtersList.GetNext() {
;        Case 1: Selections := statistic['clears']
;        Case 2: Selections := statistic['year']
;        Case 3: Selections := statistic['month']
;        Case 4: Selections := statistic['day']
;        Case 5: Selections := statistic['user']
;        Case 6: Selections := statistic['hour']
;        Default: Selections := []
;    }
;    For Items in Selections[Key] {
;        For Item in Items['Items']
;            details.Add(, Item*)
;    }
;    Loop details.GetCount() {
;        Row := A_Index
;        updateRowViewCurrency(Row)
;        addedRowColorize(Row)
;    }
;    autoResizeCols()
;    filteredList.Enabled := True
;    details.Enabled := True
;}