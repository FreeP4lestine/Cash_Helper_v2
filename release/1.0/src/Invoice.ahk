#Requires AutoHotkey v2
#SingleInstance Force
#Include <setting>

If A_Args.Length != 2 || !(A_Args[1] ~= '(\-f|\-s)')
    ExitApp()

setting := readJson()
Clients := readJson(A_AppData '\Cash Helper\client.json')
MyInfo := readJson(A_AppData '\Cash Helper\myinfo.json', [])
Sumatra := A_PtrSize = 4 ? 'sumatra\SumatraPDF32.exe' : 'sumatra\SumatraPDF64.exe'
Html2Pdf := 'wkhtmltox\bin\wkhtmltopdf.exe'
Html2Img := 'wkhtmltox\bin\wkhtmltoimage.exe'
invoiceClient := Gui(, setting['Name'])
invoiceClient.OnEvent('Close', (*) => Clean())
Clean() {
    For Ext in ['*.png', '*.pdf'] {
        FileDelete('invoice\' Ext)
    }
    ExitApp()
}
invoiceClient.SetFont('s15', 'Segoe UI')
invoiceClientList := invoiceClient.AddComboBox('w300')
invoiceClientList.Delete()
For Client in Clients {
    invoiceClientList.Add([Client])
}
invoiceClient.SetFont('s12')
invoiceClientOK := invoiceClient.AddButton('xm+50 w200', 'OK')
invoiceClientOK.OnEvent('Click', (*) => InvoiceCreateOK())
invoicePath := invoiceClient.AddEdit('xm w100 Hidden')
invoiceView := invoiceClient.AddButton('xp yp w100 Disabled', 'View')
invoiceView.OnEvent('Click', (*) => ShowPDF())
ShowPDF() {
    Dummy := Gui()
    Dummy.MarginX := Dummy.MarginY := 5
    Dummy.AddPicture(, StrSplit(invoicePath.Value, ',')[2])
    Dummy.Show()
    Dummy.OnEvent('Close', (*) => Dummy.Destroy())
}
invoicePrint := invoiceClient.AddButton('xp+100 yp w100 Disabled', 'Print')
invoicePrint.OnEvent('Click', (*) => PrintPDF())
PrintPDF() {
    EC := RunWait(Sumatra ' -print-to-default ' StrSplit(invoicePath.Value, ',')[1])
    If EC {
        MsgBox('Error occured while trying to print the document!', setting['Name'], 0x40)
    }
}

invoiceSave := invoiceClient.AddButton('xp+100 yp w100 Disabled', 'Save As')
invoiceSave.OnEvent('Click', (*) => SavePDF())
SavePDF() {
    SaveTo := FileSelect('S', A_Desktop '\Document.pdf')
    If SaveTo {
        FileCopy(StrSplit(invoicePath.Value, ',')[1], SaveTo, 1)
    }
}

invoiceClient.Show()

InvoiceCreateOK() {
    If invoiceClientList.Text = '' {
        MsgBox('Please select a client name!', setting['Name'], 0x30)
        Return
    }
    invoiceView.Enabled := False
    invoicePrint.Enabled := False
    invoiceSave.Enabled := False
    ClientInfo := []
    If Clients.Has(invoiceClientList.Text) {
        ClientInfo := Clients[invoiceClientList.Text]
    } Else {
        ClientInfo.Push('')
        ClientInfo.Push(invoiceClientList.Text)
        Loop 3 {
            ClientInfo.Push('')
        }
    }
    PDFResult := InvoiceCreate(A_Args[1], MyInfo, ClientInfo)
    invoicePath.Value := PDFResult[1] ',' PDFResult[2]
    invoiceView.Enabled := True
    invoicePrint.Enabled := True
    invoiceSave.Enabled := True
}

InvoiceCreate(Argum, MyInfo, ClientInfo) {
    Switch Argum {
        Case '-f' :
            If !FileExist(A_Args[2]) {
                MsgBox('Invalid sell object source!', setting['Name'], 0x30)
                Return
            }
            Items := readJson(A_Args[2])
        Case '-s' : Items := Argum
        Default:
            MsgBox('Invalid sell object source!', setting['Name'], 0x30)
            Return
    }
    
    HTMLTemplate := FileRead('Invoice.html')
    HTMLTemplate := StrReplace(HTMLTemplate, '#LOGO#', MyInfo[1])
    Num := 0
    Loop Files, 'Invoice\*.html'
        Num++
    Num := Format("{:03}", Num)
    HTMLTemplate := StrReplace(HTMLTemplate, '#Facture Numéro#', 'Facture Nº: ' Num)
    Now := A_Now

    HTMLTemplate := StrReplace(HTMLTemplate, '#Date#', FormatTime(Now, 'yyyy/MM/dd HH:mm:ss'))
    HTMLTemplate := StrReplace(HTMLTemplate, "#Nom de l'entreprise#", MyInfo[2])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Entreprise Addresse#", MyInfo[3])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Entreprise Code Postal#", MyInfo[4])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Entreprise Ville / Pays#", MyInfo[5])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Entreprise Numéro de téléphone#", MyInfo[6])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Entreprise E-mail#", MyInfo[7])
    
    HTMLTemplate := StrReplace(HTMLTemplate, "#Nom du client#", ClientInfo[2])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Client Addresse#", ClientInfo[3])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Client Code Postal#", ClientInfo[4])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Client Ville#", ClientInfo[5])

    ItemTR := "
    (
    <tr>
        <th scope="row">#Description#</th>
        <td>#Qté#</td>
        <td>#Prix Unitaire#</td>
        <td>#TVA1#</td>
        <td>#Total HT#</td>
    </tr>
    )"
    ListItemTR := ''
    TotalHT := 0
    Total := 0
    Discount := 0
    For Item in Items['Items'] {
        ListItemTR .= ItemTR '`n'
        ListItemTR := StrReplace(ListItemTR, '#Description#', Item[3])
        ListItemTR := StrReplace(ListItemTR, '#Qté#', Round(Item[7], 2) ' ' Item[8])
        ListItemTR := StrReplace(ListItemTR, '#Prix Unitaire#', Round(Item[5], setting['Rounder']) ' ' setting['DisplayCurrency'])
        ListItemTR := StrReplace(ListItemTR, '#TVA1#', Round(Item[9] / Item[5] * 100, 2) ' %')
        ListItemTR := StrReplace(ListItemTR, '#Total HT#', (ItemTotalHT := Round(Item[5] * Item[7] / Item[6], setting['Rounder'])) ' ' setting['DisplayCurrency'])
        TotalHT += ItemTotalHT
        Total += (Item[5] + Item[9]) * Item[7] / Item[6]
        Discount += Item[12] * Item[7] / Item[6]
    }
    HTMLTemplate := StrReplace(HTMLTemplate, "#ITEMS#", ListItemTR)
    HTMLTemplate := StrReplace(HTMLTemplate, "#Total net HT#", Round(TotalHT, setting['Rounder']) ' ' setting['DisplayCurrency'])
    HTMLTemplate := StrReplace(HTMLTemplate, "#TVA2#", Round(Total - TotalHT, setting['Rounder']) ' ' setting['DisplayCurrency'])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Remise#", Round(Discount, setting['Rounder']) ' ' setting['DisplayCurrency'])
    HTMLTemplate := StrReplace(HTMLTemplate, "#Total TTC#", Round(Total - Discount, setting['Rounder']) ' ' setting['DisplayCurrency'])

    O := FileOpen('Invoice\' Num '.html', 'w')
    O.Write(HTMLTemplate)
    O.Close()

    RunWait(Html2Pdf ' --disable-smart-shrinking "Invoice\' Num '.html" "Invoice\' Num '.pdf"', , 'Hide')
    RunWait(Html2Img ' --quality 100 "Invoice\' Num '.html" "Invoice\' Num '.png"', , 'Hide')
    Return ['Invoice\' Num '.pdf', 'Invoice\' Num '.png']
}