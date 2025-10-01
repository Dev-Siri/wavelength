package stream_controllers

import (
	"fmt"
	"io"
	"os/exec"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

func handleRangeRequest(ctx *fiber.Ctx, stdout io.ReadCloser, cmd *exec.Cmd, start, end int64) error {
	data, err := io.ReadAll(stdout)

	if err != nil {
		cmd.Process.Kill()
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to read stream: "+err.Error())
	}

	if err := cmd.Wait(); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "yt-dlp failed: "+err.Error())
	}

	totalSize := int64(len(data))

	if start >= totalSize {
		ctx.Set("Content-Range", fmt.Sprintf("bytes */%d", totalSize))
		return fiber.NewError(fiber.StatusRequestedRangeNotSatisfiable, "Range start exceeds file size")
	}

	if end == -1 || end >= totalSize {
		end = totalSize - 1
	}

	if start > end {
		return fiber.NewError(fiber.StatusRequestedRangeNotSatisfiable, "Invalid range: start > end")
	}

	contentLength := end - start + 1
	contentRange := fmt.Sprintf("bytes %d-%d/%d", start, end, totalSize)

	ctx.Set("Content-Type", "audio/mp4")
	ctx.Set("Content-Range", contentRange)
	ctx.Set("Content-Length", strconv.FormatInt(contentLength, 10))
	ctx.Set("Accept-Ranges", "bytes")
	ctx.Status(fiber.StatusPartialContent)

	_, err = ctx.Write(data[start : end+1])
	if err != nil {

		return fiber.NewError(fiber.StatusInternalServerError, "Failed to write range: "+err.Error())
	}

	return nil
}
