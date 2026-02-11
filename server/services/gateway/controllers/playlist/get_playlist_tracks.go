package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPlaylistTracks(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	playlistTracksResponse, err := clients.PlaylistClient.GetPlaylistTracks(ctx.Context(), &playlistpb.GetPlaylistTracksRequest{
		PlaylistId: playlistId,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'GetPlaylistTracks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist tracks fetched failed.")
	}

	return models.Success(ctx, playlistTracksResponse)
}
