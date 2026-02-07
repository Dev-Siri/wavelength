package validation

import (
	"wavelength/services/gateway/models/schemas"
	shared_type_constants "wavelength/shared/constants/types"
)

func IsPlaylistTrackAdditionShapeValid(schema schemas.PlaylistTrackAdditionSchema) bool {
	isTitleValid := schema.Title != "" && len(schema.Title) <= 255
	isVideoIdValid := schema.VideoId != "" && len(schema.VideoId) <= 11
	isVideoTypeValid := schema.VideoType == shared_type_constants.PlaylistTrackTypeTrack || schema.VideoType == shared_type_constants.PlaylistTrackTypeUVideo
	areArtistValid := true

	for _, artist := range schema.Artists {
		if artist.Title == "" || artist.BrowseId == "" {
			areArtistValid = false
		}
	}

	return len(schema.Artists) != 0 && schema.Thumbnail != "" && schema.Duration != "" &&
		isTitleValid && isVideoIdValid && isVideoTypeValid && areArtistValid
}
