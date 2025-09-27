package stream_controllers

import (
	"strings"
	"wavelength/api"
	"wavelength/constants"

	"github.com/gofiber/fiber/v2"
	yt_streams "github.com/kkdai/youtube/v2"
)

func GetVideoStream(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	video, err := api.YoutubeStreamClient.GetVideo(videoId)

	if err != nil {
		fiber.NewError(fiber.StatusInternalServerError, "Failed to get YouTube stream data: "+err.Error())
	}

	var mp4Format *yt_streams.Format = nil

	for _, format := range video.Formats {
		if strings.Contains(format.MimeType, constants.SupportedStreamingFormat) {
			mp4Format = &format
			break
		}
	}

	if mp4Format == nil {
		return fiber.NewError(fiber.StatusNotFound, "Cannot find any streams with the supported format. ("+constants.SupportedStreamingFormat+")")
	}

	return ctx.Redirect(mp4Format.URL, 302)
}
