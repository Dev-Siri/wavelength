package env

import (
	"os"
	"wavelength/services/gateway/logging"
)

func GetDBUrl() string {
	dbUrl := os.Getenv("DSN")

	if dbUrl == "" {
		logging.Logger.Fatal("No DSN (Database URL) set. Exiting...")
	}

	return dbUrl
}
