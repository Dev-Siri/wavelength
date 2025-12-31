package models

import type_constants "wavelength/services/gateway/constants/types"

type PlaylistTrack struct {
	PlaylistTrackId    string                           `json:"playlistTrackId"`
	Title              string                           `json:"title"`
	Thumbnail          string                           `json:"thumbnail"`
	PositionInPlaylist int                              `json:"positionInPlaylist"`
	IsExplicit         bool                             `json:"isExplicit"`
	Author             string                           `json:"author"`
	Duration           string                           `json:"duration"`
	VideoId            string                           `json:"videoId"`
	VideoType          type_constants.PlaylistTrackType `json:"videoType"`
	PlaylistId         string                           `json:"playlistId"`
}
