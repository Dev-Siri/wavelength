package artist_controllers

import (
	"wavelength/proto/artistpb"
	"wavelength/services/gateway/models"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetArtistDetails(ctx *fiber.Ctx) error {
	id := ctx.Params("id")

	artistDetailsResponse, err := shared_clients.ArtistClient.GetArtistDetails(ctx.Context(), &artistpb.GetArtistDetailsRequest{
		BrowseId: id,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'GetArtistDetails' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist details fetch failed.")
	}

	return models.Success(ctx, artistDetailsResponse)
}
