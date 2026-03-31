package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetUpNext(ctx *fiber.Ctx) error {
	videoID := ctx.Params("videoId")
	if videoID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	upNextResponse, err := clients.MusicClient.GetUpNext(ctx.Context(), &musicpb.GetUpNextRequest{
		VideoId: videoID,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'GetUpNext' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Up next fetch failed.")
	}

	return shared_models.Success(ctx, upNextResponse)
}
