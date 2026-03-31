package album_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"
	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetIsAlbumLossless(ctx *fiber.Ctx) error {
	albumID := ctx.Params("albumId")
	if albumID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Album ID is required.")
	}

	albumLosslessAvailabilityResponse, err := clients.AlbumClient.IsAlbumLossless(ctx.Context(), &albumpb.IsAlbumLosslessRequest{
		AlbumId: albumID,
	})
	if err != nil {
		logging.Logger.Error("AlbumService: 'IsAlbumLossless' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Album lossless availability fetch failed.")
	}

	return shared_models.Success(ctx, albumLosslessAvailabilityResponse)
}
