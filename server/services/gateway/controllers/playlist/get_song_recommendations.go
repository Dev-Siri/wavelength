package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetSongRecommendations(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")
	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	playlistSongRecommendations, err := clients.PlaylistClient.GetSongRecommendations(ctx.Context(), &playlistpb.GetSongRecommendationsRequest{
		PlaylistId: playlistId,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'GetSongRecommendations' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist song recommendations fetched failed.")
	}

	return models.Success(ctx, playlistSongRecommendations)
}
