class Imaging {
	__New() {
		This.loadAppImages()
	}
	loadAppImages() {
		This.Picture := Map()
		Loop Files, 'images\*.*' {
			Name := StrSplit(A_LoopFileName, '.')[1]
			This.Picture[Name] := A_LoopFileFullPath
		}
	}

	
}