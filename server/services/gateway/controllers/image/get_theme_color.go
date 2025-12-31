package image_controllers

import (
	"image"
	_ "image/jpeg"
	_ "image/png"
	"net/http"
	"wavelength/services/gateway/models"
	"wavelength/services/gateway/utils"

	"github.com/cenkalti/dominantcolor"
	"github.com/gofiber/fiber/v2"
	_ "golang.org/x/image/webp"
)

func GetThemeColor(ctx *fiber.Ctx) error {
	imageUrl := ctx.Query("imageUrl")

	if imageUrl == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Image URL not provided.")
	}

	if !utils.IsValidUrl(imageUrl) {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid image URL.")
	}

	response, err := http.Get(imageUrl)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch image from the provided URL: "+err.Error())
	}

	defer response.Body.Close()

	img, _, err := image.Decode(response.Body)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to decode image: "+err.Error())
	}

	color := dominantcolor.Find(img)

	return ctx.JSON(models.Success(
		models.ThemeColor{
			R: color.R,
			G: color.G,
			B: color.B,
		}))
}
