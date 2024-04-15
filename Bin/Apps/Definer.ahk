#Requires AutoHotkey v2.0.4
#SingleInstance Force

#Include <Admin>
#Include <Buttons>
#Include <Gdip_All>
#Include <ImageButton>
#Include <UseGDIP>
#Include <LV_Colors>
#Include <WorkDir>
#Include <HashFile>

; Interface Language Load
LanguageLoad() {
    Str := []
    If !FileExist("Sets\Language.txt")
        Return False
    Loop 1000
        Str.Push("???")
    Loop Parse FileRead("Sets\Language.txt"), "`n", "`r"
        Str[A_Index] := (StrSplit(A_LoopField, "=")[2])
    Return Str
}
Str := LanguageLoad()

; Some Definitions
SellType := [
      'PIECE'
    , 'GRAM'
    , 'LITRE'
    , 'METRE'
]
ProductList := Map()
b64NThumb := ''
hBitmap := 0

; Gui Definer
pDefiner := Gui('', Str[236])
pDefiner.OnEvent("Close", (*) => (ExitApp()
                                , Gdip_Shutdown(pToken)))
pDefiner.MarginX := 10
pDefiner.MarginY := 10

; Mode
pMode := pDefiner.AddButton('w1260', Str[295])
pMode.SetFont("Bold s12", "Calibri")
CreateImageButton(pMode, 0, IBStyles['black']*)
pMode.OnEvent('Click', (*) => SwitchMode())
SwitchMode() {
    Mode := pMode.Text
    Switch Mode {
        Case Str[295]:
            ; Look change
            pMode.Text := Str[292]
            CreateImageButton(pMode, 0, IBStyles['green']*)
            pGroup.Text := Str[268]
            pGroup.Opt('cGreen')
            CreateImageButton(pSave, 0, IBStyles['green']*)
            CreateImageButton(pRemThumb, 0, IBStyles['green']*)
            CLV.SelectionColors(0x008000, 0xFFFFFF)
            pProductList.Redraw()
            CreateImageButton(pCharge, 0, IBStyles['green']*)
            ; Enable forms
            pBarcode.Opt('-ReadOnly')
            pName.Opt('-ReadOnly')
            pSellMethod.Opt('-Disabled')
            pPriceEach.Opt('-ReadOnly')
            pBuyPrice.Opt('-ReadOnly')
            pSellPrice.Opt('-ReadOnly')
            pQuantity.Opt('-ReadOnly')
            pThumbnail.Opt('-Disabled')
            ; Enable buttons
            pSave.Enabled := True
            pRemThumb.Enabled := True
            pCharge.Enabled := False
        Case Str[292]:
            ; Look change
            pMode.Text := Str[293]
            CreateImageButton(pMode, 0, IBStyles['blue']*)
            pGroup.Text := Str[294]
            pGroup.Opt('c0000ff')
            CreateImageButton(pSave, 0, IBStyles['blue']*)
            CreateImageButton(pRemThumb, 0, IBStyles['blue']*)
            CLV.SelectionColors(0x0000FF, 0xFFFFFF)
            pProductList.Redraw()
            CreateImageButton(pCharge, 0, IBStyles['blue']*)
        Case Str[293]:
            ; Look change
            pMode.Text := Str[300]
            CreateImageButton(pMode, 0, IBStyles['orange']*)
            pGroup.Text := Str[301]
            pGroup.Opt('c804000')
            CreateImageButton(pSave, 0, IBStyles['orange']*)
            CreateImageButton(pRemThumb, 0, IBStyles['orange']*)
            CLV.SelectionColors(0x804000, 0xFFFFFF)
            pProductList.Redraw()
            CreateImageButton(pCharge, 0, IBStyles['orange']*)
            ; Enable buttons
            pSave.Enabled := False
            pRemThumb.Enabled := False
            pThumbnail.Opt('+Disabled')
        Case Str[300]:
            ; Look change
            pMode.Text := Str[304]
            CreateImageButton(pMode, 0, IBStyles['red']*)
            pGroup.Text := Str[305]
            pGroup.Opt('cred')
            CLV.SelectionColors(0x800000, 0xFFFFFF)
            pProductList.Redraw()
            CreateImageButton(pCharge, 0, IBStyles['red']*)
            ; Disable forms
            pBarcode.Opt('+ReadOnly')
            pName.Opt('+ReadOnly')
            pSellMethod.Opt('+Disabled')
            pPriceEach.Opt('+ReadOnly')
            pBuyPrice.Opt('+ReadOnly')
            pSellPrice.Opt('+ReadOnly')
            pQuantity.Opt('+ReadOnly')
            pThumbnail.Opt('+Disabled')
        Case Str[304]:
            ; Look change
            pMode.Text := Str[295]
            CreateImageButton(pMode, 0, IBStyles['black']*)
            pGroup.Text := Str[296]
            pGroup.Opt('cBlack')
            CLV.SelectionColors(0x000000, 0xFFFFFF)
            pProductList.Redraw()
            CreateImageButton(pCharge, 0, IBStyles['black']*)
            pCharge.Enabled := True
    }
    FormsCheckMark()
}

pGroup := pDefiner.AddGroupBox("xm ym+27 w450 h500 cBlack", Str[296])
pGroup.SetFont("Bold s16", "Calibri")
PA_OK := pDefiner.AddText("xp+10 yp+30 w430 h20 Center")
PA_OK.SetFont("Bold s12", "Calibri")

; Barcode Input
pDefiner.AddText("xm+10 yp+30 w130 cRed", Str[27]).SetFont("Bold s10", "Calibri")
pBarcode := pDefiner.AddEdit("yp w260 h25 cBlue Center +ReadOnly")
pBarcode.SetFont("Bold s12", "Calibri")
pBarcode.OnEvent("Change", (*) => FormsCheckMark())
pBarcodeOK := pDefiner.AddText("xp+265 yp w30 h25 Center", "")
pBarcodeOK.SetFont("Bold s14 Underline", "Calibri")

; Name Input
pDefiner.AddText("xm+10 w130 yp+30 cRed", Str[38]).SetFont("Bold s10", "Calibri")
pName := pDefiner.AddEdit("yp w260 h25 Center +ReadOnly")
pName.SetFont("Bold s12", "Calibri")
pName.OnEvent("Change", (*) => FormsCheckMark())
pNameOK := pDefiner.AddText("xp+265 yp w30 h25 Center", "")
pNameOK.SetFont("Bold s14 Underline", "Calibri")

; Sell Method Input
pDefiner.AddText("xm+10 w140 yp+30 cRed", Str[279]).SetFont("Bold s10", "Calibri")
pSellMethod := pDefiner.AddDropDownList("xp+240 yp w160 cBlue r5 +Disabled", [Str[270], Str[271], Str[272], Str[273]])
PostMessage(0x0153, -1, 21, pSellMethod)
pSellMethod.SetFont("Bold s10", "Calibri")
pSellMethod.Choose(1)
pSellMethodOK := pDefiner.AddText("xp+165 yp w30 h25 Center cGreen")
pSellMethodOK.SetFont("Bold s14 Underline", "Calibri")
pPriceEach := pDefiner.AddEdit("xp-265 yp w98 h27 cblue Number Center +ReadOnly", 1)
pPriceEach.SetFont("Bold s12", "Calibri")
pPriceEach.OnEvent("Change", (*) => FormsCheckMark())

; Buy Price Input
pDefiner.AddText("xm+10 w130 yp+30 cRed", Str[40]).SetFont("Bold s10", "Calibri")
pBuyPrice := pDefiner.AddEdit("yp w260 h25 cRed Number Center +ReadOnly")
pBuyPrice.SetFont("Bold s12", "Calibri")
pBuyPrice.OnEvent("Change", (*) => FormsCheckMark())
pBuyPriceOK := pDefiner.AddText("xp+265 yp w30 h25 Center", "")
pBuyPriceOK.SetFont("Bold s14 Underline", "Calibri")

; Sell Price Input
pDefiner.AddText("xm+10 w130 yp+30 cRed", Str[39]).SetFont("Bold s10", "Calibri")
pSellPrice := pDefiner.AddEdit("yp w260 h25 cGreen Number Center +ReadOnly")
pSellPrice.SetFont("Bold s12", "Calibri")
pSellPrice.OnEvent("Change", (*) => FormsCheckMark())
pSellPriceOK := pDefiner.AddText("xp+265 yp w30 h25 Center", "")
pSellPriceOK.SetFont("Bold s14 Underline", "Calibri")

; Quantity Input
pDefiner.AddText("xm+10 w130 yp+30", Str[68]).SetFont("Bold s10", "Calibri")
pQuantity := pDefiner.AddEdit("yp w260 h25 Center +ReadOnly", 1)
pQuantity.SetFont("Bold s12", "Calibri")

; Thumbnail Input
pDefiner.AddText("xm+10 w130 yp+30", Str[276]).SetFont("Bold s10", "Calibri")
pThumbnail := pDefiner.AddPicture("xp+205 yp+12 w128 h128 Border +Disabled", "Img\Png\User.png")
pThumbnail.OnEvent("Click", (*) => SelectThumnail())
pRemThumb := pDefiner.AddButton('wp yp+135 Disabled', Str[306])
pRemThumb.SetFont('Bold')
pRemThumb.OnEvent('Click', (*) => ClearThumnail())
CreateImageButton(pRemThumb, 0, IBStyles['black']*)
SelectThumnail() {
    Global b64NThumb
    If !ThumbnailSelect := FileSelect(,, "Select an image", "*.JPG;*.BMP;*.ICO;*.CUR;*.ANI;*.PNG;*.TIF;*.Exif;*.WMF;*.EMF") {
        Return
    }
    pToken := Gdip_Startup()
    pThumb := Gdip_CreateBitmapFromFile(ThumbnailSelect)
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
    b64NThumb := Gdip_EncodeBitmapTo64string(pNThumb)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pNThumb)
    pThumbnail.Value := "HBITMAP:" hBitmap
    hBitmap := 0
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pThumb)
    Gdip_DisposeImage(pNThumb)
}
ClearThumnail() {
    pThumbnail.Value := 'Img\Png\User.png'
    if !Row := pProductList.GetNext()
        Return
    Code := pProductList.GetText(Row, 1)
    If !FileExist('Bin\Data\Defs\' Code '.b64')
        Return
    FileDelete('Bin\Data\Defs\' Code '.b64')
}
; Enable/Disable auto-fill
pAutoFill := pDefiner.AddCheckbox('xm+10 yp+30 w430', Str[297])
pAutoFill.SetFont("Bold Underline Italic", "Calibri")
pAutoFill.Value := IniRead('Sets\AppConfig.ini', 'AppConfig', 'AutoFill', 0)
pAutoFill.OnEvent('Click', (*) => IniWrite(pAutoFill.Value, 'Sets\AppConfig.ini', 'AppConfig', 'AutoFill'))
FillUpInputs() {
    if !pAutoFill.Value || !Row := pProductList.GetNext()
        Return
    Code := pProductList.GetText(Row, 1)
    Keys := StrSplit(IniRead('Bin\Data\Defs\' Code '.ini', "INFO",, ""), "`n")
    CFGA := ["", "", 1, "", "", "", "", "", 'Img\Png\User.png']
    For Each, Key in Keys {
        CFGA[Each] := StrSplit(Key, "=")[2]
    }
    pBarcode.Value := CFGA[1]
    pName.Value := CFGA[2]
    pSellMethod.Value := CFGA[3]
    pPriceEach.Value := CFGA[4]
    pBuyPrice.Value := CFGA[5]
    pSellPrice.Value := CFGA[6]
    pQuantity.Value := CFGA[7]
    ; Thumbnail
    If !FileExist(CFGA[8]) || (CFGA[8] = 'Img\Png\User.png') {
        pThumbnail.Value := 'Img\Png\User.png'
    } Else {
        B64 := FileRead(CFGA[8])
        Try {
            Bitmap := Gdip_BitmapFromBase64(B64)
            hBitmap := Gdip_CreateHBITMAPFromBitmap(Bitmap)
            pThumbnail.Value := "HBITMAP:*" hBitmap
        }
    }
    FormsCheckMark()
}

; Enable/Disable auto-search
pAutoSearch := pDefiner.AddCheckbox('xm+10 yp+20 w430', Str[298])
pAutoSearch.SetFont("Bold Underline Italic", "Calibri")
pAutoSearch.Value := IniRead('Sets\AppConfig.ini', 'AppConfig', 'AutoSearch', 0)
pAutoSearch.OnEvent('Click', (*) => SearchThelist())
SearchThelist() {
    IniWrite(pAutoSearch.Value, 'Sets\AppConfig.ini', 'AppConfig', 'AutoSearch')
    
}

; Enable/Disable clear forms
pClearForms := pDefiner.AddCheckbox('xm+10 yp+20 w430 Checked', Str[299])
pClearForms.SetFont("Bold Underline Italic", "Calibri")
pClearForms.Value := IniRead('Sets\AppConfig.ini', 'AppConfig', 'AutoSearch', 0)
pClearForms.OnEvent('Click', (*) => CleanUpInputs())
CleanUpInputs() {
    IniWrite(pClearForms.Value, 'Sets\AppConfig.ini', 'AppConfig', 'ClearForms')
    If !pClearForms.Value
        Return
    pBarcode.value := '', pBarcodeOK.Value := ''
    pName.value := '', pNameOK.Value := ''
    pPriceEach.value := 1
    pSellMethod.Choose(1), pSellMethodOK.Value := ''
    pBuyPrice.Value := '', pBuyPriceOK.Value := ''
    pSellPrice.Value := '', pSellPriceOK.Value := ''
    pQuantity.Value := 1
    pThumbnail.Value := "Img\Png\User.png"
}

; Submit New Product
pSave := pDefiner.AddButton("xm w450 +Disabled h25", Str[278])
pSave.SetFont("Bold s12", "Calibri")
CreateImageButton(pSave, 0, IBStyles["black"]*)
pSave.OnEvent("Click", (*) => SaveProduct())
SaveProduct() {
    If (!FormsCheckMark() || !FormsCheckEdit())
        Return
    WriteDataToDB()
}
WriteDataToDB() {
    Global b64NThumb
    If !pQuantity.Value {
        pQuantity.Value := 1
    }
    CFGA := []
    CFGA.Push(pBarcode.Value), IniWrite(pBarcode.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'BARCODE')
    CFGA.Push(pName.Value), IniWrite(pName.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'NAME')
    CFGA.Push(pSellMethod.Value), IniWrite(pSellMethod.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'SELLTYPE')
    CFGA.Push(pPriceEach.Value), IniWrite(pPriceEach.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'SELLOF')
    CFGA.Push(pBuyPrice.Value), IniWrite(pBuyPrice.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'BUYWITH')
    CFGA.Push(pSellPrice.Value), IniWrite(pSellPrice.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'SELLWITH')
    CFGA.Push(pQuantity.Value), IniWrite(pQuantity.Value, "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'QUANTITY')
    If (b64NThumb != '') {
        FileOpen("Bin\Data\Defs\" pBarcode.Value ".b64", 'w').Write(b64NThumb)
        IniWrite("Bin\Data\Defs\" pBarcode.Value ".b64", "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'THUMB')
        b64NThumb := ''
    } Else {
        IniWrite("Img\Png\User.png", "Bin\Data\Defs\" pBarcode.Value ".ini", "INFO", 'THUMB')
    }
    PA_OK.Visible := True
    PA_OK.Opt((pMode.Text = Str[292] ? 'BackgroundGreen' : 'BackgroundBlue') " cWhite")
    PA_OK.Value := "'" pName.Value "' " Str[284]
    SetTimer(HoldFor5Sec, -5000)

    CFGA[3] := SellType[CFGA[3]]

    If (pMode.Text = Str[292]) {
        pProductList.Insert(1,, CFGA*)
        ProductList['' pBarcode.Value] := CFGA
    } Else {
        pProductList.Modify(ProductList['' pBarcode.Value][ProductList['' pBarcode.Value].Length],, CFGA*)
    }
    CleanUpInputs()
}
; Manage Groups
;pGroup := pDefiner.AddButton("xm+460 ym+13 w120", Str[200])
;pGroup.SetFont("Bold s12", "Calibri")
;CreateImageButton(pGroup, 0, IBStyles["info"]*)

; Registered Products List
pProductList := pDefiner.AddListView("xm+460 ym+40 w800 h486 Grid", [Str[63], Str[206], Str[285], Str[291], Str[281], Str[282], Str[68]])
CLV := LV_Colors(pProductList)
CLV.SelectionColors(0x000000, 0xFFFFFF)
pProductList.SetFont("Bold s12", "Calibri")
Loop 7 {
    pProductList.ModifyCol(A_Index, 113 " Center")
}
pProductList.ModifyCol(1, "-Center")
pProductList.OnEvent('Click', (*) => FillUpInputs())

; Import Registered Products (From Old Structure)
pCharge := pDefiner.AddButton("xm+460 yp+497 w120 +ReadOnly h25", Str[288])
pCharge.SetFont("Bold s12", "Calibri")
CreateImageButton(pCharge, 0, IBStyles["black"]*)
pCharge.OnEvent("Click", (*) => LoadDef())
LoadDef() {
    If Dir := FileSelect("D") {
        pCharge.Text := Str[289]
        CreateImageButton(pCharge, 0, IBStyles["dark"]*)
        pCharge.Enabled := False
        Loop Files, Dir "\*.def", "R" {
            Barcode := StrReplace(A_LoopFileName, ".def")
            If FileExist("Bin\Data\Defs\" Barcode ".ini")
                Continue
            Info := StrSplit(Trim(FileRead(A_LoopFileFullPath), ";"), ";")
            Try {
            CFG :=  "BARCODE=" Barcode
                . "`nNAME=" Info[1]
                . "`nSELLTYPE=" 1
                . "`nSELLOF=" 1
                . "`nBUYWITH=" Info[2]
                . "`nSELLWITH=" Info[3]
                . "`nQUANTITY=" Info[4]
                . "`nTHUMB=Img\Png\User.png"
                IniWrite(CFG, "Bin\Data\Defs\" Barcode ".ini", "INFO")
                pProductList.Insert(1,, Barcode, Info[1], SellType[1], 1, Info[2], Info[3], Info[4])
            } Catch As Err {
                FileAppend(Str[302] " => " A_LoopFileFullPath " => " Err.Message "`n", Dir "\Log.log")
            }
        }
        pProductList.ModifyCol(1, "AutoHdr")
        pProductList.ModifyCol(2, "AutoHdr")
        pCharge.Text := Str[288]
        CreateImageButton(pCharge, 0, IBStyles["dark"]*)
        pCharge.Enabled := True
    }
}
pToken := Gdip_Startup()
pDefiner.Show()
LoadCFG()
pBarcode.Focus()
Properties := Map('01GATEGORY'  , Map('TEXT'        , Str[307]
                                    , 'TEXTOPT'     , 'w300 h35'
                                    , 'TEXTFONT'    , ['Bold s14', 'Calibri']
                                    , 'INPUTOPT'    , 'w300 h25'
                                    , 'INPUTFONT'   , ['Bold s14 Underline', 'Calibri']
                                    , 'VALUE'       , []
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , '\b[A-Za-z0-9_]\b'
                                    , 'TYPE'        , 'COMBOBOX')
                , '02VSPLIT'    , Map('TEXT'        , ''
                                    , 'TEXTOPT'     , 'ym h400 0x11'
                                    , 'TEXTFONT'    , []
                                    , 'INPUTOPT'    , 'xp yp w1 h1'
                                    , 'INPUTFONT'   , []
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'w1 h1'
                                    , 'OKFONT'      , []
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'TEXT')
                , '03CODE'      , Map('TEXT'        , Str[63]
                                    , 'TEXTOPT'     , 'ym w150 h20 cBlue'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250 h25 cBlue'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , '\b[A-Za-z0-9_]\b'
                                    , 'TYPE'        , 'EDIT')
                , '04NAME'      , Map('TEXT'        , Str[206]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250 h25'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , '\b[A-Za-z0-9_]\b'
                                    , 'TYPE'        , 'EDIT')
                , '05BUYPRICE'  , Map('TEXT'        , Str[281]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20 cRed'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250 h25 cRed Number'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'EDIT')
                , '06SELLPRICE' , Map('TEXT'        , Str[282]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20 cGreen'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250 h25 cGreen Number'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'EDIT')
                , '07VAT'       , Map('TEXT'        , Str[309]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250 h25 ReadOnly'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'EDIT')
                , '08CURRENCY'  , Map('TEXT'        , Str[280]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , StrSplit(Str[310], ',')
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'DROPDOWNLIST')
                , '09SELLTYPE'  , Map('TEXT'        , Str[285]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , StrSplit(Str[311], ',')
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'DROPDOWNLIST')
                , '10STOCK'     , Map('TEXT'        , Str[6]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w250 h25 Number'
                                    , 'INPUTFONT'   , ['Bold s12', 'Calibri']
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'EDIT')
                , '11THUMB'     , Map('TEXT'        , Str[276]
                                    , 'TEXTOPT'     , 'xp-412 yp+30 w150 h20'
                                    , 'TEXTFONT'    , ['Bold s12', 'Calibri']
                                    , 'INPUTOPT'    , 'yp w128 h128 Border'
                                    , 'INPUTFONT'   , []
                                    , 'VALUE'       , ''
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'yp w30 h25 Center'
                                    , 'OKFONT'      , ["Bold s14 Underline", "Calibri"]
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'PICTURE')
                , '12SAVE'      , Map('TEXT'        , ''
                                    , 'TEXTOPT'     , 'xm w1 h1'
                                    , 'TEXTFONT'    , []
                                    , 'INPUTOPT'    , 'xp yp w800 h30'
                                    , 'INPUTFONT'   , ['Bold s14', 'Calibri']
                                    , 'VALUE'       , Str[278]
                                    , 'HANDLE'      , 0
                                    , 'OKHANDLE'    , 0
                                    , 'OKOPT'       , 'w1 h1'
                                    , 'OKFONT'      , []
                                    , 'OKREGEX'     , ''
                                    , 'TYPE'        , 'BUTTON'))
WindowAdd := Gui(, Str[308])
WindowAdd.OnEvent('Close', (*) => WindowAdd.Hide())

For Property, Control in Properties {
    WindowAdd.AddText(Control['TEXTOPT'], Control['TEXT']).SetFont(Control['TEXTFONT']*)
    If Property = '2VSPLIT'
        Continue
    Control['HANDLE'] := WindowAdd.Add(Control['TYPE'], Control['INPUTOPT'], Control['VALUE'])
    If Property = '11THUMB'
        Continue
    Control['HANDLE'].SetFont(Control['INPUTFONT']*)
    Control['OKHANDLE'] := WindowAdd.AddText(Control['OKOPT'])
    Control['OKHANDLE'].SetFont(Control['OKFONT']*)
}
WindowAdd.Show()
Return

HoldFor5Sec() {
    PA_OK.Visible := False
}

FormsCheckEdit() {
If !pBarcode.Value || pBarcodeOK.Value = "✖" {
        PA_OK.Visible := True
        PA_OK.Opt("BackgroundFFC080 cBlack")
        PA_OK.Value := Str[63] " " Str[286]
        pBarcode.Focus()
        pBarcodeOK.Opt("cRed")
        pBarcodeOK.Value := "✖"
        SetTimer(HoldFor5Sec, -5000)
        Return False
    }
    If !pName.Value || pNameOK.Value = "✖" {
        PA_OK.Visible := True
        PA_OK.Opt("BackgroundFFC080 cBlack")
        PA_OK.Value := Str[206] " " Str[286]
        pName.Focus()
        pNameOK.Opt("cRed")
        pNameOK.Value := "✖"
        SetTimer(HoldFor5Sec, -5000)
        Return False
    }
    If !pPriceEach.Value {
        PA_OK.Visible := True
        PA_OK.Opt("BackgroundFFC080 cBlack")
        PA_OK.Value := Str[270] " " Str[286]
        pPriceEach.Focus()
        pSellMethodOK.Opt("cRed")
        pSellMethodOK.Value := "✖"
        SetTimer(HoldFor5Sec, -5000)
        Return False
    }
    If !pBuyPrice.Value {
        PA_OK.Visible := True
        PA_OK.Opt("BackgroundFFC080 cBlack")
        PA_OK.Value := Str[281] " " Str[286]
        pBuyPrice.Focus()
        pBuyPriceOK.Opt("cRed")
        pBuyPriceOK.Value := "✖"
        SetTimer(HoldFor5Sec, -5000)
        Return False
    }
    If !pSellPrice.Value {
        PA_OK.Visible := True
        PA_OK.Opt("BackgroundFFC080 cBlack")
        PA_OK.Value := Str[281] " " Str[286]
        pSellPrice.Focus()
        pSellPriceOK.Opt("cRed")
        pSellPriceOK.Value := "✖"
        SetTimer(HoldFor5Sec, -5000)
        Return False
    }
    Return True
}

FormsCheckMark() {
    pBarcodeOK.Value := ''
    pNameOK.Value := ''
    pSellMethodOK.Value := ''
    pBuyPriceOK.Value := ''
    pSellPriceOK.Value := ''
    If (pMode.Text != Str[292] && pMode.Text != Str[293])
        Return
    If !pBarcode.Value {
        pBarcodeOK.Value := ''
        Return False
    }
    If pBarcode.Value ~= "[^A-Za-z0-9]" {
        pBarcodeOK.Opt("cRed")
        pBarcodeOK.Value := "✖"
        Return False
    }
    Switch pMode.Text {
        Case Str[292]:
            If FileExist("Bin\Data\Defs\" pBarcode.Value ".ini") {
                pBarcodeOK.Opt("cRed")
                pBarcodeOK.Value := "✖"
                Return False
            }
        Case Str[293]:
            If !FileExist("Bin\Data\Defs\" pBarcode.Value ".ini") {
                pBarcodeOK.Opt("cRed")
                pBarcodeOK.Value := "✖"
                Return False
            }
    }
    While (R := pProductList.GetNext())
        pProductList.Modify(R, '-Select')
    R := ProductList['' pBarcode.Value][ProductList['' pBarcode.Value].Length]
    pProductList.Modify(R, 'Select Vis')

    pBarcodeOK.Opt("cGreen")
    pBarcodeOK.Value := "✔"

    If pName.Value = "" {
        pNameOK.Opt("cRed")
        pNameOK.Value := "✖"
        Return False
    }
    pNameOK.Opt("cGreen")
    pNameOK.Value := "✔"

    If !pPriceEach.Value {
        pSellMethodOK.Value := ""
        pSellMethodOK.Opt("cRed")
        Return False
    }
    pSellMethodOK.Opt("cGreen")
    pSellMethodOK.Value := "✔"

    If !pBuyPrice.Value {
        pBuyPriceOK.Value := ""
        pBuyPriceOK.Opt("cRed")
        Return False
    }
    pBuyPriceOK.Opt("cGreen")
    pBuyPriceOK.Value := "✔"

    If !pSellPrice.Value {
        pSellPriceOK.Value := ""
        pSellPriceOK.Opt("cRed")
        Return False
    }
    pSellPriceOK.Opt("cGreen")
    pSellPriceOK.Value := "✔"
    Return True
}

LoadCFG() {
    C := 0, BCS := ""
    Loop Files, "Bin\Data\Defs\*.ini" {
        ++C
        BCS .= BCS ? "|" A_LoopFileName : A_LoopFileName
    }
    BCS := Sort(BCS, "N D|")
    pProductList.Opt("-Redraw")
    For Each, Name in StrSplit(BCS, "|") {
        FN := "Bin\Data\Defs\" Name
        Keys := StrSplit(IniRead(FN, "INFO",, ""), "`n")
        CFGA := []
        For Each, Key in Keys {
            If Each != 8
                CFGA.Push(StrSplit(Key, "=")[2])
        }
        CFGA[3] := SellType[CFGA[3]]
        Row := pProductList.Add(, CFGA*)
        CFGA.Push(Row)
        CLV.Cell(Row, 1,, 0xFF0000FF)
        CLV.Cell(Row, 3,, 0xFF808080)
        CLV.Cell(Row, 5,, 0xFFFF0000)
        CLV.Cell(Row, 6,, 0xFF008000)
        ProductList['' CFGA[1]] := CFGA
    }
    pProductList.ModifyCol(1, "AutoHdr")
    pProductList.ModifyCol(2, "AutoHdr")
    pProductList.ModifyCol(3, "AutoHdr")
    pProductList.Opt("+Redraw")
    pProductList.Focus()
}