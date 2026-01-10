package music_controllers

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

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
		go logging.Logger.Error("MusicService: 'SearchMusicVideos' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "YouTube videos search fetch failed.")
	}

	return models.Success(ctx, youtubeVideosSearchResponse)
}
