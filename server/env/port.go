package env

import (
	"os"
	"wavelength/logging"
)

func GetPORT() string {
	port := os.Getenv("PORT")

	if port == "" {
		go logging.Logger.Warn("No PORT environment variable found, defaulting to 8080")
		return "8080"
	}

	return port
}
