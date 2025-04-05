class Shadow {
    __New(HGui, Ctrl) {
        If Type(Ctrl) != 'Array' {
            Return
        }
        This.Ctrl := Ctrl
        This.boxFolder := 'images\box'
        This.Box := This.GetBox(This.Ctrl)
        This.HGui := HGui
        This.Left := {}
        This.Left.W := 7
        This.Left.H := 64
        This.Top := {}
        This.Top.W := 64
        This.Top.H := 4
        This.Right := {}
        This.Right.W := 7
        This.Right.H := 64
        This.Bottom := {}
        This.Bottom.W := 7
        This.Bottom.H := 64
        This.TopLeft := {}
        This.TopRight := {}
        This.BottomRight := {}
        This.BottomLeft := {}
        This.SetShadow()
    }
    GetBox(Ctrl, Margin := 15) {
        For Ct in Ctrl {
            Ct.GetPos(&_X, &_Y, &_Width, &_Height)
            If !IsSet(X) || _X < X
                X := _X
            If !IsSet(Y) || _Y < Y
                Y := _Y
            If !IsSet(Width) || (_X + _Width) > Width
                Width := _X + _Width
            If !IsSet(Height) || (_Y + _Height) > Height
                Height := _Y + _Height
        }
        Width := Width - X
        Height := Height - Y
        X -= Margin
        Y -= Margin
        Width += Margin * 2
        Height += Margin * 2
        This.Box := {}
        This.Box.X := X
        This.Box.Y := Y
        This.Box.Width := Width
        This.Box.Height := Height
        Return This.Box
    }
    SetShadow() {
        This.Left.C := This.HGui.AddPicture('x' This.Box.X - This.Left.W ' y' This.Box.Y + 16 ' h' This.Box.Height - 30, This.boxFolder '\left.png')
        This.Top.C := This.HGui.AddPicture('x' This.Box.X + 16 ' y' This.Box.Y - This.Top.H ' w' This.Box.Width - 32, This.boxFolder '\top.png')
        This.Right.C := This.HGui.AddPicture('x' This.Box.X + This.Box.Width ' y' This.Box.Y + 15 ' h' This.Box.Height - 30, This.boxFolder '\right.png')
        This.Bottom.C := This.HGui.AddPicture('x' This.Box.X + 15 ' y' This.Box.Y + This.Box.Height ' w' This.Box.Width - 29, This.boxFolder '\bottom.png')
        This.TopLeft.C := This.HGui.AddPicture('x' This.Box.X - 7 ' y' This.Box.Y - 4, This.boxFolder '\topleft.png')
        This.TopRight.C := This.HGui.AddPicture('x' This.Box.X + This.Box.Width - 16 ' y' This.Box.Y - 4 , This.boxFolder '\topright.png')
        This.BottomRight.C := This.HGui.AddPicture('x' This.Box.X + This.Box.Width - 14 ' y' This.Box.Y + This.Box.Height - 15 , This.boxFolder '\bottomright.png')
        This.BottomLeft.C := This.HGui.AddPicture('x' This.Box.X - 8 ' y' This.Box.Y + This.Box.Height - 16 , This.boxFolder '\bottomleft.png')
    }
    ResizeShadow() {
        This.Box := This.GetBox(This.Ctrl)
        This.Left.C.Move(This.Box.X - This.Left.W, This.Box.Y + 16,, This.Box.Height - 30)
        This.Top.C.Move(This.Box.X + 16, This.Box.Y - This.Top.H, This.Box.Width - 32)
        This.Right.C.Move(This.Box.X + This.Box.Width, This.Box.Y + 15,, This.Box.Height - 30)
        This.Bottom.C.Move(This.Box.X + 15, This.Box.Y + This.Box.Height, This.Box.Width - 29)
        This.TopLeft.C.Move(This.Box.X - 7, This.Box.Y - 4)
        This.TopRight.C.Move(This.Box.X + This.Box.Width - 16, This.Box.Y - 4)
        This.BottomRight.C.Move(This.Box.X + This.Box.Width - 14, This.Box.Y + This.Box.Height - 15)
        This.BottomLeft.C.Move(This.Box.X - 8, This.Box.Y + This.Box.Height - 16)
        This.RedrawShadow()
        
    }
    RedrawShadow() {
        This.Left.C.Redraw()
        This.Top.C.Redraw()
        This.Right.C.Redraw()
        This.Bottom.C.Redraw()
        This.TopLeft.C.Redraw()
        This.TopRight.C.Redraw()
        This.BottomRight.C.Redraw()
        This.BottomLeft.C.Redraw()
    }
    RedrawControls() {
        For Control in This.Ctrl {
            Control.Redraw()
        }
    }
}