package api_models

type MusicTrack struct {
	VideoId    string `json:"videoId"`
	Title      string `json:"title"`
	Thumbnail  string `json:"thumbnail"`
	Author     string `json:"author"`
	Duration   string `json:"duration"`
	IsExplicit bool   `json:"isExplicit"`
}
