package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/authpb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var AuthClient authpb.AuthServiceClient

func InitAuthClient() error {
	addr, err := shared_env.GetAuthClientURL()
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

	AuthClient = authpb.NewAuthServiceClient(conn)
	return nil
}
