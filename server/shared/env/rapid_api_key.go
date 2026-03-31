package shared_env

import (
	"errors"
	"os"
)

func GetRapidApiKey() (string, error) {
	rapidApiKey := os.Getenv("RAPID_API_KEY")
	if rapidApiKey == "" {
		return "", errors.New("No RAPID_API_KEY set.")
	}

	return rapidApiKey, nil
}
