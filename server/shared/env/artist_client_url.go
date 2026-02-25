package shared_env

import (
	"errors"
	"os"
)

func GetArtistClientURL() (string, error) {
	artistClientURL := os.Getenv("ARTIST_CLIENT_URL")

	if artistClientURL == "" {
		return "", errors.New("No ARTIST_CLIENT_URL set.")
	}

	return artistClientURL, nil
}
