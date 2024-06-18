#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <UseGDIP>
#Include <ImageButton>
#Include <ImagePut>
#Include <LV_Colors>
#Include <SETCUEBANNER>

UseGDIP()

MainDB				:= 'DB\MAIN.DB'
MasterUser			:= A_ComputerName
DefaultPosition		:= Map()
Welcome 			:= Gui(, 'Store Manager')
Welcome.BackColor 	:= 'White'
Welcome.MarginX 	:= 50
Welcome.MarginY 	:= 50
Welcome.SetFont('s20 Bold')
Welcome.OnEvent('Close', (*) => ExitApp())

GoBack := Welcome.AddButton('x0 y0 w50 h35 Disabled', '←')
CreateImageButton(GoBack, 8, [[0xFFFFC080, 0xFFFFA3A3], [0xFFFFA3A3, 0xFFFFC080], [0xFFFFA3A3, 0xFFFFC080], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA]]*)
GoBack.OnEvent('Click', DefaultView)

Welcome.AddText('xm y10 cGreen w300 Center', 'Welcome!')
Welcome.AddText('xp yp+30 w300 Center', 'Version: 1.0').SetFont('s7')

Login := Welcome.AddButton('w300', 'Login')
Login.GetPos(&X, &Y, &W, &H)
DefaultPosition[Login] := [X, Y, W, H]
Login.SetFont('s10')
CreateImageButton(Login, 8, [[0xFFFFC080, 0xFFFFA3A3,, 5, 0xFF000000, 1], [0xFFFFA3A3, 0xFFFFC080], [0xFFFFA3A3, 0xFFFFC080,,,, 2], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA,, 0xFFAAAAAA]]*)
Login.OnEvent('Click', LoginView)

DEMO := Welcome.AddButton('w300 Disabled', 'Quick Demo Seller')
DEMO.GetPos(&X, &Y, &W, &H)
DefaultPosition[DEMO] := [X, Y, W, H]
DEMO.SetFont('s10')
CreateImageButton(DEMO, 8, [[0xFF80FFC0, 0xFF80FFFF,, 5, 0xFF000000, 1], [0xFF80FFFF, 0xFF80FFC0], [0xFF80FFFF, 0xFF80FFC0,,,, 2], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA,, 0xFFAAAAAA]]*)

Users := Welcome.AddButton('w300', 'Manage Users')
Users.GetPos(&X, &Y, &W, &H)
DefaultPosition[Users] := [X, Y, W, H]
Users.SetFont('s10')
CreateImageButton(Users, 8, [[0xFF80FFC0, 0xFF80FFFF,, 5, 0xFF000000, 1], [0xFF80FFFF, 0xFF80FFC0], [0xFF80FFFF, 0xFF80FFC0,,,, 2], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA,, 0xFFAAAAAA]]*)
Users.OnEvent('Click', ManageView)

Welcome.SetFont('s14')

Username := Welcome.AddEdit('xm y100 w300 -E0x200 Border Center Hidden')
EM_SETCUEBANNER(Username.Hwnd, 'Username')

Password := Welcome.AddEdit('xm y140 w300 -E0x200 Border Center Password cRed Hidden')
EM_SETCUEBANNER(Password.Hwnd, 'Password')

Welcome.SetFont('s20')

Create := Welcome.AddButton('xm y100 w300 Hidden', 'Create')
Create.SetFont('s10')
CreateImageButton(Create, 8, [[0xFF80FFC0, 0xFF80FFFF,, 5, 0xFF000000, 1], [0xFF80FFFF, 0xFF80FFC0], [0xFF80FFFF, 0xFF80FFC0,,,, 2], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA,, 0xFFAAAAAA]]*)
Create.OnEvent('Click', CreateForms)

Modify := Welcome.AddButton('xm y200 w300 Hidden', 'Modify')
Modify.SetFont('s10')
CreateImageButton(Modify, 8, [[0xFF80FFC0, 0xFF80FFFF,, 5, 0xFF000000, 1], [0xFF80FFFF, 0xFF80FFC0], [0xFF80FFFF, 0xFF80FFC0,,,, 2], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA,, 0xFFAAAAAA]]*)
Modify.OnEvent('Click', ModifyForms)

Delete := Welcome.AddButton('xm y300 w300 Hidden', 'Delete')
Delete.SetFont('s10')
CreateImageButton(Delete, 8, [[0xFFFFC080, 0xFFFFA3A3,, 5, 0xFF000000, 1], [0xFFFFA3A3, 0xFFFFC080], [0xFFFFA3A3, 0xFFFFC080,,,, 2], [0xFFFFFFFF, 0xFFF0F0F0, 0xFFAAAAAA,, 0xFFAAAAAA]]*)
Delete.OnEvent('Click', DeleteForms)

Welcome.Show()

DefaultView(Ctrl, Info) {
	GoBack.Enabled := False
	Username.Visible := False
	Password.Visible := False
	Create.Visible := False, Create.Move(50, 100)
	Modify.Visible := False, Modify.Move(50, 200)
	Delete.Visible := False, Delete.Move(50, 300)
	AnimateMove(Login, [DefaultPosition[Login][1], DefaultPosition[Login][2]])
	AnimateMove(DEMO, [DefaultPosition[DEMO][1], DefaultPosition[DEMO][2]])
	AnimateMove(Users, [DefaultPosition[Users][1], DefaultPosition[Users][2]])
	Login.OnEvent('Click', LoginView)
	Login.OnEvent('Click', LoginSubmit, False)
	Users.OnEvent('Click', ManageView)
}

LoginView(Ctrl, Info) {
	GoBack.Enabled := True
	AnimateMove(DEMO, [DefaultPosition[DEMO][1] - DefaultPosition[DEMO][3] - Welcome.MarginX, DefaultPosition[DEMO][2]])
	AnimateMove(Users, [DefaultPosition[Users][1] - DefaultPosition[Users][3] - Welcome.MarginX, DefaultPosition[Users][2]])
	AnimateMove(Ctrl, [DefaultPosition[Ctrl][1], 380])
	Login.OnEvent('Click', LoginView, False)
	Login.OnEvent('Click', LoginSubmit)
	Username.Visible := True
	Password.Visible := True
}
LoginSubmit(Ctrl, Info) {
	
}

ManageView(Ctrl, Info) {
	GoBack.Enabled := True
	AnimateMove(Login, [DefaultPosition[Login][1] - DefaultPosition[Login][3] - Welcome.MarginX, DefaultPosition[Login][2]])
	AnimateMove(DEMO, [DefaultPosition[DEMO][1] - DefaultPosition[DEMO][3] - Welcome.MarginX, DefaultPosition[DEMO][2]])
	AnimateMove(Ctrl, [DefaultPosition[Ctrl][1] - DefaultPosition[Ctrl][3] - Welcome.MarginX, DefaultPosition[Ctrl][2]])
	Users.OnEvent('Click', ManageView, False)
	Create.Visible := True
	Modify.Visible := True
	Delete.Visible := True
}

CreateForms(Ctrl, Info) {
	AnimateMove(Modify, [-350, ''])
	AnimateMove(Delete, [-350, ''])
	AnimateMove(Create, ['', 380])
}

ModifyForms(Ctrl, Info) {
	AnimateMove(Delete, [-350, ''])
	AnimateMove(Create, [-350, ''])
	AnimateMove(Modify, ['', 380])
}

DeleteForms(Ctrl, Info) {
	AnimateMove(Modify, [-350, ''])
	AnimateMove(Create, [-350, ''])
	AnimateMove(Delete, ['', 380])
}

/*
Parameters

Ctrl : The gui control to move
Pos	 : The new pos to move to
T	 : 0 = Horizontally
T	 : 1 = Vertically
Step : Move speed

*/
AnimateMove(Ctrl, Pos, Step := 50) {
	Ctrl.GetPos(&X, &Y, &W, &H)
	StepX := StepY := Step
	If IsNumber(Pos[1]) && Left2Right := X > Pos[1] {
		StepX := -Step
	}
	If IsNumber(Pos[2]) && Top2Bottom := Y > Pos[2] {
		StepY := -Step
	}
	Loop {
		Ctrl.GetPos(&X, &Y, &W, &H)
		If IsNumber(Pos[1]) && DL := Abs(X - Pos[1]) {
			X := DL > Abs(StepX) ? X + StepX : Pos[1]
			Ctrl.Move(X)
		}
		If IsNumber(Pos[2]) && DL := Abs(Y - Pos[2]) {
			Y := DL > Abs(StepY) ? Y + StepY : Pos[2]
			Ctrl.Move(, Y)
		}
		OK := (IsNumber(Pos[1]) ? (Left2Right ? X <= Pos[1] : X >= Pos[1]) : 1)
		   && (IsNumber(Pos[2]) ? (Top2Bottom ? Y <= Pos[2] : Y >= Pos[2]) : 1)
		Sleep 10
	} Until OK
}