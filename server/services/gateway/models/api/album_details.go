package api_models

type AlbumDetails struct {
	Title              string       `json:"title"`
	AlbumType          string       `json:"albumType"`
	AlbumRelease       string       `json:"albumRelease"`
	AlbumAuthor        string       `json:"albumAuthor"`
	AlbumCover         string       `json:"albumCover"`
	AlbumDescription   string       `json:"albumDescription"`
	IsExplicit         bool         `json:"isExplicit"`
	AlbumTotalSong     string       `json:"albumTotalSong"`
	AlbumTotalDuration string       `json:"albumTotalDuration"`
	Results            []AlbumTrack `json:"results"`
}
