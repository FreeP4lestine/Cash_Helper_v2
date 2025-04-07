;#Include shared\jxon.ahk
#Include shared\json.ahk
readJson(File := 'setting\setting.json', CatchVal := Map()) {
	Try {
		Data := FileRead(File)
		Data := JSON.Load(Data)
	} Catch {
		Data := CatchVal
	}
	Return Data
}
writeJson(Data, File := 'setting\setting.json', Indent := '`t') {
	Data := JSON.Dump(Data, 1)
	JS := FileOpen(File, 'w')
	JS.Write(Data)
	JS.Close()
}