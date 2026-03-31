package image_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/utils"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"
	shared_models "github.com/Dev-Siri/wavelength/server/shared/models"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetCoverEffectColor(ctx *fiber.Ctx) error {
	imageUrl := ctx.Query("imageUrl")
	if imageUrl == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Image URL not provided.")
	}

	if !utils.IsValidUrl(imageUrl) {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid image URL.")
	}

	themeColorResponse, err := clients.ImageClient.GetCoverEffectColors(ctx.Context(), &imagepb.GetCoverEffectColorsRequest{
		ImageUrl: imageUrl,
	})
	if err != nil {
		logging.Logger.Error("ImageService: 'GetCoverEffectColors' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Cover effect colors pick failed.")
	}

	return shared_models.Success(ctx, themeColorResponse)
}
