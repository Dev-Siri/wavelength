package env

import (
	"errors"
	"os"
)

func GetImageClientURL() (string, error) {
	imageClientURL := os.Getenv("IMAGE_CLIENT_URL")

	if imageClientURL == "" {
		return "", errors.New("No IMAGE_CLIENT_URL set.")
	}

	return imageClientURL, nil
}
