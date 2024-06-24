#Include <SQLiteDB>
#Include <SQLError>

/*
Opens and creates an SQLite database
	Parameters:
	Filename -> the name of the file where to store the database
*/
DBOpenTable(Filename) {
	DB := SQLiteDB()
	If !DB.OpenDB(Filename)
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	Return DB
}

/*
Closes an SQLite database
	Parameters:
	DB -> the data base instance created with <DBOpenTable>
*/
DBCloseTable(DB) {
	DB.CloseDB()
}

/*
Closes a table
	Parameters:
	DB -> the data base instance created with <DBOpenTable>
*/
DBCreateTable(Filename, Tablename, Columns) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('CREATE TABLE IF NOT EXISTS ' Tablename ' (' Columns ');')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}

DBReadTable(Filename, Tablename) {
	DB := DBOpenTable(Filename)
	Table := ''
	If !DB.GetTable("SELECT * FROM " Tablename ";", &Table)
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
	Return Table
}
DBInsertRowTable(Filename, Tablename) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('INSERT INTO ' Tablename ' DEFAULT VALUES;')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}
DBUpdateRowTable(Filename, Tablename, NewValues, Row) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('UPDATE ' Tablename ' SET ' NewValues ' WHERE ROWID=' Row ';')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}
DBDeleteRowTable(Filename, Tablename, Row) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('DELETE FROM ' Tablename ' WHERE ROWID=' Row ';')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}
DBDeleteTable(Filename, Tablename) {
	DB := DBOpenTable(Filename)
	If !DB.Exec("DROP TABLE IF EXISTS " UserTable ";")
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}
DBVerifyColumns(Filename, Tablename, Columns) {
	Table := DBReadTable(Filename, Tablename)
	FoundColumns := ''
	For Each, Col in Table.ColumnNames {
		FoundColumns .= FoundColumns = '' ? Col : ', ' Col
	}
	If Columns = FoundColumns {
		Return
	}
	DBDeleteTable(Filename, Tablename)
	DBCreateTable(Filename, Tablename, Columns)
}
DBVerifyMasterKey(Filename, Tablename, Columns) {
	Table := DBReadTable(Filename, Tablename)
	If !Table.RowCount || Table.RowCount < 1 || Table.ColumnCount < 2 || Table.Rows[1][2] != 'MasterKey' {
		DBDeleteTable(Filename, Tablename)
		DBCreateTable(Filename, Tablename, Columns)
		MasterKey := ''
		If 'Yes' != Msgbox('Create a master key?`nThe default will be your computer username!', 'Master key', 0x40 + 0x4) {
			MasterKey := A_Username
		} Else {
			Entered := InputBox('Please enter a master key below:', 'Master Key', 'w400 h100', A_Username)
			If Entered.Result != 'OK' || Entered.Value = '' {
				Msgbox('A master key is required', 'Master Key', 48)
				Reload
				Return
			}
			MasterKey := Entered.Value
		}
		Columns := StrSplit(Columns, ',')
		DBInsertRowTable(Filename, Tablename)
		DBUpdateRowTable(Filename, Tablename, Columns[2] '="MasterKey", ' Columns[3] '="' MasterKey '"', 1)
	}
}