package env

import (
	"errors"
	"os"
)

func GetLyricsRapidApiKey() (string, error) {
	lyricsRapidApiKey := os.Getenv("LYRICS_RAPID_API_KEY")
	if lyricsRapidApiKey == "" {
		return "", errors.New("No LYRICS_RAPID_API_KEY set.")
	}

	return lyricsRapidApiKey, nil
}
