package shared_env

import (
	"os"

	"github.com/Dev-Siri/wavelength/server/services/gateway/constants"

	"github.com/joho/godotenv"
)

func InitEnv() error {
	if _, err := os.Stat(constants.EnvFile); os.IsNotExist(err) {
		return nil
	}

	return godotenv.Load(constants.EnvFile)
}
