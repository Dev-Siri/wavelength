package playlist_controllers

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

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
		go logging.Logger.Error("Playlist visibility change failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist visibility change failed.")
	}

	return ctx.JSON(models.Success("Visibility toggled of playlist with ID: " + playlistId))
}
