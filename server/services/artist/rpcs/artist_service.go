package artist_rpcs

import "wavelength/proto/artistpb"

type ArtistService struct {
	artistpb.UnimplementedArtistServiceServer
}

func NewArtistService() *ArtistService {
	return &ArtistService{}
}
