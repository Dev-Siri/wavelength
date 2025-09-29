package responses

import "wavelength/models"

type GeoIpResponse struct {
	Success bool             `json:"success"`
	Status  int              `json:"status"`
	Ip      *string          `json:"ip"`
	Data    models.GeoIpData `json:"data"`
	Type    string           `json:"type"`
}
