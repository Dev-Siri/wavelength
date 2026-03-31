package music_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetUpNext(
	ctx context.Context,
	request *musicpb.GetUpNextRequest,
) (*musicpb.GetUpNextResponse, error) {
	upNextResponse, err := clients.YtScraperClient.GetUpNext(ctx, &yt_scraperpb.GetUpNextRequest{
		VideoId: request.VideoId,
		Automix: true,
	})
	if err != nil {
		logging.Logger.Error("Up next fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Up next fetch failed.")
	}

	return &musicpb.GetUpNextResponse{
		Tracks: upNextResponse.Tracks,
	}, nil
}
