package clients

import (
	"wavelength/proto/albumpb"
	"wavelength/services/gateway/env"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var AlbumClient albumpb.AlbumServiceClient

func InitAlbumClient() error {
	addr, err := env.GetAlbumClientURL()
	if err != nil {
		return err
	}

	conn, err := grpc.NewClient(
		addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return err
	}

	AlbumClient = albumpb.NewAlbumServiceClient(conn)
	return nil
}
