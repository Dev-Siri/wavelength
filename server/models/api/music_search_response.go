package api_models

type MusicSearchResponse struct {
	Result        []MusicTrack `json:"result"`
	NextPageToken *string      `json:"nextPageToken"`
}
