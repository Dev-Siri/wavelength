package music_controllers

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetLikedTracks(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	likedTracksResponse, err := clients.MusicClient.GetLikedTracks(ctx.Context(), &musicpb.GetLikedTracksRequest{
		LikerEmail: authUser.Email,
	})
	if err != nil {
		go logging.Logger.Error("MusicService: 'GetLikedTracks' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Liked tracks fetch failed.")
	}

	return models.Success(ctx, likedTracksResponse)
}
