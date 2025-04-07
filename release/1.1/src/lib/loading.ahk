
class Loading {
    __New() {
        This.HGui := Gui('-SysMenu', 'Cash Helper')
        This.HGui.MarginX := 30
        This.HGui.MarginY := 30
        This.HGui.BackColor := 'White'
        This.HGui.SetFont('s20 Bold')
        This.Titl := This.HGui.AddText('xm w400 h40 BackgroundTrans Center', 'Please wait !')
        This.Dots := This.HGui.AddText('xp yp+40 wp hp BackgroundTrans Center')
        This.Interval := 500
        This.Timer := ObjBindMethod(This, 'Action')
        This.HGui.Show('Hide')
    }
    __Delete() {
        This.Stop()
        This.HGui.Destroy()
    }
    Start() {
        SetTimer(This.Timer, This.Interval)
        This.HGui.Show()
    }
    Stop() {
        SetTimer(This.Timer, 0)
        This.HGui.Hide()
    }
    Action() {
        Static T := 0
        Switch Mod(++T, 6) {
            Case 0: This.Dots.Text := ''
            Case 1: This.Dots.Text := '●'
            Case 2: This.Dots.Text := '●●'
            Case 3: This.Dots.Text := '●●●'
            Case 4: This.Dots.Text := '●●●●'
            Case 5: This.Dots.Text := '●●●●●'
        }
        If T = 6 
            T := 0
    }
}