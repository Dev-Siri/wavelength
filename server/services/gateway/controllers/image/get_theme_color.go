package image_controllers

import (
	_ "image/jpeg"
	_ "image/png"
	"wavelength/proto/imagepb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/utils"
	"wavelength/shared/logging"

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
