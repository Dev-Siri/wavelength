package env

import (
	"os"
	"wavelength/constants"

	"github.com/joho/godotenv"
)

func InitEnv() error {
	if _, err := os.Stat(constants.EnvFile); os.IsNotExist(err) {
		return nil
	}

	return godotenv.Load(constants.EnvFile)
}
