package env

import (
	"errors"
	"os"
)

func GetYTScraperURL() (string, error) {
	ytScraperUrl := os.Getenv("YT_SCRAPER_URL")

	if ytScraperUrl == "" {
		return "", errors.New("No YT_SCRAPER_URL set.")
	}

	return ytScraperUrl, nil
}
