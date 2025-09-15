package api_models

type BaseMusicTrack struct {
	VideoId   string `json:"videoId"`
	Title     string `json:"title"`
	Thumbnail string `json:"thumbnail"`
	Author    string `json:"author"`
}
