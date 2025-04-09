resizeControls(GuiObj, MinMax, Width, Height) {
    HeaderText.Move(,, Width - 160)
    HeaderBox.ResizeShadow()
    
    CommitLaterList.Move(,,, Height - 280)
    CommitLaterListZoom.Move(,,, Height - 280)
    Clearout.Move(, Height - 70)
    CommitListBox.ResizeShadow()

    DetailsList.Move(,, Width - 635, Height - 350)
    CashoutProgress.Move(, Height - 180, Width - 635)
    DetailsBox.ResizeShadow()

    DetailsList.GetPos(&X, &Y, &Width)
    CommitPaybackHistory.Move(X + Width + 55, Y,, Height - 360)
    CommitPaybackValue.Move(X + Width + 55, Height - 198)
    CommitPaybackHistoryBox.ResizeShadow()

    Width += 295
    TotalAmountText.Move(X, Height - 115, Width / 3)
    TotalAmount.Move(X, Height - 75, Width / 3)

    PaidAmountText.Move(X + Width / 3, Height - 115, Width / 3)
    PaidAmount.Move(X + Width / 3, Height - 75, Width / 3)

    LeftAmountText.Move(X + 2 * Width / 3, Height - 115, Width / 3)
    LeftAmount.Move(X + 2 * Width / 3, Height - 75, Width / 3)

    ResumeBox.ResizeShadow()
    ResumeBox.RedrawControls()
}

commitCheckout() {
    If !Row := CommitLaterListZoom.GetNext() {
        Return
    }
    If !IsNumber(commitAmountPay.Value) {
        MsgBox('Please enter a valid number!', setting['Name'], 0x30)
        Return
    }
    Name := CommitLaterList.GetText(CommitLaterList.GetNext())
    Location := 'commit\pending\later\' Name '\' names[Name][Row]['CommitTime'] '.json'
    If !names[Name][Row].Has('CreditCashout') {
        names[Name][Row]['CreditCashout'] := Map()
    }
    names[Name][Row]['CreditCashout'][Now := A_Now] := commitAmountPay.Value
    writeJson(names[Name][Row], Location)
    CashoutInfo(CommitLaterListZoom, CommitLaterListZoom.GetNext(), 1)
    ShowNameResume(CommitLaterList, CommitLaterList.GetNext(), 1)
    SetTimer(commitClose, -5000)
	commitImg.Value := 'images\commit.png'
	commitMsg.Opt('BackgroundGreen cWhite')
	commitMsg.Value := 'Commited!'
	commitAmount.Opt('ReadOnly BackgroundE6E6E6 cGray')
	commitAmountPay.Opt('ReadOnly BackgroundE6E6E6 cGray')
	commitAmountPayBack.Opt('ReadOnly BackgroundE6E6E6 cGray')
	commitOK.Enabled := False
	commitCancel.Enabled := False
	Invoice.Enabled := False
	commitMsg.Focus()
	mainWindow.Opt('-Disabled')
	payCheckWindow.Opt('-Disabled')
	payCheckWindow.Show()
}
commitClose() {
    payCheckWindow.Hide()
    mainWindow.Opt('-Disabled')
}

enterCheckout() {
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
    AmountTotal := CommitLaterListZoom.GetText(CommitLaterListZoom.GetNext(), 2)
	AmountTotal := StrSplit(AmountTotal, ' ')[1]
    AmountPaid := 0
    Loop CommitPaybackHistory.GetCount() {
        AmountPaid += StrSplit(CommitPaybackHistory.GetText(A_Index, 2), ' ')[1]
    }
    commitAmount.Value := Round(AmountTotal - AmountPaid, setting['Rounder']) ' ' setting['DisplayCurrency']
	AC := StrSplit(commitAmount.Value, ' ')
	commitAmountPay.Value := AC[1]
	commitAmountPayBack.Value := ''
	commitAmountPay.Focus()
	updateAmountPayBack()
}

updateAmountPayBack() {
	AC := StrSplit(commitAmount.Value, ' ')
	If !IsNumber(commitAmountPay.Value) {
		commitAmountPayBack.Value := ''
		Return
	}
	commitAmountPayBack.Value := Round(commitAmountPay.Value - AC[1], setting['Rounder']) ' ' AC[2]
}

LoadCommitLaterNames() {
    CommitLaterList.Delete()
    Loop Files 'commit\pending\later\*', 'D' {
        Name := A_LoopFileName
        CommitLaterList.Add('Icon' . 1, Name)
        names[Name] := []
        Loop Files, 'commit\pending\later\' Name '\*.json' {
            names[Name].Push(readJson(A_LoopFileFullPath))
        }
    }
}

ReturnMainList(Ctrl, Info) {
    CommitLaterList.Visible := True
    CommitLaterListZoom.Visible := False
    Ctrl.Visible := False
}

ShowNameSells(Ctrl, Row) {
    If !Row {
        Return
    }
    CommitLaterList.Visible := False
    CommitLaterListZoom.Visible := True
    Name := Ctrl.GetText(Row)
    GoBack.Text := '← ' Name
    CreateImageButton(GoBack, 0, IBBlack1*)
    GoBack.Visible := True
    CommitLaterListZoom.Delete()
    For Items in names[Name] {
        DateTime := Items['CommitTime']
        DateTime := FormatTime(DateTime, 'yyyy/MM/dd [ HH:mm:ss ]')
        Total := 0
        For Item in Items['Items'] {
            Total += Item[5] * Item[7]
        }
        Total := Round(Total, setting['Rounder']) ' ' setting['DisplayCurrency']
        R := CommitLaterListZoom.Add('Icon' . 2, '#' A_Index ' | ' DateTime, Total)
        CommitLaterListZoomCLV.Cell(R, 2, 0xFFFF0000, 0XFFFFFFFF)
    }
    CommitLaterListZoom.ModifyCol(1, 'AutoHdr')
    CommitLaterListZoom.ModifyCol(2, 'AutoHdr')
}

ShowNameResume(Ctrl, Row, Select) {
    If !Select {
        Return
    }
    TotalAmount.Value := '-'
    PaidAmount.Value := '-'
    LeftAmount.Value := '-'
    CashoutProgress.Value := 0
    Name := Ctrl.GetText(Row)
    Total := 0
    Paid := 0
    For Sell in names[Name] {
        For Item in Sell['Items'] {
            Total += Item[10]
        }
        If Sell.Has('CreditCashout') {
            For Cashout, Value in Sell['CreditCashout'] {
                Paid += Value
            }
        }
    }
    If !Total {
        Return
    }
    Left := Total - Paid
    If Left < 0 {
        Left := 0
    }
    CashoutProgress.Value := Round(Paid / Total * 100)
    TotalAmount.Value := Round(Total, setting['Rounder']) ' ' setting['DisplayCurrency']
    PaidAmount.Value := Round(Paid, setting['Rounder']) ' ' setting['DisplayCurrency']
    LeftAmount.Value := Round(Left, setting['Rounder']) ' ' setting['DisplayCurrency']
}

CashoutInfo(Ctrl, Row, Select) {
    If !Select {
        Return
    }
    CommitPaybackHistory.Delete()
    CommitPaybackValue.Value := '-'
    DetailsList.Delete()
    Name := CommitLaterList.GetText(CommitLaterList.GetNext())
    Paid := 0
    Sell := names[Name][Row]
    If Sell.Has('CreditCashout') {
        For Cashout, Value in Sell['CreditCashout'] {
            DateTime := FormatTime(Cashout, 'yyyy/MM/dd [ HH:mm:ss ]')
            Paid += Value
            Value := Round(Value, setting['Rounder']) ' ' setting['DisplayCurrency']
            R := CommitPaybackHistory.Add('Icon' . 3, DateTime, Value)
            CommitPaybackHistoryCLV.Cell(R, 2, 0xFF008000, 0XFFFFFFFF)
        }
    }
    For Item in Sell['Items']
        DetailsList.Add(, Item*)
    CommitPaybackHistory.ModifyCol(1, 'AutoHdr')
    CommitPaybackHistory.ModifyCol(2, 'AutoHdr')
    CommitPaybackValue.Value := Round(Paid, setting['Rounder']) ' ' setting['DisplayCurrency']
    Loop DetailsList.GetCount() {
        Row := A_Index
        updateRowViewCurrency(Row)
        addedRowColorize(Row)
    }
    autoResizeCols()
}

updateRowViewCurrency(Row := 0) {
    If Row {
        tmp := []
        For Each, Col in setting['Sell']['Session']['03'] {
            Value := DetailsList.GetText(Row, Each)
            Switch Col {
                Case 'Buy Value', 'Sell Value', 'Added Value', 'Price':
                    Value := Round(Value * currency['rates'][setting['DisplayCurrency']], setting['Rounder'])
                    tmp.Push(Value)
                Case 'CUR':
                    tmp.Push(setting['DisplayCurrency'])
                Default: tmp.Push(Value)
            }
        }
        DetailsList.Modify(Row, , tmp*)
    }
}
autoResizeCols() {
    Loop DetailsList.GetCount('Col') {
        If A_Index = 11 || A_Index = 1 {
            Continue
        }
        DetailsList.ModifyCol(A_Index, 'Center AutoHdr')
    }
    DetailsList.ModifyCol(1, '0')
    DetailsList.ModifyCol(11, 'Center 50')
}
addedRowColorize(Row) {
    DetailsListCLV.Row(Row, , 0xFF000000)
    DetailsListCLV.Cell(Row, 2, , 0xFF0000FF)
    DetailsListCLV.Cell(Row, 4, , 0xFF804000)
    DetailsListCLV.Cell(Row, 5, , 0xFF008040)
    DetailsListCLV.Cell(Row, 10, , 0xFFFF0000)
    DetailsListCLV.Cell(Row, 11, 0xFFFFC080)
}

ClearName(Ctrl, Info) {
    If !Row := CommitLaterList.GetNext()
        Return
    Name := CommitLaterList.GetText(Row)
    If 'Yes' != MsgBox('Are you sure to clear ' Name ' ?', setting['Name'], 0x40 + 0x4)
        Return
    If 'Yes' != MsgBox('[Confirm] Are you sure to clear ' Name ' ?', setting['Name'], 0x40 + 0x4)
        Return
    Loop Files, 'commit\pending\later\' Name '\*.json' {
        FileMove(A_LoopFileFullPath, 'commit\pending\')
    }
    LoadCommitLaterNames()
    TotalAmount.Value := '-'
    PaidAmount.Value := '-'
    LeftAmount.Value := '-'
    CashoutProgress.Value := 0
    DetailsList.Delete()
    CommitPaybackHistory.Delete()
    MsgBox(Name ' is clear!', setting['Name'], 0x40)
}