package env

import (
	"os"
	"wavelength/logging"
)

func GetUploadThingKey() string {
	uploadThingKey := os.Getenv("UPLOAD_THING_KEY")

	if uploadThingKey == "" {
		logging.Logger.Fatal("No UPLOAD_THING_KEY set. Exiting...")
	}

	return uploadThingKey
}
