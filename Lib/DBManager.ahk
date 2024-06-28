#Include <SQLiteDB>
#Include <SQLError>

/*
Opens and creates an SQLite database
	Parameters:
	Filename -> The name of the file where to store the database
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
	DB -> The data base instance
*/
DBCloseTable(DB) {
	DB.CloseDB()
}

/*
Closes a table
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
	Columns -> The table columns
*/
DBCreateTable(Filename, Tablename, Columns) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('CREATE TABLE IF NOT EXISTS ' Tablename ' (' Columns ');')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}

/*
Reads a table
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
*/
DBReadTable(Filename, Tablename) {
	DB := DBOpenTable(Filename)
	Table := ''
	If !DB.GetTable("SELECT * FROM " Tablename ";", &Table)
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
	Return Table
}

/*
Inserts a row at the very end of the table with the default values
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
*/
DBInsertRowTable(Filename, Tablename) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('INSERT INTO ' Tablename ' DEFAULT VALUES;')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}

/*
Updates a row values
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
	NewValues -> The new values Column_Name=Value
	Row -> The row number to update
*/
DBUpdateRowTable(Filename, Tablename, NewValues, Row) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('UPDATE ' Tablename ' SET ' NewValues ' WHERE ROWID=' Row ';')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}

/*
Deletes a row
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
	Row -> The row number to delete
*/
DBDeleteRowTable(Filename, Tablename, Row) {
	DB := DBOpenTable(Filename)
	If !DB.Exec('DELETE FROM ' Tablename ' WHERE ROWID=' Row ';')
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}

/*
Deletes a table
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
*/
DBDeleteTable(Filename, Tablename) {
	DB := DBOpenTable(Filename)
	If !DB.Exec("DROP TABLE IF EXISTS " Tablename ";")
		SQLError(DB.ErrorMsg, DB.ErrorCode)
	DBCloseTable(DB)
}

/*
Verifys if the column names are correct
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
	Columns -> The table columns
*/
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

/*
Verifys the registered master key
	Parameters:
	Filename -> The name of the file where to store the database
	Tablename -> The table name
	Columns -> The table columns
*/
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