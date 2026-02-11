package music_controllers

import (
	"fmt"

	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	"github.com/Dev-Siri/wavelength/server/services/gateway/constants"
	"github.com/Dev-Siri/wavelength/server/shared/clients"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/gofiber/fiber/v2"
	"go.uber.org/zap"
)

func GetTrackThumbnail(ctx *fiber.Ctx) error {
	videoId := ctx.Params("videoId")
	if videoId == "" {
		return fiber.NewError(fiber.StatusBadRequest, "Video ID not provided.")
	}

	imageUrl := fmt.Sprintf("%s/vi/%s/maxresdefault.jpg", constants.YouTubeImageApiUrl, videoId)
	resizeImageResponse, err := clients.ImageClient.ResizeImage(ctx.Context(), &imagepb.ResizeImageRequest{
		ImageUrl: imageUrl,
		Height:   512,
		Width:    512,
	})
	if err != nil {
		logging.Logger.Error("ImageService: 'ResizeImage' errored.", zap.Error(err))
		return fiber.NewError(fiber.StatusInternalServerError, "Track thumbnail fetch failed.")
	}

	ctx.Type(resizeImageResponse.MimeType)
	return ctx.Send(resizeImageResponse.ImageData)
}
