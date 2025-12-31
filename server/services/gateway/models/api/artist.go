package api_models

type Artist struct {
	BrowseId       string `json:"browseId"`
	Title          string `json:"title"`
	Thumbnail      string `json:"thumbnail"`
	Author         string `json:"author"`
	SubscriberText string `json:"subscriberText"`
	IsExplicit     bool   `json:"isExplicit"`
}
