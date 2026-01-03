package music_controllers

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetMusicTrackStats(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	musicTrackStats, err := clients.MusicClient.GetMusicTrackStats(ctx.Context(), &musicpb.GetMusicTrackStatsRequest{
		VideoId: videoId,
	})
	if err != nil {
		go logging.Logger.Error("MusicService: 'GetMusicTrackStats' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Track statistics fetch from YouTube failed.")
	}

	return models.Success(ctx, musicTrackStats)
}
