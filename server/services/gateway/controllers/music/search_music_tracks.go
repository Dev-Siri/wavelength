package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func SearchMusicTracks(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching music.")
	}

	tracksSearchResponse, err := clients.MusicClient.SearchMusicTracks(ctx.Context(), &musicpb.SearchMusicTracksRequest{
		Query: query,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'SearchMusicTracks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Music tracks search failed.")
	}

	return models.Success(ctx, tracksSearchResponse)
}
