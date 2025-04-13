#Include <GuiEx\ScrollBars>
#Include <GuiEx\CreateImageButton>
#Include <GuiEx\ImageButtons>
#Include <GuiEx\ImagePut>
#Include <GuiEx\ControlBorder>
#Include <GuiEx\Gdip>
#Include <GuiEx\LV_Colors>
#Include <GuiEx\ButtonIcon>

Class GuiEx extends Gui {
    Proportion := Map()
    ProportionGuis := []
	Default(QuitApp := 0) {
		pToken := Gdip_Startup()
        This.Title := setting['Name']
		This.Opt('Resize')
        This.SetFont('s25', 'Segoe UI')
		This.BackColor := 'White'
		This.MarginX := 20
		This.MarginY := 20
        If QuitApp {
            This.OnEvent('Close', Quit)
            Quit(HGui) {
                Gdip_Shutdown(pToken)
                ExitApp()
            }
        }
		This.OnEvent('Size', Resize)
        Resize(GuiObj, MinMax, Width, Height) {
        WWidth := Width
        WHeight := Height
            If !WWidth := WWidth
                GuiObj.GetClientPos(&WX, &WY, &WWidth, &WHeight)
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
                            Control.ReDraw()
                    }
                }
            }
            For Control, Ratio in This.Proportion {
                Coords := []
                Switch Type(Control) {
                    Case 'Gui.Button':
                        Coords := [
                            WWidth * Ratio[1] + (WWidth * Ratio[3] - Ratio[5]) / 2,
                            WHeight * Ratio[2] + (WHeight * Ratio[4] - Ratio[6]) / 2
                        ]
                        Control.Move(Coords*)
                        If Control.HasProp('IB')
                            CreateImageButton(Control, 0, Control.IB.Ico, Control.IB.IB*)
                        Control.Redraw()
                    Case 'Gui.Pic':
                        If Control.HasProp('WHResize') && !Control.WHResize {
                            Coords := [
                                WWidth * Ratio[1] + (WWidth * Ratio[3] - Ratio[5]) / 2,
                                WHeight * Ratio[2] + (WHeight * Ratio[4] - Ratio[6]) / 2
                            ]
                            Control.Move(Coords*)
                            Control.Redraw()
                            Continue
                        }
                        Coords := [
                            WWidth * Ratio[1],
                            WHeight * Ratio[2],
                            WWidth * Ratio[3],
                            WHeight * Ratio[4]
                        ]
                        Control.Move(Coords*)
                        Control.Redraw()
                    Case 'GuiEx':
                        If Control.HasProp('SB') {
                            Control.SB.ScrollMsg(6, 0, 0x114, Control.Hwnd)
                            Control.SB.ScrollMsg(6, 0, 0x115, Control.Hwnd)
                        }
                        Coords := [
                            WWidth * Ratio[1],
                            WHeight * Ratio[2],
                            WWidth * Ratio[3],
                            WHeight * Ratio[4]
                        ]
                        Control.Move(Coords*)
                        Control.GetPos(,, &Width, &Height)
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
    }
    AddBorder(Ctrl := [], AX := 0, YX := 0) {
        ControlBorder(This, Ctrl, AX, YX)
    }
    AddLinkEx(Option := '', Text := '', FontOption := []) {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
            This.SetFont(FontOption*)
        }
        L := This.AddLink(Option, Text)
        Return L
    }
    AddCheckBoxEx(Option := '', Text := '', FontOption := []) {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
            This.SetFont(FontOption*)
        }
        C := This.AddCheckBox(Option, Text)
        Return C
    }
    AddTextEx(Option := '', Text := '', FontOption := []) {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
            This.SetFont(FontOption*)
        }
        T := This.AddText(Option, Text)
        Return T
    }
    AddListViewEx(Option := '', Headers := [], FontOption := [], IL := 0, ILW := 0, ILH := 0) {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
            This.SetFont(FontOption*)
        }
        L := This.AddListView('-E0x200 ' Option, Headers)
        This.SetExplorerTheme(L.Hwnd)
        LC := LV_Colors(L)
        L.DefineProp(
            'Color', {
                Get: LVColor
            }
        )
        LVColor(Ctrl) {
            Return LC
        }
        If IL {
            I := This.ImageList_Create(ILW, ILH)
            L.SetImageList(I, 1)
            L.DefineProp(
                'IL', {
                    Get: ImageList
                }
            )
            ImageList(Ctrl) {
                Return I
            }
            L.DefineProp('AddEx',  {
                    Call: AddEx
                }
            )
            AddEx(Ctrl, ImageFile, Option := '', Params*) {
                Return L.Add('Icon' . IL_Add(I, ImageFile) ' ' Option, Params*)
            }
        }
        Return L
    }
    AddPicEx(Option := '', Value := '', WHResize := 1) {
        P := This.AddPicture(Option, Value)
        P.DefineProp('WHResize', {
            Get: IsWHResize
        })
        IsWHResize(Ctrl) {
            Return WHResize
        }
        P.DefineProp('B64Value', {
                Set: B64Value
            }
        )
        B64Value(Ctrl, Value) {
            Try Ctrl.Value := 'HBITMAP:*' hBitmapFromB64(Value)
        }
        Return P
    }
    AddEditEx(Option := '', Value := '', Banner := '', FontOption := [], Regex := '') {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
            This.SetFont(FontOption*)
        }
        E := This.AddEdit('-E0x200 Border BackgroundWhite ' Option, Value)
        If Banner != '' {
            This.EM_SETCUEBANNER(E.Hwnd, Banner)
        }
        E.GetPos(&X, &Y, &Width, &Height)
        If Regex != ''
            T := This.AddText('x' X ' y' Y + Height ' Hidden cRed', Regex)
        Else T := This.AddText('x' X ' y' Y + Height ' w1 h1')
        D := This.AddText('x' X ' y' Y ' w' Width ' h' Height ' Hidden')
        E.DefineProp('RegexInfo', {
            Get: GetText
        })
        GetText(Ctrl) {
            Return T
        }
        E.DefineProp('PlaceHolder', {
            Get: GetHolder
        })
        GetHolder(Ctrl) {
            Return D
        }
        If Regex != '' {
            E.OnEvent('Change', (*) => Verify())
            Verify() {
                If E.Value ~= Regex || E.Value = '' {
                    E.Opt('c000000 BackgroundFFFFFF ' Option)
                    T.Visible := False
                } Else {
                    E.Opt('cFF0000 BackgroundFFB7B7')
                    T.Visible := True
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
    AddButtonEx(Option := '', Text := '', FontOption := [], IB := '', Icon := '') {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
            This.SetFont(FontOption*)
        }
        B := This.AddButton(Option, Text)
        If IB {
            CreateImageButton(B, 0, Icon, IB*)
            B.DefineProp('IB', {
                Get: GetIB
            })
            GetIB(Ctrl) {
                Return {
                    IB: IB, 
                    Ico: Icon
                }
            }
        }
        Return B
    }
    AddGif(Option := '', Gif := '', WHResize := 1) {
        Pic := This.AddPicEx(Option, Gif, WHResize)
        Gif := ImageShow('images\store.gif', , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , Pic.Hwnd)
        Return Pic
    }
    AddScrollGui() {
        G := GuiEx('Parent' This.Hwnd ' -Caption')
        G.Default()

        SB := ScrollBar(G, 1, 1)
        G.DefineProp('SB', {
            Get: GetSB
        })
        GetSB(Ctrl) {
            Return SB
        }
        This.ProportionGuis.Push(G)
        Return G
    }
    AddGuiToProportion() {
        For G in This.ProportionGuis {
            This.GetClientPos(&WX, &WY, &WWidth, &WHeight)
            G.GetPos(&X, &Y, &Width, &Height)
            This.Proportion[G] := [
                X / WWidth,
                Y / WHeight,
                Width / WWidth,
                Height / WHeight
            ]
            ;G.Resize(G, 0, Width, Height)
        }
    }
    AddComboBoxEx(Option := '', Value := [], Banner := '', FontOption := [], Regex := '') {
        If FontOption && FontOption.Length && FontOption.Length <= 2{
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
    ; SetExplorerTheme
    SetExplorerTheme(Handle) {
        if (DllCall("kernel32\GetVersion", "uchar") > 5) {
            VarSetStrCapacity(&ClassName, 1024)
            if (DllCall("user32\GetClassName", "ptr", Handle, "str", ClassName, "int", 512, "int")) {
                if (ClassName = "SysListView32") || (ClassName = "SysTreeView32")
                    return !DllCall("uxtheme\SetWindowTheme", "ptr", Handle, "str", "Explorer", "ptr", 0)
            }
        }
        return false
    }
    ; EM_SETCUEBANNER
    EM_SETCUEBANNER(Handle, String, Option := True) {
        static ECM_FIRST := 0x1500
        static EM_SETCUEBANNER := ECM_FIRST + 1
        if (DllCall("user32\SendMessage", "ptr", Handle, "uint", EM_SETCUEBANNER, "int", Option, "str", String, "int"))
            return True
        return False
    }
    ; IL_Create
    ImageList_Create(W, H, cInitial := 1, cGrow := 1) {
        Static ILC_COLOR32 := 0x20, 
               ILC_ORIGINALSIZE := 0x00010000
        Return DllCall("comctl32.dll\ImageList_Create", "int", W, "int", H, "uint", ILC_COLOR32 | ILC_ORIGINALSIZE, "int", cInitial, "int", cGrow)
    }
}