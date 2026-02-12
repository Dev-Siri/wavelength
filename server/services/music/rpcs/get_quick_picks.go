package music_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/proto/yt_scraperpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_constants "github.com/Dev-Siri/wavelength/server/shared/constants"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
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

	response := &musicpb.GetQuickPicksResponse{
		QuickPicks: quickPicksResponse.QuickPicks,
	}

	if err := saveQuickPicksToCache(ctx, request.Ip, response); err != nil {
		logging.Logger.Error("Quick picks cache failed.")
	}

	return response, nil
}

func saveQuickPicksToCache(
	ctx context.Context,
	ip string,
	response *musicpb.GetQuickPicksResponse,
) error {
	_, err := shared_db.Redis.JSONSet(ctx, shared_constants.MusicQuickPicksKey.K(ip), "$", response).Result()
	return err
}
