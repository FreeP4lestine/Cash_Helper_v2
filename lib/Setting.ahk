#Include shared\jxon.ahk
readJson(File := 'setting\setting.json') {
	Try {
		Json := FileRead(File)
		Data := Jxon_Load(&Json)
	} Catch {
		Json := '{}'
		Data := Jxon_Load(&Json)
	}
	Return Data
}
writeJson(Json, File := 'setting\setting.json') {
	Json := Jxon_Dump(Json, '`t')
	JS := FileOpen(File, 'w')
	JS.Write(Json)
	JS.Close()
}