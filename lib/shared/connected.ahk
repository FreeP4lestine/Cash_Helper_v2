ConnectedToInternet(flag := 0x40) { 
    Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", flag,"Int",0) 
}