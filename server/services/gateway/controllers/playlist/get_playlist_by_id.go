package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPlaylistById(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	playlistResponse, err := clients.PlaylistClient.GetPlaylistById(ctx.Context(), &playlistpb.GetPlaylistByIdRequest{
		PlaylistId: playlistId,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'GetPlaylistById' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist fetch failed.")
	}

	return shared_models.Success(ctx, playlistResponse)
}
