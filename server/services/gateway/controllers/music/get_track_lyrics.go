package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetTrackLyrics(ctx *fiber.Ctx) error {
	title := ctx.Query("title")
	if title == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Title is required.")
	}

	artist := ctx.Query("artist")
	if artist == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Artist is required.")
	}

	lyrics, err := clients.MusicClient.GetMusicLyrics(ctx.Context(), &musicpb.GetMusicLyricsRequest{
		Title:  title,
		Artist: artist,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'GetMusicLyrics' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Lyrics fetch failed.")
	}

	return models.Success(ctx, lyrics)
}
