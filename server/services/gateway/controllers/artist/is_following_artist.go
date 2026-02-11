package artist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func IsFollowingArtist(ctx *fiber.Ctx) error {
	browseId := ctx.Params("browseId")

	if browseId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Browse ID is required.")
	}

	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	isFollowingResponse, err := clients.ArtistClient.IsFollowingArtist(ctx.Context(), &artistpb.IsFollowingArtistRequest{
		BrowseId:      browseId,
		FollowerEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'IsFollowingArtist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist follow status fetch failed.")
	}

	return models.Success(ctx, isFollowingResponse)
}
