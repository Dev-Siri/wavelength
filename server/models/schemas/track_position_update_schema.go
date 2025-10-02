package schemas

type TrackPositionUpdateSchema struct {
	PlaylistTrackId int `json:"playlistTrackId"`
	NewPos          int `json:"newPos"`
}
