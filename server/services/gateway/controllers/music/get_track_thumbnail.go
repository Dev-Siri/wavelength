package music_controllers

import (
	"fmt"
	"io"
	"net/http"
	"wavelength/services/gateway/constants"

	"github.com/gofiber/fiber/v2"
	"github.com/h2non/bimg"
)

func GetTrackThumbnail(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID not provided.")
	}

	imageUrl := fmt.Sprintf("%s/vi/%s/maxresdefault.jpg", constants.YouTubeImageApiUrl, videoId)
	response, err := http.Get(imageUrl)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch image from the provided URL: "+err.Error())
	}

	defer response.Body.Close()

	bodyBytes, err := io.ReadAll(response.Body)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read image bytes: "+err.Error())
	}

	bImage := bimg.NewImage(bodyBytes)

	resizedBodyBytes, err := bImage.ResizeAndCrop(512, 512)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get higher quality thumbnail.")
	}

	ctx.Type("jpeg")
	return ctx.Send(resizedBodyBytes)
}
