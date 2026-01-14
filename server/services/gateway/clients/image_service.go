package clients

import (
	"wavelength/proto/imagepb"
	"wavelength/services/gateway/env"
	shared_clients "wavelength/shared/clients"

	"google.golang.org/grpc"
)

var ImageClient imagepb.ImageServiceClient

func InitImageClient() error {
	addr, err := env.GetImageClientURL()
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

	ImageClient = imagepb.NewImageServiceClient(conn)
	return nil
}
