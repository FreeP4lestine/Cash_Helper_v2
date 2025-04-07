checkBypass(Prompt := 0) {
	setting := readJson()
	If !setting.Has('Bypass') || !setting["Bypass"] {
		Key := InputBox('Enter a bypass key, make sure to remember it!', 'Bypass key', 'w400 h100', A_UserName)
		If Key.Result != 'OK' {
			Msgbox('The bypass key is required!', 'Bypass', 0x30)
			Return False
		}
		setting["FirstUse"] := True
		setting["Bypass"] := Key.Value
		writeJson(setting)
	}
	If Prompt {
		Key := InputBox('Enter the bypass key', 'Bypass key', 'w400 h100')
		If Key.Result != 'OK' {
			Return False
		}
		If Key.Value !== setting["Bypass"] {
			Msgbox('Wrong bypass key!', 'Bypass', 0x30)
			Return False
		}
	}
	Return True
}
checkRememberProfile() {
	usersetting := readJson(A_AppData '\Cash Helper\users.json')
	If usersetting.Has('Remember') {
		loginUsername.Value := usersetting['Remember']['Username']
		loginPassword.Value := usersetting['Remember']['Password']
		bypassKey.Value := usersetting['Remember']['bypassKey']
		updateThumbnail()
		loginRemember.Value := 1
	}
}
submitAccount() {
	setting := readJson()
	If setting["Bypass"] = bypassKey.Value {
		saveLogins()
		Return True
	}
	usersetting := readJson(A_AppData '\Cash Helper\users.json')
	If !usersetting.Has('Registered') || !usersetting['Registered'].Has(loginUsername.Value) {
		Msgbox('<' loginUsername.Value '> does not exist!', 'Login', 0x30)
		Return
	}
	If usersetting['Registered'][loginUsername.Value]['Password'] !== loginPassword.Value {
		Msgbox('Incorrect password!', 'Login', 0x30)
		Return
	}
	saveLogins()
	saveLogins() {
		usersetting := readJson(A_AppData '\Cash Helper\users.json')
		If !loginRemember.Value {
			If usersetting.Has('Remember') {
				usersetting.Delete('Remember')
			}
		} Else {
			usersetting['Remember'] := Map()
			usersetting['Remember']['Username'] := loginUsername.Value
			usersetting['Remember']['Password'] := loginPassword.Value
			usersetting['Remember']['bypassKey'] := bypassKey.Value
		}
		writeJson(usersetting, A_AppData '\Cash Helper\users.json')
	}
	Return True
}

viewInfo() {
	For Edit in MyInfoHandle {
		If A_Index = 2
			Continue
		Edit.Value := ''
	}
	spaceLogo.Value := 'images\Default.png'
	If MyInfo.Length && MyInfo[2] = MyInfoHandle[2].Value {
		For Edit in MyInfoHandle {
			If A_Index = 2
				Continue
			Edit.Value := MyInfo[A_Index]
		}
		pToken := Gdip_Startup()
		If hB := hBitmapFromB64(MyInfo[1]) {
			spaceLogo.Value := 'HBITMAP:*' hB
		}
		Gdip_Shutdown(pToken)
		Return
	}
	For Client, Info in ClientInfo {
		If Client = MyInfoHandle[2].Value {
			For Edit in MyInfoHandle {
				If A_Index = 2
					Continue
				Edit.Value := Info[A_Index]
			}
			pToken := Gdip_Startup()
			If hB := hBitmapFromB64(Info[1]) {
				spaceLogo.Value := 'HBITMAP:*' hB
			}
			Gdip_Shutdown(pToken)
			Return
		}
	}
}

updateMyInfo(Client := 0) {
	Switch Client {
		Case 0:
			MyInfo := []
			For Property in MyInfoHandle {
				FormValue := Property.Value
				MyInfo.Push(FormValue)
			}
			writeJson(MyInfo, A_AppData '\Cash Helper\myinfo.json')
			Msgbox('Personal info updated!', setting['Name'], 0x40)
		Case 1:
			Switch flagDelete.Value {
				Case 0:
					ClientInfo[MyInfoHandle[2].Value] := []
					For Property in MyInfoHandle {
						FormValue := Property.Value
						ClientInfo[MyInfoHandle[2].Value].Push(FormValue)
					}
				Case 1:
					If ClientInfo.Has(MyInfoHandle[2].Value) {
						ClientInfo.Delete(MyInfoHandle[2].Value)
					}
			}
			writeJson(ClientInfo, A_AppData '\Cash Helper\client.json')
			Msgbox('Client info updated!', setting['Name'], 0x40)
	}

}

updateAccount() {
	If createUsername.Text = '' {
		Msgbox('Username must not be empty!', 'Create', 0x30)
		Return
	}
	If createUsername.Text ~= '[^A-Za-z0-9_]' {
		Msgbox('A -> Z, a -> z, 0 -> 9 and _`nonly are allowed!', 'Create', 0x30)
		Return
	}
	usersetting := readJson(A_AppData '\Cash Helper\users.json')
	If flagDelete.Value {
		If !usersetting.Has('Registered') || !usersetting['Registered'].Has(createUsername.Text) {
			Msgbox('<' createUsername.Text '> does not exist!', 'Create', 0x30)
			Return
		}
		If 'Yes' != Msgbox('<' createUsername.Text '> will be deleted!`nConfirm?', 'Create', 0x40 + 0x4) {
			Return
		}
		usersetting['Registered'].Delete(createUsername.Text)
		writeJson(usersetting, A_AppData '\Cash Helper\users.json')
		createUsername.PopulateWithUsers()
		Msgbox('Profile deleted!', 'Create')
		Return
	}
	If createPassword.Value = '' {
		Msgbox('Password must not be empty!', 'Create', 0x30)
		Return
	}
	If !usersetting.Has('Registered') {
		usersetting['Registered'] := Map()
	}
	If usersetting['Registered'].Has(createUsername.Text) {
		If 'Yes' != Msgbox('<' createUsername.Text '> already exist!`nWant to update it now?', 'Login', 0x40 + 0x4) {
			Return
		}
	}
	usersetting['Registered'][createUsername.Text] := Map()
	usersetting['Registered'][createUsername.Text]['Username'] := createUsername.Text
	usersetting['Registered'][createUsername.Text]['Password'] := createPassword.Value
	usersetting['Registered'][createUsername.Text]['b64Thumbnail'] := b64createThumbnail.Value
	usersetting['Registered'][createUsername.Text]['Autorization'] := Map()
	CR := 0
	While CR := createAutorisation.GetNext(CR, 'C') {
		usersetting['Registered'][createUsername.Text]['Autorization'][createAutorisation.GetText(CR)] := True
	}
	writeJson(usersetting, A_AppData '\Cash Helper\users.json')
	createUsername.PopulateWithUsers()
	Msgbox('Account updated!', setting['Name'], 0x40)
}
pickThumbnail(ImageCtrl, EditCtrl) {
	If EditCtrl.Value {
		EditCtrl.Value := ''
		ImageCtrl.Value := 'images\Default.png'
		Return
	}
	Image := FileSelect(, , "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico;)")
	If !Image {
		Return
	}
	pToken := Gdip_Startup()
	EditCtrl.Value := b64ResizeImage(Image)
	ImageCtrl.Value := 'HBITMAP:*' hBitmapFromB64(EditCtrl.Value)
	Gdip_Shutdown(pToken)
}
updateThumbnail() {
	usersetting := readJson(A_AppData '\Cash Helper\users.json')
	If !usersetting.Has('Registered') || !usersetting['Registered'].Has(loginUsername.Value) {
		loginThumbnail.Value := 'images\Default.png'
		Return
	}
	pToken := Gdip_Startup()
	If hB := hBitmapFromB64(usersetting['Registered'][loginUsername.Value]['b64Thumbnail']) {
		loginThumbnail.Value := 'HBITMAP:*' hB
	}
	Gdip_Shutdown(pToken)
}
createUpdateThumbnail() {
	Loop createAutorisation.GetCount()
		createAutorisation.Modify(A_Index, '-Check')
	createThumbnail.Value := 'images\Default.png'
	b64createThumbnail.Value := ''
	usersetting := readJson(A_AppData '\Cash Helper\users.json')
	If !usersetting.Has('Registered') || !usersetting['Registered'].Has(createUsername.Text) {
		Return
	}
	pToken := Gdip_Startup()
	If hB := hBitmapFromB64(usersetting['Registered'][createUsername.Text]['b64Thumbnail']) {
		createThumbnail.Value := 'HBITMAP:*' hB
		b64createThumbnail.Value := usersetting['Registered'][createUsername.Text]['b64Thumbnail']
	}
	Gdip_Shutdown(pToken)
	createPassword.Text := usersetting['Registered'][createUsername.Text]['Password']
	If usersetting['Registered'][createUsername.Text].Has('Autorization') {
		Loop createAutorisation.GetCount() {
			Name := createAutorisation.GetText(A_Index)
			If usersetting['Registered'][createUsername.Text]['Autorization'].Has(Name) {
				createAutorisation.Modify(A_Index, 'Check')
			}
		}
		createAutorisation.Redraw()
	}
}
welcomeUpdateProfile() {
	setting := readJson()
	welcomeThumbnail.Value := 'images\Default.png'
	If setting['Bypass'] = bypassKey.Value {
		loginUsername.Value := 'Owner'
	} Else {
		usersetting := readJson(A_AppData '\Cash Helper\users.json')
		If usersetting.Has('Registered')
			&& usersetting['Registered'].Has(loginUsername.Value)
			&& hB := hBitmapFromB64(usersetting['Registered'][loginUsername.Value]['b64Thumbnail']) {
				welcomeThumbnail.Value := 'HBITMAP:*' hB
		}
	}
	welcomeAccountInfo.Value := loginUsername.Value
	;welcomeWindow.GetPos(, , &Width)
	;welcomeThumbnail.Move(Width - 168)
	;welcomeAccountInfo.Move(Width - 336)
	StartTime := A_TickCount
	SetTimer(UpdateMetaInfo, 1000)
	UpdateMetaInfo() {
		;CurrentDate := FormatTime(A_Now, "dd/MM/yyyy (MMMM)")
		;CurrentTime := FormatTime(A_Now, "HH : mm : ss")
		Elapsed := ElapsedTime(A_TickCount - StartTime)
		welcomeMetaInfo.Text := Elapsed
		;SB.SetText('`tCurrent Date: ' CurrentDate, 1)
		;SB.SetText('`tCurrent Time: ' CurrentTime, 2)
		;SB.SetText('`tElapsed Time: ' Elapsed, 3)
		ElapsedTime(PassedTime) {
			Seconds := Format('{:02}', Mod(PassedTime // 1000, 60))
			Minutes := Format('{:02}', Mod(PassedTime // 1000 // 60, 60))
			Hours := Format('{:02}', Mod(PassedTime // 1000 // 60 // 60, 60))
			Days := Hours // 24
			Return Days ' : ' Hours ' : ' Minutes ' : ' Seconds
		}
	}
	; Autorization
	If setting['Bypass'] = bypassKey.Value {
		Return
	}
	Autorizations := ''
	For Each, Name in setting['Managers'] {
		If !usersetting['Registered'][loginUsername.Value].Has('Autorization') || !usersetting['Registered'][loginUsername.Value]['Autorization'].Has(Name) {
			Managers[Name].Enabled := False
			Continue
		}
		Autorizations .= (Autorizations = '' ? '' : '`n') Name
	}
	welcomeAccountInfo.Value .= '`n------`n' Autorizations
}

checkAppIntegrity() {
	DirsTree := ['commit\archived'
			   , 'commit\pending\later'
			   , 'invoice'
			   , 'setting\defs\corrupted'
			   , 'setting\sessions']
	For Dir in DirsTree {
		If !DirExist(Dir) {
			DirCreate(Dir)
		}
	}
	;---
	pToken := Gdip_Startup()
	Loop Files, 'setting\defs\*.json' {
		ItemDef := readJson(A_LoopFileFullPath)
		Modified := False
		For Prop in setting['Item'] {
			Prop := Prop[1]
			If !ItemDef.Has(Prop) {
				ItemDef[Prop] := ''
			}
			Switch Prop {
				Case 'Code':
					If ItemDef[Prop] = '' {
						FileMove(A_LoopFileFullPath, 'setting\defs\corrupted\')
						Continue
					}
				Case 'Name':
					If ItemDef[Prop] = '' {
						ItemDef[Prop] := 'NoName'
						Modified := True
					}
				Case 'Thumbnail', 'Code128':
					If ItemDef[Prop] != '' {
						If !hBitmapFromB64(ItemDef[Prop]) {
							ItemDef[Prop] := ''
							Modified := True
						}
					}
				Case 'Currency':
					If ItemDef[Prop] = '' {
						ItemDef[Prop] := 'TND'
						Modified := True
					}
				Case 'Sell Method':
					If ItemDef[Prop] = '' {
						ItemDef[Prop] := 'Piece (P)'
						Modified := True
					}
				Case 'Sell Amount':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := 1
						Modified := True
					}
				Case 'Buy Value':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := 0
						Modified := True
					}
				Case 'Sell Value':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := 0
						Modified := True
					}
				Case 'Profit Value':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := ItemDef['Sell Value'] - ItemDef['Buy Value']
						Modified := True
					}
				Case 'Profit Percent':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := Round(ItemDef['Profit Value'] / ItemDef['Buy Value'] * 100, 2)
						Modified := True
					}
				Case 'Stock Value':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := 0
						Modified := True
					}
				Case 'Added Value':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := 0
						Modified := True
					}
				Case 'Discount Value':
					If ItemDef[Prop] = '' || !IsNumber(ItemDef[Prop]) {
						ItemDef[Prop] := 0
						Modified := True
					}
				Case 'Related':
					If ItemDef[Prop] != '' && !FileExist('setting\defs\' ItemDef[Prop]) {
						ItemDef[Prop] := ''
						Modified := True
					}
			}
		}
		If Modified {
			writeJson(ItemDef, A_LoopFileFullPath)
		}
	}
	Gdip_Shutdown(pToken)
	Loop Files, 'commit\*', 'D' {
		Location := A_LoopFileName
		Loop Files, 'commit\' Location '\*.json', 'R' {
			Items := readJson(A_LoopFileFullPath)
			Modified := False
			For Item in Items['Items'] {
				If Item.Length = 11 {
					Item.Push(0)
					Modified := True
				}
			}
			If Modified {
				writeJson(Items, A_LoopFileFullPath)
			}
		}
	}
	
}
