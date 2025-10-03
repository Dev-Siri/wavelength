package stream_controllers

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"wavelength/constants"
	"wavelength/env"

	"github.com/gofiber/fiber/v2"
)

func GetAudioStream(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	existingStreamPath := fmt.Sprintf("/tmp/streams/%s-aud.mp4", videoId)

	if _, err := os.Stat(existingStreamPath); err == nil {
		return servePlayableStream(ctx, existingStreamPath, "audio/mp4")
	}

	serverUrl := env.GetYtDlpServerUrl()
	streamUrl := fmt.Sprintf("%s/stream-url?videoId=%s&format=%s", serverUrl, videoId, constants.SupportedAudioStreamingFormat)
	response, err := http.Get(streamUrl)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get stream from yt-dlp: "+err.Error())
	}

	bodyBytes, err := io.ReadAll(response.Body)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get stream: "+err.Error())
	}

	streamPathOnSys := string(bodyBytes)

	return servePlayableStream(ctx, streamPathOnSys, "audio/mp4")
}
