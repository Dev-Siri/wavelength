package clients

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/env"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var MusicClient musicpb.MusicServiceClient

func InitMusicClient() error {
	addr, err := env.GetMusicClientURL()
	if err != nil {
		return err
	}

	creds := insecure.NewCredentials()
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
