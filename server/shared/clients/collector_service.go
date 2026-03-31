package clients

import (
	"github.com/Dev-Siri/wavelength/server/proto/collectorpb"
	shared_env "github.com/Dev-Siri/wavelength/server/shared/env"
	"github.com/Dev-Siri/wavelength/server/shared/security"

	"google.golang.org/grpc"
)

var CollectorClient collectorpb.CollectorServiceClient

func InitCollectorClient() error {
	addr, err := shared_env.GetCollectorClientURL()
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

	CollectorClient = collectorpb.NewCollectorServiceClient(conn)
	return nil
}
