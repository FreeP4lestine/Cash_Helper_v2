Print() {
    Static Sumatra := 'sumatra\SumatraPDF32.exe'
    html .= "<html><head><style>"
    html .= "table, td {border: 1px solid black;border-collapse: collapse;}"
    html .= "</style></head><body><table>"
    html .= "<tr>"
    Loop 15
        html .= "<td style='width: 250px'>" A_Index "</td>"
    html .= "</tr>"
    html .= "</table></body></html>"
    If FileExist(A_ScriptDir "\test123.html")
        filedelete A_ScriptDir "\test123.html"
    fileappend html, A_ScriptDir "\test123.html"
}
Print()