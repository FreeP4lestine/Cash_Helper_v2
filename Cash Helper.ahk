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

mainWindow := GuiEx('-DPIScale Resize', setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.OnEvent('Size', Gui_Size)
Gui_Size(GuiObj, MinMax, Width, Height) {
	GuiObj.Resize(GuiObj, MinMax, Width, Height)
}
mainWindow.SetFont('s10 Bold', 'Segoe UI')
loginThumbnail := mainWindow.AddPicEx('xm+86 ym w128 h128', 'images\Default.png', 0)
loginUsername := mainWindow.AddEditEx('xm w300 Center', , 'Username', ['s10 Bold', 'Segoe UI'], '^[A-Za-z_ 0-9]+$')
loginUsername.OnEvent('Change', (*) => updateThumbnail())
mainWindow.SetFont('s9')
Keyboard := mainWindow.AddLink("xm w300 Center", '<a>Keyboard</a>')
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
mainWindow.SetFont('s10')
loginPassword := mainWindow.AddEditEx('w300 Center cRed Password', , 'Password')
bypassKey := mainWindow.AddEditEx('w300 cGreen Password Center', , 'Bypass key')
loginRemember := mainWindow.AddCheckBox(, 'Remember')
submitLogin := mainWindow.AddButtonEx('w300', 'Login', , IBGreen2)
submitLogin.OnEvent('Click', Submit)
Submit(Ctrl, Info) {
	If !checkBypass() || !submitAccount() {
		Return
	}
	welcomeWindow.Show()
	mainWindow.Hide()
	welcomeUpdateProfile()
}
mainWindow.SetFont('s9')
createAccount := mainWindow.AddLink("w300 Center", 'No account? <a>Create!</a>')
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

createWindow := GuiEx('-DPIScale Resize', setting['Name'])
createWindow.BackColor := 'White'
createWindow.MarginX := 20
createWindow.MarginY := 20
createWindow.OnEvent('Size', Gui_Size)
createWindow.SetFont('s10', 'Segoe UI')
b64createThumbnail := createWindow.AddEditEx('w300 ReadOnly Hidden')
createThumbnail := createWindow.AddPicEx('xm+86 ym w128 h128', 'images\Default.png', 0)
createThumbnail.OnEvent('Click', (*) => pickThumbnail(createThumbnail, b64createThumbnail))
createWindow.MarginY := 5
createUsername := createWindow.AddComboBoxEx('xm w300 Center', , 'Username', , '^[A-Za-z_ 0-9]+$')
createUsername.OnEvent('Change', (*) => createUpdateThumbnail())
createWindow.SetFont('s9')
Keyboard := createWindow.AddLink("w300 Center", '<a>Keyboard</a>')
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
createWindow.SetFont('s10')
createWindow.MarginY := 20
createWindow.MarginY := 5
createPassword := createWindow.AddEditEx('w300 cRed Center', , 'Password')
createWindow.MarginY := 20
createAutorisation := createWindow.AddListView('r8 w300 Checked -Hdr', ['Autorisation'])
createAutorisation.ModifyCol(1, '275')
createAutorisation.OnEvent('ItemCheck', (*) => createAutorisation.Redraw())
ILC_COLOR32 := 0x20
ILC_ORIGINALSIZE := 0x00010000
IL := ImageList_Create(24, 24, ILC_COLOR32 | ILC_ORIGINALSIZE, 100, 100)
ImageList_Create(cx, cy, flags, cInitial, cGrow) {
	return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow)
}
createAutorisation.SetImageList(IL, 1)
SetExplorerTheme(createAutorisation.Hwnd)
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
	pToken := Gdip_Startup()
	If hB := hBitmapFromB64(MyInfo[1]) {
		spaceLogo.Value := 'HBITMAP:*' hB
	}
	Gdip_Shutdown(pToken)
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

infoCreate := createWindow.AddButton('w150', 'Info Update')
infoCreate.OnEvent('Click', (*) => updateMyInfo())
CreateImageButton(infoCreate, 0, IBBlack1*)
spaceLogo.OnEvent('Click', (*) => pickThumbnail(spaceLogo, MyInfoHandle[1]))

infoClCreate := createWindow.AddButton('xp+152 yp w150', 'Client Update')
infoClCreate.OnEvent('Click', (*) => updateMyInfo(1))
CreateImageButton(infoClCreate, 0, IBBlack1*)
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

welcomeWindow := GuiEx('-DPIScale Resize', setting['Name'])
welcomeWindow.BackColor := 'White'
welcomeWindow.MarginX := 20
welcomeWindow.MarginY := 20
welcomeWindow.OnEvent('Close', (*) => ExitApp())
welcomeWindow.OnEvent('Size', Gui_Size)
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
	ButtonFunc := welcomeWindow.AddButton('w120 h143 ' _XY, '`n`n`n`n`n`n`n' Name)
	ButtonFunc.OnEvent('Click', RunMe)
	Try {
		CreateImageButton(ButtonFunc,
			0,
			[
				['images\' Name '_normal.png'],
				['images\' Name '_hover.png'],
				['images\' Name '_click.png'],
				[
					'images\SubApp_disabled2.png', , 0x80000000
				]
			]*)
	}
	Managers[Name] := ButtonFunc
	ManagersCtrl.Push(ButtonFunc)
	; Add manager option to the create window
	IL_Add(IL, 'images\' Name ' Icon.png')
	createAutorisation.Add('Icon' . A_Index, Name)
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
SloganAbout := mainWindow.AddEditEx('xp y280 wp h210 Center -Border ReadOnly BackgroundF0F0F0 -VScroll', Text)
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
