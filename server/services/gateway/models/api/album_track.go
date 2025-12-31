package api_models

type AlbumTrack struct {
	VideoId    string `json:"videoId"`
	Title      string `json:"title"`
	Duration   string `json:"duration"`
	IsExplicit bool   `json:"isExplicit"`
	Author     string `json:"author"`
}
