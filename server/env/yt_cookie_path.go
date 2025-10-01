package env

import (
	"os"
	"wavelength/logging"
)

func GetYtCookiePath() string {
	ytCookiePath := os.Getenv("YT_COOKIE_PATH")

	if ytCookiePath == "" {
		logging.Logger.Fatal("No YT_COOKIE_PATH set. Exiting...")
	}

	return ytCookiePath
}
