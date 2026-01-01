package env

import (
	"errors"
	"os"
)

func GetMusicClientURL() (string, error) {
	musicClientURL := os.Getenv("MUSIC_CLIENT_URL")

	if musicClientURL == "" {
		return "", errors.New("No MUSIC_CLIENT_URL set.")
	}

	return musicClientURL, nil
}
