package music_controllers

import (
	"wavelength/api"
	"wavelength/models/responses"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
)

func GetMusicDuration(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	call := api.YouTubeV3Client.Videos.List([]string{"contentDetails"}).Id(videoId)
	response, err := call.Do()

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get duration of track from YouTube: "+err.Error())
	}

	if len(response.Items) == 0 {
		return fiber.NewError(fiber.StatusNotFound, "Video not found.")
	}

	durationSeconds := utils.ParseDuration(response.Items[0].ContentDetails.Duration)

	return ctx.JSON(responses.Success(durationSeconds))
}
