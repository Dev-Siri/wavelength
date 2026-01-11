package clients

import (
	"wavelength/proto/albumpb"
	"wavelength/services/gateway/env"
	shared_clients "wavelength/shared/clients"

	"google.golang.org/grpc"
)

var AlbumClient albumpb.AlbumServiceClient

func InitAlbumClient() error {
	addr, err := env.GetAlbumClientURL()
	if err != nil {
		return err
	}

	creds, err := shared_clients.GetTransportCreds()
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
