#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <UseGDIP>
#Include <ImageButton>
#Include <ImagePut>
#Include <LV_Colors>
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

Welcome.AddText('xm y10 cGreen w300 Center', 'Welcome!')
Welcome.AddText('xp yp+30 w300 Center', 'Version: 1.0').SetFont('s7')

Login := Welcome.AddButton('w300', 'Login')
Login.GetPos(&X, &Y, &W, &H)
DefaultPosition[Login] := [X, Y, W, H]
Login.SetFont('s10')
CreateImageButton(Login, 8, [[0xFFFFC080, 0xFFFFA3A3,, 5, 0xFF000000, 1], [0xFFFFA3A3, 0xFFFFC080], [0xFFFFA3A3, 0xFFFFC080,,,, 2]]*)
Login.OnEvent('Click', LoginView)

DEMO := Welcome.AddButton('w300', 'Quick Demo Seller')
DEMO.GetPos(&X, &Y, &W, &H)
DefaultPosition[DEMO] := [X, Y, W, H]
DEMO.SetFont('s10')
CreateImageButton(DEMO, 8, [[0xFF80FFC0, 0xFF80FFFF,, 5, 0xFF000000, 1], [0xFF80FFFF, 0xFF80FFC0], [0xFF80FFFF, 0xFF80FFC0,,,, 2]]*)

Users := Welcome.AddButton('w300', 'Manage Users')
Users.GetPos(&X, &Y, &W, &H)
DefaultPosition[Users] := [X, Y, W, H]
Users.SetFont('s10')
CreateImageButton(Users, 8, [[0xFF80FFC0, 0xFF80FFFF,, 5, 0xFF000000, 1], [0xFF80FFFF, 0xFF80FFC0], [0xFF80FFFF, 0xFF80FFC0,,,, 2]]*)

Welcome.Show()

LoginView(Ctrl, Info) {
	AnimateMove(DEMO, DefaultPosition[DEMO][1] - DefaultPosition[DEMO][3] - Welcome.MarginX, 0)
	AnimateMove(Users, DefaultPosition[Users][1] - DefaultPosition[Users][3] - Welcome.MarginX, 0)
	AnimateMove(Ctrl, DefaultPosition[Ctrl][2] + DefaultPosition[Ctrl][4] * 4, 2, 20)
	Login.OnEvent('Click', LoginView, False)
	Login.OnEvent('Click', LoginSubmit)
}
LoginSubmit(Ctrl, Info) {
	
}

AnimateMove(Ctrl, Pos, T, Step := 50) {
	Loop {
		Ctrl.GetPos(&X, &Y, &W, &H)
		Switch T {
			Case 0 :
				Ctrl.Move(X := X - Step)
				OK := X <= Pos
			Case 1 :
				Ctrl.Move(X := X + Step)
				OK := X >= Pos
			Case 2 :
				Ctrl.Move(, Y := Y + Step)
				OK := Y >= Pos
		}
		Sleep 1
	} Until OK
}