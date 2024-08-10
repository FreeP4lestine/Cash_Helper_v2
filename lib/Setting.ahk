class Setting {
	__New() {
		This.Workdir := A_AppData '\Cash Helper'
		If !DirExist(This.Workdir) {
			DirCreate(This.Workdir)
		}
		This.Configuration := This.Workdir '\Cash Helper.ini'
		This.Version := IniRead(This.Configuration, 'Setting', 'Version', '1.0')
		This.exAPI := IniRead(This.Configuration, 'Setting', 'exAPI', '')
		This.latestCurrencyCheck := IniRead(This.Configuration, 'Setting', 'latestCurrencyCheck', '')
		This.Title := 'Cash Helper v' This.Version
		This.createTitle := 'Manage account'
	}
	writeSetting(Key, Value) {
		IniWrite(Value, This.Configuration, 'Setting', Key)
	}
}