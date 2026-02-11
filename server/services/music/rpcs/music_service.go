package music_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/musicpb"

type MusicService struct {
	musicpb.UnimplementedMusicServiceServer
}

func NewMusicService() *MusicService {
	return &MusicService{}
}
