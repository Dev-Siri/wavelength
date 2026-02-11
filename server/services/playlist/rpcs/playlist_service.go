package playlist_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/playlistpb"

type PlaylistService struct {
	playlistpb.UnimplementedPlaylistServiceServer
}

func NewPlaylistService() *PlaylistService {
	return &PlaylistService{}
}
