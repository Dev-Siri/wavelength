package schemas

import shared_type_constants "wavelength/shared/constants/types"

type PlaylistTrackAdditionSchema struct {
	Thumbnail  string                                    `json:"thumbnail"`
	Duration   string                                    `json:"duration"`
	IsExplicit bool                                      `json:"isExplicit"`
	Title      string                                    `json:"title"`
	VideoId    string                                    `json:"videoId"`
	VideoType  shared_type_constants.PlaylistTrackType   `json:"videoType"`
	Artists    []PlaylistTrackAdditionEmbeddedDataSchema `json:"artists"`
	Album      *PlaylistTrackAdditionEmbeddedDataSchema  `json:"album"`
}

type PlaylistTrackAdditionEmbeddedDataSchema struct {
	Title    string `json:"title"`
	BrowseId string `json:"browseId"`
}
