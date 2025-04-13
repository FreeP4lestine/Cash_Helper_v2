class ControlBorder {
    __New(HGui, Ctrl, AX := 0, AY := 0) {
        If Type(Ctrl) != 'Array' {
            Return
        }
        This.AX := AX
        This.AY := AY
        This.Ctrl := Ctrl
        This.HGui := HGui
        This.Box := This.GetBox()
        This.Left := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAAAcAAABACAYAAADWD20HAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA2SURBVEhL7cmxEQAgCANA99+PLo2U0siJtHEBR8i3P243TxV3JlcEpzvNjACoVCqVSqXyk+ADDu6AG930WYwAAAAASUVORK5CYII=',
            W: 7,
            H: 64
        }
        This.Top := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAAEAAAAAECAYAAAA+oDmkAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAnSURBVDhP5cPBCQAwDAMx779sHajzvQxigZRdmusnNJdnaK5n09scWubXLh7OGS8AAAAASUVORK5CYII=',
            W: 64,
            H: 4
        }
        This.Right := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAAAcAAABACAYAAADWD20HAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA2SURBVEhL7cmxDQAgCARA999OBpBWKkjk6zf2jvDdJTd2BKcZlzufs4qnmwCoVCqVSqXyk+AFFeqCG1MA/t8AAAAASUVORK5CYII=',
            W: 7,
            H: 64
        }
        This.Bottom := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAAEAAAAALCAYAAADP9otxAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABPSURBVEhL5cOxDcAgDATA338R92GBMEEYILShcpAgdvsZ5E86uDuVw8yoHEcpVI6zVirH1RqV4+6dyvGMQeV456RyrL2pHF8ElSMyqTv5A0avykhuxo2dAAAAAElFTkSuQmCC',
            W: 7,
            H: 64
        }
        This.TopLeft := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAABcAAAAUCAYAAABmvqYOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAFASURBVEhLrZSJcoJAEET9/1+MMWAQ5L7lZtyeYpFDDEe6qqtQtp5Nz+CJ/knp4zHzIfgUlqTpyJvh72BxkrCjOGaHUcTeBJ8CJSgIw5H9IGCvgg+TSqiEBML4gVTcy/Ocqqqiuq6pbdu/4UtQOBHfAbakj/AhGOkA9Hyfr8uy7E4taxEuwTKt63nkCePx8dhr9BbeJx6AHdflz+hyrWbwYRUAA2o7DvfbNE13ap1GcIBhCUZi07LIFz1vBUMzOFJjYBgcwEidF0V3Ypt6+LAObIVl23Q3TR7oXs3gSI06dMNgeLEzNcTwYdecWtSh3W48zC3bMVUPn6b+1TR+tY+oh8sNwQABVq9X3usjOk0rwYYoqkqqcJZl3bF9YjgqwVZg/Yz7nb4vF1IUZdX/xye94LJvXaev85l+BHzPi/MS0RMdnw+EHc5QtgAAAABJRU5ErkJggg=='
        }
        This.TopRight := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAABcAAAATCAYAAAB7u5a2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAEoSURBVDhPrZTrjoIwEEb7/o+o0ayJKLDcL+XO2G+kLulqKMKXTPrvnOl0UlFKSWbtFVGUJZm1l0ykWUaoDJXnXHlRcJmitRFxkhAqQaXpq1g4icwb2UaM40jDMFDXddQ0DcmqolxBIWDpJDIlNhHT+S8QVkoEeBTHLJpLbAQf4TqQlAoGAQoyjMtGsAhH9C3QfRhF1gIruE5d1xQpeBCGLFoSrILj8XEDdP8bBIuCVXAEAryB5/sswIiwXe8Eq+EI1haP63oej0hv0S5wBOPxVfcQQPRuPF/DsUGxgjqO8zeeqXst+BqOYNZXBf/U/Sa4VBDndmMBz37WPbIJjr8IXf9cLrw9WM3597AJ3rYt3V2XTuczn+ZoNsH7vufOD8cjj0ev5RMu6QEoIrWaRsZhaQAAAABJRU5ErkJggg=='
        }
        This.BottomRight := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAABUAAAAZCAYAAADe1WXtAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAJaSURBVEhLrZTpTiJRFIT7/R+FMePgIBJBGIdNFgfZ932RHWQxSNCaUzfeTEuUYI8n6X/0R9WpOm3Awry8vOC+30cqlUKtXkd/MMBsPsdytcJ6vYYl6Ha7RavdRiqdRr3R+BroZrNBo9lEOpNR0MFw+A/6+GgN+igv1mo1BSX8S6Cz2QzZXA7ZbBbNVgvD0QjzhwfrUIbUl5D+JBLI5fNqt/8NfXp6UtZj8TgKxSLanQ5G4zEeFgusJKRPQ5+fnzGQpG9vb5XScqWCbq+HyXRqHbqQF9nNYCik6qQ7OpUdL5bLz0G5R3azKUkHg0FEYzHkCwW0XkMyJ885Cso9NqSPBAYCAdwlk6i8Wh9PJm+scw5CqZDAjoQREKDP50NMVDJ1qlb93LPO+RBK4FJ+XJSEf11fw+PxIHxzo3ZZlfTNKrX1D6F6f1NJNCMXc+l2q4fh0HapXFY10rvcV8kxCNntdsrmSv5xIv9OdVdXV/jpcMAtCrnLhFSIveQF6cTNu3wD5XUwBKpiCI7zc/yw2+G8uIDX60UoHEbi7k4Beef85Ole7tvWY9hsNnw7OcH301PYz84UjOp++/2IRKNISi+LpZJSSCD3qE9y37Yew+l0wuVywS1780q6flF7E4kou/xoVKpVdd+0rIHmPb4LpeWQhEBQXM6PYRDGQGiXKbM6ZsuHgByDFcnIJ4zdo00qI6zT7Sp1/Fgw5WOBHKMu90sId0ZQ7/5eKaNVJvye3UNAjkE1hLB3BNEmlWnYserMYxCgIbSoQfuwY4EcQwM0RD9WYHoM88vmx/oAfwE5qtEs/0UDvAAAAABJRU5ErkJggg=='
        }
        This.BottomLeft := {
            B: 'iVBORw0KGgoAAAANSUhEUgAAABcAAAAcCAYAAACK7SRjAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAK3SURBVEhLpZUHbyIxEIXz//9NLkeCIPTeIYQOIfTei1KAuXkWXnlhSVjuSY4Uyfs9z5uxudtst7TebGixXNJ0OqX+YEDvjQblCwWKxeN0OBzoVunhs5mANxheKBYF/Ovr67jVvIzhzaaAxxMJWq3Xx63mpcGXq5WAD4ZDAS+WSpRg+GQyOW41L0N4s9US8GQySe12+7jVvM7gw9GIWgwsVyqUSqepVC7f3FQNjmxn87mAtzsdqlSrlHl5oQSf/uPj47jdnHTw+WJBo/GYOt0u1d7eKPv6SuFIhLr8/y0ScCwJn/Cs9/p9qr+/a7OOeLa8x6zu8EfC5TiqE5NMpcgfCFCZs9/v9+Kja6XBZVPV3Ku1GmWzWRGN3++nIZvudjvx4TXSwWU0Y55tRINnAJcJTfUxPBKNUrfXu3p6NLg0UKPBSFZ5atBYgN0eDwWDQRpxZZ+fnwLwkwQcUqM5PT2yT3NTQ6EQOZ1OYVDjyH4bUR0cS20sssdYvtXrYnLQ3ACDHWzgcDgon8+LPlx63DQ4JE8vDTCWMh6cNMcw5A8Dp8tFT1YrebxeKnJf8Ezgyd7w99/f36IvZ3CjePBS4r3B9MAAFYTCYfJwD+x2O1keH8lms4nYMpmMMMNhdHBIjUeOpjDg/FtsgJuLCUozJBqLUYDvgNvtJvvzM1m5kr8WC/15eKD7+/tzOHQaj2bAFSCiOvcAD9prLkcprgImQT611+cjFxuhJzC7CL9kgB6gybjBiAmTBBNUgn7ACJcOERnCoVMD2QM0GY8bqsAthgmiwhMNI/QE9+KFb/ZFOGRkIKuACUYVJqgEccEIDx7MUNWPcEgaGFUhTVAJ4oIRLh6eCBj+Cpc6NVArkUa4ePjNRW9geDUcOq1CrUQaSTMsU3Ap1QQ3UjVS101wKZ2JYibXf8FPpTfa0j9EyZyWVfvkVwAAAABJRU5ErkJggg=='
        }
        This.SetControlBorder()
    }
    GetBox(Margin := 15) {
        If This.Ctrl.Length {
            For Ct in This.Ctrl {
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
        } Else For Ct in This.HGui {
            This.Ctrl.Push(Ct)
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
        This.Box := {
            X: X,
            Y: Y,
            Width: Width,
            Height: Height
        }
        Return This.Box
    }
    SetControlBorder() {
        This.Left.C := This.HGui.AddPicEx(
            'x' This.Box.X - This.Left.W + This.AX ' y' This.Box.Y + 16 + This.AY ' h' This.Box.Height - 30,
            'HBITMAP:*' hBitmapFromB64(This.Left.B)
        )
        This.Top.C := This.HGui.AddPicEx(
            'x' This.Box.X + 16 + This.AX ' y' This.Box.Y - This.Top.H + This.AY ' w' This.Box.Width - 32,
            'HBITMAP:*' hBitmapFromB64(This.Top.B)
        )
        This.Right.C := This.HGui.AddPicEx(
            'x' This.Box.X + This.Box.Width + This.AX ' y' This.Box.Y + 15 + This.AY ' h' This.Box.Height - 30,
            'HBITMAP:*' hBitmapFromB64(This.Right.B)
        )
        This.Bottom.C := This.HGui.AddPicEx(
            'x' This.Box.X + 15 + This.AX ' y' This.Box.Y + This.Box.Height + This.AY ' w' This.Box.Width - 29,
            'HBITMAP:*' hBitmapFromB64(This.Bottom.B)
        )
        This.TopLeft.C := This.HGui.AddPicEx(
            'x' This.Box.X - 7 + This.AX ' y' This.Box.Y - 4 + This.AY,
            'HBITMAP:*' hBitmapFromB64(This.TopLeft.B)
        )
        This.TopRight.C := This.HGui.AddPicEx(
            'x' This.Box.X + This.Box.Width - 16 + This.AX ' y' This.Box.Y - 4 + This.AY,
            'HBITMAP:*' hBitmapFromB64(This.TopRight.B)
        )
        This.BottomRight.C := This.HGui.AddPicEx(
            'x' This.Box.X + This.Box.Width - 14 + This.AX ' y' This.Box.Y + This.Box.Height - 15 + This.AY,
            'HBITMAP:*' hBitmapFromB64(This.BottomRight.B)
        )
        This.BottomLeft.C := This.HGui.AddPicEx(
            'x' This.Box.X - 8 + This.AX ' y' This.Box.Y + This.Box.Height - 16 + This.AY,
            'HBITMAP:*' hBitmapFromB64(This.BottomLeft.B)
        )
        If This.AX {
            For Ct in This.Ctrl {
                Ct.GetPos(&X)
                Ct.Move(X + This.AX)
                If Ct.HasProp('RegexInfo') {
                    Ct.RegexInfo.GetPos(&X)
                    Ct.RegexInfo.Move(X + This.AX)
                }
                If Ct.HasProp('PlaceHolder') {
                    Ct.PlaceHolder.GetPos(&X)
                    Ct.PlaceHolder.Move(X + This.AX)
                }
            }
        }
        If This.AY {
            For Ct in This.Ctrl {
                Ct.GetPos(, &Y)
                Ct.Move(, Y + This.AY)
                If Ct.HasProp('RegexInfo') {
                    Ct.RegexInfo.GetPos(, &Y)
                    Ct.RegexInfo.Move(, Y + This.AY)
                }
                If Ct.HasProp('PlaceHolder') {
                    Ct.PlaceHolder.GetPos(, &Y)
                    Ct.PlaceHolder.Move(, Y + This.AY)
                }
            }
        }
    }
}