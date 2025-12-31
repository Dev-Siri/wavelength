package env

import (
	"os"
	"wavelength/services/gateway/logging"
)

func GetGoogleApiKey() string {
	googleApiKey := os.Getenv("GOOGLE_API_KEY")

	if googleApiKey == "" {
		logging.Logger.Fatal("No GOOGLE_API_KEY set. Exiting...")
	}

	return googleApiKey
}
