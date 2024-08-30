checkBypass(Prompt := 0) {
	setting := readJson()
	If !setting.Has('Bypass') || !setting["Bypass"] {
		Key := InputBox('Enter a bypass key, make sure to remember it!', 'Bypass key', 'w400 h100', A_UserName)
		If Key.Result != 'OK' {
			Msgbox('The bypass key is required!', 'Bypass', 0x30)
			Return
		}
		setting["FirstUse"] := True
		setting["Bypass"] := Key.Value
		writeJson(setting)
	}
	If Prompt {
		Key := InputBox('Enter the bypass key', 'Bypass key', 'w400 h100')
		If Key.Result != 'OK' {
			Return
		}
		If Key.Value !== setting["Bypass"] {
			Msgbox('Wrong bypass key!', 'Bypass', 0x30)
			Return
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
updateAccount() {
	If createUsername.Value = '' {
		Msgbox('Username must not be empty!', 'Create', 0x30)
		Return
	}
	If createUsername.Value ~= '[^A-Za-z0-9_]' {
		Msgbox('A -> Z, a -> z, 0 -> 9 and _`nonly are allowed!', 'Create', 0x30)
		Return
	}
	usersetting := readJson(A_AppData '\Cash Helper\users.json')
	If flagDelete.Value {
		If !usersetting.Has('Registered') || !usersetting['Registered'].Has(createUsername.Value) {
			Msgbox('<' createUsername.Value '> does not exist!', 'Create', 0x30)
			Return
		}
		If 'Yes' != Msgbox('<' createUsername.Value '> will be deleted!`nConfirm?', 'Create', 0x40 + 0x4) {
			Return
		}
		usersetting['Registered'].Delete(createUsername.Value)
		writeJson(usersetting, A_AppData '\Cash Helper\users.json')
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
	If usersetting['Registered'].Has(createUsername.Value) {
		If 'Yes' != Msgbox('<' createUsername.Value '> already exist!`nWant to update it now?', 'Login', 0x40 + 0x4) {
			Return
		}
	}
	usersetting['Registered'][createUsername.Value] := Map()
	usersetting['Registered'][createUsername.Value]['Username'] := createUsername.Value
	usersetting['Registered'][createUsername.Value]['Password'] := createPassword.Value
	usersetting['Registered'][createUsername.Value]['b64Thumbnail'] := b64createThumbnail.Value
	usersetting['Registered'][createUsername.Value]['Autorization'] := Map()
	CR := 0
	While CR := createAutorisation.GetNext(CR, 'C') {
		usersetting['Registered'][createUsername.Value]['Autorization'][createAutorisation.GetText(CR)] := True
	}
	writeJson(usersetting, A_AppData '\Cash Helper\users.json')
	Msgbox('Profile updated!', 'Create')
}
pickThumbnail() {
	If b64createThumbnail.Value {
		b64createThumbnail.Value := ''
		createThumbnail.Value := 'images\Default.png'
		Return
	}
	Image := FileSelect(,, "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico;)")
	If !Image {
		Return
	}
	pToken := Gdip_Startup()
	b64createThumbnail.Value := b64ResizeImage(Image)
	createThumbnail.Value := 'HBITMAP:*' hBitmapFromB64(b64createThumbnail.Value)
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
	If !usersetting.Has('Registered') || !usersetting['Registered'].Has(createUsername.Value) {
		Return
	}
	pToken := Gdip_Startup()
	If hB := hBitmapFromB64(usersetting['Registered'][createUsername.Value]['b64Thumbnail']) {
		createThumbnail.Value := 'HBITMAP:*' hB
		b64createThumbnail.Value := usersetting['Registered'][createUsername.Value]['b64Thumbnail']
	}
	Gdip_Shutdown(pToken)
	If usersetting['Registered'][createUsername.Value].Has('Autorization') {
		Loop createAutorisation.GetCount() {
			Name := createAutorisation.GetText(A_Index)
			If usersetting['Registered'][createUsername.Value]['Autorization'].Has(Name) {
				createAutorisation.Modify(A_Index, 'Check')
			}
		}
	}
}
welcomeUpdateProfile() {
	setting := readJson()
	welcomeThumbnail.Value := 'images\Default.png'
	If setting['Bypass'] = bypassKey.Value {
		loginUsername.Value := 'Owner'
	} Else {
		pToken := Gdip_Startup()
		usersetting := readJson(A_AppData '\Cash Helper\users.json')
		If usersetting.Has('Registered') 
		&& usersetting['Registered'].Has(loginUsername.Value) 
		&& hB := hBitmapFromB64(usersetting['Registered'][loginUsername.Value]['b64Thumbnail']) {
			welcomeThumbnail.Value := 'HBITMAP:*' hB
		}
		Gdip_Shutdown(pToken)
	}
	welcomeAccountInfo.Value := loginUsername.Value 
	welcomeWindow.GetPos(,, &Width)
	welcomeThumbnail.Move(Width - 168)
	welcomeAccountInfo.Move(Width - 336)
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
	For Name, Handle in Managers {
		If !usersetting['Registered'][loginUsername.Value].Has('Autorization') || !usersetting['Registered'][loginUsername.Value]['Autorization'].Has(Name) {
			Handle.Enabled := False
		}
	}
}