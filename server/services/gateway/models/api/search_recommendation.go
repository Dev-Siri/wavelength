package api_models

type SearchRecommendationQuery string

type SearchRecommendationItem struct {
	Thumbnail  string `json:"thumbnail"`
	Title      string `json:"title"`
	Subtitle   string `json:"subtitle"`
	BrowseId   string `json:"browseId"`
	IsExplicit bool   `json:"isExplicit"`
	Type       string `json:"type"`
}

type SearchRecommendationResponse struct {
	Query []SearchRecommendationQuery `json:"query"`
	Items []SearchRecommendationItem  `json:"items"`
}
