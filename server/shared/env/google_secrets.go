package shared_env

import (
	"errors"
	"os"
)

func GetGoogleSecrets() (string, string, error) {
	googleClientId := os.Getenv("GOOGLE_CLIENT_ID")
	googleClientSecret := os.Getenv("GOOGLE_CLIENT_SECRET")

	if googleClientId == "" {
		return "", "", errors.New("GOOGLE_CLIENT_ID not set.")
	}

	if googleClientSecret == "" {
		return "", "", errors.New("GOOGLE_CLIENT_SECRET not set.")
	}

	return googleClientId, googleClientSecret, nil
}
