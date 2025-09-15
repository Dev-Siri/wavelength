package api_interface

import (
	"encoding/json"
	"wavelength/constants"
	api_models "wavelength/models/api"
)

func (*YouTubeMusicClient) GetQuickPicks(gl string) (*api_models.QuickPicksResponse, error) {
	if gl == "" {
		gl = constants.DefaultRegion
	}

	response, err := rapidApiFetch("/recommend", map[string]string{
		"gl": gl,
	})

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	var quickPicks api_models.QuickPicksResponse

	if err := json.NewDecoder(response.Body).Decode(&quickPicks); err != nil {
		return nil, err
	}

	return &quickPicks, nil
}
