package models

type YouTubeVideo struct {
	VideoId   string `json:"videoId"`
	Title     string `json:"title"`
	Thumbnail string `json:"thumbnail"`
	Author    string `json:"author"`
}
