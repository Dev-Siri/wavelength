package artist_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/artistpb"

type ArtistService struct {
	artistpb.UnimplementedArtistServiceServer
}

func NewArtistService() *ArtistService {
	return &ArtistService{}
}
