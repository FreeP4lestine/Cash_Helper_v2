#Requires AutoHotkey v1
#SingleInstance Force
HEIGHT_OF_IMAGE := 20
MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_128B(Code := "6192011803672")
if (MATRIX_TO_PRINT = 1) {
	Msgbox, 0x10, Error, The input message is either blank or contains characters that cannot be encoded in CODE_128B.
	ExitApp
}
If !pToken := Gdip_Startup() {
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
pBitmap := Gdip_CreateBitmap((MATRIX_TO_PRINT.MaxIndex() + 8) * 2, HEIGHT_OF_IMAGE + 3) ; Adding 8 pixels to the width here as a "quiet zone" for the image. This serves to improve the printed code readability.
G := Gdip_GraphicsFromImage(pBitmap)
Gdip_SetSmoothingMode(pBitmap, 3)
pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)
Gdip_FillRectangle(G, pBrush, 0, 0, (MATRIX_TO_PRINT.MaxIndex() + 8) * 2, HEIGHT_OF_IMAGE + 3) ; Same as above
Gdip_DeleteBrush(pBrush)

Loop % HEIGHT_OF_IMAGE {
	CURRENT_ROW := A_Index
	Loop % MATRIX_TO_PRINT.MaxIndex() {
		CURRENT_COLUMN := A_Index
		If (MATRIX_TO_PRINT[A_Index] = 1) {
			;Loop 1
			;{
				Gdip_SetPixel(pBitmap, CURRENT_COLUMN + 3, CURRENT_ROW, 0xFF000000) ; Adding 3 to the current column and the current row to skip the quiet zones.
			;}
		}
	}
}

FileOpen("GeneratedBarcode.b64", "w").Write(Clipboard := Gdip_EncodeBitmapTo64string(pBitmap, "JPG"))

Gdip_DisposeImage(pBitmap)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
 
Msgbox, 0, Success, CODE128B image succesfully created!

#Include <BarCoder>
#Include <Gdip>