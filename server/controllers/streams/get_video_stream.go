package stream_controllers

import (
	"io"
	"os/exec"
	"wavelength/constants"
	"wavelength/env"
	"wavelength/utils"

	"github.com/gofiber/fiber/v2"
)

func GetVideoStream(ctx *fiber.Ctx) error {
	ytDlpPath := env.GetYtDlpPath()
	videoId := ctx.Params("videoId")

	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID is required.")
	}

	rangeHeader := ctx.Get("Range")
	playbackRange, err := utils.ParseRangeHeader(rangeHeader)

	if err != nil {
		return err
	}

	cmd := exec.Command(
		ytDlpPath,
		"-f", constants.SupportedVideoStreamingFormat,
		"--cookies", env.GetYtCookiePath(),
		"--no-check-certificate",
		"-o", "-",
		utils.GetYouTubeWatchUrl(videoId),
	)

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to pipe: "+err.Error())
	}

	if err := cmd.Start(); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "yt-dlp start error: "+err.Error())
	}

	if playbackRange != nil {
		return handleRangeRequest(ctx, stdout, cmd, playbackRange.Start, playbackRange.End)
	}

	ctx.Set("Content-Type", "video/mp4")
	ctx.Set("Accept-Ranges", "bytes")

	_, err = io.Copy(ctx.Response().BodyWriter(), stdout)

	if err != nil {
		cmd.Process.Kill()
		return fiber.NewError(fiber.StatusInternalServerError, "stream copy error: "+err.Error())
	}

	if err := cmd.Wait(); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "yt-dlp failed: "+err.Error())
	}

	return nil
}
