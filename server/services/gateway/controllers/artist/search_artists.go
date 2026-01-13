package artist_controllers

import (
	"wavelength/proto/artistpb"
	"wavelength/services/gateway/models"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func SearchArtists(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching artists.")
	}

	searchResults, err := shared_clients.ArtistClient.SearchArtists(ctx.Context(), &artistpb.SearchArtistsRequest{
		Query: query,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'SearchArtists' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artists search failed.")
	}

	return models.Success(ctx, searchResults)
}
