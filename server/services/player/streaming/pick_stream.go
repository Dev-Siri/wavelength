package streaming

import (
	"github.com/Dev-Siri/wavelength/server/services/player/security"
	"github.com/Dev-Siri/wavelength/server/services/player/types"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
)

func PickAndGenerateStreamURL(streamPartName string, clientDetails *security.TokenClientDetails) (string, error) {
	if !clientDetails.IsHifi {
		return shared_db.GenerateAdaptiveURL(clientDetails.VideoID, streamPartName)
	} else if clientDetails.IsLossless != nil && clientDetails.PreferredQuality == types.PreferredQualityLossless {
		return shared_db.GenerateLosslessURL(clientDetails.ISRC, streamPartName)
	} else {
		reader, err := hifiAutoStreamingHandler(streamPartName, clientDetails.ISRC, clientDetails.VideoID)
		if err != nil {
			return "", err
		}

		if reader != "" {
			return reader, nil
		}

		switch clientDetails.PreferredQuality {
		case types.PreferredQualityHifiBase:
			return shared_db.GenerateBaseHifiURL(clientDetails.ISRC, streamPartName)
		case types.PreferredQualityHifiTop, types.PreferredQualityLossless:
			return shared_db.GenerateTopHifiURL(clientDetails.ISRC, streamPartName)
		default:
			return shared_db.GenerateAdaptiveURL(clientDetails.VideoID, streamPartName)
		}
	}
}
