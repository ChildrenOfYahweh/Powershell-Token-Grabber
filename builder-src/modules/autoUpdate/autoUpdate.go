package autoUpdate

import (
	"io"
	"net/http"
	"strings"

	"fyne.io/fyne/v2"
)

func AutoUpdate() bool {
	url := "https://raw.githubusercontent.com/ChildrenOfYahweh/Kematian-Stealer/main/builder-src/FyneApp.toml"

	resp, err := http.Get(url)
	if err != nil {
		return false
	}

	defer resp.Body.Close()

	var currentVersion string
	if fyne.CurrentApp() != nil {
		currentVersion = fyne.CurrentApp().Metadata().Version
	} else {
		currentVersion = "1.0.0"
	}
	tomlVersion := getTomlVersion(resp.Body)

	// if the current version is equal to the toml version then return true
	return currentVersion == tomlVersion

}

func getTomlVersion(body io.Reader) string {
	allText, err := io.ReadAll(body)
	if err != nil {
		return ""
	}

	lines := strings.Split(string(allText), "\n")
	goodLine := strings.Split(lines[4], "\"")
	return goodLine[1]
}
