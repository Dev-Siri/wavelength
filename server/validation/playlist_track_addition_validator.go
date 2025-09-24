package validation

import (
	type_constants "wavelength/constants/types"
	"wavelength/models/schemas"
)

func IsPlaylistTrackAdditionShapeValid(schema schemas.PlaylistTrackAdditionSchema) bool {
	isTitleValid := schema.Title != "" && len(schema.Title) <= 255
	isVideoIdValid := schema.VideoId != "" && len(schema.VideoId) <= 11
	isVideoTypeValid := schema.VideoType == type_constants.PlaylistTrackTypeTrack || schema.VideoType == type_constants.PlaylistTrackTypeUVideo

	return schema.Author != "" && schema.Thumbnail != "" && schema.Duration != "" && isTitleValid && isVideoIdValid && isVideoTypeValid
}
