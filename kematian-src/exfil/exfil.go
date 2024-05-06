package exfil

import (
	"encoding/base64"
	"fmt"
)

func PrintStuff(filename string, stuff string) {
	if stuff == "" {
		stuff = "No data"
	}

	encodedBase64 := base64.StdEncoding.EncodeToString([]byte(stuff))

	fmt.Println(filename + "\n" + encodedBase64)
}
