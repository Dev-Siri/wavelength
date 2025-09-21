package models

type YouTubeStream struct {
	Url      string `json:"url"`
	Ext      string `json:"ext"`
	Abr      int    `json:"abr"`
	Duration int    `json:"duration"`
}
