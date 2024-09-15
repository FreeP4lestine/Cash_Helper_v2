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
        If A_Index = 11 {
            Continue
        }
        details.ModifyCol(A_Index, 'Center AutoHdr')
    }
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
    review['Items'] := [0, 0]
    overAllItem.Text := 'Selection summary: [ 0 ]'
    itemTotalCalculate()
    Next := 0
    Selected := 0
    Sleep(250)
    While Next := nonSubmitted.GetNext(Next) {
        Ptr := review['Pointer'][Next]
        Items := review['Pending'][Ptr]
        For Each, Item in Items['Items'] {
            review['Items'][1] += Item[4] * Item[7] / Item[6]
            review['Items'][2] += Item[10]
            Row := details.Add(, Item*)
            updateRowViewCurrency(Row)
            addedRowColorize(Row)
        }
        Selected++
    }
    If Selected = 1 {
        openTime.Value := 'Open Time: ' FormatTime(Items['OpenTime'], 'yyyy/MM/dd HH:mm:ss')
        commitTime.Value := 'Commit Time: ' FormatTime(Items['CommitTime'], 'yyyy/MM/dd HH:mm:ss')
    } Else {
        openTime.Value := 'Open Time: Multi'
        commitTime.Value := 'Commit Time : Multi'
    }
    autoResizeCols()
    overAllItem.Text := 'Selection summary: [ ' Selected ' ]'
    itemTotalCalculate()
}
itemTotalCalculate() {
        itemsBuyValue.Value := review['Items'][1] ? Round(review['Items'][1] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
        itemsSellValue.Value := review['Items'][2] ? Round(review['Items'][2] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
        itemsProfitValue.Value := review['Items'][2] - review['Items'][1] ? Round((review['Items'][2] - review['Items'][1]) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
    }
nItems(Dir) {
    objFolder := ComObject("Scripting.FileSystemObject").GetFolder(Dir)
    Return { Files: objFolder.Files.Count, Subdirs: objFolder.SubFolders.Count }
}
loadPendingSells(Flag, Username := '', Date := '') {
    If Username = 'Everyone' {
        Flag := 0
    }
    Try CountAll := nItems('commit\pending').Files
    Catch {
        CountAll := 0
        Loop Files, 'commit\pending\*.json' {
            CountAll++
        }
    }
    nonSubmittedPB.Value := 0
    nonSubmittedPB.Opt('Range1-' CountAll)
    nonSubmittedPB.Visible := True
    review['Items'] := [0, 0]
    overAllItem.Text := 'Selection summary: [ 0 ]'
    itemTotalCalculate()
    review['OverAllUser'] := [0, 0]
    totalUserUpdate()
    overAllUser.Text := 'Current user summary: [ 0 ]'
    nonSubmittedTxt.Text := 'Non reviewed sells [ 0 ]'
    nonSubmitted.Delete()
    review['Pointer'] := []
    Switch Flag {
        Case 0: 
            review['Pending'] := []
            review['File'] := []
            review['OverAll'] := [0, 0]
            daysList.Delete()
            review['Days'] := Map()
            totalUpdate()
            overAllTotal.Text := 'Overall Summary: [ 0 ]'
            Loop Files, 'commit\pending\*.json' {
                Items := readJson(A_LoopFileFullPath)
                review['File'].Push(A_LoopFileFullPath)
                review['Pending'].Push(Items)
                addToTheList(A_Index, Items)
                numberUsers(Items)
                overAllCalculate(Items)
                nonSubmittedPB.Value++
            }
            totalUpdate()
            overAllTotal.Text := 'Overall Summary: [ ' review['Pointer'].Length ' ]'
            nonSubmittedPB.Visible := False
            nonSubmittedTxt.Text := 'Non reviewed sells [ ' review['Pointer'].Length ' ]'
        Case 1:
            For Items in review['Pending'] {
                If InStr(review['File'][A_Index], 'archived') || !Items.Has('Username') || Items['Username'] = '' || (Username != Items['Username'])
                    Continue
                addToTheList(A_Index, Items)
                overAllUserCalculate(Items)
                nonSubmittedPB.Value++
            }
            totalUserUpdate()
            overAllUser.Text := 'Current user summary: [ ' review['Pointer'].Length ' ]'
            nonSubmittedPB.Visible := False
            nonSubmittedTxt.Text := 'Non reviewed sells [ ' review['Pointer'].Length ' ]'
        Case 2:
            For Ptr in review['Days'][Date] {
                Items := review['Pending'][Ptr]
                review['Pointer'].Push(Ptr)
                Date := FormatTime(Items['CommitTime'], 'yyyy/MM/dd')
                Time := FormatTime(Items['CommitTime'], '[ HH:mm:ss ]')
                DateTime := Date ' ' Time
                nonSubmitted.Add('icon1', DateTime ' [ ' Items['Items'].Length ' ]')
            }
            nonSubmittedPB.Visible := False
            nonSubmittedTxt.Text := 'Non reviewed sells [ ' review['Days'][Date].Length ' ]'
    }
}
addToTheList(Index, Items) {
    review['Pointer'].Push(Index)
    Date := FormatTime(Items['CommitTime'], 'yyyy/MM/dd')
    Time := FormatTime(Items['CommitTime'], '[ HH:mm:ss ]')
    DateTime := Date ' ' Time
    If !review['Days'].Has(Date) {
        review['Days'][Date] := []
        daysList.Add('icon5', Date)
    }
    review['Days'][Date].Push(Index)
    nonSubmitted.Add('icon1', DateTime ' [ ' Items['Items'].Length ' ]')
}
numberUsers(Items) {
    If Items.Has('Username')&& Items['Username'] != 'Everyone' && Items['Username'] != '' && !review['Users'].Has(Items['Username']) {
        review['Users'][Items['Username']] := True
        usersList.Add('Icon3', Items['Username'])
    }
}
overAllCalculate(Items) {
    For Every, Item in Items['Items'] {
        review['OverAll'][1] += Item[4] * Item[7] / Item[6]
        review['OverAll'][2] += Item[10]
    }
}
overAllUserCalculate(Items) {
    For Every, Item in Items['Items'] {
        review['OverAllUser'][1] += Item[4] * Item[7] / Item[6]
        review['OverAllUser'][2] += Item[10]
    }
}
totalUpdate() {
    totalBuyValue.Value := review['OverAll'][1] ? Round(review['OverAll'][1] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
    totalSellValue.Value := review['OverAll'][2] ? Round(review['OverAll'][2] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
    totalProfitValue.Value := review['OverAll'][2] - review['OverAll'][1] ? Round((review['OverAll'][2] - review['OverAll'][1]) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
}
totalUserUpdate() {
    totalUserBuyValue.Value := review['OverAllUser'][1] ? Round(review['OverAllUser'][1] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
    totalUserSellValue.Value := review['OverAllUser'][2] ? Round(review['OverAllUser'][2] * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
    totalUserProfitValue.Value := review['OverAllUser'][2] - review['OverAllUser'][1] ? Round((review['OverAllUser'][2] - review['OverAllUser'][1]) * currency['rates'][setting['DisplayCurrency']], setting['Rounder']) ' ' setting['DisplayCurrency'] : 0
}
clearSells() {
    If 'Yes' != MsgBox('Are you sure to clear all the listed sells?', 'Clear', 0x40 + 0x4)
        Return
    If !DirExist('commit\archived\' N := A_Now) {
        DirCreate('commit\archived\' N)
    }
    nonSubmittedPB.Value := 0
    nonSubmittedPB.Opt('Range1-' review['Pointer'].Length)
    nonSubmittedPB.Visible := True
    For Ptr in review['Pointer'] {
        If InStr(review['File'][Ptr], 'archived') {
            Continue
        }
        FileMove(review['File'][Ptr], 'commit\archived\' N '\')
        Items := review['Pending'][Ptr]
        For Each, Item in Items['Items'] {
            review['OverAll'][1] -= Item[4] * Item[7] / Item[6]
            review['OverAll'][2] -= Item[10]
        }
        SplitPath(review['File'][Ptr], &OutFileName)
        review['File'][Ptr] := 'commit\archived\' N '\' OutFileName
        nonSubmitted.Modify(A_Index, 'Icon2')
        nonSubmittedPB.Value++
    }
    nonSubmittedPB.Visible := False
    review['Items'] := [0, 0]
    itemTotalCalculate()
    overAllItem.Text := 'Selection summary: [ 0 ]'
    review['OverAllUser'] := [0, 0]
    totalUserUpdate()
    overAllUser.Text := 'Current user summary: [ 0 ]'
    If review['OverAll'][1] < 0 {
        review['OverAll'][1] := 0
    }
    If review['OverAll'][2] < 0 {
        review['OverAll'][2] := 0
    }
    totalUpdate()
    overAllTotal.Text := 'Overall Summary: [ 0 ]'
    MsgBox('All clear!', 'Clear', 0x40)
}
resizeControls(GuiObj, MinMax, Width, Height) {
    C2.Move(, , Width - 164)
    nonSubmitted.GetPos(, &Y)
    nonSubmitted.Move(,,, Height - Y - 110)
    daysList.GetPos(, &Y)
    daysList.Move(,,, Height - Y - 25)
    submit.Move(, Height - 60)
    details.GetPos(&X, &Y, &CWidth, &CHeight)
    details.Move(, , WW := Width - X - 40, Height - Y - 270)
    openTime.Move(, , WW // 2)
    commitTime.Move(X + WW // 2, , WW // 2)
    overallUser.Move(, Height - 230, WW)
    totalUserBuyValue.Move(, Height - 200, WW // 3 - 10)
    totalUserSellValue.Move(X + WW // 3 + 10, Height - 200, WW // 3 - 10)
    totalUserProfitValue.Move(X + WW // 3 * 2 + 10, Height - 200, WW // 3 - 10)
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
    Box4.ResizeShadow()
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
    Box4.RedrawShadow()
    Box5.RedrawShadow()
    Box6.RedrawShadow()
    Box7.RedrawShadow()
    Box8.RedrawShadow()
}