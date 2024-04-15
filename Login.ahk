#Requires AutoHotkey v2.0.6
#SingleInstance Force

#Include <Buttons>
#Include <Gdip_All>
#Include <ImageButton>
#Include <UseGDIP>
#Include <LV_Colors>

; Initialization
AppConfig := "Sets\AppConfig.ini"
UserConfig := "Sets\UserConfig.ini"

Name := IniRead(AppConfig, "AppConfig", "Name", "???")
AppVer := IniRead(AppConfig, "AppConfig", "Version", "???")
UpdateCheck := IniRead(AppConfig, "AppConfig", "UpdateCheck", False)
RunAtStartup := IniRead(AppConfig, "AppConfig", "RunAtStartup", False)
LastLogin := IniRead(AppConfig, "AppConfig", "LastLogin", "???")
UC := IniRead(AppConfig, "AppConfig", "UserCount", 0)

; Interface Language Load
Str := LanguageLoad()
LanguageLoad() {
    Str := []
    Loop 1000
        Str.Push("???")
    If !FileExist("Sets\Language.txt")
        Return Str
    Loop Parse FileRead("Sets\Language.txt"), "`n", "`r"
        Str[A_Index] := (StrSplit(A_LoopField, "=")[2])
    Return Str
}

; Gui
pStartUp := Gui(, Str[35])
pStartUp.MarginX := pStartUp.MarginY := 10
pStartUp.BackColor := 'White'
pStartUp.OnEvent("Close", (*) => ExitApp())

; GIF Load
;WB := pStartUp.Add("ActiveX", "w400 h207 -VScroll -HScroll", "Shell.Explorer").Value
;wb.Navigate("about:blank")
;html := '<html>`n<title>name</title>`n<body>`n<center>`n<img style="position:absolute;left:0px;top:0px" src="' A_ScriptDir '/Img/Gif/StartUp.gif" >`n</center>`n</body>`n</html>'
;wb.document.write(html)
;WB.document.body.style.overflow := "hidden"

; Informer
pInfo := pStartUp.AddText("h25 w400 Center")
pInfo.SetFont("s13 Bold", "Calibri")

; User Image Load Or Set
pUserPic := pStartUp.AddPicture("xm+136 ", DefaultImg := "Img\Png\User.png")
pUserPic.OnEvent("Click", (*) => SelectThumbnail())
SelectThumbnail() {
    Global DefaultImg
    If (pUsername.Text = "") {
        MsgBox("The username cannot be targeted!", "No username", 48)
        Return
    }
    If (!IniRead(UserConfig, pUsername.Text, , "")) {
        MsgBox(pUsername.Text " is not registered!", "Invalid", 48)
        Return
    }
    If !Thumbnail := FileSelect(, , "Select an image", "*.JPG;*.BMP;*.ICO;*.CUR;*.ANI;*.PNG;*.TIF;*.Exif;*.WMF;*.EMF") {
        Return
    }
    pToken := Gdip_Startup()
    pThumb := Gdip_CreateBitmapFromFile(Thumbnail)
    Gdip_GetDimensions(pThumb, &Width, &Height)
    MAX_SIZE := 128
    r := Width > Height ? Width / MAX_SIZE : Height / MAX_SIZE
    Width := Width / r, Height := Height / r
    pNThumb := Gdip_CreateBitmap(MAX_SIZE, MAX_SIZE)
    G := Gdip_GraphicsFromImage(pNThumb)
    Gdip_DrawImage(G
                 , pThumb
                 , Width < MAX_SIZE ? (MAX_SIZE - Width) / 2 : 0
                 , Height < MAX_SIZE ? (MAX_SIZE - Height) / 2 : 0
                 , Width
                 , Height)
    B64Img := Gdip_EncodeBitmapTo64string(pNThumb)
    If StrLen(B64Img) > 65533 {
        MsgBox(Str[303], Str[243], 48)
    }
    IniWrite(StrReplace(B64Img, "=", "\"), UserConfig, pUsername.Text, "Thumbnail")
    pUserPic.Value := "HBITMAP:*" Gdip_CreateHBITMAPFromBitmap(pNThumb)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pNThumb)
    Gdip_Shutdown(pToken)
}

; Username Input Field
pStartUp.SetFont("Bold s10", "Calibri")
pUsernameT := pStartUp.AddText("xm w400", Str[87])
pUsername := pStartUp.AddComboBox("w400")
pUsername.SetFont("s12")
pUsername.OnEvent("Change", UserCheck), DefinedUsers()
UserCheck(*) {
    pPassword.Value := ""
    If !IniRead(UserConfig, pUsername.Text, , False) {
        Return
    }
    pLevel.Choose(IniRead(UserConfig, pUsername.Text, "Level", False))
    Try {
        B64Img := StrReplace(IniRead(UserConfig, pUsername.Text, "Thumbnail", ""), "\", "=")
        pThumb := Gdip_BitmapFromBase64(B64Img)
        HpThumb := Gdip_CreateHBITMAPFromBitmap(pThumb)
        pUserPic.Value := "HBITMAP:*" HpThumb
        Gdip_DisposeImage(pThumb)
    }
    If !IniRead(UserConfig, pUsername.Text, "Save", False) {
        pSave.Value := False
        Return
    }
    pPassword.Value := IniRead(UserConfig, pUsername.Text, "Password", False)
    pSave.Value := True
}
DefinedUsers() {
    pUsername.Delete()
    For Index, User in StrSplit(IniRead(UserConfig, , , ""), "`n") {
        pUsername.Add([User])
        If User = IniRead(AppConfig, "AppConfig", "LastLogin", "") {
            pUsername.Choose(Index)
        }
    }
}

; Password Input Field
pPasswordT := pStartUp.AddText("xm w400", Str[88])
pPassword := pStartUp.AddEdit("w360 Password● h26")
pPassword.SetFont("s12 cRed")

; Password Show Or Hide Option
pShowHide := pStartUp.AddPicture("xp+365 yp-4 w30", "Img\Png\Hide.png")
ShowPass := False, pShowHide.OnEvent("Click", (*) => ShowHidePass())
ShowHidePass() {
    Global ShowPass
    If (ShowPass := !ShowPass) {
        pPassword.Opt("-Password")
        pShowHide.Value := "Img\Png\Show.png"
    } Else {
        pPassword.Opt("+Password●")
        pShowHide.Value := "Img\Png\Hide.png"
    }
}

pLevelT := pStartUp.AddText("xm w400", Str[207])
pLevel := pStartUp.AddDropDownList("w400", ["Admin", "User"])
pLevel.SetFont("s12")
pLevel.Choose(1)
pLevel.Enabled := False

; Remember Login Option
pSave := pStartUp.AddCheckBox("xm", Str[32])
pSave.SetFont("s8 italic underline")

; Submit Button
pGo := pStartUp.AddButton("xm+250 w150 h65", Str[258])
pGo.SetFont("s16 Bold", "Calibri")
CreateImageButton(pGo, 0, [[0xFFFFFF,,, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
pGo.OnEvent("Click", Login)
Login(*) {
    If (pUsername.Text = "") {
        MsgBox("The username cannot be targeted!", "No username", 48)
        Return
    }
    If (!IniRead(UserConfig, pUsername.Text, , "")) {
        MsgBox(pUsername.Text " is not registered!", "Invalid", 48)
        Return
    }
    If (!P := IniRead(UserConfig, pUsername.Text, "Password", "")) {
        MsgBox(pUsername.Text " doesn't seem to have a valid password!", "Invalid", 48)
        Return
    }
    If (P != pPassword.Value) {
        MsgBox("The password is incorrect!", "Invalid", 48)
        Return
    }

    LoggingInfo := Map()
    LoggingInfo["Name"] := pUsername.Text
    LoggingInfo["Pass"] := pPassword.Value
    LoggingInfo["Level"] := pLevel.Text
    IniWrite(pUsername.Text, AppConfig, "AppConfig", "LastLogin")
    (pSave.Value) ? IniWrite(True, UserConfig, pUsername.Text, "Save") : IniWrite(False, UserConfig, pUsername.Text, "Save")

    pStartUp.Destroy()

    pFeatures := Gui(, Str[1])
    pFeatures.BackColor := 'White'
    pFeatures.MarginX := pFeatures.MarginY := 10
    pFeatures.OnEvent("Close", (*) => ExitApp())
    pFeatures.SetFont("Bold s12", "Calibri")

    wb := pFeatures.Add("ActiveX", "w780 h77", "Shell.Explorer").Value
    wb.Navigate("about:blank")
    html := '<html>`n<title>name</title>`n<body style="background-color:#FFFFFF;">`n<center>`n<img style="position:absolute;top:0px;left:220px" src="' A_ScriptDir '/Img/Gif/Logo.gif" >`n</center>`n</body>`n</html>'
    wb.document.write(html)
    wb.document.body.style.overflow := "hidden"

    LV := pFeatures.AddListView("wp r10 -Hdr Grid -Multi", [Str[263], Str[264]])
    LV.ModifyCol(1, 720)
    LV.ModifyCol(2, 52 " Center")
    CLV := LV_Colors(LV)
    CLV.SelectionColors(0xB2B2B2)
    LV.OnEvent("Click", RunApp)

    ImageListID := IL_Create(1)
    LV.SetImageList(ImageListID)
    IL_Add(ImageListID, "shell32.dll", 290) 

    Features := StrSplit(IniRead("Sets\Features.ini",,, ""), "`n")
    For Every, Feature in Features {
        R := LV.Add("Icon1", Feature, Str[266])
        CLV.Cell(R, 2, 0xFF8080)
    }
    
    pLaunch := pFeatures.AddButton("xm+290 w200 h65", Str[267])
    pLaunch.SetFont("Bold s25", "Calibri")
    CreateImageButton(pLaunch, 0, [[0xFFFFFF,,, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    pLaunch.OnEvent("Click", RunApp)

    RunApp(GuiCtrlObj, Info) {
        AppNum := LV.GetNext()
        If AppNum {
            Try {
                Run("Bin\Apps\" LV.GetText(AppNum))
            } Catch {
                Try {
                    Run("Bin\Apps\" LV.GetText(AppNum) ".ahk")
                }
            }
        }
    }
    pFeatures.Show()
}

; Add User Button
pNewUser := pStartUp.AddButton("xm yp+40", Str[248])
CreateImageButton(pNewUser, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
pNewUser.OnEvent("Click", (*) => AddUser())
AddUser() {
    If UC {
        If (pUsername.Text = "") {
            MsgBox("The username cannot be targeted!", "No username", 48)
            Return
        }
        If (!IniRead(UserConfig, pUsername.Text, , "")) {
            MsgBox(pUsername.Text " is not registered!", "Invalid", 48)
            Return
        }
        If (IniRead(UserConfig, pUsername.Text, "Password", "???") != pPassword.Value) {
            MsgBox("The password is incorrect!", "Invalid", 48)
            Return
        }
        If (IniRead(UserConfig, pUsername.Text, "Level", "???") != "Admin") {
            MsgBox(pUsername.Text " is not an admin!", "Prevelige", 48)
            Return
        }
    }
    AddUserView()
}
AddUserView() {
    Global UC
    pUserPic.Value := "Img\Png\User.png"
    pUsernameT.Text := Str[92], pUsername.Opt("c004680")
    pUsername.OnEvent("Change", UserCheck, False)
    pPasswordT.Text := Str[93], pPassword.Opt("c004680")
    pLevel.Enabled := True
    If !UC {
        pLevel.Enabled := False
        pLevel.Choose(1)
    }
    pSave.Visible := False
    pGo.Text := "+ " Str[250], CreateImageButton(pGo, 0, [[0xFFFFFF,, 0x008000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    pNewUser.Visible := False
    pUserRemove.Visible := False
    pGoBack.Visible := True
    pGo.OnEvent("Click", Login, False)
    pGo.OnEvent("Click", AddUserApply)
    pGo.OnEvent("Click", RemoveUserApply, False)
    pGo.Focus()
}
AddUserApply(*) {
    If (pUsername.Text = "") {
        MsgBox("The username cannot be targeted!", "No username", 48)
        Return
    }
    If (IniRead(UserConfig, pUsername.Text, , "")) {
        MsgBox(pUsername.Text " already registered!", "Invalid", 48)
        Return
    }
    If (pUsername.Text ~= "[^A-Za-z0-9_]") {
        MsgBox("The username contains illegal caracter!, must be in ([A-Z], [a-z], [0-9], [_])", "Invalid", 48)
        Return
    }
    If (StrLen(pPassword.Value) < 8) {
        MsgBox("The password is too short!", "Too short", 48)
        Return
    }
    IniWrite(pPassword.Value, UserConfig, pUsername.Text, "Password")
    IniWrite(pLevel.Text, UserConfig, pUsername.Text, "Level")
    pInfo.Visible := True
    pInfo.Opt("cffffff Background008000")
    pInfo.Value := "✓ " Str[256]
    SetTimer(WaitHideInfo, -5000)
    WaitHideInfo() {
        pInfo.Visible := False
    }
    UC := IniRead(AppConfig, "AppConfig", "UserCount", 0)
    If IsInteger(UC) && (pLevel.Text = "Admin") {
        IniWrite(++UC, AppConfig, "AppConfig", "UserCount")
    }
    DefinedUsers(), UserCheck()
}

; Remove User Button
pUserRemove := pStartUp.AddButton("xp+60 yp", Str[257])
CreateImageButton(pUserRemove, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
pUserRemove.OnEvent("Click", (*) => RemoveUser())
RemoveUser() {
    If (pUsername.Text = "") {
        MsgBox("The username cannot be targeted!", "No username", 48)
        Return
    }
    If (!IniRead(UserConfig, pUsername.Text, , "")) {
        MsgBox(pUsername.Text " is not registered!", "Invalid", 48)
        Return
    }
    If (IniRead(UserConfig, pUsername.Text, "Password", "???") != pPassword.Value) {
        MsgBox("The password is incorrect!", "Invalid", 48)
        Return
    }
    If (IniRead(UserConfig, pUsername.Text, "Level", "???") != "Admin") {
        MsgBox(pUsername.Text " is not an admin!", "Prevelige", 48)
        Return
    }
    RemoveUserView()
}
RemoveUserView() {
    pUserPic.Value := "Img\Png\User.png"
    pUsernameT.Text := Str[259], pUsernameT.Opt("cff0000"), pUsername.Opt("c004680")
    pUsername.OnEvent("Change", UserCheck, False)
    pPasswordT.Visible := False, pPassword.Visible := False, pShowHide.Visible := False
    pLevelT.Visible := False, pLevel.Visible := False
    pSave.Visible := False
    pGo.Text := Str[91], CreateImageButton(pGo, 0, [[0xFFFFFF,, 0xFF0000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    pNewUser.Visible := False
    pUserRemove.Visible := False
    pGoBack.Visible := True
    pGo.OnEvent("Click", Login, False)
    pGo.OnEvent("Click", AddUserApply, False)
    pGo.OnEvent("Click", RemoveUserApply)
}
RemoveUserApply(*) {
    Global UC
    If (pUsername.Text = "") {
        MsgBox("The username cannot be targeted!", "No username", 48)
        Return
    }
    If (!IniRead(UserConfig, pUsername.Text, , "")) {
        MsgBox(pUsername.Text " is not registered!", "Invalid", 48)
        Return
    }
    Level := IniRead(UserConfig, pUsername.Text, "Level", "")
    IniDelete(UserConfig, pUsername.Text)
    pInfo.Visible := True
    pInfo.Opt("cffffff BackgroundFF0000")
    pInfo.Value := "X " Str[261]
    SetTimer(WaitHideInfo, -5000)
    WaitHideInfo() {
        pInfo.Visible := False
    }
    UC := IniRead(AppConfig, "AppConfig", "UserCount", 0)
    If IsInteger(UC) && (Level = "Admin") {
        IniWrite(--UC, AppConfig, "AppConfig", "UserCount")
    }
    DefinedUsers(), UserCheck()
}

pKBDShow := pStartUp.AddButton("xp+60 yp", Str[290])
CreateImageButton(pKBDShow, 0, [[0xFFFFFF,,, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
pKBDShow.OnEvent("Click", (*) => KBDShow())
KBDShow() {
    Run('osk.exe')
}
; Go Back Button
pGoBack := pStartUp.AddButton("xm yp", "←")
pGoBack.Visible := False
CreateImageButton(pGoBack, 0, [[0xFFFFFF,, 0xFF8000, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
pGoBack.OnEvent("Click", (*) => GoBack())
GoBack() {
    DefaultView()
}
DefaultView(*) {
    pUserPic.Value := "Img\Png\User.png"
    pUsernameT.Visible := True, pUsernameT.Text := Str[87], pUsername.Visible := True, pUsernameT.Opt("c000000"), pUsername.Opt("c000000")
    pUsername.OnEvent("Change", UserCheck, True)
    pPasswordT.Visible := True, pPasswordT.Text := Str[88], pPassword.Visible := True, pPassword.Opt("cff0000"), pShowHide.Visible := True
    pLevelT.Visible := True, pLevel.Visible := True
    pLevel.Enabled := False
    pSave.Visible := True
    pGo.Text := Str[258], CreateImageButton(pGo, 0, [[0xFFFFFF,,, 4, 0xCCCCCC, 2], [0xE6E6E6], [0xCCCCCC], [0xFFFFFF,, 0xCCCCCC]]*)
    pNewUser.Visible := True
    pUserRemove.Visible := True
    pGoBack.Visible := False
    pGo.OnEvent("Click", Login)
    pGo.OnEvent("Click", AddUserApply, False)
    pGo.OnEvent("Click", RemoveUserApply, False)
    pGo.Focus(), UserCheck()
}

pStartUp.Show(), pGo.Focus(), UserCheck()
if IsInteger(UC) && (UC = 0) {
    AddUserView()
}
Return

#r:: Reload()