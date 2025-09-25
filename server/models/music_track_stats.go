package models

type MusicTrackStats struct {
	Views    uint64 `json:"views"`
	Likes    uint64 `json:"likes"`
	Comments uint64 `json:"comments"`
}
