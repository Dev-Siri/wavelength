package collector_rpcs

import "github.com/Dev-Siri/wavelength/server/proto/collectorpb"

type CollectorService struct {
	collectorpb.UnimplementedCollectorServiceServer
}

func NewCollectorService() *CollectorService {
	return &CollectorService{}
}
