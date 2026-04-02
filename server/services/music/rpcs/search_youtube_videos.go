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

func (m *MusicService) SearchYouTubeVideos(
	ctx context.Context,
	request *musicpb.SearchYouTubeVideosRequest,
) (*musicpb.SearchYouTubeVideosResponse, error) {
	videosResponse, err := clients.YtScraperClient.SearchYouTubeVideos(ctx, &yt_scraperpb.SearchYouTubeVideosRequest{
		Query: request.Query,
	})
	if err != nil {
		logging.Logger.Error("YouTube videos fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "YouTube videos fetch failed.")
	}

	if len(videosResponse.Videos) == 0 {
		return nil, status.Error(codes.NotFound, "No search results for that query.")
	}

	return &musicpb.SearchYouTubeVideosResponse{
		YoutubeVideos: videosResponse.Videos,
	}, nil
}
