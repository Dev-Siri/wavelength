package music_rpcs

import "wavelength/proto/musicpb"

type MusicService struct {
	musicpb.UnimplementedMusicServiceServer
}

func NewMusicService() *MusicService {
	return &MusicService{}
}
