package api_models

type ArtistSearchResponse struct {
	Result        []Artist `json:"result"`
	NextPageToken *string  `json:"nextPageToken"`
}
