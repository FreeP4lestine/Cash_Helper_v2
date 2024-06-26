; User defined function
CreateArray(Length) {
	Array := []
	Loop Length {
		Array.Push('')
	}
	Return Array
}
ClearArray(Array) {
	Loop Array.Length {
		Array[A_Index] := ''
	}
	Return Array
}
ArrayMerge(Array1 := [], Array2 := []) {
	Merged := ''
	If Array1.Length != Array2.Length {
		Return Merged
	}
	Loop Array1.Length {
		Merged .= Merged = '' ? Array1[A_Index] '="' Array2[A_Index] '"' : ', ' Array1[A_Index] '="' Array2[A_Index] '"'
	}
	Return Merged
}
UpdateComboBox(Ctrl, Array) {
	Ctrl.Delete()
	For Row, Col in Array {
		Ctrl.Add([Col[2]])
	}
}
MasterKeyCheck(MasterKey) {
	EnteredKey := EnterKey := InputBox('Please enter the master key below:', 'Master Key', 'w400 h100')
	If EnteredKey.Result != 'OK' {
		Return False
	}
	If EnteredKey.Value = '' {
		Msgbox('The master key is required', 'Master Key', 48)
		Return False
	}
	If EnteredKey.Value !== MasterKey {
		Msgbox('The master key is incorrect', 'Master Key', 48)
		Return False
	}
	Return True
}
IBBitmapCombine(Image1, Image2, ImgLoc := 'DB\Img') {
	Image3 := StrReplace(Image1, 'SubApp', Image2)
	Image2 .= '.png'
	If !FileExist(ImgLoc '\' Image2) {
		Return ImgLoc '\' Image1
	}
	pBitmap1 := Gdip_CreateBitmapFromFile(ImgLoc '\' Image1)
	pBitmap2 := Gdip_CreateBitmapFromFile(ImgLoc '\' Image2)
	pGraphics := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_DrawImage(pGraphics, pBitmap2, 28, 28, 64, 64)
	If !FileExist(ImgLoc '\' Image3) {
		Gdip_SaveBitmapToFile(pBitmap1, ImgLoc '\' Image3)
	}
	Gdip_DeleteGraphics(pGraphics)
	Gdip_DisposeImage(pBitmap1)
	Gdip_DisposeImage(pBitmap2)
	Return ImgLoc '\' Image3
}