/*
Parameters
For AHK v2
Ctrl : The gui control to move
Pos	 : The new pos to move to [X, Y]
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