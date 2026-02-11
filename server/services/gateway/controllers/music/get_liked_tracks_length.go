package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetLikedTracksLength(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	likedTracksLengthResponse, err := clients.MusicClient.GetLikedTracksLength(ctx.Context(), &musicpb.GetLikedTracksLengthRequest{
		LikerEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'GetLikedTracksLength' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Liked tracks length fetch failed.")
	}

	return models.Success(ctx, likedTracksLengthResponse)
}
