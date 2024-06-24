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
		Merged .= Merged = '' ? Array1[A_Index] '="' Array2[A_Index] '"' 
							  : ', ' Array1[A_Index] '="' Array2[A_Index] '"'
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