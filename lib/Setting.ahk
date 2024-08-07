class Setting {
	__New() {
		This.Workdir := A_AppData '\Cash Helper'
		If !DirExist(This.Workdir) {
			DirCreate(This.Workdir)
		}
		This.Configuration := This.Workdir '\' StrReplace(A_ScriptName, 'ahk', 'ini')
		This.Version := IniRead(This.Configuration, 'Setting', 'Version', '1.0')
		This.Title := 'Cash Helper v' This.Version
		This.createTitle := 'Manage account'
	}
}