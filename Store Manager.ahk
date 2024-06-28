#Requires AutoHotkey v2.0
#SingleInstance Force

#Include <UseGDIP>
#Include <ImageButton>
#Include <Gdip_All>
#Include <LV_Colors>
#Include <SetCueBanner>
#Include <AnimateMove>
#Include <DBManager>
#Include <UserDefinedFunctions>
#Include <IButtons>

Functions := ['Sell Manager', 'Review Manager', 'Stock Manager', 'Statistics Manager', 'Discounts Manager', 'Currency Manager', 'Credit Manager', 'About', 'Updates Check', 'Report Bug']

MainDB := 'DB\MAIN.DB'
UserTable := 'UserTable'
UserTableCols := 'Row, Username, Password, Thumbnail, Level, Access, Extra'
UserTableColsArr := StrSplit(UserTableCols, ', ')
CreateUserInfo := CreateArray(UserTableColsArr.Length)

DBOpenTable(MainDB)
DBCreateTable(MainDB, UserTable, UserTableCols)
DBVerifyColumns(MainDB, UserTable, UserTableCols)
DBVerifyMasterKey(MainDB, UserTable, UserTableCols)

Levels := ['Admin', 'Standart']

DP := Map()

Welcome := Gui(, 'Store Manager')
Welcome.BackColor := 'White'
Welcome.MarginX := 50
Welcome.MarginY := 50
Welcome.SetFont('s19 Bold')
Welcome.OnEvent('Close', (*) => ExitApp())

GoBack := Welcome.AddButton('x0 y0 w50 h30 Disabled', '←')
CreateImageButton(GoBack, 0, IBBlack2*)
GoBack.OnEvent('Click', DefaultView)

Welcome.SetFont('s20')
Welcome.AddText('xm y10 cGreen w300 Center', 'Welcome!')
Welcome.AddText('xp yp+30 w300 Center', 'Version: 1.0').SetFont('s7')

Login := Welcome.AddButton('w300', 'Login')
Login.GetPos(&X, &Y, &W, &H)
DP[Login] := [X, Y, W, H]
Login.SetFont('s10')
CreateImageButton(Login, 0, IBBlack2*)
Login.OnEvent('Click', LoginView)

DEMO := Welcome.AddButton('w300 Disabled', 'Quick Demo Seller')
DEMO.GetPos(&X, &Y, &W, &H)
DP[DEMO] := [X, Y, W, H]
DEMO.SetFont('s10')
CreateImageButton(DEMO, 0, IBBlack2*)

Users := Welcome.AddButton('w300', 'Manage Users')
Users.GetPos(&X, &Y, &W, &H)
DP[Users] := [X, Y, W, H]
Users.SetFont('s10')
CreateImageButton(Users, 0, IBBlack2*)
Users.OnEvent('Click', ManageView)

Thumbnail := Welcome.AddPicture('xm+86 y70 w128 h128 Hidden', 'DB\Img\userlogo.png')

ChooseThumbnail := Welcome.AddButton('xp yp+130 w98 h25 Hidden', 'Logo Select')
ChooseThumbnail.SetFont('s8')
CreateImageButton(ChooseThumbnail, 0, IBBlack*)
ChooseThumbnail.OnEvent('Click', SelectThumbnail)

RemoveThumbnail := Welcome.AddButton('xp+100 yp w28 h25 Hidden', 'X')
RemoveThumbnail.SetFont('s8')
CreateImageButton(RemoveThumbnail, 0, IBRed*)
RemoveThumbnail.OnEvent('Click', ClearThumbnail)

Welcome.SetFont('s14')

Try {
	LoadGif := Welcome.AddActiveX('xm+118 y70 w64 h64 Hidden ', 'Shell.Explorer')
	LoadGif.Value.Navigate("about:<meta charset='utf-8'><meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
	LoadGif.Value.document.body.innerHTML := "<style> * { border: 0; margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; } </style><img src='" A_ScriptDir "\DB\Img\loading.gif'>"
} Catch {
	If Type(LoadGif) = 'Gui.ActiveX' {
		LoadGif.Enabled := False
		LoadGif.Visible := False
	}
}
Username := Welcome.AddEdit('xm y240 w300 -E0x200 Border Hidden')
EM_SETCUEBANNER(Username.Hwnd, ' Username')
Username.OnEvent('Change', SavedInputsCheck)

UsernameM := Welcome.AddComboBox('xp yp wp r5 Hidden')
UsernameM.OnEvent('Change', ChargeUser)

Password := Welcome.AddEdit('xm yp+40 w300 -E0x200 Border Password cRed Hidden')
EM_SETCUEBANNER(Password.Hwnd, ' Password')

Welcome.SetFont('s10 Underline')

ALevel := Welcome.AddCheckBox('xm yp+40 Hidden', Levels[1])
ALevel.OnEvent('Click', CheckAdmin)

ULevel := Welcome.AddCheckBox('xp+218 yp Hidden Right Checked', Levels[2])
ULevel.OnEvent('Click', CheckStandart)

Welcome.SetFont('s20 norm')
Welcome.SetFont('Bold')

Create := Welcome.AddButton('xm y100 w300 Hidden', 'Create')
Create.SetFont('s10')
CreateImageButton(Create, 0, IBBlack2*)
Create.OnEvent('Click', CreateForms)

Modify := Welcome.AddButton('xm y200 w300 Hidden', 'Modify')
Modify.SetFont('s10')
CreateImageButton(Modify, 0, IBBlack2*)
Modify.OnEvent('Click', ModifyForms)

Delete := Welcome.AddButton('xm y300 w300 Hidden', 'Delete')
Delete.SetFont('s10')
CreateImageButton(Delete, 0, IBRed2*)
Delete.OnEvent('Click', DeleteForms)

Welcome.Show()

DefaultView(Ctrl, Info) {
	GoBack.Enabled := False
	Username.Visible := False
	Username.Value := ''
	UsernameM.Visible := False
	UsernameM.Delete()
	UsernameM.Value := 0
	Password.Visible := False
	Password.Value := ''
	Password.Opt('Password')
	EM_SETCUEBANNER(Username.Hwnd, ' Username')
	EM_SETCUEBANNER(Password.Hwnd, ' Password')
	Thumbnail.Visible := False
	Thumbnail.Value := 'DB\Img\userlogo.png'
	ChooseThumbnail.Visible := False
	RemoveThumbnail.Visible := False
	ALevel.Visible := False
	ULevel.Visible := False
	LoadGif.Visible := False
	Create.Visible := False, Create.Move(50, 100)
	Modify.Visible := False, Modify.Move(50, 200)
	Delete.Visible := False, Delete.Move(50, 300)
	AnimateMove(Login, [DP[Login][1], DP[Login][2]])
	AnimateMove(DEMO, [DP[DEMO][1], DP[DEMO][2]])
	AnimateMove(Users, [DP[Users][1], DP[Users][2]])
	Users.OnEvent('Click', ManageView)
	Login.OnEvent('Click', LoginView)
	Login.OnEvent('Click', LoginSubmit, False)
	Create.OnEvent('Click', CreateForms)
	Create.OnEvent('Click', CreateFormsSubmit, False)
	Modify.OnEvent('Click', ModifyForms)
	Modify.OnEvent('Click', ModifyFormsSubmit, False)
	Delete.OnEvent('Click', DeleteForms)
	Delete.OnEvent('Click', DeleteFormsSubmit, False)
}

LoginView(Ctrl, Info) {
	GoBack.Enabled := True
	AnimateMove(DEMO, [-350, DP[DEMO][2]])
	AnimateMove(Users, [-350, DP[Users][2]])
	AnimateMove(Ctrl, [DP[Ctrl][1], 360])
	Login.OnEvent('Click', LoginView, False)
	Login.OnEvent('Click', LoginSubmit)
	Username.Visible := True
	Password.Visible := True
	LoadGif.Visible := True
	LoadGif.Redraw()
	Username.Focus()
}
LoginSubmit(Ctrl, Info) {
	If !FileExist('DB\MAIN.db') || (Username.Value Password.Value = '') {
		Msgbox('Unable to login!`n`n1 - Unable to find the user setting`n2 - Inputs are empty', 'Login failure!', 48)
		Username.Focus()
		Return
	}
	Table := DBReadTable(MainDB, UserTable)
	Bypass := False
	If Table.Rows[1][2] = 'Masterkey' && (Username.Value == Table.Rows[1][3] || Password.Value == Table.Rows[1][3]) {
		Bypass := True
	}
	If !Bypass {
		NormalLogin := [False, False]
		If Username.Value = '' {
			Msgbox('Unable to login!`n`nNo username input', 'Login failure!', 48)
			Return
		}
		If Password.Value = '' {
			Msgbox('Unable to login!`n`nNo password input', 'Login failure!', 48)
			Return
		}
		For Row, Col in Table.Rows {
			If Row = 1 {
				Continue
			}
			If Col[2] = Username.Value {
				NormalLogin[1] := True
			}
			If NormalLogin[1] && Col[3] == Password.Value {
				NormalLogin[2] := True
				Break
			}
		}
		If !NormalLogin[1] {
			Msgbox('Unable to login!`n`nUsername not found', 'Login failure!', 48)
			Return
		}
		If !NormalLogin[2] {
			Msgbox('Unable to login!`n`nPassword incorrect', 'Login failure!', 48)
			Return
		}
	}
	Welcome.Destroy()
	Board := Gui(, 'Store Manager')
	Board.BackColor := 'White'
	Board.MarginX := 20
	Board.MarginY := 20
	Board.AddText('xm y10 cGreen w400 h50', 'Store Manager').SetFont('s25 Bold')
	Board.AddText('xp+10 yp+40 w100', 'Version: 1.0').SetFont('s7 Bold')
	Board.SetFont('s10', 'Calibri')
	Board.OnEvent('Close', (*) => ExitApp())
	FunctionPerRow := 4
	pToken := Gdip_Startup()
	While Functions.Length {
		Loop (Functions.Length > FunctionPerRow ? FunctionPerRow : Functions.Length) {
			SubAppName := Functions.RemoveAt(1)
			If !FileExist(SubAppName '.ahk') {
				FileAppend('#Requires AutoHotkey v2.0`n#SingleInstance Force', SubAppName '.ahk')
			}
			SubApp := Board.AddButton('w120 h143 ' ((A_Index = 1) ? 'xm' : 'yp'), '`n`n`n`n`n`n`n' SubAppName)
			IBFireFox[1] := [IBBitmapCombine('SubApp_normal.png', SubAppName)]
			IBFireFox[2] := [IBBitmapCombine('SubApp_hover.png', SubAppName)]
			IBFireFox[3] := [IBBitmapCombine('SubApp_click.png', SubAppName)]
			IBFireFox[4] := [IBBitmapCombine('SubApp_disabled.png', SubAppName)]
			CreateImageButton(SubApp, 0, IBFireFox*)
			SubApp.OnEvent('Click', LaunchSubApp)
		}
	}
	Gdip_Shutdown(pToken)
	Board.Show()
}

ManageView(Ctrl, Info) {
	Table := DBReadTable(MainDB, UserTable)
	If !MasterKeyCheck(Table.Rows[1][3]) {
		Return
	}
	GoBack.Enabled := True
	AnimateMove(Login, [-350, DP[Login][2]])
	AnimateMove(DEMO, [-350, DP[DEMO][2]])
	AnimateMove(Ctrl, [-350, DP[Ctrl][2]])
	Users.OnEvent('Click', ManageView, False)
	Create.Visible := True
	Modify.Visible := True
	Delete.Visible := True
}

CreateForms(Ctrl, Info) {
	AnimateMove(Modify, [-350, ''])
	AnimateMove(Delete, [-350, ''])
	AnimateMove(Create, ['', 360])
	Thumbnail.Visible := True
	ChooseThumbnail.Visible := True
	RemoveThumbnail.Visible := True
	Username.Visible := True
	Password.Visible := True
	Password.Opt('-Password')
	EM_SETCUEBANNER(Username.Hwnd, ' New Username')
	EM_SETCUEBANNER(Password.Hwnd, ' New Password')
	ALevel.Visible := True
	ULevel.Visible := True
	Ctrl.OnEvent('Click', CreateForms, False)
	Ctrl.OnEvent('Click', CreateFormsSubmit)
	Username.Focus()
}

CreateFormsSubmit(Ctrl, Info) {
	Global CreateUserInfo
	Table := DBReadTable(MainDB, UserTable)
	CreateUserInfo[1] := Table.RowCount + 1
	If Username.Value = '' {
		Msgbox('Input username required!', 'Unable to create', 0x30)
		Username.Focus()
		Return
	}
	If Username.Value = Table.Rows[1][3] || 'MasterKey' = Username.Value {
		Msgbox(Username.Value ' is reserved!', 'Unable to create', 0x30)
		Username.Focus()
		Return
	}
	CreateUserInfo[2] := Username.Value
	If Password.Value = '' {
		Msgbox('Input password required!', 'Unable to create', 0x30)
		Password.Focus()
		Return
	}
	If Password.Value == Table.Rows[1][3] {
		Msgbox(Password.Value ' is reserved!', 'Unable to create', 0x30)
		Password.Focus()
		Return
	}
	CreateUserInfo[3] := Password.Value
	If !ALevel.Value && !ULevel.Value {
		Msgbox('Select level required!', 'Unable to create', 0x30)
		ALevel.Focus()
		Return
	}
	If ALevel.Value {
		CreateUserInfo[5] := ALevel.Text
	}
	If ULevel.Value {
		CreateUserInfo[5] := ULevel.Text
	}
	For Row, Col in Table.Rows {
		If Col[2] = Username.Value {
			Msgbox(Username.Value ' is already created!', 'Unable to create', 0x30)
			Username.Focus()
			Return
		}
	}
	NewValues := ArrayMerge(UserTableColsArr, CreateUserInfo)
	DBInsertRowTable(MainDB, UserTable)
	DBUpdateRowTable(MainDB, UserTable, NewValues, CreateUserInfo[1])
	CreateUserInfo := ClearArray(CreateUserInfo)
	If 'Yes' = Msgbox('User successfully created!`n`nReturn to login now?', 'Done', 0x40 + 0x4)
		DefaultView(Ctrl, Info)
}

ClearThumbnail(Ctrl, Info) {
	Thumbnail.Move(,, 128, 128)
	Thumbnail.Value := 'DB\Img\userlogo.png'
	CreateUserInfo[4] := ''
}

SelectThumbnail(Ctrl, Info) {
	B64Image := ''
	CreateUserInfo[4] := ''
	Image := FileSelect(,, "Select an image:", "Images (*.bmp; *.dib; *.rle; *.jpg; *.jpeg; *.jpe; *.jfif; *.gif; *.emf; *.wmf; *.tif; *.tiff; *.png; *.ico; *.heic; *.hif; *.webp; *avif; *avifs)")
	If !Image {
		Return
	}
	pToken := Gdip_Startup()
	pBitmap1 := Gdip_CreateBitmapFromFile(Image)
	ImageWidth := Gdip_GetImageWidth(pBitmap1)
	ImageHeight := Gdip_GetImageHeight(pBitmap1)
	If ImageWidth > ImageHeight {
		ScaleFactor := ImageWidth / 128
		ImageWidth /= ScaleFactor
		ImageHeight /= ScaleFactor
		YPastePos := (128 - ImageHeight) / 2
	} Else {
		ScaleFactor := ImageHeight / 128
		ImageWidth /= ScaleFactor
		ImageHeight /= ScaleFactor
		XPastePos := (128 - ImageWidth) / 2
	}
	pBitmap2 := Gdip_CreateBitmap(128, 128)
	pGraphics := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(pGraphics, pBitmap1, IsSet(XPastePos) ? XPastePos : 0, IsSet(YPastePos) ? YPastePos : 0, ImageWidth, ImageHeight)
	B64Image := Gdip_EncodeBitmapTo64string(pBitmap2)
	Thumbnail.Value := 'hbitmap:* ' Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(B64Image))
	CreateUserInfo[4] := B64Image
	Gdip_DeleteGraphics(pGraphics)
	Gdip_DisposeImage(pBitmap1)
	Gdip_DisposeImage(pBitmap2)
	Gdip_Shutdown(pToken)
}

CheckAdmin(Ctrl, Info) {
	ULevel.Value := 0
}

CheckStandart(Ctrl, Info) {
	ALevel.Value := 0
}

ModifyForms(Ctrl, Info) {
	Table := DBReadTable(MainDB, UserTable)
	AnimateMove(Delete, [-350, ''])
	AnimateMove(Create, [-350, ''])
	AnimateMove(Modify, ['', 360])
	Thumbnail.Visible := True
	ChooseThumbnail.Visible := True
	RemoveThumbnail.Visible := True
	UsernameM.Visible := True
	Password.Visible := True
	Password.Opt('-Password')
	ALevel.Visible := True
	ULevel.Visible := True
	Ctrl.OnEvent('Click', ModifyForms, False)
	Ctrl.OnEvent('Click', ModifyFormsSubmit)
	UsernameM.Focus()
	UpdateComboBox(UsernameM, Table.Rows)
}
ChargeUser(Ctrl, Info) {
	Thumbnail.Value := 'DB\Img\userlogo.png'
	Password.Value := ''
	ALevel.Value := 1
	ULevel.Value := 0
	Table := DBReadTable(MainDB, UserTable)
	If !UsernameM.Value || Table.RowCount < UsernameM.Value || Table.Rows[UsernameM.Value][2] != UsernameM.Text {
		Return
	}
	If Table.Rows[UsernameM.Value][4] != '' {
		Thumbnail.Value := 'hbitmap:* ' Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(Table.Rows[UsernameM.Value][4]))
		CreateUserInfo[4] := Table.Rows[UsernameM.Value][4]
	} Else {
		Thumbnail.Value := 'DB\Img\userlogo.png'
	}
	Password.Value := Table.Rows[UsernameM.Value][3]
	If Table.Rows[UsernameM.Value][5] = ALevel.Text {
		ALevel.Value := 1
		ULevel.Value := 0
	}
	If Table.Rows[UsernameM.Value][5] = ULevel.Text {
		ALevel.Value := 0
		ULevel.Value := 1
	}
}
ModifyFormsSubmit(Ctrl, Info) {
	Global CreateUserInfo
	Table := DBReadTable(MainDB, UserTable)
	If UsernameM.Text = '' {
		Msgbox('Input username required!', 'Unable to modify', 0x30)
		UsernameM.Focus()
		Return
	}
	UserExists := False
	For Row, Col in Table.Rows {
		If Col[2] = UsernameM.Text {
			CreateUserInfo[1] := Row
			UserExists := True
		}
	}
	If !UserExists {
		Msgbox(UsernameM.Text ' is not registered!', 'Unable to modify', 0x30)
		UsernameM.Focus()
		Return
	}
	If UsernameM.Text = Table.Rows[1][3] {
		Msgbox(UsernameM.Text ' is reserved!', 'Unable to modify', 0x30)
		UsernameM.Focus()
		Return
	}
	CreateUserInfo[2] := UsernameM.Text
	If Password.Value = '' {
		Msgbox('Input password required!', 'Unable to modify', 0x30)
		Password.Focus()
		Return
	}
	If 'MasterKey' != UsernameM.Text && Password.Value == Table.Rows[1][3] {
		Msgbox(Password.Value ' is reserved!', 'Unable to modify', 0x30)
		Password.Focus()
		Return
	}
	CreateUserInfo[3] := Password.Value
	If !ALevel.Value && !ULevel.Value {
		Msgbox('Select level required!', 'Unable to modify', 0x30)
		ALevel.Focus()
		Return
	}
	If ALevel.Value {
		CreateUserInfo[5] := ALevel.Text
	}
	If ULevel.Value {
		CreateUserInfo[5] := ULevel.Text
	}
	NewValues := ArrayMerge(UserTableColsArr, CreateUserInfo)
	DBUpdateRowTable(MainDB, UserTable, NewValues, CreateUserInfo[1])
	CreateUserInfo := ClearArray(CreateUserInfo)
	If 'Yes' = Msgbox('User successfully modified!`n`nReturn to login now?', 'Done', 0x40 + 0x4)
		DefaultView(Ctrl, Info)
}
DeleteForms(Ctrl, Info) {
	Table := DBReadTable(MainDB, UserTable)
	AnimateMove(Modify, [-350, ''])
	AnimateMove(Create, [-350, ''])
	AnimateMove(Delete, ['', 360])
	UsernameM.Visible := True
	Thumbnail.Visible := True
	Ctrl.OnEvent('Click', DeleteForms, False)
	Ctrl.OnEvent('Click', DeleteFormsSubmit)
	UsernameM.Focus()
	UpdateComboBox(UsernameM, Table.Rows)
}
DeleteFormsSubmit(Ctrl, Info) {
	; Double confirmation
	Loop 2 {
		If 'Yes' != Msgbox('Are you sure to delete < ' UsernameM.Text ' > ?' (A_Index = 2 ? '`n[Double Confirmation]' : ''), 'Confirm!', 0x40 + 0x4) {
			Return
		}
	}
	Row := UsernameM.Value
	DBDeleteRowTable(MainDB, UserTable, Row)
	If UsernameM.Text = 'MasterKey' {
		Reload
		Return
	}
	Table := DBReadTable(MainDB, UserTable)
	UpdateComboBox(UsernameM, Table.Rows)
	If 'Yes' = Msgbox('User successfully deleted!`n`nReturn to login now?', 'Done', 0x40 + 0x4)
		DefaultView(Ctrl, Info)
}
SavedInputsCheck(Ctrl, Info) {
	LoadGif.Visible := True
	Thumbnail.Visible := False
	Thumbnail.Value := 'DB\Img\userlogo.png'
	Table := DBReadTable(MainDB, UserTable)
	If !Username.Value || !Table.RowCount {
		Return
	}
	UserExist := False
	For Row, Col in Table.Rows {
		If Col[2] = Username.Value {
			UserExist := Row
			Break
		}
	}
	If !UserExist {
		Return
	}
	LoadGif.Visible := False
	Thumbnail.Visible := True
	If Table.Rows[UserExist][4] != '' {
		Thumbnail.Value := 'hbitmap:* ' Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(Table.Rows[UserExist][4]))
		CreateUserInfo[4] := Table.Rows[UserExist][4]
	}
}

LaunchSubApp(Ctrl, Info) {
	SubAppLoc := StrReplace(Ctrl.Text, '`n') '.ahk'
	If FileExist(SubAppLoc) {
		Run(SubAppLoc ' ' A_ScriptDir)
	}
}