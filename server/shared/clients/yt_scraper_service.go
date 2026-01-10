package shared_clients

import (
	"wavelength/proto/yt_scraperpb"
	shared_env "wavelength/shared/env"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var YtScraperClient yt_scraperpb.YTScraperClient

func InitYtScraperClient() error {
	addr, err := shared_env.GetYTScraperURL()
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

	YtScraperClient = yt_scraperpb.NewYTScraperClient(conn)
	return nil
}
