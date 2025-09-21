package models

type Playlist struct {
	PlaylistId        string  `json:"playlistId"`
	Name              string  `json:"name"`
	AuthorGoogleEmail string  `json:"authorGoogleEmail"`
	AuthorName        string  `json:"authorName"`
	AuthorImage       string  `json:"authorImage"`
	CoverImage        *string `json:"coverImage"`
	IsPublic          bool    `json:"isPublic"`
}
