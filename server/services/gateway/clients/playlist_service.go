package clients

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/env"
	shared_clients "wavelength/shared/clients"

	"google.golang.org/grpc"
)

var PlaylistClient playlistpb.PlaylistServiceClient

func InitPlaylistClient() error {
	addr, err := env.GetPlaylistClientURL()
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

	PlaylistClient = playlistpb.NewPlaylistServiceClient(conn)
	return nil
}
