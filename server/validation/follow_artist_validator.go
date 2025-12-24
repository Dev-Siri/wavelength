package validation

import (
	"wavelength/models/schemas"
	"wavelength/utils"
)

func IsFollowArtistShapeValid(schema schemas.ArtistFollowSchmea) bool {
	return schema.BrowseId != "" && len(schema.BrowseId) <= 255 && schema.Name != "" && len(schema.Name) <= 255 &&
		utils.IsValidUrl(schema.Thumbnail) && len(schema.Thumbnail) <= 350
}
