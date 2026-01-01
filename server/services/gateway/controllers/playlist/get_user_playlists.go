package playlist_controllers

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetUserPlaylists(ctx *fiber.Ctx) error {
	email := ctx.Params("email")

	if email == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Email is required.")
	}

	playlistsResponse, err := clients.PlaylistClient.GetUserPlaylists(ctx.Context(), &playlistpb.GetUserPlaylistsRequest{
		UserEmail: email,
	})
	if err != nil {
		go logging.Logger.Error("PlaylistService: 'GetUserPlaylists' errored", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlists fetch failed.")
	}

	return ctx.JSON(models.Success(playlistsResponse.Playlists))
}
