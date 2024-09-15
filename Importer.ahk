#Requires AutoHotkey v2
#SingleInstance Force
#Include <setting>
setting := readJson()
G := Gui(, 'Import old definitions')
G.OnEvent('Close', (*) => ExitApp())
srcFolder := G.AddEdit('ReadOnly w300')
choosesrcFolder := G.AddButton('xp+310 yp-1', 'Browse')
choosesrcFolder.OnEvent('Click', (*) => srcFolder.Value := FileSelect('D'))
destFolder := G.AddEdit('xm ReadOnly w300')
choosedestFolder := G.AddButton('xp+310 yp-1', 'Browse')
choosedestFolder.OnEvent('Click', (*) => destFolder.Value := FileSelect('D'))
item := G.AddRadio('xm', 'Item')
item.OnEvent('Click', (*) => destFolder.Value := 'setting\defs')
sell := G.AddRadio('yp', 'Submitted sells')
sell.OnEvent('Click', (*) => destFolder.Value := 'commit\archived')
Nsell := G.AddRadio('yp', 'Non Submitted sells')
Nsell.OnEvent('Click', (*) => destFolder.Value := 'commit\pending')
import := G.AddButton('xm w300', 'Import')
import.OnEvent('Click', importData)
importPB := G.AddProgress('xm w300')
G.Show()
importData(Ctrl, Info) {
    Ctrl.Enabled := False
    If item.Value {
        formatContentItem(Name, Content) {
            Code := SubStr(Name, 1, -4)
            If FileExist(destFolder.Value '\' Code '.json') {
                Return True
            }
            item := Map()
            For Property in setting['Item'] {
                item[Property[1]] := ''
            }
            item['Code'] := Code
            item['Name'] := Content[1]
            item['Currency'] := 'TND'
            item['Sell Method'] := 'Piece (P)'
            item['Sell Amount'] := 1
            item['Buy Value'] := Round(Content[2] / 1000, 3)
            item['Sell Value'] := Round(Content[3] / 1000, 3)
            item['Profit Value'] := Round(item['Sell Value'] - item['Buy Value'], 3)
            item['Profit Percent'] := Round(item['Profit Value'] / item['Buy Value'] * 100, 2)
            item['Stock Value'] := Content[4]
            writeJson(item, destFolder.Value '\' Code '.json')
            Return True
        }
        Counted := 0
        Loop Files, srcFolder.Value '\*.def'
            ++Counted
        importPB.Opt('range1-' Counted)
        importPB.Value := 0
        Loop Files, srcFolder.Value '\*.def' {
            Content := StrSplit(FileRead(A_LoopFileFullPath), ';')
            Try {
                rc := formatContentItem(A_LoopFileName, Content)
                If !rc
                    Break
            } Catch {
                FileAppend('Item | ' A_LoopFileFullPath '`n', 'importerrors.txt')
            }
            importPB.Value++
        }
    }
    If sell.Value {
        formatContentSell(SubDir, Name, Content) {
            date := SubStr(Name, 1, -5)
            If !DirExist(destFolder.Value '\' SubDir)
                DirCreate(destFolder.Value '\' SubDir)
            If FileExist(destFolder.Value '\' SubDir '\' date '.json') {
                Return True
            }
            username := Content.RemoveAt(1)
            username := StrSplit(username, '|')
            If username.Length = 2
                username := username[1]
            Else username := ''
            session := Map()
            session['OpenTime'] := date
            session['CommitTime'] := date
            If username
                session['Username'] := username
            session['Items'] := []
            data := Content.RemoveAt(1)
            data := StrSplit(data, '|')
            For Index, Info in data {
                session['Items'].Push([])
                itemdata := StrSplit(Info, ';')
                session['Items'][Index].Push('')
                session['Items'][Index].Push(itemdata[1])
                session['Items'][Index].Push(itemdata[2])
                session['Items'][Index].Push(Round(StrSplit(itemdata[5], 'x')[1] / 1000, 3))
                session['Items'][Index].Push(Round(StrSplit(itemdata[3], 'x')[1] / 1000, 3))
                session['Items'][Index].Push('1')
                session['Items'][Index].Push(StrSplit(itemdata[3], 'x')[2])
                session['Items'][Index].Push('P')
                session['Items'][Index].Push(0)
                session['Items'][Index].Push(Round(itemdata[4] / 1000, 3))
                session['Items'][Index].Push('TND')
            }
            writeJson(session, destFolder.Value '\' SubDir '\' date '.json')
            Return True
        }
        Counted := 0
        Loop Files, srcFolder.Value '\*.sell', 'R'
            ++Counted
        importPB.Opt('range1-' Counted)
        importPB.Value := 0
        Loop Files, srcFolder.Value '\*', 'D' {
            dir := A_LoopFileName
            Loop Files, srcFolder.Value '\' dir '\*.sell' {
                Content := StrSplit(FileRead(A_LoopFileFullPath), '> ')
                Try {
                    rc := formatContentSell(dir, A_LoopFileName, Content)
                    If !rc
                        Break
                } Catch {
                    FileAppend('Submitted | ' A_LoopFileFullPath '`n', 'importerrors.txt')
                }
                importPB.Value++
            }
        }
    }
    If Nsell.Value {
        formatContentNSell(Name, Content) {
            date := SubStr(Name, 1, -5)
            If FileExist(destFolder.Value '\' date '.json') {
                Return True
            }
            username := Content.RemoveAt(1)
            username := StrSplit(username, '|')
            If username.Length = 2
                username := username[1]
            Else username := ''
            session := Map()
            session['OpenTime'] := date
            session['CommitTime'] := date
            If username
                session['Username'] := username
            session['Items'] := []
            data := Content.RemoveAt(1)
            data := StrSplit(data, '|')
            For Index, Info in data {
                session['Items'].Push([])
                itemdata := StrSplit(Info, ';')
                session['Items'][Index].Push('')
                session['Items'][Index].Push(itemdata[1])
                session['Items'][Index].Push(itemdata[2])
                session['Items'][Index].Push(Round(StrSplit(itemdata[5], 'x')[1] / 1000, 3))
                session['Items'][Index].Push(Round(StrSplit(itemdata[3], 'x')[1] / 1000, 3))
                session['Items'][Index].Push('1')
                session['Items'][Index].Push(StrSplit(itemdata[3], 'x')[2])
                session['Items'][Index].Push('P')
                session['Items'][Index].Push(0)
                session['Items'][Index].Push(Round(itemdata[4] / 1000, 3))
                session['Items'][Index].Push('TND')
            }
            writeJson(session, destFolder.Value '\' date '.json')
            Return True
        }
        Counted := 0
        Loop Files, srcFolder.Value '\*.sell'
            ++Counted
        importPB.Opt('range1-' Counted)
        importPB.Value := 0
        Loop Files, srcFolder.Value '\*.sell' {
            Content := StrSplit(FileRead(A_LoopFileFullPath), '> ')
            Try {
                rc := formatContentNSell(A_LoopFileName, Content)
                If !rc
                    Break
            } Catch {
                FileAppend('Non Submitted | ' A_LoopFileFullPath '`n', 'importerrors.txt')
            }
            importPB.Value++
        }
    }
    Ctrl.Enabled := True
    Msgbox('Import complete!', 'Complete', 0x40)
}