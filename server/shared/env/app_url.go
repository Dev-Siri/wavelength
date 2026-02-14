package shared_env

import (
	"os"
)

func GetAppURL() string {
	appURL := os.Getenv("APP_URL")

	if appURL == "" {
		port := GetPORT()
		return "http://localhost:" + port
	}

	return appURL
}
