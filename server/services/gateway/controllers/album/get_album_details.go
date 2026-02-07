package album_controllers

import (
	"wavelength/proto/albumpb"
	"wavelength/services/gateway/models"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetAlbumDetails(ctx *fiber.Ctx) error {
	albumId := ctx.Params("albumId")

	if albumId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Album ID is required for searching albums.")
	}

	albumDetailsResponse, err := shared_clients.AlbumClient.GetAlbumDetails(ctx.Context(), &albumpb.GetAlbumDetailsRequest{
		AlbumId: albumId,
	})
	if err != nil {
		logging.Logger.Error("AlbumService: 'GetAlbumDetails' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Album details fetch failed.")
	}

	return models.Success(ctx, albumDetailsResponse)
}
