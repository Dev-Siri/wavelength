package lyrics_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/lyricspb"

type LyricService struct {
	lyricspb.UnimplementedLyricServiceServer
}

func NewLyricService() *LyricService {
	return &LyricService{}
}
