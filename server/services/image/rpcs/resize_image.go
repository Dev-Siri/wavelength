package image_rpcs

import (
	"context"
	"io"
	"net/http"

	"github.com/Dev-Siri/wavelength/server/proto/imagepb"
	"github.com/Dev-Siri/wavelength/server/shared/logging"

	"github.com/h2non/bimg"
	"go.uber.org/zap"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func (i *ImageService) ResizeImage(
	ctx context.Context,
	request *imagepb.ResizeImageRequest,
) (*imagepb.ResizeImageResponse, error) {
	response, err := http.Get(request.ImageUrl)
	if err != nil {
		logging.Logger.Error("Image fetch failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Image fetch failed.")
	}

	defer response.Body.Close()

	bodyBytes, err := io.ReadAll(response.Body)
	if err != nil {
		logging.Logger.Error("Image bytes read failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Image bytes read failed.")
	}

	// Hard-coded as jpeg for simplicity.
	const mimeType = "jpeg"
	bImage := bimg.NewImage(bodyBytes)
	resizedBodyBytes, err := bImage.ResizeAndCrop(int(request.Height), int(request.Width))

	if err != nil {
		logging.Logger.Error("Image resize failed.", zap.Error(err))
		return nil, status.Error(codes.Internal, "Image resize failed.")
	}

	return &imagepb.ResizeImageResponse{
		ImageData: resizedBodyBytes,
		MimeType:  mimeType,
	}, nil
}
