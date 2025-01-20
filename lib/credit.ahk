resizeControls(GuiObj, MinMax, Width, Height) {
    HeaderText.Move(,, Width - 160)
    HeaderBox.ResizeShadow()
    
    CommitLaterList.Move(,,, Height - 300)
    Commit.Move(, Height - 80)
    CommitListBox.ResizeShadow()
}