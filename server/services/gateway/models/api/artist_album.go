package api_models

type ArtistAlbum struct {
	BrowseId   string `json:"browseId"`
	Title      string `json:"title"`
	Thumbnail  string `json:"thumbnail"`
	Subtitle   string `json:"subtitle"`
	IsExplicit bool   `json:"isExplicit"`
}
