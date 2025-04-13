#Requires AutoHotkey v2
#SingleInstance Force

#Include <GuiEx\GuiEx>

#Include <inc\ui-base>
#Include <review>
#Include <setting>
#Include <GuiEx\GuiEx>

If A_Args.Length != 1 || A_Args[1] = '' {
	ExitApp()
}
usersetting := readJson(A_AppData '\Cash Helper\users.json')
If !usersetting.Has('Registered') || !usersetting['Registered'].Has(A_Args[1]) {
	ExitApp()
}
username := A_Args[1]

setting := readJson()
currency := readJson('setting\currency.json')
review := Map()
review['Pending'] := []
review['OverAll'] := [0, 0]
review['OverAllItems'] := [0, 0]
review['OverAllUser'] := [0, 0]
review['OverAllDay'] := [0, 0]
review['Pointer'] := []

mainWindow := GuiEx()
mainWindow.Default()

Logo := mainWindow.AddPicEx('xm+20 ym+20', 'images\Review Manager.png', 1)
Title := mainWindow.AddTextEx('ym+20 w990', 'Review Manager', ['s25'])
mainWindow.AddBorder([Logo, Title])

IL := IL_Create(,, True)
IL_Add(IL, 'images\pending.png')
IL_Add(IL, 'images\archived.png')
IL_Add(IL, 'images\user.png')
IL_Add(IL, 'images\users.png')
IL_Add(IL, 'images\day.png')

Users := mainWindow.AddTextEx('xm+20 ym+140 w180 Center', 'Users:', ['Bold s10'])
usersList := mainWindow.AddListViewEx('wp cBlue r6', ['Users'], ['norm'], 1, 32, 32)
mainWindow.AddBorder([Users, usersList])

usersList.OnEvent('Click', displayUserSellsFunc)
displayUserSellsFunc(Ctrl, Info) {
    loadPendingSells(1)
}
Days := mainWindow.AddTextEx('xm+20 ym+375 w180 Center', 'Days:', ['Bold s10'])
daysList := mainWindow.AddListViewEx('xm+20 wp r9', ['Days'], ['norm'], 1, 32, 32)
daysList.OnEvent('Click', displayDateSellsFunc)
displayDateSellsFunc(Ctrl, Info) {
    loadPendingSells(2)
}
mainWindow.AddBorder([Days, daysList])

openTime := mainWindow.AddEditEx('xm+555 ym+140 w150 Left ReadOnly -Border',,, ['s10 Bold'])
commitTime := mainWindow.AddEditEx('xm+942 ym+140 w150 Right ReadOnly -Border')
mainWindow.AddBorder([openTime, commitTime])

Invoice := mainWindow.AddButtonEx('xm+250 ym+140 w125', 'Invoice',, IBBlack1, 'images\buttons\invoice.png')
Invoice.OnEvent('Click', (*) => (R := nonSubmitted.GetNext()) && Run('Invoice.ahk -f ' review['Pending'][review['Pointer'][R]].File))

CancelSell := mainWindow.AddButtonEx('xp+125 yp w125 Disabled', 'Cancel',, IBBlack1, 'images\buttons\cancel.png')
CancelSell.OnEvent('Click', (*) => CancelSellNow())
nonSubmittedTxt := mainWindow.AddTextEx('xp-125 yp+40 w250 cred Center', 'Non reviewed sells')
nonSubmittedPB := mainWindow.AddProgress('wp h18 Hidden -Smooth')
nonSubmitted := mainWindow.AddListViewEx('wp Multi r15 -Hdr', ['Not Submitted'], ['norm'], 1, 32, 32)
details := mainWindow.AddListViewEx('xm+555 ym+210 w530 h220 NoSortHdr -E0x200',, ['s12'])
For Each, Col in setting['Sell']['Session']['03'] {
    details.InsertCol(Each, , Col)
}
nonSubmitted.OnEvent('Click', displayDetailsFunc)
displayDetailsFunc(Ctrl, Info) {
    displayDetails()
}

overAllItem := mainWindow.AddTextEx('xm+555 ym+450', 'Selection summary: ( 0 )', ['s10'])
itemsBuyValue := mainWindow.AddEditEx('w176 Center ReadOnly cRed -Border', 0,, ['norm s15'])
itemsSellValue := mainWindow.AddEditEx('xp+180 yp w176 Center ReadOnly cGreen -Border', 0)
itemsProfitValue := mainWindow.AddEditEx('xp+180 yp w176 Center ReadOnly cGreen -Border', 0)
overAllTotal := mainWindow.AddTextEx('xm+555 ym+550', 'Overall Summary:', ['s10 Bold'])
totalBuyValue := mainWindow.AddEditEx('w176 Center ReadOnly cRed -Border', 0,, ['s15'])
totalSellValue := mainWindow.AddEditEx('xp+180 yp w176 Center ReadOnly cGreen -Border', 0)
totalProfitValue := mainWindow.AddEditEx('xp+180 yp w176 Center ReadOnly cGreen -Border', 0)
mainWindow.AddBorder([details, overAllItem, itemsBuyValue, itemsSellValue, itemsProfitValue, overAllTotal, totalBuyValue, totalSellValue, totalProfitValue])
submit := mainWindow.AddButtonEx('xm+275 ym+595 w200', 'Clear!', ['s12 Bold'], IBBlack1, 'images\buttons\commit.png')
submit.OnEvent('Click', clearSellsFunc)
clearSellsFunc(Ctrl, Info) {
    clearSells()
}
mainWindow.AddBorder([nonSubmitted, nonSubmittedPB, nonSubmittedTxt, submit, Invoice])
mainWindow.Show()
autoResizeCols()
loadAll()