package api_models

type Lyric struct {
	Text    string `json:"text"`
	StartMs int    `json:"startMs"`
	DurMs   int    `json:"durMs"`
}
