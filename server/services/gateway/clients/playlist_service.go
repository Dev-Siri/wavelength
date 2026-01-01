package clients

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/env"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var PlaylistClient playlistpb.PlaylistServiceClient

func InitPlaylistClient() error {
	addr, err := env.GetPlaylistClientURL()
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

	PlaylistClient = playlistpb.NewPlaylistServiceClient(conn)
	return nil
}
