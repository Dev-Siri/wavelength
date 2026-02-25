package shared_env

import (
	"errors"
	"os"
)

func GetAlbumClientURL() (string, error) {
	albumClientURL := os.Getenv("ALBUM_CLIENT_URL")

	if albumClientURL == "" {
		return "", errors.New("No ALBUM_CLIENT_URL set.")
	}

	return albumClientURL, nil
}
