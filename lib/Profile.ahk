class Profile {
	__New() {
		This.appSetting := Setting()
		This.Configuration := This.appSetting.Configuration
		This.FirstUse := IniRead(This.Configuration, 'Setting', 'FirstUse', 0)
		This.Bypass := IniRead(This.Configuration, 'Setting', 'Bypass', 0)
		This.Thumbnail := ''
	}
	checkBypass(Prompt := 0) {
		If !This.Bypass {
			Key := InputBox('Enter a bypass key, make sure to remember it!', 'Bypass key', 'w400 h100', A_UserName)
			If Key.Result != 'OK' {
				Msgbox('The bypass key is required!', 'Bypass', 0x30)
				Return False
			}
			IniWrite(1, This.Configuration, 'Setting', 'FirstUse')
			IniWrite(This.Bypass := Key.Value, This.Configuration, 'Setting', 'Bypass')
		}
		If Prompt {
			Key := InputBox('Enter the bypass key', 'Bypass key', 'w400 h100')
			If Key.Result != 'OK' {
				Return False
			}
			If Key.Value !== This.Bypass {
				Msgbox('Wrong bypass key!', 'Bypass', 0x30)
				Return False
			}
		}
		Return True
	}
	checkRememberProfile() {
		If (!Inputs := StrSplit(IniRead(This.Configuration, 'Setting', 'Remember', ''), ',')) || Inputs.Length != 3 {
			Return
		}
		loginUsername.Value := Inputs.RemoveAt(1)
		loginPassword.Value := Inputs.RemoveAt(1)
		bypassKey.Value := Inputs.RemoveAt(1)
		loginRemember.Value := 1
		This.updateThumbnail()
	}
	profileExists(Name) {
		If DirExist(This.appSetting.Workdir '\' Name) || !FileExist(This.appSetting.Workdir '\' Name) {
			Return False
		}
		Profile := FileOpen(This.appSetting.Workdir '\' Name, 'r')
		ProfileInfo := Map()
		ProfileInfo.Username := Profile.ReadLine()
		ProfileInfo.Password := Profile.ReadLine()
		ProfileInfo.Thumbnail := Profile.ReadLine()
		Return ProfileInfo
	}
	submitAccount() {
		If This.Bypass = bypassKey.Value {
			saveLogins()
			Return True
		}
		If !Profile := This.profileExists(loginUsername.Value) {
			Msgbox('<' loginUsername.Value '> does not exist!', 'Login', 0x30)
			Return False
		}
		If Profile.Password !== loginPassword.Value {
			Msgbox('Incorrect password!', 'Login', 0x30)
			Return False
		}
		saveLogins()
		saveLogins() {
			If loginRemember.Value {
				IniWrite(loginUsername.Value
					 ',' loginPassword.Value
					 ',' bypassKey.Value, This.Configuration, 'Setting', 'Remember')
			} Else {
				If IniRead(This.Configuration, 'Setting', 'Remember', '') {
					IniDelete(This.Configuration, 'Setting', 'Remember')
				}
			}
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
		If flagDelete.Value {
			If !Profile := This.profileExists(createUsername.Value) {
				Msgbox('<' createUsername.Value '> does not exist!', 'Create', 0x30)
				Return
			}
			If 'Yes' != Msgbox('<' createUsername.Value '> will be deleted!`nConfirm?', 'Create', 0x40 + 0x4) {
				Return
			}
			FileDelete(This.appSetting.Workdir '\' createUsername.Value)
			Msgbox('Profile deleted!', 'Create')
			Return
		}
		If createPassword.Value = '' {
			Msgbox('Password must not be empty!', 'Create', 0x30)
			Return
		}
		If Profile := This.profileExists(createUsername.Value) {
			If 'Yes' != Msgbox('<' createUsername.Value '> already exist!`nWant to update it now?', 'Login', 0x40 + 0x4) {
				Return
			}
		}
		Obj := FileOpen(This.appSetting.Workdir '\' createUsername.Value, 'w')
		Obj.WriteLine(createUsername.Value)
		Obj.WriteLine(createPassword.Value)
		Obj.WriteLine(This.Thumbnail), This.Thumbnail := ''
		Obj.Close()
		This.updateThumbnail()
		Msgbox('Profile updated!', 'Create')
	}
	pickThumbnail() {
		Image := FileSelect(,, "Select an image:", "Images (*.bmp; *.jpg; *.jpeg; *.jpe; *.gif; *.png; *.ico;)")
		If !Image {
			Return
		}
		This.Thumbnail := appImage.b64ResizeImage(Image)
		createThumbnail.Value := 'HBITMAP:*' appImage.hBitmapFromB64(This.Thumbnail)
	}
	updateThumbnail() {
		If !Profile := This.profileExists(loginUsername.Value) {
			loginThumbnail.Value := appImage.Picture['Default']
			Return
		}
		Try {
			loginThumbnail.Value := 'HBITMAP:*' appImage.hBitmapFromB64(Profile.Thumbnail)
		}
	}
	createUpdateThumbnail() {
		If !Profile := This.profileExists(createUsername.Value) {
			createThumbnail.Value := appImage.Picture['Default']
			Return
		}
		Try {
			createThumbnail.Value := 'HBITMAP:*' appImage.hBitmapFromB64(Profile.Thumbnail)
		}
	}
	welcomeUpdateProfile() {
		If This.Bypass = bypassKey.Value {
			loginUsername.Value := 'Owner'
			welcomeThumbnail.Value := appImage.Picture['Default']
		} Else {
			Profile := This.profileExists(loginUsername.Value)
			welcomeThumbnail.Value := 'HBITMAP:*' appImage.hBitmapFromB64(Profile.Thumbnail)
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
	}
}