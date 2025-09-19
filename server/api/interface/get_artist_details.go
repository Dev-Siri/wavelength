package api_interface

import (
	"encoding/json"
	api_models "wavelength/models/api"
)

func (*YouTubeMusicClient) GetArtistDetails(id string) (*api_models.ArtistResponse, error) {
	response, err := rapidApiFetch("/getArtists", map[string]string{
		"id": id,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var quickPicks api_models.ArtistResponse

	if err := json.NewDecoder(response.Body).Decode(&quickPicks); err != nil {
		return nil, err
	}

	return &quickPicks, nil
}
