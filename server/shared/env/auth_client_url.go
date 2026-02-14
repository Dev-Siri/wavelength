package shared_env

import (
	"errors"
	"os"
)

func GetAuthClientURL() (string, error) {
	authClientURL := os.Getenv("AUTH_CLIENT_URL")

	if authClientURL == "" {
		return "", errors.New("No AUTH_CLIENT_URL set.")
	}

	return authClientURL, nil
}
