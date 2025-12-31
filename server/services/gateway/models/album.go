package models

type Album struct {
	AlbumId     string `json:"albumId"`
	AlbumType   string `json:"albumType"`
	Title       string `json:"title"`
	Thumbnail   string `json:"thumbnail"`
	Author      string `json:"author"`
	ReleaseDate string `json:"releaseDate"`
	IsExplicit  bool   `json:"isExplicit"`
}
