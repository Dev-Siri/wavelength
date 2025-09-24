package models

type PlaylistTrack struct {
	PlaylistTrackId    string `json:"playlistTrackId"`
	Title              string `json:"title"`
	Thumbnail          string `json:"thumbnail"`
	PositionInPlaylist int    `json:"positionInPlaylist"`
	IsExplicit         bool   `json:"isExplicit"`
	Author             string `json:"author"`
	Duration           string `json:"duration"`
	VideoId            string `json:"videoId"`
	VideoType          string `json:"videoType"`
	PlaylistId         string `json:"playlistId"`
}
