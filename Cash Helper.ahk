#Requires AutoHotkey v2
#SingleInstance Force

#Include <Gdip_All>
#Include <Gdip>
#Include <CreateImageButton>
#Include <Setting>
#Include <Profile>
#Include <Image>

appSetting := Setting()
appImage := Image()
appProfile := Profile()
appProfile.checkBypass()
gdipImage := Gdip()

mainWindow := Gui(, appSetting.Title)
mainWindow.BackColor := 'White'
mainWindow.MarginX := 20
mainWindow.MarginY := 20
mainWindow.OnEvent('Close', (*) => ExitApp())
mainWindow.SetFont('s10')
loginThumbnail := mainWindow.AddPicture('xm+86 w128 h128', appImage.Choose['Default'])
mainWindow.AddText('xm w300 Center', 'Username / ID:')
mainWindow.MarginY := 5
loginUsername := mainWindow.AddEdit('w300')
loginUsername.OnEvent('Change', (*) => appProfile.updateThumbnail())
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
submitLogin.OnEvent('Click', (*) => appProfile.checkBypass() && appProfile.submitAccount() ? (welcomeWindow.Show(), mainWindow.Hide(), appProfile.welcomeUpdateProfile()) : '')
mainWindow.SetFont('s9')
createAccount := mainWindow.AddLink("w300 Center", 'No account? <a>Create!</a>')
createAccount.OnEvent('Click', (*) => appProfile.checkBypass(1) ? createWindow.Show() : '')
createWindow := Gui(, appSetting.createTitle)
createWindow.BackColor := 'White'
createWindow.MarginX := 20
createWindow.MarginY := 20
createWindow.SetFont('s10')
createThumbnail := createWindow.AddPicture('xm+86 w128 h128', appImage.Choose['Default'])
createThumbnail.OnEvent('Click', (*) => appProfile.pickThumbnail())
createWindow.AddText('xm w300 Center', '* Username / ID:')
createWindow.MarginY := 5
createUsername := createWindow.AddEdit('w300')
createUsername.OnEvent('Change', (*) => appProfile.createUpdateThumbnail())
createWindow.SetFont('s9')
Keyboard := createWindow.AddLink("w300 Center", '<a>Keyboard</a>')
Keyboard.OnEvent('Click', (*) => Run('osk.exe'))
createWindow.SetFont('s10')
createWindow.MarginY := 20
createWindow.AddText('w300 Center', '* Password:')
createWindow.MarginY := 5
createPassword := createWindow.AddEdit('w300 cRed Password')
createWindow.MarginY := 20
flagDelete := createWindow.AddCheckBox(, 'Flag to delete')
submitCreate := createWindow.AddButton('w300', 'Update')
submitCreate.OnEvent('Click', (*) => appProfile.updateAccount())

welcomeWindow := Gui(, appSetting.Title)
welcomeWindow.BackColor := 'White'
welcomeWindow.MarginX := 20
welcomeWindow.MarginY := 20
welcomeWindow.OnEvent('Close', (*) => ExitApp())
welcomeWindow.SetFont('s25')
welcomeTitle := welcomeWindow.AddText(, appSetting.Title)
welcomeTitle.Focus()
welcomeWindow.SetFont('s15')
welcomeMetaInfo := welcomeWindow.AddText('xp yp+35 wp cGray')
welcomeWindow.SetFont('s10')
welcomeAccountInfo := welcomeWindow.AddEdit('ym h128 -VScroll Right ReadOnly BackgroundWhite -E0x200')
welcomeAccountInfo.SetFont('Bold')
welcomeThumbnail := welcomeWindow.AddPicture('ym w128 h128')
welcomeWindow.SetFont('s10 norm')
FunctionPerRow := 5
Applications := FileOpen('setting\Application', 'r')
While !Applications.AtEOF {
	Name := Applications.ReadLine()
	If !FileExist(Name '.ahk') {
		FileAppend('', Name '.ahk')
	}
	_XY := Mod((Index := A_Index - 1), FunctionPerRow) = 0 ? 'xm' : 'xp+145 yp'
	ButtonFunc := welcomeWindow.AddButton('w120 h143 ' _XY, '`n`n`n`n`n`n`n' Name)
	ButtonFunc.OnEvent('Click', RunMe)
	CreateImageButton(ButtonFunc, 0, [['images\' Name '_normal.png'			 ]
									, ['images\' Name '_hover.png'			 ]
									, ['images\' Name '_click.png'			 ]
									, ['images\SubApp_disabled2.png',, 0x80000000]]*)
}
RunMe(Ctrl, Info) {
	Run(StrReplace(Ctrl.Text, '`n') '.ahk')
}
mainWindow.Show()
appProfile.checkRememberProfile()