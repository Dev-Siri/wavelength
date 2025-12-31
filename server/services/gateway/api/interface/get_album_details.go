package api_interface

import (
	"encoding/json"
	api_models "wavelength/services/gateway/models/api"
)

func (*YouTubeMusicClient) GetAlbumsDetails(albumId string) (*api_models.AlbumDetails, error) {
	response, err := rapidApiFetch("/getAlbum", map[string]string{
		"id": albumId,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var albumDetails api_models.AlbumDetails

	if err := json.NewDecoder(response.Body).Decode(&albumDetails); err != nil {
		return nil, err
	}

	return &albumDetails, nil
}
