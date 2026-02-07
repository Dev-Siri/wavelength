package shared_env

import (
	"errors"
	"os"
)

func GetArtistClientURL() (string, error) {
	musicClientURL := os.Getenv("ARTIST_CLIENT_URL")

	if musicClientURL == "" {
		return "", errors.New("No ARTIST_CLIENT_URL set.")
	}

	return musicClientURL, nil
}
