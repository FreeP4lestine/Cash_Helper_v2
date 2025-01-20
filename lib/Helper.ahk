#Include <ImagePut>
#Include <SQLiteDB>
#Include <CNG>
#Include <CreateImageButton>
#Include <ImageButtons>
#Include <ColorGradient>
#Include <inc\ui-base>

Class Helper {
    __New() {
        This.Author := 'Mohamed Chandoul'
        This.AuthorEmail := 'Chandoul.Mohamed26@Gmail.com'
        This.AppName := 'Cash Helper'
        This.AppVersion := '2.0'
        This.GuiOpt := 'E0x02000000 E0x00080000'
        This.BackColor := 'White'
        This.Font := ['Bold', 'Segoe UI']
        This.Margin := 10
        This.StoreGif := 'images\store.gif'
        This.StorePng := 'images\storeback.png'
        This.TreeList := [A_AppData '\' This.AppName]
        This.KeysDBPath := This.TreeList[1] '\Keys.db'
        This.UsersDBPath := This.TreeList[1] '\Users.db'
        This.KeyTable := 'KeyTable'
        This.SQLDB := SQLiteDB()
        This.__StartUp()
    }
    __StartUp() {
        This.__OSCheck()
        This.__GuiSetup()
        This.__TreeCheck()
        This.__KeysCheck()
    }
    __OSCheck() {
        MajorOSVersion := StrSplit(A_OSVersion, '.')[1]
        If MajorOSVersion < 6 {
            MsgBox('Sorry to inform you that your operating system is not supported!`nVista is the minimum operating system', 'Un-supported OS', 0x10)
            ExitApp()
        }
    }
    __GuiSetup() {
        This.Gui := Gui(This.GuiOpt, This.AppName ' v' This.AppVersion)
        This.Gui.OnEvent('Close', (*) => ExitApp())
        This.Gui.BackColor := This.BackColor
        This.Gui.SetFont(This.Font*)
        This.Gui.MarginX := This.Margin
        This.Gui.MarginY := This.Margin
        This.StatusBar := This.Gui.AddStatusBar()
        This.StatusBar.SetParts(100, 100, 300)
        This.StatusBar.SetText('`t' This.AppName)
        This.StatusBar.SetText('`tv' This.AppVersion, 2)
        This.StatusBar.SetText('`t' This.Author, 3)
        This.StatusBar.SetText('`t' This.AuthorEmail, 4)
        This.Gui.AddPicture(, This.StorePng)
        This.Gif := This.Gui.AddPicture('xm+195 yp w' ImageWidth(This.StoreGif) ' h' ImageHeight(This.StoreGif), This.StoreGif)
        Try ImageShow(This.StoreGif, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , This.Gif.Hwnd)
        Catch
            This.Gui.AddPicture('xm+195', This.StoreGif)
        This.Gui.AddPicture('xm+124', 'images\slogan100.png')
        This.Gui.SetFont('s12')
        This.UserName := This.Gui.AddEdit('xm+200 w380 Center c000080 ')
        This.__EM_SETCUEBANNER(This.UserName, 'Username / Loginname', 1)
        This.PassWord := This.Gui.AddEdit('xm+200 w380 Center cRed Password')
        This.__EM_SETCUEBANNER(This.PassWord, 'Password', 1)
        This.Gui.SetFont('s14')
        This.Login := This.Gui.AddButton('xm+200 wp', 'Login'), CreateImageButton(This.Login, 0, IBBlack1*)
        This.Gui.AddPicture(, 'images\login.png')
        This.Gui.SetFont('s8')
        This.HideShow := This.Gui.AddCheckbox('Right xp yp w380', 'Show password')
        This.Remember := This.Gui.AddCheckbox('Right wp', 'Remember my inputs')
        This.Keyboard := This.Gui.AddCheckbox('Right wp', 'Hide / Show keyboard')
        This.Create := This.Gui.AddButton('wp', 'No account?, create one!'), CreateImageButton(This.Create, 0, IBGreen1*)
        This.Gui.Show('w800 h600')
        SetTimer(This.Timer := ObjBindMethod(This, "__BackColorAnimate"), 5000)
    }
    __TreeCheck() {
        For Tree in This.TreeList {
            If !DirExist(Tree)
                Try DirCreate(Tree)
                Catch {
                    MsgBox("Unable to create the app environement!", "Error", 16)
                    ExitApp()
                }
        }
    }
    __KeysCheck() {
        This.Gui.Opt('Disabled')
        _OK_ := True
        _OK_ := _OK_ && This.SQLDB.OpenDB(This.KeysDBPath)
        SQLCom := "SELECT AppKey FROM " This.KeyTable ";"
        _OK_ := _OK_ && This.SQLDB.GetTable(SQLCom, &Table)
        This.SQLDB.CloseDB()
        _OK_ := _OK_ && Table.HasNames && Table.ColumnCount
        __ValidKeys() {
            AppKey1 := Table.Rows[1][1]
            AppKey2 := 'CASHHELPER'
            AppKey2 .= '_' This.__CPU_SN()
            AppKey2 := Hash.String('SHA-256', AppKey2)
            Return AppKey2 == AppKey1
        }
        _OK_ := _OK_ && __ValidKeys()
        If !_OK_ {
            MsgBox("Unable to run the app due to the lack of some neccessary information!", "Key error", 0x10 ' T5')
            ExitApp()
        }
        This.Gui.Opt('-Disabled')
        WinActivate(This.Gui)
    }
    __KeysCreate() { ; CASHHELPER_%CPUSN%
        AppKey := 'CASHHELPER'
        AppKey .= '_' This.__CPU_SN()
        AppKey := Hash.String('SHA-256', AppKey)
        SQLCom := "CREATE TABLE " This.KeyTable "(AppKey VARCHAR(64));"
                . "INSERT INTO " This.KeyTable " (AppKey) VALUES ('" AppKey "');"
        If FileExist(This.KeysDBPath)
            FileDelete(This.KeysDBPath)
        This.SQLDB.OpenDB(This.KeysDBPath)
        This.SQLDB.Exec(SQLCom)
        This.SQLDB.CloseDB()
    }
    __CPU_SN() {
        objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
        colItems := objWMIService.ExecQuery("Select * From Win32_BaseBoard")._NewEnum
        While colItems(&SWbemObjectEx)
            Return SWbemObjectEx.SerialNumber
    }
    __EM_SETCUEBANNER(handle, string, option := false) {
    	static ECM_FIRST := 0x1500
    	static EM_SETCUEBANNER := ECM_FIRST + 1
    	SendMessage(EM_SETCUEBANNER, option, StrPtr(string), handle)
    }
    __BackColorAnimate() {
        SetTimer(This.Timer, 0)
        Static Colors := [0xFFFFFF, 0xFFC080, 0xC0FF80, 0x80FF80, 0x80FFC0, 0x80FFFF, 0x8080FF, 0xFFFFFF]
        Static Interval := 1000
        Static Slp := Interval // 2
        Loop Interval
            This.Gui.BackColor := ColorGradient(A_Index / Interval, Colors), Sleep(Slp)
        SetTimer(This.Timer, 5000)
    }

    Class LoginButton {
        __New(Parent) {
            This.Parent := Parent
            This.Parent.Login.OnEvent('Click', (*) => This.__AttempLogin())
        }
        __AttempLogin() {
            If (Username := This.Parent.UserName.Value) = '' {
                MsgBox('Username must not be empty!', 'Login', 0x30)
                This.Parent.UserName.Focus()
                Return
            }
            If (Password := This.Parent.PassWord.Value) = '' {
                MsgBox('Password must not be empty!', 'Login', 0x30)
                This.Parent.PassWord.Focus()
                Return
            }
            This.Parent.SQLDB.OpenDB(This.Parent.UsersDBPath)
            SQLCom := "SELECT AppKey FROM " This.Parent.UserName.Value ";"
            If !This.Parent.SQLDB.GetTable(SQLCom, &Table) {
                MsgBox('There is no such a record for this user, please register first!', 'Login', 0x30)
                Return
            }
        }
    }

    Class LoginCheckBoxs {
        __New(Parent) {
            This.Parent := Parent
            Parent.HideShow.OnEvent('Click', (*) => This.__HideShow())
            Parent.Keyboard.OnEvent('Click', (*) => This.__Keyboard())
        }
        __HideShow() {
            Static Toggle := 0
            This.Parent.PassWord.Opt(((!(Toggle := !Toggle)) ? '' : '-') 'Password')
        }
        __Keyboard() {
            Static Toggle := 0
            If Toggle := !Toggle
                Run('osk.exe')
            Else If PID := ProcessExist('osk.exe')
                ProcessClose(PID)
        }
    }

    Class CreateAccount {
        __New(Parent) {
            This.Parent := Parent
            Parent.Create.OnEvent('Click', (*) => This.__CreateStartUp())
        }
        __CreateStartUp() {
            This.Gui := AutoHotkeyUxGui('Accounts Manager', This.Parent.GuiOpt)
            This.Gui.OnEvent('Close', (*) => This.Gui.Destroy())
            This.Gui.BackColor := This.Parent.BackColor
            This.Gui.SetFont('s12', This.Parent.Font[2])
            This.Gui.MarginX := This.Parent.Margin
            This.Gui.MarginY := This.Parent.Margin
            This.Username := This.Gui.AddEdit('xm+400 Center w380')
            This.Parent.__EM_SETCUEBANNER(This.Username, 'Username / Loginname', 1)
            This.Passowrd := This.Gui.AddEdit('xm+400 Center w380')
            This.Parent.__EM_SETCUEBANNER(This.Passowrd, 'Password', 1)
            This.UserPic := This.Gui.AddPicture('xm+526 w128', 'images\Default.png')
            This.Gui.SetFont('s8')
            This.SelectUserPic := This.Gui.AddButton('xm+400 w185', 'Select')
            CreateImageButton(This.SelectUserPic, 0, IBGreen1*)
            This.RemoveUserPic := This.Gui.AddButton('xm+595 yp w185', 'Remove')
            CreateImageButton(This.RemoveUserPic, 0, IBRed1*)
            This.Options := This.Gui.AddListMenu('xm+400 w380 r4 Checked BackgroundWhite Border')
            This.Gui.SetFont('s12')
            This.Extras := This.Gui.AddEdit('xm+400 Center w380 r4')
            This.Parent.__EM_SETCUEBANNER(This.Extras, 'Extra Info', 1)
            This.Create := This.Gui.AddButton('xm+400 Center w380', 'Update')
            This.Gui.SetFont('s10')
            This.Users := This.Gui.AddListMenu('xm ym w380 r14')
            CreateImageButton(This.Create, 0, IBBlack1*)
            This.Gui.Show('w800 h600')
        }
    }
}