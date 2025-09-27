package stream_controllers

import (
	"wavelength/api"
	"wavelength/constants"

	"github.com/gofiber/fiber/v2"
)

func GetAudioStream(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	video, err := api.YoutubeStreamClient.GetVideo(videoId)

	if err != nil {
		fiber.NewError(fiber.StatusInternalServerError, "Failed to get YouTube stream data: "+err.Error())
	}

	formats := video.Formats.WithAudioChannels().Type(constants.SupportedStreamingFormat)
	requiredFormat := &formats[0]

	return ctx.Redirect(requiredFormat.URL, 302)
}
