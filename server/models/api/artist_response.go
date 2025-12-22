package api_models

type ArtistResponse struct {
	Title           string                             `json:"title"`
	Description     string                             `json:"description"`
	Thumbnail       string                             `json:"thumbnail"`
	SubscriberCount string                             `json:"subscriberCount"`
	TopSongs        ArtistContentResponse[ArtistSong]  `json:"top songs"`
	Albums          ArtistContentResponse[ArtistAlbum] `json:"albums"`
	SinglesAndEps   ArtistContentResponse[ArtistAlbum] `json:"singles_&_eps"`
}

type ArtistContentResponse[T any] struct {
	BrowseId    string `json:"browseId"`
	TitleHeader string `json:"titleHeader"`
	Contents    []T    `json:"contents"`
}
