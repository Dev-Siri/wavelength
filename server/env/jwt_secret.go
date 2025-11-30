package env

import (
	"os"
	"wavelength/logging"
)

func GetJwtSecret() []byte {
	jwtSecret := os.Getenv("JWT_SECRET")

	if jwtSecret == "" {
		logging.Logger.Fatal("No JWT_SECRET set. Exiting...")
	}

	return []byte(jwtSecret)
}
