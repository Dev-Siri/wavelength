package shared_env

import (
	"errors"
	"os"
)

func GetPlaylistClientURL() (string, error) {
	playlistClientURL := os.Getenv("PLAYLIST_CLIENT_URL")

	if playlistClientURL == "" {
		return "", errors.New("No PLAYLIST_CLIENT_URL set.")
	}

	return playlistClientURL, nil
}
