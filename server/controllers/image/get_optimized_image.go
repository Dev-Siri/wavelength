package image_controllers

import (
	"io"
	"net/http"
	"wavelength/logging"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
	"github.com/h2non/bimg"
	"go.uber.org/zap"
)

func GetOptimizedImage(ctx *fiber.Ctx) error {
	imageUrl := ctx.Query("url")
	height := ctx.QueryInt("h")

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

	bodyBytes, err := io.ReadAll(response.Body)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read image bytes: "+err.Error())
	}

	if height == 0 {
		go logging.Logger.Error("Height not provided.")
		ctx.Set("Cache-Control", "public, max-age=86400")
		return ctx.Send(bodyBytes)
	}

	bImage := bimg.NewImage(bodyBytes)
	optimizedImageBytes, err := bImage.Process(bimg.Options{
		Height: height,
		Width:  0,
		Type:   bimg.AVIF,
		// Quality: 5,
	})

	if err != nil {
		go logging.Logger.Error("Failed to resize image.", zap.Error(err))
		ctx.Set("Cache-Control", "public, max-age=86400")
		return ctx.Send(bodyBytes)
	}

	ctx.Set("Cache-Control", "public, max-age=86400")
	ctx.Type("image/avif")
	return ctx.Send(optimizedImageBytes)
}
