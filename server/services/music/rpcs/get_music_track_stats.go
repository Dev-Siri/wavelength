package music_rpcs

import (
	"context"
	"wavelength/proto/commonpb"
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/api"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetMusicTrackStats(
	ctx context.Context,
	request *musicpb.GetMusicTrackStatsRequest,
) (*musicpb.GetMusicTrackStatsResponse, error) {
	response, err := api.YouTubeV3Client.Videos.List([]string{"statistics"}).Id(request.VideoId).Do()

	if err != nil {
		go logging.Logger.Error("Track statistics fetch from YouTube failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Track statistics fetch from YouTube failed.")
	}

	stats := response.Items[0].Statistics

	return &musicpb.GetMusicTrackStatsResponse{
		MusicTrackStats: &commonpb.MusicTrackStats{
			ViewCount:    stats.ViewCount,
			LikeCount:    stats.LikeCount,
			CommentCount: stats.CommentCount,
		},
	}, nil
}
