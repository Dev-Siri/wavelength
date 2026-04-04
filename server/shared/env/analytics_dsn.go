package shared_env

import (
	"errors"
	"os"
)

func GetAnalyticsDSN() (string, error) {
	analyticsDSN := os.Getenv("ANALYTICS_DSN")
	if analyticsDSN == "" {
		return "", errors.New("No ANALYTICS_DSN set.")
	}

	return analyticsDSN, nil
}
