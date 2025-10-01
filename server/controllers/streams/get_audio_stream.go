package stream_controllers

import (
	"bytes"
	"os/exec"
	"wavelength/constants"
	"wavelength/env"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
)

func GetAudioStream(ctx *fiber.Ctx) error {
	ytDlpPath := env.GetYtDlpPath()
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	cmd := exec.Command(
		ytDlpPath,
		"-f", constants.SupportedAudioStreamingFormat,
		"-g", utils.GetYouTubeWatchUrl(videoId),
		"--cookies", env.GetYtCookiePath(),
	)

	var stderr bytes.Buffer

	cmd.Stderr = &stderr

	out, err := cmd.Output()

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "yt-dlp failed: "+err.Error()+" - "+stderr.String())
	}

	ytDlpOutput := string(out)
	audioURL := ytDlpOutput[:len(ytDlpOutput)-1]

	return ctx.Redirect(audioURL, 302)
}
