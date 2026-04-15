package models

type QueueableMusic struct {
	VideoID   string `json:"videoId"`
	Title     string `json:"title"`
	Thumbnail string `json:"thumbnail"`
	Duration  any    `json:"duration"`
	VideoType string `json:"videoType"`
	Artists   []struct {
		Title    string `json:"title"`
		BrowseID string `json:"browseId"`
	} `json:"artists"`
	Album *struct {
		Title    string `json:"title"`
		BrowseID string `json:"browseId"`
	} `json:"album,omitempty"`
}
