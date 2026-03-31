package playlist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/playlistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPublicPlaylists(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	publicPlaylistsResponse, err := clients.PlaylistClient.GetPublicPlaylists(ctx.Context(), &playlistpb.GetPublicPlaylistsRequest{
		Query: query,
	})
	if err != nil {
		logging.Logger.Error("Public playlists fetch failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Public playlists fetch failed.")
	}

	return shared_models.Success(ctx, publicPlaylistsResponse)
}
