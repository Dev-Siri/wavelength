package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var ImageClient imagepb.ImageServiceClient

func InitImageClient() error {
	addr, err := env.GetImageClientURL()
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

	ImageClient = imagepb.NewImageServiceClient(conn)
	return nil
}
