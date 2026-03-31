package shared_env

import (
	"errors"
	"os"
)

func GetCollectorClientURL() (string, error) {
	collectorClientURL := os.Getenv("COLLECTOR_CLIENT_URL")

	if collectorClientURL == "" {
		return "", errors.New("No COLLECTOR_CLIENT_URL set.")
	}

	return collectorClientURL, nil
}
