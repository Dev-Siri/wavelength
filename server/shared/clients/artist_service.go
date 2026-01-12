package shared_clients

import (
	"wavelength/proto/artistpb"
	"wavelength/services/gateway/env"

	"google.golang.org/grpc"
)

var ArtistClient artistpb.ArtistServiceClient

func InitArtistClient() error {
	addr, err := env.GetArtistClientURL()
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
