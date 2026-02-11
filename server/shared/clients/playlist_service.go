package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var PlaylistClient playlistpb.PlaylistServiceClient

func InitPlaylistClient() error {
	addr, err := env.GetPlaylistClientURL()
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

	PlaylistClient = playlistpb.NewPlaylistServiceClient(conn)
	return nil
}
