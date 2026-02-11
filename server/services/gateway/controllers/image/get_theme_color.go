package image_controllers

import (
	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/models"
	"github.com/Dev-Siri/wavelength/server/services/gateway/utils"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetThemeColor(ctx *fiber.Ctx) error {
	imageUrl := ctx.Query("imageUrl")
	if imageUrl == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Image URL not provided.")
	}

	if !utils.IsValidUrl(imageUrl) {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid image URL.")
	}

	themeColorResponse, err := clients.ImageClient.GetThemeColor(ctx.Context(), &imagepb.GetThemeColorRequest{
		ImageUrl: imageUrl,
	})
	if err != nil {
		logging.Logger.Error("ImageService: 'GetThemeColor' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Image theme color pick failed.")
	}

	return models.Success(ctx, themeColorResponse.ThemeColor)
}
