package artist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetArtistDetails(ctx *fiber.Ctx) error {
	id := ctx.Params("id")

	artistDetailsResponse, err := clients.ArtistClient.GetArtistDetails(ctx.Context(), &artistpb.GetArtistDetailsRequest{
		BrowseId: id,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'GetArtistDetails' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist details fetch failed.")
	}

	return models.Success(ctx, artistDetailsResponse)
}
