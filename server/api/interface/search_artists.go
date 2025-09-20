package api_interface

import (
	"encoding/json"
	api_models "wavelength/models/api"
)

func (*YouTubeMusicClient) SearchArtists(q string, nextPageToken string) (*api_models.ArtistSearchResponse, error) {
	response, err := rapidApiFetch("/search", map[string]string{
		"q":        q,
		"type":     "artists",
		"nextPage": nextPageToken,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var artistSearchResponse api_models.ArtistSearchResponse

	if err := json.NewDecoder(response.Body).Decode(&artistSearchResponse); err != nil {
		return nil, err
	}

	return &artistSearchResponse, nil
}
