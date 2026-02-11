package validation

import (
	"github.com/Dev-Siri/wavelength/server/services/gateway/models/schemas"
	"github.com/Dev-Siri/wavelength/server/services/gateway/utils"
)

func IsFollowArtistShapeValid(schema schemas.ArtistFollowSchema) bool {
	return schema.BrowseId != "" && len(schema.BrowseId) <= 255 && schema.Name != "" && len(schema.Name) <= 255 &&
		utils.IsValidUrl(schema.Thumbnail) && len(schema.Thumbnail) <= 350
}
