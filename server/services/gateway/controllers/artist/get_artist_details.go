package artist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetArtistDetails(ctx *fiber.Ctx) error {
	browseID := ctx.Params("browseId")
	if browseID == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Browse ID (browseId) is required.")
	}

	artistDetailsResponse, err := clients.ArtistClient.GetArtistDetails(ctx.Context(), &artistpb.GetArtistDetailsRequest{
		BrowseId: browseID,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'GetArtistDetails' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist details fetch failed.")
	}

	return shared_models.Success(ctx, artistDetailsResponse)
}
