package api_interface

import (
	"encoding/json"
	api_models "wavelength/services/gateway/models/api"
)

func (*YouTubeMusicClient) SearchAlbums(query string, nextPageToken string) (*api_models.AlbumSearchResponse, error) {
	response, err := rapidApiFetch("/search", map[string]string{
		"q":        query,
		"type":     "albums",
		"nextPage": nextPageToken,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var albumResponse api_models.AlbumSearchResponse

	if err := json.NewDecoder(response.Body).Decode(&albumResponse); err != nil {
		return nil, err
	}

	return &albumResponse, nil
}
