package shared_env

import (
	"os"

	"github.com/joho/godotenv"
)

const envFile = ".env"

func InitEnv() error {
	if _, err := os.Stat(envFile); os.IsNotExist(err) {
		return nil
	}

	return godotenv.Load(envFile)
}
