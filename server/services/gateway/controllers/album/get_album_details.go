package album_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/albumpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetAlbumDetails(ctx *fiber.Ctx) error {
	albumId := ctx.Params("albumId")

	if albumId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Album ID is required for searching albums.")
	}

	albumDetailsResponse, err := clients.AlbumClient.GetAlbumDetails(ctx.Context(), &albumpb.GetAlbumDetailsRequest{
		AlbumId: albumId,
	})
	if err != nil {
		logging.Logger.Error("AlbumService: 'GetAlbumDetails' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Album details fetch failed.")
	}

	return shared_models.Success(ctx, albumDetailsResponse)
}
