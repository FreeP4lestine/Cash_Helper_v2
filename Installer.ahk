#Requires AutoHotkey v2
#SingleInstance Force
IG := Gui(, 'Cash Helper v2 Installer')
IG.SetFont('s12 Bold')
IG.MarginX := 20
IG.MarginY := 20
IG.OnEvent('Close', (*) => ExitApp())
IG.AddButton('w300', 'Install').OnEvent('Click', Setup)
IG.Show()
Setup(Ctrl, Info) {
    Ctrl.Enabled := False
    Dirs := [InstallDir := A_ProgramFiles '\Cash Helper v2'
           , InstallDir '\commit'
           , InstallDir '\commit\pending'
           , InstallDir '\commit\pending\later'
           , InstallDir '\commit\archived'
           , InstallDir '\setting\defs'
           , InstallDir '\images\box'
           , InstallDir '\lib\shared'
           , InstallDir '\lib\shared\v1'
           , InstallDir '\lib\inc'
           , InstallDir '\setting\sessions']
    For Dir in Dirs {
        If !DirExist(Dir) {
            DirCreate(Dir)
        }
    }
    FileInstall('About.ahk', A_ProgramFiles '\Cash Helper v2\About.ahk', 1)
    FileInstall('Cash Helper.ahk', A_ProgramFiles '\Cash Helper v2\Cash Helper.ahk', 1)
    FileInstall('Credit Manager.ahk', A_ProgramFiles '\Cash Helper v2\Credit Manager.ahk', 1)
    FileInstall('Currency Manager.ahk', A_ProgramFiles '\Cash Helper v2\Currency Manager.ahk', 1)
    FileInstall('Discounts Manager.ahk', A_ProgramFiles '\Cash Helper v2\Discounts Manager.ahk', 1)
    FileInstall('Importer.ahk', A_ProgramFiles '\Cash Helper v2\Importer.ahk', 1)
    FileInstall('Report Bug Manager.ahk', A_ProgramFiles '\Cash Helper v2\Report Bug Manager.ahk', 1)
    FileInstall('Review Manager.ahk', A_ProgramFiles '\Cash Helper v2\Review Manager.ahk', 1)
    FileInstall('Sell Manager.ahk', A_ProgramFiles '\Cash Helper v2\Sell Manager.ahk', 1)
    FileInstall('Statistics Manager.ahk', A_ProgramFiles '\Cash Helper v2\Statistics Manager.ahk', 1)
    FileInstall('Stock Manager.ahk', A_ProgramFiles '\Cash Helper v2\Stock Manager.ahk', 1)
    FileInstall('Updates Check.ahk', A_ProgramFiles '\Cash Helper v2\Updates Check.ahk', 1)
    FileInstall('lib\class_image.ahk', A_ProgramFiles '\Cash Helper v2\lib\class_image.ahk', 1)
    FileInstall('lib\currency.ahk', A_ProgramFiles '\Cash Helper v2\lib\currency.ahk', 1)
    FileInstall('lib\loading.ahk', A_ProgramFiles '\Cash Helper v2\lib\loading.ahk', 1)
    FileInstall('lib\profile.ahk', A_ProgramFiles '\Cash Helper v2\lib\profile.ahk', 1)
    FileInstall('lib\review.ahk', A_ProgramFiles '\Cash Helper v2\lib\review.ahk', 1)
    FileInstall('lib\sell.ahk', A_ProgramFiles '\Cash Helper v2\lib\sell.ahk', 1)
    FileInstall('lib\setting.ahk', A_ProgramFiles '\Cash Helper v2\lib\setting.ahk', 1)
    FileInstall('lib\shadow.ahk', A_ProgramFiles '\Cash Helper v2\lib\shadow.ahk', 1)
    FileInstall('lib\statistic.ahk', A_ProgramFiles '\Cash Helper v2\lib\statistic.ahk', 1)
    FileInstall('lib\stock.ahk', A_ProgramFiles '\Cash Helper v2\lib\stock.ahk', 1)
    FileInstall('lib\inc\bounce-v1.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\bounce-v1.ahk', 1)
    FileInstall('lib\inc\CommandLineToArgs.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\CommandLineToArgs.ahk', 1)
    FileInstall('lib\inc\common.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\common.ahk', 1)
    FileInstall('lib\inc\config.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\config.ahk', 1)
    FileInstall('lib\inc\CreateAppShortcut.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\CreateAppShortcut.ahk', 1)
    FileInstall('lib\inc\EnableUIAccess.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\EnableUIAccess.ahk', 1)
    FileInstall('lib\inc\GetGitHubReleaseAssetURL.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\GetGitHubReleaseAssetURL.ahk', 1)
    FileInstall('lib\inc\HashFile.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\HashFile.ahk', 1)
    FileInstall('lib\inc\identify.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\identify.ahk', 1)
    FileInstall('lib\inc\identify_regex.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\identify_regex.ahk', 1)
    FileInstall('lib\inc\launcher-common.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\launcher-common.ahk', 1)
    FileInstall('lib\inc\ShellRun.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\ShellRun.ahk', 1)
    FileInstall('lib\inc\ui-base.ahk', A_ProgramFiles '\Cash Helper v2\lib\inc\ui-base.ahk', 1)
    FileInstall('lib\shared\barcoder.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\barcoder.ahk', 1)
    FileInstall('lib\shared\connected.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\connected.ahk', 1)
    FileInstall('lib\shared\createimagebutton.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\createimagebutton.ahk', 1)
    FileInstall('lib\shared\cuebanner.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\cuebanner.ahk', 1)
    FileInstall('lib\shared\explorertheme.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\explorertheme.ahk', 1)
    FileInstall('lib\shared\gdip.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\gdip.ahk', 1)
    FileInstall('lib\shared\imageput.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\imageput.ahk', 1)
    FileInstall('lib\shared\incelledit.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\incelledit.ahk', 1)
    FileInstall('lib\shared\json.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\json.ahk', 1)
    FileInstall('lib\shared\jxon.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\jxon.ahk', 1)
    FileInstall('lib\shared\lv_colors.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\lv_colors.ahk', 1)
    FileInstall('lib\shared\scrollbars.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\scrollbars.ahk', 1)
    FileInstall('lib\shared\v1\chart.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\v1\chart.ahk', 1)
    FileInstall('lib\shared\v1\gdip.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\v1\gdip.ahk', 1)
    FileInstall('lib\shared\v1\plot.ahk', A_ProgramFiles '\Cash Helper v2\lib\shared\v1\plot.ahk', 1)
    FileInstall('images\About.png', A_ProgramFiles '\Cash Helper v2\images\About.png', 1)
    FileInstall('images\About_click.png', A_ProgramFiles '\Cash Helper v2\images\About_click.png', 1)
    FileInstall('images\About_disabled.png', A_ProgramFiles '\Cash Helper v2\images\About_disabled.png', 1)
    FileInstall('images\About_hover.png', A_ProgramFiles '\Cash Helper v2\images\About_hover.png', 1)
    FileInstall('images\About_normal.png', A_ProgramFiles '\Cash Helper v2\images\About_normal.png', 1)
    FileInstall('images\amount.png', A_ProgramFiles '\Cash Helper v2\images\amount.png', 1)
    FileInstall('images\archived.png', A_ProgramFiles '\Cash Helper v2\images\archived.png', 1)
    FileInstall('images\box.png', A_ProgramFiles '\Cash Helper v2\images\box.png', 1)
    FileInstall('images\clear.png', A_ProgramFiles '\Cash Helper v2\images\clear.png', 1)
    FileInstall('images\commit.png', A_ProgramFiles '\Cash Helper v2\images\commit.png', 1)
    FileInstall('images\commitoff.png', A_ProgramFiles '\Cash Helper v2\images\commitoff.png', 1)
    FileInstall('images\Credit Manager.png', A_ProgramFiles '\Cash Helper v2\images\Credit Manager.png', 1)
    FileInstall('images\Credit Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Credit Manager_click.png', 1)
    FileInstall('images\Credit Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Credit Manager_disabled.png', 1)
    FileInstall('images\Credit Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Credit Manager_hover.png', 1)
    FileInstall('images\Credit Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Credit Manager_normal.png', 1)
    FileInstall('images\Currency Manager.png', A_ProgramFiles '\Cash Helper v2\images\Currency Manager.png', 1)
    FileInstall('images\Currency Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Currency Manager_click.png', 1)
    FileInstall('images\Currency Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Currency Manager_disabled.png', 1)
    FileInstall('images\Currency Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Currency Manager_hover.png', 1)
    FileInstall('images\Currency Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Currency Manager_normal.png', 1)
    FileInstall('images\day.png', A_ProgramFiles '\Cash Helper v2\images\day.png', 1)
    FileInstall('images\Default.png', A_ProgramFiles '\Cash Helper v2\images\Default.png', 1)
    FileInstall('images\Discounts Manager.png', A_ProgramFiles '\Cash Helper v2\images\Discounts Manager.png', 1)
    FileInstall('images\Discounts Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Discounts Manager_click.png', 1)
    FileInstall('images\Discounts Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Discounts Manager_disabled.png', 1)
    FileInstall('images\Discounts Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Discounts Manager_hover.png', 1)
    FileInstall('images\Discounts Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Discounts Manager_normal.png', 1)
    FileInstall('images\filter.png', A_ProgramFiles '\Cash Helper v2\images\filter.png', 1)
    FileInstall('images\get.png', A_ProgramFiles '\Cash Helper v2\images\get.png', 1)
    FileInstall('images\give.png', A_ProgramFiles '\Cash Helper v2\images\give.png', 1)
    FileInstall('images\hour.png', A_ProgramFiles '\Cash Helper v2\images\hour.png', 1)
    FileInstall('images\month.png', A_ProgramFiles '\Cash Helper v2\images\month.png', 1)
    FileInstall('images\pending.png', A_ProgramFiles '\Cash Helper v2\images\pending.png', 1)
    FileInstall('images\Report Bug.png', A_ProgramFiles '\Cash Helper v2\images\Report Bug.png', 1)
    FileInstall('images\Report Bug_click.png', A_ProgramFiles '\Cash Helper v2\images\Report Bug_click.png', 1)
    FileInstall('images\Report Bug_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Report Bug_disabled.png', 1)
    FileInstall('images\Report Bug_hover.png', A_ProgramFiles '\Cash Helper v2\images\Report Bug_hover.png', 1)
    FileInstall('images\Report Bug_normal.png', A_ProgramFiles '\Cash Helper v2\images\Report Bug_normal.png', 1)
    FileInstall('images\Review Manager.png', A_ProgramFiles '\Cash Helper v2\images\Review Manager.png', 1)
    FileInstall('images\Review Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Review Manager_click.png', 1)
    FileInstall('images\Review Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Review Manager_disabled.png', 1)
    FileInstall('images\Review Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Review Manager_hover.png', 1)
    FileInstall('images\Review Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Review Manager_normal.png', 1)
    FileInstall('images\Sell Manager.png', A_ProgramFiles '\Cash Helper v2\images\Sell Manager.png', 1)
    FileInstall('images\Sell Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Sell Manager_click.png', 1)
    FileInstall('images\Sell Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Sell Manager_disabled.png', 1)
    FileInstall('images\Sell Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Sell Manager_hover.png', 1)
    FileInstall('images\Sell Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Sell Manager_normal.png', 1)
    FileInstall('images\Statistics Manager.png', A_ProgramFiles '\Cash Helper v2\images\Statistics Manager.png', 1)
    FileInstall('images\Statistics Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Statistics Manager_click.png', 1)
    FileInstall('images\Statistics Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Statistics Manager_disabled.png', 1)
    FileInstall('images\Statistics Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Statistics Manager_hover.png', 1)
    FileInstall('images\Statistics Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Statistics Manager_normal.png', 1)
    FileInstall('images\Stock Manager.png', A_ProgramFiles '\Cash Helper v2\images\Stock Manager.png', 1)
    FileInstall('images\Stock Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\Stock Manager_click.png', 1)
    FileInstall('images\Stock Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Stock Manager_disabled.png', 1)
    FileInstall('images\Stock Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\Stock Manager_hover.png', 1)
    FileInstall('images\Stock Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\Stock Manager_normal.png', 1)
    FileInstall('images\SubApp_click.png', A_ProgramFiles '\Cash Helper v2\images\SubApp_click.png', 1)
    FileInstall('images\SubApp_disabled.png', A_ProgramFiles '\Cash Helper v2\images\SubApp_disabled.png', 1)
    FileInstall('images\SubApp_disabled2.png', A_ProgramFiles '\Cash Helper v2\images\SubApp_disabled2.png', 1)
    FileInstall('images\SubApp_hover.png', A_ProgramFiles '\Cash Helper v2\images\SubApp_hover.png', 1)
    FileInstall('images\SubApp_normal.png', A_ProgramFiles '\Cash Helper v2\images\SubApp_normal.png', 1)
    FileInstall('images\Updates Check.png', A_ProgramFiles '\Cash Helper v2\images\Updates Check.png', 1)
    FileInstall('images\Updates Check_click.png', A_ProgramFiles '\Cash Helper v2\images\Updates Check_click.png', 1)
    FileInstall('images\Updates Check_disabled.png', A_ProgramFiles '\Cash Helper v2\images\Updates Check_disabled.png', 1)
    FileInstall('images\Updates Check_hover.png', A_ProgramFiles '\Cash Helper v2\images\Updates Check_hover.png', 1)
    FileInstall('images\Updates Check_normal.png', A_ProgramFiles '\Cash Helper v2\images\Updates Check_normal.png', 1)
    FileInstall('images\User Manager.png', A_ProgramFiles '\Cash Helper v2\images\User Manager.png', 1)
    FileInstall('images\User Manager_click.png', A_ProgramFiles '\Cash Helper v2\images\User Manager_click.png', 1)
    FileInstall('images\User Manager_disabled.png', A_ProgramFiles '\Cash Helper v2\images\User Manager_disabled.png', 1)
    FileInstall('images\User Manager_hover.png', A_ProgramFiles '\Cash Helper v2\images\User Manager_hover.png', 1)
    FileInstall('images\User Manager_normal.png', A_ProgramFiles '\Cash Helper v2\images\User Manager_normal.png', 1)
    FileInstall('images\user.png', A_ProgramFiles '\Cash Helper v2\images\user.png', 1)
    FileInstall('images\users.png', A_ProgramFiles '\Cash Helper v2\images\users.png', 1)
    FileInstall('images\year.png', A_ProgramFiles '\Cash Helper v2\images\year.png', 1)
    FileInstall('images\box\bottom.png', A_ProgramFiles '\Cash Helper v2\images\box\bottom.png', 1)
    FileInstall('images\box\bottomleft.png', A_ProgramFiles '\Cash Helper v2\images\box\bottomleft.png', 1)
    FileInstall('images\box\bottomright.png', A_ProgramFiles '\Cash Helper v2\images\box\bottomright.png', 1)
    FileInstall('images\box\left.png', A_ProgramFiles '\Cash Helper v2\images\box\left.png', 1)
    FileInstall('images\box\right.png', A_ProgramFiles '\Cash Helper v2\images\box\right.png', 1)
    FileInstall('images\box\top.png', A_ProgramFiles '\Cash Helper v2\images\box\top.png', 1)
    FileInstall('images\box\topleft.png', A_ProgramFiles '\Cash Helper v2\images\box\topleft.png', 1)
    FileInstall('images\box\topright.png', A_ProgramFiles '\Cash Helper v2\images\box\topright.png', 1)

    FileCreateShortcut(InstallDir '\Cash Helper.ahk', A_Desktop '\Cash Helper v2.lnk', InstallDir,,, A_AhkPath,, 1)
    If 'Yes' = MsgBox('Installation complete!', 'Run now?', 0x40 + 0x4) {
        Run(InstallDir '\Cash Helper.ahk')
    }
    ExitApp()
}
f1:: {
    InstallDir := A_ProgramFiles '\Cash Helper v2'
    FI := ''
    Loop Files, '*.ahk', 'R' {
        Path := (A_LoopFileDir ? A_LoopFileDir '\' : '') A_LoopFileName
        FI .= "FileInstall('" Path "', A_ProgramFiles '\Cash Helper v2\" Path "', 1)`n"
    }
    Loop Files, '*.png', 'R' {
        Path := (A_LoopFileDir ? A_LoopFileDir '\' : '') A_LoopFileName
        FI .= "FileInstall('" Path "', A_ProgramFiles '\Cash Helper v2\" Path "', 1)`n"
    }
    Loop Files, 'setting\*.json' {
        Path := (A_LoopFileDir ? A_LoopFileDir '\' : '') A_LoopFileName
        FI .= "FileInstall('" Path "', A_ProgramFiles '\Cash Helper v2\" Path "', 1)`n"
    }
    A_Clipboard := FI
}

