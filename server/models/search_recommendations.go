package models

import api_models "wavelength/models/api"

type SearchSuggestedLinkMeta struct {
	Type                string `json:"type"`
	AuthorOrAlbum       string `json:"authorOrAlbum"`
	PlaysOrAlbumRelease string `json:"playsOrAlbumRelease"`
}

type SearchSuggestedLink struct {
	Meta       SearchSuggestedLinkMeta `json:"meta"`
	Thumbnail  string                  `json:"thumbnail"`
	Title      string                  `json:"title"`
	Subtitle   string                  `json:"subtitle"`
	BrowseId   string                  `json:"browseId"`
	IsExplicit bool                    `json:"isExplicit"`
	Type       string                  `json:"type"`
}

type SearchRecommendations struct {
	MatchingQueries []api_models.SearchRecommendationQuery `json:"matchingQueries"`
	MatchingLinks   []SearchSuggestedLink                  `json:"matchingLinks"`
}
