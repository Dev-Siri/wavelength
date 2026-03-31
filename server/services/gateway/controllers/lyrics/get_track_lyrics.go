package lyrics_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/lyricspb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetTrackLyrics(ctx *fiber.Ctx) error {
	videoID := ctx.Params("videoId")
	if videoID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	lyrics, err := clients.LyricClient.GetTrackLyrics(ctx.Context(), &lyricspb.GetTrackLyricsRequest{
		VideoId: videoID,
	})
	if err != nil {
		logging.Logger.Error("LyricService: 'GetTrackLyrics' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Lyrics fetch failed.")
	}

	return shared_models.Success(ctx, lyrics)
}
