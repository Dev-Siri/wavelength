package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var ArtistClient artistpb.ArtistServiceClient

func InitArtistClient() error {
	addr, err := shared_env.GetArtistClientURL()
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

	ArtistClient = artistpb.NewArtistServiceClient(conn)
	return nil
}
