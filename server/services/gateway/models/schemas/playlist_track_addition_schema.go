package schemas

import type_constants "wavelength/services/gateway/constants/types"

type PlaylistTrackAdditionSchema struct {
	Thumbnail  string                              `json:"thumbnail"`
	Duration   string                              `json:"duration"`
	IsExplicit bool                                `json:"isExplicit"`
	Title      string                              `json:"title"`
	VideoId    string                              `json:"videoId"`
	VideoType  type_constants.PlaylistTrackType    `json:"videoType"`
	Artists    []PlaylistTrackAdditionArtistSchema `json:"artists"`
}

type PlaylistTrackAdditionArtistSchema struct {
	Title    string `json:"title"`
	BrowseId string `json:"browseId"`
}
