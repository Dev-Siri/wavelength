package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPlaylistTracks(ctx *fiber.Ctx) error {
	playlistId := ctx.Params("playlistId")
	if playlistId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Playlist ID is required.")
	}

	q := ctx.Query("q")
	var query *string
	if q != "" {
		query = &q
	}

	playlistTracksResponse, err := clients.PlaylistClient.GetPlaylistTracks(ctx.Context(), &playlistpb.GetPlaylistTracksRequest{
		PlaylistId: playlistId,
		Query:      query,
	})
	if err != nil {
		logging.Logger.Error("PlaylistService: 'GetPlaylistTracks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Playlist tracks fetched failed.")
	}

	return shared_models.Success(ctx, playlistTracksResponse)
}
