package playlist_controllers

import (
	"wavelength/proto/playlistpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetPublicPlaylists(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	publicPlaylistsResponse, err := clients.PlaylistClient.GetPublicPlaylists(ctx.Context(), &playlistpb.GetPublicPlaylistsRequest{
		Query: query,
	})
	if err != nil {
		go logging.Logger.Error("Public playlists fetch failed.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Public playlists fetch failed.")
	}

	return models.Success(ctx, publicPlaylistsResponse.Playlists)
}
