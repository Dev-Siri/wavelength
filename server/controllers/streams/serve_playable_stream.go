package stream_controllers

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

func servePlayableStream(ctx *fiber.Ctx, streamPath string, contentType string) error {
	streamBytes, err := os.ReadFile(streamPath)
	streamSize := len(streamBytes)

	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Unable to open stream file: "+err.Error())
	}

	rangeHeader := ctx.Get("Range")

	if rangeHeader == "" {
		ctx.Set("Content-Length", fmt.Sprintf("%d", streamSize))
		ctx.Set("Content-Type", contentType)

		return ctx.Send(streamBytes)
	}

	var start, end int
	var s string

	if _, err := fmt.Sscanf(rangeHeader, "bytes=%s", &s); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid Range header.")
	}

	parts := strings.Split(s, "-")

	if len(parts) != 2 {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid Range header format.")
	}

	start, _ = strconv.Atoi(parts[0])

	if parts[1] == "" {
		end = streamSize - 1
	} else {
		end, _ = strconv.Atoi(parts[1])
	}

	if start > end || end >= streamSize {
		ctx.Status(fiber.StatusRequestedRangeNotSatisfiable)
		ctx.Set("Content-Range", fmt.Sprintf("bytes */%d", streamSize))
		return nil
	}

	chunk := streamBytes[start : end+1]

	ctx.Status(fiber.StatusPartialContent)
	ctx.Set("Content-Type", contentType)
	ctx.Set("Content-Length", fmt.Sprintf("%d", len(chunk)))
	ctx.Set("Content-Range", fmt.Sprintf("bytes %d-%d/%d", start, end, streamSize))
	return ctx.Send(chunk)
}
