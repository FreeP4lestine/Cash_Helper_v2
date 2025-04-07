#Include <GuiEx\ScrollBars>
#Include <GuiEx\CreateImageButton>
#Include <GuiEx\ImageButtons>
#Include <GuiEx\ImagePut>
#Include <GuiEx\ControlBorder>
#Include <GuiEx\Gdip>

Class GuiEx extends Gui {
    Proportion := Map()
    AddPicEx(
        Option := '',
        Value := '',
        WHResize := 1
    ) {
        P := This.AddPicture(Option, Value)
        P.DefineProp('WHResize', {
            Get: IsWHResize
        })
        IsWHResize(Ctrl) {
            Return WHResize
        }
        Return P
    }
    AddEditEx(
        Option := '',
        Value := '',
        Banner := '',
        FontOption := [],
        Regex := ''
    ) {
        If FontOption && Type(FontOption) = 'Array' && FontOption.Length = 2 {
            This.SetFont(FontOption*)
        }
        E := This.AddEdit('-E0x200 Border ' Option, Value)
        If Banner != '' {
            This.EM_SETCUEBANNER(E.Hwnd, Banner)
        }
        E.GetPos(&X, &Y, &Width, &Height)
        X := This.AddText('x' X ' y' Y + Height ' Hidden cRed', Regex)
        E.DefineProp('RegexInfo', {
            Get: GetText
        })
        GetText(Ctrl) {
            Return X
        }
        If Regex != '' {
            E.OnEvent('Change', (*) => Verify())
            Verify() {
                If E.Value ~= Regex || E.Value = '' {
                    E.Opt('c000000 BackgroundFFFFFF ' Option)
                    X.Visible := False
                } Else {
                    E.Opt('cFF0000 BackgroundFFB7B7')
                    X.Visible := True
                }
                E.Redraw()
            }
        }
        E.DefineProp('IsValid', {
            Get: IsValid
        })
        IsValid(Ctrl) {
            Return Regex != '' ? Ctrl.Value ~= Regex : 1
        }

        Return E
    }
    ; https://docs.microsoft.com/en-us/windows/win32/controls/em-setcuebanner
    EM_SETCUEBANNER(Handle, String, Option := True) {
        static ECM_FIRST := 0x1500
        static EM_SETCUEBANNER := ECM_FIRST + 1
        if (DllCall("user32\SendMessage", "ptr", Handle, "uint", EM_SETCUEBANNER, "int", Option, "str", String, "int"))
            return True
        return False
    }
    AddButtonEx(
        Option := '',
        Text := '',
        FontOption := [],
        IB := ''
    ) {
        If FontOption && Type(FontOption) = 'Array' && FontOption.Length = 2 {
            This.SetFont(FontOption*)
        }
        B := This.AddButton(Option, Text)
        If IB {
            CreateImageButton(B, 0, IB*)
            B.DefineProp('IB', {
                Get: GetIB
            })
            GetIB(Ctrl) {
                Return IB
            }
        }
        Return B
    }
    AddGif(
        Option := '',
        Gif := '',
        WHResize := 1
    ) {
        Pic := This.AddPicEx(Option, Gif, WHResize)
        Gif := ImageShow('images\store.gif', , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , Pic.Hwnd)
        Return Pic
    }
    Resize(
        GuiObj,
        MinMax,
        Width,
        Height
    ) {
        WWidth := Width
        WHeight := Height
        If !WWidth := WWidth
            GuiObj.GetPos(&WX, &WY, &WWidth, &WHeight)
        If !This.Proportion.Count {
            For Control in GuiObj {
                Control.GetPos(&X, &Y, &Width, &Height)
                Switch Type(Control) {
                    Case 'Gui.Button', 'Gui.Pic':
                        This.Proportion[Control] := [
                            X / WWidth,
                            Y / WHeight,
                            Width / WWidth,
                            Height / WHeight,
                            Width,
                            Height
                        ]
                    Default:
                        This.Proportion[Control] := [
                            X / WWidth,
                            Y / WHeight,
                            Width / WWidth,
                            Height / WHeight
                        ]

                }
            }
        }
        For Control, Ratio in This.Proportion {
            Coords := []
            ;msgbox Type(Control)
            Switch Type(Control) {
                Case 'Gui.Button':
                    Coords := [
                        WWidth * Ratio[1] + (WWidth * Ratio[3] - Ratio[5]) / 2,
                        WHeight * Ratio[2] + (WHeight * Ratio[4] - Ratio[6]) / 2
                    ]
                    Control.Move(Coords*)
                    If Control.HasProp('IB')
                        CreateImageButton(Control, 0, Control.IB*)
                    Control.Redraw()
                Case 'Gui.Pic':
                    If Control.HasProp('WHResize') && !Control.WHResize {
                        Coords := [
                            WWidth * Ratio[1] + (WWidth * Ratio[3] - Ratio[5]) / 2,
                            WHeight * Ratio[2] + (WHeight * Ratio[4] - Ratio[6]) / 2
                        ]
                        Control.Move(Coords*)
                        Control.Redraw()
                    } Else {
                        Coords := [
                            WWidth * Ratio[1],
                            WHeight * Ratio[2],
                            WWidth * Ratio[3],
                            WHeight * Ratio[4]
                        ]
                        Control.Move(Coords*)
                        Control.Redraw()
                    }
                Case 'GuiEx':
                    Coords := [
                        WWidth * Ratio[1],
                        WHeight * Ratio[2],
                        WWidth * Ratio[3],
                        WHeight * Ratio[4]
                    ]
                    Control.Move(Coords*)
                    WinRedraw(Control)
                Default:
                    Coords := [
                        WWidth * Ratio[1],
                        WHeight * Ratio[2],
                        WWidth * Ratio[3],
                        WHeight * Ratio[4]
                    ]
                    Control.Move(Coords*)
                    Control.Redraw()

            }
        }
    }
    ProportionAddGui(G) {
        This.GetClientPos(&WX, &WY, &WWidth, &WHeight)
        G.GetPos(&X, &Y, &Width, &Height)
        This.Proportion[G] := [
            X / WWidth,
            Y / WHeight,
            Width / WWidth,
            Height / WHeight
        ]
    }
    AddScrollGui() {
        G := GuiEx('-DPIScale Parent' mainWindow.Hwnd ' -Caption')
        G.BackColor := 'FFFFFF'
        G.MarginX := 10
        G.MarginY := 10
        SB := ScrollBar(G, 1, 1)

        Return G
    }
    AddComboBoxEx(
        Option := '',
        Value := [],
        Banner := '',
        FontOption := [],
        Regex := ''
    ) {
        If FontOption && Type(FontOption) = 'Array' && FontOption.Length = 2 {
            This.SetFont(FontOption*)
        }
        CB := This.AddComboBox('-E0x200 Border ' Option, Value)
        If InStr(Option, 'Center') {
            EditHandle := DllCall("User32.dll\GetWindow", "Ptr", CB.Hwnd, "UInt", 5, "Ptr") ; Get Edit Handle
            WinSetStyle("+0x0001", EditHandle) ; Apply ES_CENTER to center text
        }
        If Banner != '' {
            SendMessage(0x1703, 0, StrPtr(Banner), CB.Hwnd) ; CB_SETCUEBANNER
        }
        CB.GetPos(&X, &Y, &Width, &Height)
        X := This.AddText('x' X ' y' Y + Height ' Hidden cRed', Regex)
        CB.DefineProp('RegexInfo', {
            Get: GetText
        })
        GetText(Ctrl) {
            Return X
        }
        If Regex != '' {
            CB.OnEvent('Change', (*) => Verify())
            Verify() {
                If CB.Text ~= Regex || CB.Text = '' {
                    CB.Opt('c000000 BackgroundFFFFFF ' Option)
                    X.Visible := False
                } Else {
                    CB.Opt('cFF0000 BackgroundFFB7B7')
                    X.Visible := True
                }
                CB.Redraw()
            }
        }
        CB.DefineProp('IsValid', {
            Get: IsValid
        })
        IsValid(Ctrl) {
            Return Regex != '' ? Ctrl.Text ~= Regex : 1
        }
        CB.DefineProp('PopulateWithUsers', {
            Call: PopulateWithUsers
        })
        PopulateWithUsers(Ctrl) {
            Users := readJson(A_AppData '\Cash Helper\users.json')
            Ctrl.Delete()
            If Users.Has('Registered') {
                For User in Users['Registered'] {
                    Ctrl.Add([User])
                }
            }
        }
        Return CB
    }
}