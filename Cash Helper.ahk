#Requires AutoHotkey v2
#SingleInstance Force

#Include <GuiEx\GuiEx>
#Include <profile>
#Include <setting>
#Include <shared\explorertheme>
#Include <shared\cuebanner>

If !DirExist(A_AppData '\Cash Helper') {
	DirCreate(A_AppData '\Cash Helper')
}
If !checkBypass() {
	ExitApp()
}

setting := readJson()

pToken := Gdip_Startup()

mainWindow := GuiEx()
mainWindow.Default(1)

loginThumbnail := mainWindow.AddPicEx('xm+86 ym w128 h128', 'images\Default.png', 0)
loginUsername := mainWindow.AddEditEx('xm w300 Center', , 'Username', ['s10 Bold', 'Segoe UI'], '^[A-Za-z_ 0-9]+$')
loginUsername.OnEvent('Change', (*) => updateThumbnail())
Keyboard := mainWindow.AddLinkEx("xm w300 Center", '<a>Keyboard</a>', ['s9'])
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
loginPassword := mainWindow.AddEditEx('w300 Center cRed Password', , 'Password', ['s10'])
bypassKey := mainWindow.AddEditEx('w300 cGreen Password Center', , 'Bypass key')
loginRemember := mainWindow.AddCheckBoxEx(, 'Remember')
submitLogin := mainWindow.AddButtonEx('w300', 'Login',, IBGreen2)
submitLogin.OnEvent('Click', Submit)
Submit(Ctrl, Info) {
	If !checkBypass() || !submitAccount() {
		Return
	}
	welcomeWindow.Show()
	mainWindow.Hide()
	welcomeUpdateProfile()
}
createAccount := mainWindow.AddLinkEx("w300 Center", 'No account? <a>Create!</a>', ['s9'])
createAccount.OnEvent('Click', Create)
Create(Ctrl, ID, HREF) {
	If !checkBypass(True) {
		Return
	}
	createUsername.PopulateWithUsers()
	createWindow.Show()
}
ControlBorder(
	mainWindow, [
		loginThumbnail,
		loginUsername,
		Keyboard,
		loginPassword,
		bypassKey,
		loginRemember,
		submitLogin,
		createAccount
	],
	20,
	20
)

createWindow := GuiEx()
createWindow.Default()

b64createThumbnail := createWindow.AddEditEx('w300 ReadOnly Hidden',,, ['s10', 'Segoe UI'])
createThumbnail := createWindow.AddPicEx('xm+86 ym w128 h128', 'images\Default.png', 0)
createThumbnail.OnEvent('Click', (*) => pickThumbnail(createThumbnail, b64createThumbnail))
createWindow.MarginY := 5
createUsername := createWindow.AddComboBoxEx('xm w300 Center', , 'Username', , '^[A-Za-z_ 0-9]+$')
createUsername.OnEvent('Change', (*) => createUpdateThumbnail())
Keyboard := createWindow.AddLinkEx("w300 Center", '<a>Keyboard</a>', ['s9'])
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
createPassword := createWindow.AddEditEx('w300 cRed Center', , 'Password', ['s10'])
createWindow.MarginY := 20
createAutorisation := createWindow.AddListViewEx('r8 w300 Checked -Hdr', ['Autorisation'],, 1, 24, 24)
createAutorisation.ModifyCol(1, '275')
createAutorisation.OnEvent('ItemCheck', (*) => createAutorisation.Redraw())
flagDelete := createWindow.AddCheckBox(, 'Flag to delete')
submitCreate := createWindow.AddButtonEx('xm yp+75 w300', 'Account Update', , IBBlack1)
submitCreate.OnEvent('Click', (*) => updateAccount())
ControlBorder(
	createWindow, [
		b64createThumbnail,
		createThumbnail,
		createUsername,
		Keyboard,
		createPassword,
		createAutorisation,
		flagDelete,
		submitCreate
	],
	20,
	20
)

MyInfoHandle := []
MyInfo := readJson(A_AppData '\Cash Helper\myinfo.json', [])
ClientInfo := readJson(A_AppData '\Cash Helper\client.json')

PersonalText := createWindow.AddText('xm+350 ym w300 Center', 'My personal/client space')
PersonalText.SetFont('Bold')
spaceLogo := createWindow.AddPicEx('xp+86 yp+50 w128 h128', 'images\Default.png', 0)
If MyInfo.Length {
	spaceLogo.B64Value := MyInfo[1]
}
createWindow.MarginY := 5
For Property in setting['MyInfo'] {
	Form := createWindow.AddEditEx((A_Index = 1 ? 'xp-86 yp+140 Hidden ' : '') ' cBlue w300 Center', , Property)
	MyInfoHandle.Push(Form)
	If MyInfo.Length >= A_Index {
		Form.Value := MyInfo[A_Index]
	}
}

MyInfoHandle[2].OnEvent('Change', (*) => viewInfo())
createWindow.MarginY := 20

infoCreate := createWindow.AddButtonEx('w150', 'Info Update',, IBBlack1)
infoCreate.OnEvent('Click', (*) => updateMyInfo())
spaceLogo.OnEvent('Click', (*) => pickThumbnail(spaceLogo, MyInfoHandle[1]))

infoClCreate := createWindow.AddButtonEx('xp+152 yp w150', 'Client Update',, IBBlack1)
infoClCreate.OnEvent('Click', (*) => updateMyInfo(1))
ControlBorder(
	createWindow, [
		PersonalText,
		spaceLogo,
		infoCreate,
		infoClCreate,
		MyInfoHandle*
	],
	20,
	20
)

welcomeWindow := GuiEx()
welcomeWindow.Default(1)

welcomeWindow.SetFont('s25', 'Segoe UI')
welcomeTitle := welcomeWindow.AddText(, setting['Name'])
welcomeTitle.Focus()
welcomeWindow.SetFont('s15')
welcomeMetaInfo := welcomeWindow.AddText('xp yp+35 wp cGray')
welcomeWindow.SetFont('s10')
welcomeAccountInfo := welcomeWindow.AddEdit('xm+403 ym h128 Right -VScroll ReadOnly BackgroundWhite -E0x200')
welcomeAccountInfo.SetFont('s8')
welcomeThumbnail := welcomeWindow.AddPicEx('ym w128 h128',, 0)
welcomeWindow.SetFont('s10 Bold')
ControlBorder(
	welcomeWindow, [
		welcomeTitle,
		welcomeMetaInfo,
		welcomeAccountInfo,
		welcomeThumbnail
	],
	20,
	10
)
FunctionPerRow := 5
Managers := Map()
ManagersCtrl := []
For Each, Name in setting['Managers'] {
	If !FileExist(Name '.ahk') {
		FileAppend('', Name '.ahk')
	}
	_XY := Mod((Index := A_Index - 1), FunctionPerRow) = 0 ? 'xm' : 'xp+145 yp'
	IBTheme := [
		['images\' Name '_normal.png'], ['images\' Name '_hover.png'], ['images\' Name '_click.png'], ['images\SubApp_disabled2.png', , 0x80000000]
	]
	ButtonFunc := welcomeWindow.AddButtonEx('w120 h143 ' _XY, '`n`n`n`n`n`n`n' Name,, IBTheme)
	ButtonFunc.OnEvent('Click', RunMe)
	Managers[Name] := ButtonFunc
	ManagersCtrl.Push(ButtonFunc)
	; Add manager option to the create window
	createAutorisation.AddEx('images\' Name ' Icon.png',, Name)
}
manageAccount := welcomeWindow.AddLink("xm+5", '<a>Manage accounts!</a>')
manageAccount.OnEvent('Click', Create)
ControlBorder(
	welcomeWindow, [
		manageAccount,
		ManagersCtrl*
	],
	20
)

RunMe(Ctrl, Info) {
	Run(StrReplace(Ctrl.Text, '`n') '.ahk ' loginUsername.Value)
}

Slogan := mainWindow.AddPicEx('xm+450 ym', 'images\slogan100.png', 0)
SloganGif := mainWindow.AddGif('xp-100 yp+50', 'images\store.gif', 0)
Text := '
(
Cash Helper
Version: setting['Version']

A humble application made
that helps with the ordinary store tasks
gives you the ability to manage better
safly define your products database
and sell them in ease
without being afraid to make mistakes

Many thanks for my friends who have helped me with this app

Who knows, maybe it will be great one day!

Contact:

Email: chandoul.mohamed26@gmail.com
Phone: +216 26259084

If you notice any bugs, let me know :)
Your feedback is so important

Have a nice day :D
)'
Text := StrReplace(Text, "setting['Version']", setting['Version'])
SloganAbout := mainWindow.AddEditEx('xp y280 wp h180 Center -Border ReadOnly BackgroundF0F0F0 -VScroll', Text)
ControlBorder(
	mainWindow, [
		Slogan,
		SloganGif,
		SloganAbout
	],
	20,
	20
)
mainWindow.Show()

checkRememberProfile()
checkAppIntegrity()
;MsgBox('Welcome!`n`nHey there! it is nice to see you back :D', setting['Name'], 0x40 ' T3')
