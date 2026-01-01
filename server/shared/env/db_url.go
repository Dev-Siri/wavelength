package shared_env

import (
	"errors"
	"os"
)

func GetDBUrl() (string, error) {
	dbUrl := os.Getenv("DSN")

	if dbUrl == "" {
		return "", errors.New("No DSN (Database URL) set.")
	}

	return dbUrl, nil
}
