package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPlaylistTracksLikedStatus(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")
	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	playlistTracksLikedStatus, err := clients.PlaylistClient.GetPlaylistTracksLikedStatus(ctx.Context(), &playlistpb.GetPlaylistTracksLikedStatusRequest{
		PlaylistId: playlistId,
		LikerEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'GetPlaylistTracksLikedStatus' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlists tracks liked status fetch failed.")
	}

	return shared_models.Success(ctx, playlistTracksLikedStatus)
}
