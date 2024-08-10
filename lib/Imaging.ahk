class Imaging {
	loadAppImages() {
		This.Picture := Map()
		Loop Files, 'images\*.*' {
			Name := StrSplit(A_LoopFileName, '.')[1]
			This.Picture[Name] := A_LoopFileFullPath
		}
	}
	b64ResizeImage(Image, Width := 128, Height := 128) {
		This.pToken := Gdip_Startup()
		pBitmap1 := Gdip_CreateBitmapFromFile(Image)
		ImageWidth := Gdip_GetImageWidth(pBitmap1)
		ImageHeight := Gdip_GetImageHeight(pBitmap1)
		If ImageWidth > ImageHeight {
			ScaleFactor := ImageWidth / Width
			If !ScaleFactor {
				ScaleFactor := 1
			}
			ImageWidth /= ScaleFactor
			ImageHeight /= ScaleFactor
			YPastePos := (Height - ImageHeight) / 2
		} Else {
			ScaleFactor := ImageHeight / Height
			If !ScaleFactor {
				ScaleFactor := 1
			}
			ImageWidth /= ScaleFactor
			ImageHeight /= ScaleFactor
			XPastePos := (Width - ImageWidth) / 2
		}
		pBitmap2 := Gdip_CreateBitmap(Width, Height)
		pGraphics := Gdip_GraphicsFromImage(pBitmap2)
		Gdip_DrawImage(pGraphics, pBitmap1, IsSet(XPastePos) ? XPastePos : 0, 0, ImageWidth, ImageHeight)
		b64Image := Gdip_EncodeBitmapTo64string(pBitmap2)
		Gdip_DeleteGraphics(pGraphics)
		Gdip_DisposeImage(pBitmap1)
		Gdip_DisposeImage(pBitmap2)
		Gdip_Shutdown(This.pToken)
		Return b64Image
	}
	hBitmapFromB64(b64Image) {
		This.pToken := Gdip_Startup()
		HBITMAP := Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(b64Image))
		Gdip_Shutdown(This.pToken)
		Return HBITMAP
	}
}