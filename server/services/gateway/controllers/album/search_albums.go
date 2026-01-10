package album_controllers

import (
	"wavelength/proto/albumpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func SearchAlbums(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching albums.")
	}

	albumSearchResponse, err := clients.AlbumClient.SearchAlbums(ctx.Context(), &albumpb.SearchAlbumsRequest{
		Query: query,
	})
	if err != nil {
		go logging.Logger.Error("AlbumService: 'SearchAlbums' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Albums search failed.")
	}

	return models.Success(ctx, albumSearchResponse)
}
