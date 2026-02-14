package shared_env

import (
	"errors"
	"os"
)

func GetJwtSecret() ([]byte, error) {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		return nil, errors.New("No JWT_SECRET set.")
	}

	return []byte(jwtSecret), nil
}
