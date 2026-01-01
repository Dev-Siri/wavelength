package env

import (
	"os"
	"wavelength/shared/logging"
)

func GetLyricsRapidApiHost() string {
	lyricsRapidApiHost := os.Getenv("LYRICS_RAPID_API_HOST")

	if lyricsRapidApiHost == "" {
		logging.Logger.Fatal("No LYRICS_RAPID_API_HOST set. Exiting...")
	}

	return lyricsRapidApiHost
}
