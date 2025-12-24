package models

type FollowedArtist struct {
	FollowId        string `json:"followId"`
	FollowerEmail   string `json:"followerEmail"`
	ArtistName      string `json:"artistName"`
	ArtistThumbnail string `json:"artistThumbnail"`
	ArtistBrowseId  string `json:"artistBrowseId"`
}
