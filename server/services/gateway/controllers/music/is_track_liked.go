package music_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/musicpb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func IsTrackLiked(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Parameter 'videoId' is required.")
	}

	authUser, ok := ctx.Locals("authUser").(models.AuthUser)

	if !ok {
		return fiber.NewError(fiber.StatusUnauthorized, "This route is protected. Login to Wavelength to access it's contents.")
	}

	isTrackLikedResponse, err := clients.MusicClient.IsTrackLiked(ctx.Context(), &musicpb.IsTrackLikedRequest{
		LikerEmail: authUser.Email,
		VideoId:    videoId,
	})
	if err != nil {
		logging.Logger.Error("MusicService: 'IsTrackLiked' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Liked status check failed.")
	}

	return models.Success(ctx, isTrackLikedResponse)
}
