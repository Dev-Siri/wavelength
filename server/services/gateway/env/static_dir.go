package env

import (
	"os"

	"github.com/Dev-Siri/wavelength/server/shared/logging"
)

func GetStaticDir() string {
	staticDir := os.Getenv("STATIC_DIR")

	if staticDir == "" {
		go logging.Logger.Warn("No STATIC_DIR set. Defaulting to `./static`")
		return "./static"
	}

	return staticDir
}
