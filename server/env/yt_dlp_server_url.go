package env

import (
	"os"
	"wavelength/logging"
)

func GetYtDlpServerUrl() string {
	ytDlpServerUrl := os.Getenv("YT_DLP_SERVER_URL")

	if ytDlpServerUrl == "" {
		logging.Logger.Fatal("No YT_DLP_SERVER_URL set. Exiting...")
	}

	return ytDlpServerUrl
}
