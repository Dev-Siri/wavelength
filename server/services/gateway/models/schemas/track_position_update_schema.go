package schemas

type TrackPositionUpdateSchema struct {
	PlaylistTrackId string `json:"playlistTrackId"`
	NewPos          int    `json:"newPos"`
}
