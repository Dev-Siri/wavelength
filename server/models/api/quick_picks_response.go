package api_models

type QuickPicksResponse struct {
	Error   bool             `json:"error"`
	Results []BaseMusicTrack `json:"results"`
}
