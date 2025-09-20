package api_interface

import (
	"encoding/json"
	api_models "wavelength/models/api"
)

func (*YouTubeMusicClient) GetMatchedSong(id string) ([]api_models.SongMatch, error) {
	response, err := rapidApiFetch("/matching", map[string]string{
		"id": id,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var songMatches []api_models.SongMatch

	if err := json.NewDecoder(response.Body).Decode(&songMatches); err != nil {
		return nil, err
	}

	return songMatches, nil
}
