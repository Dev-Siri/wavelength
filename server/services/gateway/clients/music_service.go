package clients

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/env"
	shared_clients "wavelength/shared/clients"

	"google.golang.org/grpc"
)

var MusicClient musicpb.MusicServiceClient

func InitMusicClient() error {
	addr, err := env.GetMusicClientURL()
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

	MusicClient = musicpb.NewMusicServiceClient(conn)
	return nil
}
