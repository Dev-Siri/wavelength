package stream_controllers

import (
	"github.com/Dev-Siri/wavelength/server/services/player/types"
	shared_db "github.com/Dev-Siri/wavelength/server/shared/db"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

type playabilityStatusResponse struct {
	PlayabilityStatus types.PlayabilityStatus `json:"playabilityStatus"`
}

func GetStreamPlayabilityStatus(ctx *fiber.Ctx) error {
	_, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return shared_models.Success(ctx, playabilityStatusResponse{
			PlayabilityStatus: types.PlayabilityStatusUnplayable,
		})
	}

	videoID := ctx.Params("videoId")
	if videoID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	row := shared_db.StreamDatabase.QueryRowContext(ctx.Context(), `
		SELECT COUNT(*) FROM "stream_metadata"
		WHERE video_id = $1;
	`, videoID)

	var streamCount int
	if err := row.Scan(&streamCount); err != nil {
		logging.Logger.Error("Stream count read failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Stream count read failed.")
	}

	var playabilityStatus types.PlayabilityStatus
	if streamCount > 0 {
		playabilityStatus = types.PlayabilityStatusPlayable
	} else {
		playabilityStatus = types.PlayabilityStatusUnavailable
	}

	return shared_models.Success(ctx, playabilityStatusResponse{
		PlayabilityStatus: playabilityStatus,
	})
}
