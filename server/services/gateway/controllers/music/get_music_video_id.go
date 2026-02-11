package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

// NOTE:
/*
  The "Music Video ID Route" is at best, a guesser. It can only try to accurately
  match the song name or artist name to get the actual music video. But there are many times it
  may not be accurate. So a wrong music video or even a short can get selected. Since YouTube doesn't provide any
  filters (music video, track or normal video) whatsoever for these use cases.
*/
func GetMusicVideoPreviewId(ctx *fiber.Ctx) error {
	songTitle := ctx.Query("title")
	artist := ctx.Query("artist")

	if songTitle == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Song Title (title) search param is required.")
	}

	if artist == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Artist (artist) search param is required.")
	}

	musicVideoPreviewResponse, err := clients.MusicClient.GetMusicVideoId(ctx.Context(), &musicpb.GetMusicVideoIdRequest{
		Title:  songTitle,
		Artist: artist,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'GetMusicVideoId' errored", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Music video fetch from YouTube failed.")
	}

	return models.Success(ctx, musicVideoPreviewResponse)
}
