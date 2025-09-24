package schemas

import type_constants "wavelength/constants/types"

type PlaylistTrackAdditionSchema struct {
	Author     string                           `json:"author"`
	Thumbnail  string                           `json:"thumbnail"`
	Duration   string                           `json:"duration"`
	IsExplicit bool                             `json:"isExplicit"`
	Title      string                           `json:"title"`
	VideoId    string                           `json:"videoId"`
	VideoType  type_constants.PlaylistTrackType `json:"videoType"`
}
