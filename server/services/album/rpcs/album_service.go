package album_rpcs

import "wavelength/proto/albumpb"

type AlbumService struct {
	albumpb.UnimplementedAlbumServiceServer
}

func NewAlbumService() *AlbumService {
	return &AlbumService{}
}
