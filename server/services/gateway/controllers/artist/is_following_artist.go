package artist_controllers

import (
	"wavelength/proto/artistpb"
	"wavelength/services/gateway/models"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

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

	isFollowingResponse, err := shared_clients.ArtistClient.IsFollowingArtist(ctx.Context(), &artistpb.IsFollowingArtistRequest{
		BrowseId:      browseId,
		FollowerEmail: authUser.Email,
	})
	if err != nil {
		go logging.Logger.Error("ArtistService: 'IsFollowingArtist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Artist follow status fetch failed.")
	}

	return models.Success(ctx, isFollowingResponse)
}
