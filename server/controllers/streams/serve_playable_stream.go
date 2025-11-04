package stream_controllers

import (
	"fmt"
	"io"
	"os"

	"github.com/gofiber/fiber/v2"
)

func servePlayableStream(ctx *fiber.Ctx, streamPath string, contentType string) error {
	file, err := os.Open(streamPath)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Unable to open stream file: "+err.Error())
	}

	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Unable to stat stream file: "+err.Error())
	}

	fileSize := stat.Size()
	ctx.Set(fiber.HeaderContentType, contentType)
	ctx.Set(fiber.HeaderAcceptRanges, "bytes")
	ctx.Set(fiber.HeaderConnection, "keep-alive")

	rangeHeader := ctx.Get("Range")
	if rangeHeader == "" {
		ctx.Set(fiber.HeaderContentLength, fmt.Sprintf("%d", fileSize))
		_, err = io.Copy(ctx.Response().BodyWriter(), file)
		return err
	}

	var start, end int64

	_, err = fmt.Sscanf(rangeHeader, "bytes=%d-%d", &start, &end)
	if err != nil {
		if _, err := fmt.Sscanf(rangeHeader, "bytes=%d-", &start); err != nil {
			return fiber.NewError(fiber.StatusBadRequest, "Invalid Range header.")
		}
		end = fileSize - 1
	}

	if end == 0 || end >= fileSize {
		end = fileSize - 1
	}

	if start > end || start >= fileSize {
		ctx.Status(fiber.StatusRequestedRangeNotSatisfiable)
		ctx.Set(fiber.HeaderContentRange, fmt.Sprintf("bytes */%d", fileSize))
		return nil
	}

	length := end - start + 1
	ctx.Status(fiber.StatusPartialContent)
	ctx.Set(fiber.HeaderContentLength, fmt.Sprintf("%d", length))
	ctx.Set(fiber.HeaderContentRange, fmt.Sprintf("bytes %d-%d/%d", start, end, fileSize))

	_, err = file.Seek(start, io.SeekStart)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Seek failed: "+err.Error())
	}

	_, err = io.CopyN(ctx.Response().BodyWriter(), file, length)
	return err
}
