package music_controllers

import (
	"wavelength/proto/musicpb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetLikedTrackCount(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	likedTrackCountResponse, err := clients.MusicClient.GetLikedTrackCount(ctx.Context(), &musicpb.GetLikedTrackCountRequest{
		LikerEmail: authUser.Email,
	})
	if err != nil {
		go logging.Logger.Error("MusicServer: 'GetLikedTrackCount' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Like count read failed.")
	}

	return ctx.JSON(models.Success(likedTrackCountResponse.LikeCount))
}
