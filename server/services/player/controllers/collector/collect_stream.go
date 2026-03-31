package collector_controllers

import (
	"database/sql"

	"github.com/Dev-Siri/wavelength/server/proto/collectorpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func CollectStream(ctx *fiber.Ctx) error {
	videoID := ctx.Params("videoId")
	if videoID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	isInDatabase, err := isStreamAlreadyInDatabase(videoID)
	if err != nil {
		logging.Logger.Error("Stream existence check failed.", zap.Error(err))
		return err
	}

	if !isInDatabase {
		_, err := clients.CollectorClient.CollectYouTubeStream(ctx.Context(), &collectorpb.CollectYouTubeStreamRequest{
			VideoId: videoID,
		})
		if err != nil {
			logging.Logger.Error("CollectorClient: 'CollectYouTubeStream' errored", zap.Error(err))
			return fiber.NewError(fiber.StatusInternalServerError, "Adaptive stream extract failed.")
		}
	}

	isHifiInDatabase, err := isHifiStreamAlreadyInDatabase(videoID)
	if err != nil {
		logging.Logger.Error("Hi-Fi Stream existence check failed.", zap.Error(err))
		return err
	}

	if !isHifiInDatabase {
		_, err := clients.CollectorClient.CollectHifiStream(ctx.Context(), &collectorpb.CollectHifiStreamRequest{
			VideoId: videoID,
		})
		if err != nil {
			logging.Logger.Error("CollectorClient: 'CollectHifiStream' errored.", zap.Error(err))
			return fiber.NewError(fiber.StatusInternalServerError, "Hi-fi stream extract failed.")
		}
	}

	return shared_models.Success(ctx.Status(fiber.StatusAccepted), "Recorded.")
}

func isStreamAlreadyInDatabase(videoID string) (bool, error) {
	row := shared_db.StreamDatabase.QueryRow(`
		SELECT COUNT(*) FROM "stream_metadata"
		WHERE video_id = $1;
	`, videoID)

	var streamCount int
	if err := row.Scan(&streamCount); err != nil {
		if err == sql.ErrNoRows {
			return false, nil
		}

		return false, err
	}

	return streamCount > 0, nil
}

func isHifiStreamAlreadyInDatabase(videoID string) (bool, error) {
	row := shared_db.StreamDatabase.QueryRow(`
		SELECT COUNT(*) FROM "stream_metadata"
		WHERE video_id = $1 AND is_hifi_available = TRUE;
	`, videoID)

	var hifiStreamCount int
	if err := row.Scan(&hifiStreamCount); err != nil {
		if err == sql.ErrNoRows {
			return false, nil
		}

		return false, err
	}

	return hifiStreamCount > 0, nil
}
