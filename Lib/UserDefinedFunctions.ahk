; User defined function
/*
Creates specific length array with empty values
	Parameters:
	Length -> Array length
*/
CreateArray(Length) {
	Array := []
	Loop Length {
		Array.Push('')
	}
	Return Array
}

/*
Replaces all values in an array with empty ones
	Parameters:
	Array -> an array
*/
ClearArray(Array) {
	Loop Array.Length {
		Array[A_Index] := ''
	}
	Return Array
}

/*
Concatinates all values of an array
	Parameters:
	Array -> an array
	Delimiter -> Delimiter to seperate the values
	Quote -> Quote the values
*/
ArrayJoin(Array, Delimiter := ', ', Quote := '"') {
	Joined := ''
	For Each, Item in Array {
		JoinItem := Quote Item Quote
		If Delimiter = '' || Joined = '' {
			Joined .= JoinItem
		} Else {
			Joined .= Delimiter JoinItem
		}
	}
	Return Joined
}

/*
Analyzes and choses a certain slice from a value based on StrSplit() split
	Parameters:
	Array -> an array
	Index -> The index of the slice to keep
*/
ArrayItemSelectSlice(Array, Index := 2, Spliter := '#') {
	NewArray := []
	For Each, Item in Array {
		NewArray.Push(StrSplit(Item, Spliter)[Index])
	}
	Return NewArray
}

/*
Joins two same length arrays into one string
	Parameters:
	Array1 -> an array
	Array2 -> an array
	Delimiter -> Delimiter to seperate the values
	Quote -> Quote the values
*/
ArrayMerge(Array1 := [], Array2 := [], Delimiter := ', ', Quote := '"') {
	If Array1.Length != Array2.Length {
		Return Merged
	}
	Merged := ''
	Loop Array1.Length {
		JoinItem := Quote Array1[A_Index] Quote '=' Quote Array2[A_Index] Quote
		If Delimiter = '' || Merged = '' {
			Merged .= JoinItem
		} Else {
			Merged .= Delimiter JoinItem
		}
	}
	Return Merged
}

/*
Updates the listed values inside a ComboBox control
	Parameters:
	Ctrl -> ComboBox control
	Array -> an array
*/
UpdateComboBox(Ctrl, Array) {
	Ctrl.Delete()
	For Row, Col in Array {
		Ctrl.Add([Col[2]])
	}
}

/*
Checks if the master key equal to the user input
	Parameters:
	MasterKey -> The master key
*/
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

/*
Overlay Image1 by the Image2
	Parameters:
	Image1 -> Path to the image
	Image2 -> Path to the image
	ImgLoc -> Path where to save the result image
*/
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

/*
Adds a form to the GUI
	Parameters:
	GuiHandle -> Gui object
	Control -> Control definition
	Width -> Width of the form
*/
CreateForm(GuiHandle, Control, Width := 300) {
	TypeControl := StrSplit(Control, '#')
	GuiHandle.SetFont('s10', 'Calibri')
	T := GuiHandle.AddText('xm w' Width, TypeControl[2] ':')
	Switch TypeControl[1] {
		Case 'I' :
			C1 := GuiHandle.AddPicture('w64 h64')
			C2 := GuiHandle.AddButton('xp+200 yp', 'Logo Select')
			C2.SetFont('Bold', 'Calibri')
			CreateImageButton(C2, 0, IBBlack*)
			C3 := GuiHandle.AddButton('wp', 'X')
			C3.SetFont('Bold', 'Calibri')
			CreateImageButton(C3, 0, IBRed*)
			C := [C1, C2, C3]
		Case 'E' :
			GuiHandle.SetFont('s14', 'Calibri')
			C := GuiHandle.AddEdit('w' Width ' -E0x200 Border')
		Case 'C' :
			GuiHandle.SetFont('s14', 'Calibri')
			C := GuiHandle.AddComboBox('w' Width ' -E0x200 Border')
	}
	Return [T, C]
}

/*
Adjusts the a GUI to fit the screen
	Parameters:
	GuiHandle -> Gui object
	SizeW -> Maximum width
	SizeH -> Maximum height
*/
WindowSizeFix(GuiHandle, SizeW := A_ScreenWidth - 10, SizeH := A_ScreenHeight - 75) {
	GuiHandle.GetPos(&X, &Y, &W, &H)
	If X + W > SizeW {
		If W > SizeW {
			GuiHandle.Move(10,, SizeW)
		} Else {
			GuiHandle.Move(10)
		}
	}
	If Y + H > SizeH {
		If H > SizeH {
			GuiHandle.Move(, 5,, SizeH)
		} Else {
			GuiHandle.Move(, 5)
		}
	}
}

/*
Loads SQL items to the ListView and the TreeView
	Parameters:
	LoadLoc -> Items location
	ListView -> ListView object
	TreeView -> TreeView object
	Parent -> Name of the first parent in TreeView
*/
ChargeItems(LoadLoc, ListView, ListViewColors, TreeView, Parent := 'Items Tree View') {
	TreeView.Delete()
	ListView.Delete()
	TreeMap := Map()
	TreeMap[LoadLoc] := TreeView.Add(Parent,, 'Icon2')
	TreeView.Modify(TreeMap[LoadLoc], 'Bold')
	Loop Files, LoadLoc '\*', 'RD' {
		SubParent := A_LoopFileDir '\' A_LoopFileName
		If !TreeMap.Has(SubParent) {
			ID := TreeView.Add(A_LoopFileName, TreeMap[A_LoopFileDir], 'Icon2')
			TreeView.Modify(ID, 'Bold')
			TreeMap[SubParent] := ID
		}
	}
	FilesCount := 0
	Loop Files, LoadLoc '\' '*.Def', 'R' {
		FilesCount++
	}
	ProgressBar.Visible := True
	ProgressText.Visible := True
	ProgressBar.Value := 0
	ProgressBar.Opt('Range0-' FilesCount)
	For Parent, ID in TreeMap {
		AddToTheParent(Parent, ID)
	}
	Loop ListView.GetCount('Col') - 1
		ListView.ModifyCol(A_Index + 1, 'AutoHdr Center')
	ListView.Redraw()
	TreeView.Redraw()
	AddToTheParent(LoopDir, Parent) {
		Loop Files, LoopDir '\*.def' {
			ProgressBar.Value++
			ProgressText.Value := 'Loading ' LoopDir ' --> ' A_LoopFileName '...'
			TreeView.Add(A_LoopFileName, Parent, 'Icon3')
			SerilizedData := FileRead(A_LoopFileFullPath)
			SerilizedData := StrSplit(SerilizedData, ', ')
			SerilizedData := ArrayItemSelectSlice(SerilizedData,, '=')
			R := ListView.Add('Icon3', SerilizedData*)
			ListViewColors.Cell(R, 2, 0xFFE6E6E6)
			ListViewColors.Cell(R, 3,, 0xFF0000FF)
			ListViewColors.Cell(R, 4, 0xFFE6E6E6)
			ListViewColors.Cell(R, 6, 0xFFE6E6E6)
			ListViewColors.Cell(R, 8, 0xFFE6E6E6)
			ListViewColors.Cell(R, 9,, 0xFFFF0000)
			ListViewColors.Cell(R, 10,, 0xFF008000)
			ListViewColors.Cell(R, 11, 0xFFE6E6E6)
			ListViewColors.Cell(R, 13, 0xFFE6E6E6)
		}
	}
	ProgressBar.Visible := False
	ProgressText.Visible := False
}