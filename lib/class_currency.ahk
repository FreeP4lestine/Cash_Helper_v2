class Currency {
	__New(SellCurrencyFile := 'setting\SellCurrency') {
		This.SellCurrencyNameFile := SellCurrencyFile
		This.SellCurrency := []
		This.SellCurrencyName := Map()
		This.Updates := []
	}
	getSellCurrency() {
		If FileExist(This.SellCurrencyNameFile) {
			O := FileOpen(This.SellCurrencyNameFile, 'r')
			While !O.AtEOF {
				Definition := StrSplit(O.ReadLine(), ';')
				This.SellCurrency.Push({Symbol: Definition[1], Name: Definition[2], ConvertFactor: Definition[3]})
				This.SellCurrencyName[Definition[1]] := {Name: Definition[2], ConvertFactor: Definition[3]}
			}
			This.ViewCurrency := 'TND'
		}
	}
	readCurrencies() {
		mainList.Delete()
		For Definition in This.SellCurrency {
			R := mainList.Add(, Definition.Symbol, Definition.Name, Definition.ConvertFactor)
			mainListCLV.Cell(A_Index, 1, '0xFFE6E6E6')
			mainListCLV.Cell(A_Index, 3,, '0xFF0000FF')
			mainListCLV.Row(A_Index, '0xFFFFFFFF')
		}
		For Update in This.Updates {
			mainListCLV.Row(Update, '0xFFFFC080')
		}
		mainList.Redraw()
		FormulaResult.Text := This.SellCurrencyName.Has('USD') && This.SellCurrencyName.Has('TND') ? Round(This.SellCurrencyName['USD'].ConvertFactor / This.SellCurrencyName['TND'].ConvertFactor, 3) : '1.000'
		mainList.ModifyCol(1, 'AutoHdr')
		mainList.ModifyCol(2, 'AutoHdr')
		mainList.ModifyCol(3, 'AutoHdr')
	}
	updateCurrencies() {
		If Symbol.Value = '' || This.SellCurrencyName.Has(Symbol.Value) && 'Yes' != MsgBox(Symbol.Value ' already exist!`nUpdate it now?', 'Currency', 0x40 + 0x4) {
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
		Updated := False
		For Currency in This.SellCurrency {
			If Currency.Symbol = Symbol.Value {
				This.SellCurrency[A_Index] := {Symbol: Symbol.Value, Name: Name.Value, ConvertFactor: ConvertF.Value}
				Updated := True
			}
		}
		If !Updated {
			This.SellCurrency.Push({Symbol: Symbol.Value, Name: Name.Value, ConvertFactor: ConvertF.Value})
		}
		O := FileOpen(This.SellCurrencyNameFile, 'w')
		For Currency in This.SellCurrency {
			O.WriteLine(Currency.Symbol ';' Currency.Name ';' Currency.ConvertFactor)
		}
		O.Close()
		This.SellCurrencyName[Symbol.Value] := {Name: Name.Value, ConvertFactor: ConvertF.Value}
		This.readCurrencies()
		MsgBox('Updated successfully!', 'Currency', 0x40)
	}
	showCurrentCurrency(Currency := '') {
		If Currency = '' || !This.SellCurrencyName.Has(Currency) {
			Symbol.Value := ''
			Name.Value := ''
			ConvertF.Value := ''
			Return
		}
		Symbol.Value := Currency
		Name.Value := This.SellCurrencyName[Currency].Name
		ConvertF.Value := This.SellCurrencyName[Currency].ConvertFactor
	}
	deleteCurrencies() {
		If !Row := mainList.GetNext() {
			Return
		}
		deleteCurrency := mainList.GetText(Row)
		For Currency in This.SellCurrency {
			If Currency.Symbol = deleteCurrency {
				This.SellCurrency.RemoveAt(A_Index)
			}
		}
		O := FileOpen(This.SellCurrencyNameFile, 'w')
		For Currency in This.SellCurrency {
			O.WriteLine(Currency.Symbol ';' Currency.Name ';' Currency.ConvertFactor)
		}
		O.Close()
		This.SellCurrencyName.Delete(deleteCurrency)
		This.readCurrencies()
		This.showCurrentCurrency()
		MsgBox('Deleted successfully!', 'Currency', 0x40)
	}
	onlineUpdateCurrencies() {
		If !ConnectedToInternet() {
			MsgBox('Internet connection required!', 'Currency', 0x30)
			Return
		}
		If appSetting.exAPI = '' {
			API := InputBox('Exchange Rates Data API key is required!', 'API', 'w400 h100')
			If API.Result != 'OK' || API.Value = '' {
				Return
			}
			appSetting.writeSetting('exAPI', appSetting.exAPI := API.Value)
		}
		symbols := ''
		For Currency in This.SellCurrency {
			If Currency.Symbol ~= 'TND|TNM' {
				Continue
			}
			symbols .= symbols = '' ? Currency.Symbol : ',' Currency.Symbol
		}
		url := "https://api.apilayer.com/exchangerates_data/latest?symbols=" symbols "&base=TND"
		whr := ComObject('WinHttp.WinHttpRequest.5.1')
		whr.Open('GET', url, False)
		whr.SetRequestHeader('apikey', appSetting.exAPI)
		Try {
			whr.Send()
			Response := whr.ResponseText
		} Catch {
			Response := '{"success":false}'
		}
		exRate := Jxon_Load(&Response)
		If !exRate['success'] {
			If 'Yes' != MsgBox('Unable to return the exchange rate from server!`nThe following link copied to the clipboard`n`n' (A_Clipboard := url) '`n`nContinue?', 'Currency', 0x30 + 0x4) {
				Return
			}
		}
		This.Updates := []
		For Currency in This.SellCurrency {
			If Currency.Symbol ~= 'TND|TNM' {
				Continue
			}
			exChange := Round(exRate['rates'][Currency.Symbol], 3)
			prevExChange := Currency.ConvertFactor
			This.SellCurrency[A_Index].ConvertFactor := exChange
			This.SellCurrencyName[Currency.Symbol].ConvertFactor := This.SellCurrency[A_Index].ConvertFactor
			If prevExChange != exChange {
				This.Updates.Push(A_Index)
			}
		}
		whr := 0
		O := FileOpen(This.SellCurrencyNameFile, 'w')
		For Currency in This.SellCurrency {
			O.WriteLine(Currency.Symbol ';' Currency.Name ';' Currency.ConvertFactor)
		}
		O.Close()
		This.readCurrencies()
		This.showCurrentCurrency()
		appSetting.writeSetting('latestCurrencyCheck', appSetting.latestCurrencyCheck := exRate['date'])
		This.latestCurrencyCheck()
		MsgBox('Updated successfully!', 'Currency', 0x40)
	}
	latestCurrencyCheck() {
		If appSetting.latestCurrencyCheck != '' {
			LatestCheck.Text := 'Latest Check: ' appSetting.latestCurrencyCheck
		} Else {
			LatestCheck.Text := 'Latest Check: ' 'None'
		}
	}
	newAPIKey() {
		API := InputBox('Enter Exchange Rates Data API key', 'API', 'w400 h100')
		If API.Result != 'OK' || API.Value = '' {
			Return
		}
		appSetting.writeSetting('exAPI', appSetting.exAPI := API.Value)
		MsgBox(appSetting.exAPI '`nis now the your new api key!', 'API', 0x40)
	}
	updateRoundValue() {
		appSetting.writeSetting('Rounder', Rounder.Value ? Rounder.Value : 0)
	}
	setDefaultCurrency() {
		If !This.SellCurrencyName.Has(Symbol.Value) {
			MsgBox('Currency is not set!', 'No Currency', 0x30)
			Return
		}
		appSetting.writeSetting('Currency', Symbol.Value)
		MsgBox(This.SellCurrencyName[Symbol.Value].Name ' is now the default currecny', 'Default Currency', 0x40)
	}
}
