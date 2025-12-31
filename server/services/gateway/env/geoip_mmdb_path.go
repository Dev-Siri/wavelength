package env

import (
	"os"
	"wavelength/services/gateway/logging"
)

func GetGeoIPMMDBPath() string {
	geoipMmdbPath := os.Getenv("GEOIP_MMDB_PATH")

	if geoipMmdbPath == "" {
		logging.Logger.Fatal("No GEOIP_MMDB_PATH set. Exiting...")
	}

	return geoipMmdbPath
}
