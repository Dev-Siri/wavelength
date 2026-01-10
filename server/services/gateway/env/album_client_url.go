package env

import (
	"errors"
	"os"
)

func GetAlbumClientURL() (string, error) {
	musicClientURL := os.Getenv("ALBUM_CLIENT_URL")

	if musicClientURL == "" {
		return "", errors.New("No ALBUM_CLIENT_URL set.")
	}

	return musicClientURL, nil
}
