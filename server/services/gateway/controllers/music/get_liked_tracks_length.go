package music_controllers

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

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
		go logging.Logger.Error("MusicService: 'GetLikedTracksLength' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Liked tracks length fetch failed.")
	}

	return ctx.JSON(models.Success(likedTracksLengthResponse.LikedTracksLength))
}
