package shared_env

import "os"

type FeatureFlagList struct {
	LosslessCollectionEnabled bool
}

var FeatureFlags = FeatureFlagList{
	// Lossless collection depends on https://github.com/binimum/hifi-api.
	// The app has already experienced failure from the API probably due to Tidal API changes.
	// For that reason, lossless collection is put behind a feature flag to secure any future breaks.
	LosslessCollectionEnabled: os.Getenv("FEATURE_FLAG_LOSSLESS_COLLECTION") == "ON",
}
