package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func ChangePlaylistVisibility(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	_, err := clients.PlaylistClient.ChangePlaylistVisibility(ctx.Context(), &playlistpb.ChangePlaylistVisibilityRequest{
		PlaylistId:    playlistId,
		AuthUserEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("Playlist visibility change failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist visibility change failed.")
	}

	return models.Success(ctx, "Visibility toggled of playlist with ID: "+playlistId)
}
