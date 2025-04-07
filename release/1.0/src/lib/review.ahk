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
        details.Modify(Row, , tmp*)
    }
}
autoResizeCols() {
    Loop details.GetCount('Col') {
        If A_Index = 11 || A_Index = 1 {
            Continue
        }
        details.ModifyCol(A_Index, 'Center AutoHdr')
    }
    details.ModifyCol(1, '0')
    details.ModifyCol(11, 'Center 50')
}
addedRowColorize(Row) {
    detailsCLV.Row(Row, , 0xFF000000)
    detailsCLV.Cell(Row, 2, , 0xFF0000FF)
    detailsCLV.Cell(Row, 4, , 0xFF804000)
    detailsCLV.Cell(Row, 5, , 0xFF008040)
    detailsCLV.Cell(Row, 10, , 0xFFFF0000)
    detailsCLV.Cell(Row, 11, 0xFFFFC080)
}
displayDetails() {
    details.Delete()
    itemsBuyValue.Value := 0
    itemsSellValue.Value := 0
    itemsProfitValue.Value := 0
    S := B := P := 0
    While Next := nonSubmitted.GetNext(IsSet(Next) ? Next : 0) {
        Ptr := review['Pointer'][Next]
        Sell := review['Pending'][Ptr]
        For Each, Item in Sell.JSON['Items'] {
            Row := details.Add(, Item*)
            S += Item[5] * Item[7] / Item[6]
            B += Item[4] * Item[7] / Item[6]
        }
    }
    If S {
        itemsBuyValue.Value := Round(B * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        itemsSellValue.Value := Round(S * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        itemsProfitValue.Value := Round((S - B) * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
    }
    Loop details.GetCount() {
        Row := A_Index
        updateRowViewCurrency(Row)
        addedRowColorize(Row)
    }
    autoResizeCols()
}
loadAll() {
    nonSubmitted.Delete()
    nonSubmittedTxt.Value := 'Sells loading - Please wait...'
    nItems(Dir) {
        objFolder := ComObject("Scripting.FileSystemObject").GetFolder(Dir)
        Return { Files: objFolder.Files.Count, Subdirs: objFolder.SubFolders.Count }
    }
    Try CountAll := nItems('commit\pending').Files
    Catch {
        CountAll := 0
        Loop Files, 'commit\pending\*.json' {
            CountAll++
        }
    }
    review['Pending'] := []
    review['Pointer'] := []
    S := B := P := 0
    Loop Files, 'commit\pending\*.json' {
        Sell := {File: A_LoopFileFullPath, JSON: readJson(A_LoopFileFullPath)}
        review['Pending'].Push(Sell)
        review['Pointer'].Push(A_Index)
        DateTime := FormatTime(Sell.JSON['CommitTime'], 'yyyy/MM/dd [ HH:mm:ss ]')
        nonSubmitted.Add('icon1', DateTime ' [ ' Sell.JSON['Items'].Length ' ]')
        For Item in Sell.JSON['Items'] {
            S += Item[10]
            B += Item[4] * Item[7] / Item[6]
        }
    }
    nonSubmittedTxt.Value := 'Non reviewed sells'
    If S {
        totalBuyValue.Value := Round(B * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        totalSellValue.Value := Round(S * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        totalProfitValue.Value := Round((S - B) * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
    }
    loadUsers()
    loadDays()
}
loadUsers() {
    Users.Value := 'Users loading - Please wait...'
    Found := review['Users'] := Map()
    usersList.Delete()
    usersList.Add('Icon4 Select Focus', 'Everyone')
    usersList.Modify(1,, 'Every (one / day) - ( ' review['Pending'].Length ' )')
    For Sell in review['Pending'] {
        If !Sell.JSON.Has('Username') || Sell.JSON['Username'] = '' {
            If !Found.Has('--Unknown--') {
                R := usersList.Add('Icon3', '--Unknown--')
                Found['--Unknown--'] := {Title: '--Unknown--', Row: R, Pointer: []}
            }
            Found['--Unknown--'].Pointer.Push(A_Index)
            usersList.Modify(Found['--Unknown--'].Row,, Found['--Unknown--'].Title ' (' Found['--Unknown--'].Pointer.Length ')')
            Continue
        }
        If !Found.Has(Sell.JSON['Username']) {
            R := usersList.Add('Icon3', Sell.JSON['Username'])
            Found[Sell.JSON['Username']] := {Title: Sell.JSON['Username'], Row: R, Pointer: []}
        }
        Found[Sell.JSON['Username']].Pointer.Push(A_Index)
        usersList.Modify(Found[Sell.JSON['Username']].Row,, Found[Sell.JSON['Username']].Title ' - (' Found[Sell.JSON['Username']].Pointer.Length ')')
    }
    Users.Value := 'Users:'
}
loadDays() {
    daysList.Delete()
    Days.Value := 'Days loading - Please wait...'
    Found := review['Days'] := Map()
    For Sell in review['Pending'] {
        Day := FormatTime(Sell.JSON['CommitTime'], 'yyyy/MM/dd')
        If !Found.Has(Day) {
            R := daysList.Add('Icon5', Day)
            Found[Day] := {Title: Day, Row: R, Pointer: []}
        }
        Found[Day].Pointer.Push(A_Index)
        daysList.Modify(Found[Day].Row,, Found[Day].Title ' - (' Found[Day].Pointer.Length ')')
    }
    Days.Value := 'Days:'
}
loadPendingSells(Flag) {
    review['Users']
    Switch Flag {
        Case 0: loadAll()
        Case 1:
            nonSubmitted.Delete()
            R := usersList.GetNext()
            If !R {
                Return
            }
            If R = 1 {
                loadPendingSells(0)
                Return
            }
            UsernameA := usersList.GetText(usersList.GetNext())
            UsernameA := StrSplit(UsernameA, ' - ')[1]
            review['Pointer'] := []
            For Ptr in review['Users'][UsernameA].Pointer {
                Sell := review['Pending'][Ptr]
                If InStr(Sell.File, 'archived') {
                    Continue
                }
                DateTime := FormatTime(Sell.JSON['CommitTime'], 'yyyy/MM/dd [ HH:mm:ss ]')
                nonSubmitted.Add('icon1', DateTime ' [ ' Sell.JSON['Items'].Length ' ]')
                review['Pointer'].Push(Ptr)
            }
        Case 2:
            nonSubmitted.Delete()
            R := daysList.GetNext()
            If !R {
                Return
            }
            Day := daysList.GetText(daysList.GetNext())
            Day := StrSplit(Day, ' - ')[1]
            review['Pointer'] := []
            For Ptr in review['Days'][Day].Pointer {
                Sell := review['Pending'][Ptr]
                If InStr(Sell.File, 'archived') {
                    Continue
                }
                DateTime := FormatTime(Sell.JSON['CommitTime'], 'yyyy/MM/dd [ HH:mm:ss ]')
                nonSubmitted.Add('icon1', DateTime ' [ ' Sell.JSON['Items'].Length ' ]')
                review['Pointer'].Push(Ptr)
            }
    }
}
clearSells() {
    If 'Yes' != MsgBox('Are you sure to clear all the listed sells?', 'Clear', 0x40 + 0x4)
        Return
    details.Delete()
    itemsBuyValue.Value := 0
    itemsSellValue.Value := 0
    itemsProfitValue.Value := 0
    If !DirExist('commit\archived\' N := A_Now) {
        DirCreate('commit\archived\' N)
    }
    For Ptr in review['Pointer'] {
        Sell := review['Pending'][Ptr]
        If InStr(Sell.File, 'archived') {
            Continue
        }
        FileMove(Sell.File, 'commit\archived\' N '\')
        SplitPath(Sell.File, &OutFileName)
        Sell.File := 'commit\archived\' N '\' OutFileName
        nonSubmitted.Modify(A_Index, 'Icon2')
    }
    reCalculateTotal()
    reCalculateTotal() {
        S := B := P := 0
        For Sell in review['Pending'] {
            If InStr(Sell.File, 'archived') {
                Continue
            }
            For Item in Sell.JSON['Items'] {
                S += Item[5] * Item[7] / Item[6]
                B += Item[4] * Item[7] / Item[6]
            }
        }
        If S {
            totalBuyValue.Value := Round(B * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
            totalSellValue.Value := Round(S * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
            totalProfitValue.Value := Round((S - B) * currency['rates'][Setting['DisplayCurrency']], setting['Rounder']) ' ' Setting['DisplayCurrency']
        }
    }
    MsgBox('All clear!', 'Clear', 0x40)
}
resizeControls(GuiObj, MinMax, Width, Height) {
    C2.Move(, , Width - 164)
    nonSubmitted.GetPos(, &Y)
    nonSubmitted.Move(,,, Height - Y - 70)
    daysList.GetPos(, &Y)
    daysList.Move(,,, Height - Y - 25)
    submit.Move(, Height - 60)
    details.GetPos(&X, &Y, &CWidth, &CHeight)
    details.Move(, , WW := Width - X - 40, Height - Y - 210)
    openTime.Move(, , WW // 2)
    commitTime.Move(X + WW // 2, , WW // 2)
    overAllItem.Move(, Height - 170, WW)
    itemsBuyValue.Move(, Height - 140, WW // 3 - 10)
    itemsSellValue.Move(X + WW // 3 + 10, Height - 140, WW // 3 - 10)
    itemsProfitValue.Move(X + WW // 3 * 2 + 10, Height - 140, WW // 3 - 10)
    overallTotal.Move(, Height - 100, WW)
    totalBuyValue.Move(, Height - 70, WW // 3 - 10)
    totalSellValue.Move(X + WW // 3 + 10, Height - 70, WW // 3 - 10)
    totalProfitValue.Move(X + WW // 3 * 2, Height - 70, WW // 3 - 10)
    Box1.ResizeShadow()
    Box2.ResizeShadow()
    Box3.ResizeShadow()
    Box5.ResizeShadow()
    Box6.ResizeShadow()
    Box7.ResizeShadow()
    Box8.ResizeShadow()
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
    Box8.RedrawShadow()
}

CancelSellNow() {
    Msgbox nonSubmitted.GetNext(IsSet(R) ? R : 0)
    If !R := nonSubmitted.GetNext() {
        Loop Files, 'commits\pending\*.json' {
            Data := readJson(A_LoopFileFullPath)
            RechargeStock(Data)
            FileDelete(A_LoopFileFullPath)
        }
    } Else While (R := nonSubmitted.GetNext(IsSet(R) ? R : 0)) {
        Msgbox File := review['Pending'][review['Pointer'][R]].File
        Data := readJson(File)
        RechargeStock(Data)
        FileDelete(File)
    }
    RechargeStock(Items) {
        For Item in Items['Items'] {
            Code := Item[2]
            Def := readJson('setting\Defs\' Code '.json')
            Def['Stock Value'] += Item[7]
        }
    }
}