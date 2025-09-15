package env

import (
	"os"
	"wavelength/constants"

	"github.com/joho/godotenv"
)

func InitEnv() error {
	if _, err := os.Stat(constants.EnvFile); err != nil {
		return err
	}

	return godotenv.Load(constants.EnvFile)
}
