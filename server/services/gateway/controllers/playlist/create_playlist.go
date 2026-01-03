package playlist_controllers

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func CreatePlaylist(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	_, err := clients.PlaylistClient.CreatePlaylist(ctx.Context(), &playlistpb.CreatePlaylistRequest{
		AuthorEmail:       authUser.Email,
		AuthorDisplayName: authUser.DisplayName,
		AuthorPhotoUrl:    authUser.PhotoUrl,
	})
	if err != nil {
		go logging.Logger.Error("PlaylistService: 'CreatePlaylist' errored", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to create playlist.")
	}

	return models.Success(ctx, "Created new playlist for "+authUser.Email)
}
