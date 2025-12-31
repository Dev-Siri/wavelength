package models

import (
	api_models "wavelength/services/gateway/models/api"
)

type Artist struct {
	Title           string                  `json:"title"`
	Description     string                  `json:"description"`
	SubscriberCount string                  `json:"subscriberCount"`
	TopSongs        []api_models.ArtistSong `json:"topSongs"`
	Albums          []Album                 `json:"albums"`
	SinglesAndEps   []Album                 `json:"singlesAndEps"`
}
