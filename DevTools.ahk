#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <GuiEx\Gdip>

; Image to b64 from file
^!c:: { 
    P := Gdip_Startup()
    Try A_Clipboard := Gdip_EncodeBitmapTo64string(Gdip_CreateBitmapFromFile(FileGetSelectedPath()))
    Gdip_Shutdown(P)
}
; Image to b64 from clipboard
^!b:: { 
    P := Gdip_Startup()
    Try A_Clipboard := Gdip_EncodeBitmapTo64string(Gdip_CreateBitmapFromClipboard())
    Gdip_Shutdown(P)
}
; 
FileGetSelectedPath() {
    hwnd := WinActive("ahk_class CabinetWClass") ; Get active Explorer window
    if !hwnd
        hwnd := WinActive("ahk_class ExploreWClass") ; Handles older Explorer windows
    
    if hwnd
    {
        for window in ComObject("Shell.Application").Windows
        {
            if (window.hwnd == hwnd)
                return window.Document.FocusedItem.Path
        }
    }
    return ""
}
