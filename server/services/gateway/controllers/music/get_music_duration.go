package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetMusicDuration(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	durationResponse, err := clients.MusicClient.GetMusicDuration(ctx.Context(), &musicpb.GetMusicDurationRequest{
		VideoId: videoId,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'GetMusicDuration' errored", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Duration fetch from YouTube failed.")
	}

	return models.Success(ctx, durationResponse)
}
