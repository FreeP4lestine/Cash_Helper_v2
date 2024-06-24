UserTableGet(&Table) {
	If !DB.OpenDB(MainDB)
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	If !DB.GetTable("SELECT * FROM " UserTable ";", &Table)
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	If Type(Table) != 'SQLiteDB._Table' {
		Msgbox('Unable to login!`n`nInvalid data, make sure to run a clean installation of the app', 'Login failure!', 48)
		ExitApp
	}
}