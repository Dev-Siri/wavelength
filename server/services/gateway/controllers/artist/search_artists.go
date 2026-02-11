package artist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func SearchArtists(ctx *fiber.Ctx) error {
	query := ctx.Query("q")

	if query == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Query (q) is required for searching artists.")
	}

	searchResults, err := clients.ArtistClient.SearchArtists(ctx.Context(), &artistpb.SearchArtistsRequest{
		Query: query,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'SearchArtists' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artists search failed.")
	}

	return models.Success(ctx, searchResults)
}
