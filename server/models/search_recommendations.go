package models

import api_models "wavelength/models/api"

type SearchRecommendations struct {
	MatchingQueries []api_models.SearchRecommendationQuery `json:"matchingQueries"`
	MatchingLinks   []api_models.SearchRecommendationItem  `json:"matchingLinks"`
}
