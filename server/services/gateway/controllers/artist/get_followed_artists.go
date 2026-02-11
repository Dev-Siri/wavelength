package artist_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/artistpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetFollowedArtists(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)
	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	followedArtistsResponse, err := clients.ArtistClient.GetFollowedArtists(ctx.Context(), &artistpb.GetFollowedArtistsRequest{
		FollowerEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("ArtistService: 'GetFollowedArtist' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Followed artists fetch failed.")
	}

	return models.Success(ctx, followedArtistsResponse)
}
