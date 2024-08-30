SetExplorerTheme(handle) {
	if (DllCall("kernel32\GetVersion", "uchar") > 5) {
		VarSetStrCapacity(&ClassName, 1024)
		if (DllCall("user32\GetClassName", "ptr", handle, "str", ClassName, "int", 512, "int")) {
			if (ClassName = "SysListView32") || (ClassName = "SysTreeView32")
				return !DllCall("uxtheme\SetWindowTheme", "ptr", handle, "str", "Explorer", "ptr", 0)
		}
	}
	return false
}