class Image {
	__New() {
		This.Choose := Map()
		Loop Files, 'images\*.*' {
			Name := StrSplit(A_LoopFileName, '.')[1]
			This.Choose[Name] := A_LoopFileFullPath
		}
	}
}