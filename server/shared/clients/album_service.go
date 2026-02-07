package shared_clients

import (
	"wavelength/proto/albumpb"
	shared_env "wavelength/shared/env"

	"google.golang.org/grpc"
)

var AlbumClient albumpb.AlbumServiceClient

func InitAlbumClient() error {
	addr, err := shared_env.GetAlbumClientURL()
	if err != nil {
		return err
	}

	creds, err := GetTransportCreds()
	if err != nil {
		return err
	}

	conn, err := grpc.NewClient(
		addr,
		grpc.WithTransportCredentials(creds),
	)
	if err != nil {
		return err
	}

	AlbumClient = albumpb.NewAlbumServiceClient(conn)
	return nil
}
