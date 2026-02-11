package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models/schemas"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func EditPlaylist(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")
	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	var playlistEditBody schemas.PlaylistEditSchema
	if err := ctx.BodyParser(&playlistEditBody); err != nil {
		logging.Logger.Error("Invalid JSON body.", zap.Error(err))
		return fiber.NewError(fiber.StatusBadRequest, "Invalid JSON body.")
	}

	_, err := clients.PlaylistClient.EditPlaylist(ctx.Context(), &playlistpb.EditPlaylistRequest{
		PlaylistId: playlistId,
		Name:       playlistEditBody.Name,
		CoverImage: playlistEditBody.CoverImage,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'EditPlaylist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to edit playlist.")
	}

	return models.Success(ctx, "Edited playlist with ID "+playlistId+" successfully.")
}
