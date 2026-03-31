package shared_env

import (
	"errors"
	"os"
)

func GetLyricClientURL() (string, error) {
	lyricClientURL := os.Getenv("LYRIC_CLIENT_URL")

	if lyricClientURL == "" {
		return "", errors.New("No LYRIC_CLIENT_URL set.")
	}

	return lyricClientURL, nil
}
