#Requires AutoHotkey v2
#SingleInstance Force

#Include <profile>
#Include <setting>
#Include <shared\gdip>
#Include <shared\createimagebutton>

If !DirExist(A_AppData '\Cash Helper') {
	DirCreate(A_AppData '\Cash Helper')
}
If !checkBypass() {
	ExitApp()
}

setting := readJson()

mainWindow := Gui(, setting['Name'])
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.SetFont('s10')
loginThumbnail := mainWindow.AddPicture('xm+86 w128 h128', 'images\Default.png')
mainWindow.AddText('xm w300 Center', 'Username / ID:')
mainWindow.MarginY := 5
loginUsername := mainWindow.AddEdit('w300')
loginUsername.OnEvent('Change', (*) => updateThumbnail())
mainWindow.SetFont('s9')
Keyboard := mainWindow.AddLink("w300 Center", '<a>Keyboard</a>')
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
mainWindow.SetFont('s10')
mainWindow.MarginY := 20
mainWindow.AddText('xm yp+20 w300 Center', 'Password:')
mainWindow.MarginY := 5
loginPassword := mainWindow.AddEdit('w300 cRed Password')
mainWindow.MarginY := 20
mainWindow.AddText('w300 Center', 'Bypass key:')
mainWindow.MarginY := 5
bypassKey := mainWindow.AddEdit('w300 cGreen Password')
mainWindow.MarginY := 20
loginRemember := mainWindow.AddCheckBox(, 'Remember')
submitLogin := mainWindow.AddButton('w300', 'Login')
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
	createWindow.Show()
}
createWindow := Gui(, setting['Name'])
createWindow.BackColor := 'White'
createWindow.MarginX := 20
createWindow.MarginY := 20
createWindow.SetFont('s10')
b64createThumbnail := createWindow.AddEdit('x0 y0 w300 ReadOnly Hidden')
createThumbnail := createWindow.AddPicture('xm+86 ym w128 h128', 'images\Default.png')
createThumbnail.OnEvent('Click', (*) => pickThumbnail())
createWindow.AddText('xm w300 Center', '* Username / ID:')
createWindow.MarginY := 5
createUsername := createWindow.AddEdit('w300')
createUsername.OnEvent('Change', (*) => createUpdateThumbnail())
createWindow.SetFont('s9')
Keyboard := createWindow.AddLink("w300 Center", '<a>Keyboard</a>')
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
createWindow.SetFont('s10')
createWindow.MarginY := 20
createWindow.AddText('w300 Center', '* Password:')
createWindow.MarginY := 5
createPassword := createWindow.AddEdit('w300 cRed Password')
createWindow.MarginY := 20
createAutorisation := createWindow.AddListView('r10 w300 Checked', ['Autorisation'])
ImageListID := IL_Create(setting['Managers'].Count)
createAutorisation.SetImageList(ImageListID)
flagDelete := createWindow.AddCheckBox(, 'Flag to delete')
submitCreate := createWindow.AddButton('w300', 'Update')
submitCreate.OnEvent('Click', (*) => updateAccount())

welcomeWindow := Gui(, setting['Name'])
welcomeWindow.BackColor := 'White'
welcomeWindow.MarginX := 20
welcomeWindow.MarginY := 20
welcomeWindow.OnEvent('Close', (*) => ExitApp())
welcomeWindow.SetFont('s25')
welcomeTitle := welcomeWindow.AddText(, setting['Name'])
welcomeTitle.Focus()
welcomeWindow.SetFont('s15')
welcomeMetaInfo := welcomeWindow.AddText('xp yp+35 wp cGray')
welcomeWindow.SetFont('s10')
welcomeAccountInfo := welcomeWindow.AddEdit('ym h128 Right -VScroll ReadOnly BackgroundWhite -E0x200')
welcomeAccountInfo.SetFont('s8')
welcomeThumbnail := welcomeWindow.AddPicture('ym w128 h128')
welcomeWindow.SetFont('s10 norm')
FunctionPerRow := 5
Managers := Map()
pToken := Gdip_Startup()
For Each, Name in setting['Managers'] {
	If !FileExist(Name '.ahk') {
		FileAppend('', Name '.ahk')
	}
	_XY := Mod((Index := A_Index - 1), FunctionPerRow) = 0 ? 'xm' : 'xp+145 yp'
	ButtonFunc := welcomeWindow.AddButton('w120 h143 ' _XY, '`n`n`n`n`n`n`n' Name)
	ButtonFunc.OnEvent('Click', RunMe)
	Try {
		 CreateImageButton(ButtonFunc, 0, [['images\' Name '_normal.png']
		 								 , ['images\' Name '_hover.png']
		 								 , ['images\' Name '_click.png']
		 								 , ['images\SubApp_disabled2.png',, 0x80000000]]*)
	}
	Managers[Name] := ButtonFunc
	; Add manager option to the create window
	IL_Add(ImageListID, 'images\' Name '.png')
	createAutorisation.Add('Icon' A_Index, Name)
}
Gdip_Shutdown(pToken)
RunMe(Ctrl, Info) {
	Run(StrReplace(Ctrl.Text, '`n') '.ahk ' loginUsername.Value)
}
mainWindow.Show()
checkRememberProfile()