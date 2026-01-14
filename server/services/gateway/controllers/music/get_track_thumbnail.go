package music_controllers

import (
	"fmt"
	"wavelength/proto/imagepb"
	"wavelength/services/gateway/clients"
	"wavelength/services/gateway/constants"
	"wavelength/shared/logging"

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
