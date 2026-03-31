package collector_rpcs

import (
	"context"

	"github.com/Dev-Siri/wavelength/server/proto/collectorpb"
	"github.com/Dev-Siri/wavelength/server/services/collector/mediapipe"
	"github.com/Dev-Siri/wavelength/server/services/player/types"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/Dev-Siri/wavelength/server/shared/tidal"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

func (c *CollectorService) CollectHifiStream(
	ctx context.Context,
	request *collectorpb.CollectHifiStreamRequest,
) (*emptypb.Empty, error) {
	universalIDs, err := tidal.Hifi.FetchUniversalIDs(ctx, request.VideoId)
	if err != nil {
		logging.Logger.Error("Tidal track ID fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Tidal track ID fetch failed.")
	}

	hifiManifest, err := tidal.Hifi.GetLosslessManifest(universalIDs.TidalID)
	if err != nil {
		logging.Logger.Error("Hi-fi stream manifest fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Hi-fi stream fetch failed.")
	}

	logging.Logger.Debug("Operating on Tidal Hi-Fi stream manifest (base64).", zap.String("manifest", hifiManifest.Data.Manifest))

	downloadedLosslessFilePath, err := mediapipe.DownloadHighResAudio(&hifiManifest.Data)
	if err != nil {
		logging.Logger.Error("Hi-fi stream download failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Hi-fi stream download failed.")
	}

	aac256Path, err := mediapipe.ReencodeToAAC(downloadedLosslessFilePath, mediapipe.FFmpegBitrate256)
	if err != nil {
		logging.Logger.Error("Re-encode to 256k AAC failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Re-encode to 256k AAC failed.")
	}

	hls256Dir, err := mediapipe.RemuxToHLS(aac256Path)
	if err != nil {
		logging.Logger.Error("Remuxing 256k AAC to HLS failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Remuxing 256k AAC to HLS failed.")
	}

	if err := mediapipe.UploadHlsStream(universalIDs.ISRC, hls256Dir, shared_db.BaseHifiStreamsBucketName); err != nil {
		logging.Logger.Error("256k (AAC) HLS stream upload failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "256k (AAC) HLS stream upload failed.")
	}

	aac320Path, err := mediapipe.ReencodeToAAC(downloadedLosslessFilePath, mediapipe.FFmpegBitrate320)
	if err != nil {
		logging.Logger.Error("Re-encode to 320k AAC failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Re-encode to 320k AAC failed.")
	}

	hls320Dir, err := mediapipe.RemuxToHLS(aac320Path)
	if err != nil {
		logging.Logger.Error("Remuxing 320k AAC to HLS failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Remuxing 320k AAC to HLS failed.")
	}

	if err := mediapipe.UploadHlsStream(universalIDs.ISRC, hls320Dir, shared_db.TopHifiStreamsBucketName); err != nil {
		logging.Logger.Error("320k (AAC) HLS stream upload failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "320k (AAC) HLS stream upload failed.")
	}

	losslessDir, err := mediapipe.RemuxToHLS(downloadedLosslessFilePath)
	if err != nil {
		logging.Logger.Error("Remuxing lossless (FLAC) to HLS failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Remuxing lossless (FLAC) to HLS failed.")
	}

	if err := mediapipe.UploadHlsStream(universalIDs.ISRC, losslessDir, shared_db.LosslessStreamBucketName); err != nil {
		logging.Logger.Error("Lossless (FLAC) HLS stream upload failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Lossless (FLAC) HLS stream upload failed.")
	}

	var bitType types.LosslessBitType
	if hifiManifest.Data.AudioQuality == "LOSSLESS" {
		bitType = types.LosslessBitType16Bit
	} else {
		bitType = types.LosslessBitType24Bit
	}

	_, err = shared_db.StreamDatabase.Exec(`
		UPDATE "stream_metadata"
		SET is_hifi_available = TRUE, is_lossless_available = $2
		WHERE video_id = $1;
	`, request.VideoId, bitType)
	if err != nil {
		logging.Logger.Error("Stream metadata Hi-fi, Lossless availability update failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Stream metadata Hi-fi, Lossless availability update failed.")
	}

	return &emptypb.Empty{}, nil
}
