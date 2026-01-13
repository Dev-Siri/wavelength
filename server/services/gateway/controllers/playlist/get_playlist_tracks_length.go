package playlist_controllers

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPlaylistTracksLength(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")

	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	tracksLengthResponse, err := clients.PlaylistClient.GetPlaylistTracksLength(ctx.Context(), &playlistpb.PlaylistTracksLengthRequest{
		PlaylistId: playlistId,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'GetPlaylistTracksLength' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlists tracks length fetch failed.")
	}

	return models.Success(ctx, tracksLengthResponse)
}
