package api_models

type AlbumSearchResponse struct {
	Result        []Album `json:"result"`
	NextPageToken *string `json:"nextPageToken"`
}
