package models

type MusicTrackStats struct {
	ViewCount    uint64 `json:"viewCount"`
	LikeCount    uint64 `json:"likeCount"`
	CommentCount uint64 `json:"commentCount"`
}
