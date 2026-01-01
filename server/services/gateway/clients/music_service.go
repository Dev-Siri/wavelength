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

	conn, err := grpc.NewClient(
		addr,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return err
	}

	MusicClient = musicpb.NewMusicServiceClient(conn)
	return nil
}
