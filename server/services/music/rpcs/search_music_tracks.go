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

func (m *MusicService) SearchMusicTracks(
	ctx context.Context,
	request *musicpb.SearchMusicTracksRequest,
) (*musicpb.SearchMusicTracksResponse, error) {
	tracksSearchResponse, err := clients.YtScraperClient.SearchTracks(ctx, &yt_scraperpb.SearchTracksRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("Tracks search failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Tracks search failed.")
	}

	return &musicpb.SearchMusicTracksResponse{
		Tracks: tracksSearchResponse.Tracks,
	}, nil
}
