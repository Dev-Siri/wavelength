package env

import (
	"os"
	"wavelength/logging"
)

func GetRapidApiKeys() (string, string) {
	rapidApiKey := os.Getenv("RAPID_API_KEY")
	rapidApiHost := os.Getenv("RAPID_API_HOST")

	if rapidApiKey == "" {
		logging.Logger.Fatal("No RAPID_API_KEY set. Exiting...")
	}

	if rapidApiHost == "" {

		logging.Logger.Fatal("No RAPID_API_HOST set. Exiting...")
	}

	return rapidApiKey, rapidApiHost
}
