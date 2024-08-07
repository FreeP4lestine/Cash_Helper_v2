#Requires Autohotkey v2.0
#SingleInstance Force
/*
If A_Args.Length != 2 {
	MsgBox("Incorrect arguments!", "NoCode", 0x10)
	ExitApp()
}

Code := A_Args[1]
HEIGHT_OF_IMAGE := A_Args[2]

if !isNumber(HEIGHT_OF_IMAGE) {
	MsgBox("Incorrect height!", "NoCode", 0x10)
	ExitApp()
}
*/
Code := '123'
HEIGHT_OF_IMAGE := 40
MATRIX_TO_PRINT := BARCODER_GENERATE_CODE_128B(Code)
if (MATRIX_TO_PRINT = 1) {
	MsgBox("The input message is either blank or contains characters that cannot be encoded in CODE_128B.", "Error", 16)
	ExitApp()
}
If !pToken := Gdip_Startup() {
	MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system", "gdiplus error!", 48)
	ExitApp()
}
pBitmap := Gdip_CreateBitmap((MATRIX_TO_PRINT.Length + 8) * 2, HEIGHT_OF_IMAGE + 3) ; Adding 8 pixels to the width here as a "quiet zone" for the image. This serves to improve the printed code readability.
G := Gdip_GraphicsFromImage(pBitmap)
Gdip_SetSmoothingMode(pBitmap, 3)
pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)
Gdip_FillRectangle(G, pBrush, 0, 0, (MATRIX_TO_PRINT.Length + 8) * 2, HEIGHT_OF_IMAGE + 3) ; Same as above
Gdip_DeleteBrush(pBrush)

Loop HEIGHT_OF_IMAGE {
	CURRENT_ROW := A_Index
	Loop MATRIX_TO_PRINT.Length {
		CURRENT_COLUMN := A_Index * 2
		If (MATRIX_TO_PRINT[A_Index] = 1) {
			Loop 2
			{
				Gdip_SetPixel(pBitmap, CURRENT_COLUMN + 3 + A_Index - 1, CURRENT_ROW, 0xFF000000) ; Adding 3 to the current column and the current row to skip the quiet zones.
			}
		}
	}
}

FileOpen("GeneratedBarcode.b64", "w").Write(Gdip_EncodeBitmapTo64string(pBitmap, "JPG"))

Gdip_DisposeImage(pBitmap)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
 
MsgBox("CODE128B image succesfully created!", "Success", 0)

#Include <barcoderv2>
#Include <Gdip_All>