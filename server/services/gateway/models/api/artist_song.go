package api_models

type ArtistSong struct {
	VideoId    string `json:"videoId"`
	Title      string `json:"title"`
	Thumbnail  string `json:"thumbnail"`
	Author     string `json:"author"`
	IsExplicit bool   `json:"isExplicit"`
}
