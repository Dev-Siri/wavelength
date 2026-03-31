package collector_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/collectorpb"
	"github.com/Dev-Siri/wavelength/server/services/collector/mediapipe"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/google/uuid"
	"github.com/lrstanley/go-ytdlp"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (c *CollectorService) CollectYouTubeStream(
	ctx context.Context,
	request *collectorpb.CollectYouTubeStreamRequest,
) (*emptypb.Empty, error) {
	metadata, err := mediapipe.FetchYouTubeURL(ctx, request.VideoId)
	if err != nil {
		logging.Logger.Error("Stream metadata fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Stream metadata fetch failed.")
	}

	if len(metadata) == 0 {
		logging.Logger.Error("yt-dlp returned empty metadata list")
		return nil, status.Error(codes.Internal, "yt-dlp returned no metadata")
	}

	requiredMetadata := metadata[0]

	if requiredMetadata.URL == nil {
		logging.Logger.Error("Missing stream URL from yt-dlp metadata")
		return nil, status.Error(codes.Internal, "yt-dlp returned nil stream URL")
	}

	url := requiredMetadata.URL
	if url == nil {
		logging.Logger.Error("Missing stream URL.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Missing stream URL.")
	}

	hlsDir, err := mediapipe.RemuxToHLS(*url)
	if err != nil {
		logging.Logger.Error("Stream remux to HLS failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Stream remux to HLS failed.")
	}

	if err := mediapipe.UploadHlsStream(request.VideoId, hlsDir, shared_db.AdaptiveStreamsBucketName); err != nil {
		logging.Logger.Error("HLS stream upload failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "HLS stream upload failed.")
	}

	if err := addToDatabase(metadata, request.VideoId); err != nil {
		logging.Logger.Error("Recording stream entry in database failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "HLS stream upload failed.")
	}

	return &emptypb.Empty{}, nil
}

func addToDatabase(metadata []*ytdlp.ExtractedInfo, videoID string) error {
	streamID := uuid.NewString()
	format := metadata[0]

	if format.ABR == nil {
		abr := 128.000
		format.ABR = &abr
	}

	if format.ACodec == nil {
		acodec := "opus"
		format.ACodec = &acodec
	}

	if format.Container == nil {
		container := "webm_dash"
		format.Container = &container
	}

	_, err := shared_db.StreamDatabase.Exec(`
		INSERT INTO "stream_metadata" (
			stream_id,
			video_id,
			bitrate,
			codec,
			container,
			duration_seconds
		) VALUES ( $1, $2, $3, $4, $5, $6 );
	`, streamID, videoID, format.ABR, format.ACodec, format.Container, format.Duration)
	return err
}
