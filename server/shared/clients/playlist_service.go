package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var PlaylistClient playlistpb.PlaylistServiceClient

func InitPlaylistClient() error {
	addr, err := shared_env.GetPlaylistClientURL()
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
