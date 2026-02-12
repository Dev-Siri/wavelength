package shared_env

import (
	"errors"
	"os"
)

func GetRedisURL() (string, error) {
	redisURL := os.Getenv("REDIS_URL")

	if redisURL == "" {
		return "", errors.New("No REDIS_URL set.")
	}

	return redisURL, nil
}
