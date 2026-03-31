package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func CreatePlaylist(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	_, err := clients.PlaylistClient.CreatePlaylist(ctx.Context(), &playlistpb.CreatePlaylistRequest{
		AuthorEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'CreatePlaylist' errored", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to create playlist.")
	}

	return shared_models.Success(ctx, "Created new playlist for "+authUser.Email)
}
