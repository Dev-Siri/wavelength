package models

import type_constants "wavelength/services/gateway/constants/types"

type LikedTrack struct {
	LikeId     string                           `json:"likeId"`
	Email      string                           `json:"email"`
	Title      string                           `json:"title"`
	Thumbnail  string                           `json:"thumbnail"`
	IsExplicit bool                             `json:"isExplicit"`
	Author     string                           `json:"author"`
	Duration   string                           `json:"duration"`
	VideoId    string                           `json:"videoId"`
	VideoType  type_constants.PlaylistTrackType `json:"videoType"`
}
