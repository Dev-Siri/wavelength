package env

import (
	"errors"
	"os"
)

func GetGoogleApiKey() (string, error) {
	googleApiKey := os.Getenv("GOOGLE_API_KEY")

	if googleApiKey == "" {
		return "", errors.New("No GOOGLE_API_KEY set.")
	}

	return googleApiKey, nil
}
