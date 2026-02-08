package env

import (
	"errors"
	"os"
)

func GetLyricsRapidApiHost() (string, error) {
	lyricsRapidApiHost := os.Getenv("LYRICS_RAPID_API_HOST")
	if lyricsRapidApiHost == "" {
		return "", errors.New("No LYRICS_RAPID_API_HOST set.")
	}

	return lyricsRapidApiHost, nil
}
