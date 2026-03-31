package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetLikedTrackCount(ctx *fiber.Ctx) error {
	authUser, ok := ctx.Locals("authUser").(shared_models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	likedTrackCountResponse, err := clients.MusicClient.GetLikedTrackCount(ctx.Context(), &musicpb.GetLikedTrackCountRequest{
		LikerEmail: authUser.Email,
	})
	if err != nil {
		logging.Logger.Error("MusicServer: 'GetLikedTrackCount' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Like count read failed.")
	}

	return shared_models.Success(ctx, likedTrackCountResponse)
}
