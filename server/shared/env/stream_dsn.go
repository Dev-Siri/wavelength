package shared_env

import (
	"errors"
	"os"
)

func GetStreamDSN() (string, error) {
	streamDSN := os.Getenv("STREAM_DSN")
	if streamDSN == "" {
		return "", errors.New("No STREAM_DSN set.")
	}

	return streamDSN, nil
}
