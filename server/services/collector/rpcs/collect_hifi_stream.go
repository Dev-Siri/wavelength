package collector_rpcs

import (
	"context"
	"os"
	"sync"

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

	logging.Logger.Debug("Operating on Tidal Hi-Fi stream manifest (base64).",
		zap.Int("manifestLength", len(hifiManifest.Data.Manifest)),
		zap.String("manifestMimeType", hifiManifest.Data.ManifestMimeType),
		zap.String("audioQuality", string(hifiManifest.Data.AudioQuality)),
	)

	downloadedLosslessFilePath, err := mediapipe.DownloadHighResAudio(&hifiManifest.Data)
	if err != nil {
		logging.Logger.Error("Hi-fi stream download failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Hi-fi stream download failed.")
	}

	defer os.Remove(downloadedLosslessFilePath)

	var wg sync.WaitGroup
	errorChan := make(chan error, 3)

	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	wg.Go(func() {
		select {
		case <-ctx.Done():
			return
		default:
		}

		aac256Path, err := mediapipe.ReencodeToAAC(ctx, downloadedLosslessFilePath, mediapipe.FFmpegBitrate256)
		if err != nil {
			errorChan <- err
			cancel()
			return
		}

		defer os.Remove(aac256Path)

		select {
		case <-ctx.Done():
			return
		default:
		}

		hls256Dir, err := mediapipe.RemuxToHLS(ctx, aac256Path)
		if err != nil {
			errorChan <- err
			cancel()
			return
		}

		defer os.RemoveAll(hls256Dir)

		select {
		case <-ctx.Done():
			return
		default:
		}

		if err := mediapipe.UploadHlsStream(ctx, universalIDs.ISRC, hls256Dir, shared_db.BaseHifiStreamsBucketName); err != nil {
			errorChan <- err
			cancel()
			return
		}
	})

	wg.Go(func() {
		select {
		case <-ctx.Done():
			return
		default:
		}

		aac320Path, err := mediapipe.ReencodeToAAC(ctx, downloadedLosslessFilePath, mediapipe.FFmpegBitrate320)
		if err != nil {
			errorChan <- err
			cancel()
			return
		}

		defer os.Remove(aac320Path)

		select {
		case <-ctx.Done():
			return
		default:
		}

		hls320Dir, err := mediapipe.RemuxToHLS(ctx, aac320Path)
		if err != nil {
			errorChan <- err
			cancel()
			return
		}

		defer os.RemoveAll(hls320Dir)

		select {
		case <-ctx.Done():
			return
		default:
		}

		if err := mediapipe.UploadHlsStream(ctx, universalIDs.ISRC, hls320Dir, shared_db.TopHifiStreamsBucketName); err != nil {
			errorChan <- err
			cancel()
			return
		}
	})

	if hifiManifest.Data.AudioQuality == tidal.AudioQualityLossless ||
		hifiManifest.Data.AudioQuality == tidal.AudioQualityHiResLossless {
		wg.Go(func() {
			select {
			case <-ctx.Done():
				return
			default:
			}

			losslessDir, err := mediapipe.RemuxToHLS(ctx, downloadedLosslessFilePath)
			if err != nil {
				errorChan <- err
				cancel()
				return
			}

			defer os.RemoveAll(losslessDir)

			select {
			case <-ctx.Done():
				return
			default:
			}

			if err := mediapipe.UploadHlsStream(ctx, universalIDs.ISRC, losslessDir, shared_db.LosslessStreamBucketName); err != nil {
				errorChan <- err
				cancel()
				return
			}
		})
	}

	wg.Wait()
	close(errorChan)

	for err := range errorChan {
		if err != nil {
			logging.Logger.Error("Hi-Fi extract failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Hi-Fi extract failed.")
		}
	}

	tx, err := shared_db.Database.BeginTx(ctx, nil)
	if err != nil {
		logging.Logger.Error("Transaction open failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Transaction open failed.")
	}

	defer tx.Rollback()

	_, err = tx.Exec(`
		UPDATE "stream_metadata"
		SET is_hifi_available = TRUE
		WHERE video_id = $1;
	`, request.VideoId)
	if err != nil {
		logging.Logger.Error("Stream metadata Hi-Fi availability update failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Stream metadata Hi-Fi availability update failed.")
	}

	if hifiManifest.Data.AudioQuality == tidal.AudioQualityLossless ||
		hifiManifest.Data.AudioQuality == tidal.AudioQualityHiResLossless {
		var bitType types.LosslessBitType
		if hifiManifest.Data.AudioQuality == tidal.AudioQualityLossless {
			bitType = types.LosslessBitType16Bit
		} else {
			bitType = types.LosslessBitType24Bit
		}

		_, err = tx.Exec(`
		UPDATE "stream_metadata"
		SET is_lossless_available = $2
		WHERE video_id = $1;
	`, request.VideoId, bitType)
		if err != nil {
			logging.Logger.Error("Stream metadata lossless availability update failed.", zap.Error(err))
			return nil, status.Error(codes.Internal, "Stream metadata lossless availability update failed.")
		}
	}

	if err := tx.Commit(); err != nil {
		logging.Logger.Error("Stream metadata transaction commit failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Stream metadata transaction commit failed.")
	}

	return &emptypb.Empty{}, nil
}
