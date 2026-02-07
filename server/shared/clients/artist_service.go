package shared_clients

import (
	"wavelength/proto/artistpb"
	shared_env "wavelength/shared/env"

	"google.golang.org/grpc"
)

var ArtistClient artistpb.ArtistServiceClient

func InitArtistClient() error {
	addr, err := shared_env.GetArtistClientURL()
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

	ArtistClient = artistpb.NewArtistServiceClient(conn)
	return nil
}
