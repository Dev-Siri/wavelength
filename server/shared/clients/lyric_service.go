package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/lyricspb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"
	"google.golang.org/grpc"
)

var LyricClient lyricspb.LyricServiceClient

func InitLyricClient() error {
	addr, err := shared_env.GetLyricClientURL()
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

	LyricClient = lyricspb.NewLyricServiceClient(conn)
	return nil
}
