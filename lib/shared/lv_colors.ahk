; ======================================================================================================================
; Namespace:      LV_Colors
; Function:       Individual row and cell coloring for AHK ListView controls.
; Tested with:    AHK 2.0.2 (U32/U64)
; Tested on:      Win 10 (x64)
; Changelog:      2023-01-04/2.0.0/just me   Initial release of the AHK v2 version
; ======================================================================================================================
; CLASS LV_Colors
;
; The class provides methods to set individual colors for rows and/or cells, to clear all colors, to prevent/allow
; sorting and rezising of columns dynamically, and to deactivate/activate the notification handler for NM_CUSTOMDRAW
; notifications (see below).
;
; A message handler for NM_CUSTOMDRAW notifications will be activated for the specified ListView whenever a new
; instance is created. If you want to temporarily disable coloring call MyInstance.ShowColors(False). This must
; be done also before you try to destroy the instance. To enable it again, call MyInstance.ShowColors().
;
; To avoid the loss of Gui events and messages the message handler is set 'critical'. To prevent 'freezing' of the
; list-view or the whole GUI this script requires AHK v2.0.1+.
; ======================================================================================================================
Class LV_Colors {
   ; ===================================================================================================================
   ; __New()         Constructor - Create a new LV_Colors instance for the given ListView
   ; Parameters:     HWND        -  ListView's HWND.
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 StaticMode  -  Static color assignment, i.e. the colors will be assigned permanently to the row
   ;                                contents rather than to the row number.
   ;                                Values:  True/False
   ;                                Default: False
   ;                 NoSort      -  Prevent sorting by click on a header item.
   ;                                Values:  True/False
   ;                                Default: False
   ;                 NoSizing    -  Prevent resizing of columns.
   ;                                Values:  True/False
   ;                                Default: False
   ; ===================================================================================================================
   __New(LV, StaticMode := False, NoSort := False, NoSizing := False) {
      If (LV.Type != "ListView")
         Throw TypeError("LV_Colors requires a ListView control!", -1, LV.Type)
      ; ----------------------------------------------------------------------------------------------------------------
      ; Set LVS_EX_DOUBLEBUFFER (0x010000) style to avoid drawing issues.
      LV.Opt("+LV0x010000")
      ; Get the default colors
      BkClr := SendMessage(0x1025, 0, 0, LV) ; LVM_GETTEXTBKCOLOR
      TxClr := SendMessage(0x1023, 0, 0, LV) ; LVM_GETTEXTCOLOR
      ; Get the header control
      Header := SendMessage(0x101F, 0, 0, LV) ; LVM_GETHEADER
      ; Set other properties
      This.LV := LV
      This.HWND := LV.HWND
      This.Header := Header
      This.BkClr := BkCLr
      This.TxClr := Txclr
      This.IsStatic := !!StaticMode
      This.AltCols := False
      This.AltRows := False
      This.SelColors := False
      This.NoSort(!!NoSort)
      This.NoSizing(!!NoSizing)
      This.ShowColors()
      This.RowCount := LV.GetCount()
      This.ColCount := LV.GetCount("Col")
      This.Rows := Map()
      This.Rows.Capacity := This.RowCount
      This.Cells := Map()
      This.Cells.Capacity := This.RowCount
   }
   ; ===================================================================================================================
   ; __Delete()      Destructor
   ; ===================================================================================================================
   __Delete() {
      This.ShowColors(False)
      If WinExist(This.HWND)
         WinRedraw(This.HWND)
   }
   ; ===================================================================================================================
   ; Clear()         Clears all row and cell colors.
   ; Parameters:     AltRows     -  Reset alternate row coloring (True / False)
   ;                                Default: False
   ;                 AltCols     -  Reset alternate column coloring (True / False)
   ;                                Default: False
   ; Return Value:   Always True.
   ; ===================================================================================================================
   Clear(AltRows := False, AltCols := False) {
      If (AltCols)
         This.AltCols := False
      If (AltRows)
         This.AltRows := False
      This.Rows.Clear()
      This.Rows.Capacity := This.RowCount
      This.Cells.Clear()
      This.Cells.Capacity := This.RowCount
      Return True
   }
   ; ===================================================================================================================
   ; UpdateProps()   Updates the RowCount, ColCount, BkClr, and TxClr properties.
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   UpdateProps() {
      If !(This.HWND)
         Return False
      This.BkClr := SendMessage(0x1025, 0, 0, This.LV) ; LVM_GETTEXTBKCOLOR
      This.TxClr := SendMessage(0x1023, 0, 0, This.LV) ; LVM_GETTEXTCOLOR
      This.RowCount := This.LV.GetCount()
      This.Colcount := This.LV.GetCount("Col")
      If WinExist(This.HWND)
         WinRedraw(This.HWND)
      Return True
   }
   ; ===================================================================================================================
   ; AlternateRows() Sets background and/or text color for even row numbers.
   ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   AlternateRows(BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.AltRows := False
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      This.ARB := (BkBGR != "") ? BkBGR : This.BkClr
      This.ART := (TxBGR != "") ? TxBGR : This.TxClr
      This.AltRows := True
      Return True
   }
   ; ===================================================================================================================
   ; AlternateCols() Sets background and/or text color for even column numbers.
   ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   AlternateCols(BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.AltCols := False
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      This.ACB := (BkBGR != "") ? BkBGR : This.BkClr
      This.ACT := (TxBGR != "") ? TxBGR : This.TxClr
      This.AltCols := True
      Return True
   }
   ; ===================================================================================================================
   ; SelectionColors() Sets background and/or text color for selected rows.
   ; Parameters:     BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default selected background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default selected text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   SelectionColors(BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.SelColors := False
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      This.SELB := BkBGR
      This.SELT := TxBGR
      This.SelColors := True
      Return True
   }
   ; ===================================================================================================================
   ; Row()           Sets background and/or text color for the specified row.
   ; Parameters:     Row         -  Row number
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> default text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   Row(Row, BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.RowCount := This.LV.GetCount()
      If (Row >This.RowCount)
         Return False
      If This.IsStatic
         Row := This.MapIndexToID(Row)
      If This.Rows.Has(Row)
         This.Rows.Delete(Row)
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      ; Colors := {B: (BkBGR != "") ? BkBGR : This.BkClr, T: (TxBGR != "") ? TxBGR : This.TxClr}
      This.Rows[Row] := Map("B", (BkBGR != "") ? BkBGR : This.BkClr, "T", (TxBGR != "") ? TxBGR : This.TxClr)
      Return True
   }
   ; ===================================================================================================================
   ; Cell()          Sets background and/or text color for the specified cell.
   ; Parameters:     Row         -  Row number
   ;                 Col         -  Column number
   ;                 Optional ------------------------------------------------------------------------------------------
   ;                 BkColor     -  Background color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> row's background color
   ;                 TxColor     -  Text color as RGB color integer (e.g. 0xFF0000 = red) or HTML color name.
   ;                                Default: Empty -> row's text color
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   Cell(Row, Col, BkColor := "", TxColor := "") {
      If !(This.HWND)
         Return False
      This.RowCount := This.LV.GetCount()
      This.ColCount := This.LV.GetCount('Col')
      If (Row > This.RowCount) || (Col > This.ColCount)
         Return False
      If This.IsStatic
         Row := This.MapIndexToID(Row)
      If This.Cells.Has(Row) && This.Cells[Row].Has(Col)
         This.Cells[Row].Delete(Col)
      If (BkColor = "") && (TxColor = "")
         Return True
      BkBGR := This.BGR(BkColor)
      TxBGR := This.BGR(TxColor)
      If (BkBGR = "") && (TxBGR = "")
         Return False
      If !This.Cells.Has(Row)
         This.Cells[Row] := [], This.Cells[Row].Capacity := This.ColCount
      If (Col > This.Cells[Row].Length)
         This.Cells[Row].Length := Col
      This.Cells[Row][Col] := Map("B", (BkBGR != "") ? BkBGR : This.BkClr, "T", (TxBGR != "") ? TxBGR : This.TxClr)
      Return True
   }
   ; ===================================================================================================================
   ; NoSort()        Prevents/allows sorting by click on a header item for this ListView.
   ; Parameters:     Apply       -  True/False
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   NoSort(Apply := True) {
      If !(This.HWND)
         Return False
      This.LV.Opt((Apply ? "+" : "-") . "NoSort")
      Return True
   }
   ; ===================================================================================================================
   ; NoSizing()      Prevents/allows resizing of columns for this ListView.
   ; Parameters:     Apply       -  True/False
   ; Return Value:   True on success, otherwise false.
   ; ===================================================================================================================
   NoSizing(Apply := True) {
      If !(This.Header)
         Return False
      ControlSetStyle((Apply ? "+" : "-") . "0x0800", This.Header) ; HDS_NOSIZING = 0x0800
      Return True
   }
   ; ===================================================================================================================
   ; ShowColors()    Adds/removes a message handler for NM_CUSTOMDRAW notifications of this ListView.
   ; Parameters:     Apply       -  True/False
   ; Return Value:   Always True
   ; ===================================================================================================================
   ShowColors(Apply := True) {
      If (Apply) && !This.HasOwnProp("OnNotifyFunc") {
         This.OnNotifyFunc := ObjBindMethod(This, "NM_CUSTOMDRAW")
         This.LV.OnNotify(-12, This.OnNotifyFunc)
         WinRedraw(This.HWND)
      }
      Else If !(Apply) && This.HasOwnProp("OnNotifyFunc") {
         This.LV.OnNotify(-12, This.OnNotifyFunc, 0)
         This.OnNotifyFunc := ""
         This.DeleteProp("OnNotifyFunc")
         WinRedraw(This.HWND)
      }
      Return True
   }
   ; ===================================================================================================================
   ; Internally used/called Methods
   ; ===================================================================================================================
   NM_CUSTOMDRAW(LV, L) {
      ; Return values: 0x00 (CDRF_DODEFAULT), 0x20 (CDRF_NOTIFYITEMDRAW / CDRF_NOTIFYSUBITEMDRAW)
      Static SizeNMHDR := A_PtrSize * 3                  ; Size of NMHDR structure
      Static SizeNCD := SizeNMHDR + 16 + (A_PtrSize * 5) ; Size of NMCUSTOMDRAW structure
      Static OffItem := SizeNMHDR + 16 + (A_PtrSize * 2) ; Offset of dwItemSpec (NMCUSTOMDRAW)
      Static OffItemState := OffItem + A_PtrSize         ; Offset of uItemState  (NMCUSTOMDRAW)
      Static OffCT :=  SizeNCD                           ; Offset of clrText (NMLVCUSTOMDRAW)
      Static OffCB := OffCT + 4                          ; Offset of clrTextBk (NMLVCUSTOMDRAW)
      Static OffSubItem := OffCB + 4                     ; Offset of iSubItem (NMLVCUSTOMDRAW)
      Critical -1
      If !(This.HWND) || (NumGet(L, "UPtr") != This.HWND)
         Return
      ; ----------------------------------------------------------------------------------------------------------------
      DrawStage := NumGet(L + SizeNMHDR, "UInt"),
      Row := NumGet(L + OffItem, "UPtr") + 1,
      Col := NumGet(L + OffSubItem, "Int") + 1,
      Item := Row - 1
      If This.IsStatic
         Row := This.MapIndexToID(Row)
      ; CDDS_SUBITEMPREPAINT = 0x030001 --------------------------------------------------------------------------------
      If (DrawStage = 0x030001) {
         UseAltCol := (This.AltCols) && !(Col & 1),
         ColColors := (This.Cells.Has(Row) && This.Cells[Row].Has(Col)) ? This.Cells[Row][Col] : Map("B", "", "T", ""),
         ColB := (ColColors["B"] != "") ? ColColors["B"] : UseAltCol ? This.ACB : This.RowB,
         ColT := (ColColors["T"] != "") ? ColColors["T"] : UseAltCol ? This.ACT : This.RowT,
         NumPut("UInt", ColT, L + OffCT), NumPut("UInt", ColB, L + OffCB)
         Return (!This.AltCols && (Col > This.Cells[Row].Length)) ? 0x00 : 0x020
      }
      ; CDDS_ITEMPREPAINT = 0x010001 -----------------------------------------------------------------------------------
      If (DrawStage = 0x010001) {
         ; LVM_GETITEMSTATE = 0x102C, LVIS_SELECTED = 0x0002
         If (This.SelColors) && SendMessage(0x102C, Item, 0x0002, This.HWND) {
            ; Remove the CDIS_SELECTED (0x0001) and CDIS_FOCUS (0x0010) states from uItemState and set the colors.
            NumPut("UInt", NumGet(L + OffItemState, "UInt") & ~0x0011, L + OffItemState)
            If (This.SELB != "")
               NumPut("UInt", This.SELB, L + OffCB)
            If (This.SELT != "")
               NumPut("UInt", This.SELT, L + OffCT)
            Return 0x02 ; CDRF_NEWFONT
         }
         UseAltRow := This.AltRows && (Item & 1),
         RowColors := This.Rows.Has(Row) ? This.Rows[Row] : "",
         This.RowB := RowColors ? RowColors["B"] : UseAltRow ? This.ARB : This.BkClr,
         This.RowT := RowColors ? RowColors["T"] : UseAltRow ? This.ART : This.TxClr
         If (This.AltCols || This.Cells.Has(Row))
            Return 0x20
         NumPut("UInt", This.RowT, L + OffCT), NumPut("UInt", This.RowB, L + OffCB)
         Return 0x00
      }
      ; CDDS_PREPAINT = 0x000001 ---------------------------------------------------------------------------------------
      Return (DrawStage = 0x000001) ? 0x20 : 0x00
   }
   ; -------------------------------------------------------------------------------------------------------------------
   MapIndexToID(Row) { ; provides the unique internal ID of the given row number
      Return SendMessage(0x10B4, Row - 1, 0, This.HWND) ; LVM_MAPINDEXTOID
   }
   ; -------------------------------------------------------------------------------------------------------------------
   BGR(Color, Default := "") { ; converts colors to BGR
      ; HTML Colors (BGR)
      Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                    , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                    , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
      If IsInteger(Color)
         Return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
      Return (HTML.HasOwnProp(Color) ? HTML.%Color% : Default)
   }
}