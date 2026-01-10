package music_rpcs

import (
	"context"
	"wavelength/proto/musicpb"
	"wavelength/services/music/api"
	"wavelength/services/music/utils"
	"wavelength/shared/logging"

	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (m *MusicService) GetMusicDuration(
	ctx context.Context,
	request *musicpb.GetMusicDurationRequest,
) (*musicpb.GetMusicDurationResponse, error) {
	call := api.YouTubeV3Client.Videos.List([]string{"contentDetails"}).Id(request.VideoId)
	response, err := call.Do()

	if err != nil {
		go logging.Logger.Error("Duration fetch from YouTube failed. ", zap.Error(err))
		return nil, status.Error(codes.Internal, "Duration fetch from YouTube failed. ")
	}

	if len(response.Items) == 0 {
		return nil, status.Error(codes.NotFound, "Video not found.")
	}

	durationSeconds := utils.ParseDuration(response.Items[0].ContentDetails.Duration)
	return &musicpb.GetMusicDurationResponse{
		DurationSeconds: uint32(durationSeconds),
	}, nil
}
