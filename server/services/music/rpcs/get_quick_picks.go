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

func (m *MusicService) GetQuickPicks(
	ctx context.Context,
	request *musicpb.GetQuickPicksRequest,
) (*musicpb.GetQuickPicksResponse, error) {
	quickPicksResponse, err := clients.YtScraperClient.GetQuickPicks(ctx, &yt_scraperpb.GetQuickPicksRequest{
		Gl: request.Gl,
	})
	if err != nil {
		logging.Logger.Error("Quick picks fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Quick picks fetch failed.")
	}

	return &musicpb.GetQuickPicksResponse{
		QuickPicks: quickPicksResponse.QuickPicks,
	}, nil
}
