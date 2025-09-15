package env

import (
	"os"
	"wavelength/logging"
)

func GetCorsOrigin() string {
	corsOrigin := os.Getenv("CORS_ORIGIN")

	if corsOrigin == "" {
		go logging.Logger.Warn("No CORS_ORIGIN set, defaulting to localhost:5173.")
		return "http://localhost:5173"
	}

	return corsOrigin
}
