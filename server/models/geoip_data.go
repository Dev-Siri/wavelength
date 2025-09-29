package models

type GeoIpData struct {
	Range    [2]float64 `json:"range"`
	Country  string     `json:"country"`
	Region   string     `json:"region"`
	Eu       string     `json:"eu"`
	Timezone string     `json:"timezone"`
	City     string     `json:"city"`
	Ll       [2]float64 `json:"ll"`
	Metro    int        `json:"metro"`
	Area     int        `json:"area"`
}
