ResizedB64Image(Image, Size) {
	B64 := ''
	Buff := ImagePutBuffer(Image)
	pBitmap := Buff.pBitmap
	If ImageWidth(Image) > ImageHeight(Image) {
		ImagePut.BitmapScale(&pBitmap, [Size[1], ""])
	} Else {
		ImagePut.BitmapScale(&pBitmap, ["", Size[2]])
	}
	B64 := ImagePutBase64(pBitmap)
	Return [B64, ImageWidth(pBitmap), ImageHeight(pBitmap)]
}