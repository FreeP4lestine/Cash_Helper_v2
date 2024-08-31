readSymbols() {
	setting := readJson()
	If !setting['exAPI'] && !setting['exAPI'] := newAPIKey() {
		Return
	}
	url := "https://api.apilayer.com/exchangerates_data/symbols"
	whr := ComObject('WinHttp.WinHttpRequest.5.1')
	whr.Open('GET', url, False)
	whr.SetRequestHeader('apikey', setting['exAPI'])
	Try {
		whr.Send()
		Response := whr.ResponseText
	} Catch {
		Response := '{"success":false}'
	}
	exRate := Jxon_Load(&Response)
	writeJson(exRate, 'setting\currencySymbol.json')
}
readCurrencies() {
	mainList.Delete()
	setting := readJson()
	currencySymbol := readJson('setting\currencySymbol.json')
	currency := readJson('setting\currency.json')
	If !currencySymbol.Has('symbols') || !currency.Has('rates') {
		Return
	}
	For symbol, name in currencySymbol["symbols"] {
		R := mainList.Add(, symbol, name, Round(currency['rates'][symbol], setting['Rounder']))
		mainListCLV.Cell(A_Index, 1, '0xFFE6E6E6')
		mainListCLV.Cell(A_Index, 3,, '0xFF0000FF')
		mainListCLV.Row(A_Index, '0xFFFFFFFF')
	}
	mainList.Redraw()
	If currency['rates'].Has('USD') && currency['rates'].Has('TND')
		FormulaResult.Text := Round(currency['rates']['USD'] / currency['rates']['TND'], 3)
	Else {
		FormulaResult.Text := '1.000'
	}
	mainList.ModifyCol(1, 'AutoHdr')
	mainList.ModifyCol(2, 'AutoHdr')
	mainList.ModifyCol(3, 'AutoHdr')
}
updateCurrencies() {
	currencySymbol := readJson('setting\currencySymbol.json')
	currency := readJson('setting\currency.json')
	If Symbol.Value = '' || currency['rates'].Has(Symbol.Value) && 'Yes' != MsgBox(Symbol.Value ' already exist!`nUpdate it now?', 'Currency', 0x40 + 0x4) {
		Return
	}
	If Name.Value = '' {
		MsgBox('Name is required', 'Currency', 0x30)
		Return
	}
	If !IsNumber(ConvertF.Value) {
		MsgBox('Invalid convert factor', 'Currency', 0x30)
		Return
	}
	currencySymbol['symbols'][Symbol.Value] := Name.Value
	currency['rates'][Symbol.Value] := ConvertF.Value
	writeJson(currencySymbol, 'setting\currencySymbol.json')
	writeJson(currency, 'setting\currency.json')
	readCurrencies()
	MsgBox('Updated successfully!', 'Currency', 0x40)
}
showCurrentCurrency() {
	If !Row := mainList.GetNext() {
		Return
	}
	Sym := mainList.GetText(Row)
	currencySymbol := readJson('setting\currencySymbol.json')
	currency := readJson('setting\currency.json')
	If Sym = '' || !currencySymbol['symbols'].Has(Sym) || !currency['rates'].Has(Sym) {
		Symbol.Value := ''
		Name.Value := ''
		ConvertF.Value := ''
		Return
	}
	Symbol.Value := Sym
	Name.Value := currencySymbol['symbols'][Sym]
	setting := readJson()
	ConvertF.Value := Round(currency['rates'][Sym], setting['Rounder'])
}
deleteCurrency() {
	If !Row := mainList.GetNext() {
		Return
	}
	deleteCurrency := mainList.GetText(Row)
	currencySymbol := readJson('setting\currencySymbol.json')
	If currencySymbol['symbols'].Has(deleteCurrency) {
		currencySymbol['symbols'].Delete(deleteCurrency)
		writeJson(currencySymbol, 'setting\currencySymbol.json')
	}
	currency := readJson('setting\currency.json')
	If !currency['rates'].Has(deleteCurrency) {
		Return
	}
	currency['rates'].Delete(deleteCurrency)
	writeJson(currency, 'setting\currency.json')
	readCurrencies()
	showCurrentCurrency()
	MsgBox('Deleted successfully!', 'Currency', 0x40)
}
onlineUpdateCurrencies() {
	setting := readJson()
	If !ConnectedToInternet() {
		MsgBox('Internet connection required!', 'Currency', 0x30)
		Return
	}
	If setting['exAPI'] = '' && !newAPIKey() {
		Return
	}
	setting := readJson()
	currencySymbol := readJson('setting\currencySymbol.json')
	symbols := ''
	For symbol in currencySymbol['symbols'] {
		symbols .= (symbols = '' ? '' : ',') symbol
	}
	url := "https://api.apilayer.com/exchangerates_data/latest?symbols=" symbols "&base=TND"
	whr := ComObject('WinHttp.WinHttpRequest.5.1')
	whr.Open('GET', url, False)
	whr.SetRequestHeader('apikey', setting['exAPI'])
	Try {
		whr.Send()
		Response := whr.ResponseText
	} Catch {
		Response := '{"success":false}'
	}
	exRate := Jxon_Load(&Response)
	If !exRate.Has('success') || !exRate['success'] {
		MsgBox('Unable to return the exchange rate from server!`nThe following link copied to the clipboard`n`n' (A_Clipboard := url), 'Currency', 0x30)
		Return
	}
	writeJson(exRate, 'setting\currency.json')
	readCurrencies()
	showCurrentCurrency()
	setting['LatestCurrencyCheck'] := exRate['date']
	writeJson(setting)
	latestCurrencyCheck()
	MsgBox('Updated successfully!', 'Currency', 0x40)
}
latestCurrencyCheck() {
	setting := readJson()
	If setting['LatestCurrencyCheck'] != '' {
		LatestCheck.Text := 'Latest Check: ' setting['LatestCurrencyCheck']
	} Else {
		LatestCheck.Text := 'Latest Check: ' 'None'
	}
}
newAPIKey() {
	API := InputBox('Enter Exchange Rates Data API key', 'API', 'w400 h100')
	If API.Result != 'OK' || API.Value = '' {
		Return
	}
	setting := readJson()
	setting['exAPI'] := API.Value
	writeJson(setting)
	MsgBox(API.Value '`nis now the your new api key!', 'API', 0x40)
	Return API.Value
}
updateRoundValue() {
	setting := readJson()
	setting['Rounder'] := Rounder.Value ? Rounder.Value : 0
	writeJson(setting)
}
setDefaultCurrency() {
	currency := readJson('setting\currency.json')
	If Symbol.Value = '' || !currency.Has('rates') || !currency['rates'].Has(Symbol.Value) {
		MsgBox('Currency is not set!', 'No Currency', 0x30)
		Return
	}
	setting := readJson()
	setting['DisplayCurrency'] := Symbol.Value
	writeJson(setting)
	currencySymbol := readJson('setting\currencySymbol.json')
	MsgBox(currencySymbol['symbols'][Symbol.Value] ' is now the default currecny', 'Default Currency', 0x40)
}