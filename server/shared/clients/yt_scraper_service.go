package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var YtScraperClient yt_scraperpb.YTScraperClient

func InitYtScraperClient() error {
	addr, err := shared_env.GetYTScraperURL()
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

	YtScraperClient = yt_scraperpb.NewYTScraperClient(conn)
	return nil
}
