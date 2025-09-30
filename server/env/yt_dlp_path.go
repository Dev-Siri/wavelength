package env

import (
	"os"
	"wavelength/logging"
)

func GetYtDlpPath() string {
	ytDlpPath := os.Getenv("YT_DLP_PATH")

	if ytDlpPath == "" {
		logging.Logger.Fatal("No YT_DLP_PATH set. Exiting...")
	}

	return ytDlpPath
}
