class AddCheckBox {
	__New(GuiObj, Width := '', Height := '', Option := '', Text := '', Check := 0) {
		This.Box := GuiObj.AddPicture('w' Height ' h' Height)
		This.Text := GuiObj.AddText('xp+' (Height + 5) ' yp w' Width ' h' Height)
		This.Value := Check
	}
	Toggle() {
		If Check := !Check {
			
		} Else {

		}
	}
}