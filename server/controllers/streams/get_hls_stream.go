package stream_controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"wavelength/constants"
	"wavelength/env"
	"wavelength/models"

	"github.com/gofiber/fiber/v2"
)

func GetHlsStream(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	serverUrl := env.GetYtDlpServerUrl()
	streamUrl := fmt.Sprintf("%s/stream-hls?videoId=%s", serverUrl, videoId)
	response, err := http.Get(streamUrl)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get stream from yt-dlp: "+err.Error())
	}

	var hlsStreamResponse models.HlsStreamShape

	if err := json.NewDecoder(response.Body).Decode(&hlsStreamResponse); err != nil {
		return err
	}

	if len(hlsStreamResponse.Streams) == 0 {
		return fiber.NewError(fiber.StatusNotFound, "No HLS streams found.")
	}

	var supportedStream *models.HlsStream

	for _, stream := range hlsStreamResponse.Streams {
		if stream.VideoExt == "none" && stream.AudioExt == constants.SupportedHlsStreamingFormat {
			supportedStream = &stream
			break
		}

		if stream.AudioExt == "none" && stream.VideoExt == constants.SupportedHlsStreamingFormat {
			supportedStream = &stream
			break
		}
	}

	if supportedStream == nil {
		return fiber.NewError(fiber.StatusNotFound, "No supported HLS streams found.")
	}

	m3u8Response, err := http.Get(supportedStream.URL)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get HLS of video: "+err.Error())
	}

	hlsContent, err := io.ReadAll(m3u8Response.Body)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read HLS response: "+err.Error())
	}

	ctx.Type("application/vnd.apple.mpegurl")
	return ctx.Send(hlsContent)
}
