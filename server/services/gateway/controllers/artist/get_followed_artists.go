package artist_controllers

import (
	"wavelength/proto/artistpb"
	"wavelength/services/gateway/models"
	shared_clients "wavelength/shared/clients"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetFollowedArtists(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	followedArtistsResponse, err := shared_clients.ArtistClient.GetFollowedArtists(ctx.Context(), &artistpb.GetFollowedArtistsRequest{
		FollowerEmail: authUser.Email,
	})
	if err != nil {
		go logging.Logger.Error("ArtistService: 'GetFollowedArtist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Followed artists fetch failed.")
	}

	return models.Success(ctx, followedArtistsResponse)
}
