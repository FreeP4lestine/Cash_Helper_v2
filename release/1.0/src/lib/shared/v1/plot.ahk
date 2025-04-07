#Requires AutoHotkey v1
#SingleInstance, Force
#Include, lib\shared\v1\gdip.ahk
#Include, lib\shared\v1\chart.ahk
SetBatchLines, -1
OnExit(Func("Gdip_Shutdown").bind(Gdip_Startup()))
ControlGetText, CSP, Edit1, % "ahk_id " A_Args[1]
CSP := StrSplit(CSP, ",")
chart := chart(hwnd, "Doughnut")
chart.width := 300
chart.height := 300
chart.title("Over all cost, sell, and profit resume")
data := CSP
chart.data(data, { labels: "Cost: " Round(CSP[1], 3) " TND |,Sell: " Round(CSP[2], 3) " TND |,Profit: " Round(CSP[3], 3) " TND |"
                 , colors: [0xFF4747, 0xA600, 0xFF] })
pToken := Gdip_Startup()
pbm := Gdip_CreateBitmap(chart.width, chart.height)
pg := Gdip_GraphicsFromImage(pbm)
chart.render(pg)
Msgbox % HB := Gdip_CreateHBITMAPFromBitmap(pbm)
ControlSetText, Edit1, % pbm, % "ahk_id " A_Args[1]
Pause
;ptoken := Gdip_Startup()
;chart.save(A_Desktop "\chat.png", 5000, 2000)
;Gdip_Shutdown(ptoken)

;OnMessage(0x200, "onHover") ; WM_MOUSEMOVE
;
;onHover(wparam, lparam, msg, hwnd) {
;    global chart
;    MouseGetPos,,,, hwnd, 2
;    if (chart.hwnd == hwnd) {
;        VarSetCapacity(pt, 8, 0)
;        DllCall("GetCursorPos", "ptr",&pt)
;        DllCall("ScreenToClient", "ptr",hwnd, "ptr",&pt)
;        ToolTip % chart.at(NumGet(pt, 0, "int"), NumGet(pt, 4, "int"))
;    }
;}