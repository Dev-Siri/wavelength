package album_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/albumpb"

type AlbumService struct {
	albumpb.UnimplementedAlbumServiceServer
}

func NewAlbumService() *AlbumService {
	return &AlbumService{}
}
