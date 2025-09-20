package api_interface

import (
	"encoding/json"
	api_models "wavelength/models/api"
)

func (*YouTubeMusicClient) SearchMusicTracks(q string, nextPageToken string) (*api_models.MusicSearchResponse, error) {
	response, err := rapidApiFetch("/search", map[string]string{
		"q":        q,
		"type":     "song",
		"nextPage": nextPageToken,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var musicSearchResponse api_models.MusicSearchResponse

	if err := json.NewDecoder(response.Body).Decode(&musicSearchResponse); err != nil {
		return nil, err
	}

	return &musicSearchResponse, nil
}
