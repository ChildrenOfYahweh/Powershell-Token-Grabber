package main

import (
	"time"
	"builder/modules/autoUpdate"
	"builder/modules/cursed"
	"builder/modules/options/utils"
	"builder/ui-tabs/batchTab"
	"builder/ui-tabs/exeTab"
	"builder/ui-tabs/homeTab"
	"builder/ui-tabs/powershellTab"
	"builder/ui-tabs/removeTab"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

func main() {
	a := app.New()
	win := a.NewWindow(cursed.Generate("Kematian Stealer Builder", "normal", true, true, true))
	win.Resize(fyne.NewSize(500, 400))
	win.CenterOnScreen()

	if !autoUpdate.AutoUpdate() {
		utils.MakeSuccessMessage(a, "A NEW UPDATE IS AVAILABLE! PLEASE DOWNLOAD IT FROM THE GITHUB REPO!")
	}

	tabs := container.NewAppTabs(
		container.NewTabItem("Home", homeTab.GetHomeTab(a)),
		container.NewTabItem("Powershell", powershellTab.GetBuilderPowershell(a)),
		container.NewTabItem("Batch", batchTab.GetBatchBuilder(a)),
		container.NewTabItem("EXE", exeTab.GetExeBuilder(a)),
		container.NewTabItem("Remove", removeTab.GetRemoveTab(a)),
		container.NewTabItem("Credits", widget.NewLabel("Made by KDot227, Chainski and EvilByteCode")),
	)

	win.SetContent(tabs)

	tabs.SetTabLocation(container.TabLocationLeading)

	win.SetContent(tabs)

	outputChannel := make(chan string)

	go func() {
		ticker := time.NewTicker(25 * time.Millisecond)
		defer ticker.Stop()

		for range ticker.C {
			output := cursed.Generate("Kematian Stealer Builder", "normal", true, true, true)
			outputChannel <- output
		}
	}()

	go func() {
		for output := range outputChannel {
			win.SetTitle(output)
		}
	}()

	win.ShowAndRun()
}
