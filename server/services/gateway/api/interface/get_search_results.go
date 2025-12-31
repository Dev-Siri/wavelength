package api_interface

import (
	"encoding/json"
	api_models "wavelength/services/gateway/models/api"
)

func (*YouTubeMusicClient) GetSearchResults(query string) (*api_models.SearchRecommendationResponse, error) {
	response, err := rapidApiFetch("/search_suggestions", map[string]string{
		"q": query,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var searchRecommendations api_models.SearchRecommendationResponse

	if err := json.NewDecoder(response.Body).Decode(&searchRecommendations); err != nil {
		return nil, err
	}

	return &searchRecommendations, nil
}
