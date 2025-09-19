package api_models

type ArtistResponse struct {
	Title           string               `json:"title"`
	Description     string               `json:"description"`
	Thumbnail       string               `json:"thumbnail"`
	SubscriberCount string               `json:"subscriberCount"`
	Songs           []ArtistResponseSong `json:"songs"`
}

type ArtistResponseSong struct {
	BrowseId    string       `json:"browseId"`
	TitleHeader string       `json:"titleHeader"`
	Contents    []ArtistSong `json:"contents"`
}
