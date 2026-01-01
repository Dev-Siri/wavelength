package rpcs

import "wavelength/proto/playlistpb"

type PlaylistService struct {
	playlistpb.UnimplementedPlaylistServiceServer
}

func NewPlaylistService() *PlaylistService {
	return &PlaylistService{}
}
