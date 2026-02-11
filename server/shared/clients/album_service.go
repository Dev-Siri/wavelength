package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var AlbumClient albumpb.AlbumServiceClient

func InitAlbumClient() error {
	addr, err := shared_env.GetAlbumClientURL()
	if err != nil {
		return err
	}

	creds, err := security.GetTransportCreds()
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
