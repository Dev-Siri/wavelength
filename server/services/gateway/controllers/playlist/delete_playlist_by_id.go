package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func DeletePlaylistById(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	playlistId := ctx.Params("playlistId")

	_, err := clients.PlaylistClient.DeletePlaylist(ctx.Context(), &playlistpb.DeletePlaylistRequest{
		PlaylistId:    playlistId,
		AuthUserEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'DeletePlaylist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist deletion failed.")
	}

	return shared_models.Success(ctx, "Deleted playlist with ID "+playlistId)
}
