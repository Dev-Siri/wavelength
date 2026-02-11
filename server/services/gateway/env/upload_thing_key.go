package env

import (
	"os"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
)

func GetUploadThingKey() string {
	uploadThingKey := os.Getenv("UPLOAD_THING_KEY")

	if uploadThingKey == "" {
		logging.Logger.Fatal("No UPLOAD_THING_KEY set. Exiting...")
	}

	return uploadThingKey
}
