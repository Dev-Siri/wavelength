package album_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetAlbumLiveCover(ctx *fiber.Ctx) error {
	videoID := ctx.Params("videoId")
	if videoID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	albumID := ctx.Params("albumId")
	if albumID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Album ID is required.")
	}

	albumLiveCoverResponse, err := clients.AlbumClient.GetAlbumLiveCover(ctx.Context(), &albumpb.GetAlbumLiveCoverRequest{
		VideoId: videoID,
		AlbumId: albumID,
	})
	if err != nil {
		logging.Logger.Error("AlbumClient: 'GetAlbumLiveCover' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Live album cover fetch failed.")
	}
	return shared_models.Success(ctx, albumLiveCoverResponse)
}
