package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func SearchYouTubeVideos(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching YouTube videos.")
	}

	youtubeVideosSearchResponse, err := clients.MusicClient.SearchYouTubeVideos(ctx.Context(), &musicpb.SearchYouTubeVideosRequest{
		Query: query,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'SearchMusicVideos' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "YouTube videos search fetch failed.")
	}

	return shared_models.Success(ctx, youtubeVideosSearchResponse)
}
