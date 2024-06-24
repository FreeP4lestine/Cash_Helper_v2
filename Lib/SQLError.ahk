SQLError(ErrorMessage, ErrorCose) {
	If 'Yes' = MsgBox("Msg:`t" . ErrorMessage . "`nCode:`t" . ErrorCose "`n`nQuit?", "SQLite Error", 0x10 + 0x4)
	ExitApp
}