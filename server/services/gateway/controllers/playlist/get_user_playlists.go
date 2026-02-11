package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

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
		logging.Logger.Error("PlaylistService: 'GetUserPlaylists' errored", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlists fetch failed.")
	}

	return models.Success(ctx, playlistsResponse)
}
