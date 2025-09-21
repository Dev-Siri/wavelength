package stream_controllers

import (
	"strconv"
	"strings"
	"wavelength/api"
	"wavelength/constants"
	"wavelength/models"
	"wavelength/models/responses"

	"github.com/gofiber/fiber/v2"
	yt_streams "github.com/kkdai/youtube/v2"
)

func GetAudioStream(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	video, err := api.YoutubeStreamClient.GetVideo(videoId)

	if err != nil {
		fiber.NewError(fiber.StatusInternalServerError, "Failed to get YouTube stream data: "+err.Error())
	}

	var mp4Format *yt_streams.Format = nil

	formats := video.Formats.WithAudioChannels()

	for _, format := range formats {
		if strings.Contains(format.MimeType, constants.SupportedStreamingFormat) {
			mp4Format = &format
		}
	}

	if mp4Format == nil {
		return fiber.NewError(fiber.StatusNotFound, "Cannot find any streams with the supported format. ("+constants.SupportedStreamingFormat+")")
	}

	duration, err := strconv.Atoi(mp4Format.ApproxDurationMs)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to parse duration of stream.")
	}

	durationSecond := duration / 1000

	return ctx.JSON(responses.Success[models.YouTubeStream]{
		Success: true,
		Data: models.YouTubeStream{
			Url:      mp4Format.URL,
			Ext:      mp4Format.MimeType,
			Abr:      mp4Format.Bitrate,
			Duration: durationSecond,
		},
	})
}
